if game.PlaceId ~= 2788229376 then
    game:GetService('Players').LocalPlayer:Kick('wrong game retard')
    return
end
print("[] Loading Hero Control..")
task.wait(1)
print("[] Checking Coordinates")
task.wait(1)
local function shadowzeckxd()
    for _ = 1, 5 do
        if getgenv().Hero_Key and getgenv().HeroControl and getgenv().HeroControl.Host then
            return true
        end
        task.wait(0.1)
    end
    return false
end
print("[] Validating Key")
task.wait(1)
if not shadowzeckxd() or getgenv().Hero_Key ~= 'Hero_XzQaPrAv_Admin' then
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
local function bc()
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
local function de()
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
local function ef()
    hh.afk = r.Heartbeat:Connect(function()
        local lm = tick()
        if lm - ww >= xx then
            if dd == 'setup' then
                dd = nil
            end
            if z then
                z.PlatformStand = false
            end
            v:SendKeyEvent(true, Enum.KeyCode.W, false, game)
            task.wait(0.2)
            v:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            if z then
                z.PlatformStand = true
            end
            if dd == nil then
                dd = 'setup'
            end
            ww = lm
        end
    end)
end
local ww = tick()
local xx = 600
local function fg(mn, op)
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
local function gh()
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
local function hi(xy, za)
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
    fg(x, true)
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
local function ij()
    gh()
    hi(Vector3.new(-265, -7, -380), 5)
end
local function jk()
    gh()
    hi(Vector3.new(-375, 16, -286), 5)
end
local function kl()
    gh()
    hi(Vector3.new(-263, 53 - 2.8, -1129), 2.8)
end
local function lm()
    gh()
    hi(Vector3.new(-932, 21 - 5 + 0.3 + 0.6, -483), 5)
end
local function mn()
    gh()
    hi(Vector3.new(-749, 22 - 5 + 1.2, -485), 5)
end
local function no()
    gh()
    hi(Vector3.new(-295, 21 - 3, -111), 5)
end
local function op()
    gh()
    hi(Vector3.new(-295, 22 - 3, -68), 5)
end
local function pq()
    gh()
    hi(Vector3.new(-654, 21 - 3, 256), 5)
end
local function qr()
    gh()
    hi(Vector3.new(636, 47 - 5, -80), 5)
end
local function rs()
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
local function st()
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
local function tu(za)
    if za == bb then
        w:Kick('Kicked by your host.')
    end
end
local function uv(bc)
    x = bc
    y = bc and bc:WaitForChild('HumanoidRootPart', 5)
    z = bc and bc:WaitForChild('Humanoid', 5)
    if not y or not z then
        return
    end
    if dd == 'setup' and lastXy then
        hi(lastXy, lastZa or 0)
    elseif cc and ff and lastXy then
        hi(lastXy, lastZa or 0)
    else
        hi(Vector3.new(0, 1000000, 0), 0)
    end
end
local function vw(de)
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
            ij()
        elseif setup_loc == 'bank' then
            jk()
        elseif setup_loc == 'boxingclub' then
            kl()
        elseif setup_loc == 'basketball' then
            lm()
        elseif setup_loc == 'soccer' then
            mn()
        elseif setup_loc == 'cell' then
            no()
        elseif setup_loc == 'cell2' then
            op()
        elseif setup_loc == 'school' then
            pq()
        elseif setup_loc == 'train' then
            qr()
        end
    elseif hi == 'start' then
        rs()
    elseif hi == 'stop' then
        st()
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
                    vw(kl.Text)
                end)
            end
        end
    end)
    bb.CharacterAdded:Connect(tu)
end
w.CharacterAdded:Connect(uv)
task.wait(0.1)
cd()
bc()
de()
ef()
task.wait(1)
print("[] Protecting Alt")
task.delay(2.5, function()
    stopRendering()
    hi(Vector3.new(0, 1000000, 0), 0)
end)
task.wait(1)
print("[] Made By hardst_yle With <3")
