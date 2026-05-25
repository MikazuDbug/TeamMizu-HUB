-- Mizukage Official | TeamMizu🔰 - All rights reserved
-- Game: Blade Ball
-- Script rebuilt by MIZU-OS v14.0

-- LOAD LUNA (WAJIB)
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- BUAT WINDOW UTAMA
local Window = Luna:CreateWindow({
    Name = "Mizukage Official",
    Subtitle = "Blade Ball - TeamMizu🔰",
    LogoID = "104266190557772",
    LoadingEnabled = true,
    LoadingTitle = "Mizukage System",
    LoadingSubtitle = "by @MizukageOfficial",
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "MizukageHub/BladeBall"
    },
    KeySystem = false
})

-- HOME TAB (WAJIB)
Window:CreateHomeTab({
    SupportedExecutors = {"Delta", "Codex", "Wave", "Arceus X", "Synapse X", "Krnl", "Fluxus", "Electron", "JJSploit", "Calamari", "SirHurt", "Sentinel", "WEAREDEVS", "Comet", "Cellery", "ProtoSmasher", "Script-Ware", "EasyExploits"},
    DiscordInvite = "Mizukage-Official",
    Icon = 1
})

-- ============================================
-- SERVICES
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled and not (UserInputService.KeyboardEnabled or UserInputService.MouseEnabled)

-- ============================================
-- GLOBAL STATE (getgenv)
-- ============================================
local G = getgenv()
G.mizu_auto_parry = G.mizu_auto_parry or false
G.mizu_speed_hack = G.mizu_speed_hack or false
G.mizu_speed_value = G.mizu_speed_value or 16
G.mizu_esp_enabled = G.mizu_esp_enabled or false
G.mizu_full_bright = G.mizu_full_bright or false
G.mizu_boost_fps = G.mizu_boost_fps or false

-- ============================================
-- SCRIPT STATE
-- ============================================
local State = {
    parryMethod = "F",
    isSpamming = false,
    spamFloatingUI = nil,
    spamButtonRef = nil,
    autoParryConnections = {},
    spamConnections = {},
    lastParryTime = tick(),
    parryCount = 0,
    lastCurveTime = tick(),
    lastSuccessTime = tick(),
    curveAngle = 0,
    runtimeFolder = nil
}

-- ============================================
-- RUNTIME FOLDER
-- ============================================
local function GetRuntimeFolder()
    local runtime = Workspace:FindFirstChild("Runtime")
    if not runtime then runtime = Workspace.ChildAdded:Wait() end
    return runtime
end

State.runtimeFolder = GetRuntimeFolder()

Workspace.ChildAdded:Connect(function(child)
    if child.Name == "Runtime" then State.runtimeFolder = child end
end)

-- ============================================
-- PARRY EXECUTION
-- ============================================
local function ExecuteParry()
    if isMobile then
        local success, blockGui = pcall(function() return LocalPlayer.PlayerGui.Hotbar.Block end)
        if success and blockGui then
            for _, sound in ipairs(blockGui:GetDescendants()) do
                if sound:IsA("Sound") then sound.Volume = 0 end
            end
            pcall(function() firesignal(blockGui.Activated) end)
            task.wait(0.1)
            for _, sound in ipairs(blockGui:GetDescendants()) do
                if sound:IsA("Sound") then sound.Volume = 1 end
            end
        end
        return
    end
    
    if State.parryMethod == "F" then
        VirtualInputManager:SendKeyEvent(true, "F", false, game)
        task.defer(function() VirtualInputManager:SendKeyEvent(false, "F", false, game) end)
    elseif State.parryMethod == "LeftClick" then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.defer(function() VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0) end)
    end
end

-- ============================================
-- BALL UTILITIES
-- ============================================
local BallUtils = {}

function BallUtils.GetAllBalls()
    local balls = {}
    local ballsFolder = Workspace:FindFirstChild("Balls")
    if not ballsFolder then return balls end
    
    for _, ball in ipairs(ballsFolder:GetChildren()) do
        if ball:GetAttribute("realBall") then
            ball.CanCollide = false
            table.insert(balls, ball)
        end
    end
    return balls
end

function BallUtils.GetNearestBall()
    local ballsFolder = Workspace:FindFirstChild("Balls")
    if not ballsFolder then return nil end
    
    for _, ball in ipairs(ballsFolder:GetChildren()) do
        if ball:GetAttribute("realBall") then
            ball.CanCollide = false
            return ball
        end
    end
    return nil
end

function BallUtils.GetClosestPlayer()
    local aliveFolder = Workspace:FindFirstChild("Alive")
    if not aliveFolder then return nil end
    
    local closestDist = math.huge
    local closestPlayer = nil
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    
    if not hrp then return nil end
    
    for _, player in ipairs(aliveFolder:GetChildren()) do
        if tostring(player) ~= tostring(LocalPlayer) and player:FindFirstChild("HumanoidRootPart") then
            local dist = (hrp.Position - player.HumanoidRootPart.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestPlayer = player
            end
        end
    end
    
    return closestPlayer
end

function BallUtils.GetBallProperties()
    local ball = BallUtils.GetNearestBall()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    
    if not ball or not hrp then
        return { velocity = Vector3.zero, direction = Vector3.zero, distance = 0 }
    end
    
    return {
        velocity = ball.AssemblyLinearVelocity,
        direction = (hrp.Position - ball.Position).Unit,
        distance = (hrp.Position - ball.Position).Magnitude
    }
end

function BallUtils.IsBallCurved()
    local ball = BallUtils.GetNearestBall()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    
    if not ball or not hrp then return false end
    
    local zoomies = ball:FindFirstChild("zoomies")
    if not zoomies then return false end
    
    local ballVelocity = zoomies.VectorVelocity
    local ballSpeed = ballVelocity.Magnitude
    local directionToPlayer = (hrp.Position - ball.Position).Unit
    local dotProduct = directionToPlayer:Dot(ballVelocity.Unit)
    local distance = (hrp.Position - ball.Position).Magnitude
    local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    
    local targetAngle = math.deg(math.acos(math.clamp(dotProduct, -1, 1)))
    State.curveAngle = State.curveAngle + (targetAngle - State.curveAngle) * 0.8
    
    local isCurved = false
    
    if ballSpeed > 100 and distance / ballSpeed - ping > ping * 10 then
        local reactionTime = math.max(15 - math.min(distance / 1000, 15) + math.min(ballSpeed / 100, 40), 15)
        if distance < reactionTime then return false end
    end
    
    if dotProduct < 0.5 - ping then isCurved = true end
    
    if State.curveAngle < 1.8 then State.lastCurveTime = tick() end
    
    if tick() - State.lastCurveTime < reactionTime / 1.5 then return true end
    if tick() - State.lastSuccessTime < reactionTime / 1.5 then return true end
    
    return isCurved
end

function BallUtils.ShouldParry(ball)
    if not ball then return false end
    
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local zoomies = ball:FindFirstChild("zoomies")
    if not zoomies then return false end
    
    if ball:GetAttribute("target") ~= tostring(LocalPlayer) then return false end
    if ball:FindFirstChild("ComboCounter") then return false end
    
    local slashVFX = ball:FindFirstChild("AeroDynamicSlashVFX")
    if slashVFX then
        Debris:AddItem(slashVFX, 0)
        State.lastParryTime = tick()
    end
    
    local runtime = State.runtimeFolder
    local tornado = runtime and runtime:FindFirstChild("Tornado")
    if tornado then
        local tornadoTime = tornado:GetAttribute("TornadoTime") or 1
        if tick() - State.lastParryTime < tornadoTime + 0.314159 then return false end
    end
    
    local ballSpeed = zoomies.VectorVelocity.Magnitude
    local distance = (hrp.Position - ball.Position).Magnitude
    local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    local reactionTime = math.max(ballSpeed / 2.2 + ping / 10 * 1.3 - math.min(ballSpeed / 25, 17 * 0.7), 18)
    
    local singularity = hrp:FindFirstChild("SingularityCape")
    if singularity then return false end
    
    if BallUtils.IsBallCurved() then return false end
    
    if distance <= reactionTime then return true end
    
    local directionToPlayer = (ball.Position - hrp.Position).Unit
    if directionToPlayer:Dot(zoomies.VectorVelocity.Unit) > 0.92 and distance <= reactionTime * 1.35 then
        return true
    end
    
    return false
end

-- ============================================
-- AUTO PARRY SYSTEM
-- ============================================
local function StopAutoParry()
    for _, conn in ipairs(State.autoParryConnections) do
        if conn and conn.Connected then conn:Disconnect() end
    end
    State.autoParryConnections = {}
end

local function StartAutoParry()
    StopAutoParry()
    
    local lastParryFrame = false
    
    local function CheckParry()
        if not G.mizu_auto_parry then return end
        
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        local balls = BallUtils.GetAllBalls()
        for _, ball in ipairs(balls) do
            if BallUtils.ShouldParry(ball) then
                ExecuteParry()
                State.parryCount = State.parryCount + 1
                ball:GetAttributeChangedSignal("target"):Once(function() lastParryFrame = false end)
                break
            end
        end
    end
    
    table.insert(State.autoParryConnections, RunService.PreSimulation:Connect(CheckParry))
    table.insert(State.autoParryConnections, RunService.Heartbeat:Connect(CheckParry))
    table.insert(State.autoParryConnections, RunService.RenderStepped:Connect(CheckParry))
end

-- ============================================
-- AUTO SPAM SYSTEM
-- ============================================
local function StopAutoSpam()
    for _, conn in ipairs(State.spamConnections) do
        if conn and conn.Connected then conn:Disconnect() end
    end
    State.spamConnections = {}
    
    if State.spamFloatingUI then
        State.spamFloatingUI:Destroy()
        State.spamFloatingUI = nil
        State.spamButtonRef = nil
    end
end

local function UpdateSpamButtonUI()
    if not State.spamButtonRef then return end
    
    if State.isSpamming then
        State.spamButtonRef.Text = "● ON"
        State.spamButtonRef.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
    else
        State.spamButtonRef.Text = "● OFF"
        State.spamButtonRef.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    end
end

local function ToggleAutoSpam()
    State.isSpamming = not State.isSpamming
    
    if State.isSpamming then
        table.insert(State.spamConnections, RunService.Heartbeat:Connect(function()
            if State.isSpamming then ExecuteParry() end
        end))
        Luna:Notification({ Title = "Auto Spam", Content = "Aktif!", Icon = "check", ImageSource = "Material" })
    else
        StopAutoSpam()
        Luna:Notification({ Title = "Auto Spam", Content = "Mati", Icon = "warning", ImageSource = "Material" })
    end
    
    UpdateSpamButtonUI()
end

local function CreateSpamFloatingUI()
    StopAutoSpam()
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MizuSpam"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer.PlayerGui
    
    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 170, 0, 75)
    mainFrame.Position = UDim2.new(0.5, -85, 0, 14)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = Color3.fromRGB(70, 70, 70)
    stroke.Thickness = 1.2
    
    local titleLabel = Instance.new("TextLabel", mainFrame)
    titleLabel.Size = UDim2.new(1, 0, 0, 22)
    titleLabel.Position = UDim2.new(0, 0, 0, 3)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "SPAM PARRY"
    titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    
    local toggleButton = Instance.new("TextButton", mainFrame)
    toggleButton.Size = UDim2.new(0, 148, 0, 38)
    toggleButton.Position = UDim2.new(0.5, -74, 0, 30)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 17
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.BorderSizePixel = 0
    Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 8)
    
    State.spamButtonRef = toggleButton
    State.spamFloatingUI = screenGui
    
    toggleButton.MouseButton1Click:Connect(ToggleAutoSpam)
    UpdateSpamButtonUI()
end

local function SetAutoSpam(enabled)
    if enabled then
        State.isSpamming = true
        CreateSpamFloatingUI()
        table.insert(State.spamConnections, RunService.Heartbeat:Connect(function()
            if State.isSpamming then ExecuteParry() end
        end))
    else
        State.isSpamming = false
        StopAutoSpam()
    end
end

-- ============================================
-- BALL TRACKING SYSTEM
-- ============================================
local function CreateBallTracker()
    local tracker = { activeBalls = {}, ballConnections = {}, folderConnections = {} }
    
    local function onBallAdded(ball)
        if not ball:IsA("BasePart") then return end
        if ball:GetAttribute("realBall") ~= true then return end
        if not ball.Parent or (ball.Parent.Name ~= "Balls" and ball.Parent.Name ~= "TrainingBalls") then return end
        
        if ball:GetAttribute("target") == LocalPlayer.Name then tracker.activeBalls[ball] = true end
        
        tracker.ballConnections[ball] = ball:GetAttributeChangedSignal("target"):Connect(function()
            tracker.activeBalls[ball] = ball:GetAttribute("target") == LocalPlayer.Name
        end)
        
        ball.AncestryChanged:Connect(function()
            if tracker.ballConnections[ball] then
                tracker.ballConnections[ball]:Disconnect()
                tracker.ballConnections[ball] = nil
                tracker.activeBalls[ball] = nil
            end
        end)
    end
    
    local function onBallRemoved(ball)
        if tracker.ballConnections[ball] then
            tracker.ballConnections[ball]:Disconnect()
            tracker.ballConnections[ball] = nil
        end
        tracker.activeBalls[ball] = nil
    end
    
    local function trackFolder(folder)
        if tracker.folderConnections[folder] then return end
        for _, ball in ipairs(folder:GetChildren()) do onBallAdded(ball) end
        tracker.folderConnections[folder] = {
            added = folder.ChildAdded:Connect(onBallAdded),
            removed = folder.ChildRemoved:Connect(onBallRemoved)
        }
    end
    
    for _, child in ipairs(Workspace:GetChildren()) do
        if child.Name == "Balls" or child.Name == "TrainingBalls" then trackFolder(child) end
    end
    
    Workspace.ChildAdded:Connect(function(child)
        if child.Name == "Balls" or child.Name == "TrainingBalls" then trackFolder(child) end
    end)
    
    tracker.GetActiveBalls = function()
        local balls = {}
        for ball, active in pairs(tracker.activeBalls) do
            if active and ball.Parent then table.insert(balls, ball) else tracker.activeBalls[ball] = nil end
        end
        return balls
    end
    
    return tracker
end

local BallTracker = CreateBallTracker()

-- ============================================
-- EVENT LISTENERS
-- ============================================
pcall(function()
    local parryRemote = ReplicatedStorage:FindFirstChild("Remotes")
    if parryRemote then
        parryRemote = parryRemote:FindFirstChild("ParrySuccessAll")
        if parryRemote then
            parryRemote.OnClientEvent:Connect(function(player, part)
                local character = LocalPlayer.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                local ball = BallUtils.GetNearestBall()
                if not ball then return end
                
                local zoomies = ball:FindFirstChild("zoomies")
                if not zoomies then return end
                
                local ballSpeed = zoomies.VectorVelocity.Magnitude
                local distance = (hrp.Position - ball.Position).Magnitude
                local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
                
                local reactionWindow = 15 - math.min(distance / 1000, 15) + math.min(ballSpeed / 100, 40)
                if ballSpeed > 100 and distance / ballSpeed - ping / 1000 > ping / 1000 * 10 then
                    reactionWindow = math.max(reactionWindow - 15, 15)
                end
                
                if part ~= hrp and distance > reactionWindow then State.lastSuccessTime = tick() end
            end)
        end
    end
end)

pcall(function()
    local runtime = GetRuntimeFolder()
    if runtime then
        runtime.ChildAdded:Connect(function(child)
            if child.Name == "Tornado" then State.lastParryTime = tick() end
        end)
    end
end)

-- ============================================
-- SPEED HACK
-- ============================================
local speedConnection = nil
local defaultWalkSpeed = 16

local function UpdateSpeedHack()
    if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
    
    if G.mizu_speed_hack then
        speedConnection = RunService.Heartbeat:Connect(function()
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            if humanoid then humanoid.WalkSpeed = G.mizu_speed_value or 16 end
        end)
    else
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        if humanoid then humanoid.WalkSpeed = defaultWalkSpeed end
    end
end

-- ============================================
-- ESP SYSTEM
-- ============================================
local espFolder = Instance.new("Folder")
espFolder.Name = "Mizu_ESP"
espFolder.Parent = Workspace

local function CreateESPForPlayer(player)
    if player == LocalPlayer then return end
    
    local function addHighlight(character)
        task.wait(0.5)
        local highlight = Instance.new("Highlight")
        highlight.Name = player.Name
        highlight.FillColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineColor = Color3.fromRGB(200, 200, 200)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Enabled = G.mizu_esp_enabled or false
        highlight.Adornee = character
        highlight.Parent = espFolder
        
        player.CharacterAdded:Connect(function(newChar)
            task.wait(0.5)
            highlight.Adornee = newChar
        end)
    end
    
    if player.Character then addHighlight(player.Character) end
    player.CharacterAdded:Connect(addHighlight)
end

for _, player in ipairs(Players:GetPlayers()) do CreateESPForPlayer(player) end
Players.PlayerAdded:Connect(CreateESPForPlayer)

-- ============================================
-- FULL BRIGHT
-- ============================================
local savedLighting = {
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    FogEnd = Lighting.FogEnd,
    ClockTime = Lighting.ClockTime
}

local function UpdateFullBright()
    if G.mizu_full_bright then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.FogEnd = 1000000000
        Lighting.ClockTime = 14
    else
        Lighting.Brightness = savedLighting.Brightness
        Lighting.Ambient = savedLighting.Ambient
        Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
        Lighting.FogEnd = savedLighting.FogEnd
        Lighting.ClockTime = savedLighting.ClockTime
    end
end

-- ============================================
-- BOOST FPS
-- ============================================
local function UpdateBoostFPS()
    if G.mizu_boost_fps then
        settings().Rendering.QualityLevel = 1
        settings().Rendering.EnableFRM = false
        settings().Physics.AllowSleep = true
        settings().Physics.PhysicsEnvironmentalThrottle = 1
        
        local terrain = Workspace:FindFirstChildWhichIsA("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
        end
        
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1000000000
        
        pcall(function()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") then
                    obj.Enabled = false
                end
            end
        end)
    else
        settings().Rendering.QualityLevel = 7
        settings().Rendering.EnableFRM = true
        settings().Physics.AllowSleep = false
        settings().Physics.PhysicsEnvironmentalThrottle = 0
        Lighting.GlobalShadows = true
        
        pcall(function()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") then
                    obj.Enabled = true
                end
            end
        end)
    end
end

-- ============================================
-- KEYBOARD SHORTCUTS
-- ============================================
if not isMobile then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.E and State.spamFloatingUI then ToggleAutoSpam() end
    end)
end

-- ============================================
-- CREATE TABS (LUNA)
-- ============================================

local MainPage = Window:CreateTab({ Name = "MENU", Icon = "rocket", ImageSource = "Material", ShowTitle = true })
local VisualPage = Window:CreateTab({ Name = "VISUAL", Icon = "palette", ImageSource = "Material", ShowTitle = true })
local SettingPage = Window:CreateTab({ Name = "SETTING", Icon = "settings", ImageSource = "Material", ShowTitle = true })
local InfoPage = Window:CreateTab({ Name = "INFO", Icon = "info", ImageSource = "Material", ShowTitle = true })

-- Main Page
MainPage:CreateParagraph({ Title = "AUTO PARRY", Text = "Pengaturan auto parry" })
MainPage:CreateToggle({ Name = "Auto Parry", CurrentValue = false, Callback = function(v) G.mizu_auto_parry = v; if v then StartAutoParry() else StopAutoParry() end end })
MainPage:CreateToggle({ Name = "Auto Spam Parry", CurrentValue = false, Callback = function(v) SetAutoSpam(v); if v then Luna:Notification({ Title = "Auto Spam", Content = "Aktif! Tekan E untuk toggle", Icon = "check", ImageSource = "Material" }) end end })

MainPage:CreateDivider()
MainPage:CreateParagraph({ Title = "PARRY METHOD", Text = "Metode parry" })
MainPage:CreateDropdown({ Name = "Parry Method", Options = {"F", "LeftClick"}, CurrentOption = {"F"}, Callback = function(method) State.parryMethod = method[1] end })

MainPage:CreateDivider()
MainPage:CreateParagraph({ Title = "SPEED HACK", Text = "Pengaturan kecepatan" })
MainPage:CreateSlider({ Name = "Speed Value", Range = {16, 80}, Increment = 1, CurrentValue = 16, Callback = function(v) G.mizu_speed_value = v; if G.mizu_speed_hack then local char = LocalPlayer.Character; local hum = char and char:FindFirstChild("Humanoid"); if hum then hum.WalkSpeed = v end end end })
MainPage:CreateToggle({ Name = "Enable Speed Hack", CurrentValue = false, Callback = function(v) G.mizu_speed_hack = v; UpdateSpeedHack() end })

-- Visual Page
VisualPage:CreateParagraph({ Title = "ESP PLAYER", Text = "ESP untuk pemain" })
VisualPage:CreateToggle({ Name = "Enable ESP", CurrentValue = false, Callback = function(v) G.mizu_esp_enabled = v; for _, highlight in ipairs(espFolder:GetChildren()) do if highlight:IsA("Highlight") then highlight.Enabled = v end end end })

VisualPage:CreateDivider()
VisualPage:CreateParagraph({ Title = "FULL BRIGHT", Text = "Pencahayaan penuh" })
VisualPage:CreateToggle({ Name = "Enable Full Bright", CurrentValue = false, Callback = function(v) G.mizu_full_bright = v; UpdateFullBright() end })

-- Setting Page
SettingPage:CreateParagraph({ Title = "BOOST FPS", Text = "Optimasi performa" })
SettingPage:CreateToggle({ Name = "Boost FPS", CurrentValue = false, Callback = function(v) G.mizu_boost_fps = v; UpdateBoostFPS() end })

-- Info Page
InfoPage:CreateParagraph({ Title = "SCRIPT INFO", Text = "Informasi script" })
InfoPage:CreateParagraph({ Title = "Mizukage Blade Ball", Text = "Version: 2.0" })
InfoPage:CreateDivider()
InfoPage:CreateParagraph({ Title = "Features", Text = "- Auto Parry (Stronger Detection)\n- Auto Spam + Floating UI (Keybind E)\n- Speed Hack (Max 80)\n- ESP Player\n- Full Bright\n- Boost FPS\n- Parry Method: F / LeftClick" })
InfoPage:CreateParagraph({ Title = "Credits", Text = "TeamMizu🔰" })

-- Theme Tab (WAJIB)
local ThemeTab = Window:CreateTab({ Name = "Theme", Icon = "palette", ImageSource = "Material", ShowTitle = true })
ThemeTab:BuildThemeSection()

-- Config Tab (WAJIB)
local ConfigTabWindow = Window:CreateTab({ Name = "Config", Icon = "settings", ImageSource = "Material", ShowTitle = true })
ConfigTabWindow:BuildConfigSection()
ConfigTabWindow:CreateButton({
    Name = "Shutdown Script",
    Callback = function()
        getgenv().MizuConfig = getgenv().MizuConfig or { IsRunning = true }
        getgenv().MizuConfig.IsRunning = false
        Luna:Destroy()
    end
})

-- ============================================
-- INITIALIZATION
-- ============================================
UpdateSpeedHack()
UpdateFullBright()
UpdateBoostFPS()

task.wait(0.5)
Luna:Notification({
    Title = "Mizukage System",
    Content = "Blade Ball loaded!",
    Icon = "verified",
    ImageSource = "Material"
})