-- Mizukage Official | TeamMizu🔰 - All rights reserved
-- Game: Aura Trade
-- Script rebuilt by MIZU-OS v14.0

-- LOAD LUNA (WAJIB)
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- BUAT WINDOW UTAMA
local Window = Luna:CreateWindow({
    Name = "Mizukage Official",
    Subtitle = "Aura Trade - TeamMizu🔰",
    LogoID = "104266190557772",
    LoadingEnabled = true,
    LoadingTitle = "Mizukage System",
    LoadingSubtitle = "by @MizukageOfficial",
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "MizukageHub/AuraTrade"
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
-- SERVICES & INIT
-- ============================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local username = lp.Name

local character = nil
local root = nil
local humanoid = nil

local function updateChar(char)
    character = char
    root = character and character:FindFirstChild("HumanoidRootPart")
    humanoid = character and character:FindFirstChild("Humanoid")
end

updateChar(lp.Character or lp.CharacterAdded:Wait())
lp.CharacterAdded:Connect(updateChar)

-- ============================================
-- ANTI CHEAT BYPASS
-- ============================================
local anti = workspace:FindFirstChild(username):FindFirstChild("LocalScript")
if anti then
    anti:Destroy()
    Luna:Notification({ Title = "Mizukage System", Content = "Successfully bypassed anti-cheat.", Icon = "check", ImageSource = "Material" })
else
    Luna:Notification({ Title = "Warning", Content = "Failed to bypass anti-cheat.", Icon = "warning", ImageSource = "Material" })
end

-- ============================================
-- GLOBAL STATE
-- ============================================
local RarityPriority = {
    ["Contrast"] = 1, ["Volcanic"] = 2, ["Tesla"] = 3, ["Heart"] = 4,
    ["Spirit"] = 5, ["Cursed"] = 6, ["Fairy"] = 7, ["Frost"] = 8,
    ["Galatic"] = 9, ["Shimmer"] = 10, ["Lightning"] = 11, ["Pyronova"] = 12,
    ["Inferno"] = 13, ["Divine"] = 14,
}

local State = {
    bestToggle = false,
    antiAfkToggle = false,
    snipeToggle = false,
    noclipToggle = false,
    walkToggle = false,
    currentSpeed = 25,
    selectedSnipeTypes = {},
    tpAuraExploit = false,
    antiAdminToggle = false,
    antiFlingToggle = false,
    flingToggle = false,
    noclipConnection = nil,
    clip = false
}

local sniped = {}
local selectedTypes = {}

-- ============================================
-- NOCLIP FUNCTIONS
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
-- AURA RAIN UI
-- ============================================
local function rainUI()
    local playerGui = lp:WaitForChild("PlayerGui")

    local events = {
        {Name = "Spawn_GALATIC", Interval = 0.01, Type = "RemoteEvent"},
        {Name = "Spawn_FROST", Interval = 0.01, Type = "RemoteEvent"},
        {Name = "Lightning_Strike", Interval = 0.01, Type = "RemoteEvent"},
    }

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MizuAuraRain"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 180, 0, 160)
    frame.Position = UDim2.new(0.5, -90, 0.5, -80)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = frame
    frame.Active = true
    frame.Draggable = true

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 25)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Aura Rain UI"
    titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 20
    titleLabel.Parent = frame

    local toggles = {}

    for i, eventData in ipairs(events) do
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 160, 0, 25)
        toggleBtn.Position = UDim2.new(0, 10, 0, 25 + (i - 1) * 27)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        toggleBtn.TextColor3 = Color3.new(1, 1, 1)
        toggleBtn.Font = Enum.Font.SourceSansBold
        toggleBtn.TextSize = 18
        toggleBtn.Text = eventData.Name .. ": OFF"
        toggleBtn.Parent = frame
        toggles[eventData.Name] = {Button = toggleBtn, Toggled = false}
    end

    for _, eventData in ipairs(events) do
        local eventInstance = ReplicatedStorage:FindFirstChild(eventData.Name)
        if eventInstance then
            local toggleData = toggles[eventData.Name]
            toggleData.Button.MouseButton1Click:Connect(function()
                toggleData.Toggled = not toggleData.Toggled
                toggleData.Button.Text = eventData.Name .. (toggleData.Toggled and ": ON" or ": OFF")
                if toggleData.Toggled then
                    task.spawn(function()
                        while toggleData.Toggled do
                            if eventData.Type == "RemoteEvent" then
                                eventInstance:FireServer()
                            end
                            task.wait(eventData.Interval)
                        end
                    end)
                end
            end)
        end
    end
end

-- ============================================
-- GET AURA SCORE
-- ============================================
local function getAuraScore(toolName)
    for aura, score in pairs(RarityPriority) do
        if string.find(string.lower(toolName), string.lower(aura)) then
            return score
        end
    end
    return nil
end

local function findBestAuras()
    local found = {}

    for _, plrModel in ipairs(workspace:GetChildren()) do
        if plrModel.Name ~= lp.Name then
            local char = plrModel
            local backpack = plrModel:FindFirstChild("Backpack")

            local tool = char:FindFirstChildWhichIsA("Tool")
            if tool then
                local score = getAuraScore(tool.Name)
                if score then
                    table.insert(found, {player = plrModel.Name, tool = tool.Name, score = score})
                end
            end

            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        local score = getAuraScore(tool.Name)
                        if score then
                            table.insert(found, {player = plrModel.Name, tool = tool.Name, score = score})
                        end
                    end
                end
            end
        end
    end

    table.sort(found, function(a, b) return a.score > b.score end)

    for i = 1, math.min(2, #found) do
        Luna:Notification({ Title = "Best Aura", Content = found[i].tool .. "\nOwner: " .. found[i].player, Icon = "info", ImageSource = "Material" })
    end
end

-- ============================================
-- ANTI FLING LOOP
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
-- ANTI AFK LOOP
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
-- FLING FUNCTION
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
-- SNIPE AURA LOOP
-- ============================================
task.spawn(function()
    while true do
        task.wait()
        if not State.snipeToggle or #selectedTypes == 0 then continue end

        local character = lp.Character
        if not character then continue end

        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then continue end

        local found = false

        for _, v in ipairs(Workspace:GetChildren()) do
            if v:IsA("Tool") and not sniped[v] then
                local toolName = v.Name
                local lowerName = v.Name:lower()
                for _, type in ipairs(selectedTypes) do
                    if type ~= "" and lowerName:find(type:lower(), 1, true) then
                        local handle = v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart")
                        if handle then
                            rootPart.CFrame = handle.CFrame + Vector3.new(0, 1, 0)
                            sniped[v] = true
                            found = true
                            Luna:Notification({ Title = "Sniped", Content = toolName, Icon = "check", ImageSource = "Material" })
                            break
                        end
                    end
                end
                if found then break end
            end
        end
    end
end)

-- ============================================
-- TP TO RAINED AURA LOOP
-- ============================================
task.spawn(function()
    while true do
        task.wait()
        if not State.tpAuraExploit or not root then continue end

        for _, tool in ipairs(workspace:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "5" and not sniped[tool] then
                local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
                if handle then
                    root.CFrame = handle.CFrame + Vector3.new(0, 1, 0)
                    sniped[tool] = true
                    task.wait(0.1)
                end
            end
        end
    end
end)

-- ============================================
-- EQUIP BEST AURA LOOP
-- ============================================
local function isBetter(rarity1, stage1, rarity2, stage2)
    local StageOverrides = {
        ["Shimmer"] = { [5] = "Lightning" },
        ["Lightning"] = { [5] = "Pyronova" },
        ["Pyronova"] = { [4] = "Inferno" },
        ["Frost"] = { [5] = "Galatic" },
        ["Fairy"] = { [5] = "Frost" },
        ["Galatic"] = { [5] = "Shimmer" }
    }
    
    local overrides = StageOverrides[rarity1]
    if overrides and overrides[stage1] and rarity2 == overrides[stage1] then
        return true
    end
    local rank1 = RarityPriority[rarity1] or 0
    local rank2 = RarityPriority[rarity2] or 0
    if rank1 ~= rank2 then return rank1 > rank2 end
    return stage1 > stage2
end

local function getToolInfo(tool)
    local name = tool.Name
    local rarity, stage = name:match("^(%w+)%s%[STAGE%s(%d+)%]")
    if not rarity or not stage then return nil, 0 end
    return rarity, tonumber(stage)
end

local function equipBestTool(player)
    local backpack = player:FindFirstChild("Backpack")
    local char = player.Character
    if not backpack or not char then return end

    local bestTool, bestRarity, bestStage

    for _, container in ipairs({ backpack, char }) do
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                local rarity, stage = getToolInfo(tool)
                if rarity and (not bestTool or isBetter(rarity, stage, bestRarity, bestStage)) then
                    bestTool = tool
                    bestRarity = rarity
                    bestStage = stage
                end
            end
        end
    end

    if bestTool then
        local equippedTool = char:FindFirstChildOfClass("Tool")
        if equippedTool and equippedTool.Name ~= bestTool.Name then
            equippedTool.Parent = backpack
        end
        if not equippedTool or equippedTool.Name ~= bestTool.Name then
            bestTool.Parent = char
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        if State.bestToggle then
            for _, player in ipairs(Players:GetPlayers()) do
                pcall(function()
                    if player.Character then equipBestTool(player) end
                end)
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
local ExploitTab = Window:CreateTab({ Name = "Exploits", Icon = "cpu", ImageSource = "Material", ShowTitle = true })
local MiscTab = Window:CreateTab({ Name = "Misc", Icon = "more_horiz", ImageSource = "Material", ShowTitle = true })

-- Main Tab
MainTab:CreateParagraph({ Title = "AURA FARM", Text = "Pengaturan auto aura" })
MainTab:CreateToggle({ Name = "Equip Best Aura", CurrentValue = false, Callback = function(v) State.bestToggle = v end })
MainTab:CreateToggle({ Name = "Snipe Auras", CurrentValue = false, Callback = function(v) State.snipeToggle = v end })

local snipeTypeOptions = { "Contrast", "Volcanic", "Tesla", "Heart", "Spirit", "Cursed", "Fairy", "Frost", "Galatic", "Shimmer", "Lightning", "Pyronova", "Inferno", "Werewolf", "Bionic", "Divine" }
MainTab:CreateDropdown({ Name = "Snipe Type", Options = snipeTypeOptions, CurrentOption = {}, Multi = true, Callback = function(v) selectedTypes = v end })

MainTab:CreateButton({ Name = "Find Best Aura", Callback = function() findBestAuras() end })

-- Player Tab
PlayerTab:CreateParagraph({ Title = "PLAYER MODS", Text = "Modifikasi karakter" })
PlayerTab:CreateToggle({ Name = "Noclip", CurrentValue = false, Callback = function(v) State.noclipToggle = v; if v then noclip() else clip() end end })
PlayerTab:CreateToggle({ Name = "WalkSpeed Changer", CurrentValue = false, Callback = function(v) State.walkToggle = v end })
PlayerTab:CreateSlider({ Name = "WalkSpeed", Range = {16, 100}, Increment = 1, CurrentValue = 16, Callback = function(v) State.currentSpeed = v end })

-- Exploit Tab
ExploitTab:CreateParagraph({ Title = "EXPLOITS", Text = "Fitur exploit" })
ExploitTab:CreateButton({ Name = "Aura Rain (EXPLOIT)", Callback = function() rainUI() end })
ExploitTab:CreateToggle({ Name = "Teleport To Rained Aura", CurrentValue = false, Callback = function(v) State.tpAuraExploit = v end })

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
Luna:Notification({
    Title = "Mizukage System",
    Content = "Aura Trade loaded!",
    Icon = "verified",
    ImageSource = "Material"
})