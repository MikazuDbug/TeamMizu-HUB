-- Mizukage Official | TeamMizu🔰 - All rights reserved
-- Game: Poop Game
-- Script rebuilt by MIZU-OS v14.0
-- ⚠️ WAJIB DIISI: Place ID game Poop Game

-- LOAD LUNA (WAJIB)
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- BUAT WINDOW UTAMA
local Window = Luna:CreateWindow({
    Name = "Mizukage Official",
    Subtitle = "Poop Game - TeamMizu🔰",
    LogoID = "104266190557772",
    LoadingEnabled = true,
    LoadingTitle = "Mizukage System",
    LoadingSubtitle = "by @MizukageOfficial",
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "MizukageHub/PoopGame"
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
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer

-- ============================================
-- REMOTES
-- ============================================
local PoopEvent = ReplicatedStorage:WaitForChild("PoopEvent")
local PoopCharge = ReplicatedStorage:WaitForChild("PoopChargeStart")
local PoopEventSold = ReplicatedStorage:WaitForChild("PoopSold")

-- ============================================
-- CHARACTER & UI REFERENCES
-- ============================================
local character = lp.Character or lp.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local gui = lp:WaitForChild("PlayerGui")
local container = gui:WaitForChild("PoopBalancingUI"):WaitForChild("BalancingContainer")
local bar = container:WaitForChild("MovingBar")
local zone = container:WaitForChild("TargetZone")

-- ============================================
-- STATE
-- ============================================
local State = {
    farmToggle = false,
    sellToggle = false,
    sellSpeed = 1,
    walkToggle = false,
    currentSpeed = 28,
    noclipToggle = false,
    instaToggle = false,
    instaSpeed = 0.30,
    removeToggle = false,
    antiAfkToggle = false,
    flingToggle = false,
    antiFlingToggle = false,
    noclipConnection = nil,
    clip = false,
    clicked = false
}

-- ============================================
-- NOCLIP
-- ============================================
local function noclip()
    State.clip = false
    if State.noclipConnection then State.noclipConnection:Disconnect() end
    State.noclipConnection = RunService.Stepped:Connect(function()
        if State.clip == false and lp.Character then
            for _, v in ipairs(lp.Character:GetChildren()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
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
-- AUTO SELL LOOP
-- ============================================
task.spawn(function()
    while true do
        if State.sellToggle then
            pcall(function()
                PoopEventSold:FireServer()
            end)
            task.wait(State.sellSpeed)
        else
            task.wait(1)
        end
    end
end)

-- ============================================
-- WALKSPEED LOOP
-- ============================================
task.spawn(function()
    while true do
        if State.walkToggle and humanoid then
            humanoid.WalkSpeed = State.currentSpeed
        end
        task.wait()
    end
end)

-- ============================================
-- INSTANT POOP LOOP
-- ============================================
task.spawn(function()
    while true do
        if State.instaToggle then
            local args = { 1 }
            PoopCharge:FireServer(unpack(args))
            PoopEvent:FireServer(unpack(args))
        end
        task.wait(State.instaSpeed)
    end
end)

-- ============================================
-- REMOVE POOPS LOOP
-- ============================================
task.spawn(function()
    while true do
        if State.removeToggle then
            for _, obj in pairs(Workspace:GetChildren()) do
                local name = string.lower(obj.Name)
                if name:find("poop") and not name:find("poopsellernpc") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
        task.wait(0.05)
    end
end)

-- ============================================
-- ANTI AFK
-- ============================================
task.spawn(function()
    while true do
        if State.antiAfkToggle and root then
            root.CFrame = root.CFrame + Vector3.new(0, 3, 0)
        end
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
-- AUTO FARM SKILLCHECK
-- ============================================
RunService.RenderStepped:Connect(function()
    if not State.farmToggle then return end
    if not bar or not zone then return end

    local barX = bar.AbsolutePosition.X + bar.AbsoluteSize.X / 2
    local zoneStart = zone.AbsolutePosition.X
    local zoneEnd = zoneStart + zone.AbsoluteSize.X

    if barX >= zoneStart and barX <= zoneEnd then
        if not State.clicked then
            local clickX = zoneStart + zone.AbsoluteSize.X / 2
            local clickY = zone.AbsolutePosition.Y + zone.AbsoluteSize.Y / 2

            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)

            State.clicked = true
        end
    else
        State.clicked = false
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
local PlayerTab = Window:CreateTab({ Name = "Player", Icon = "person", ImageSource = "Material", ShowTitle = true })
local ExploitTab = Window:CreateTab({ Name = "Exploits", Icon = "cpu", ImageSource = "Material", ShowTitle = true })
local MiscTab = Window:CreateTab({ Name = "Misc", Icon = "more_horiz", ImageSource = "Material", ShowTitle = true })

-- Main Tab
MainTab:CreateParagraph({ Title = "AUTO FARM", Text = "Pengaturan auto farm" })
MainTab:CreateToggle({ Name = "Auto Farm Poop", CurrentValue = false, Callback = function(v) State.farmToggle = v end })
MainTab:CreateToggle({ Name = "Auto Sell Inventory", CurrentValue = false, Callback = function(v) State.sellToggle = v end })
MainTab:CreateSlider({ Name = "Auto Sell Interval", Range = {1, 180}, Increment = 1, CurrentValue = 1, Callback = function(v) State.sellSpeed = v end })

-- Player Tab
PlayerTab:CreateParagraph({ Title = "PLAYER MODS", Text = "Modifikasi karakter" })
PlayerTab:CreateToggle({ Name = "Noclip", CurrentValue = false, Callback = function(v) State.noclipToggle = v; if v then noclip() else clip() end end })
PlayerTab:CreateToggle({ Name = "WalkSpeed Changer", CurrentValue = false, Callback = function(v) State.walkToggle = v end })
PlayerTab:CreateSlider({ Name = "WalkSpeed", Range = {28, 100}, Increment = 1, CurrentValue = 28, Callback = function(v) State.currentSpeed = v end })

-- Exploit Tab
ExploitTab:CreateParagraph({ Title = "EXPLOITS", Text = "Fitur exploit" })
ExploitTab:CreateToggle({ Name = "Instant Poop", CurrentValue = false, Callback = function(v) State.instaToggle = v end })
ExploitTab:CreateSlider({ Name = "Instant Poop Interval", Range = {0.30, 10}, Increment = 0.01, CurrentValue = 0.30, Callback = function(v) State.instaSpeed = v end })
ExploitTab:CreateToggle({ Name = "Remove Poops", CurrentValue = false, Callback = function(v) State.removeToggle = v end })

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
    Content = "Poop Game loaded!",
    Icon = "verified",
    ImageSource = "Material"
})