-- Mizukage Official | TeamMizu🔰 - All rights reserved
-- Game: Flick (Murder Mystery 2)
-- Script rebuilt by MIZU-OS v14.0
-- ⚠️ WAJIB DIISI: Place ID game Flick/MM2

-- LOAD LUNA (WAJIB)
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- BUAT WINDOW UTAMA
local Window = Luna:CreateWindow({
    Name = "Mizukage Official",
    Subtitle = "Flick - TeamMizu🔰",
    LogoID = "104266190557772",
    LoadingEnabled = true,
    LoadingTitle = "Mizukage System",
    LoadingSubtitle = "by @MizukageOfficial",
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "MizukageHub/Flick"
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer

-- ============================================
-- CHARACTER REFS
-- ============================================
local character = nil
local hum = nil
local root = nil

local function updateChar(char)
    character = char
    root = character and character:FindFirstChild("HumanoidRootPart")
    hum = character and character:FindFirstChild("Humanoid")
end

updateChar(lp.Character or lp.CharacterAdded:Wait())
lp.CharacterAdded:Connect(updateChar)

-- ============================================
-- STATE
-- ============================================
local State = {
    autoAimToggle = false,
    fovToggle = false,
    fovRadius = 30,
    aimbotPart = "Head",
    aimbotSmoothness = 10,
    teamCheckToggle = false,
    wallCheckToggle = false,
    walkToggle = false,
    currentSpeed = 28,
    noclipToggle = false,
    antiAfkToggle = false,
    flingToggle = false,
    antiFlingToggle = false,
    espHighlight = false,
    espTracers = false,
    espNames = false,
    espBoxes = false,
    espStuds = false,
    selectedEspTypes = {},
    noclipConnection = nil,
    clip = false
}

-- ============================================
-- FOV CIRCLE GUI
-- ============================================
local CoreGui = game:GetService("CoreGui")
local PlayerGui = lp:WaitForChild("PlayerGui")

local existing = CoreGui:FindFirstChild("MizuFOV") or PlayerGui:FindFirstChild("MizuFOV")
if existing then existing:Destroy() end

local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "MizuFOV"
FOVGui.DisplayOrder = 10
FOVGui.ResetOnSpawn = false
FOVGui.IgnoreGuiInset = true

local success, err = pcall(function() FOVGui.Parent = CoreGui end)
if not success then FOVGui.Parent = PlayerGui end

local FOVFrame = Instance.new("Frame")
FOVFrame.Name = "FOVCircle"
FOVFrame.BackgroundTransparency = 1
FOVFrame.BorderSizePixel = 0
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVFrame.Visible = false
FOVFrame.Parent = FOVGui

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1.5
UIStroke.Color = Color3.fromRGB(0, 255, 255)
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = FOVFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = FOVFrame

-- ============================================
-- NOCLIP
-- ============================================
local function noclip()
    State.clip = false
    if State.noclipConnection then State.noclipConnection:Disconnect() end
    State.noclipConnection = RunService.Stepped:Connect(function()
        if State.clip == false and lp.Character then
            for _, v in ipairs(lp.Character:GetChildren()) do
                if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
            end
        end
    end)
end

local function clip()
    State.clip = true
    if State.noclipConnection then
        State.noclipConnection:Disconnect()
        State.noclipConnection = nil
    end
end

-- ============================================
-- WALKSPEED BYPASS
-- ============================================
local function applyBypassSpeed()
    task.spawn(function()
        while task.wait(0.2) do
            if not State.walkToggle then continue end
            if hum then
                for _, conn in ipairs(getconnections(hum:GetPropertyChangedSignal("WalkSpeed"))) do
                    conn:Disable()
                end
                hum.WalkSpeed = State.currentSpeed
            end
        end
    end)
end
applyBypassSpeed()

-- ============================================
-- ANTI AFK
-- ============================================
task.spawn(function()
    while true do
        if State.antiAfkToggle and root then root.CFrame = root.CFrame + Vector3.new(0, 3, 0) end
        task.wait(60)
    end
end)

-- ============================================
-- FLING
-- ============================================
local function fling()
    local movel = 0.1
    while State.flingToggle do
        RunService.Heartbeat:Wait()
        if root then
            local vel = root.Velocity
            root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
            RunService.RenderStepped:Wait()
            root.Velocity = vel
            RunService.Stepped:Wait()
            root.Velocity = vel + Vector3.new(0, movel, 0)
            movel = -movel
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.02)
        if State.flingToggle then fling() end
    end
end)

-- ============================================
-- ANTI FLING
-- ============================================
task.spawn(function()
    while task.wait(0.02) do
        if State.antiFlingToggle then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character then
                    for _, part in ipairs(plr.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end
    end
end)

-- ============================================
-- AIMBOT
-- ============================================
local function isAlive(obj)
    local hum = obj:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function autoaim()
    RunService.Heartbeat:Connect(function()
        local screenCenter = Camera.ViewportSize / 2

        if State.fovToggle then
            FOVFrame.Visible = true
            local diameter = State.fovRadius * 2
            FOVFrame.Size = UDim2.new(0, diameter, 0, diameter)
        else
            FOVFrame.Visible = false
        end

        if not State.autoAimToggle or not lp.Character then return end
        if not root then return end

        local nearestTarget = nil
        local shortestDistance = math.huge

        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj == lp.Character then continue end
            if not obj:IsA("Model") then continue end
            if obj.Name == "deadbody" then continue end
            if not isAlive(obj) then continue end
            
            local targetPart = obj:FindFirstChild(State.aimbotPart)
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen and State.fovToggle then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist > State.fovRadius then continue end
                elseif State.fovToggle and not onScreen then
                    continue
                end

                if State.wallCheckToggle then
                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {lp.Character, obj}
                    local ray = workspace:Raycast(root.Position, (targetPart.Position - root.Position), rayParams)
                    if ray then continue end
                end

                local mag = (targetPart.Position - root.Position).Magnitude
                if mag < shortestDistance then
                    shortestDistance = mag
                    nearestTarget = obj
                end
            end
        end

        if nearestTarget then
            local tPart = nearestTarget:FindFirstChild(State.aimbotPart)
            if tPart then
                local targetLook = CFrame.new(Camera.CFrame.Position, tPart.Position)
                if State.aimbotSmoothness > 0 then
                    Camera.CFrame = Camera.CFrame:Lerp(targetLook, 1 / State.aimbotSmoothness)
                else
                    Camera.CFrame = targetLook
                end
            end
        end
    end)
end

-- ============================================
-- SILENT AIM (NO RECOIL)
-- ============================================
local function setupSilentAim()
    local bullet_handler = require(game:GetService("ReplicatedStorage").ModuleScripts.GunModules.BulletHandler)
    local old = bullet_handler.Fire
    bullet_handler.Fire = function(data)
        local closest = nil
        local closestDist = 999
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= lp and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Camera.ViewportSize / 2).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = head
                        end
                    end
                end
            end
        end
        if closest then
            data.Force = data.Force * 1000
            data.Direction = (closest.Position - data.Origin).Unit
        end
        return old(data)
    end
end

-- ============================================
-- FOV SLIDER
-- ============================================
local fovRadius = 70
RunService.RenderStepped:Connect(function()
    if workspace.CurrentCamera.FieldOfView ~= fovRadius then
        workspace.CurrentCamera.FieldOfView = fovRadius
    end
end)

-- ============================================
-- ESP SYSTEM (SEDERHANA)
-- ============================================
local esp = {}
local DrawingAvailable = (type(Drawing) == "table" or type(Drawing) == "userdata")

local function contains(tbl, val)
    if not tbl or type(tbl) ~= "table" then return false end
    for _, v in ipairs(tbl) do if v == val then return true end end
    return false
end

local function isPlayerObject(obj)
    if obj:IsA("Model") and obj:FindFirstChild("Head") and obj.Name ~= lp.Name then return true end
    return false
end

local function passesDropdownFilter(obj)
    if not State.selectedEspTypes or #State.selectedEspTypes == 0 then return false end
    if contains(State.selectedEspTypes, "Players") and isPlayerObject(obj) then return true end
    return false
end

local function getObjColor(obj)
    return Color3.fromRGB(0, 255, 0)
end

local function getRootPosition(target)
    if target:IsA("BasePart") then return target.Position end
    if target:IsA("Model") then
        if target.PrimaryPart then return target.PrimaryPart.Position end
        local r = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("VisibleParts")
        if r and r:IsA("BasePart") then return r.Position end
        return target:GetPivot().Position
    end
    return Vector3.new(0, 0, 0)
end

local function ensureHighlight(obj)
    if not State.espHighlight then
        if esp[obj] and esp[obj].highlight then
            esp[obj].highlight:Destroy()
            esp[obj].highlight = nil
        end
        return
    end
    if not esp[obj] then esp[obj] = {} end
    if not esp[obj].highlight then
        local h = Instance.new("Highlight")
        h.Adornee = obj
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
        h.FillColor = getObjColor(obj)
        h.OutlineColor = Color3.new(1, 1, 1)
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = obj
        esp[obj].highlight = h
    end
end

local function removeESP(obj)
    if esp[obj] and esp[obj].highlight then
        pcall(function() esp[obj].highlight:Destroy() end)
        esp[obj] = nil
    end
end

local lastUpdateEsp = 0
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastUpdateEsp > 1.5 then
        lastUpdateEsp = now
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj ~= lp.Character and passesDropdownFilter(obj) then
                ensureHighlight(obj)
            end
        end
    end
end)

-- ============================================
-- PROTECT IDENTITY
-- ============================================
local idConn = nil
local function bacon(c)
    if not character then return end
    for _, v in pairs(character:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Clothing") or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") then v:Destroy() end
    end
    if character:FindFirstChild("Head") and character.Head:FindFirstChild("face") then character.Head.face.Texture = "rbxassetid://144075659" end
    local bc = character:FindFirstChild("BodyColors") or Instance.new("BodyColors", c)
    bc.HeadColor3 = Color3.fromRGB(234, 184, 146)
    bc.TorsoColor3 = Color3.fromRGB(116, 134, 157)
    bc.LeftLegColor3 = Color3.fromRGB(82, 84, 82)
    bc.RightLegColor3 = Color3.fromRGB(82, 84, 82)
    bc.LeftArmColor3 = bc.HeadColor3
    bc.RightArmColor3 = bc.HeadColor3
    lp.Name = "mizukage"
    lp.DisplayName = "mizukage"
end

-- ============================================
-- CREATE TABS (LUNA)
-- ============================================

local MainTab = Window:CreateTab({ Name = "Main", Icon = "rocket", ImageSource = "Material", ShowTitle = true })
local EspTab = Window:CreateTab({ Name = "ESP", Icon = "visibility", ImageSource = "Material", ShowTitle = true })
local PlayerTab = Window:CreateTab({ Name = "Player", Icon = "person", ImageSource = "Material", ShowTitle = true })
local MiscTab = Window:CreateTab({ Name = "Misc", Icon = "more_horiz", ImageSource = "Material", ShowTitle = true })

-- Main Tab - Aimbot Section
MainTab:CreateParagraph({ Title = "AIMBOT", Text = "Pengaturan aimbot" })
MainTab:CreateToggle({ Name = "Auto Aimbot", CurrentValue = false, Callback = function(v) State.autoAimToggle = v; if v then autoaim() end end })
MainTab:CreateToggle({ Name = "Aimbot FOV", CurrentValue = false, Callback = function(v) State.fovToggle = v end })

MainTab:CreateDivider()
MainTab:CreateParagraph({ Title = "AIMBOT SETTINGS", Text = "Konfigurasi aimbot" })
MainTab:CreateDropdown({ Name = "Target Part", Options = { "Head", "HumanoidRootPart" }, CurrentOption = {"Head"}, Callback = function(v) State.aimbotPart = v[1] end })
MainTab:CreateSlider({ Name = "Camera Smoothness", Range = {0, 50}, Increment = 1, CurrentValue = 10, Callback = function(v) State.aimbotSmoothness = v end })
MainTab:CreateSlider({ Name = "FOV Radius", Range = {10, 150}, Increment = 1, CurrentValue = 30, Callback = function(v) State.fovRadius = v end })
MainTab:CreateToggle({ Name = "Wall Check?", CurrentValue = false, Callback = function(v) State.wallCheckToggle = v end })

MainTab:CreateDivider()
MainTab:CreateParagraph({ Title = "EXPLOITS", Text = "Fitur exploit" })
MainTab:CreateToggle({ Name = "Silent Aim/Insta Hit", CurrentValue = false, Callback = function(v) if v then setupSilentAim() end end })

-- ESP Tab
EspTab:CreateParagraph({ Title = "VISUAL", Text = "Pengaturan visual" })
EspTab:CreateSlider({ Name = "FOV Radius", Range = {1, 120}, Increment = 1, CurrentValue = 70, Callback = function(v) fovRadius = v end })
EspTab:CreateButton({ Name = "Full Bright", Callback = function()
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.Brightness = 2
    Lighting.ShadowSoftness = 0
    Lighting.GlobalShadows = false
end })
EspTab:CreateDropdown({ Name = "ESP Types", Options = { "Players" }, CurrentOption = {}, Multi = true, Callback = function(v) State.selectedEspTypes = v end })
EspTab:CreateToggle({ Name = "Highlight objects", CurrentValue = false, Callback = function(v) State.espHighlight = v end })

-- Player Tab
PlayerTab:CreateParagraph({ Title = "PLAYER MODS", Text = "Modifikasi karakter" })
PlayerTab:CreateToggle({ Name = "Noclip", CurrentValue = false, Callback = function(v) State.noclipToggle = v; if v then noclip() else clip() end end })
PlayerTab:CreateToggle({ Name = "WalkSpeed Changer", CurrentValue = false, Callback = function(v) State.walkToggle = v end })
PlayerTab:CreateSlider({ Name = "WalkSpeed", Range = {16, 100}, Increment = 1, CurrentValue = 16, Callback = function(v) State.currentSpeed = v end })

-- Misc Tab
MiscTab:CreateParagraph({ Title = "MISC", Text = "Fitur tambahan" })
MiscTab:CreateToggle({ Name = "Protect Identity", CurrentValue = false, Callback = function(v)
    if v then
        bacon(character)
        if idConn then idConn:Disconnect() end
        idConn = lp.CharacterAdded:Connect(function(c) bacon(c); task.wait(2); bacon(c) end)
    else
        if idConn then idConn:Disconnect() end
    end
end })
MiscTab:CreateToggle({ Name = "Anti AFK", CurrentValue = false, Callback = function(v) State.antiAfkToggle = v end })
MiscTab:CreateToggle({ Name = "Anti Fling", CurrentValue = false, Callback = function(v) State.antiFlingToggle = v end })
MiscTab:CreateToggle({ Name = "Touch Fling", CurrentValue = false, Callback = function(v) State.flingToggle = v end })

-- Theme Tab
local ThemeTab = Window:CreateTab({ Name = "Theme", Icon = "palette", ImageSource = "Material", ShowTitle = true })
ThemeTab:BuildThemeSection()

-- Config Tab
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
Luna:Notification({
    Title = "Mizukage System",
    Content = "Flick loaded!",
    Icon = "verified",
    ImageSource = "Material"
})