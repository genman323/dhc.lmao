-- Services
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')
local TeleportService = game:GetService('TeleportService')
local TweenService = game:GetService('TweenService')

-- Local player and character setup
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild('HumanoidRootPart', 5)
local humanoid = character:WaitForChild('Humanoid', 5)

-- Host setup
local hostName = 'HarperViperZero20033'
local hostPlayer = nil

-- State variables
local isDropping = false
local currentMode = nil -- "swarm", "follow", "setup", nil
local currentTarget = nil
local originalCFrame = nil
local airlockPlatform = nil
local lastDropTime = 0
local dropCooldown = 0.1
local originalAnims = nil
local originalPosition = nil -- Store original position before dropping
local connections = {
    drop = nil,
    swarm = nil,
    follow = nil,
    fps = nil,
    afk = nil,
    setupMove = nil,
}

-- Anti-cheat bypass (unchanged)
local detectionFlags = {
    'CHECKER_1',
    'CHECKER',
    'TeleportDetect',
    'OneMoreTime',
    'BRICKCHECK',
    'BADREQUEST',
    'BANREMOTE',
    'KICKREMOTE',
    'PERMAIDBAN',
    'PERMABAN',
}
local oldNamecall
oldNamecall = hookmetamethod(game, '__namecall', function(self, ...)
    local args = { ... }
    local method = getnamecallmethod()
    if
        method == 'FireServer'
        and self.Name == 'MainEvent'
        and table.find(detectionFlags, args[1])
    then
        return task.wait(9e9)
    end
    return oldNamecall(self, ...)
end)

-- Main event
local mainEvent = ReplicatedStorage:WaitForChild('MainEvent', 5)
if not mainEvent then
    warn('MainEvent not found. Some features like dropping cash may not work.')
end

-- Utility Functions
local function waitForHost(timeout)
    local success, result = pcall(function()
        return Players:WaitForChild(hostName, timeout)
    end)
    if success and result then
        return result
    end
    warn(
        'Host player '
            .. hostName
            .. ' not found within '
            .. timeout
            .. ' seconds.'
    )
    return nil
end

local function getPlayers()
    return Players:GetPlayers()
end

local function disableAllSeats()
    for _, seat in ipairs(game.Workspace:GetDescendants()) do
        if seat:IsA('Seat') then
            seat.Disabled = true
        end
    end
end

local function createOverlay()
    local screenGui = Instance.new('ScreenGui')
    screenGui.Parent = player:WaitForChild('PlayerGui', 5)
    screenGui.Name = 'DhcOverlay'
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true

    local blurEffect = Instance.new('BlurEffect')
    blurEffect.Size = 48
    blurEffect.Parent = game.Lighting

    local background = Instance.new('Frame')
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0
    background.Parent = screenGui

    local mainText = Instance.new('TextLabel')
    mainText.Size = UDim2.new(0, 400, 0, 100)
    mainText.Position = UDim2.new(0.5, -200, 0.5, -50)
    mainText.BackgroundTransparency = 1
    mainText.Text = 'dhc.lmao'
    mainText.TextSize = 48
    mainText.Font = Enum.Font.GothamBold
    mainText.TextColor3 = Color3.fromRGB(120, 60, 180) -- Starting purple
    mainText.Parent = background

    local gradient = Instance.new('UIGradient')
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 60, 180)), -- Purple
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))      -- Black
    }
    gradient.Parent = mainText
end

local function limitFPS()
    local targetDeltaTime = 1 / 5
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

-- FIXED: AFK prevention - now every 58s instead of every frame
local lastAFKJump = 0
local afkInterval = 58 -- seconds
local function preventAFK()
    connections.afk = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        if currentTime - lastAFKJump >= afkInterval then
            if humanoid then
                humanoid.Jump = true
                task.wait(0.1)
                humanoid.Jump = false
            end
            lastAFKJump = currentTime
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
    table.sort(alts, function(a, b)
        return a.Name < b.Name
    end)
    local maxAlts = 20
    if #alts > maxAlts then
        warn('Limiting to ' .. maxAlts .. ' alts due to maximum capacity.')
        alts = { table.unpack(alts, 1, maxAlts) }
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
        if part:IsA('BasePart') and not part:IsA('Accessory') then
            part.CanCollide = not enable
            if enable then
                part.Velocity = Vector3.zero
            end
        end
    end
end

-- Animation Management (Updated for Server Sync)
local function saveOriginalAnimations()
    local animate = character:WaitForChild('Animate')
    originalAnims = {
        idle1 = animate.idle.Animation1.AnimationId,
        idle2 = animate.idle.Animation2.AnimationId,
        walk = animate.walk.WalkAnim.AnimationId,
        run = animate.run.RunAnim.AnimationId,
        jump = animate.jump.JumpAnim.AnimationId,
        climb = animate.climb.ClimbAnim.AnimationId,
        fall = animate.fall.FallAnim.AnimationId,
    }
end

local function applyLevitationAnimation()
    if not character or not humanoid then return end
    
    -- Local client animation (for alt's screen)
    local animate = character:WaitForChild('Animate')
    animate.idle.Animation1.AnimationId = 'http://www.roblox.com/asset/?id=70731164340462'
    animate.idle.Animation2.AnimationId = 'http://www.roblox.com/asset/?id=70731164340462'
    animate.walk.WalkAnim.AnimationId = 'http://www.roblox.com/asset/?id=70731164340462'
    animate.run.RunAnim.AnimationId = 'http://www.roblox.com/asset/?id=70731164340462'
    animate.jump.JumpAnim.AnimationId = 'http://www.roblox.com/asset/?id=670731164340462'
    animate.climb.ClimbAnim.AnimationId = 'http://www.roblox.com/asset/?id=70731164340462'
    animate.fall.FallAnim.AnimationId = 'http://www.roblox.com/asset/?id=70731164340462'
    humanoid.Jump = true
    
    -- Request server to sync animation
    if mainEvent then
        pcall(function()
            mainEvent:FireServer('ApplyLevitation', {
                idle1 = 'http://www.roblox.com/asset/?id=70731164340462',
                idle2 = 'http://www.roblox.com/asset/?id=70731164340462',
                walk = 'http://www.roblox.com/asset/?id=70731164340462',
                run = 'http://www.roblox.com/asset/?id=70731164340462',
                jump = 'http://www.roblox.com/asset/?id=70731164340462',
                climb = 'http://www.roblox.com/asset/?id=70731164340462',
                fall = 'http://www.roblox.com/asset/?id=70731164340462',
            })
        end)
    end
end

local function restoreOriginalAnimations()
    if not character or not humanoid or not originalAnims then return end
    
    local animate = character:WaitForChild('Animate')
    animate.idle.Animation1.AnimationId = originalAnims.idle1
    animate.idle.Animation2.AnimationId = originalAnims.idle2
    animate.walk.WalkAnim.AnimationId = originalAnims.walk
    animate.run.RunAnim.AnimationId = originalAnims.run
    animate.jump.JumpAnim.AnimationId = originalAnims.jump
    animate.climb.ClimbAnim.AnimationId = originalAnims.climb
    animate.fall.FallAnim.AnimationId = originalAnims.fall
    humanoid.Jump = true
    
    if mainEvent then
        pcall(function()
            mainEvent:FireServer('RestoreAnimations', originalAnims)
        end)
    end
end

local function setupAnimationServerHandler()
    if not mainEvent then return end
    
    mainEvent.OnClientEvent:Connect(function(action, data)
        if action == 'ApplyLevitation' and character then
            local humanoid = character:FindFirstChild('Humanoid')
            if humanoid then
                local animate = character:FindFirstChild('Animate')
                if animate then
                    animate.idle.Animation1.AnimationId = data.idle1
                    animate.idle.Animation2.AnimationId = data.idle2
                    animate.walk.WalkAnim.AnimationId = data.walk
                    animate.run.RunAnim.AnimationId = data.run
                    animate.jump.JumpAnim.AnimationId = data.jump
                    animate.climb.ClimbAnim.AnimationId = data.climb
                    animate.fall.FallAnim.AnimationId = data.fall
                    humanoid.Jump = true
                end
            end
        elseif action == 'RestoreAnimations' and character then
            local humanoid = character:FindFirstChild('Humanoid')
            if humanoid and data then
                local animate = character:FindFirstChild('Animate')
                if animate then
                    animate.idle.Animation1.AnimationId = data.idle1
                    animate.idle.Animation2.AnimationId = data.idle2
                    animate.walk.WalkAnim.AnimationId = data.walk
                    animate.run.RunAnim.AnimationId = data.run
                    animate.jump.JumpAnim.AnimationId = data.jump
                    animate.climb.ClimbAnim.AnimationId = data.climb
                    animate.fall.FallAnim.AnimationId = data.fall
                    humanoid.Jump = true
                end
            end
        end
    end)
end

-- Mode Management
local function disableCurrentMode()
    if humanoidRootPart then
        humanoidRootPart.Anchored = false
    end
    for key, conn in pairs(connections) do
        if key ~= 'fps' and key ~= 'afk' and key ~= 'drop' and conn then
            conn:Disconnect()
            connections[key] = nil
        end
    end
    currentMode = nil
    currentTarget = nil
    toggleNoclip(character, false)
end

-- FIXED: Added unswarm function
local function unswarm()
    if currentMode ~= 'swarm' then
        warn('Not in swarm mode.')
        return
    end
    disableCurrentMode()
    print('Unswarm: Returning to setup.')
    setupClub() -- Default to club grid
end

local function setupGrid(position, facingDirection)
    if not humanoidRootPart then
        warn('Setup grid failed: Local character not found')
        return
    end
    toggleNoclip(character, true)
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
    local targetCFrame =
        CFrame.new(offsetPosition, offsetPosition + facingDirection)
    local tweenInfo =
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(
        humanoidRootPart,
        tweenInfo,
        { CFrame = targetCFrame }
    )
    tween:Play()
    currentMode = 'setup'
    tween.Completed:Connect(function()
        if currentMode == 'setup' then
            currentMode = nil
        end
    end)
    toggleNoclip(character, false)
end

local function setup(targetPlayer)
    disableCurrentMode()
    if
        not targetPlayer
        or not targetPlayer.Character
        or not targetPlayer.Character:FindFirstChild('HumanoidRootPart')
        or not humanoidRootPart
    then
        warn('Setup failed: Invalid target or local character')
        return
    end
    toggleNoclip(character, true)
    local targetRoot = targetPlayer.Character.HumanoidRootPart
    local players = getPlayers()
    local index = getAltIndex(player.Name, players)
    local spacing = 1
    local behindDirection = -targetRoot.CFrame.LookVector
    local offsetPosition = targetRoot.Position
        + behindDirection * (spacing * (index + 1))
    local targetCFrame = CFrame.lookAt(offsetPosition, targetRoot.Position)
    local tweenInfo =
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(
        humanoidRootPart,
        tweenInfo,
        { CFrame = targetCFrame }
    )
    tween:Play()
    currentMode = 'setup'
    tween.Completed:Connect(function()
        if currentMode == 'setup' then
            currentMode = nil
        end
    end)
    toggleNoclip(character, false)
end

local function setupClub()
    setupGrid(Vector3.new(-265, -7, -380), Vector3.new(0, 0, -1))
end

local function setupBank()
    setupGrid(Vector3.new(-376, 21, -283), Vector3.new(0, 0, -1))
end

local function swarm(targetPlayer)
    disableCurrentMode()
    currentMode = 'swarm'
    currentTarget = targetPlayer
    if
        not currentTarget
        or not currentTarget.Character
        or not currentTarget.Character:FindFirstChild('HumanoidRootPart')
        or not humanoidRootPart
    then
        warn('Swarm failed: Invalid target or local character')
        currentMode = nil
        currentTarget = nil
        return
    end
    toggleNoclip(character, true)
    connections.swarm = RunService.RenderStepped:Connect(function()
        if
            currentMode ~= 'swarm'
            or not humanoidRootPart
            or not currentTarget
            or not currentTarget.Character
            or not currentTarget.Character:FindFirstChild('HumanoidRootPart')
        then
            toggleNoclip(character, false)
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
    end)
end

local function follow(targetPlayer)
    disableCurrentMode()
    currentMode = 'follow'
    currentTarget = targetPlayer
    if
        not currentTarget
        or not currentTarget.Character
        or not currentTarget.Character:FindFirstChild('HumanoidRootPart')
        or not humanoidRootPart
    then
        warn('Follow failed: Invalid target or local character')
        currentMode = nil
        currentTarget = nil
        return
    end
    toggleNoclip(character, true)
    connections.follow = RunService.RenderStepped:Connect(function()
        if
            currentMode ~= 'follow'
            or not humanoidRootPart
            or not currentTarget
            or not currentTarget.Character
            or not currentTarget.Character:FindFirstChild('HumanoidRootPart')
        then
            toggleNoclip(character, false)
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
        humanoidRootPart.CFrame = currentCFrame:Lerp(targetCFrame, 0.3) -- Reduced for less jitter
    end)
end

local function bring()
    disableCurrentMode()
    if
        not hostPlayer
        or not hostPlayer.Character
        or not hostPlayer.Character:FindFirstChild('HumanoidRootPart')
        or not humanoidRootPart
    then
        warn('Bring failed: Invalid host or local character')
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
    local tweenInfo =
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(
        humanoidRootPart,
        tweenInfo,
        { CFrame = targetCFrame }
    )
    tween:Play()
end

-- FIXED: Completely restructured drop - bury once, freeze, drop in loop, unbury on stop
local function buryAlt()
    if not humanoidRootPart then
        return
    end
    originalPosition = humanoidRootPart.CFrame -- Save original position
    toggleNoclip(character, true)

    -- Improved raycast for ground (longer range, filter more)
    local rayOrigin = humanoidRootPart.Position
    local rayDirection = Vector3.new(0, -2000, 0) -- Longer ray
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = { character }
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local raycastResult =
        workspace:Raycast(rayOrigin, rayDirection, raycastParams)

    local groundY
    if raycastResult then
        groundY = raycastResult.Position.Y
        print('Raycast hit ground at Y=' .. groundY)
    else
        groundY = humanoidRootPart.Position.Y -- Fallback
        warn('Raycast failed - using fallback Y=' .. groundY)
    end

    local buryDepth = 5 -- Studs underground
    local targetY = groundY - buryDepth
    local startCFrame = humanoidRootPart.CFrame
    local targetCFrame = CFrame.new(
        startCFrame.Position.X,
        targetY,
        startCFrame.Position.Z
    ) * startCFrame.Rotation

    local tweenInfo =
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(
        humanoidRootPart,
        tweenInfo,
        { CFrame = targetCFrame }
    )
    tween:Play()
    tween.Completed:Wait()

    humanoidRootPart.Anchored = true -- FREEZE underground
    print('Alt buried and frozen at Y=' .. targetY)
end

local function unburyAlt()
    if not humanoidRootPart then
        return
    end
    humanoidRootPart.Anchored = false
    toggleNoclip(character, false)
    if originalPosition then
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, { CFrame = originalPosition })
        tween:Play()
        tween.Completed:Wait()
        originalPosition = nil -- Clear after returning
    else
        warn('No original position saved, returning to setup.')
        setupClub() -- Fallback if no original position
    end
    print('Alt unburied and returned to original position.')
end

local function dropv2()
    if not mainEvent then
        warn('MainEvent not found, cannot drop cash.')
        return
    end
    if isDropping then
        return
    end -- Prevent double-start
    isDropping = true

    -- Bury once at start
    buryAlt()

    -- Start dropping loop (no movement, just fire remote)
    connections.drop = RunService.Heartbeat:Connect(function()
        if not isDropping or not humanoidRootPart then
            return
        end
        local currentTime = tick()
        if currentTime - lastDropTime >= dropCooldown then
            pcall(function()
                mainEvent:FireServer('DropMoney', 15000)
            end)
            lastDropTime = currentTime
        end
    end)
    print('Dropv2 started - alt buried and dropping continuously.')
end

local function dropCash()
    if not mainEvent then
        warn('MainEvent not found, cannot drop cash.')
        return
    end
    if isDropping then
        return
    end -- Prevent double-start
    isDropping = true

    -- Start dropping loop without burying
    connections.drop = RunService.Heartbeat:Connect(function()
        if not isDropping or not humanoidRootPart then
            return
        end
        local currentTime = tick()
        if currentTime - lastDropTime >= dropCooldown then
            pcall(function()
                mainEvent:FireServer('DropMoney', 15000)
            end)
            lastDropTime = currentTime
        end
    end)
    print('Drop started - cash dropping without burying.')
end

local function stopDrop()
    if not isDropping then
        return
    end
    isDropping = false
    if connections.drop then
        connections.drop:Disconnect()
        connections.drop = nil
    end
    if mainEvent then
        pcall(function()
            mainEvent:FireServer('Block', false)
        end)
    end
    -- Only unbury if the alt was buried (from dropv2)
    if originalPosition then
        unburyAlt()
    end
    print('Drop stopped.')
end

local function kickAlt()
    pcall(function()
        player:Kick('Kicked by your host.')
    end)
end

local function rejoinGame()
    pcall(function()
        TeleportService:TeleportToPlaceInstance(
            game.PlaceId,
            game.JobId,
            player
        )
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
        if currentMode == 'swarm' then
            swarm(hostPlayer)
        elseif currentMode == 'follow' then
            follow(hostPlayer)
        end
    end
end

local function handlePlayerCharacterReset(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild('HumanoidRootPart', 5)
    humanoid = newChar:WaitForChild('Humanoid', 5)
    if currentMode and currentTarget then
        if currentMode == 'swarm' then
            swarm(currentTarget)
        elseif currentMode == 'follow' then
            follow(currentTarget)
        elseif currentMode == 'setup' and currentTarget == nil then
            setupClub()
        end
    end
    if isDropping then
        if originalPosition then
            buryAlt() -- Re-bury if respawned during dropv2
        end
    end
end

local function handleCommands(message)
    local lowerMsg = string.lower(message)
    if string.sub(lowerMsg, 1, 1) ~= '?' then
        return
    end
    local cmd = string.sub(lowerMsg, 2):match('^%s*(.-)%s*$')
    if cmd == '' then
        return
    end

    if cmd == 'setup host' then
        setup(hostPlayer)
    elseif cmd:match('^setup%s+(.+)$') then
        local targetName = cmd:match('^setup%s+(.+)$')
        if targetName == 'club' then
            setupClub()
        elseif targetName == 'bank' then
            setupBank()
        else
            local target = Players:FindFirstChild(targetName)
            if target then
                setup(target)
            else
                warn('Setup failed: Player ' .. targetName .. ' not found')
            end
        end
    elseif cmd == 'swarm host' then
        swarm(hostPlayer)
    elseif cmd:match('^swarm%s+(.+)$') then
        local targetName = cmd:match('^swarm%s+(.+)$')
        local target = Players:FindFirstChild(targetName)
        if target then
            swarm(target)
        else
            warn('Swarm failed: Player ' .. targetName .. ' not found')
        end
    elseif cmd == 'unswarm' then
        unswarm() -- NOW WORKS!
    elseif cmd == 'follow host' then
        follow(hostPlayer)
    elseif cmd:match('^follow%s+(.+)$') then
        local targetName = cmd:match('^follow%s+(.+)$')
        local target = Players:FindFirstChild(targetName)
        if target then
            follow(target)
        else
            warn('Follow failed: Player ' .. targetName .. ' not found')
        end
    elseif cmd == 'unfollow' then
        disableCurrentMode()
        setup(hostPlayer)
    elseif cmd == 'bring' then
        bring()
    elseif cmd == 'dropv2' then
        dropv2()
    elseif cmd == 'drop' then
        dropCash()
    elseif cmd == 'stop' then
        stopDrop()
    elseif cmd == 'kick' then
        kickAlt()
    elseif cmd == 'rejoin' then
        rejoinGame()
    else
        warn('Unknown command: ' .. cmd)
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
        stopDrop()
        currentMode = nil
        currentTarget = nil
        if game.Lighting:FindFirstChild('BlurEffect') then
            game.Lighting.BlurEffect:Destroy()
        end
    end
end

-- Update status in overlay (simplified, no UI update needed)
local function updateStatus(status, altCount)
    -- No UI update since overlay is static
end

-- Initialization
hostPlayer = waitForHost(10)
if not hostPlayer then
    warn('Script cannot proceed without host player. Shutting down.')
    return
end

Players.PlayerRemoving:Connect(handleHostLeaving)
hostPlayer.Chatted:Connect(handleCommands)
hostPlayer.CharacterAdded:Connect(handleHostCharacterReset)
player.CharacterAdded:Connect(handlePlayerCharacterReset)
player.AncestryChanged:Connect(cleanup)

createOverlay()
limitFPS()
preventAFK()
disableAllSeats()
setupAnimationServerHandler()

saveOriginalAnimations()
applyLevitationAnimation()

print(
    'dhc.lmao Alt Control Script (FIXED) loaded for '
        .. player.Name
        .. ' in Da Hood'
)
