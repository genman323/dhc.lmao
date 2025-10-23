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

  -- Main Frame
  local mainFrame = Instance.new("Frame", gui)
  mainFrame.Size = UDim2.new(0, 300, 0, 400)
  mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
  mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
  mainFrame.BorderSizePixel = 0

  -- Title
  local title = Instance.new("TextLabel", mainFrame)
  title.Size = UDim2.new(1, 0, 0, 40)
  title.Position = UDim2.new(0, 0, 0, 0)
  title.Text = "Hezyan"
  title.TextColor3 = Color3.fromRGB(255, 255, 255)
  title.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
  title.Font = Enum.Font.GothamBold
  title.TextSize = 16
  title.BorderSizePixel = 0

  -- Tabs
  local tabFrame = Instance.new("Frame", mainFrame)
  tabFrame.Size = UDim2.new(1, -10, 0, 30)
  tabFrame.Position = UDim2.new(0, 5, 0, 45)
  tabFrame.BackgroundTransparency = 1

  local tabLayout = Instance.new("UIListLayout", tabFrame)
  tabLayout.FillDirection = Enum.FillDirection.Horizontal
  tabLayout.Padding = UDim.new(0, 5)

  local tabs = {"main", "visuals", "character", "misc", "settings"}
  local currentTab = "main"

  for _, tab in ipairs(tabs) do
    local tabButton = Instance.new("TextButton", tabFrame)
    tabButton.Size = UDim2.new(0, 50, 1, 0)
    tabButton.Text = tab
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    tabButton.BorderSizePixel = 0
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 12

    tabButton.MouseButton1Click:Connect(function()
      currentTab = tab
      updateContent()
    end)

    tabButton.MouseEnter:Connect(function()
      tabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end)

    tabButton.MouseLeave:Connect(function()
      tabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    end)
  end

  -- Content Frame
  local contentFrame = Instance.new("Frame", mainFrame)
  contentFrame.Size = UDim2.new(1, -10, 0, 300)
  contentFrame.Position = UDim2.new(0, 5, 0, 80)
  contentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
  contentFrame.BorderSizePixel = 0

  local contentLayout = Instance.new("UIListLayout", contentFrame)
  contentLayout.Padding = UDim.new(0, 5)

  local function createToggle(name, key)
    local toggleFrame = Instance.new("Frame", contentFrame)
    toggleFrame.Size = UDim2.new(1, -10, 0, 30)
    toggleFrame.BackgroundTransparency = 1

    local toggleButton = Instance.new("TextButton", toggleFrame)
    toggleButton.Size = UDim2.new(0, 20, 1, 0)
    toggleButton.Position = UDim2.new(0, 0, 0, 0)
    toggleButton.Text = ""
    toggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    toggleButton.BorderSizePixel = 0

    local toggleLabel = Instance.new("TextLabel", toggleFrame)
    toggleLabel.Size = UDim2.new(1, -25, 1, 0)
    toggleLabel.Position = UDim2.new(0, 25, 0, 0)
    toggleLabel.Text = name
    toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextSize = 12

    local isEnabled = false
    toggleButton.MouseButton1Click:Connect(function()
      isEnabled = not isEnabled
      toggleButton.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(45, 45, 60)
      if chan then
        chan:SendAsync(gg .. key .. (isEnabled and " 1" or " 0"))
      end
    end)
  end

  local function updateContent()
    contentFrame:ClearAllChildren()
    contentLayout.Parent = contentFrame

    if currentTab == "main" then
      createToggle("silent aim", "sa")
      createToggle("closest part", "cp")
      createToggle("match y axis", "my")
    elseif currentTab == "visuals" then
      createToggle("sticky aim targeting", "sat")
      createToggle("visible only", "vo")
    elseif currentTab == "character" then
      createToggle("ignore protected", "ip")
      createToggle("ignore crew/team", "ict")
    elseif currentTab == "misc" then
      createToggle("magic bullet exploits", "mbe")
      createToggle("extra pellet", "ep")
    elseif currentTab == "settings" then
      createToggle("kill aura", "ka")
      createToggle("trust only target", "tot")
    end
  end

  updateContent()

  return
end

-- ALTS: Load control script (unchanged)
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
