local function safeWait(seconds)
    if task and task.wait then
        return task.wait(seconds)
    else
        return wait(seconds)
    end
end
if game.PlaceId ~= 2788229376 then
    game:GetService('Players').LocalPlayer:Kick('wrong game retard')
    return
end

local function shadowzeckxd()
    for _ = 1, 5 do
        if getgenv().Shadow_Key and getgenv().ShadowControl and getgenv().ShadowControl.Host then
            return true
        end
        safeWait(0.1)
    end
    return false
end
if not shadowzeckxd() or getgenv().Shadow_Key ~= 'Shadow_XzQaPrAv_Admin' then
    game:GetService('Players').LocalPlayer:Kick('Invalid or missing Shadow_Key.')
    return
end
if not getgenv().ShadowControl.Host or getgenv().ShadowControl.Host == '' then
    game:GetService('Players').LocalPlayer:Kick('ShadowControl.Host not defined or empty.')
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
}
local ii = q:WaitForChild('MainEvent', 5)
if not ii then
    w:Kick('MainEvent not found.')
    return
end
local function ab(pq)
    if string.lower(w.Name) == string.lower(getgenv().ShadowControl.Host) then
        w:Kick('Cannot execute on host.')
        return nil
    end
    local rs, tu = pcall(function()
        return p:WaitForChild(getgenv().ShadowControl.Host, pq)
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
    yz.BackgroundTransparency = 0
    yz.Parent = xy
    yz.ZIndex = 1000
    local dotCount = 90
    local dots = {}
    for i = 1, dotCount do
        local dot = Instance.new('Frame')
        dot.Size = UDim2.new(0, 1, 0, 1)
        dot.BackgroundColor3 = Color3.fromRGB(51, 0, 255)
        dot.BorderSizePixel = 0
        dot.Parent = yz
        dot.Position = UDim2.new(math.random(), 0, math.random(), 0)
        dot.ZIndex = 1001
        dots[i] = {
            frame = dot,
            target = Vector2.new(math.random(), math.random()),
            lastUpdate = tick(),
        }
    end
    r.RenderStepped:Connect(function(dt)
        for _, dot in ipairs(dots) do
            if tick() - dot.lastUpdate >= 5 then
                dot.target = Vector2.new(math.random(), math.random())
                dot.lastUpdate = tick()
            end
            local current = Vector2.new(
                dot.frame.Position.X.Scale,
                dot.frame.Position.Y.Scale
            )
            local newPos = current:Lerp(dot.target, 0.02)
            dot.frame.Position = UDim2.new(newPos.X, 0, newPos.Y, 0)
        end
    end)
    local R2tQaZ0v5 = {}
    R2tQaZ0v5['1'] = Instance.new('ScreenGui')
    R2tQaZ0v5['1'].Parent = game.CoreGui
    R2tQaZ0v5['1'].Name = 'notification'
    R2tQaZ0v5['1'].ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    R2tQaZ0v5['1'].DisplayOrder = 1001
    R2tQaZ0v5['2'] = Instance.new('Frame', R2tQaZ0v5['1'])
    R2tQaZ0v5['2'].BorderSizePixel = 0
    R2tQaZ0v5['2'].BackgroundColor3 = Color3.fromRGB(52, 0, 255)
    R2tQaZ0v5['2'].Size = UDim2.new(0, 254, 0, 85)
    R2tQaZ0v5['2'].Position = UDim2.new(0, -254, 0.9, -25)
    R2tQaZ0v5['2'].BorderColor3 = Color3.fromRGB(0, 0, 0)
    R2tQaZ0v5['2'].Name = 'tbg'
    R2tQaZ0v5['2'].BackgroundTransparency = 0.7
    R2tQaZ0v5['3'] = Instance.new('Frame', R2tQaZ0v5['2'])
    R2tQaZ0v5['3'].BorderSizePixel = 0
    R2tQaZ0v5['3'].BackgroundColor3 = Color3.fromRGB(52, 0, 255)
    R2tQaZ0v5['3'].Size = UDim2.new(0, 237, 0, 70)
    R2tQaZ0v5['3'].Position = UDim2.new(0.03002, 0, 0.0936, 0)
    R2tQaZ0v5['3'].BorderColor3 = Color3.fromRGB(0, 0, 0)
    R2tQaZ0v5['3'].Name = 'bg'
    R2tQaZ0v5['3'].BackgroundTransparency = 0.7
    R2tQaZ0v5['4'] = Instance.new('TextLabel', R2tQaZ0v5['3'])
    R2tQaZ0v5['4'].BorderSizePixel = 0
    R2tQaZ0v5['4'].TextSize = 22
    R2tQaZ0v5['4'].TextTransparency = 0.8
    R2tQaZ0v5['4'].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    R2tQaZ0v5['4'].FontFace = Font.new(
        'rbxasset://fonts/families/RobotoMono.json',
        Enum.FontWeight.Bold,
        Enum.FontStyle.Normal
    )
    R2tQaZ0v5['4'].TextColor3 = Color3.fromRGB(255, 255, 255)
    R2tQaZ0v5['4'].BackgroundTransparency = 1
    R2tQaZ0v5['4'].Size = UDim2.new(0, 237, 0, 70)
    R2tQaZ0v5['4'].BorderColor3 = Color3.fromRGB(0, 0, 0)
    R2tQaZ0v5['4'].Text = 'Shadow Control Loaded.'
    R2tQaZ0v5['4'].Name = 'lolz'
    R2tQaZ0v5['6'] = Instance.new('UICorner', R2tQaZ0v5['3'])
    local slideIn = t:Create(
        R2tQaZ0v5['2'],
        TweenInfo.new(0.5),
        { Position = UDim2.new(0, 0, 0.9, -25) }
    )
    slideIn:Play()
    slideIn.Completed:Connect(function()
        safeWait(2) -- Wait 2 seconds after overlay appears
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/genman323/dhc.lmao/refs/heads/main/Extra/Notification/hi.lua"))()
        end)
        local tweenInfo = TweenInfo.new(
            1,
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut,
            0,
            false
        )
        local function createTween(color)
            local tween = t:Create(R2tQaZ0v5['4'], tweenInfo, { TextColor3 = color })
            tween:Play()
            return tween
        end
        spawn(function()
            while R2tQaZ0v5['1'].Parent do
                local tweenToPurple = createTween(Color3.fromRGB(51, 0, 255))
                tweenToPurple.Completed:Wait()
                local tweenToWhite = createTween(Color3.fromRGB(255, 255, 255))
                tweenToWhite.Completed:Wait()
            end
        end)
        delay(2.3, function()
            if R2tQaZ0v5['1'].Parent then
                local slideOut = t:Create(
                    R2tQaZ0v5['2'],
                    TweenInfo.new(0.5),
                    { Position = UDim2.new(0, -254, 0.9, -25) }
                )
                slideOut:Play()
                slideOut.Completed:Connect(function()
                    R2tQaZ0v5['1']:Destroy()
                end)
            end
        end)
    end)
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
            v:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            wait(0.1)
            v:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            ww = lm
        end
    end)
end
local ww = 0
local xx = 58
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
    if not y then
        return
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
    local jk = TweenInfo.new(0, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local kl = t:Create(y, jk, { CFrame = hi })
    kl:Play()
    kl.Completed:Connect(function()
        if z then
            z.PlatformStand = true
        end
        dd = 'setup'
        hh.setup = r.Heartbeat:Connect(function()
            if dd == 'setup' and y then
                y.CFrame = hi
                y.Velocity = Vector3.zero
                y.AssemblyLinearVelocity = Vector3.zero
                y.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end)
end
local function ij()
    gh()
    hi(Vector3.new(-265, -7, -380), 5)
end
local function jk()
    gh()
    hi(Vector3.new(-375, 21 - 5, -286), 5)
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
    if dd == 'setup' then
        ij()
    end
    if cc and ff then
        ij()
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
        local jk = hi:match('^setup%s+(.+)$')
        if jk == 'club' then
            ij()
        elseif jk == 'bank' then
            jk()
        elseif jk == 'boxingclub' then
            kl()
        elseif jk == 'basketball' then
            lm()
        elseif jk == 'soccer' then
            mn()
        elseif jk == 'cell' then
            no()
        elseif jk == 'cell2' then
            op()
        elseif jk == 'school' then
            pq()
        elseif jk == 'train' then
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
safeWait(0.1)
cd()
bc()
de()
ef()
