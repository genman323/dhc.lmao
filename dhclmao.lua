-- Alt Control Script for Da Hood
-- Controls alternate accounts with commands from a host player

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

-- Local Player and Host Setup
local player = Players.LocalPlayer
print("Local player initialized: " .. player.Name)
local hostName = "Sab3r_PRO2003"
local hostPlayer = nil
local character = player.Character or player.CharacterAdded:Wait()
print("Character loaded for " .. player.Name)
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- State Variables
local isDropping = false
local currentMode = nil -- "swarm", "follow", "airlock", "setup", nil
local currentTarget = nil
local originalCFrame = nil
local connections = {
    drop = nil,
    swarm = nil,
    follow = nil,
    fps = nil,
    afk = nil,
    airlockFreeze = nil,
    setupMove = nil,
    grab = nil
}
local lastDropTime = 0
local dropCooldown = 0.1
local mainEvent = ReplicatedStorage:WaitForChild("MainEvent")
if mainEvent then
    print("mainEvent found in ReplicatedStorage")
else
    warn("mainEvent not found in ReplicatedStorage")
end
local airlockPlatform = nil
local airlockPosition = nil

-- Utility Functions
local function waitForHost(timeout)
    local success, result = pcall(function()
        return Players:WaitForChild(hostName, timeout)
    end)
    if success and result then
        print("Host player " .. hostName .. " found")
        return result
    else
        warn("Host player " .. hostName .. " not found within " .. timeout .. " seconds.")
        return nil
    end
end

local function getPlayers()
    return Players:GetPlayers()
end

local function disableAllSeats()
    for _, seat in pairs(game.Workspace:GetDescendants()) do
        if seat:IsA("Seat") then
            seat.Disabled = true
        end
    end
end

local function toggleNoclip(char, enable)
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and not part:IsA("Accessory") then
            part.CanCollide = not enable
            part.Velocity = Vector3.new(0, 0, 0)
        end
    end
end

local function createAirlockPlatform(position)
    if airlockPlatform then
        airlockPlatform:Destroy()
    end
    airlockPlatform = Instance.new("Part")
    airlockPlatform.Size = Vector3.new(20, 0.5, 20)
    airlockPlatform.Position = position
    airlockPlatform.Anchored = true
    airlockPlatform.CanCollide = true
    airlockPlatform.Transparency = 1
    airlockPlatform.Parent = game.Workspace
    return airlockPlatform
end

-- Command Functions
local function disableCurrentMode()
    if humanoidRootPart then
        humanoidRootPart.Anchored = false
    end
    if currentMode == "swarm" and connections.swarm then
        connections.swarm:Disconnect()
        connections.swarm = nil
    elseif currentMode == "follow" and connections.follow then
        connections.follow:Disconnect()
        connections.follow = nil
    elseif currentMode == "airlock" and connections.airlockFreeze then
        connections.airlockFreeze:Disconnect()
        connections.airlockFreeze = nil
    elseif currentMode == "setup" and connections.setupMove then
        connections.setupMove:Disconnect()
        connections.setupMove = nil
    elseif currentMode == "grab" and connections.grab then
        connections.grab:Disconnect()
        connections.grab = nil
    end
    if airlockPlatform then
        airlockPlatform:Destroy()
        airlockPlatform = nil
    end
    currentMode = nil
    currentTarget = nil
    airlockPosition = nil
    toggleNoclip(character, false)
end

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
    local spacing = 1
    local behindDirection = -targetRoot.CFrame.LookVector
    local offsetPosition = targetRoot.Position + behindDirection * (spacing * (index + 1))
    local targetCFrame = CFrame.lookAt(offsetPosition, targetRoot.Position)
    local startTime = tick()
    local duration = 0.5
    local startCFrame = humanoidRootPart.CFrame
    currentMode = "setup"
    if connections.setupMove then
        connections.setupMove:Disconnect()
    end
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
            connections.setupMove:Disconnect()
            connections.setupMove = nil
        end
    end)
    toggleNoclip(character, false)
end

local function setupClub()
    disableCurrentMode()
    if not humanoidRootPart then
        warn("Setup club failed: Local character not found")
        return
    end
    toggleNoclip(character, true)
    local clubPos = Vector3.new(-265, -7, -380)
    local players = getPlayers()
    local index = getAltIndex(player.Name, players)
    local totalAlts = #players - 1
    local maxAlts = 20
    if totalAlts > maxAlts then
        totalAlts = maxAlts
    end
    local rows = 5
    local cols = 4
    local spacing = 2
    local halfWidth = (cols * spacing) / 2
    local halfDepth = (rows * spacing) / 2
    local row = math.floor(index / cols)
    local col = index % cols
    local offsetX = -halfWidth + (col * spacing) + (spacing / 2)
    local offsetZ = -halfDepth + (row * spacing) + (spacing / 2)
    local offsetPosition = clubPos + Vector3.new(offsetX, 0, offsetZ)
    local targetCFrame = CFrame.new(offsetPosition, offsetPosition + Vector3.new(0, 0, -1))
    local startTime = tick()
    local duration = 0.5
    local startCFrame = humanoidRootPart.CFrame
    currentMode = "setup"
    if connections.setupMove then
        connections.setupMove:Disconnect()
    end
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
            connections.setupMove:Disconnect()
            connections.setupMove = nil
        end
    end)
    toggleNoclip(character, false)
    return clubPos
end

local function setupBank()
    disableCurrentMode()
    if not humanoidRootPart then
        warn("Setup bank failed: Local character not found")
        return
    end
    toggleNoclip(character, true)
    local bankPos = Vector3.new(-376, 21, -283)
    local players = getPlayers()
    local index = getAltIndex(player.Name, players)
    local totalAlts = #players - 1
    local maxAlts = 20
    if totalAlts > maxAlts then
        totalAlts = maxAlts
    end
    local rows = 5
    local cols = 4
    local spacing = 2
    local halfWidth = (cols * spacing) / 2
    local halfDepth = (rows * spacing) / 2
    local row = math.floor(index / cols)
    local col = index % cols
    local offsetX = -halfWidth + (col * spacing) + (spacing / 2)
    local offsetZ = -halfDepth + (row * spacing) + (spacing / 2)
    local offsetPosition = bankPos + Vector3.new(offsetX, 0, offsetZ)
    local targetCFrame = CFrame.new(offsetPosition, offsetPosition + Vector3.new(0, 0, -1))
    local startTime = tick()
    local duration = 0.5
    local startCFrame = humanoidRootPart.CFrame
    currentMode = "setup"
    if connections.setupMove then
        connections.setupMove:Disconnect()
    end
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
            connections.setupMove:Disconnect()
            connections.setupMove = nil
        end
    end)
    toggleNoclip(character, false)
end

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
        if currentMode ~= "swarm" or not humanoidRootPart or not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
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
        if currentMode ~= "follow" or not humanoidRootPart or not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
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
    local targetHeight = commonY + 13
    local platformPosition = Vector3.new(originalCFrame.Position.X, targetHeight - 0.5, originalCFrame.Position.Z)
    airlockPlatform = createAirlockPlatform(platformPosition)
    airlockPosition = CFrame.new(platformPosition + Vector3.new(0, 1, 0))
    toggleNoclip(character, true)
    humanoidRootPart.CFrame = airlockPosition
    humanoidRootPart.Anchored = true
    toggleNoclip(character, false)
    task.wait(0.1)
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

local function unairlock()
    if airlockPlatform then
        airlockPlatform:Destroy()
        airlockPlatform = nil
    end
    if connections.airlockFreeze then
        connections.airlockFreeze:Disconnect()
        connections.airlockFreeze = nil
    end
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

local function unswarm()
    disableCurrentMode()
    setup(hostPlayer)
end

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

local function grabAndBring(target, destination)
    if getAltIndex(player.Name, getPlayers()) ~= 0 then
        warn("Only the first alt performs grab for this command.")
        return
    end
    disableCurrentMode()
    if not target or not target.Character or not target.Character:FindFirstChild("UpperTorso") or not target.Character:FindFirstChild("HumanoidRootPart") or not target.Character:FindFirstChild("BodyEffects") or not humanoidRootPart or not humanoid then
        warn("Grab and bring failed: Invalid target or local character")
        return
    end
    toggleNoclip(character, true)
    local targetChar = target.Character
    local bodyEffects = targetChar.BodyEffects
    local combat = character:FindFirstChild("Combat") or player.Backpack:FindFirstChild("Combat")
    if not combat then
        warn("No Combat tool found for punching")
        toggleNoclip(character, false)
        return
    end
    humanoid:EquipTool(combat)
    currentMode = "grab"
    connections.grab = RunService.RenderStepped:Connect(function()
        if currentMode ~= "grab" or not targetChar or not bodyEffects["K.O"] then
            connections.grab:Disconnect()
            connections.grab = nil
            toggleNoclip(character, false)
            return
        end
        if bodyEffects["K.O"].Value then
            humanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, math.pi, 0)
            local vim = game:GetService("VirtualInputManager")
            vim:SendKeyEvent(true, Enum.KeyCode.G, false, game)
            task.wait(0.1)
            vim:SendKeyEvent(false, Enum.KeyCode.G, false, game)
            task.wait(0.5)
            humanoid:MoveTo(destination)
            connections.grab:Disconnect()
            connections.grab = nil
            currentMode = nil
            toggleNoclip(character, false)
        else
            humanoidRootPart.CFrame = targetChar.UpperTorso.CFrame * CFrame.new(0, 0, -2) * CFrame.Angles(0, math.pi, 0)
            combat:Activate()
        end
    end)
end

local function buyMask()
    disableCurrentMode()
    if not humanoidRootPart then
        warn("Buy mask failed: Local character not found, retrying...")
        task.wait(2)
        humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
        if not humanoidRootPart then
            warn("Retry failed: HumanoidRootPart not found")
            return
        end
    end
    if not mainEvent then
        warn("mainEvent not found, cannot buy mask.")
        return
    end
    toggleNoclip(character, true)
    local maskShopPos = Vector3.new(-254, 21, -412) -- Replace with your exact coordinates
    print("Teleporting to mask shop at: " .. tostring(maskShopPos))
    humanoidRootPart.CFrame = CFrame.new(maskShopPos)
    task.wait(0.5)
    local success, err = pcall(function()
        mainEvent:FireServer("BuyItem", "Surgeon Mask")
    end)
    if not success then
        warn("Failed to buy mask: " .. err)
    else
        print("Attempted to buy Surgeon Mask")
    end
    task.wait(0.5)
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local mask = backpack:FindFirstChild("Surgeon Mask")
        if mask and humanoid then
            humanoid:EquipTool(mask)
            print("Equipped Surgeon Mask")
        else
            warn("Surgeon Mask not found in backpack")
        end
    end
    task.wait(0.5)
    setup(hostPlayer)
    toggleNoclip(character, false)
end

local function dropAllCash()
    if not mainEvent then
        warn("MainEvent not found, cannot drop cash.")
        return
    end
    isDropping = true
    if connections.drop then
        connections.drop:Disconnect()
    end
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

local function stopDrop()
    isDropping = false
    if connections.drop then
        connections.drop:Disconnect()
        connections.drop = nil
    end
    if mainEvent then
        pcall(function()
            mainEvent:FireServer("Block", false)
        end)
    end
end

local function kickAlt()
    pcall(function()
        player:Kick("Kicked by your host.")
    end)
end

local function rejoinGame()
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end)
end

-- Anti-Cheat Bypass
local detectionFlags = {
    "CHECKER_1", "CHECKER", "TeleportDetect", "OneMoreTime", "BRICKCHECK",
    "BADREQUEST", "BANREMOTE", "KICKREMOTE", "PERMAIDBAN", "PERMABAN"
}

local oldNamecall
local success, err = pcall(function()
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if method == "FireServer" and self.Name == "MainEvent" and table.find(detectionFlags, args[1]) then
            return wait(9e9)
        end
        return oldNamecall(self, ...)
    end)
end)
if success then
    print("Anti-cheat bypass with hookmetamethod initialized")
else
    warn("Failed to initialize hookmetamethod: " .. err .. ". Anti-cheat bypass disabled.")
end

-- UI Setup
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

-- Performance Optimization
local function limitFPS()
    local targetDeltaTime = 1 / 5
    local lastTime = tick()
    connections.fps = RunService.RenderStepped:Connect(function(deltaTime)
        local currentTime = tick()
        local elapsed = currentTime - lastTime
        if elapsed < targetDeltaTime then
            task.wait(targetDeltaTime - elapsed)
        end
        lastTime = currentTime
    end)
end

local function preventAFK()
    connections.afk = RunService.Heartbeat:Connect(function()
        if humanoid then
            humanoid.Jump = true
            task.wait(0.1)
            humanoid.Jump = false
        end
    end)
end

-- Alt Positioning
local function getAltIndex(playerName, players)
    local alts = {}
    for _, p in pairs(players) do
        if p ~= hostPlayer then
            table.insert(alts, p)
        end
    end
    table.sort(alts, function(a, b) return a.Name < b.Name end)
    local maxAlts = 20
    if #alts > maxAlts then
        warn("Limiting to " .. maxAlts .. " alts due to maximum capacity.")
        alts = table.move(alts, 1, maxAlts, 1, {})
    end
    for i, p in ipairs(alts) do
        if p.Name == playerName then
            return i - 1
        end
    end
    return 0
end

-- Event Handlers
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == hostPlayer then
        kickAlt()
    end
end)

hostPlayer.CharacterAdded:Connect(function(newChar)
    if currentTarget == hostPlayer then
        if currentMode == "swarm" then
            swarm(hostPlayer)
        end
        if currentMode == "follow" then
            follow(hostPlayer)
        end
    end
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    humanoid = newChar:WaitForChild("Humanoid")
    if currentMode and currentTarget then
        if currentMode == "swarm" then
            swarm(currentTarget)
        end
        if currentMode == "follow" then
            follow(currentTarget)
        end
        if currentMode == "airlock" and airlockPosition then
            airlock()
        end
        if currentMode == "setup" and currentTarget == nil then
            if currentTarget == nil and setupClub then
                setupClub()
            end
        end
        if currentMode == "grab" then
        end
    end
end)

player.AncestryChanged:Connect(function()
    if not player:IsDescendantOf(game) then
        for key, conn in pairs(connections) do
            if conn then
                conn:Disconnect()
            end
            connections[key] = nil
        end
        isDropping = false
        currentMode = nil
        currentTarget = nil
        airlockPosition = nil
        if airlockPlatform then
            airlockPlatform:Destroy()
            airlockPlatform = nil
        end
    end
end)

-- Command Handler
hostPlayer.Chatted:Connect(function(message)
    local lowerMsg = string.lower(message)
    if string.sub(lowerMsg, 1, 1) ~= "?" then
        return
    end
    local cmd = string.sub(lowerMsg, 2):match("^%s*(.-)%s*$")
    if cmd == "" then
        return
    end
    if cmd == "setup host" then
        setup(hostPlayer)
    elseif cmd:match("^setup%s+(.+)$") then
        local targetName = cmd:match("^setup%s+(.+)$")
        if targetName == "club" then
            setupClub()
        elseif targetName == "bank" then
            setupBank()
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
    elseif cmd:match("^bring%s+(.+)$") then
        local targetName = cmd:match("^bring%s+(.+)$")
        local target = nil
        local destination = nil
        if targetName == "host" then
            target = hostPlayer
            destination = Vector3.new(-265, -7, -380)
        else
            target = Players:FindFirstChild(targetName)
            if target then
                destination = hostPlayer.Character and hostPlayer.Character:FindFirstChild("HumanoidRootPart") and hostPlayer.Character.HumanoidRootPart.Position or Vector3.new(0, 0, 0)
            end
        end
        if target and destination then
            grabAndBring(target, destination)
        else
            warn("Bring failed: Player " .. targetName .. " not found")
        end
    elseif cmd == "drop" then
        dropAllCash()
    elseif cmd == "stop" then
        stopDrop()
    elseif cmd == "kick" then
        kickAlt()
    elseif cmd == "rejoin" then
        rejoinGame()
    elseif cmd == "mask" then
        print("Executing ?mask command")
        buyMask()
    else
        warn("Unknown command: " .. cmd)
    end
end)

-- Initialization
hostPlayer = waitForHost(10)
if not hostPlayer then
    warn("Script cannot proceed without host player. Shutting down.")
    return
end

createOverlay()
limitFPS()
preventAFK()
disableAllSeats()
print("dhc.lmao Alt Control Script loaded for " .. player.Name .. " in Da Hood")
