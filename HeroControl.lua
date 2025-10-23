if game.PlaceId ~= 2788229376 then
  game:GetService('Players').LocalPlayer:Kick('wrong game retard')
  return
end

local script_key = 'qCqkyJnsIdGuValXkmeYLEcN'
local host = 'username'

local function check()
  return script_key == 'qCqkyJnsIdGuValXkmeYLEcN' and host and host ~= ''
end
if not check() then
  game:GetService('Players').LocalPlayer:Kick('Invalid Key.')
  return
end
if not host or host == '' then
  game:GetService('Players').LocalPlayer:Kick('Host not defined.')
  return
end

local p = game:GetService('Players')
local w = p.LocalPlayer
local isHost = string.lower(w.Name) == string.lower(host)
local r = game:GetService('RunService')
local u = game:GetService('TextChatService')
local x = w.Character or w.CharacterAdded:Wait()
local y = x and x:WaitForChild('HumanoidRootPart')
local z = x and x:WaitForChild('Humanoid')
local dd = nil
local gg = '.'
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

local function club() resetState() moveToPosition(Vector3.new(-264.9, -6.2, -374.9), 5) end
local function bank() resetState() moveToPosition(Vector3.new(-375, 16, -286), 5) end
local function boxingclub() resetState() moveToPosition(Vector3.new(-263, 53 - 2.8, -1129), 2.8) end
local function basketball() resetState() moveToPosition(Vector3.new(-932, 21 - 5 + 0.3 + 0.6, -483), 5) end
local function soccer() resetState() moveToPosition(Vector3.new(-749, 22 - 5 + 1.2, -485), 5) end
local function cell() resetState() moveToPosition(Vector3.new(-295, 21 - 3, -111), 5) end
local function cell2() resetState() moveToPosition(Vector3.new(-295, 22 - 3, -68), 5) end
local function school() resetState() moveToPosition(Vector3.new(-654, 21 - 3, 256), 5) end
local function train() resetState() moveToPosition(Vector3.new(636, 47 - 5, -80), 5) end
local function casino() resetState() moveToPosition(Vector3.new(-865.8, 22.0, -142.0), 4.8) end

local function start()
  if enabled then
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

  if cmd:match('^s%s+(.+)$') then
    local loc = cmd:match('^s%s+(.+)$')
    if loc == 'club' then club()
    elseif loc == 'bank' then bank()
    elseif loc == 'boxingclub' then boxingclub()
    elseif loc == 'basketball' then basketball()
    elseif loc == 'soccer' then soccer()
    elseif loc == 'cell' then cell()
    elseif loc == 'cell2' then cell2()
    elseif loc == 'school' then school()
    elseif loc == 'train' then train()
    elseif loc == 'casino' then casino()
    end
  elseif cmd == 'start' then
    enabled = true
    start()
  elseif cmd == 'stop' then
    enabled = false
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
      if sender and string.lower(sender.Name) == string.lower(host) then
        pcall(handleCommand, msg.Text)
      end
    end
  end)
end

w.CharacterAdded:Connect(onCharacterAdded)
method6()
