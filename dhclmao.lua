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
local isDropping, isSwarming, isSpinning, isAirlocked, isStacked, isCircled = false, false, false, false, false, false
local swarmTarget = nil
local originalHideCFrame = nil
local connections = {drop = nil, swarm = nil, spin = nil, follow = {}, fps = nil, afk = nil}
local lastDropTime, dropCooldown = 0, 0.1
local mainEvent = ReplicatedStorage:WaitForChild("MainEvent", 10)

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
    toggleNoclip(rootPart.Parent, true)
    rootPart.Anchored = false
    local tweenInfo = TweenInfo.new(duration, easingStyle or Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
    if delay then task.wait(delay) end
    tween:Play()
    local tweenConnection = RunService.Heartbeat:Connect(function()
        if tween.PlaybackState == Enum.PlaybackState.Playing then
            pcall(function()
                mainEvent:FireServer("UpdatePosition", rootPart.Position)
            end, function(err)
                warn("Failed to update position: " .. tostring(err))
            end)
        end
    end)
    tween.Completed:Connect(function()
        toggleNoclip(rootPart.Parent, false)
        pcall(function()
            mainEvent:FireServer("UpdatePosition", rootPart.Position)
        end, function(err)
            warn("Failed to update position: " .. tostring(err))
        end)
        tweenConnection:Disconnect()
    end)
end

-- Setup alt behind target player
local function setupAtTarget(targetPlayer, altHumanoidRootPart)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        warn("Setup failed: Invalid target player or HumanoidRootPart")
        pcall(function() mainEvent:FireServer("Notify", "Setup failed: Target player not found") end)
        return
    end
    local targetRoot = targetPlayer.Character.HumanoidRootPart
    local players = getPlayers()
    local index = getAltIndex(Players:GetPlayerFromCharacter(altHumanoidRootPart.Parent).Name, players)
    local spacing = 3
    local behindDirection = -targetRoot.CFrame.LookVector
    local offsetPosition = targetRoot.Position + behindDirection * spacing * (index + 1)
    local targetCFrame = CFrame.lookAt(offsetPosition, targetRoot.Position)
    tweenToPosition(altHumanoidRootPart, targetCFrame, 0.8, Enum.EasingStyle.Cubic)
    pcall(function() mainEvent:FireServer("Notify", "Setup completed for " .. targetPlayer.Name) end)
end

-- Toggle noclip for character
local function toggleNoclip(char, enable)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and not part:IsA("Accessory") then
            part.CanCollide = not enable
        end
    end
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
                local success, err = pcall(function()
                    mainEvent:FireServer("DropMoney", 15000)
                    mainEvent:FireServer("Block", true)
                end)
                if not success then
                    warn("Failed to drop money or block: " .. tostring(err))
                    if err:match("MainEvent") then
                        isDropping = false
                        connections.drop:Disconnect()
                        connections.drop = nil
                        warn("MainEvent not found, stopping drop.")
                    end
                end
                lastDropTime = currentTime
            end
        end
    end)
end

-- Stop dropping cash
local function stopDrop()
    isDropping = false
    if connections.drop then connections.drop:Disconnect(); connections.drop = nil end
    pcall(function()
        mainEvent:FireServer("Block", false)
    end, function(err)
        warn("Failed to stop block: " .. tostring(err))
    end)
end

-- Form alts in a circle around host
local function circleFormation()
    isCircled = true
    if isSwarming then swarmPlayer(false) end
    if isSpinning then spin(false) end
    if isAirlocked then unairlockAlt() end
    if isStacked then unstackAllAlts() end
    stopFollowAllAlts()
    local hostRoot = hostPlayer.Character and hostPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hostRoot then
        warn("Circle failed: Host player or HumanoidRootPart not found")
        isCircled = false
        return
    end
    local basePosition = hostRoot.Position
    local radius = 10
    local players = getPlayers()
    local altCount = #players - 1
    local activeTweens = {}
    for _, alt in pairs(players) do
        if alt ~= hostPlayer and alt.Character and alt.Character:FindFirstChild("HumanoidRootPart") then
            local altRoot = alt.Character.HumanoidRootPart
            local index = getAltIndex(alt.Name, players)
            local angle = index * (2 * math.pi / math.max(1, altCount))
            local x, z = math.cos(angle) * radius, math.sin(angle) * radius
            local position = Vector3.new(basePosition.X + x, basePosition.Y, basePosition.Z + z)
            local targetCFrame = CFrame.lookAt(position, basePosition)
            altRoot.Anchored = false
            local tween = TweenService:Create(altRoot, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {CFrame = targetCFrame})
            activeTweens[alt] = tween
            task.wait(index * 0.1)
            tween:Play()
        end
    end
    local tweenConnection = RunService.Heartbeat:Connect(function()
        for alt, tween in pairs(activeTweens) do
            if tween.PlaybackState == Enum.PlaybackState.Playing then
                pcall(function()
                    mainEvent:FireServer("UpdatePosition", alt.Character.HumanoidRootPart.Position)
                end, function(err)
                    warn("Failed to update position in circleFormation: " .. tostring(err))
                end)
            end
        end
    end)
    for alt, tween in pairs(activeTweens) do
        tween.Completed:Connect(function()
            local altRoot = alt.Character and alt.Character:FindFirstChild("HumanoidRootPart")
            if altRoot then
                altRoot.Anchored = true
                toggleNoclip(alt.Character, false)
                pcall(function()
                    mainEvent:FireServer("UpdatePosition", altRoot.Position)
                end, function(err)
                    warn("Failed to update position in circleFormation: " .. tostring(err))
                end)
            end
            activeTweens[alt] = nil
            if next(activeTweens) == nil then
                tweenConnection:Disconnect()
            end
        end)
    end
end

-- Swarm around target player
local function swarmPlayer(start, target)
    isSwarming = start
    if start then
        swarmTarget = target or hostPlayer
        if not swarmTarget or not swarmTarget.Character or not swarmTarget.Character:FindFirstChild("HumanoidRootPart") then
            warn("Swarm target is invalid or not ready")
            isSwarming = false
            swarmTarget = nil
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
                tweenToPosition(humanoidRootPart, lookAtCFrame, 0.2, Enum.EasingStyle.Smooth)
            end
        end)
    else
        isSwarming = false
        toggleNoclip(character, false)
        if connections.swarm then connections.swarm:Disconnect(); connections.swarm = nil end
        swarmTarget = nil
        setupAtTarget(hostPlayer, humanoidRootPart)
    end
end

-- Spin alt character
local function spin(start)
    isSpinning = start
    if start then
        if connections.spin then connections.spin:Disconnect() end
        connections.spin = RunService.RenderStepped:Connect(function(deltaTime)
            if isSpinning then
                local currentCFrame = humanoidRootPart.CFrame
                tweenToPosition(humanoidRootPart, currentCFrame * CFrame.Angles(0, math.rad(360 * deltaTime * 2), 0), 0.15, Enum.EasingStyle.Cubic)
            end
        end)
    else
        if connections.spin then connections.spin:Disconnect(); connections.spin = nil end
    end
end

-- Airlock alt above ground
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
    pcall(function()
        mainEvent:FireServer("UpdatePosition", humanoidRootPart.Position)
    end, function(err)
        warn("Failed to update position in airlockAlt: " .. tostring(err))
    end)
end

-- Unairlock alt
local function unairlockAlt()
    if isAirlocked and originalHideCFrame then
        toggleNoclip(character, true)
        humanoidRootPart.Anchored = false
        isAirlocked = false
        humanoidRootPart.CFrame = originalHideCFrame
        toggleNoclip(character, false)
        pcall(function()
            mainEvent:FireServer("UpdatePosition", humanoidRootPart.Position)
        end, function(err)
            warn("Failed to update position in unairlockAlt: " .. tostring(err))
        end)
    end
end

-- Make all alts follow target
local function followAllAlts(targetPlayer)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        warn("Follow failed: Invalid target player or HumanoidRootPart")
        pcall(function() mainEvent:FireServer("Notify", "Follow failed: Target player not found") end)
        return
    end
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
                        tweenToPosition(altHumanoidRootPart, CFrame.lookAt(myPos, hostPos), 0.15, Enum.EasingStyle.Cubic, index * 0.1)
                    end
                end)
            end
        end
    end
end

-- Stop all alts from following
local function stopFollowAllAlts()
    for _, conn in pairs(connections.follow) do if conn then conn:Disconnect() end end
    connections.follow = {}
    toggleNoclip(character, false)
    setupAtTarget(hostPlayer, humanoidRootPart)
end

-- Bring all alts near host
local function bringAllAlts()
    local hostRoot = hostPlayer.Character and hostPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hostRoot then
        warn("Bring failed: Host player or HumanoidRootPart not found")
        pcall(function() mainEvent:FireServer("Notify", "Bring failed: Host not found") end)
        return
    end
    local players = getPlayers()
    for _, alt in pairs(players) do
        if alt ~= hostPlayer and alt.Character and alt.Character:FindFirstChild("HumanoidRootPart") then
            local altHumanoidRootPart = alt.Character.HumanoidRootPart
            local index = getAltIndex(alt.Name, players)
            local targetCFrame = hostRoot.CFrame + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
            tweenToPosition(altHumanoidRootPart, targetCFrame, 0.5, Enum.EasingStyle.Quad, index * 0.1)
        end
    end
end

-- Stack alts in a spiral
local function stackAllAlts()
    isStacked = true
    if isSwarming then swarmPlayer(false) end
    if isSpinning then spin(false) end
    if isAirlocked then unairlockAlt() end
    stopFollowAllAlts()
    local hostRoot = hostPlayer.Character and hostPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hostRoot then
        warn("Host player or HumanoidRootPart not found, cannot stack alts")
        isStacked = false
        pcall(function() mainEvent:FireServer("Notify", "Stack failed: Host not found") end)
        return
    end
    local basePosition = hostRoot.Position
    local heightOffset = 3
    local players = getPlayers()
    local altCount = #players - 1
    local spiralRadius = math.min(2, altCount * 0.2)
    local activeTweens = {}
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
            altHumanoidRootPart.Anchored = false
            local tween = TweenService:Create(altHumanoidRootPart, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {CFrame = targetCFrame})
            activeTweens[alt] = tween
            task.wait(index * 0.1)
            tween:Play()
        end
    end
    local tweenConnection = RunService.Heartbeat:Connect(function()
        for alt, tween in pairs(activeTweens) do
            if tween.PlaybackState == Enum.PlaybackState.Playing then
                pcall(function()
                    mainEvent:FireServer("UpdatePosition", alt.Character.HumanoidRootPart.Position)
                end, function(err)
                    warn("Failed to update position in stackAllAlts: " .. tostring(err))
                end)
            end
        end
    end)
    for alt, tween in pairs(activeTweens) do
        tween.Completed:Connect(function()
            local altRoot = alt.Character and alt.Character:FindFirstChild("HumanoidRootPart")
            if altRoot then
                altRoot.Anchored = true
                toggleNoclip(alt.Character, false)
                pcall(function()
                    mainEvent:FireServer("UpdatePosition", altRoot.Position)
                end, function(err)
                    warn("Failed to update position in stackAllAlts: " .. tostring(err))
                end)
            end
            activeTweens[alt] = nil
            if next(activeTweens) == nil then
                tweenConnection:Disconnect()
            end
        end)
    end
end

-- Unstack all alts
local function unstackAllAlts()
    isStacked = false
    local hostRoot = hostPlayer.Character and hostPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hostRoot then
        warn("Unstack failed: Host player or HumanoidRootPart not found")
        pcall(function() mainEvent:FireServer("Notify", "Unstack failed: Host not found") end)
        return
    end
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
            tweenToPosition(altHumanoidRootPart, CFrame.lookAt(targetPosition, basePosition), 1.0, Enum.EasingStyle.Quad, index * 0.1)
        end
    end
end

-- Reset all alt states
local function resetAlts()
    isStacked = false
    isCircled = false
    if isSwarming then swarmPlayer(false) end
    if isSpinning then spin(false) end
    if isAirlocked then unairlockAlt() end
    stopFollowAllAlts()
    setupAtTarget(hostPlayer, humanoidRootPart)
end

-- Kick alt
local function kickAlt()
    pcall(function()
        player:Kick("Kicked by host.")
    end, function(err)
        warn("Failed to kick alt: " .. tostring(err))
    end)
end

-- Rejoin game
local function rejoinGame()
    pcall(function()
        local placeId, jobId = game.PlaceId, game.JobId
        if placeId and jobId then
            TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
        else
            warn("Failed to rejoin: Invalid PlaceId or JobId")
        end
    end, function(err)
        warn("Failed to rejoin game: " .. tostring(err))
    end)
end

-- Handle host leaving
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == hostPlayer then kickAlt() end
end)

-- Handle host character reset
hostPlayer.CharacterAdded:Connect(function(newChar)
    hostRoot = newChar:WaitForChild("HumanoidRootPart")
    if isCircled then circleFormation() end
    if isStacked then stackAllAlts() end
    if isSwarming and swarmTarget == hostPlayer then swarmPlayer(true, hostPlayer) end
end)

-- Handle commands from host
hostPlayer.Chatted:Connect(function(message)
    pcall(function()
        local lowerMsg = string.lower(message)
        if string.sub(lowerMsg, 1, 1) ~= "?" then return end
        local cmd = string.sub(lowerMsg, 2):match("^%s*(.-)%s*$")
        if cmd == "" then return end

        if cmd == "setup host" then
            setupAtTarget(hostPlayer, humanoidRootPart)
        elseif cmd:match("^setup%s+(.+)$") then
            local targetName = cmd:match("^setup%s+(.+)$")
            local target = Players:FindFirstChild(targetName)
            if target then
                setupAtTarget(target, humanoidRootPart)
            else
                warn("Setup failed: Player " .. targetName .. " not found")
                pcall(function() mainEvent:FireServer("Notify", "Setup failed: Player " .. targetName .. " not found") end)
            end
        elseif cmd == "drop" then
            dropAllCash()
        elseif cmd == "stop" then
            stopDrop()
        elseif cmd == "circle host" then
            circleFormation()
        elseif cmd == "swarm host" then
            isStacked = false
            isCircled = false
            if isSpinning then spin(false) end
            if isAirlocked then unairlockAlt() end
            stopFollowAllAlts()
            swarmPlayer(true, hostPlayer)
        elseif cmd == "unswarm host" then
            swarmPlayer(false)
        elseif cmd:match("^swarm%s+(.+)$") then
            local targetName = cmd:match("^swarm%s+(.+)$")
            local target = Players:FindFirstChild(targetName)
            if target then
                isStacked = false
                isCircled = false
                if isSpinning then spin(false) end
                if isAirlocked then unairlockAlt() end
                stopFollowAllAlts()
                swarmPlayer(true, target)
            else
                warn("Swarm failed: Player " .. targetName .. " not found")
                pcall(function() mainEvent:FireServer("Notify", "Swarm failed: Player " .. targetName .. " not found") end)
            end
        elseif cmd == "unswarm" then
            swarmPlayer(false)
        elseif cmd == "spin" then
            spin(true)
        elseif cmd == "unspin" then
            spin(false)
        elseif cmd == "airlock" then
            isStacked = false
            isCircled = false
            if isSwarming then swarmPlayer(false) end
            if isSpinning then spin(false) end
            stopFollowAllAlts()
            airlockAlt()
        elseif cmd == "unairlock" then
            unairlockAlt()
        elseif cmd == "bring" then
            isStacked = false
            isCircled = false
            if isSwarming then swarmPlayer(false) end
            if isSpinning then spin(false) end
            if isAirlocked then unairlockAlt() end
            stopFollowAllAlts()
            bringAllAlts()
        elseif cmd == "follow host" then
            isStacked = false
            isCircled = false
            if isSwarming then swarmPlayer(false) end
            if isSpinning then spin(false) end
            if isAirlocked then unairlockAlt() end
            followAllAlts(hostPlayer)
        elseif cmd:match("^follow%s+(.+)$") then
            local targetName = cmd:match("^follow%s+(.+)$")
            local target = Players:FindFirstChild(targetName)
            if target then
                isStacked = false
                isCircled = false
                if isSwarming then swarmPlayer(false) end
                if isSpinning then spin(false) end
                if isAirlocked then unairlockAlt() end
                followAllAlts(target)
            else
                warn("Follow failed: Player " .. targetName .. " not found")
                pcall(function() mainEvent:FireServer("Notify", "Follow failed: Player " .. targetName .. " not found") end)
            end
        elseif cmd == "unfollow" then
            stopFollowAllAlts()
        elseif cmd == "stack host" then
            isCircled = false
            stackAllAlts()
        elseif cmd == "unstack" then
            unstackAllAlts()
        elseif cmd == "reset" then
            resetAlts()
        elseif cmd == "kick" then
            kickAlt()
        elseif cmd == "rejoin" then
            rejoinGame()
        else
            warn("Unknown command: " .. cmd)
            pcall(function() mainEvent:FireServer("Notify", "Unknown command: " .. cmd) end)
        end
    end, function(err)
        warn("Error processing command: " .. tostring(err))
        pcall(function() mainEvent:FireServer("Notify", "Error processing command: " .. tostring(err)) end)
    end)
end)

-- Handle player character reset
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    humanoid = newChar:WaitForChild("Humanoid")
    if isSwarming and swarmTarget then swarmPlayer(true, swarmTarget) end
    if isSpinning then spin(true) end
    if isAirlocked then airlockAlt() end
    if isStacked then stackAllAlts() end
    if isCircled then circleFormation() end
end)

-- Cleanup connections when player leaves
player.AncestryChanged:Connect(function()
    if not player:IsDescendantOf(game) then
        for key, conn in pairs(connections) do
            if type(conn) == "table" then
                for _, subConn in pairs(conn) do
                    if subConn then subConn:Disconnect() end
                end
            elseif conn then
                conn:Disconnect()
            end
            connections[key] = nil
        end
        isDropping, isSwarming, isSpinning, isAirlocked, isStacked, isCircled = false, false, false, false, false, false
        swarmTarget = nil
    end
end)

-- Initialize script
createOverlay()
limitFPS()
preventAFK()
disableAllSeats()
print("dhc.lmao Alt Control Script loaded for " .. player.Name)
