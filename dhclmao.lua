-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

-- Local player and character setup
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
local humanoid = character:WaitForChild("Humanoid", 5)

-- Host setup
local hostName = "Sab3r_PRO2003"
local hostPlayer = nil

-- State variables
local isDropping = false
local currentMode = nil -- "swarm", "follow", "airlock", "setup", nil
local currentTarget = nil
local originalCFrame = nil
local airlockPlatform = nil
local airlockPosition = nil
local lastDropTime = 0
local dropCooldown = 0.1
local originalAnims = nil
local connections = {
    drop = nil,
    swarm = nil,
    follow = nil,
    fps = nil,
    afk = nil,
    airlockFreeze = nil,
    setupMove = nil
}

-- Anti-cheat bypass
local detectionFlags = {
    "CHECKER_1", "CHECKER", "TeleportDetect", "OneMoreTime", "BRICKCHECK",
    "BADREQUEST", "BANREMOTE", "KICKREMOTE", "PERMAIDBAN", "PERMABAN"
}
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if method == "FireServer" and self.Name == "MainEvent" and table.find(detectionFlags, args[1]) then
        return task.wait(9e9) -- Block detection
    end
    return oldNamecall(self, ...)
end)

-- Main event
local mainEvent = ReplicatedStorage:WaitForChild("MainEvent", 5)
if not mainEvent then
    warn("MainEvent not found. Some features like dropping cash may not work.")
end

-- Utility Functions
local function waitForHost(timeout)
    local success, result = pcall(function()
        return Players:WaitForChild(hostName, timeout)
    end)
    if success and result then
        return result
    end
    warn("Host player " .. hostName .. " not found within " .. timeout .. " seconds.")
    return nil
end

local function getPlayers()
    return Players:GetPlayers()
end

local function disableAllSeats()
    for _, seat in ipairs(game.Workspace:GetDescendants()) do
        if seat:IsA("Seat") then
            seat.Disabled = true
        end
    end
end

local function createOverlay()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player:WaitForChild("PlayerGui", 5)
    screenGui.Name = "DhcOverlay"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true

    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Size = 48 -- Stronger blur
    blurEffect.Parent = game.Lighting

    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.5 -- Slightly visible to allow overlay focus
    background.Parent = screenGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 150)
    frame.Position = UDim2.new(0.5, -200, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(30, 0, 50) -- Dark purple background
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 15)
    uiCorner.Parent = frame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 1, -20)
    textLabel.Position = UDim2.new(0, 10, 0, 10)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "dhc.lmao"
    textLabel.TextColor3 = Color3.fromRGB(150, 100, 200) -- Light purple text
    textLabel.TextSize = 18
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextWrapped = true
    textLabel.Parent = frame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Thickness = 2
    uiStroke.Color = Color3.fromRGB(80, 40, 120) -- Purple outline
    uiStroke.Parent = frame
end

local function limitFPS()
    local targetDeltaTime = 1 / 5 -- Cap at 5 FPS
    local lastTime = tick()
    connections.fps = RunService.RenderStepped:Connect(function()
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

local function getAltIndex(playerName, players)
    local alts = {}
    for _, p in ipairs(players) do
        if p ~= hostPlayer then
            table.insert(alts, p)
        end
    end
    table.sort(alts, function(a, b) return a.Name < b.Name end)
    local maxAlts = 20
    if #alts > maxAlts then
        warn("Limiting to " .. maxAlts .. " alts due to maximum capacity.")
        alts = {table.unpack(alts, 1, maxAlts)}
    end
    for i, p in ipairs(alts) do
        if p.Name == playerName then
            return i - 1
        end
    end
    return 0
end

local function toggleNoclip(char, enable)
    if not char then
        return
    end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and not part:IsA("Accessory") then
            part.CanCollide = false -- Always disable collision for alts
            part.Velocity = Vector3.zero
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

-- Animation Management
local function saveOriginalAnimations()
    local animate = character:WaitForChild("Animate")
    originalAnims = {
        idle1 = animate.idle.Animation1.AnimationId,
        idle2 = animate.idle.Animation2.AnimationId,
        walk = animate.walk.WalkAnim.AnimationId,
        run = animate.run.RunAnim.AnimationId,
        jump = animate.jump.JumpAnim.AnimationId,
        climb = animate.climb.ClimbAnim.AnimationId,
        fall = animate.fall.FallAnim.AnimationId
    }
end

local function applyLevitationAnimation()
    local animate = character:WaitForChild("Animate")
    animate.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=616006778"
    animate.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=616008087"
    animate.walk.WalkAnim.AnimationId = "http://www.roblox.com/asset/?id=616013216"
    animate.run.RunAnim.AnimationId = "http://www.roblox.com/asset/?id=616010382"
    animate.jump.JumpAnim.AnimationId = "http://www.roblox.com/asset/?id=616008936"
    animate.climb.ClimbAnim.AnimationId = "http://www.roblox.com/asset/?id=616003713"
    animate.fall.FallAnim.AnimationId = "http://www.roblox.com/asset/?id=616005863"
    humanoid.Jump = true
end

local function restoreOriginalAnimations()
    if originalAnims and character:FindFirstChild("Animate") then
        local animate = character.Animate
        animate.idle.Animation1.AnimationId = originalAnims.idle1
        animate.idle.Animation2.AnimationId = originalAnims.idle2
        animate.walk.WalkAnim.AnimationId = originalAnims.walk
        animate.run.RunAnim.AnimationId = originalAnims.run
        animate.jump.JumpAnim.AnimationId = originalAnims.jump
        animate.climb.ClimbAnim.AnimationId = originalAnims.climb
        animate.fall.FallAnim.AnimationId = originalAnims.fall
        humanoid.Jump = true
    end
end

-- Mode Management
local function disableCurrentMode()
    if humanoidRootPart then
        humanoidRootPart.Anchored = false
    end
    for key, conn in pairs(connections) do
        if key ~= "fps" and key ~= "afk" and key ~= "drop" and conn then
            conn:Disconnect()
            connections[key] = nil
        end
    end
    if airlockPlatform then
        airlockPlatform:Destroy()
        airlockPlatform = nil
    end
    currentMode = nil
    currentTarget = nil
    airlockPosition = nil
    toggleNoclip(character, true) -- Keep noclip on
end

local function setupGrid(position, facingDirection)
    if not humanoidRootPart then
        warn("Setup grid failed: Local character not found")
        return
    end
    toggleNoclip(character, true) -- Keep noclip on
    local players = getPlayers()
    local index = getAltIndex(player.Name, players)
    local rows, cols, spacing = 5, 4, 2
    local maxAlts = 20
    local totalAlts = math.min(#players - 1, maxAlts)
    local halfWidth = (cols * spacing) / 2
    local halfDepth = (rows * spacing) / 2
    local row = math.floor(index / cols)
    local col = index % cols
    local offsetX = -halfWidth + (col * spacing) + (spacing / 2)
    local offsetZ = -halfDepth + (row * spacing) + (spacing / 2)
    local offsetPosition = position + Vector3.new(offsetX, 0, offsetZ)
    local targetCFrame = CFrame.new(offsetPosition, offsetPosition + facingDirection)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    currentMode = "setup"
    tween.Completed:Connect(function()
        if currentMode == "setup" then
            currentMode = nil
        end
    end)
    -- No toggleNoclip off, keep it on
end

local function setup(targetPlayer)
    disableCurrentMode()
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") or not humanoidRootPart then
        warn("Setup failed: Invalid target or local character")
        return
    end
    toggleNoclip(character, true) -- Keep noclip on
    local targetRoot = targetPlayer.Character.HumanoidRootPart
    local players = getPlayers()
    local index = getAltIndex(player.Name, players)
    local spacing = 1
    local behindDirection = -targetRoot.CFrame.LookVector
    local offsetPosition = targetRoot.Position + behindDirection * (spacing * (index + 1))
    local targetCFrame = CFrame.lookAt(offsetPosition, targetRoot.Position)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    currentMode = "setup"
    tween.Completed:Connect(function()
        if currentMode == "setup" then
            currentMode = nil
        end
    end)
    -- No toggleNoclip off, keep it on
end

local function setupClub()
    setupGrid(Vector3.new(-265, -7, -380), Vector3.new(0, 0, -1))
end

local function setupBank()
    setupGrid(Vector3.new(-376, 21, -283), Vector3.new(0, 0, -1))
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
    toggleNoclip(character, true) -- Keep noclip on
    connections.swarm = RunService.RenderStepped:Connect(function()
        if currentMode ~= "swarm" or not humanoidRootPart or not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then
            toggleNoclip(character, true) -- Keep noclip on
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
        local targetPosition = center + Vector3.new(x, 0, z)
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.lookAt(targetPosition, center)})
        tween:Play()
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
    toggleNoclip(character, true) -- Keep noclip on
    connections.follow = RunService.RenderStepped:Connect(function()
        if currentMode ~= "follow" or not humanoidRootPart or not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then
            toggleNoclip(character, true) -- Keep noclip on
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
        local targetCFrame = CFrame.lookAt(myPos, lookPos)
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
    end)
end

local function airlock()
    disableCurrentMode()
    if not humanoidRootPart or not humanoid then
        warn("Airlock failed: Humanoid or HumanoidRootPart not found")
        return
    end
    -- Save original position and animations
    originalCFrame = humanoidRootPart.CFrame
    saveOriginalAnimations()

    -- Use raycasting to find the ground height for accurate positioning
    local rayOrigin = humanoidRootPart.Position
    local rayDirection = Vector3.new(0, -1000, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    local groundY = raycastResult and raycastResult.Position.Y or humanoidRootPart.Position.Y
    local targetHeight = groundY + 13 -- Target exactly 13 studs above ground

    -- Create airlock platform at target height
    airlockPosition = CFrame.new(humanoidRootPart.Position.X, targetHeight, humanoidRootPart.Position.Z)
    airlockPlatform = createAirlockPlatform(Vector3.new(humanoidRootPart.Position.X, targetHeight, humanoidRootPart.Position.Z))

    -- Move character to airlock position with smooth transition, preserving orientation
    toggleNoclip(character, true) -- Keep noclip on
    local startTime = tick()
    local duration = 1.0 -- Smoother lift
    local startCFrame = humanoidRootPart.CFrame
    local targetCFrame = CFrame.new(humanoidRootPart.Position.X, targetHeight, humanoidRootPart.Position.Z) * startCFrame.Rotation -- Preserve rotation, lift vertically
    currentMode = "airlock"
    if connections.airlockMove then
        connections.airlockMove:Disconnect()
    end
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Connect(function()
        if currentMode == "airlock" and humanoidRootPart then
            humanoidRootPart.Anchored = false -- Allow standing on platform
            humanoidRootPart.Velocity = Vector3.new(0, 0, 0) -- Prevent movement
            applyLevitationAnimation()
        end
    end)
    -- No toggleNoclip off, keep it on
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
    toggleNoclip(character, true) -- Keep noclip on
    humanoidRootPart.Anchored = false
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = originalCFrame})
    tween:Play()
    restoreOriginalAnimations()
    -- No toggleNoclip off, keep it on
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
    toggleNoclip(character, true) -- Keep noclip on
    local hostRoot = hostPlayer.Character.HumanoidRootPart
    local players = getPlayers()
    local index = getAltIndex(player.Name, players)
    local angle = index * (2 * math.pi / #players)
    local radius = 2
    local x = math.cos(angle) * radius
    local z = math.sin(angle) * radius
    local targetPosition = hostRoot.Position + Vector3.new(x, 0, z)
    local targetCFrame = CFrame.lookAt(targetPosition, hostRoot.Position)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    -- No toggleNoclip off, keep it on
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
                    -- Removed Block to prevent blocking
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
        -- Ensure player is properly loaded
        if player.Parent and player.Character then
            -- Try simple teleport first
            TeleportService:Teleport(game.PlaceId, player)
        else
            warn("Player not fully loaded, retrying in 1 second...")
            task.wait(1)
            TeleportService:Teleport(game.PlaceId, player)
        end
    end)
end

-- Event Handlers
local function handleHostLeaving(leavingPlayer)
    if leavingPlayer == hostPlayer then
        kickAlt()
    end
end

local function handleHostCharacterReset(newChar)
    if currentTarget == hostPlayer then
        if currentMode == "swarm" then
            swarm(hostPlayer)
        elseif currentMode == "follow" then
            follow(hostPlayer)
        end
    end
end

local function handlePlayerCharacterReset(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart", 5)
    humanoid = newChar:WaitForChild("Humanoid", 5)
    toggleNoclip(character, true) -- Ensure noclip on character reset
    if currentMode and currentTarget then
        if currentMode == "swarm" then
            swarm(currentTarget)
        elseif currentMode == "follow" then
            follow(currentTarget)
        elseif currentMode == "airlock" and airlockPosition then
            airlock()
        elseif currentMode == "setup" and currentTarget == nil then
            setupClub()
        end
    end
end

local function handleCommands(message)
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

local function cleanup()
    if not player:IsDescendantOf(game) then
        for key, conn in pairs(connections) do
            if conn then
                conn:Disconnect()
                connections[key] = nil
            end
        end
        isDropping = false
        currentMode = nil
        currentTarget = nil
        airlockPosition = nil
        if airlockPlatform then
            airlockPlatform:Destroy()
            airlockPlatform = nil
        end
        if game.Lighting:FindFirstChild("BlurEffect") then
            game.Lighting.BlurEffect:Destroy()
        end
    end
end

-- Initialization
hostPlayer = waitForHost(10)
if not hostPlayer then
    warn("Script cannot proceed without host player. Shutting down.")
    return
end

toggleNoclip(character, true) -- Enable noclip on script start
Players.PlayerRemoving:Connect(handleHostLeaving)
hostPlayer.Chatted:Connect(handleCommands)
hostPlayer.CharacterAdded:Connect(handleHostCharacterReset)
player.CharacterAdded:Connect(handlePlayerCharacterReset)
player.AncestryChanged:Connect(cleanup)

createOverlay()
limitFPS()
preventAFK()
disableAllSeats()

print("dhc.lmao Alt Control Script loaded for " .. player.Name .. " in Da Hood")
