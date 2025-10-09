local a = game:GetService('Players')
local b = game:GetService('ReplicatedStorage')
local c = game:GetService('RunService')
local d = game:GetService('TeleportService')
local e = game:GetService('TweenService')
local f = game:GetService('TextChatService')
local g = game:GetService('VirtualInputManager')
local h = a.LocalPlayer
local i = h.Character or h.CharacterAdded:Wait()
local j = i and i:WaitForChild('HumanoidRootPart', 5)
local k = i and i:WaitForChild('Humanoid', 5)
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
local z = {
    drop = nil,
    fps = nil,
    afk = nil,
    setupMove = nil,
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
    h:Kick('Host not found.')
    return nil
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
    mm.Parent = h:WaitForChild('PlayerGui', 5) or game.CoreGui
    mm.Name = 'DhcOverlay'
    mm.ResetOnSpawn = false
    mm.IgnoreGuiInset = true
    mm.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mm.DisplayOrder = 10
    local nn = Instance.new('BlurEffect')
    nn.Size = 48
    nn.Parent = game.Lighting
    local oo = Instance.new('Frame')
    oo.Size = UDim2.new(1, 0, 1, 0)
    oo.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    oo.BackgroundTransparency = 0
    oo.Parent = mm
    oo.ZIndex = 10

    -- Add themed text label
    local textLabel = Instance.new('TextLabel')
    textLabel.Size = UDim2.new(0, 200, 0, 50)
    textLabel.Position = UDim2.new(0.5, -100, 0.5, -25)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = 'DHC.LMAO'
    textLabel.TextColor3 = Color3.fromRGB(120, 60, 180)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 24
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Parent = oo

    local dotCount = 30
    for i = 1, dotCount do
        local dot = Instance.new('Frame')
        dot.Size = UDim2.new(0, 2, 0, 2)
        dot.BackgroundColor3 = Color3.fromRGB(120, 60, 180)
        dot.BorderSizePixel = 0
        dot.Parent = oo
        dot.Position = UDim2.new(math.random(), 0, math.random(), 0)
        local tweenInfo = TweenInfo.new(
            math.random(15, 60) / 10,
            Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut,
            -1,
            true
        )
        local goal = {
            Position = UDim2.new(math.random(), 0, math.random(), 0),
        }
        local tween = e:Create(dot, tweenInfo, goal)
        tween:Play()
    end
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
    local qqq = i and i:FindFirstChild('Animate')
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
    if i then
        lll(i, false)
    end
end

local function yyy(zzz, aaaa)
    if not j then
        return
    end
    if not t then
        t = j.CFrame
    end
    lll(i, true)
    local bbbb = i and i:FindFirstChild('Animate')
    if bbbb then
        bbbb.Enabled = false
    end
    local cccc = zzz.Y - aaaa
    local dddd = Vector3.new(zzz.X, cccc, zzz.Z)
    local eeee = CFrame.new(dddd) * CFrame.Angles(0, math.pi, 0)
    local ffff =
        TweenInfo.new(0, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local gggg = e:Create(j, ffff, { CFrame = eeee })
    gggg:Play()
    gggg.Completed:Connect(function()
        if k then
            k.PlatformStand = true
        end
        o = 'setup'
        z.setup = c.Heartbeat:Connect(function()
            if o == 'setup' and j then
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
    yyy(Vector3.new(-265, -7, -380), 5)
end

local function iiii()
    ppp()
    yyy(Vector3.new(-375, 21 - 5, -286), 5)
end

local function jjjj()
    ppp()
    yyy(Vector3.new(-263, 53 - 2.8, -1129), 2.8)
end

local function kkkkk()
    ppp()
    yyy(Vector3.new(-932, 21 - 5 + 0.3 + 0.6, -483), 5) -- Increased by 0.6 studs
end

local function lllll()
    ppp()
    yyy(Vector3.new(-749, 22 - 5 + 1.2, -485), 5)
end

local function mmmmm()
    ppp()
    yyy(Vector3.new(-295, 21 - 3, -111), 5)
end

local function nnnnn()
    ppp()
    yyy(Vector3.new(-295, 22 - 3, -68), 5)
end

local function ooooo()
    ppp()
    yyy(Vector3.new(-654, 21 - 3, 256), 5)
end

local function ppppp()
    ppp()
    yyy(Vector3.new(636, 47 - 5, -80), 5)
end

local function kkkk()
    ppp()
    if
        not m
        or not m.Character
        or not m.Character:FindFirstChild('HumanoidRootPart')
    then
        return
    end
    local mmmm = m.Character.HumanoidRootPart
    local targetPosition = mmmm.CFrame
    lll(i, true)
    local nnnn = i and i:FindFirstChild('Animate')
    if nnnn then
        nnnn.Enabled = false
    end
    local ffff =
        TweenInfo.new(0, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local gggg = e:Create(j, ffff, { CFrame = targetPosition })
    gggg:Play()
    gggg.Completed:Connect(function()
        if i then
            lll(i, false)
        end
        if nnnn then
            nnnn.Enabled = true
        end
        if k then
            k.PlatformStand = false
        end
    end)
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
    local aaaaaa = s
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

local function jjjjjj(kkkkk)
    if kkkkk == m then
        h:Kick('Kicked by your host.')
    end
end

local function nnnnnn(ooooo)
    i = ooooo
    j = ooooo and ooooo:WaitForChild('HumanoidRootPart', 5)
    k = ooooo and ooooo:WaitForChild('Humanoid', 5)
    if o == 'setup' then
        hhhh()
    end
    if n and t then
        hhhh()
    end
end

local function pppppp(qqqqq)
    if not qqqqq or type(qqqqq) ~= 'string' or qqqqq == '' then
        return
    end
    local rrrrr = string.lower(qqqqq)
    if string.sub(rrrrr, 1, #x) ~= x then
        return
    end
    local sssss = string.sub(rrrrr, #x + 1):match('^%s*(.-)%s*$') or ''
    if sssss == '' then
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
        elseif vvvvv == 'basketball' then
            kkkkk()
        elseif vvvvv == 'soccer' then
            lllll()
        elseif vvvvv == 'cell' then
            mmmmm()
        elseif vvvvv == 'cell2' then
            nnnnn()
        elseif vvvvv == 'school' then
            ooooo()
        elseif vvvvv == 'train' then
            ppppp()
        end
    elseif sssss == 'bring' then
        kkkk()
    elseif sssss == 'drop' then
        yyyyyy()
    elseif sssss == 'stop' then
        cccccc()
    end
end

m = gg(5)
if m then
    local channel = f
        and f.TextChannels
        and (f.TextChannels.RBXGeneral or f.TextChannels.RBXSystem)
    if channel then
        channel.MessageReceived:Connect(function(ffffff)
            if ffffff and ffffff.TextSource and ffffff.Text then
                local gggggg = a:GetPlayerByUserId(ffffff.TextSource.UserId)
                if gggggg == m then
                    pcall(function()
                        pppppp(ffffff.Text)
                    end)
                else
                    pcall(function()
                        pppppp(ffffff.Text) -- Allow local commands
                    end)
                end
            end
        end)
    end
    m.CharacterAdded:Connect(jjjjjj)
end
h.CharacterAdded:Connect(nnnnnn)
ll()
jj()
rr()
yy()
