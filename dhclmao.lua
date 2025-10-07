local a = game:GetService('Players')
local b = game:GetService('ReplicatedStorage')
local c = game:GetService('RunService')
local d = game:GetService('TeleportService')
local e = game:GetService('TweenService')
local f = game:GetService('TextChatService')
local g = game:GetService('VirtualInputManager')

local h = a.LocalPlayer
local i = h.Character or h.CharacterAdded:Wait()
local j = i:WaitForChild('HumanoidRootPart', 5)
local k = i:WaitForChild('Humanoid', 5)

local l = 'HarperViperZero20033'
local m = nil
local n = false
local o = nil
local p = nil
local q = nil
local r = 0
local s = 0.1
local t = nil
local u = false
local v = nil
local w = false
local x = '?'
local y = false

local z = {
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
    setup = nil,
}

local ff = b:WaitForChild('MainEvent', 5)

local function gg(tt)
    local uu, vv = pcall(function()
        return a:WaitForChild(l, tt)
    end)
    if uu and vv then
        return vv
    end
    pcall(function()
        h:Kick('Host not found.')
    end)
    return nil
end

local function hh(ii)
    return a:FindFirstChild(ii)
end

local function jj()
    for _, kk in ipairs(game.Workspace:GetDescendants()) do
        if kk:IsA('Seat') then
            kk.Disabled = true
        end
    end
end

local function ll()
    local mm = Instance.new('ScreenGui')
    mm.Parent = h:WaitForChild('PlayerGui', 5)
    mm.Name = 'DhcOverlay'
    mm.ResetOnSpawn = false
    mm.IgnoreGuiInset = true
    local nn = Instance.new('BlurEffect')
    nn.Size = 48
    nn.Parent = game.Lighting
    local oo = Instance.new('Frame')
    oo.Size = UDim2.new(1, 0, 1, 0)
    oo.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    oo.BackgroundTransparency = 0
    oo.Parent = mm
    local pp = Instance.new('TextLabel')
    pp.Size = UDim2.new(0, 400, 0, 100)
    pp.Position = UDim2.new(0.5, -200, 0.5, -50)
    pp.BackgroundTransparency = 1
    pp.Text = 'dhc.lmao'
    pp.TextSize = 48
    pp.Font = Enum.Font.GothamBold
    pp.TextColor3 = Color3.fromRGB(120, 60, 180)
    pp.Parent = oo
    local qq = Instance.new('UIGradient')
    qq.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 60, 180)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
    })
    qq.Parent = pp
end

local function rr()
    local ss = 1 / 5
    local tt = tick()
    z.fps = c.RenderStepped:Connect(function()
        local uu = tick()
        local vv = uu - tt
        if vv < ss then
            task.wait(ss - vv)
        end
        tt = tick()
    end)
end

local ww = 0
local xx = 58
local function yy()
    z.afk = c.Heartbeat:Connect(function()
        local zz = tick()
        if zz - ww >= xx then
            g:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.1)
            g:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            ww = zz
        end
    end)
end

local function aaa(bbb, ccc, ddd)
    local eee = {}
    for _, fff in ipairs(ccc) do
        if fff ~= ddd then
            table.insert(eee, fff)
        end
    end
    table.sort(eee, function(ggg, hhh)
        return ggg.Name < hhh.Name
    end)
    local iii = 20
    if #eee > iii then
        eee = { table.unpack(eee, 1, iii) }
    end
    for jjj, kkk in ipairs(eee) do
        if kkk.Name == bbb then
            return jjj - 1
        end
    end
    return 0
end

local function lll(mmm, nnn)
    if not mmm then
        return
    end
    for _, ooo in ipairs(mmm:GetDescendants()) do
        if ooo:IsA('BasePart') and not ooo:IsA('Accessory') then
            ooo.CanCollide = not nnn
            if nnn then
                ooo.Velocity = Vector3.zero
                ooo.Anchored = false
            end
        end
    end
end

local function ppp()
    if j then
        j.Anchored = false
        j.Velocity = Vector3.zero
    end
    if k then
        k.PlatformStand = false
    end
    local qqq = i:FindFirstChild('Animate')
    if qqq then
        qqq.Enabled = true
    end
    for rrr, sss in pairs(z) do
        if rrr ~= 'fps' and rrr ~= 'afk' and rrr ~= 'drop' and sss then
            sss:Disconnect()
            z[rrr] = nil
        end
    end
    o = nil
    p = nil
    v = nil
    lll(i, false)
end

local function ttt()
    if o ~= 'swarm' then
        return
    end
    ppp()
end

local function uuu()
    if o ~= 'halo' then
        return
    end
    ppp()
end

local function vvv()
    if o ~= 'circle' then
        return
    end
    ppp()
end

local function www()
    if o ~= 'spin' then
        return
    end
    ppp()
end

local function xxx()
    if o ~= 'airlock' then
        return
    end
    ppp()
end

local function yyy(zzz, aaaa)
    if not j then
        return
    end
    if not t then
        t = j.CFrame
    end
    lll(i, true)
    local bbbb = i:FindFirstChild('Animate')
    if bbbb then
        bbbb.Enabled = false
    end
    local cccc = zzz.Y - aaaa
    local dddd = Vector3.new(zzz.X, cccc, zzz.Z)
    local eeee = CFrame.new(dddd) * CFrame.Angles(0, math.pi, 0)
    local ffff =
        TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local gggg = e:Create(j, ffff, { CFrame = eeee })
    gggg:Play()
    gggg.Completed:Connect(function()
        k.PlatformStand = true
        o = 'setup'
        z.setup = c.Heartbeat:Connect(function()
            if o == 'setup' then
                j.CFrame = eeee
                j.Velocity = Vector3.zero
                j.AssemblyLinearVelocity = Vector3.zero
                j.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end)
end

local function hhhh()
    ppp()
    if f and f.TextChannels and f.TextChannels.RBXGeneral then
        pcall(function()
            f.TextChannels.RBXGeneral:SendAsync('Setting up..')
        end)
    end
    task.wait(1)
    yyy(Vector3.new(-265, -7, -380), 5)
end

local function iiii()
    ppp()
    if f and f.TextChannels and f.TextChannels.RBXGeneral then
        pcall(function()
            f.TextChannels.RBXGeneral:SendAsync('Setting up..')
        end)
    end
    task.wait(1)
    yyy(Vector3.new(-376, 21, -283), 5)
end

local function jjjj()
    ppp()
    if f and f.TextChannels and f.TextChannels.RBXGeneral then
        pcall(function()
            f.TextChannels.RBXGeneral:SendAsync('Setting up..')
        end)
    end
    task.wait(1)
    yyy(Vector3.new(-261.07, 53.37, -1127.65), 5)
end

local function kkkk()
    if o == 'setup' then
        k.PlatformStand = false
        if z.setup then
            z.setup:Disconnect()
            z.setup = nil
        end
        local llll = i:FindFirstChild('Animate')
        if llll then
            llll.Enabled = true
        end
        o = nil
    end
    ppp()
    if
        not j
        or not m
        or not m.Character
        or not m.Character:FindFirstChild('HumanoidRootPart')
    then
        return
    end
    local mmmm = m.Character.HumanoidRootPart
    lll(i, true)
    local nnnn = i:FindFirstChild('Animate')
    if nnnn then
        nnnn.Enabled = false
    end
    local oooo = a:GetPlayers()
    local pppp = aaa(h.Name, oooo, m)
    local qqqq = #oooo - 1
    local rrrr = pppp * (2 * math.pi / qqqq)
    local ssss = 2
    local tttt = math.cos(rrrr) * ssss
    local uuuu = math.sin(rrrr) * ssss
    local vvvv = mmmm.Position + Vector3.new(tttt, 0, uuuu)
    local wwww = CFrame.lookAt(vvvv, mmmm.Position)
    local xxxx =
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local yyyy = e:Create(j, xxxx, { CFrame = wwww })
    yyyy:Play()
    yyyy.Completed:Connect(function()
        lll(i, false)
        if nnnn then
            nnnn.Enabled = true
        end
        k.PlatformStand = false
    end)
    if not w then
        if f and f.TextChannels and f.TextChannels.RBXGeneral then
            pcall(function()
                f.TextChannels.RBXGeneral:SendAsync('Greetings, Master.')
            end)
        end
        w = true
    end
end

local function zzzz(aaaaa)
    ppp()
    o = 'swarm'
    p = aaaaa
    if
        not p
        or not p.Character
        or not p.Character:FindFirstChild('HumanoidRootPart')
        or not j
    then
        o = nil
        p = nil
        return
    end
    lll(i, true)
    k.PlatformStand = true
    local bbbbb = i:FindFirstChild('Animate')
    if bbbbb then
        bbbbb.Enabled = false
    end
    local ccccc = 0
    local ddddd = y and 0.1 or 0
    z.swarm = c.Heartbeat:Connect(function()
        if
            o ~= 'swarm'
            or not j
            or not p
            or not p.Character
            or not p.Character:FindFirstChild('HumanoidRootPart')
        then
            k.PlatformStand = false
            if bbbbb then
                bbbbb.Enabled = true
            end
            lll(i, false)
            return
        end
        local eeeee = tick()
        if eeeee - ccccc < ddddd then
            return
        end
        ccccc = eeeee
        local fffff = p.Character.HumanoidRootPart.Position
        local ggggg = 0
        for iiiii = 1, #h.Name do
            ggggg = ggggg + string.byte(h.Name, iiiii)
        end
        local hhhhh = (ggggg % 360) / 180 * math.pi + os.clock() * 2
        local iiiii = 10
        local jjjjj = math.cos(hhhhh) * iiiii
        local kkkkk = math.sin(hhhhh) * iiiii
        local lllll = fffff + Vector3.new(jjjjj, 0, kkkkk)
        j.CFrame = CFrame.lookAt(lllll, fffff)
        j.Velocity = Vector3.zero
        j.AssemblyLinearVelocity = Vector3.zero
        j.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function mmmmm(nnnnn)
    ppp()
    o = 'halo'
    p = nnnnn
    if
        not p
        or not p.Character
        or not p.Character:FindFirstChild('HumanoidRootPart')
        or not j
    then
        o = nil
        p = nil
        return
    end
    lll(i, true)
    k.PlatformStand = true
    local ooooo = i:FindFirstChild('Animate')
    if ooooo then
        ooooo.Enabled = false
    end
    local ppppp = 0
    local qqqqq = y and 0.1 or 0
    z.halo = c.Heartbeat:Connect(function()
        if
            o ~= 'halo'
            or not j
            or not p
            or not p.Character
            or not p.Character:FindFirstChild('HumanoidRootPart')
        then
            k.PlatformStand = false
            if ooooo then
                ooooo.Enabled = true
            end
            lll(i, false)
            return
        end
        local rrrrr = tick()
        if rrrrr - ppppp < qqqqq then
            return
        end
        ppppp = rrrrr
        local sssss = p.Character.HumanoidRootPart.Position
            + Vector3.new(0, 6, 0)
        local ttttt = 0
        for uuuuu = 1, #h.Name do
            ttttt = ttttt + string.byte(h.Name, uuuuu)
        end
        local vvvvv = (ttttt % 360) / 180 * math.pi + os.clock() * 2
        local wwwww = 2
        local xxxxx = math.cos(vvvvv) * wwwww
        local yyyyy = math.sin(vvvvv) * wwwww
        local zzzzz = sssss + Vector3.new(xxxxx, 0, yyyyy)
        j.CFrame = CFrame.lookAt(zzzzz, sssss)
        j.Velocity = Vector3.zero
        j.AssemblyLinearVelocity = Vector3.zero
        j.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function aaaaaa(bbbbbb)
    ppp()
    o = 'circle'
    p = bbbbbb
    if
        not p
        or not p.Character
        or not p.Character:FindFirstChild('HumanoidRootPart')
        or not j
    then
        o = nil
        p = nil
        return
    end
    lll(i, true)
    local cccccc = p.Character.HumanoidRootPart.Position
    local dddddd = a:GetPlayers()
    local eeeeee = aaa(h.Name, dddddd, p)
    local ffffff = math.min(#dddddd - 1, 20)
    local gggggg = eeeeee * (2 * math.pi / 20)
    local hhhhhh = 10
    local iiiiii = math.cos(gggggg) * hhhhhh
    local jjjjjj = math.sin(gggggg) * hhhhhh
    local kkkkkk = cccccc + Vector3.new(iiiii, 0, jjjjjj)
    local llllll = CFrame.lookAt(kkkkkk, cccccc)
    local mmmmmm =
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local nnnnnn = e:Create(j, mmmmmm, { CFrame = llllll })
    nnnnnn:Play()
    nnnnnn.Completed:Connect(function()
        lll(i, false)
    end)
end

local function oooooo()
    ppp()
    o = 'spin'
    if not j then
        o = nil
        return
    end
    lll(i, true)
    k.PlatformStand = true
    local pppppp = i:FindFirstChild('Animate')
    if pppppp then
        pppppp.Enabled = false
    end
    local qqqqqq = j.CFrame
    local rrrrrr = 0
    local ssssss = y and 0.1 or 0
    z.spin = c.Heartbeat:Connect(function()
        if o ~= 'spin' or not j then
            k.PlatformStand = false
            if pppppp then
                pppppp.Enabled = true
            end
            lll(i, false)
            return
        end
        local tttttt = tick()
        if tttttt - rrrrrr < ssssss then
            return
        end
        rrrrrr = tttttt
        local uuuuuu = CFrame.Angles(0, os.clock() * 4, 0)
        j.CFrame = qqqqqq * uuuuuu
        j.Velocity = Vector3.zero
        j.AssemblyLinearVelocity = Vector3.zero
        j.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function vvvvvv()
    ppp()
    o = 'airlock'
    if not j then
        o = nil
        return
    end
    lll(i, true)
    k.PlatformStand = true
    local wwwwww = i:FindFirstChild('Animate')
    if wwwwww then
        wwwwww.Enabled = false
    end
    local xxxxxx = j.CFrame
    local yyyyyy = xxxxxx.Position + Vector3.new(0, 13, 0)
    v = CFrame.new(yyyyyy, yyyyyy + xxxxxx.LookVector)
    local zzzzzz = 0
    local aaaaaa = y and 0.1 or 0
    z.airlock = c.Heartbeat:Connect(function()
        if o ~= 'airlock' or not j then
            k.PlatformStand = false
            if wwwwww then
                wwwwww.Enabled = true
            end
            lll(i, false)
            return
        end
        local bbbbbb = tick()
        if bbbbbb - zzzzzz < aaaaaa then
            return
        end
        zzzzzz = bbbbbb
        j.CFrame = v
        j.Velocity = Vector3.zero
        j.AssemblyLinearVelocity = Vector3.zero
        j.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function cccccc(dddddd)
    ppp()
    o = 'follow'
    p = dddddd
    if
        not p
        or not p.Character
        or not p.Character:FindFirstChild('HumanoidRootPart')
        or not j
    then
        o = nil
        p = nil
        return
    end
    lll(i, true)
    k.PlatformStand = true
    local eeeeee = i:FindFirstChild('Animate')
    if eeeeee then
        eeeeee.Enabled = false
    end
    local ffffff = 0
    local gggggg = y and 0.1 or 0
    z.follow = c.Heartbeat:Connect(function()
        if
            o ~= 'follow'
            or not j
            or not p
            or not p.Character
            or not p.Character:FindFirstChild('HumanoidRootPart')
        then
            k.PlatformStand = false
            if eeeeee then
                eeeeee.Enabled = true
            end
            lll(i, false)
            return
        end
        local hhhhhh = tick()
        if hhhhhh - ffffff < gggggg then
            return
        end
        ffffff = hhhhhh
        local iiiiii = p.Character.HumanoidRootPart
        local jjjjjj = iiiiii.Position
        local kkkkkk = a:GetPlayers()
        local llllll = aaa(h.Name, kkkkkk, p)
        local mmmmmm = 2 + (llllll * 1)
        local nnnnnn = -iiiiii.CFrame.LookVector * mmmmmm
        local oooooo = jjjjjj + nnnnnn
        j.CFrame = CFrame.lookAt(oooooo, jjjjjj)
        j.Velocity = Vector3.zero
        j.AssemblyLinearVelocity = Vector3.zero
        j.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function pppppp()
    if not k or not i then
        return
    end
    local qqqqqq = h:WaitForChild('Backpack', 5)
    if not qqqqqq then
        return
    end
    local rrrrrr = 3
    for ssssss = 1, rrrrrr do
        local tttttt = qqqqqq:FindFirstChild('[Wallet]')
        if tttttt then
            tttttt.Parent = i
            return
        else
            task.wait(0.1)
        end
    end
end

local function uuuuuu()
    if not k or not i then
        return
    end
    local vvvvvv = 3
    for wwwwww = 1, vvvvvv do
        local xxxxxx = i:FindFirstChild('[Wallet]')
        if xxxxxx and xxxxxx:IsA('Tool') then
            xxxxxx.Parent = h:WaitForChild('Backpack', 5)
            return
        else
            task.wait(0.1)
        end
    end
end

local function yyyyyy()
    if not ff then
        return
    end
    if n then
        return
    end
    n = true
    local zzzzzz = 0
    local aaaaaa = y and 0.2 or s
    z.drop = c.Heartbeat:Connect(function()
        if not n or not j then
            return
        end
        local bbbbbb = tick()
        if bbbbbb - zzzzzz >= aaaaaa then
            pcall(function()
                ff:FireServer('DropMoney', 15000)
            end)
            zzzzzz = bbbbbb
        end
    end)
end

local function cccccc()
    n = false
    if z.drop then
        z.drop:Disconnect()
        z.drop = nil
    end
    if ff then
        pcall(function()
            ff:FireServer('Block', false)
        end)
    end
end

local function dddddd()
    g:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    u = true
end

local function eeeeee()
    g:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    u = false
end

local function ffffff()
    pcall(function()
        h:Kick('Kicked by your host.')
    end)
end

local function gggggg()
    pcall(function()
        d:TeleportToPlaceInstance(game.PlaceId, game.JobId, h)
    end)
end

local function hhhhhh(iiiii)
    if f and f.TextChannels and f.TextChannels.RBXGeneral then
        pcall(function()
            f.TextChannels.RBXGeneral:SendAsync(iiiii)
        end)
    end
end

local function jjjjjj(kkkkk)
    if kkkkk == m then
        ffffff()
    end
end

local function llllll(mmmmm)
    if p == m then
        if o == 'swarm' then
            zzzz(m)
        elseif o == 'follow' then
            cccccc(m)
        elseif o == 'halo' then
            mmmmm(m)
        elseif o == 'circle' then
            aaaaaa(m)
        elseif o == 'spin' then
            oooooo()
        end
    end
    if o == 'airlock' then
        vvvvvv()
    end
end

local function nnnnnn(ooooo)
    i = ooooo
    j = ooooo:WaitForChild('HumanoidRootPart', 5)
    k = ooooo:WaitForChild('Humanoid', 5)
    if o and p then
        if o == 'swarm' then
            zzzz(p)
        elseif o == 'follow' then
            cccccc(p)
        elseif o == 'halo' then
            mmmmm(p)
        elseif o == 'circle' then
            aaaaaa(p)
        elseif o == 'spin' then
            oooooo()
        elseif o == 'setup' then
            hhhh()
        end
    end
    if o == 'airlock' then
        vvvvvv()
    end
    if n and t then
        hhhh()
    end
end

local function pppppp(qqqqq)
    local rrrrr = string.lower(qqqqq)
    if string.sub(rrrrr, 1, #x) ~= x then
        return
    end
    local sssss = string.sub(rrrrr, #x + 1):match('^%s*(.-)%s*$')
    if sssss == '' then
        return
    end
    if sssss:match('^prefix%s+(.+)$') then
        local ttttt = sssss:match('^prefix%s+(.+)$')
        x = ttttt
        hhhhhh('Prefix Changed.')
        return
    end
    if sssss == 'lowcpu' or sssss == 'lcm' then
        y = not y
        hhhhhh('Low CPU mode ' .. (y and 'on' or 'off') .. '.')
        if o and p then
            if o == 'swarm' then
                zzzz(p)
            elseif o == 'follow' then
                cccccc(p)
            elseif o == 'halo' then
                mmmmm(p)
            elseif o == 'spin' then
                oooooo()
            elseif o == 'airlock' then
                vvvvvv()
            end
        end
        if n then
            cccccc()
            task.wait(0.1)
            yyyyyy()
        end
        return
    end
    if sssss:match('^setup%s+(.+)$') then
        local vvvvv = sssss:match('^setup%s+(.+)$')
        if vvvvv == 'club' then
            hhhh()
        elseif vvvvv == 'bank' then
            iiii()
        elseif vvvvv == 'boxingclub' then
            jjjj()
        end
    elseif sssss == 'swarm host' then
        zzzz(m)
    elseif sssss:match('^swarm%s+(.+)$') then
        local wwwww = sssss:match('^swarm%s+(.+)$')
        local xxxxx = hh(wwwww)
        if xxxxx then
            zzzz(xxxxx)
        end
    elseif sssss == 'unswarm' then
        ttt()
    elseif sssss == 'halo host' then
        mmmmm(m)
    elseif sssss:match('^halo%s+(.+)$') then
        local yyyyy = sssss:match('^halo%s+(.+)$')
        local zzzzz = hh(yyyyy)
        if zzzzz then
            mmmmm(zzzzz)
        end
    elseif sssss == 'unhalo' then
        uuu()
    elseif sssss == 'circle host' then
        aaaaaa(m)
    elseif sssss:match('^circle%s+(.+)$') then
        local aaaaaa = sssss:match('^circle%s+(.+)$')
        local bbbbbb = hh(aaaaaa)
        if bbbbbb then
            aaaaaa(bbbbbb)
        end
    elseif sssss == 'uncircle' then
        vvv()
    elseif sssss == 'spin' then
        oooooo()
    elseif sssss == 'unspin' then
        www()
    elseif sssss == 'airlock' then
        vvvvvv()
    elseif sssss == 'unairlock' then
        xxx()
    elseif sssss == 'follow host' then
        cccccc(m)
    elseif sssss:match('^follow%s+(.+)$') then
        local cccccc = sssss:match('^follow%s+(.+)$')
        local dddddd = hh(cccccc)
        if dddddd then
            cccccc(dddddd)
        end
    elseif sssss == 'unfollow' then
        ppp()
    elseif sssss == 'bring' then
        kkkk()
    elseif sssss == 'drop' then
        yyyyyy()
    elseif sssss == 'stop' or sssss == 'undrop' then
        cccccc()
    elseif sssss == 'block' then
        dddddd()
    elseif sssss == 'unblock' then
        eeeeee()
    elseif sssss == 'kick' then
        ffffff()
    elseif sssss == 'rejoin' then
        gggggg()
    elseif sssss:match('^say%s+(.+)$') then
        local eeeeee = sssss:match('^say%s+(.+)$')
        hhhhhh(eeeee)
    elseif sssss == 'wallet' then
        pppppp()
    elseif sssss == 'unwallet' then
        uuuuuu()
    end
end

m = gg(5)

f.TextChannels.RBXGeneral.MessageReceived:Connect(function(ffffff)
    if ffffff.TextSource then
        local gggggg = a:GetPlayerByUserId(ffffff.TextSource.UserId)
        if gggggg == m then
            pppppp(ffffff.Text)
        end
    end
end)

a.PlayerRemoving:Connect(jjjjjj)
if m then
    m.CharacterAdded:Connect(llllll)
end
h.CharacterAdded:Connect(nnnnnn)

ll()
jj()
rr()
yy()
print('DHC.LMAO - [############]')
