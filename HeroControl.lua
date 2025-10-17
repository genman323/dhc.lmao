if game.PlaceId ~= 2788229376 then
    game:GetService('Players').LocalPlayer:Kick('wrong game retard')
    return
end
print("[] Checking Coordinates")
task.wait(1)
local function zXqW7kP()
    for _ = 1, 5 do
        if getgenv().Key and getgenv().HeroControl and getgenv().HeroControl.Host then
            return true
        end
        task.wait(0.1)
    end
    return false
end
print("[] Validating Key")
task.wait(1)
if not zXqW7kP() or getgenv().Key ~= 'Hero_XzQaPrAv_Admin' then
    game:GetService('Players').LocalPlayer:Kick('Invalid Key.')
    return
end
if not getgenv().HeroControl.Host or getgenv().HeroControl.Host == '' then
    game:GetService('Players').LocalPlayer:Kick('HeroControl.Host not defined or empty.')
    return
end
local p = game:GetService('Players')
local q = game:GetService('ReplicatedStorage')
local r = game:GetService('RunService')
local t = game:GetService('TweenService')
local u = game:GetService('TextChatService')
local v = game:GetService('VirtualInputManager')
local w = p.LocalPlayer
local x = w.Character or w.CharacterAdded:Wait()
local y = x and x:WaitForChild('HumanoidRootPart', 5)
local z = x and x:WaitForChild('Humanoid', 5)
local bb = nil
local cc = false
local dd = nil
local ee = 0.1
local ff = nil
local gg = '?'
local hh = {
    drop = nil,
    fps = nil,
    afk = nil,
    setup = nil,
    hostCheck = nil
}
local ii = q:WaitForChild('MainEvent', 5)
if not ii then
    w:Kick('MainEvent not found.')
    return
end
local lastXy = nil
local lastZa = 0
local positions = {
    Vector3.new(253074625.14, 9553424.79, 101833.26),
    Vector3.new(-1323325.08, 4062333.25, 1351371.94),
    Vector3.new(-1313284.82, 2158782.75, -1290322.85),
    Vector3.new(-21342551.82, 9115685.17, -1797866.71),
    Vector3.new(-1343989.01, 7443484.08, -21128427.32),
    Vector3.new(-2134669.14, 1342163.38, -41436313.78),
    Vector3.new(-1983435.73, 7567518.96, -1645461.98),
    Vector3.new(-645459.94, -21325455.09, -343434589.73),
    Vector3.new(-234434577.24, 190343449.41, 33443439.56),
    Vector3.new(-123434309.49, 171343434.56, -163434300.56),
    Vector3.new(-1343433400.62, 93434334369.83, -14343343411.39),
    Vector3.new(2213434346.08, 4334343760.71, -273434323.11),
    Vector3.new(97343482.99, 334334434.21, -7643434343440.42),
    Vector3.new(61734343434408.19, 1993433444359.44, 3534434434913.78),
    Vector3.new(1234343434793.66, 1943434343416.05, 5966334344347.36)
    Vector3.new(253074625.14, 9553434433424.79, 1014334833.26),
    Vector3.new(-1323325.08, 406233434333.25, 1351371.94),
    Vector3.new(-131434343284.82, 2158782.75, -1290322.85),
    Vector3.new(-21343434342551.82, 9115685.17, -1797866.71),
    Vector3.new(-134334343989.01, 7443434343484.08, -21128427.32),
    Vector3.new(-2134669.14, 133434442163.38, -4433431436313.78),
    Vector3.new(-1983435.73, 7567518.96, -164546134.98),
    Vector3.new(-6452323459.94, -212332325455.09, -3434433434589.73),
    Vector3.new(-23442334577.24, 190343223449.41, 334433439.56),
    Vector3.new(-12342334309.49, 171343223434.56, -163435454300.56),
    Vector3.new(-13432332433400.62, 934345454334369.83, -143437676343411.39),
    Vector3.new(2213232343234346.08, 4334342323233760.71, -273432322334323.11),
    Vector3.new(9734332382.99, 334323232334434.21, -764332322343440.42),
    Vector3.new(617332323434408.19, 1993432322334359.44, 35344233234913.78),
    Vector3.new(1234342323793.66, 1943434232316.05, 5962323634347.36)
}

local function ab(pq)
    if string.lower(w.Name) == string.lower(getgenv().HeroControl.Host) then
        w:Kick('Cannot execute on host.')
        return nil
    end
    local rs, tu = pcall(function()
        return p:WaitForChild(getgenv().HeroControl.Host, pq)
    end)
    if rs and tu then
        return tu
    end
    w:Kick('Host not found.')
    return nil
end
local function xY4zT6rE()
    for _, de in ipairs(game.Workspace:GetDescendants()) do
        if de:IsA('Seat') then
            de.Disabled = true
        end
    end
end
local function stopRendering()
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        if obj:IsA('BasePart') or obj:IsA('Decal') or obj:IsA('Texture') then
            obj.Transparency = 1
        elseif obj:IsA('Model') or obj:IsA('Folder') then
            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA('BasePart') or child:IsA('Decal') or child:IsA('Texture') then
                    child.Transparency = 1
                end
            end
        end
    end
    game.Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA('BasePart') or obj:IsA('Decal') or obj:IsA('Texture') then
            obj.Transparency = 1
        end
    end)
end
local function cd()
    local xy = Instance.new('ScreenGui')
    xy.Parent = game.CoreGui
    xy.Name = 'ReXaFqQ'
    xy.ResetOnSpawn = false
    xy.IgnoreGuiInset = true
    xy.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    xy.DisplayOrder = 1000
    game.Lighting.GlobalShadows = false
    game.Lighting.FogEnd = 1000000
    game.Lighting.FogStart = 1000000
    local yz = Instance.new('Frame')
    yz.Size = UDim2.new(1, 0, 1, 0)
    yz.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    yz.BackgroundTransparency = 1
    yz.Parent = xy
    yz.ZIndex = 1000
    local fadeInTween = t:Create(
        yz,
        TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
        { BackgroundTransparency = 0 }
    )
    fadeInTween:Play()
end
local function pQ9wE2rT()
    local fg = 1 / 5
    local hi = tick()
    hh.fps = r.RenderStepped:Connect(function()
        local jk = tick()
        local kl = jk - hi
        if kl < fg then
            wait(fg - kl)
        end
        hi = tick()
    end)
end
local function mB5vX8nL()
    local lastCameraRotation = tick()
    local afkInterval = 300 -- 5 minutes in seconds
    hh.afk = r.Heartbeat:Connect(function()
        local currentTime = tick()
        if currentTime - lastCameraRotation >= afkInterval then
            if z then
                z.PlatformStand = false
            end
            -- Rotate camera slightly
            local camera = game.Workspace.CurrentCamera
            if camera then
                local currentCFrame = camera.CFrame
                camera.CFrame = currentCFrame * CFrame.Angles(0, math.rad(5), 0) -- Rotate 5 degrees
            end
            if z then
                z.PlatformStand = true
            end
            lastCameraRotation = currentTime
        end
    end)
end
local function fG7hJ2kP(mn, op)
    if not mn then
        return
    end
    for _, qr in ipairs(mn:GetDescendants()) do
        if qr:IsA('BasePart') and not qr:IsA('Accessory') then
            qr.CanCollide = not op
            if op then
                qr.Velocity = Vector3.zero
                qr.Anchored = false
            end
        end
    end
end
local function rT4yU9iO()
    if y then
        y.Anchored = false
        y.Velocity = Vector3.zero
    end
    if z then
        z.PlatformStand = false
    end
    local rs = x and x:FindFirstChild('Animate')
    if rs then
        rs.Enabled = true
    end
    for tu, vw in pairs(hh) do
        if tu ~= 'fps' and tu ~= 'afk' and tu ~= 'drop' and vw then
            vw:Disconnect()
            hh[tu] = nil
        end
    end
    dd = nil
end
local function mN3qWvX7(xy, za)
    if not y or not x or not z then
        return
    end
    if not xy or not xy.Y then
        return
    end
    if za == nil then
        za = 0
    end
    if not ff then
        ff = y.CFrame
    end
    fG7hJ2kP(x, true)
    local bc = x and x:FindFirstChild('Animate')
    if bc then
        bc.Enabled = false
    end
    local de = xy.Y - za
    local fg = Vector3.new(xy.X, de, xy.Z)
    local hi = CFrame.new(fg) * CFrame.Angles(0, math.pi, 0)
    y.CFrame = hi
    y.Velocity = Vector3.zero
    if z then
        z.PlatformStand = true
    end
    dd = 'setup'
    lastXy = xy
    lastZa = za
    hh.setup = r.Heartbeat:Connect(function()
        if dd == 'setup' and y then
            y.CFrame = hi
            y.Velocity = Vector3.zero
            y.AssemblyLinearVelocity = Vector3.zero
            y.AssemblyAngularVelocity = Vector3.zero
        end
    end)
end
local function flyToPosition(xy, za)
    if not y or not x or not z then
        return
    end
    if not xy or not xy.Y then
        return
    end
    if za == nil then
        za = 0
    end
    if not ff then
        ff = y.CFrame
    end
    fG7hJ2kP(x, true)
    local bc = x and x:FindFirstChild('Animate')
    if bc then
        bc.Enabled = false
    end
    local de = xy.Y - za
    local fg = Vector3.new(xy.X, de, xy.Z)
    local hi = CFrame.new(fg) * CFrame.Angles(0, math.pi, 0)
    y.CFrame = hi
    y.Velocity = Vector3.zero
    if z then
        z.PlatformStand = true
    end
    y.Velocity = Vector3.zero
    y.AssemblyLinearVelocity = Vector3.zero
    y.AssemblyAngularVelocity = Vector3.zero
end
local function moveToPositions()
    if dd == 'flying' or dd == 'setup' then
        return
    end
    dd = 'flying'
    task.spawn(function()
        while dd == 'flying' do
            for _, pos in ipairs(positions) do
                if dd ~= 'flying' then
                    break
                end
                flyToPosition(pos, 0)
                task.wait(0.1)
            end
        end
        dd = nil
    end)
end
local function cL6mP8wQ()
    rT4yU9iO()
    mN3qWvX7(Vector3.new(-265, -7, -380), 5)
end
local function vB2nX5rY()
    rT4yU9iO()
    mN3qWvX7(Vector3.new(-375, 16, -286), 5)
end
local function qW9tE3mR()
    rT4yU9iO()
    mN3qWvX7(Vector3.new(-263, 53 - 2.8, -1129), 2.8)
end
local function jK7pL4xZ()
    rT4yU9iO()
    mN3qWvX7(Vector3.new(-932, 21 - 5 + 0.3 + 0.6, -483), 5)
end
local function hN8qW2vT()
    rT4yU9iO()
    mN3qWvX7(Vector3.new(-749, 22 - 5 + 1.2, -485), 5)
end
local function fM3rT9yU()
    rT4yU9iO()
    mN3qWvX7(Vector3.new(-295, 21 - 3, -111), 5)
end
local function pX6wQ4nL()
    rT4yU9iO()
    mN3qWvX7(Vector3.new(-295, 22 - 3, -68), 5)
end
local function tR2vB8mK()
    rT4yU9iO()
    mN3qWvX7(Vector3.new(-654, 21 - 3, 256), 5)
end
local function yU5qP9wE()
    rT4yU9iO()
    mN3qWvX7(Vector3.new(636, 47 - 5, -80), 5)
end
local function dS7kL3pQ()
    if not ii then
        return
    end
    if cc then
        return
    end
    cc = true
    local tu = 0
    local vw = ee
    hh.drop = r.Heartbeat:Connect(function()
        if not cc or not y then
            return
        end
        local xy = tick()
        if xy - tu >= vw then
            pcall(function()
                ii:FireServer('DropMoney', 15000)
            end)
            tu = xy
        end
    end)
end
local function gH4nX8qW()
    cc = false
    if hh.drop then
        hh.drop:Disconnect()
        hh.drop = nil
    end
    if ii then
        pcall(function()
            ii:FireServer('Block', false)
        end)
    end
end
local function iL9mT2rY(za)
    if za == bb then
        w:Kick('Kicked by your host.')
    end
end
local function eW6qP4vB(bc)
    x = bc
    y = bc and bc:WaitForChild('HumanoidRootPart', 5)
    z = bc and bc:WaitForChild('Humanoid', 5)
    if not y or not z then
        return
    end
    if dd == 'setup' and lastXy then
        mN3qWvX7(lastXy, lastZa or 0)
    elseif cc and ff and lastXy then
        mN3qWvX7(lastXy, lastZa or 0)
    else
        moveToPositions()
    end
end
local function oK3tR7yU(de)
    if not de or type(de) ~= 'string' or de == '' then
        return
    end
    local fg = string.lower(de)
    if string.sub(fg, 1, #gg) ~= gg then
        return
    end
    local hi = string.sub(fg, #gg + 1):match('^%s*(.-)%s*$') or ''
    if hi == '' then
        return
    end
    if hi:match('^setup%s+(.+)$') then
        local setup_loc = hi:match('^setup%s+(.+)$')
        if setup_loc == 'club' then
            cL6mP8wQ()
        elseif setup_loc == 'bank' then
            vB2nX5rY()
        elseif setup_loc == 'boxingclub' then
            qW9tE3mR()
        elseif setup_loc == 'basketball' then
            jK7pL4xZ()
        elseif setup_loc == 'soccer' then
            hN8qW2vT()
        elseif setup_loc == 'cell' then
            fM3rT9yU()
        elseif setup_loc == 'cell2' then
            pX6wQ4nL()
        elseif setup_loc == 'school' then
            tR2vB8mK()
        elseif setup_loc == 'train' then
            yU5qP9wE()
        end
    elseif hi == 'start' then
        dS7kL3pQ()
    elseif hi == 'stop' then
        gH4nX8qW()
    end
end

bb = ab(5)
if bb then
    hh.hostCheck = r.Heartbeat:Connect(function()
        local host = ab(1)
        if not host then
            w:Kick('Host not found.')
        end
    end)
    local chan = u and u.TextChannels and (u.TextChannels.RBXGeneral or u.TextChannels.RBXSystem)
    if not chan then
        w:Kick('TextChatService channel not found.')
        return
    end
    chan.MessageReceived:Connect(function(kl)
        if kl and kl.TextSource and kl.Text then
            local mn = p:GetPlayerByUserId(kl.TextSource.UserId)
            if mn == bb then
                pcall(function()
                    oK3tR7yU(kl.Text)
                end)
            end
        end
    end)
    bb.CharacterAdded:Connect(iL9mT2rY)
end
w.CharacterAdded:Connect(eW6qP4vB)

task.wait(0.1)
cd()
xY4zT6rE()
pQ9wE2rT()
mB5vX8nL()
task.wait(3)
print("[] Protecting Alt")
task.delay(2.5, function()
    stopRendering()
    moveToPositions()
end)
