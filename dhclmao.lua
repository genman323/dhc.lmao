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
local isBlocking = false -- Flag for blocking
local airlockCFrame = nil -- Saved CFrame for airlock
local connections = { -- Hold onto our connections
    drop = nil,
    swarm = nil,
    follow = nil,
    fps = nil,
    afk = nil,
    setupMove = nil,
    halo = nil,
    circle = nil,
    airlock = nil,
    spin = nil,
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
local function getPlayerByName(playerName)
    return Players:FindFirstChild(playerName)
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
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)) -- To black
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
local function getAltIndex(playerName, players, exclude)
    local alts = {}
    for _, p in ipairs(players) do
        if p ~= exclude then
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
                part.Anchored = false
            end
        end
    end
end
-- Switch between modes
local function disableCurrentMode()
    if humanoidRootPart then
        humanoidRootPart.Anchored = false
        humanoidRootPart.Velocity = Vector3.zero
    end
    if humanoid then
        humanoid.PlatformStand = false
    end
    local animateScript = character:FindFirstChild("Animate")
    if animateScript then
        animateScript.Enabled = true
    end
    for key, conn in pairs(connections) do
        if key ~= "fps" and key ~= "afk" and key ~= "drop" and conn then
            conn:Disconnect()
            connections[key] = nil
        end
    end
    currentMode = nil
    currentTarget = nil
    airlockCFrame = nil
    toggleNoclip(character, false)
end
local function unswarm()
    if currentMode ~= "swarm" then
        warn("Not swarming right now!")
        return
    end
    disableCurrentMode()
    print("Unswarming complete.")
end
local function unhalo()
    if currentMode ~= "halo" then
        warn("Not in halo mode right now!")
        return
    end
    disableCurrentMode()
    print("Unhalo complete.")
end
local function uncircle()
    if currentMode ~= "circle" then
        warn("Not in circle mode right now!")
        return
    end
    disableCurrentMode()
    print("Uncircle complete.")
end
local function unspin()
    if currentMode ~= "spin" then
        warn("Not spinning right now!")
        return
    end
    disableCurrentMode()
    print("Unspin complete.")
end
local function unairlock()
    if currentMode ~= "airlock" then
        warn("Not in airlock mode right now!")
        return
    end
    disableCurrentMode()
    print("Unairlock complete.")
end
local function setupGrid(position, depth)
    if not humanoidRootPart then
        warn("No character to set up, bummer!")
        return
    end
    -- Save original position if not already saved
    if not originalPosition then
        originalPosition = humanoidRootPart.CFrame
    end
    -- Only control this alt, not all alts
    toggleNoclip(character, true)
    local animateScript = character:FindFirstChild("Animate")
    if animateScript then
        animateScript.Enabled = false
    end
    -- Use fixed depth without raycast to avoid positioning issues
    local targetY = position.Y - depth
    local players = Players:GetPlayers()
    local index = getAltIndex(player.Name, players, hostPlayer)
    local gridSize = math.ceil(math.sqrt(#players - 1)) -- Approximate square grid
    local row = math.floor(index / gridSize)
    local col = index % gridSize
    local spacing = 0.5 -- Slight offset to make them distinguishable without overlapping too much
    local offsetX = col * spacing - (gridSize * spacing / 2)
    local offsetZ = row * spacing - (gridSize * spacing / 2)
    local targetPosition = Vector3.new(position.X + offsetX, targetY, position.Z + offsetZ)
    local targetCFrame = CFrame.new(targetPosition)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, { CFrame = targetCFrame })
    tween:Play()
    tween.Completed:Connect(function()
        humanoidRootPart.Anchored = true -- Freeze this alt in place (server-visible)
        currentMode = "setup"
        print("Alt " .. player.Name .. " stuffed underground at " .. tostring(targetPosition))
    end)
end
local function bring()
    if currentMode == "setup" then
        humanoidRootPart.Anchored = false
        local animateScript = character:FindFirstChild("Animate")
        if animateScript then
            animateScript.Enabled = true
        end
        currentMode = nil
        print("Alt " .. player.Name .. " unburied from setup.")
    end
    disableCurrentMode()
    if humanoidRootPart then
        humanoidRootPart.Anchored = false
    end
    if not hostPlayer or not hostPlayer.Character or not hostPlayer.Character:FindFirstChild("HumanoidRootPart") then
        warn("Bring failed, check the host!")
        return
    end
    toggleNoclip(character, true)
    local hostRoot = hostPlayer.Character.HumanoidRootPart
    local players = Players:GetPlayers()
    local index = getAltIndex(player.Name, players, hostPlayer)
    local numAlts = #players - 1
    local angle = index * (2 * math.pi / numAlts)
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
        print("Alt " .. player.Name .. " brought to host at " .. tostring(targetPosition))
    end)
end
local function setupClub()
    setupGrid(Vector3.new(-265, -7, -380), 8) -- Increased depth for full burial
end
local function setupBank()
    setupGrid(Vector3.new(-376, 21, -283), 10) -- Increased depth for full burial
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
    humanoid.PlatformStand = true -- Prevent humanoid from moving/falling
    local animateScript = character:FindFirstChild("Animate")
    if animateScript then
        animateScript.Enabled = false -- Disable animations to avoid glitches
    end
    connections.swarm = RunService.Heartbeat:Connect(function()
        if currentMode ~= "swarm" or not humanoidRootPart or not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then
            humanoid.PlatformStand = false
            if animateScript then
                animateScript.Enabled = true
            end
            toggleNoclip(character, false)
            return
        end
        local center = currentTarget.Character.HumanoidRootPart.Position
        local hash = 0
        for i = 1, #player.Name do
            hash = hash + string.byte(player.Name, i)
        end
        local angle = (hash % 360) / 180 * math.pi + os.clock() * 2 -- Unique spin per alt
        local radius = 10
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        local targetPosition = center + Vector3.new(x, 0, z)
        humanoidRootPart.CFrame = CFrame.lookAt(targetPosition, center) -- Direct set for smooth movement
        humanoidRootPart.Velocity = Vector3.zero -- Kill any velocity to prevent falling/glitching
        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero -- Extra anti-physics
        humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
    end)
    print("Swarm mode activated for " .. player.Name .. " around " .. currentTarget.Name)
end
local function halo(targetPlayer)
    disableCurrentMode()
    currentMode = "halo"
    currentTarget = targetPlayer
    if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") or not humanoidRootPart then
        warn("Halo failed, bad target!")
        currentMode = nil
        currentTarget = nil
        return
    end
    toggleNoclip(character, true)
    humanoid.PlatformStand = true -- Prevent humanoid from moving/falling
    local animateScript = character:FindFirstChild("Animate")
    if animateScript then
        animateScript.Enabled = false -- Disable animations to avoid glitches
    end
    connections.halo = RunService.Heartbeat:Connect(function()
        if currentMode ~= "halo" or not humanoidRootPart or not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then
            humanoid.PlatformStand = false
            if animateScript then
                animateScript.Enabled = true
            end
            toggleNoclip(character, false)
            return
        end
        local center = currentTarget.Character.HumanoidRootPart.Position + Vector3.new(0, 6, 0) -- Above the head
        local hash = 0
        for i = 1, #player.Name do
            hash = hash + string.byte(player.Name, i)
        end
        local angle = (hash % 360) / 180 * math.pi + os.clock() * 2 -- Unique spin per alt
        local radius = 2 -- Small radius for halo
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        local targetPosition = center + Vector3.new(x, 0, z)
        humanoidRootPart.CFrame = CFrame.lookAt(targetPosition, center) -- Direct set for smooth movement
        humanoidRootPart.Velocity = Vector3.zero -- Kill any velocity to prevent falling/glitching
        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero -- Extra anti-physics
        humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
    end)
    print("Halo mode activated for " .. player.Name .. " around " .. currentTarget.Name)
end
local function circle(targetPlayer)
    disableCurrentMode()
    currentMode = "circle"
    currentTarget = targetPlayer
    if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") or not humanoidRootPart then
        warn("Circle failed, bad target!")
        currentMode = nil
        currentTarget = nil
        return
    end
    toggleNoclip(character, true)
    -- Position once, statically, no freezing
    local center = currentTarget.Character.HumanoidRootPart.Position
    local players = Players:GetPlayers()
    local index = getAltIndex(player.Name, players, currentTarget)
    local numAlts = math.min(#players - 1, 20) -- Support up to 20 alts
    local angle = index * (2 * math.pi / numAlts)
    local radius = 10 -- Same as swarm radius
    local x = math.cos(angle) * radius
    local z = math.sin(angle) * radius
    local targetPosition = center + Vector3.new(x, 0, z)
    local targetCFrame = CFrame.lookAt(targetPosition, center)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, { CFrame = targetCFrame })
    tween:Play()
    tween.Completed:Connect(function()
        toggleNoclip(character, false)
        print("Alt " .. player.Name .. " positioned in circle around " .. currentTarget.Name)
    end)
end
local function spin()
    disableCurrentMode()
    currentMode = "spin"
    if not humanoidRootPart then
        warn("Spin failed, no HumanoidRootPart!")
        currentMode = nil
        return
    end
    toggleNoclip(character, true)
    humanoid.PlatformStand = true -- Prevent humanoid from moving/falling
    local animateScript = character:FindFirstChild("Animate")
    if animateScript then
        animateScript.Enabled = false -- Disable animations to avoid glitches
    end
    local startCFrame = humanoidRootPart.CFrame
    connections.spin = RunService.Heartbeat:Connect(function()
        if currentMode ~= "spin" or not humanoidRootPart then
            humanoid.PlatformStand = false
            if animateScript then
                animateScript.Enabled = true
            end
            toggleNoclip(character, false)
            return
        end
        local rotation = CFrame.Angles(0, os.clock() * 4, 0) -- Spin around Y axis
        humanoidRootPart.CFrame = startCFrame * rotation
        humanoidRootPart.Velocity = Vector3.zero
        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
    end)
    print("Spin mode activated for " .. player.Name)
end
local function airlock()
    disableCurrentMode()
    currentMode = "airlock"
    if not humanoidRootPart then
        warn("Airlock failed, no HumanoidRootPart!")
        currentMode = nil
        return
    end
    toggleNoclip(character, true)
    humanoid.PlatformStand = true -- Prevent humanoid from moving/falling
    local animateScript = character:FindFirstChild("Animate")
    if animateScript then
        animateScript.Enabled = false -- Disable animations to avoid glitches
    end
    -- Lift 13 studs up from current position, and use loop for better replication
    local currentCFrame = humanoidRootPart.CFrame
    local targetPosition = currentCFrame.Position + Vector3.new(0, 13, 0)
    airlockCFrame = CFrame.new(targetPosition, targetPosition + currentCFrame.LookVector) -- Preserve facing
    connections.airlock = RunService.Heartbeat:Connect(function()
        if currentMode ~= "airlock" or not humanoidRootPart then
            humanoid.PlatformStand = false
            if animateScript then
                animateScript.Enabled = true
            end
            toggleNoclip(character, false)
            return
        end
        humanoidRootPart.CFrame = airlockCFrame
        humanoidRootPart.Velocity = Vector3.zero
        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
    end)
    print("Airlock mode activated for " .. player.Name .. " at current position +13 studs")
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
    humanoid.PlatformStand = true -- Prevent humanoid from moving/falling
    local animateScript = character:FindFirstChild("Animate")
    if animateScript then
        animateScript.Enabled = false -- Disable animations to avoid glitches
    end
    connections.follow = RunService.Heartbeat:Connect(function()
        if currentMode ~= "follow" or not humanoidRootPart or not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then
            humanoid.PlatformStand = false
            if animateScript then
                animateScript.Enabled = true
            end
            toggleNoclip(character, false)
            return
        end
        local targetRoot = currentTarget.Character.HumanoidRootPart
        local targetPos = targetRoot.Position
        local players = Players:GetPlayers()
        local index = getAltIndex(player.Name, players, currentTarget)
        local offsetDistance = 1 + (index * 1)
        local behindOffset = -targetRoot.CFrame.LookVector * offsetDistance
        local targetPosition = targetPos + behindOffset
        humanoidRootPart.CFrame = CFrame.lookAt(targetPosition, targetPos) -- Direct set for smooth movement
        humanoidRootPart.Velocity = Vector3.zero -- Kill any velocity to prevent falling/glitching
        humanoidRootPart.AssemblyLinearVelocity = Vector3.zero -- Extra anti-physics
        humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
    end)
    print("Follow mode activated for " .. player.Name .. " behind " .. currentTarget.Name)
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
local function sendMessage(message)
    local textChatService = game:GetService("TextChatService")
    if textChatService and textChatService.TextChannels and textChatService.TextChannels.RBXGeneral then
        pcall(function()
            textChatService.TextChannels.RBXGeneral:SendAsync(message)
        end)
        print("Sent message: " .. message)
    else
        warn("TextChatService or RBXGeneral channel not found!")
    end
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
        elseif currentMode == "halo" then
            halo(hostPlayer)
        elseif currentMode == "circle" then
            circle(hostPlayer)
        elseif currentMode == "spin" then
            spin()
        end
    end
    if currentMode == "airlock" then
        airlock()
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
        elseif currentMode == "halo" then
            halo(currentTarget)
        elseif currentMode == "circle" then
            circle(currentTarget)
        elseif currentMode == "spin" then
            spin()
        elseif currentMode == "setup" then
            setupClub()
        end
    end
    if currentMode == "airlock" then
        airlock()
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
            warn("Setup failed, only 'club' or 'bank' allowed")
        end
    elseif cmd == "swarm host" then
        swarm(hostPlayer)
    elseif cmd:match("^swarm%s+(.+)$") then
        local targetName = cmd:match("^swarm%s+(.+)$")
        local target = getPlayerByName(targetName)
        if target then
            swarm(target)
        else
            warn("Swarm failed, no player named " .. targetName)
        end
    elseif cmd == "unswarm" then
        unswarm()
    elseif cmd == "halo host" then
        halo(hostPlayer)
    elseif cmd:match("^halo%s+(.+)$") then
        local targetName = cmd:match("^halo%s+(.+)$")
        local target = getPlayerByName(targetName)
        if target then
            halo(target)
        else
            warn("Halo failed, no player named " .. targetName)
        end
    elseif cmd == "unhalo" then
        unhalo()
    elseif cmd == "circle host" then
        circle(hostPlayer)
    elseif cmd:match("^circle%s+(.+)$") then
        local targetName = cmd:match("^circle%s+(.+)$")
        local target = getPlayerByName(targetName)
        if target then
            circle(target)
        else
            warn("Circle failed, no player named " .. targetName)
        end
    elseif cmd == "uncircle" then
        uncircle()
    elseif cmd == "spin" then
        spin()
    elseif cmd == "unspin" then
        unspin()
    elseif cmd == "airlock" then
        airlock()
    elseif cmd == "unairlock" then
        unairlock()
    elseif cmd == "follow host" then
        follow(hostPlayer)
    elseif cmd:match("^follow%s+(.+)$") then
        local targetName = cmd:match("^follow%s+(.+)$")
        local target = getPlayerByName(targetName)
        if target then
            follow(target)
        else
            warn("Follow failed, no player named " .. targetName)
        end
    elseif cmd == "unfollow" then
        disableCurrentMode()
        print("Unfollow complete.")
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
    elseif cmd == "block" then
        isBlocking = true
        if mainEvent then
            pcall(function()
                mainEvent:FireServer("Block", true)
            end)
        end
        print("Blocking enabled for alt " .. player.Name)
    elseif cmd == "unblock" then
        isBlocking = false
        if mainEvent then
            pcall(function()
                mainEvent:FireServer("Block", false)
            end)
        end
        print("Blocking disabled for alt " .. player.Name)
    elseif cmd:match("^msg%s+(.+)$") then
        local messageText = cmd:match("^msg%s+(.+)$")
        sendMessage(messageText)
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
