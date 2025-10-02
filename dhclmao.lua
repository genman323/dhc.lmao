local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer
local hostName = "Sab3r_PRO2003"
local hostPlayer = Players:WaitForChild(hostName)
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local isDropping, isSwarming, isSpinning, isAirlocked = false, false, false, false
local originalHideCFrame = nil
local connections = {drop = nil, swarm = nil, spin = nil, follow = {}}
local lastDropTime, dropCooldown = 0, 0.1
local mainEvent = ReplicatedStorage:WaitForChild("MainEvent")

-- Cache player list once per function call
local function getPlayers()
    return Players:GetPlayers()
end

local function disableAllSeats()
    for _, seat in pairs(game.Workspace:GetDescendants()) do
        if seat:IsA("Seat") then seat.Disabled = true end
    end
end

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

local function limitFPS()
    local targetDeltaTime = 1 / 5
    local lastTime = tick()
    RunService.RenderStepped:Connect(function(deltaTime)
        local currentTime = tick()
        local elapsed = currentTime - lastTime
        if elapsed < targetDeltaTime then task.wait(targetDeltaTime - elapsed) end
        lastTime = currentTime
    end)
end

local function getAltIndex(playerName, players)
    local alts = {}
    for _, p in pairs(players) do if p ~= hostPlayer then table.insert(alts, p) end end
    table.sort(alts, function(a, b) return a.Name < b.Name end)
    for i, p in ipairs(alts) do if p.Name == playerName then return i - 1 end end
    return 0
end

local function setupAtTarget(targetPlayer, altHumanoidRootPart)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local targetRoot = targetPlayer.Character.HumanoidRootPart
    local players = getPlayers()
    local index = getAltIndex(Players:GetPlayerFromCharacter(altHumanoidRootPart.Parent).Name, players)
    local spacing = 3 -- Increased spacing to prevent overlap and clumping
    local behindDirection = -targetRoot.CFrame.LookVector
    local offsetPosition = targetRoot.Position + behindDirection * spacing * (index + 1)
    toggleNoclip(altHumanoidRootPart.Parent, true) -- Enable noclip to avoid collisions
    local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Cubic)
    local tween = TweenService:Create(altHumanoidRootPart, tweenInfo, {CFrame = CFrame.lookAt(offsetPosition, targetRoot.Position)})
    tween:Play()
    tween.Completed:Connect(function()
        toggleNoclip(altHumanoidRootPart.Parent, false) -- Disable noclip after positioning
        pcall(function() mainEvent:FireServer("UpdatePosition", altHumanoidRootPart.Position) end)
    end)
end

local function toggleNoclip(char, enable)
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") then part.CanCollide = not enable end
    end
end

local function dropAllCash()
    isDropping = true
    if connections.drop then connections.drop:Disconnect() end
    connections.drop = RunService.Heartbeat:Connect(function()
        if isDropping then
            local currentTime = tick()
            if currentTime - lastDropTime >= dropCooldown then
                pcall(function() mainEvent:FireServer("DropMoney", 15000); mainEvent:FireServer("Block", true) end)
                lastDropTime = currentTime
            end
        end
    end)
end

local function stopDrop()
    isDropping = false
    if connections.drop then connections.drop:Disconnect(); connections.drop = nil end
    pcall(function() mainEvent:FireServer("Block", false) end)
end

local function swarmPlayer(start, target)
    isSwarming = start
    if start then
        swarmTarget = target or hostPlayer
        if not swarmTarget or not swarmTarget.Character or not swarmTarget.Character:FindFirstChild("HumanoidRootPart") then
            warn("Swarm target is invalid or not ready")
            isSwarming = false
            return
        end
        if connections.swarm then connections.swarm:Disconnect() end
        toggleNoclip(character, true)
        connections.swarm = RunService.RenderStepped:Connect(function(deltaTime)
            if isSwarming then
                local targetChar = swarmTarget.Character
                if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
                    warn("Swarm target lost, stopping swarm")
                    swarmPlayer(false)
                    return
                end
                local center = targetChar.HumanoidRootPart.Position
                local radius = 10
                local players = getPlayers()
                local index = getAltIndex(player.Name, players)
                local angle = (index * math.pi / 2) + (os.clock() * 2)
                local x, z = math.cos(angle) * radius, math.sin(angle) * radius
                local position = center + Vector3.new(x, 0, z)
                local lookAtCFrame = CFrame.lookAt(position, center)
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Smooth, Enum.EasingDirection.InOut)
                local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = lookAtCFrame})
                tween:Play()
                pcall(function() mainEvent:FireServer("UpdatePosition", humanoidRootPart.Position) end)
            end
        end)
    else
        isSwarming = false
        toggleNoclip(character, false)
        if connections.swarm then connections.swarm:Disconnect(); connections.swarm = nil end
        setupAtTarget(hostPlayer, humanoidRootPart)
    end
end

local function spin(start)
    isSpinning = start
    if start then
        if connections.spin then connections.spin:Disconnect() end
        connections.spin = RunService.RenderStepped:Connect(function(deltaTime)
            if isSpinning then
                local currentCFrame = humanoidRootPart.CFrame
                local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Cubic)
                TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = currentCFrame * CFrame.Angles(0, math.rad(360 * deltaTime * 2), 0)}):Play()
            end
        end)
    else
        if connections.spin then connections.spin:Disconnect(); connections.spin = nil end
    end
end

local function airlockAlt()
    if not humanoidRootPart then return end
    originalHideCFrame = humanoidRootPart.CFrame
    local referenceHeight = (hostPlayer.Character and hostPlayer.Character:FindFirstChild("HumanoidRootPart") and hostPlayer.Character.HumanoidRootPart.Position.Y) or humanoidRootPart.Position.Y
    local targetCFrame = CFrame.new(humanoidRootPart.Position.X, referenceHeight + 15, humanoidRootPart.Position.Z) * humanoidRootPart.CFrame.Rotation
    toggleNoclip(character, true)
    humanoidRootPart.Anchored = true
    humanoidRootPart.CFrame = targetCFrame
    isAirlocked = true
    toggleNoclip(character, false)
    pcall(function() mainEvent:FireServer("UpdatePosition", humanoidRootPart.Position) end)
end

local function unairlockAlt()
    if isAirlocked and originalHideCFrame then
        toggleNoclip(character, true)
        humanoidRootPart.Anchored = false
        isAirlocked = false
        humanoidRootPart.CFrame = originalHideCFrame
        toggleNoclip(character, false)
        pcall(function() mainEvent:FireServer("UpdatePosition", humanoidRootPart.Position) end)
    end
end

local function followAllAlts(targetPlayer)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local targetRoot = targetPlayer.Character.HumanoidRootPart
    for _, conn in pairs(connections.follow) do if conn then conn:Disconnect() end end
    connections.follow = {}

    local players = getPlayers()
    for _, alt in pairs(players) do
        if alt ~= hostPlayer then
            local altChar = alt.Character
            if altChar and altChar:FindFirstChild("HumanoidRootPart") then
                local altHumanoidRootPart = altChar.HumanoidRootPart
                toggleNoclip(altChar, true)
                local index = getAltIndex(alt.Name, players)
                local offsetDistance = 2 + (index * 0.5)
                connections.follow[alt.Name] = RunService.RenderStepped:Connect(function()
                    local targetPos = targetRoot.Position
                    local behindOffset = -targetRoot.CFrame.LookVector * offsetDistance
                    local myPos = targetPos + behindOffset
                    local hostPos = hostPlayer.Character and hostPlayer.Character:FindFirstChild("HumanoidRootPart") and hostPlayer.Character.HumanoidRootPart.Position
                    if hostPos then
                        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Cubic)
                        TweenService:Create(altHumanoidRootPart, tweenInfo, {CFrame = CFrame.lookAt(myPos, hostPos)}):Play()
                    end
                end)
            end
        end
    end
end

local function stopFollowAllAlts()
    for _, conn in pairs(connections.follow) do if conn then conn:Disconnect() end end
    connections.follow = {}
    toggleNoclip(character, false)
    setupAtTarget(hostPlayer, humanoidRootPart)
end

local function bringAllAlts()
    local hostRoot = hostPlayer.Character and hostPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hostRoot then return end
    local players = getPlayers()
    for _, alt in pairs(players) do
        if alt ~= hostPlayer and alt.Character and alt.Character:FindFirstChild("HumanoidRootPart") then
            local altHumanoidRootPart = alt.Character.HumanoidRootPart
            local targetCFrame = hostRoot.CFrame + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
            toggleNoclip(alt.Character, true)
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad)
            TweenService:Create(altHumanoidRootPart, tweenInfo, {CFrame = targetCFrame}):Play()
        end
    end
end

local function stackAllAlts()
    local hostRoot = hostPlayer.Character and hostPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hostRoot then
        warn("Host player or HumanoidRootPart not found, cannot stack alts")
        return
    end
    local basePosition = hostRoot.Position
    local heightOffset = 3 -- Increased to prevent clipping
    local players = getPlayers()
    local altCount = #players - 1 -- Exclude host
    local spiralRadius = math.min(2, altCount * 0.2) -- Scales with alt count
    for _, alt in pairs(players) do
        if alt ~= hostPlayer and alt.Character and alt.Character:FindFirstChild("HumanoidRootPart") then
            local altHumanoidRootPart = alt.Character.HumanoidRootPart
            local index = getAltIndex(alt.Name, players)
            local angle = index * (2 * math.pi / math.max(1, altCount))
            local xOffset = math.cos(angle) * spiralRadius
            local zOffset = math.sin(angle) * spiralRadius
            local targetPosition = Vector3.new(
                basePosition.X + xOffset,
                basePosition.Y + (index * heightOffset) + hostRoot.Size.Y + 1,
                basePosition.Z + zOffset
            )
            local targetCFrame = CFrame.new(targetPosition) * hostRoot.CFrame.Rotation
            toggleNoclip(alt.Character, true)
            altHumanoidRootPart.Anchored = false
            local tweenInfo = TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
            local tween = TweenService:Create(altHumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
            task.wait(index * 0.1) -- Stagger tweens to reduce lag
            tween:Play()
            tween.Completed:Connect(function()
                altHumanoidRootPart.Anchored = true
                toggleNoclip(alt.Character, false)
                pcall(function()
                    mainEvent:FireServer("UpdatePosition", altHumanoidRootPart.Position)
                end)
            end)
            RunService.Heartbeat:Connect(function()
                if tween.PlaybackState == Enum.PlaybackState.Playing then
                    pcall(function()
                        mainEvent:FireServer("UpdatePosition", altHumanoidRootPart.Position)
                    end)
                end
            end)
        end
    end
end

local function unstackAllAlts()
    local hostRoot = hostPlayer.Character and hostPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hostRoot then return end
    local basePosition = hostRoot.Position
    local players = getPlayers()
    for _, alt in pairs(players) do
        if alt ~= hostPlayer and alt.Character and alt.Character:FindFirstChild("HumanoidRootPart") then
            local altHumanoidRootPart = alt.Character.HumanoidRootPart
            altHumanoidRootPart.Anchored = false
            local index = getAltIndex(alt.Name, players)
            local spacing = 1
            local behindDirection = -hostRoot.CFrame.LookVector
            local targetPosition = basePosition + behindDirection * spacing * (index + 1)
            toggleNoclip(alt.Character, true)
            local tweenInfo = TweenInfo.new(1.0, Enum.EasingStyle.Quad)
            local tween = TweenService:Create(altHumanoidRootPart, tweenInfo, {CFrame = CFrame.lookAt(targetPosition, basePosition)})
            tween:Play()
            tween.Completed:Connect(function()
                toggleNoclip(alt.Character, false)
                pcall(function() mainEvent:FireServer("UpdatePosition", altHumanoidRootPart.Position) end)
            end)
        end
    end
end

local function resetAlts()
    setupAtTarget(hostPlayer, humanoidRootPart)
end

local function kickAlt()
    pcall(function() player:Kick("Kicked by host.") end)
end

local function rejoinGame()
    pcall(function()
        local placeId, jobId = game.PlaceId, game.JobId
        if placeId and jobId then TeleportService:TeleportToPlaceInstance(placeId, jobId, player) end
    end)
end

Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == hostPlayer then kickAlt() end
end)

createOverlay()
limitFPS()
disableAllSeats()

hostPlayer.Chatted:Connect(function(message)
    pcall(function()
        local lowerMsg = string.lower(message)
        if string.sub(lowerMsg, 1, 1) ~= "?" then return end
        local cmd = string.sub(lowerMsg, 2)
        
        if cmd == "setup host" then
            setupAtTarget(hostPlayer, humanoidRootPart)
        elseif cmd:find("^setup ") then
            local targetName = string.sub(cmd, 7)
            local target = Players:FindFirstChild(targetName)
            if target then setupAtTarget(target, humanoidRootPart) end
        elseif cmd == "drop" then
            dropAllCash()
        elseif cmd == "stop" then
            stopDrop()
        elseif cmd == "swarm host" then
            swarmPlayer(true, hostPlayer)
        elseif cmd == "unswarm host" then
            swarmPlayer(false)
        elseif cmd:find("^swarm ") then
            local targetName = string.sub(cmd, 7)
            local target = Players:FindFirstChild(targetName)
            if target then swarmPlayer(true, target) end
        elseif cmd == "unswarm" then
            swarmPlayer(false)
        elseif cmd == "spin" then
            spin(true)
        elseif cmd == "unspin" then
            spin(false)
        elseif cmd == "airlock" then
            airlockAlt()
        elseif cmd == "unairlock" then
            unairlockAlt()
        elseif cmd == "bring" then
            bringAllAlts()
        elseif cmd == "follow host" then
            followAllAlts(hostPlayer)
        elseif cmd:find("^follow ") then
            local targetName = string.sub(cmd, 7)
            local target = Players:FindFirstChild(targetName)
            if target then followAllAlts(target) end
        elseif cmd == "unfollow" then
            stopFollowAllAlts()
        elseif cmd == "stack host" then
            stackAllAlts()
        elseif cmd == "unstack" then
            unstackAllAlts()
        elseif cmd == "reset" then
            resetAlts()
        elseif cmd == "kick" then
            kickAlt()
        elseif cmd == "rejoin" then
            rejoinGame()
        end
    end)
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    if isSwarming then swarmPlayer(true, swarmTarget) end
    if isSpinning then spin(true) end
    if isAirlocked then airlockAlt() end
end)

print("dhc.lmao Alt Control Script loaded for " .. player.Name)
