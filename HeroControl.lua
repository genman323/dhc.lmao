if game.PlaceId ~= 2788229376 then
  game:GetService('Players').LocalPlayer:Kick('wrong game retard')
  return
end

local function checkKey()
  return getgenv().Key == 'Hero_XzQaPrAv_Admin' and getgenv().HeroControl and getgenv().HeroControl.Host
end
if not checkKey() then
  game:GetService('Players').LocalPlayer:Kick('Invalid Key.')
  return
end
if not getgenv().HeroControl.Host or getgenv().HeroControl.Host == '' then
  game:GetService('Players').LocalPlayer:Kick('Host not defined.')
  return
end

local p = game:GetService('Players')
local w = p.LocalPlayer
local isHost = string.lower(w.Name) == string.lower(getgenv().HeroControl.Host)

-- HOST: Only load GUI
if isHost then
  local u = game:GetService('TextChatService')
  local gg = '-'
  local chan = u and u.TextChannels and (u.TextChannels.RBXGeneral or u.TextChannels.RBXSystem)
  
  local gui = Instance.new("ScreenGui")
  gui.Parent = w.PlayerGui
  gui.Name = "HeroControl"
  gui.ResetOnSpawn = false

  local mainFrame = Instance.new("Frame", gui)
  mainFrame.Size = UDim2.new(0, 220, 0, 420)
  mainFrame.Position = UDim2.new(0, 15, 0.5, -210)
  mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
  mainFrame.BorderSizePixel = 0

  local mainCorner = Instance.new("UICorner", mainFrame)
  mainCorner.CornerRadius = UDim.new(0, 16)

  local mainStroke = Instance.new("UIStroke", mainFrame)
  mainStroke.Color = Color3.fromRGB(45, 45, 55)
  mainStroke.Thickness = 2

  -- Gradient background
  local gradient = Instance.new("UIGradient", mainFrame)
  gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
  }
  gradient.Rotation = 45

  -- Header
  local header = Instance.new("Frame", mainFrame)
  header.Size = UDim2.new(1, 0, 0, 60)
  header.Position = UDim2.new(0, 0, 0, 0)
  header.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
  header.BorderSizePixel = 0

  local headerCorner = Instance.new("UICorner", header)
  headerCorner.CornerRadius = UDim.new(0, 16)

  local headerGradient = Instance.new("UIGradient", header)
  headerGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 162, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 140, 220))
  }
  headerGradient.Rotation = 90

  local title = Instance.new("TextLabel", header)
  title.Size = UDim2.new(1, -20, 1, 0)
  title.Position = UDim2.new(0, 10, 0, 0)
  title.Text = "🚀 HERO CONTROL"
  title.TextColor3 = Color3.fromRGB(255, 255, 255)
  title.BackgroundTransparency = 1
  title.Font = Enum.Font.GothamBold
  title.TextSize = 18
  title.TextXAlignment = Enum.TextXAlignment.Left

  -- Scroll Frame
  local scrollFrame = Instance.new("ScrollingFrame", mainFrame)
  scrollFrame.Size = UDim2.new(1, -20, 1, -80)
  scrollFrame.Position = UDim2.new(0, 10, 0, 70)
  scrollFrame.BackgroundTransparency = 1
  scrollFrame.BorderSizePixel = 0
  scrollFrame.ScrollBarThickness = 6
  scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
  scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 380)

  local uiList = Instance.new("UIListLayout", scrollFrame)
  uiList.Padding = UDim.new(0, 8)
  uiList.SortOrder = Enum.SortOrder.LayoutOrder

  -- Drop Button
  local dropBtn = Instance.new("TextButton", scrollFrame)
  dropBtn.Size = UDim2.new(1, -20, 0, 50)
  dropBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
  dropBtn.Text = "💰 DROP $15K"
  dropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
  dropBtn.Font = Enum.Font.GothamBold
  dropBtn.TextSize = 15
  dropBtn.BorderSizePixel = 0
  dropBtn.LayoutOrder = 1

  local dropCorner = Instance.new("UICorner", dropBtn)
  dropCorner.CornerRadius = UDim.new(0, 12)

  local dropStroke = Instance.new("UIStroke", dropBtn)
  dropStroke.Color = Color3.fromRGB(70, 70, 90)
  dropStroke.Thickness = 2

  -- Setup Buttons
  local buttons = {
    {text = "🎰 Casino", cmd = "co"},
    {text = "🏫 School", cmd = "sl"},
    {text = "🔒 Cell", cmd = "cl"},
    {text = "🔒 Cell 2", cmd = "c2"},
    {text = "🏦 Bank", cmd = "b"},
    {text = "🎪 Club", cmd = "c"},
    {text = "🥊 Boxing Club", cmd = "bc"},
    {text = "🏀 Basketball", cmd = "bb"},
    {text = "⚽ Soccer", cmd = "s"},
    {text = "🚂 Train", cmd = "t"}
  }

  for i, btnInfo in ipairs(buttons) do
    local button = Instance.new("TextButton", scrollFrame)
    button.Size = UDim2.new(1, -20, 0, 48)
    button.Text = btnInfo.text
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.LayoutOrder = i + 1

    local btnCorner = Instance.new("UICorner", button)
    btnCorner.CornerRadius = UDim.new(0, 10)

    local btnStroke = Instance.new("UIStroke", button)
    btnStroke.Color = Color3.fromRGB(65, 65, 80)
    btnStroke.Thickness = 1.5

    button.MouseButton1Click:Connect(function()
      if chan then
        chan:SendAsync(gg .. "setup " .. btnInfo.cmd)
        button.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
        wait(0.15)
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
      end
    end)

    button.MouseEnter:Connect(function()
      button.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
      btnStroke.Color = Color3.fromRGB(0, 162, 255)
    end)

    button.MouseLeave:Connect(function()
      button.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
      btnStroke.Color = Color3.fromRGB(65, 65, 80)
    end)
  end

  -- Drop button events
  dropBtn.MouseButton1Click:Connect(function()
    if chan then
      chan:SendAsync(gg .. "d")
      dropBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
      wait(0.15)
      dropBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    end
  end)

  dropBtn.MouseEnter:Connect(function()
    dropBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    dropStroke.Color = Color3.fromRGB(0, 200, 0)
  end)

  dropBtn.MouseLeave:Connect(function()
    dropBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    dropStroke.Color = Color3.fromRGB(70, 70, 90)
  end)

  return
end

-- ALTS: Load control script
local r = game:GetService('RunService')
local u = game:GetService('TextChatService')
local x = w.Character or w.CharacterAdded:Wait()
local y = x and x:WaitForChild('HumanoidRootPart')
local z = x and x:WaitForChild('Humanoid')
local dd = nil
local gg = '-'
local hh = { setup = nil }
local dropping = false
local dropConnection = nil

local function method6()
  local virtualUser = game:GetService('VirtualUser')
  w.Idled:Connect(function()
    virtualUser:CaptureController()
    virtualUser:ClickButton2(Vector2.new())
  end)
  local camera = game.Workspace.CurrentCamera
  camera.CameraType = Enum.CameraType.Scriptable
  camera.CFrame = CFrame.new(0, -5000000, 0)
end

local function resetState()
  if y then y.Velocity = Vector3.zero end
  if z then z.PlatformStand = false end
  local anim = x:FindFirstChild('Animate')
  if anim then anim.Enabled = true end
  if hh.setup then hh.setup:Disconnect() hh.setup = nil end
  dd = nil
end

local function moveToPosition(pos, offset)
  if not y or not x or not z then return end
  if not pos or not pos.Y then return end
  offset = offset or 0
  local targetY = pos.Y - offset
  local targetPos = Vector3.new(pos.X, targetY, pos.Z)
  local targetCFrame = CFrame.new(targetPos) * CFrame.Angles(0, math.pi, 0)

  for _, part in ipairs(x:GetDescendants()) do
    if part:IsA('BasePart') and not part:IsA('Accessory') then
      part.CanCollide = false
    end
  end
  local anim = x:FindFirstChild('Animate')
  if anim then anim.Enabled = false end

  y.CFrame = targetCFrame
  y.Velocity = Vector3.zero
  z.PlatformStand = true
  dd = 'setup'

  hh.setup = r.Heartbeat:Connect(function()
    if dd == 'setup' and y then
      y.CFrame = targetCFrame
      y.Velocity = Vector3.zero
      y.AssemblyLinearVelocity = Vector3.zero
      y.AssemblyAngularVelocity = Vector3.zero
      z.PlatformStand = true
    end
  end)
end

-- Setup functions
local function club() resetState() moveToPosition(Vector3.new(-264.9, -6.2, -374.9), 5) end
local function bank() resetState() moveToPosition(Vector3.new(-375, 16, -286), 5) end
local function boxingclub() resetState() moveToPosition(Vector3.new(-263, 53 - 2.8, -1129), 2.8) end
local function basketball() resetState() moveToPosition(Vector3.new(-932, 21 - 5 + 0.3 + 0.6, -483), 5) end
local function soccer() resetState() moveToPosition(Vector3.new(-749, 22 - 5 + 1.2, -485), 5) end
local function cell() resetState() moveToPosition(Vector3.new(-295, 21 - 3, -111), 5) end
local function cell2() resetState() moveToPosition(Vector3.new(-295, 22 - 3, -68), 5) end
local function school() resetState() moveToPosition(Vector3.new(-654, 21 - 3, 256), 5) end
local function train() resetState() moveToPosition(Vector3.new(636, 47 - 5, -80), 5) end
local function casino() resetState() moveToPosition(Vector3.new(-865.8, 22.0, -142.0), 4.5) end

local function dropMoney()
  if dropping then
    local args = {
      [1] = "DropMoney",
      [2] = 15000
    }
    game:GetService("ReplicatedStorage").MainEvent:FireServer(unpack(args))
    dropConnection = r.Heartbeat:Connect(function()
      if dropping then
        game:GetService("ReplicatedStorage").MainEvent:FireServer(unpack(args))
      else
        dropConnection:Disconnect()
      end
    end)
  end
end

local function handleCommand(msg)
  if not msg or type(msg) ~= 'string' then return end
  local text = string.lower(msg)
  if string.sub(text, 1, #gg) ~= gg then return end
  local cmd = string.sub(text, #gg + 1):match('^%s*(.-)%s*$')
  if not cmd or cmd == '' then return end

  if cmd:match('^setup%s+(.+)$') then
    local loc = cmd:match('^setup%s+(.+)$')
    if loc == 'c' then club()
    elseif loc == 'b' then bank()
    elseif loc == 'bc' then boxingclub()
    elseif loc == 'bb' then basketball()
    elseif loc == 's' then soccer()
    elseif loc == 'cl' then cell()
    elseif loc == 'c2' then cell2()
    elseif loc == 'sl' then school()
    elseif loc == 't' then train()
    elseif loc == 'co' then casino()
    end
  elseif cmd == 'd' then
    dropping = true
    dropMoney()
  elseif cmd == 'stp' then
    dropping = false
  end
end

local function onCharacterAdded(char)
  x = char
  y = char:WaitForChild('HumanoidRootPart')
  z = char:WaitForChild('Humanoid')
  if y and z then method6() end
end

local chan = u and u.TextChannels and (u.TextChannels.RBXGeneral or u.TextChannels.RBXSystem)
if chan then
  chan.MessageReceived:Connect(function(msg)
    if msg.TextSource and p:GetPlayerByUserId(msg.TextSource.UserId) then
      local sender = p:GetPlayerByUserId(msg.TextSource.UserId)
      if sender and string.lower(sender.Name) == string.lower(getgenv().HeroControl.Host) then
        pcall(handleCommand, msg.Text)
      end
    end
  end)
end

w.CharacterAdded:Connect(onCharacterAdded)
method6()
