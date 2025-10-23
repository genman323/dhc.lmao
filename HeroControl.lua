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
  gui.Name = "SetupGUI"

  local frame = Instance.new("Frame", gui)
  frame.Size = UDim2.new(0, 160, 0, 340)
  frame.Position = UDim2.new(0, 10, 0.5, -170)
  frame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
  frame.BorderSizePixel = 0
  frame.Active = true
  frame.Draggable = true

  local corner = Instance.new("UICorner", frame)
  corner.CornerRadius = UDim.new(0, 8)

  local title = Instance.new("TextLabel", frame)
  title.Size = UDim2.new(1, 0, 0, 35)
  title.Position = UDim2.new(0, 0, 0, 0)
  title.Text = "📍 Setup Controller"
  title.TextColor3 = Color3.new(1, 1, 1)
  title.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
  title.Font = Enum.Font.GothamBold
  title.TextSize = 16
  title.TextXAlignment = Enum.TextXAlignment.Center

  local titleCorner = Instance.new("UICorner", title)
  titleCorner.CornerRadius = UDim.new(0, 8)

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
    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(1, -10, 0, 35)
    button.Position = UDim2.new(0, 5, 0, 40 + (i-1) * 38)
    button.Text = btnInfo.text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.Gotham
    button.TextSize = 14

    local btnCorner = Instance.new("UICorner", button)
    btnCorner.CornerRadius = UDim.new(0, 6)

    button.MouseButton1Click:Connect(function()
      if chan then
        chan:SendAsync(gg .. "setup " .. btnInfo.cmd)
        button.BackgroundColor3 = Color3.new(0, 0.7, 0)
        wait(0.2)
        button.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
      end
    end)

    button.MouseEnter:Connect(function()
      button.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    end)

    button.MouseLeave:Connect(function()
      button.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    end)
  end

  return -- Host doesn't need the rest
end

-- ALTS: Load original control script
local r = game:GetService('RunService')
local u = game:GetService('TextChatService')
local x = w.Character or w.CharacterAdded:Wait()
local y = x and x:WaitForChild('HumanoidRootPart')
local z = x and x:WaitForChild('Humanoid')
local dd = nil
local gg = '-'
local hh = { setup = nil }

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
  if y then
    y.Velocity = Vector3.zero
  end
  if z then
    z.PlatformStand = false
  end
  local anim = x:FindFirstChild('Animate')
  if anim then anim.Enabled = true end
  if hh.setup then
    hh.setup:Disconnect()
    hh.setup = nil
  end
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
  end
end

local function onCharacterAdded(char)
  x = char
  y = char:WaitForChild('HumanoidRootPart')
  z = char:WaitForChild('Humanoid')
  if y and z then
    method6()
  end
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
