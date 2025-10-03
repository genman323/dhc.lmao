local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer
local hostName = "Sab3r_PRO2003"
local hostPlayer = nil
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local isDropping = false
local currentMode = nil  -- "swarm", "follow", "airlock", "setup", nil
local currentTarget = nil
local originalCFrame = nil
local connections = {drop = nil, swarm = nil, follow = nil, fps = nil, afk = nil, airlockFreeze = nil, setupMove = nil}
local lastDropTime, dropCooldown = 0, 0.1
local mainEvent = ReplicatedStorage:WaitForChild("MainEvent")
local airlockPlatform = nil
local airlockPosition = nil  -- Store airlock target position

-- Anti-cheat bypass hook
local detectionFlags = {
    "CHECKER_1", "CHECKER", "TeleportDetect", "OneMoreTime", "BRICKCHECK",
    "BADREQUEST", "BANREMOTE", "KICKREMOTE", "PERMAIDBAN", "PERMABAN"
}
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if method == "FireServer" and self.Name == "MainEvent" and table.find(detectionFlags, args[1]) then
        return wait(9e9)  -- Block detection
    end
    return oldNamecall(self, ...)
end)

if not mainEvent then
    warn("MainEvent not found. Some features like dropping cash may not work.")
end

-- Wait for host with timeout
local function waitForHost(timeout)
    local success, result = pcall(function()
        return Players:WaitForChild(hostName, timeout)
    end)
    if success and result then
        return result
    else
        warn("Host player " .. hostName .. " not found within " .. timeout .. " seconds.")
        return nil
    end
end
hostPlayer = waitForHost(10)
if not hostPlayer then
    warn("Script cannot proceed without host player. Shutting down.")
    return
end

-- Cache player list once per function call
local function getPlayers()
    return Players:GetPlayers()
end

-- Disable all seats
local function disableAllSeats()
    for _, seat in pairs(game.Workspace:GetDescendants()) do
        if seat:IsA("Seat") then seat.Disabled = true end
    end
end

-- Create overlay UI
local function createOverlay()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.Name = "DhcOverlay"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 200, 0, 50)
    textLabel.Position = UDim2.new(0.5, -100, 0.5, -25)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "dhc.lmao"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 24
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = frame
end

-- Limit FPS to reduce client load
local function limitFPS()
    local targetDeltaTime = 1 / 5
    local lastTime = tick()
    connections.fps = RunService.RenderStepped:Connect(function(deltaTime)
        local currentTime = tick()
        local elapsed = currentTime - lastTime
        if elapsed < targetDeltaTime then task.wait(targetDeltaTime - elapsed) end
        lastTime = currentTime
    end)
end

-- Prevent AFK kicking
local function preventAFK()
    connections.afk = RunService.Heartbeat:Connect(function()
        if humanoid then
            humanoid.Jump = true
            task.wait(0.1)
            humanoid.Jump = false
        end
    end)
end

-- Get alt index for positioning
local function getAltIndex(playerName, players)
    local alts = {}
    for _, p in pairs(players) do if p ~= hostPlayer then table.insert(alts, p) end end
    table.sort(alts, function(a, b) return a.Name < b.Name end)
    for i, p in ipairs(alts) do if p.Name == playerName then return i - 1 end end
    return 0
end

-- Toggle noclip for character
local function toggleNoclip(char, enable)
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and not part:IsA("Accessory") then
            part.CanCollide = not enable
            part.Velocity = Vector3.new(0, 0, 0)  -- Reset velocity to reduce glitching
        end
    end
end

-- Create airlock platform
local function createAirlockPlatform(position)
    if airlockPlatform then airlockPlatform:Destroy() end
    airlockPlatform = Instance.new("Part")
    airlockPlatform.Size = Vector3.new(20, 0.5, 20)  -- Larger platform for stability
    airlockPlatform.Position = position
    airlockPlatform.Anchored = true
    airlockPlatform.CanCollide = true
    airlockPlatform.Transparency = 1  -- Invisible
    airlockPlatform.Parent = game.Workspace
    return airlockPlatform
end

-- Disable current mode
local function disableCurrentMode()
    if humanoidRootPart then humanoidRootPart.Anchored = false end
    if currentMode == "swarm" then
        if connections.swarm then connections.swarm:Disconnect(); connections.swarm = nil end
    elseif currentMode == "follow" then
        if connections.follow then connections.follow:Disconnect(); connections.follow = nil end
    elseif currentMode == "airlock" then
        if connections.airlockFreeze then connections.airlockFreeze:Disconnect(); connections.airlockFreeze = nil end
    elseif currentMode == "setup" then
        if connections.setupMove then connections.setupMove:Disconnect(); connections.setupMove = nil end
    end
    if airlockPlatform then airlockPlatform:Destroy() airlockPlatform = nil end
    currentMode = nil
    currentTarget = nil
    airlockPosition = nil
    toggleNoclip(character, false)
end

-- Setup line behind target player
local function setup(targetPlayer)
    disableCurrentMode()
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") or not humanoidRootPart then
        warn("Setup failed: Invalid target or local character")
        return
    end
    toggleNoclip(character, true)
    local targetRoot = targetPlayer.Character.HumanoidRootPart
    local players = getPlayers()
    local index = getAltIndex(player.Name, players)
    local spacing = 1  -- 1 stud spacing for single-file line
    local behindDirection = -targetRoot.CFrame.LookVector
    local offsetPosition = targetRoot.Position + behindDirection * (spacing * (index + 1))
    local targetCFrame = CFrame.lookAt(offsetPosition, targetRoot.Position)
    
    local startTime = tick()
    local duration = 0.5  -- Smooth transition over 0.5 seconds
    local startCFrame = humanoidRootPart.CFrame
    currentMode = "setup"
    
    if connections.setupMove then connections.setupMove:Disconnect() end
    connections.setupMove = RunService.RenderStepped:Connect(function()
        if currentMode ~= "setup" or not humanoidRootPart then
            connections.setupMove:Disconnect()
            connections.setupMove = nil
            return
        end
        local elapsed = tick() - startTime
        local t = math.min(elapsed / duration, 1)
        humanoidRootPart.CFrame = startCFrame:Lerp(targetCFrame, t)
        if t >= 1 then
            humanoidRootPart.Anchored = true
            connections.setupMove:Disconnect()
            connections.setupMove = nil
        end
    end)
    toggleNoclip(character, false)
end

-- Setup line in middle of club
local function setupClub()
    disableCurrentMode()
    if not humanoidRootPart then
        warn("Setup club failed: Local character not found")
        return
    end
    toggleNoclip(character, true)
    local clubPos = Vector3.new(-265, -7, -380) -- Updated to your exact club spot
    local players = getPlayers()
    local index = getAltIndex(player.Name, players)
    local spacing = 1 -- 1 stud spacing for single-file line
    local behindDirection = Vector3.new(0, 0, -1) -- Fixed direction for line (along -Z)
    local offsetPosition = clubPos + behindDirection * (spacing * (index + 1))
    local targetCFrame = CFrame.lookAt(offsetPosition, clubPos)
  
    local startTime = tick()
    local duration = 0.5 -- Smooth transition over 0.5 seconds
    local startCFrame = humanoidRootPart.CFrame
    currentMode = "setup"
  
    if connections.setupMove then connections.setupMove:Disconnect() end
    connections.setupMove = RunService.RenderStepped:Connect(function()
        if currentMode ~= "setup" or not humanoidRootPart then
            connections.setupMove:Disconnect()
            connections.setupMove = nil
            return
        end
        local elapsed = tick() - startTime
        local t = math.min(elapsed / duration, 1)
        humanoidRootPart.CFrame = startCFrame:Lerp(targetCFrame, t)
        if t >= 1 then
            humanoidRootPart.Anchored = true
            connections.setupMove:Disconnect()
            connections.setupMove = nil
        end
    end)
    toggleNoclip(character, false)
end
-- Swarm around target
local function swarm(targetPlayer)
    disableCurrentMode()
    currentMode = "swarm"
    currentTarget = targetPlayer
    if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") or not humanoidRootPart then
        warn("Swarm failed: Invalid target or local character")
        currentMode = nil
        currentTarget = nil
        return
    end
    toggleNoclip(character, true)
    connections.swarm = RunService.RenderStepped:Connect(function()
        if currentMode ~= "swarm" or not humanoidRootPart or not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then return end
        local center = currentTarget.Character.HumanoidRootPart.Position
        local hash = 0
        for i = 1, #player.Name do
            hash = hash + string.byte(player.Name, i)
        end
        local angle = (hash % 360) / 180 * math.pi + os.clock() * 2
        local radius = 10
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        local position = center + Vector3.new(x, 0, z)
        humanoidRootPart.CFrame = CFrame.lookAt(position, center)
        task.wait(0.05)
    end)
end

-- Follow target
local function follow(targetPlayer)
    disableCurrentMode()
    currentMode = "follow"
    currentTarget = targetPlayer
    if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") or not humanoidRootPart then
        warn("Follow failed: Invalid target or local character")
        currentMode = nil
        currentTarget = nil
        return
    end
    toggleNoclip(character, true)
    connections.follow = RunService.RenderStepped:Connect(function()
        if currentMode ~= "follow" or not humanoidRootPart or not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then return end
        local targetRoot = currentTarget.Character.HumanoidRootPart
        local targetPos = targetRoot.Position
        local players = getPlayers()
        local index = getAltIndex(player.Name, players)
        local offsetDistance = 1 + (index * 1)
        local behindOffset = -targetRoot.CFrame.LookVector * offsetDistance
        local myPos = targetPos + behindOffset
        local lookPos = targetPos
        local currentCFrame = humanoidRootPart.CFrame
        local targetCFrame = CFrame.lookAt(myPos, lookPos)
        humanoidRootPart.CFrame = currentCFrame:Lerp(targetCFrame, 0.5)
        task.wait(0.01)
    end)
end

-- Airlock alts
local function airlock()
    disableCurrentMode()
    if not humanoidRootPart or not humanoid then
        warn("Airlock failed: Humanoid or HumanoidRootPart not found")
        return
    end
    originalCFrame = humanoidRootPart.CFrame
    local players = getPlayers()
    local index = getAltIndex(player.Name, players)
    local commonY = (hostPlayer.Character and hostPlayer.Character:FindFirstChild("HumanoidRootPart") and hostPlayer.Character.HumanoidRootPart.Position.Y) or originalCFrame.Position.Y
    local targetHeight = commonY + 13  -- Move 13 studs up
    local platformPosition = Vector3.new(originalCFrame.Position.X, targetHeight - 0.5, originalCFrame.Position.Z)  -- Platform just below character
    airlockPlatform = createAirlockPlatform(platformPosition)
    airlockPosition = CFrame.new(platformPosition + Vector3.new(0, 1, 0))  -- Store target position
    toggleNoclip(character, true)
    humanoidRootPart.CFrame = airlockPosition
    humanoidRootPart.Anchored = true  -- Anchor to prevent falling
    toggleNoclip(character, false)
    task.wait(0.1)  -- Brief delay to ensure position sets
    -- Use a custom loop to enforce position
    if not connections.airlockFreeze then
        connections.airlockFreeze = RunService.RenderStepped:Connect(function()
            if currentMode == "airlock" and humanoidRootPart and airlockPosition then
                humanoidRootPart.CFrame = airlockPosition
                humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                humanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
            end
        end)
    end
    currentMode = "airlock"
end

-- Unairlock alts
local function unairlock()
    if airlockPlatform then airlockPlatform:Destroy() airlockPlatform = nil end
    if connections.airlockFreeze then connections.airlockFreeze:Disconnect(); connections.airlockFreeze = nil end
    if not humanoidRootPart or not humanoid or not originalCFrame then
        warn("Unairlock failed: Missing required components")
        return
    end
    toggleNoclip(character, true)
    humanoidRootPart.Anchored = false
    humanoidRootPart.CFrame = originalCFrame
    toggleNoclip(character, false)
    originalCFrame = nil
    airlockPosition = nil
    currentMode = nil
end

-- Unswarm
local function unswarm()
    disableCurrentMode()
    setup(hostPlayer)
end

-- Bring alts to host
local function bring()
    disableCurrentMode()
    if not hostPlayer or not hostPlayer.Character or not hostPlayer.Character:FindFirstChild("HumanoidRootPart") or not humanoidRootPart then
        warn("Bring failed: Invalid host or local character")
        return
    end
    toggleNoclip(character, true)
    local hostRoot = hostPlayer.Character.HumanoidRootPart
    local players = getPlayers()
    local index = getAltIndex(player.Name, players)
    local angle = index * (2 * math.pi / #players)
    local radius = 2
    local x = math.cos(angle) * radius
    local z = math.sin(angle) * radius
    local targetPosition = hostRoot.Position + Vector3.new(x, 0, z)
    local targetCFrame = CFrame.lookAt(targetPosition, hostRoot.Position)
    humanoidRootPart.CFrame = targetCFrame
    toggleNoclip(character, false)
end

-- Drop cash repeatedly
local function dropAllCash()
    if not mainEvent then
        warn("MainEvent not found, cannot drop cash.")
        return
    end
    isDropping = true
    if connections.drop then connections.drop:Disconnect() end
    connections.drop = RunService.Heartbeat:Connect(function()
        if isDropping then
            local currentTime = tick()
            if currentTime - lastDropTime >= dropCooldown then
                pcall(function()
                    mainEvent:FireServer("DropMoney", 15000)
                    mainEvent:FireServer("Block", true)
                end)
                lastDropTime = currentTime
            end
        end
    end)
end

-- Stop dropping cash
local function stopDrop()
    isDropping = false
    if connections.drop then connections.drop:Disconnect(); connections.drop = nil end
    if mainEvent then
        pcall(function()
            mainEvent:FireServer("Block", false)
        end)
    end
end

-- Kick alt
local function kickAlt()
    pcall(function()
        player:Kick("Kicked by you're host.")
    end)
end

-- Rejoin game
local function rejoinGame()
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end)
end

-- Handle host leaving
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == hostPlayer then kickAlt() end
end)

-- Handle host character reset
hostPlayer.CharacterAdded:Connect(function(newChar)
    if currentTarget == hostPlayer then
        if currentMode == "swarm" then swarm(hostPlayer) end
        if currentMode == "follow" then follow(hostPlayer) end
    end
end)

-- Handle commands from host
hostPlayer.Chatted:Connect(function(message)
    local lowerMsg = string.lower(message)
    if string.sub(lowerMsg, 1, 1) ~= "?" then return end
    local cmd = string.sub(lowerMsg, 2):match("^%s*(.-)%s*$")
    if cmd == "" then return end

    if cmd == "setup host" then
        setup(hostPlayer)
    elseif cmd:match("^setup%s+(.+)$") then
        local targetName = cmd:match("^setup%s+(.+)$")
        if targetName == "club" then
            setupClub()
        else
            local target = Players:FindFirstChild(targetName)
            if target then
                setup(target)
            else
                warn("Setup failed: Player " .. targetName .. " not found")
            end
        end
    elseif cmd == "swarm host" then
        swarm(hostPlayer)
    elseif cmd:match("^swarm%s+(.+)$") then
        local targetName = cmd:match("^swarm%s+(.+)$")
        local target = Players:FindFirstChild(targetName)
        if target then
            swarm(target)
        else
            warn("Swarm failed: Player " .. targetName .. " not found")
        end
    elseif cmd == "unswarm" then
        unswarm()
    elseif cmd == "follow host" then
        follow(hostPlayer)
    elseif cmd:match("^follow%s+(.+)$") then
        local targetName = cmd:match("^follow%s+(.+)$")
        local target = Players:FindFirstChild(targetName)
        if target then
            follow(target)
        else
            warn("Follow failed: Player " .. targetName .. " not found")
        end
    elseif cmd == "unfollow" then
        disableCurrentMode()
        setup(hostPlayer)
    elseif cmd == "airlock" then
        airlock()
    elseif cmd == "unairlock" then
        unairlock()
    elseif cmd == "bring" then
        bring()
    elseif cmd == "drop" then
        dropAllCash()
    elseif cmd == "stop" then
        stopDrop()
    elseif cmd == "kick" then
        kickAlt()
    elseif cmd == "rejoin" then
        rejoinGame()
    else
        warn("Unknown command: " .. cmd)
    end
end)

-- Handle player character reset
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    humanoid = newChar:WaitForChild("Humanoid")
    if currentMode and currentTarget then
        if currentMode == "swarm" then swarm(currentTarget) end
        if currentMode == "follow" then follow(currentTarget) end
        if currentMode == "airlock" and airlockPosition then airlock() end
        if currentMode == "setup" and currentTarget == nil then setupClub() end  -- Reapply club setup if targeted nil
    end
end)

-- Cleanup connections when player leaves
player.AncestryChanged:Connect(function()
    if not player:IsDescendantOf(game) then
        for key, conn in pairs(connections) do
            if conn then conn:Disconnect() end
            connections[key] = nil
        end
        isDropping = false
        currentMode = nil
        currentTarget = nil
        airlockPosition = nil
        if airlockPlatform then airlockPlatform:Destroy() airlockPlatform = nil end
    end
end)

-- Initialize script
createOverlay()
limitFPS()
preventAFK()
disableAllSeats()
print("dhc.lmao Alt Control Script loaded for " .. player.Name .. " in Da Hood")
