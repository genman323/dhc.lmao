local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local hostName = "2tacticalforyou"
local hostPlayer = nil
local character = nil
local humanoidRootPart = nil
local humanoid = nil
local isDropping = false
local currentMode = nil -- "swarm", "follow", "airlock", "setup", nil
local currentTarget = nil
local originalCFrame = nil
local connections = {drop = nil, swarm = nil, follow = nil, fps = nil, afk = nil, airlockFreeze = nil, setupMove = nil}
local lastDropTime, dropCooldown = 0, 0.1
local mainEvent = ReplicatedStorage:WaitForChild("MainEvent")
local airlockPlatform = nil
local airlockPosition = nil
local isHost = false -- Role flag

-- Anti-cheat bypass with safety
local detectionFlags = {"CHECKER_1", "CHECKER", "TeleportDetect", "OneMoreTime", "BRICKCHECK", "BADREQUEST", "BANREMOTE", "KICKREMOTE", "PERMAIDBAN", "PERMABAN"}
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
if not success then
    warn("Failed to set up anti-cheat bypass: " .. tostring(err))
end

if not mainEvent then
    warn("MainEvent not found. Some features like dropping cash may not work.")
end

-- Wait for host
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

-- Utility functions
local function getPlayers()
    return Players:GetPlayers()
end

local function disableAllSeats()
    for _, seat in pairs(game.Workspace:GetDescendants()) do
        if seat:IsA("Seat") then seat.Disabled = true end
    end
end

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

local function preventAFK()
    connections.afk = RunService.Heartbeat:Connect(function()
        if humanoid then
            humanoid.Jump = true
            task.wait(0.1)
            humanoid.Jump = false
        end
    end)
end

local function getAltIndex(playerName, players)
    local alts = {}
    for _, p in pairs(players) do if p ~= hostPlayer then table.insert(alts, p) end end
    table.sort(alts, function(a, b) return a.Name < b.Name end)
    local maxAlts = 20
    if #alts > maxAlts then
        warn("Limiting to " .. maxAlts .. " alts due to maximum capacity.")
        alts = table.move(alts, 1, maxAlts, 1, {})
    end
    for i, p in ipairs(alts) do if p.Name == playerName then return i - 1 end end
    return 0
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
    if airlockPlatform then airlockPlatform:Destroy() end
    airlockPlatform = Instance.new("Part")
    airlockPlatform.Size = Vector3.new(20, 0.5, 20)
    airlockPlatform.Position = position
    airlockPlatform.Anchored = true
    airlockPlatform.CanCollide = true
    airlockPlatform.Transparency = 1
    airlockPlatform.Parent = game.Workspace
    return airlockPlatform
end

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
    if character then toggleNoclip(character, false) end
end

-- Movement functions
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
    if connections.setupMove then connections.setupMove:Disconnect() end
    connections.setupMove = RunService.RenderStepped:Connect(function()
        if currentMode ~= "setup" or not humanoidRootPart then
            if connections.setupMove then connections.setupMove:Disconnect() end
            connections.setupMove = nil
            return
        end
        local elapsed = tick() - startTime
        local t = math.min(elapsed / duration, 1)
        humanoidRootPart.CFrame = startCFrame:Lerp(targetCFrame, t)
        if t >= 1 then
            if connections.setupMove then connections.setupMove:Disconnect() end
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
    if totalAlts > maxAlts then totalAlts = maxAlts end
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
    if connections.setupMove then connections.setupMove:Disconnect() end
    connections.setupMove = RunService.RenderStepped:Connect(function()
        if currentMode ~= "setup" or not humanoidRootPart then
            if connections.setupMove then connections.setupMove:Disconnect() end
            connections.setupMove = nil
            return
        end
        local elapsed = tick() - startTime
        local t = math.min(elapsed / duration, 1)
        humanoidRootPart.CFrame = startCFrame:Lerp(targetCFrame, t)
        if t >= 1 then
            if connections.setupMove then connections.setupMove:Disconnect() end
            connections.setupMove = nil
        end
    end)
    toggleNoclip(character, false)
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
    if totalAlts > maxAlts then totalAlts = maxAlts end
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
    if connections.setupMove then connections.setupMove:Disconnect() end
    connections.setupMove = RunService.RenderStepped:Connect(function()
        if currentMode ~= "setup" or not humanoidRootPart then
            if connections.setupMove then connections.setupMove:Disconnect() end
            connections.setupMove = nil
            return
        end
        local elapsed = tick() - startTime
        local t = math.min(elapsed / duration, 1)
        humanoidRootPart.CFrame = startCFrame:Lerp(targetCFrame, t)
        if t >= 1 then
            if connections.setupMove then connections.setupMove:Disconnect() end
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

local function stopDrop()
    isDropping = false
    if connections.drop then connections.drop:Disconnect(); connections.drop = nil end
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

-- GUI creation
local function createRoleSelectionGUI()
    if not player:FindFirstChild("PlayerGui") then
        warn("PlayerGui not found.")
        return
    end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RoleSelectionGUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Select Role"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = frame

    local altButton = Instance.new("TextButton")
    altButton.Size = UDim2.new(0, 120, 0, 50)
    altButton.Position = UDim2.new(0, 30, 0, 80)
    altButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    altButton.Text = "Alt"
    altButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    altButton.TextSize = 18
    altButton.Font = Enum.Font.Gotham
    altButton.Parent = frame
    local altCorner = Instance.new("UICorner")
    altCorner.CornerRadius = UDim.new(0, 8)
    altCorner.Parent = altButton

    local hostButton = Instance.new("TextButton")
    hostButton.Size = UDim2.new(0, 120, 0, 50)
    hostButton.Position = UDim2.new(0, 150, 0, 80)
    hostButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    hostButton.Text = "Host"
    hostButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    hostButton.TextSize = 18
    hostButton.Font = Enum.Font.Gotham
    hostButton.Parent = frame
    local hostCorner = Instance.new("UICorner")
    hostCorner.CornerRadius = UDim.new(0, 8)
    hostCorner.Parent = hostButton

    local function onRoleSelected(role)
        isHost = (role == "Host")
        screenGui:Destroy()
        createMainGUI()
        if not isHost then
            -- Start listening for commands if Alt
            hostPlayer.Chatted:Connect(function(message)
                handleCommand(message)
            end)
        end
    end

    altButton.MouseButton1Click:Connect(function() onRoleSelected("Alt") end)
    hostButton.MouseButton1Click:Connect(function() onRoleSelected("Host") end)
end

local function createMainGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DhcControlGUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = frame

    -- Make GUI draggable
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "dhc.lmao Control"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = frame

    if isHost then
        -- Host GUI with buttons
        local buttonConfigs = {
            {Text = "Setup Host", Func = function() setup(hostPlayer) end, YOffset = 70},
            {Text = "Setup Club", Func = setupClub, YOffset = 120},
            {Text = "Setup Bank", Func = setupBank, YOffset = 170},
            {Text = "Swarm Host", Func = function() swarm(hostPlayer) end, YOffset = 220},
            {Text = "Unswarm", Func = unswarm, YOffset = 270},
            {Text = "Follow Host", Func = function() follow(hostPlayer) end, YOffset = 320},
            {Text = "Unfollow", Func = function() disableCurrentMode(); setup(hostPlayer) end, YOffset = 370},
            {Text = "Airlock", Func = airlock, YOffset = 420},
            {Text = "Unairlock", Func = unairlock, YOffset = 470},
            {Text = "Bring", Func = bring, YOffset = 520},
            {Text = "Drop Cash", Func = dropAllCash, YOffset = 570},
            {Text = "Stop Drop", Func = stopDrop, YOffset = 620},
            {Text = "Kick Alts", Func = kickAlt, YOffset = 670},
            {Text = "Rejoin", Func = rejoinGame, YOffset = 720}
        }

        for _, config in ipairs(buttonConfigs) do
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(0, 240, 0, 40)
            button.Position = UDim2.new(0, 30, 0, config.YOffset)
            button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            button.Text = config.Text
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.TextSize = 16
            button.Font = Enum.Font.Gotham
            button.Parent = frame
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 8)
            btnCorner.Parent = button
            button.MouseButton1Click:Connect(config.Func)
        end

        local targetLabel = Instance.new("TextLabel")
        targetLabel.Size = UDim2.new(0, 240, 0, 30)
        targetLabel.Position = UDim2.new(0, 30, 0, 770)
        targetLabel.BackgroundTransparency = 1
        targetLabel.Text = "Target Player:"
        targetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        targetLabel.TextSize = 14
        targetLabel.Font = Enum.Font.Gotham
        targetLabel.Parent = frame

        local targetBox = Instance.new("TextBox")
        targetBox.Size = UDim2.new(0, 240, 0, 40)
        targetBox.Position = UDim2.new(0, 30, 0, 800)
        targetBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        targetBox.Text = ""
        targetBox.PlaceholderText = "Enter player name"
        targetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        targetBox.TextSize = 14
        targetBox.Font = Enum.Font.Gotham
        targetBox.Parent = frame
        local boxCorner = Instance.new("UICorner")
        boxCorner.CornerRadius = UDim.new(0, 8)
        boxCorner.Parent = targetBox

        local setupTargetButton = Instance.new("TextButton")
        setupTargetButton.Size = UDim2.new(0, 120, 0, 40)
        setupTargetButton.Position = UDim2.new(0, 30, 0, 850)
        setupTargetButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        setupTargetButton.Text = "Setup Target"
        setupTargetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        setupTargetButton.TextSize = 14
        setupTargetButton.Font = Enum.Font.Gotham
        setupTargetButton.Parent = frame
        local setupCorner = Instance.new("UICorner")
        setupCorner.CornerRadius = UDim.new(0, 8)
        setupCorner.Parent = setupTargetButton
        setupTargetButton.MouseButton1Click:Connect(function()
            local targetName = targetBox.Text
            local target = Players:FindFirstChild(targetName)
            if target then
                setup(target)
            else
                warn("Setup failed: Player " .. targetName .. " not found")
            end
        end)

        local swarmTargetButton = Instance.new("TextButton")
        swarmTargetButton.Size = UDim2.new(0, 120, 0, 40)
        swarmTargetButton.Position = UDim2.new(0, 150, 0, 850)
        swarmTargetButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        swarmTargetButton.Text = "Swarm Target"
        swarmTargetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        swarmTargetButton.TextSize = 14
        swarmTargetButton.Font = Enum.Font.Gotham
        swarmTargetButton.Parent = frame
        local swarmCorner = Instance.new("UICorner")
        swarmCorner.CornerRadius = UDim.new(0, 8)
        swarmCorner.Parent = swarmTargetButton
        swarmTargetButton.MouseButton1Click:Connect(function()
            local targetName = targetBox.Text
            local target = Players:FindFirstChild(targetName)
            if target then
                swarm(target)
            else
                warn("Swarm failed: Player " .. targetName .. " not found")
            end
        end)

        local followTargetButton = Instance.new("TextButton")
        followTargetButton.Size = UDim2.new(0, 120, 0, 40)
        followTargetButton.Position = UDim2.new(0, 30, 0, 900)
        followTargetButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        followTargetButton.Text = "Follow Target"
        followTargetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        followTargetButton.TextSize = 14
        followTargetButton.Font = Enum.Font.Gotham
        followTargetButton.Parent = frame
        local followCorner = Instance.new("UICorner")
        followCorner.CornerRadius = UDim.new(0, 8)
        followCorner.Parent = followTargetButton
        followTargetButton.MouseButton1Click:Connect(function()
            local targetName = targetBox.Text
            local target = Players:FindFirstChild(targetName)
            if target then
                follow(target)
            else
                warn("Follow failed: Player " .. targetName .. " not found")
            end
        end)
    else
        -- Alt GUI (minimal, shows status)
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(1, 0, 0, 50)
        statusLabel.Position = UDim2.new(0, 0, 0, 70)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = "Alt Mode: Waiting for commands"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        statusLabel.TextSize = 16
        statusLabel.Font = Enum.Font.Gotham
        statusLabel.TextXAlignment = Enum.TextXAlignment.Center
        statusLabel.Parent = frame
    end
end

-- Command handler for Alt mode
local function handleCommand(message)
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
end

-- Event handlers
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == hostPlayer then kickAlt() end
end)

hostPlayer.CharacterAdded:Connect(function(newChar)
    if currentTarget == hostPlayer then
        if currentMode == "swarm" then swarm(hostPlayer) end
        if currentMode == "follow" then follow(hostPlayer) end
    end
end)

local function onCharacterAdded(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart", 10)
    humanoid = newChar:WaitForChild("Humanoid", 10)
    if not humanoidRootPart or not humanoid then
        warn("Failed to find HumanoidRootPart or Humanoid in character.")
        return
    end
    if currentMode and currentTarget then
        if currentMode == "swarm" then swarm(currentTarget) end
        if currentMode == "follow" then follow(currentTarget) end
        if currentMode == "airlock" and airlockPosition then airlock() end
        if currentMode == "setup" and currentTarget == nil then
            if currentTarget == nil and setupClub then setupClub() end
        end
    end
end

player.CharacterAdded:Connect(onCharacterAdded)

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

-- Initialize
local function initializeScript()
    disableAllSeats()
    limitFPS()
    preventAFK()
    createRoleSelectionGUI()
    print("dhc.lmao Alt Control Script with GUI loaded for " .. player.Name .. " in Da Hood")
end

if player.Character then
    onCharacterAdded(player.Character)
    initializeScript()
else
    player.CharacterAdded:Wait()
    onCharacterAdded(player.Character)
    initializeScript()
end
