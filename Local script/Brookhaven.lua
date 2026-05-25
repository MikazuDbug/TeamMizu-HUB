-- Mizukage Official | TeamMizu🔰 - All rights reserved
-- Game: Brookhaven
-- Script rebuilt by MIZU-OS v14.0

-- LOAD LUNA (WAJIB)
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- BUAT WINDOW UTAMA
local Window = Luna:CreateWindow({
    Name = "Mizukage Official",
    Subtitle = "Brookhaven - TeamMizu🔰",
    LogoID = "104266190557772",
    LoadingEnabled = true,
    LoadingTitle = "Mizukage System",
    LoadingSubtitle = "by @MizukageOfficial",
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "MizukageHub/Brookhaven"
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
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local playerNames = {}

local function updatePlayerList()
    playerNames = {}
    for _, player in pairs(Players:GetPlayers()) do
        table.insert(playerNames, player.Name)
    end
end
updatePlayerList()

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
    selectedPlayer = "",
    selectedTPlayer = "",
    loopFling = false,
    loopTP = false,
    walkToggle = false,
    currentSpeed = 16,
    noclipToggle = false,
    antiAfkToggle = false,
    flingToggle = false,
    antiFlingToggle = false,
    noclipConnection = nil,
    clip = false
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
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
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
-- LOOP FLING
-- ============================================
local function loopfling()
    task.spawn(function()
        local savedCF = root and root.CFrame or CFrame.new()
        while State.loopFling do
            task.wait(0.01)
            local hasCouch = false
            local couchTool = nil
            
            for _, item in pairs(lp.Backpack:GetChildren()) do
                if item.Name == "Couch" then
                    hasCouch = true
                    couchTool = item
                    break
                end
            end
            
            if not hasCouch and lp.Character then
                for _, item in pairs(lp.Character:GetChildren()) do
                    if item:IsA("Tool") and item.Name == "Couch" then
                        hasCouch = true
                        couchTool = item
                        break
                    end
                end
            end
            
            if not hasCouch then
                local args = { "PickingTools", "Couch" }
                game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Too1l"):InvokeServer(unpack(args))
            end
            
            if couchTool and couchTool.Parent == lp.Backpack then
                couchTool.Parent = lp.Character
            end
            
            local targetPlayer = Players:FindFirstChild(State.selectedPlayer)
            if targetPlayer and targetPlayer.Character and root then
                if (root.Position - targetPlayer.Character.HumanoidRootPart.Position).Magnitude < 5000 then
                    savedCF = root.CFrame
                end
                
                local seat1 = couchTool and couchTool:FindFirstChild("Seat1")
                local seat2 = couchTool and couchTool:FindFirstChild("Seat2")
                
                if seat1 and seat1.Occupant or seat2 and seat2.Occupant then
                    root.CFrame = CFrame.new(9999999, 9999999, 9999999)
                    task.wait(0.5)
                    if couchTool and couchTool.Parent == lp.Character then
                        couchTool.Parent = lp.Backpack
                    end
                    task.wait(0.5)
                    root.CFrame = savedCF
                    
                    repeat task.wait() until targetPlayer and targetPlayer.Character and (targetPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude < 1000
                else
                    if targetPlayer.Character.HumanoidRootPart then
                        root.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2) + Vector3.new(0, -5, 0)
                    end
                end
            end
        end
    end)
end

-- ============================================
-- BRING
-- ============================================
local function bring()
    local oldPos = root.CFrame
    local hasCouch = false
    local couchTool = nil
            
    for _, item in pairs(lp.Backpack:GetChildren()) do
        if item.Name == "Couch" then
            hasCouch = true
            couchTool = item
            break
        end
    end
            
    if not hasCouch and lp.Character then
        for _, item in pairs(lp.Character:GetChildren()) do
            if item:IsA("Tool") and item.Name == "Couch" then
                hasCouch = true
                couchTool = item
                break
            end
        end
    end
            
    if not hasCouch then
        local args = { "PickingTools", "Couch" }
        game:GetService("ReplicatedStorage"):WaitForChild("RE"):WaitForChild("1Too1l"):InvokeServer(unpack(args))
    end
            
    if couchTool and couchTool.Parent == lp.Backpack then
        couchTool.Parent = lp.Character
    end
            
    local targetPlayer = Players:FindFirstChild(State.selectedPlayer)
    while targetPlayer and targetPlayer.Character and root do
        local seat1 = couchTool and couchTool:FindFirstChild("Seat1")
        local seat2 = couchTool and couchTool:FindFirstChild("Seat2")
        
        if (seat1 and seat1.Occupant) or (seat2 and seat2.Occupant) then
            root.CFrame = oldPos
            task.wait(1)
            if couchTool and couchTool.Parent == lp.Character then
                couchTool.Parent = lp.Backpack
            end
            break
        end
        
        if targetPlayer.Character.HumanoidRootPart then 
            root.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2) + Vector3.new(0, -5, 0) 
        end
        
        task.wait()
    end
end

-- ============================================
-- PROTECT IDENTITY
-- ============================================
local idConn = nil
local function bacon(c)
    if not character then return end
    for _, v in pairs(character:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Clothing") or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") then
            v:Destroy()
        end
    end
    if character:FindFirstChild("Head") and character.Head:FindFirstChild("face") then
        character.Head.face.Texture = "rbxassetid://144075659"
    end
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
local MiscTab = Window:CreateTab({ Name = "Misc", Icon = "more_horiz", ImageSource = "Material", ShowTitle = true })

-- Main Tab - Trolling Section
MainTab:CreateParagraph({ Title = "TROLLING", Text = "Fitur trolling ke player lain" })

local trollingDropdown = MainTab:CreateDropdown({ Name = "Choose Target", Options = playerNames, CurrentOption = {}, Callback = function(v) State.selectedPlayer = v[1] end })
MainTab:CreateToggle({ Name = "Loop Fling Target", CurrentValue = false, Callback = function(v) State.loopFling = v; if v then loopfling() end end })
MainTab:CreateButton({ Name = "Bring Target", Callback = function() bring() end })

MainTab:CreateDivider()
MainTab:CreateParagraph({ Title = "TELEPORTS", Text = "Teleportasi ke player" })

local teleportDropdown = MainTab:CreateDropdown({ Name = "Choose Target", Options = playerNames, CurrentOption = {}, Callback = function(v) State.selectedTPlayer = v[1] end })
MainTab:CreateButton({ Name = "Teleport To Target", Callback = function()
    local target = Players:FindFirstChild(State.selectedTPlayer)
    if target and target.Character and target.Character:FindFirstChild("Head") and root then
        root.CFrame = target.Character.Head.CFrame
    end
end })
MainTab:CreateToggle({ Name = "Loop Teleport To Target", CurrentValue = false, Callback = function(v)
    State.loopTP = v
    task.spawn(function()
        while State.loopTP do
            task.wait(0.01)
            local target = Players:FindFirstChild(State.selectedTPlayer)
            if target and target.Character and target.Character:FindFirstChild("Head") and root then
                root.CFrame = target.Character.Head.CFrame
            end
        end
    end)
end })

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
-- PLAYER LIST UPDATES
-- ============================================
Players.PlayerAdded:Connect(function(player)
    table.insert(playerNames, player.Name)
    trollingDropdown:SetOptions(playerNames)
    teleportDropdown:SetOptions(playerNames)
end)

Players.PlayerRemoving:Connect(function(player)
    for i, name in pairs(playerNames) do
        if name == player.Name then
            table.remove(playerNames, i)
            trollingDropdown:SetOptions(playerNames)
            teleportDropdown:SetOptions(playerNames)
            break
        end
    end
end)

-- ============================================
-- INITIALIZATION
-- ============================================
Luna:Notification({
    Title = "Mizukage System",
    Content = "Brookhaven loaded!",
    Icon = "verified",
    ImageSource = "Material"
})