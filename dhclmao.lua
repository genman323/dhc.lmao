local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local hostName = "Sab3r_PRO2003"
local hostPlayer = Players:WaitForChild(hostName)
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local isDropping = false
local isSwarming = false
local swarmTarget = nil
local isSpinning = false
local isAirlocked = false
local originalHideCFrame = nil
local dropConnection
local swarmConnection
local spinConnection
local followConnections = {}
local lastDropTime = 0
local dropCooldown = 0.1
local mainEvent = ReplicatedStorage:WaitForChild("MainEvent")

local function disableAllSeats()
    for _, seat in pairs(game.Workspace:GetDescendants()) do
        if seat:IsA("Seat") then
            seat.Disabled = true
        end
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
        if elapsed < targetDeltaTime then
            task.wait(targetDeltaTime - elapsed)
        end
        lastTime = currentTime
    end)
end

local function getAltIndex(playerName)
    local alts = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= hostPlayer then
            table.insert(alts, p)
        end
    end
    
    table.sort(alts, function(a, b) return a.Name < b.Name end)
    
    local index = 0
    for i, p in ipairs(alts) do
        if p.Name == playerName then
            index = i - 1
            break
        end
    end
    return index
end

local function setupAtTarget(targetPlayer)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        print("Target not found or invalid")
        return
    end
    
    local targetRoot = targetPlayer.Character.HumanoidRootPart
    local basePosition = targetRoot.Position
    local index = getAltIndex(player.Name)
    local spacing = 1
    local behindDirection = -targetRoot.CFrame.LookVector
    local offsetPosition = basePosition + behindDirection * spacing * (index + 1)
    local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.lookAt(offsetPosition, basePosition)})
    tween:Play()
end

local function enableNoclip(char)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function disableNoclip(char)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

local function dropAllCash()
    isDropping = true
    if dropConnection then dropConnection:Disconnect() end
    dropConnection = RunService.Heartbeat:Connect(function()
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
    if dropConnection then
        dropConnection:Disconnect()
        dropConnection = nil
    end
    pcall(function()
        mainEvent:FireServer("Block", false)
    end)
end

local function swarmPlayer(start, target)
    isSwarming = start
    if start then
        swarmTarget = target or hostPlayer
        if swarmConnection then swarmConnection:Disconnect() end
        enableNoclip(character)
        swarmConnection = RunService.RenderStepped:Connect(function(deltaTime)
            if isSwarming then
                local targetChar = swarmTarget.Character
                if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
                    print("Swarm target character or HumanoidRootPart not found")
                    return
                end
                local center = targetChar.HumanoidRootPart.Position
                local hash = 0
                for i = 1, #player.Name do
                    hash = hash + string.byte(player.Name, i)
                end
                local angle = (hash % 360) / 180 * math.pi + os.clock() * 1
                local radius = 10
                local x = math.cos(angle) * radius
                local z = math.sin(angle) * radius
                local position = center + Vector3.new(x, 0, z)
                local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
                local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.lookAt(position, center)})
                tween:Play()
                task.wait(0.05)
            end
        end)
    else
        disableNoclip(character)
        if swarmConnection then
            swarmConnection:Disconnect()
            swarmConnection = nil
        end
    end
end

local function spin(start)
    isSpinning = start
    if start then
        if spinConnection then spinConnection:Disconnect() end
        spinConnection = RunService.RenderStepped:Connect(function(deltaTime)
            if isSpinning then
                local currentCFrame = humanoidRootPart.CFrame
                local rotation = CFrame.Angles(0, math.rad(360 * deltaTime * 2), 0)
                local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
                local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = currentCFrame * rotation})
                tween:Play()
                task.wait(0.05)
            end
        end)
    else
        if spinConnection then
            spinConnection:Disconnect()
            spinConnection = nil
        end
    end
end

local function airlockAlt()
    if not humanoidRootPart then return end
    originalHideCFrame = humanoidRootPart.CFrame
    local referenceHeight = hostPlayer.Character and hostPlayer.Character:FindFirstChild("HumanoidRootPart") and hostPlayer.Character.HumanoidRootPart.Position.Y or humanoidRootPart.Position.Y
    local targetCFrame = CFrame.new(humanoidRootPart.Position.X, referenceHeight + 7, humanoidRootPart.Position.Z) * humanoidRootPart.CFrame.Rotation
    enableNoclip(character)
    humanoidRootPart.Anchored = true
    humanoidRootPart.CFrame = targetCFrame
    isAirlocked = true
    disableNoclip(character)
    pcall(function()
        mainEvent:FireServer("UpdatePosition", humanoidRootPart.Position)
    end)
end

local function unairlockAlt()
    if isAirlocked and originalHideCFrame then
        enableNoclip(character)
        humanoidRootPart.Anchored = false
        isAirlocked = false
        humanoidRootPart.CFrame = originalHideCFrame
        disableNoclip(character)
        pcall(function()
            mainEvent:FireServer("UpdatePosition", humanoidRootPart.Position)
        end)
    end
end

local function followAllAlts(targetPlayer)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        print("Target not found or invalid")
        return
    end
    
    local targetRoot = targetPlayer.Character.HumanoidRootPart
    for _, conn in pairs(followConnections) do
        if conn then conn:Disconnect() end
    end
    followConnections = {}

    for _, alt in pairs(Players:GetPlayers()) do
        if alt ~= hostPlayer then
            local altChar = alt.Character
            if altChar and altChar:FindFirstChild("HumanoidRootPart") then
                local altHumanoidRootPart = altChar.HumanoidRootPart
                enableNoclip(altChar)
                local index = getAltIndex(alt.Name)
                local offsetDistance = 2 + (index * 0.5)
                local isFollowing = true

                followConnections[alt.Name] = RunService.RenderStepped:Connect(function()
                    if isFollowing then
                        local targetPos = targetRoot.Position
                        local behindOffset = -targetRoot.CFrame.LookVector * offsetDistance
                        local myPos = targetPos + behindOffset + Vector3.new(0, 0, 0)
                        local hostPos = hostPlayer.Character and hostPlayer.Character:FindFirstChild("HumanoidRootPart") and hostPlayer.Character.HumanoidRootPart.Position
                        if hostPos then
                            local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
                            local tween = TweenService:Create(altHumanoidRootPart, tweenInfo, {
                                CFrame = CFrame.lookAt(myPos, hostPos)
                            })
                            tween:Play()
                        end
                    end
                end)
            end
        end
    end
end

local function stopFollowAllAlts()
    for _, conn in pairs(followConnections) do
        if conn then conn:Disconnect() end
    end
    followConnections = {}
    disableNoclip(character)
    setupAtTarget(hostPlayer)
end

local function bringAllAlts()
    for _, alt in pairs(Players:GetPlayers()) do
        if alt ~= hostPlayer and alt.Character and alt.Character:FindFirstChild("HumanoidRootPart") then
            local altHumanoidRootPart = alt.Character.HumanoidRootPart
            local hostRoot = hostPlayer.Character and hostPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hostRoot then
                local targetCFrame = hostRoot.CFrame + Vector3.new(math.random(-5,5), 0, math.random(-5,5))
                enableNoclip(alt.Character)
                local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                local tween = TweenService:Create(altHumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
                tween:Play()
                tween.Completed:Connect(function()
                    disableNoclip(alt.Character)
                    pcall(function()
                        mainEvent:FireServer("UpdatePosition", altHumanoidRootPart.Position)
                    end)
                end)
            end
        end
    end
end

local function stackAllAlts()
    local hostRoot = hostPlayer.Character and hostPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hostRoot then return end

    local basePosition = hostRoot.Position
    local heightOffset = 2 -- 2 studs between each alt
    for _, alt in pairs(Players:GetPlayers()) do
        if alt ~= hostPlayer and alt.Character and alt.Character:FindFirstChild("HumanoidRootPart") then
            local altHumanoidRootPart = alt.Character.HumanoidRootPart
            local index = getAltIndex(alt.Name)
            local targetPosition = Vector3.new(basePosition.X, basePosition.Y + (index * heightOffset), basePosition.Z)
            enableNoclip(alt.Character)
            local tweenInfo = TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
            local tween = TweenService:Create(altHumanoidRootPart, tweenInfo, {CFrame = CFrame.new(targetPosition)})
            tween:Play()
            tween.Completed:Connect(function()
                altHumanoidRootPart.Anchored = true
                disableNoclip(alt.Character)
                pcall(function()
                    mainEvent:FireServer("UpdatePosition", altHumanoidRootPart.Position)
                end)
            end)
        end
    end
end

local function resetAlts()
    setupAtTarget(hostPlayer)
end

local function kickAlt()
    pcall(function()
        player:Kick("Kicked by host.")
    end)
end

local function rejoinGame()
    pcall(function()
        local placeId = game.PlaceId
        local jobId = game.JobId
        if placeId and jobId then
            TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
        else
            print("Failed to rejoin: PlaceId or JobId not available")
        end
    end)
end

Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == hostPlayer then
        kickAlt()
    end
end)

createOverlay()
limitFPS()
disableAllSeats()

hostPlayer.Chatted:Connect(function(message)
    pcall(function()
        local lowerMsg = string.lower(message)
        local prefix = "?"
        if string.sub(lowerMsg, 1, #prefix) ~= prefix then return end
        
        local cmd = string.sub(lowerMsg, #prefix + 1)
        
        if cmd == "setup host" then
            setupAtTarget(hostPlayer)
        elseif cmd:find("^setup ") then
            local targetName = string.sub(message, #prefix + 7)
            local target = Players:FindFirstChild(targetName)
            if target then
                setupAtTarget(target)
            end
        elseif cmd == "drop" then
            dropAllCash()
        elseif cmd == "stop" then
            stopDrop()
        elseif cmd == "swarm host" then
            swarmPlayer(true, hostPlayer)
        elseif cmd == "unswarm host" then
            swarmPlayer(false)
        elseif cmd:find("^swarm ") then
            local targetName = string.sub(message, #prefix + 7)
            local target = Players:FindFirstChild(targetName)
            if target then
                swarmPlayer(true, target)
            end
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
            local targetName = string.sub(message, #prefix + 7)
            local target = Players:FindFirstChild(targetName)
            if target then
                followAllAlts(target)
            end
        elseif cmd == "unfollow" then
            stopFollowAllAlts()
        elseif cmd == "stack host" then
            stackAllAlts()
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
    if isSwarming then
        swarmPlayer(true, swarmTarget)
    end
    if isSpinning then
        spin(true)
    end
    if isAirlocked then
        airlockAlt()
    end
end)

print("dhc.lmao Alt Control Script loaded for " .. player.Name)
