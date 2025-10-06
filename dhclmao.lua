-- Services to get this script rolling
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

-- Grab the local player and their character
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait() -- Wait if it’s not ready
local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
local humanoid = character:WaitForChild("Humanoid", 5)

-- Set up the host and some tracking vars
local hostName = "HarperViperZero20033" -- The main player we follow
local hostPlayer = nil

local isDropping = false -- Are we dropping cash?
local currentMode = nil -- Could be "swarm", "follow", or "setup"
local currentTarget = nil
local originalCFrame = nil
local lastDropTime = 0
local dropCooldown = 0.1 -- Short pause between drops
local originalPosition = nil -- Where the alt started
local connections = { -- Hold onto our connections
    drop = nil,
    swarm = nil,
    follow = nil,
    fps = nil,
    afk = nil,
    setupMove = nil,
}

-- Quick anti-cheat trick to dodge detection
local detectionFlags = {
    "CHECKER_1",
    "CHECKER",
    "TeleportDetect",
    "OneMoreTime",
    "BRICKCHECK",
    "BADREQUEST",
    "BANREMOTE",
    "KICKREMOTE",
    "PERMAIDBAN",
    "PERMABAN",
}
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = { ... }
    local method = getnamecallmethod()
    if method == "FireServer" and self.Name == "MainEvent" and table.find(detectionFlags, args[1]) then
        return task.wait(9e9) -- Put those checks on hold!
    end
    return oldNamecall(self, ...)
end)

-- Check for the main event to drop cash
local mainEvent = ReplicatedStorage:WaitForChild("MainEvent", 5)
if not mainEvent then
    warn("Oh no, no MainEvent! Cash drops might not work.")
end

-- Handy little helpers to keep things tidy
local function waitForHost(timeout)
    local success, result = pcall(function()
        return Players:WaitForChild(hostName, timeout)
    end)
    if success and result then
        return result
    end
    warn("Host " .. hostName .. " not found after " .. timeout .. " seconds. Hmm!")
    return nil
end

local function getPlayers()
    return Players:GetPlayers() -- Get all the players
end

local function disableAllSeats()
    for _, seat in ipairs(game.Workspace:GetDescendants()) do
        if seat:IsA("Seat") then
            seat.Disabled = true -- No one’s sitting down!
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
    blurEffect.Size = 48
    blurEffect.Parent = game.Lighting

    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0
    background.Parent = screenGui

    local mainText = Instance.new("TextLabel")
    mainText.Size = UDim2.new(0, 400, 0, 100)
    mainText.Position = UDim2.new(0.5, -200, 0.5, -50)
    mainText.BackgroundTransparency = 1
    mainText.Text = "dhc.lmao"
    mainText.TextSize = 48
    mainText.Font = Enum.Font.GothamBold
    mainText.TextColor3 = Color3.fromRGB(120, 60, 180) -- Start with purple
    mainText.Parent = background

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 60, 180)), -- Fade from purple
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))      -- To black
    }
    gradient.Parent = mainText
end

local function limitFPS()
    local targetDeltaTime = 1 / 5 -- Keep it easy at 5 FPS
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

-- Stop us from going AFK
local lastAFKJump = 0
local afkInterval = 58 -- Jump every so often
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
        warn("Too many alts! Cutting it to " .. maxAlts)
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
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and not part:IsA("Accessory") then
            part.CanCollide = not enable
            if enable then
                part.Velocity = Vector3.zero
            end
        end
    end
end

-- Switch between modes
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
    currentMode = nil
    currentTarget = nil
    toggleNoclip(character, false)
end

local function unswarm()
    if currentMode ~= "swarm" then
        warn("Not swarming right now!")
        return
    end
    disableCurrentMode()
    print("Unswarming, heading back to club setup.")
    setupClub() -- Back to the club
end

local function setupGrid(position)
    if not humanoidRootPart then
        warn("No character to set up, bummer!")
        return
    end
    toggleNoclip(character, true)
    local players = getPlayers()
    local alts = {}
    for _, p in ipairs(players) do
        if p ~= hostPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(alts, p.Character.HumanoidRootPart)
        end
    end
    -- Sort alts by name to ensure consistent grid placement
    table.sort(alts, function(a, b)
        return a.Parent.Name < b.Parent.Name
    end)
    -- Limit to 20 alts
    local maxAlts = 20
    if #alts > maxAlts then
        warn("Whoa, too many alts! Cutting to " .. maxAlts)
        alts = { table.unpack(alts, 1, maxAlts) }
    end
    -- Find the ground level for burying
    local rayOrigin = position
    local rayDirection = Vector3.new(0, -2000, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Include
    raycastParams.FilterDescendantsInstances = game.Workspace:GetChildren()
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    local groundY
    if raycastResult then
        groundY = raycastResult.Position.Y
        print("Ground found at Y=" .. groundY)
    else
        groundY = position.Y -- Fallback if ray misses
        warn("No ground hit, using fallback Y=" .. groundY)
    end
    local buryDepth = 5 -- Bury 5 studs down
    local targetY = groundY - buryDepth
    -- Set up a 4x5 grid
    local gridWidth = 4
    local gridHeight = 5
    local spacing = 2 -- 2 studs between each alt
    -- Calculate grid starting point (centered around the input position)
    local startX = position.X - (gridWidth - 1) * spacing / 2
    local startZ = position.Z - (gridHeight - 1) * spacing / 2
    -- Place each alt in the grid
    for i, altRoot in ipairs(alts) do
        local row = math.floor((i - 1) / gridWidth) -- 0-based row
        local col = (i - 1) % gridWidth -- 0-based column
        local targetPosition = Vector3.new(
            startX + col * spacing,
            targetY,
            startZ + row * spacing
        )
        local startCFrame = altRoot.CFrame
        local targetCFrame = CFrame.new(targetPosition) * startCFrame.Rotation
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(altRoot, tweenInfo, { CFrame = targetCFrame })
        tween:Play()
        tween.Completed:Wait()
        altRoot.Anchored = true -- Lock them in place
        print("Alt " .. altRoot.Parent.Name .. " placed at grid position (" .. col .. ", " .. row .. ") at " .. tostring(targetPosition))
    end
    toggleNoclip(character, false)
end

local function setup(targetPlayer)
    disableCurrentMode()
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") or not humanoidRootPart then
        warn("Setup failed, check the target!")
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
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, { CFrame = targetCFrame })
    tween:Play()
    currentMode = "setup"
    tween.Completed:Connect(function()
        if currentMode == "setup" then
            currentMode = nil
        end
        toggleNoclip(character, false)
    end)
end

local function setupClub()
    setupGrid(Vector3.new(-265, -7, -380)) -- Stuff them at club
end

local function setupBank()
    setupGrid(Vector3.new(-376, 21, -283)) -- Stuff them at bank
end

local function swarm(targetPlayer)
    disableCurrentMode()
    currentMode = "swarm"
    currentTarget = targetPlayer
    if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") or not humanoidRootPart then
        warn("Swarm failed, bad target!")
        currentMode = nil
        currentTarget = nil
        return
    end
    toggleNoclip(character, true)
    connections.swarm = RunService.RenderStepped:Connect(function()
        if currentMode ~= "swarm" or not humanoidRootPart or not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then
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
    currentMode = "follow"
    currentTarget = targetPlayer
    if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") or not humanoidRootPart then
        warn("Follow failed, bad target!")
        currentMode = nil
        currentTarget = nil
        return
    end
    toggleNoclip(character, true)
    connections.follow = RunService.RenderStepped:Connect(function()
        if currentMode ~= "follow" or not humanoidRootPart or not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then
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
        humanoidRootPart.CFrame = currentCFrame:Lerp(targetCFrame, 0.3) -- Smooth move
    end)
end

local function bring()
    disableCurrentMode()
    if not hostPlayer or not hostPlayer.Character or not hostPlayer.Character:FindFirstChild("HumanoidRootPart") or not humanoidRootPart then
        warn("Bring failed, check the host!")
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
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, { CFrame = targetCFrame })
    tween:Play()
    tween.Completed:Connect(function()
        toggleNoclip(character, false)
    end)
end

local function unburyAlt()
    if not humanoidRootPart then return end
    humanoidRootPart.Anchored = false
    toggleNoclip(character, true)
    if originalPosition then
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, { CFrame = originalPosition })
        tween:Play()
        tween.Completed:Wait()
        originalPosition = nil -- Clear it out
        toggleNoclip(character, false)
    else
        warn("No starting spot, heading to club!")
        setupClub() -- Fallback
    end
    print("Alt unburied and back.")
end

local function wallet()
    if not humanoid or not character then
        warn("Can’t pull out wallet, no character!")
        return
    end
    local backpack = player:WaitForChild("Backpack", 5)
    if not backpack then
        warn("No backpack found, weird!")
        return
    end
    local walletTool = backpack:FindFirstChild("[Wallet]")
    if walletTool then
        walletTool.Parent = character -- Equip the wallet
        print("Wallet pulled out!")
    else
        warn("No [Wallet] tool in backpack!")
    end
end

local function unwallet()
    if not humanoid or not character then
        warn("Can’t put away wallet, no character!")
        return
    end
    local walletTool = character:FindFirstChild("[Wallet]")
    if walletTool and walletTool:IsA("Tool") then
        walletTool.Parent = player:WaitForChild("Backpack", 5) -- Put it back
        print("Wallet put away!")
    else
        warn("No [Wallet] equipped to put away!")
    end
end

local function dropCash()
    if not mainEvent then
        warn("No MainEvent, can’t drop cash!")
        return
    end
    if isDropping then return end -- No double drops
    isDropping = true

    connections.drop = RunService.Heartbeat:Connect(function()
        if not isDropping or not humanoidRootPart then return end
        local currentTime = tick()
        if currentTime - lastDropTime >= dropCooldown then
            pcall(function()
                mainEvent:FireServer("DropMoney", 15000)
            end)
            lastDropTime = currentTime
        end
    end)
    print("Drop started, cash coming down!")
end

local function stopDrop()
    if not isDropping then return end
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
    if originalPosition then
        unburyAlt()
    end
    print("Drop stopped, all clear.")
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

-- Handle player events
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
    if currentMode and currentTarget then
        if currentMode == "swarm" then
            swarm(currentTarget)
        elseif currentMode == "follow" then
            follow(currentTarget)
        elseif currentMode == "setup" and currentTarget == nil then
            setupClub()
        end
    end
    if isDropping and originalPosition then
        setupClub() -- Re-bury if needed
    end
end

local function handleCommands(message)
    local lowerMsg = string.lower(message)
    if string.sub(lowerMsg, 1, 1) ~= "?" then return end
    local cmd = string.sub(lowerMsg, 2):match("^%s*(.-)%s*$")
    if cmd == "" then return end

    if cmd:match("^setup%s+(.+)$") then
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
                warn("Setup failed, no " .. targetName)
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
            warn("Swarm failed, no " .. targetName)
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
            warn("Follow failed, no " .. targetName)
        end
    elseif cmd == "unfollow" then
        disableCurrentMode()
        setup(hostPlayer)
    elseif cmd == "bring" then
        bring()
    elseif cmd == "drop" then
        dropCash()
    elseif cmd == "wallet" then
        wallet()
    elseif cmd == "unwallet" then
        unwallet()
    elseif cmd == "stop" then
        stopDrop()
    elseif cmd == "kick" then
        kickAlt()
    elseif cmd == "rejoin" then
        rejoinGame()
    else
        warn("What’s that? Unknown command: " .. cmd)
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
        if game.Lighting:FindFirstChild("BlurEffect") then
            game.Lighting.BlurEffect:Destroy()
        end
    end
end

local function updateStatus(status, altCount)
    -- No UI update since overlay is static
end

-- Let’s get this show on the road!
hostPlayer = waitForHost(10)
if not hostPlayer then
    warn("No host found, shutting down!")
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

print("dhc.lmao Alt Control Script (FIXED) loaded for " .. player.Name .. " in Da Hood!")
