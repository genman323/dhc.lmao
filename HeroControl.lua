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
local r = game:GetService('RunService')
local u = game:GetService('TextChatService')
local w = p.LocalPlayer
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

-- GUI setup only for host
local isHost = string.lower(w.Name) == string.lower(getgenv().HeroControl.Host)
if isHost then
  local gui = Instance.new("ScreenGui")
  gui.Parent = w.PlayerGui
  gui.Name = "SetupGUI"

  local frame = Instance.new("Frame", gui)
  frame.Size = UDim2.new(0, 150, 0, 300)
  frame.Position = UDim2.new(0, 10, 0.5, -150)
  frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
  frame.BorderSizePixel = 0

  local title = Instance.new("TextLabel", frame)
  title.Size = UDim2.new(1, 0, 0, 30)
  title.Position = UDim2.new(0, 0, 0, 0)
  title.Text = "Setups"
  title.TextColor3 = Color3.new(1, 1, 1)
  title.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
  title.Font = Enum.Font.SourceSansBold
  title.TextSize = 18

  local buttons = {
    {text = "Casino", cmd = "co", pos = 30},
    {text = "School", cmd = "sl", pos = 60},
    {text = "Cell", cmd = "cl", pos = 90},
    {text = "Cell 2", cmd = "c2", pos = 120},
    {text = "Bank", cmd = "b", pos = 150},
    {text = "Club", cmd = "c", pos = 180},
    {text = "Boxing Club", cmd = "bc", pos = 210},
    {text = "Basketball", cmd = "bb", pos = 240},
    {text = "Soccer", cmd = "s", pos = 270},
    {text = "Train", cmd = "t", pos = 300}
  }

  for i, btnInfo in ipairs(buttons) do
    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Position = UDim2.new(0, 0, 0, btnInfo.pos)
    button.Text = btnInfo.text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.SourceSans
    button.TextSize = 14

    button.MouseButton1Click:Connect(function()
      if chan then
        chan:SendAsync(gg .. "setup " .. btnInfo.cmd)
      end
    end)
  end
end
