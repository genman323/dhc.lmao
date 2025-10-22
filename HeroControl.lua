if game.PlaceId ~= 2788229376 then
  game:GetService('Players').LocalPlayer:Kick('wrong game')
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
local q = game:GetService('ReplicatedStorage')
local u = game:GetService('TextChatService')
local w = p.LocalPlayer
local x = w.Character or w.CharacterAdded:Wait()
local y = x and x:WaitForChild('HumanoidRootPart', 5)
local z = x and x:WaitForChild('Humanoid', 5)
local bb = nil
local dd = nil
local gg = '-'
local hh = {
  setup = nil,
  hostCheck = nil,
  follow = nil,
}
local ii = q:WaitForChild('MainEvent', 5)
if not ii then
  w:Kick('MainEvent not found.')
  return
end

local function findHost(pq)
  if string.lower(w.Name) == string.lower(getgenv().HeroControl.Host) then
    w:Kick('Cannot execute on host.')
    return nil
  end
  local rs, tu = pcall(function()
    return p:FindFirstChild(getgenv().HeroControl.Host, pq)
  end)
  if rs and tu then
    return tu
  end
  w:Kick('Host not found.')
  return nil
end
local function setCharacterPhysics(mn, op)
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
local function method6()
  local virtualUser = game:GetService('VirtualUser')
  w.Idled:Connect(function()
    virtualUser:CaptureController()
    virtualUser:ClickButton2(Vector2.new())
  end)
  local camera = game.Workspace.CurrentCamera
  camera.CameraType = Enum.CameraType.Scriptable
  camera.CFrame = CFrame.new(Vector3.new(0, -5000000, 0))
  for _, obj in ipairs(game.Workspace:GetDescendants()) do
    if obj:IsA('BasePart') or obj:IsA('Decal') or obj:IsA('Texture') then
      obj:Destroy()
    elseif obj:IsA('Model') or obj:IsA('Folder') then
      for _, child in ipairs(obj:GetDescendants()) do
        if child:IsA('BasePart') or child:IsA('Decal') or child:IsA('Texture') then
          child:Destroy()
        end
      end
    end
  end
  game.Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA('BasePart') or obj:IsA('Decal') or obj:IsA('Texture') then
      obj:Destroy()
    end
  end)
end
local function resetState()
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
    if vw then
      vw:Disconnect()
      hh[tu] = nil
    end
  end
  dd = nil
end
local function moveToPosition(xy, za)
  if not y or not x or not z then
    return
  end
  if not xy or not xy.Y then
    return
  end
  if za == nil then
    za = 0
  end
  setCharacterPhysics(x, true)
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
  hh.setup = r.Heartbeat:Connect(function()
    if dd == 'setup' and y then
      y.CFrame = hi
      y.Velocity = Vector3.zero
      y.AssemblyLinearVelocity = Vector3.zero
      y.AssemblyAngularVelocity = Vector3.zero
      z.PlatformStand = true
    end
  end)
  pcall(function()
    ii:FireServer('Block', true)
  end)
end
local function thisisoa()
  if not y or not x or not z or not bb then
    return
  end
  resetState()
  setCharacterPhysics(x, true)
  local bc = x and x:FindFirstChild('Animate')
  if bc then
    bc.Enabled = false
  end
  if z then
    z.PlatformStand = true
  end
  dd = 'follow'
  hh.follow = r.Heartbeat:Connect(function()
    if dd ~= 'follow' or not y then
      return
    end
    local hostChar = bb.Character
    if not hostChar then
      return
    end
    local hostRoot = hostChar:FindFirstChild('HumanoidRootPart')
    if not hostRoot then
      return
    end
    local xy = hostRoot.Position
    local za = 10
    local de = xy.Y - za
    local fg = Vector3.new(xy.X, de, xy.Z)
    local hi = CFrame.new(fg) * CFrame.Angles(0, math.pi, 0)
    y.CFrame = hi
    y.Velocity = Vector3.zero
    y.AssemblyLinearVelocity = Vector3.zero
    y.AssemblyAngularVelocity = Vector3.zero
    z.PlatformStand = true
  end)
  pcall(function()
    ii:FireServer('Block', true)
  end)
end
local function setupClub()
  resetState()
  moveToPosition(Vector3.new(-264.9, -6.2, -374.9), 5)
end
local function setupBank()
  resetState()
  moveToPosition(Vector3.new(-375, 16, -286), 5)
end
local function setupBoxingClub()
  resetState()
  moveToPosition(Vector3.new(-263, 53 - 2.8, -1129), 2.8)
end
local function setupBasketball()
  resetState()
  moveToPosition(Vector3.new(-932, 21 - 5 + 0.3 + 0.6, -483), 5)
end
local function setupSoccer()
  resetState()
  moveToPosition(Vector3.new(-749, 22 - 5 + 1.2, -485), 5)
end
local function setupCell()
  resetState()
  moveToPosition(Vector3.new(-295, 21 - 3, -111), 5)
end
local function setupCell2()
  resetState()
  moveToPosition(Vector3.new(-295, 22 - 3, -68), 5)
end
local function setupSchool()
  resetState()
  moveToPosition(Vector3.new(-654, 21 - 3, 256), 5)
end
local function setupTrain()
  resetState()
  moveToPosition(Vector3.new(636, 47 - 5, -80), 5)
end
local function setupCasino()
  resetState()
  moveToPosition(Vector3.new(-865.9, 21.8, -141.8), 3.5)
end
local function handleCommand(de)
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
      setupClub()
    elseif setup_loc == 'bank' then
      setupBank()
    elseif setup_loc == 'boxingclub' then
      setupBoxingClub()
    elseif setup_loc == 'basketball' then
      setupBasketball()
    elseif setup_loc == 'soccer' then
      setupSoccer()
    elseif setup_loc == 'cell' then
      setupCell()
    elseif setup_loc == 'cell2' then
      setupCell2()
    elseif setup_loc == 'school' then
      setupSchool()
    elseif setup_loc == 'train' then
      setupTrain()
    elseif setup_loc == 'casino' then
      setupCasino()
    end
  elseif hi == 'follow' or hi == 'reset' then
    thisisoa()
  end
end
local function onCharacterAdded(bc)
  x = bc
  y = bc and bc:WaitForChild('HumanoidRootPart', 5)
  z = bc and bc:WaitForChild('Humanoid', 5)
  if not y or not z then
    return
  end
  method6()
  thisisoa()
end
local function onHostCharacterAdded(za)
  if za == bb then
    w:Kick('Kicked by your host.')
  end
end

bb = findHost(5)
if bb then
  hh.hostCheck = r.Heartbeat:Connect(function()
    local host = findHost(1)
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
          handleCommand(kl.Text)
        end)
      end
    end
  end)
  bb.CharacterAdded:Connect(onHostCharacterAdded)
end
w.CharacterAdded:Connect(onCharacterAdded)
method6()
thisisoa()
