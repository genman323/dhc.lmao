local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer
local hostName = "Sab3r_PRO2003"
local hostPlayer = nil
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local isDropping = false
local currentMode = nil  -- "swarm", "follow", "stack", nil
local currentTarget = nil
local originalCFrame = nil
local connections = {drop = nil, swarm = nil, follow = nil, fps = nil, afk = nil}
local lastDropTime, dropCooldown = 0, 0.1
local mainEvent = ReplicatedStorage:WaitForChild("MainEvent")

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

-- Reusable tween function
local function tweenToPosition(rootPart, targetCFrame, duration, easingStyle, delay)
    if not rootPart or not character then return end
    toggleNoclip(character, true)
    rootPart.Anchored = false
    local tweenInfo = TweenInfo.new(duration, easingStyle or Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
    if delay then task.wait(delay) end
    tween:Play()
    tween.Completed:Wait()
    toggleNoclip(character, false)
end

-- Toggle noclip for character
local function toggleNoclip(char, enable)
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and not part:IsA("Accessory") then
            part.CanCollide = not enable
        end
    end
end

-- Disable current mode
local function disableCurrentMode()
    if currentMode == "swarm" then
        if connections.swarm then connections.swarm:Disconnect(); connections.swarm = nil end
    elseif currentMode == "follow" then
        if connections.follow then connections.follow:Disconnect(); connections.follow = nil end
    elseif currentMode == "stack" then
        humanoidRootPart.Anchored = false
    end
    currentMode = nil
    currentTarget = nil
    toggleNoclip(character, false)
end

-- Setup line behind target
local function setup(targetPlayer)
    disableCurrentMode()
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        warn("Setup failed: Invalid target")
        return
    end
    local targetRoot = targetPlayer.Character.HumanoidRootPart
    local players = getPlayers()
    local index = getAltIndex(player.Name, players)
    local spacing = 1
    local behindDirection = -targetRoot.CFrame.LookVector
    local offsetPosition = targetRoot.Position + behindDirection * spacing * (index + 1)
    local targetCFrame = CFrame.lookAt(offsetPosition, targetRoot.Position)
    tweenToPosition(humanoidRootPart, targetCFrame, 0.8, Enum.EasingStyle.Cubic, index * 0.1)
end

-- Swarm around target
local function swarm(targetPlayer)
    disableCurrentMode()
    currentMode = "swarm"
    currentTarget = targetPlayer
    if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then
        warn("Swarm failed: Invalid target")
        currentMode = nil
        currentTarget = nil
        return
    end
    toggleNoclip(character, true)
    connections.swarm = RunService.RenderStepped:Connect(function()
        if not currentMode == "swarm" or not humanoidRootPart or not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then return end
        local center = currentTarget.Character.HumanoidRootPart.Position
        local radius = 10
        local players = getPlayers()
        local index = getAltIndex(player.Name, players)
        local angle = (index * math.pi / 2) + (os.clock() * 4)  -- Faster speed
        local x, z = math.cos(angle) * radius, math.sin(angle) * radius
        local position = center + Vector3.new(x, 0, z)
        local lookAtCFrame = CFrame.lookAt(position, center)
        tweenToPosition(humanoidRootPart, lookAtCFrame, 0.1, Enum.EasingStyle.Sine)
    end)
end

-- Follow target
local function follow(targetPlayer)
    disableCurrentMode()
    currentMode = "follow"
    currentTarget = targetPlayer
    if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then
        warn("Follow failed: Invalid target")
        currentMode = nil
        currentTarget = nil
        return
    end
    toggleNoclip(character, true)
    local players = getPlayers()
    local index = getAltIndex(player.Name, players)
    task.wait(index * 0.1)
    connections.follow = RunService.RenderStepped:Connect(function()
        if not currentMode == "follow" or not humanoidRootPart or not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then return end
        local targetRoot = currentTarget.Character.HumanoidRootPart
        local targetPos = targetRoot.Position
        local offsetDistance = 1 + (index * 1)  -- 1 stud spacing
        local behindOffset = -targetRoot.CFrame.LookVector * offsetDistance
        local myPos = targetPos + behindOffset
        local lookPos = targetPos
        tweenToPosition(humanoidRootPart, CFrame.lookAt(myPos, lookPos), 0.15, Enum.EasingStyle.Cubic)
    end)
end

-- Stack on target
local function stack(targetPlayer)
    disableCurrentMode()
    currentMode = "stack"
    currentTarget = targetPlayer
    if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then
        warn("Stack failed: Invalid target")
        currentMode = nil
        currentTarget = nil
        return
    end
    local targetRoot = currentTarget.Character.HumanoidRootPart
    local basePosition = targetRoot.Position
    local heightOffset = 5  -- Perfect spacing for characters
    local players = getPlayers()
    local index = getAltIndex(player.Name, players)
    local targetPosition = Vector3.new(basePosition.X, basePosition.Y + (index + 1) * heightOffset, basePosition.Z)
    local targetCFrame = CFrame.new(targetPosition) * targetRoot.CFrame.Rotation
    humanoidRootPart.Anchored = false
    task.wait(index * 0.1)
    tweenToPosition(humanoidRootPart, targetCFrame, 1.0, Enum.EasingStyle.Quad)
    humanoidRootPart.Anchored = true
end

-- Airlock alts
local function airlock()
    disableCurrentMode()
    if not humanoidRootPart then return end
    originalCFrame = humanoidRootPart.CFrame
    local players = getPlayers()
    local index = getAltIndex(player.Name, players)
    local targetHeight = originalCFrame.Position.Y + 10  -- Exactly 10 studs up
    local targetCFrame = CFrame.new(originalCFrame.Position.X, targetHeight, originalCFrame.Position.Z) * originalCFrame.Rotation
    tweenToPosition(humanoidRootPart, targetCFrame, 0.5, Enum.EasingStyle.Quad, index * 0.1)
    humanoidRootPart.Anchored = true
end

-- Unairlock alts
local function unairlock()
    if not humanoidRootPart or not originalCFrame then return end
    humanoidRootPart.Anchored = false
    tweenToPosition(humanoidRootPart, originalCFrame, 0.5, Enum.EasingStyle.Quad)
    originalCFrame = nil
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
        if currentMode == "stack" then stack(hostPlayer) end
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
        local target = Players:FindFirstChild(targetName)
        if target then
            setup(target)
        else
            warn("Setup failed: Player " .. targetName .. " not found")
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
        disableCurrentMode()
        setup(hostPlayer)
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
    elseif cmd == "stack host" then
        stack(hostPlayer)
    elseif cmd:match("^stack%s+(.+)$") then
        local targetName = cmd:match("^stack%s+(.+)$")
        local target = Players:FindFirstChild(targetName)
        if target then
            stack(target)
        else
            warn("Stack failed: Player " .. targetName .. " not found")
        end
    elseif cmd == "airlock" then
        airlock()
    elseif cmd == "unairlock" then
        unairlock()
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
        if currentMode == "stack" then stack(currentTarget) end
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
    end
end)

-- Initialize script
createOverlay()
limitFPS()
preventAFK()
disableAllSeats()
print("dhc.lmao Alt Control Script loaded for " .. player.Name)
