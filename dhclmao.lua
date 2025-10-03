local config = getgenv().AltControlConfig
if not config then
    warn("AltControlConfig not found. Script cannot proceed.")
    return
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local isHost = player.UserId == config.HostUserId
local isAlt = table.find(config.AltUserIds, player.UserId) ~= nil
if not isHost and not isAlt then
    warn("This script is only for the configured host or alts. Shutting down.")
    return
end

-- Create overlay for everyone (host and alts) - always shows
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
    print("Overlay created for " .. player.Name)
end

-- Host GUI (only for host)
if isHost then
    local function createGUI()
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "AltControlGUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = player:WaitForChild("PlayerGui")

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 250, 0, 400)
        frame.Position = UDim2.new(0.5, -125, 0.5, -200)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.BorderSizePixel = 0
        frame.Parent = screenGui

        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 8)
        uiCorner.Parent = frame

        local uiStroke = Instance.new("UIStroke")
        uiStroke.Color = Color3.fromRGB(100, 100, 100)
        uiStroke.Transparency = 0.5
        uiStroke.Parent = frame

        local titleFrame = Instance.new("Frame")
        titleFrame.Size = UDim2.new(1, 0, 0, 30)
        titleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        titleFrame.BorderSizePixel = 0
        titleFrame.Parent = frame

        local titleCorner = Instance.new("UICorner")
        titleCorner.CornerRadius = UDim.new(0, 8)
        titleCorner.Parent = titleFrame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -30, 1, 0)
        titleLabel.Position = UDim2.new(0, 10, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = "Alt Control"
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextSize = 18
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = titleFrame

        local closeButton = Instance.new("TextButton")
        closeButton.Size = UDim2.new(0, 30, 0, 30)
        closeButton.Position = UDim2.new(1, -30, 0, 0)
        closeButton.BackgroundTransparency = 1
        closeButton.Text = "X"
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.TextSize = 18
        closeButton.Font = Enum.Font.Gotham
        closeButton.Parent = titleFrame
        closeButton.MouseButton1Click:Connect(function()
            screenGui:Destroy()
        end)

        local scrollingFrame = Instance.new("ScrollingFrame")
        scrollingFrame.Size = UDim2.new(1, 0, 1, -30)
        scrollingFrame.Position = UDim2.new(0, 0, 0, 30)
        scrollingFrame.BackgroundTransparency = 1
        scrollingFrame.ScrollBarThickness = 4
        scrollingFrame.Parent = frame

        local uiListLayout = Instance.new("UIListLayout")
        uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        uiListLayout.Padding = UDim.new(0, 5)
        uiListLayout.Parent = scrollingFrame

        local targetBox = Instance.new("TextBox")
        targetBox.Size = UDim2.new(1, -10, 0, 30)
        targetBox.Position = UDim2.new(0, 5, 0, 0)
        targetBox.PlaceholderText = "Target Player Name"
        targetBox.Text = ""
        targetBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        targetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        targetBox.BorderSizePixel = 0
        targetBox.Font = Enum.Font.Gotham
        targetBox.TextSize = 14
        targetBox.Parent = scrollingFrame

        local targetCorner = Instance.new("UICorner")
        targetCorner.CornerRadius = UDim.new(0, 4)
        targetCorner.Parent = targetBox

        local targetStroke = Instance.new("UIStroke")
        targetStroke.Color = Color3.fromRGB(80, 80, 80)
        targetStroke.Parent = targetBox

        local function addButton(text, cmdFunc)
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, -10, 0, 30)
            button.Text = text
            button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.BorderSizePixel = 0
            button.Font = Enum.Font.Gotham
            button.TextSize = 14
            button.Parent = scrollingFrame
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = button
            local btnStroke = Instance.new("UIStroke")
            btnStroke.Color = Color3.fromRGB(80, 80, 80)
            btnStroke.Parent = button
            button.MouseButton1Click:Connect(function()
                local cmd = cmdFunc()
                if cmd then
                    player:Chat("?" .. cmd)
                    print("Sent command: ?" .. cmd) -- Debug
                end
            end)
        end

        addButton("Setup Host", function() return "setup host" end)
        addButton("Setup Club", function() return "setup club" end)
        addButton("Setup Bank", function() return "setup bank" end)
        addButton("Setup Target", function()
            local target = targetBox.Text
            if target == "" then return nil end
            return "setup " .. target
        end)
        addButton("Swarm Host", function() return "swarm host" end)
        addButton("Swarm Target", function()
            local target = targetBox.Text
            if target == "" then return nil end
            return "swarm " .. target
        end)
        addButton("Unswarm", function() return "unswarm" end)
        addButton("Follow Host", function() return "follow host" end)
        addButton("Follow Target", function()
            local target = targetBox.Text
            if target == "" then return nil end
            return "follow " .. target
        end)
        addButton("Unfollow", function() return "unfollow" end)
        addButton("Airlock", function() return "airlock" end)
        addButton("Unairlock", function() return "unairlock" end)
        addButton("Bring", function() return "bring" end)
        addButton("Drop", function() return "drop" end)
        addButton("Stop Drop", function() return "stop" end)
        addButton("Kick Alts", function() return "kick" end)
        addButton("Rejoin Alts", function() return "rejoin" end)

        -- Draggable logic
        local dragging = false
        local dragInput, dragStart, startPos
        local function updateInput(input)
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
        titleFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        titleFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then updateInput(input) end
        end)
    end

    createGUI()
    print("Alt Control GUI loaded for host " .. player.Name)
end

-- Alt logic (if not host)
if isAlt then
    print("Alt mode activated for " .. player.Name)
    local hostPlayer = nil
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    local isDropping = false
    local currentMode = nil
    local currentTarget = nil
    local originalCFrame = nil
    local connections = {}
    local lastDropTime, dropCooldown = 0, 0.1
    local mainEvent = ReplicatedStorage:WaitForChild("MainEvent")
    local airlockPlatform = nil
    local airlockPosition = nil

    -- Anti-cheat bypass
    local detectionFlags = {"CHECKER_1", "CHECKER", "TeleportDetect", "OneMoreTime", "BRICKCHECK", "BADREQUEST", "BANREMOTE", "KICKREMOTE", "PERMAIDBAN", "PERMABAN"}
    local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if method == "FireServer" and self.Name == "MainEvent" and table.find(detectionFlags, args[1]) then
            return wait(9e9)
        end
        return oldNamecall(self, ...)
    end)

    if not mainEvent then warn("MainEvent not found.") end

    -- Wait for host (non-blocking for overlay)
    spawn(function()
        local timeout = 60
        local startTime = tick()
        while tick() - startTime < timeout do
            hostPlayer = Players:GetPlayerByUserId(config.HostUserId)
            if hostPlayer then
                print("Host found: " .. hostPlayer.Name)
                break
            end
            task.wait(0.5)
        end
        if not hostPlayer then warn("Host not found after " .. timeout .. "s. Commands disabled.") end
    end)

    -- Core functions (simplified)
    local function getPlayers() return Players:GetPlayers() end
    local function disableAllSeats()
        for _, seat in pairs(game.Workspace:GetDescendants()) do if seat:IsA("Seat") then seat.Disabled = true end end
    end
    local function getAltIndex(playerName)
        local alts = {}
        for _, p in pairs(getPlayers()) do if p ~= hostPlayer then table.insert(alts, p) end end
        table.sort(alts, function(a, b) return a.Name < b.Name end)
        for i, p in ipairs(alts) do if p.Name == playerName then return i - 1 end end
        return 0
    end
    local function toggleNoclip(enable)
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsA("Accessory") then
                part.CanCollide = not enable
                part.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
    local function disableCurrentMode()
        if humanoidRootPart then humanoidRootPart.Anchored = false end
        for _, conn in pairs(connections) do if conn then conn:Disconnect() end end
        connections = {}
        if airlockPlatform then airlockPlatform:Destroy() airlockPlatform = nil end
        currentMode = nil
        currentTarget = nil
        airlockPosition = nil
        toggleNoclip(false)
    end

    -- Command handlers (simplified)
    local function setup(targetPlayer)
        disableCurrentMode()
        if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        toggleNoclip(true)
        local index = getAltIndex(player.Name)
        local behind = -targetPlayer.Character.HumanoidRootPart.CFrame.LookVector * (1 * (index + 1))
        humanoidRootPart.CFrame = CFrame.lookAt(targetPlayer.Character.HumanoidRootPart.Position + behind, targetPlayer.Character.HumanoidRootPart.Position)
        toggleNoclip(false)
    end

    local function setupClub()
        disableCurrentMode()
        toggleNoclip(true)
        local clubPos = Vector3.new(-265, -7, -380)
        local index = getAltIndex(player.Name)
        local row, col = math.floor(index / 4), index % 4
        local offset = Vector3.new(-6 + col * 2, 0, -8 + row * 2)
        humanoidRootPart.CFrame = CFrame.new(clubPos + offset, clubPos + offset + Vector3.new(0, 0, -1))
        toggleNoclip(false)
    end

    local function setupBank()
        disableCurrentMode()
        toggleNoclip(true)
        local bankPos = Vector3.new(-376, 21, -283)
        local index = getAltIndex(player.Name)
        local row, col = math.floor(index / 4), index % 4
        local offset = Vector3.new(-6 + col * 2, 0, -8 + row * 2)
        humanoidRootPart.CFrame = CFrame.new(bankPos + offset, bankPos + offset + Vector3.new(0, 0, -1))
        toggleNoclip(false)
    end

    local function swarm(targetPlayer)
        disableCurrentMode()
        currentMode = "swarm"
        currentTarget = targetPlayer
        toggleNoclip(true)
        connections.swarm = RunService.RenderStepped:Connect(function()
            if not currentTarget or not currentTarget.Character then return end
            local center = currentTarget.Character.HumanoidRootPart.Position
            local hash = 0 for i = 1, #player.Name do hash = hash + string.byte(player.Name, i) end
            local angle = (hash % 360) / 180 * math.pi + os.clock() * 2
            local pos = center + Vector3.new(math.cos(angle) * 10, 0, math.sin(angle) * 10)
            humanoidRootPart.CFrame = CFrame.lookAt(pos, center)
        end)
    end

    local function follow(targetPlayer)
        disableCurrentMode()
        currentMode = "follow"
        currentTarget = targetPlayer
        toggleNoclip(true)
        connections.follow = RunService.RenderStepped:Connect(function()
            if not currentTarget or not currentTarget.Character then return end
            local index = getAltIndex(player.Name)
            local offset = -currentTarget.Character.HumanoidRootPart.CFrame.LookVector * (1 + index)
            local targetPos = currentTarget.Character.HumanoidRootPart.Position + offset
            humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(CFrame.lookAt(targetPos, currentTarget.Character.HumanoidRootPart.Position), 0.5)
        end)
    end

    local function airlock()
        disableCurrentMode()
        originalCFrame = humanoidRootPart.CFrame
        local y = (hostPlayer and hostPlayer.Character and hostPlayer.Character:FindFirstChild("HumanoidRootPart")) and hostPlayer.Character.HumanoidRootPart.Position.Y or originalCFrame.Position.Y
        airlockPosition = CFrame.new(originalCFrame.Position.X, y + 13, originalCFrame.Position.Z)
        toggleNoclip(true)
        humanoidRootPart.CFrame = airlockPosition
        humanoidRootPart.Anchored = true
        toggleNoclip(false)
        currentMode = "airlock"
        connections.airlock = RunService.RenderStepped:Connect(function()
            if currentMode == "airlock" then humanoidRootPart.CFrame = airlockPosition end
        end)
    end

    local function unairlock()
        if airlockPlatform then airlockPlatform:Destroy() end
        if connections.airlock then connections.airlock:Disconnect() end
        humanoidRootPart.Anchored = false
        humanoidRootPart.CFrame = originalCFrame
        currentMode = nil
    end

    local function bring()
        disableCurrentMode()
        if not hostPlayer or not hostPlayer.Character then return end
        toggleNoclip(true)
        local index = getAltIndex(player.Name)
        local angle = index * (2 * math.pi / (#getPlayers()))
        local pos = hostPlayer.Character.HumanoidRootPart.Position + Vector3.new(math.cos(angle) * 2, 0, math.sin(angle) * 2)
        humanoidRootPart.CFrame = CFrame.lookAt(pos, hostPlayer.Character.HumanoidRootPart.Position)
        toggleNoclip(false)
    end

    local function dropAllCash()
        isDropping = true
        connections.drop = RunService.Heartbeat:Connect(function()
            if isDropping and mainEvent then
                local now = tick()
                if now - lastDropTime >= dropCooldown then
                    pcall(function() mainEvent:FireServer("DropMoney", 15000) mainEvent:FireServer("Block", true) end)
                    lastDropTime = now
                end
            end
        end)
    end

    local function stopDrop()
        isDropping = false
        if connections.drop then connections.drop:Disconnect() end
        if mainEvent then pcall(function() mainEvent:FireServer("Block", false) end) end
    end

    local function kickAlt() player:Kick("Kicked by host") end
    local function rejoinGame() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) end

    -- Listen for host chat
    Players.PlayerAdded:Connect(function(p)
        if p.UserId == config.HostUserId then
            hostPlayer = p
            print("Host joined: " .. p.Name)
            p.Chatted:Connect(function(msg)
                local lower = string.lower(msg)
                if string.sub(lower, 1, 1) ~= "?" then return end
                local cmd = string.sub(lower, 2):match("^%s*(.-)%s*$")
                if cmd == "" then return end
                print("Alt received: " .. cmd)
                if cmd == "setup host" then setup(hostPlayer)
                elseif string.find(cmd, "setup ") then
                    local targetName = string.match(cmd, "setup (.+)")
                    if targetName == "club" then setupClub()
                    elseif targetName == "bank" then setupBank()
                    else local target = Players:FindFirstChild(targetName); if target then setup(target) end
                    end
                elseif cmd == "swarm host" then swarm(hostPlayer)
                elseif string.find(cmd, "swarm ") then local targetName = string.match(cmd, "swarm (.+)"); local target = Players:FindFirstChild(targetName); if target then swarm(target) end
                elseif cmd == "unswarm" then disableCurrentMode(); setup(hostPlayer)
                elseif cmd == "follow host" then follow(hostPlayer)
                elseif string.find(cmd, "follow ") then local targetName = string.match(cmd, "follow (.+)"); local target = Players:FindFirstChild(targetName); if target then follow(target) end
                elseif cmd == "unfollow" then disableCurrentMode(); setup(hostPlayer)
                elseif cmd == "airlock" then airlock()
                elseif cmd == "unairlock" then unairlock()
                elseif cmd == "bring" then bring()
                elseif cmd == "drop" then dropAllCash()
                elseif cmd == "stop" then stopDrop()
                elseif cmd == "kick" then kickAlt()
                elseif cmd == "rejoin" then rejoinGame()
                else warn("Unknown: " .. cmd) end
            end)
        end
    end)

    -- Handle leaving/resets
    Players.PlayerRemoving:Connect(function(p) if p == hostPlayer then kickAlt() end end)
    player.CharacterAdded:Connect(function(newChar)
        character = newChar
        humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
        humanoid = newChar:WaitForChild("Humanoid")
        -- Reapply mode if active
        if currentMode == "airlock" then airlock() end
    end)

    -- Init for alt
    disableAllSeats()
    connections.fps = RunService.RenderStepped:Connect(function()
        local targetDelta = 1 / 5
        local elapsed = tick() - (connections.lastTime or 0)
        if elapsed < targetDelta then task.wait(targetDelta - elapsed) end
        connections.lastTime = tick()
    end)
    connections.afk = RunService.Heartbeat:Connect(function()
        if humanoid then humanoid.Jump = true; task.wait(0.1); humanoid.Jump = false end
    end)
    print("Alt initialized for " .. player.Name)
end

-- Always create overlay last
createOverlay()
print("dhc.lmao Script loaded for " .. player.Name)
