-- ╔════════════════════════════════════════════════════════════════╗
-- ║ 👑 MIZUKAGE V14.3 - ULTIMATE TAS EXPLOIT (DYNAMIC CATEGORY)
-- ║ 🎮 TARGET   : Sore✨[Ava Gratis + Duyung] (111208180846561)
-- ║ ⚙️ ENGINE   : Cloud Hub Protocol & Ultimate TAS
-- ╚════════════════════════════════════════════════════════════════╝

if getgenv().MizuSoreLoaded then return end
getgenv().MizuSoreLoaded = true

--========================================================================
-- 1. GLOBAL CONFIGURATION & SERVICE DECLARATION
--========================================================================
local Services = setmetatable({}, { __index = function(t, k) return game:GetService(k) end })
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService
local VirtualUser = Services.VirtualUser
local UserInputService = Services.UserInputService
local LocalPlayer = Players.LocalPlayer

getgenv().MizuConfig = {
    IsRunning = true,
    
    -- Farm Settings
    AutoFarmFish = false,
    AutoSell = false,
    FarmDelay = 0.5,
    FarmMode = "Specific Fish", -- "Specific Fish", "Random By Category", "Random ALL"
    SelectedCategory = "Unknown",
    SelectedFish = "Ancient Relic Crocodile",
    
    -- Troll & Network
    AuraCast = false,
    SpamFakeChat = false,
    ChatSpamDelay = 2,
    SelectedRod = "Owner Rod",
    
    -- Player Mods
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false
}

-- Database Ekstraksi Murni Server
local FishDatabase = {
    -- Unknown (Mythic)
    {name = "Ancient Whale", rarity = "Unknown", minKg = 200, maxKg = 800},
    {name = "Ancient Relic Crocodile", rarity = "Unknown", minKg = 150, maxKg = 600},
    -- Legendary
    {name = "Plasma Shark", rarity = "Legendary", minKg = 80, maxKg = 400},
    -- Epic
    {name = "Pink Dolphin", rarity = "Epic", minKg = 40, maxKg = 300},
    {name = "Monster Shark", rarity = "Epic", minKg = 35, maxKg = 280},
    {name = "Loving Shark", rarity = "Epic", minKg = 30, maxKg = 250},
    {name = "Queen Crab", rarity = "Epic", minKg = 25, maxKg = 220},
    -- Rare
    {name = "Zombie Shark", rarity = "Rare", minKg = 20, maxKg = 150},
    {name = "Wraithfin Abyssal", rarity = "Rare", minKg = 15, maxKg = 140},
    {name = "Luminous Fish", rarity = "Rare", minKg = 12, maxKg = 130},
    {name = "Lion Fish", rarity = "Rare", minKg = 10, maxKg = 120},
    -- Uncommon
    {name = "Dead Spooky Koi Fish", rarity = "Uncommon", minKg = 5, maxKg = 80},
    {name = "Dead Scary Clownfish", rarity = "Uncommon", minKg = 4, maxKg = 75},
    {name = "Jellyfish", rarity = "Uncommon", minKg = 3, maxKg = 65},
    -- Common
    {name = "Goliath Tiger", rarity = "Common", minKg = 2, maxKg = 70},
    {name = "Pumpkin Carved Shark", rarity = "Common", minKg = 1, maxKg = 60},
    {name = "Freshwater Piranha", rarity = "Common", minKg = 1, maxKg = 60},
    {name = "Fangtooth", rarity = "Common", minKg = 1.5, maxKg = 55},
    {name = "Boar Fish", rarity = "Common", minKg = 0.5, maxKg = 50},
    {name = "Blackcap Basslet", rarity = "Common", minKg = 0.5, maxKg = 45},
    {name = "Hermit Crab", rarity = "Common", minKg = 0.8, maxKg = 40}
}

local FishNames = {}
for _, fish in ipairs(FishDatabase) do table.insert(FishNames, fish.name) end

local Categories = {"Unknown", "Legendary", "Epic", "Rare", "Uncommon", "Common"}
local FarmModes = {"Specific Fish", "Random By Category", "Random ALL"}

local RodDatabase = {
    "Basic Rod", "Angelic Rod", "Gold Rod", "Lucky Rod", "Lightning", "Polarized", 
    "Fluorescent Rod", "GhostRod", "Frozen Rod", "LightingPunk Rod", "Pirate Octopus",
    "Aqua Prism", "Flery", "Loving", "ZombieRod", "Forsaken", "Crystalized", "Earthly",
    "Manifest", "Megalofriend", "Purple Saber", "Katanaa", "Umbrella", "Developer Rod",
    "Admin Rod", "Owner Rod"
}

-- Remotes Mapping
local FishingSys = ReplicatedStorage:WaitForChild("FishingSystem")
local Remotes = {
    FishGiver = FishingSys:WaitForChild("FishGiver"),
    CastRep = FishingSys:WaitForChild("CastReplication"),
    CleanupCast = FishingSys:WaitForChild("CleanupCast"),
    SendChat = FishingSys:WaitForChild("SendChatMessage"),
    InvEvents = FishingSys:WaitForChild("InventoryEvents")
}
Remotes.SellAll = Remotes.InvEvents:WaitForChild("Inventory_SellAll")
Remotes.EquipRod = Remotes.InvEvents:WaitForChild("Inventory_EquipRod")
Remotes.UnequipAll = Remotes.InvEvents:WaitForChild("Inventory_UnequipAll")
Remotes.GetData = Remotes.InvEvents:WaitForChild("Inventory_GetData")

--========================================================================
-- 2. DYNAMIC RANDOMIZER & BYPASS LOGIC
--========================================================================
local function GenerateWeight(minKg, maxKg)
    local raw = minKg + (math.random() * (maxKg - minKg))
    return math.floor(raw * 10 + 0.5) / 10
end

local function GetSpecificFishData(name)
    for _, f in ipairs(FishDatabase) do
        if f.name == name then return f end
    end
    return FishDatabase[1]
end

local function GetRandomFishByCategory(category)
    local filtered = {}
    for _, f in ipairs(FishDatabase) do
        if f.rarity == category then
            table.insert(filtered, f)
        end
    end
    if #filtered == 0 then return FishDatabase[1] end
    return filtered[math.random(1, #filtered)]
end

local function GetRandomAllFish()
    return FishDatabase[math.random(1, #FishDatabase)]
end

local function DetermineFishDataToSpoof()
    local mode = getgenv().MizuConfig.FarmMode
    if mode == "Specific Fish" then
        return GetSpecificFishData(getgenv().MizuConfig.SelectedFish)
    elseif mode == "Random By Category" then
        return GetRandomFishByCategory(getgenv().MizuConfig.SelectedCategory)
    elseif mode == "Random ALL" then
        return GetRandomAllFish()
    end
    return FishDatabase[1]
end

local function ExecuteFishSpoof()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local fData = DetermineFishDataToSpoof()
    local HRP = LocalPlayer.Character.HumanoidRootPart
    local fakePos = HRP.Position + (HRP.CFrame.LookVector * 15) - Vector3.new(0, 5, 0)

    Remotes.FishGiver:FireServer({
        hookPosition = fakePos,
        rarity = fData.rarity,
        name = fData.name,
        weight = GenerateWeight(fData.minKg, fData.maxKg)
    })
end

local function SpoofAllFishOnce()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local HRP = LocalPlayer.Character.HumanoidRootPart
    local fakePos = HRP.Position + (HRP.CFrame.LookVector * 15) - Vector3.new(0, 5, 0)

    for _, fData in ipairs(FishDatabase) do
        Remotes.FishGiver:FireServer({
            hookPosition = fakePos,
            rarity = fData.rarity,
            name = fData.name,
            weight = GenerateWeight(fData.minKg, fData.maxKg)
        })
        task.wait(0.05)
    end
end

local function SendFakeChat()
    local fData = DetermineFishDataToSpoof()
    Remotes.SendChat:FireServer("General", LocalPlayer.Name, fData.name, GenerateWeight(fData.minKg, fData.maxKg), fData.rarity)
end

local angle = 0
local function ExecuteBobberAura()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local HRP = LocalPlayer.Character.HumanoidRootPart
    
    angle = angle + math.rad(25)
    local targetPos = HRP.Position + Vector3.new(math.cos(angle) * 15, 0, math.sin(angle) * 15)
    Remotes.CastRep:FireServer(LocalPlayer, targetPos, HRP.Position + Vector3.new(0, 5, 0), getgenv().MizuConfig.SelectedRod, 100)
end

--========================================================================
-- 3. THREADING & ANTI-AFK
--========================================================================
-- Auto Farm Loop
task.spawn(function()
    while getgenv().MizuConfig.IsRunning do
        if getgenv().MizuConfig.AutoFarmFish then ExecuteFishSpoof() end
        if getgenv().MizuConfig.AutoSell then 
            pcall(function() Remotes.SellAll:InvokeServer() end)
        end
        task.wait(getgenv().MizuConfig.FarmDelay)
    end
end)

-- Visual & LocalPlayer Mods Loop
task.spawn(function()
    RunService.RenderStepped:Connect(function()
        if not getgenv().MizuConfig.IsRunning then return end
        
        if getgenv().MizuConfig.AuraCast then ExecuteBobberAura() end
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local hum = LocalPlayer.Character.Humanoid
            if getgenv().MizuConfig.WalkSpeed > 16 then hum.WalkSpeed = getgenv().MizuConfig.WalkSpeed end
            if getgenv().MizuConfig.JumpPower > 50 then hum.JumpPower = getgenv().MizuConfig.JumpPower end
        end
    end)
end)

-- Chat Spammer Loop
task.spawn(function()
    while getgenv().MizuConfig.IsRunning do
        if getgenv().MizuConfig.SpamFakeChat then SendFakeChat() end
        task.wait(getgenv().MizuConfig.ChatSpamDelay)
    end
end)

-- Infinite Jump Logic
UserInputService.JumpRequest:Connect(function()
    if getgenv().MizuConfig.IsRunning and getgenv().MizuConfig.InfiniteJump then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

--========================================================================
-- 4. LUNA V2 UI RENDERING
--========================================================================
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()
local Window = Luna:CreateWindow({
    Name = "Mizukage Official", 
    Subtitle = "Sore✨[Ava Gratis + Duyung]", 
    LogoID = "104266190557772",
    LoadingEnabled = true, 
    LoadingTitle = "Mizukage System v14.3", 
    ConfigSettings = { ConfigFolder = "MizukageHub" }, 
    KeySystem = false
})

Window:CreateHomeTab({ SupportedExecutors = {"Delta", "Codex", "Wave", "Arceus X"}, DiscordInvite = "mizukage", Icon = 1 })

-- 🎣 TAB 1: FISHING OP
local FishTab = Window:CreateTab({ Name = "Auto Fishing", Icon = "anchor", ShowTitle = true })

FishTab:CreateSection("⚙️ Mode & Spoofer Database")
FishTab:CreateDropdown({
    Name = "Mode Auto Farm",
    Options = FarmModes,
    CurrentOption = {"Specific Fish"},
    MultipleOptions = false,
    Flag = "DropFarmMode",
    Callback = function(Opt) getgenv().MizuConfig.FarmMode = type(Opt) == "table" and Opt[1] or Opt end,
})

FishTab:CreateDropdown({
    Name = "Filter Kategori (Mode Random By Category)",
    Options = Categories,
    CurrentOption = {"Unknown"},
    MultipleOptions = false,
    Flag = "DropCategory",
    Callback = function(Opt) getgenv().MizuConfig.SelectedCategory = type(Opt) == "table" and Opt[1] or Opt end,
})

FishTab:CreateDropdown({
    Name = "Target Ikan (Mode Specific Fish)",
    Options = FishNames,
    CurrentOption = {"Ancient Relic Crocodile"},
    MultipleOptions = false,
    Flag = "DropFish",
    Callback = function(Opt) getgenv().MizuConfig.SelectedFish = type(Opt) == "table" and Opt[1] or Opt end,
})

FishTab:CreateSlider({
    Name = "Kecepatan Tarikan (x10 ms)",
    Range = {1, 30}, 
    Increment = 1,
    CurrentValue = 5,
    Flag = "SliderSpeed",
    Callback = function(Value) getgenv().MizuConfig.FarmDelay = (Value / 10) end,
})

FishTab:CreateDivider()
FishTab:CreateSection("🔄 Mode Full Otomatis")
FishTab:CreateToggle({ Name = "🐟 Aktifkan Auto Farm Memancing", CurrentValue = false, Callback = function(V) getgenv().MizuConfig.AutoFarmFish = V end }, "TglAutoF")
FishTab:CreateToggle({ Name = "💰 Aktifkan Auto Sell Instan", CurrentValue = false, Callback = function(V) getgenv().MizuConfig.AutoSell = V end }, "TglAutoS")

FishTab:CreateDivider()
FishTab:CreateSection("⚡ Eksekusi Manual")
FishTab:CreateButton({ Name = "🎣 Pancing 1x Instan (Sesuai Mode)", Callback = function() ExecuteFishSpoof(); Luna:Notification({Title="Mizu-OS", Content="Ikan ditarik!", Duration=2}) end })
FishTab:CreateButton({ Name = "🐟 Ambil Semua Database Ikan (1x All)", Callback = function() task.spawn(SpoofAllFishOnce); Luna:Notification({Title="Mizu-OS", Content="Mengeksekusi semua ID ikan...", Duration=2}) end })
FishTab:CreateButton({ Name = "💰 Jual Semua Ikan Sekarang", Callback = function() Remotes.SellAll:InvokeServer(); Luna:Notification({Title="Mizu-OS", Content="Ikan Terjual!", Duration=2}) end })

-- 🎒 TAB 2: INVENTORY
local InvTab = Window:CreateTab({ Name = "Inventory", Icon = "backpack", ShowTitle = true })

InvTab:CreateSection("🎒 Equipment Manager")
InvTab:CreateDropdown({
    Name = "Force Equip Rod (Bypass Unlocked)",
    Options = RodDatabase,
    CurrentOption = {"Owner Rod"},
    MultipleOptions = false,
    Flag = "DropRod",
    Callback = function(Opt) getgenv().MizuConfig.SelectedRod = type(Opt) == "table" and Opt[1] or Opt end,
})

InvTab:CreateButton({ Name = "Pegang Pancingan Sekarang", Callback = function() Remotes.EquipRod:FireServer(getgenv().MizuConfig.SelectedRod); Remotes.GetData:InvokeServer() end })
InvTab:CreateButton({ Name = "Lepas Semua Alat", Callback = function() Remotes.UnequipAll:FireServer() end })

-- 🌐 TAB 3: NETWORK TROLL
local TrollTab = Window:CreateTab({ Name = "Network Troll", Icon = "skull", ShowTitle = true })

TrollTab:CreateSection("🌐 Server Abuser")
TrollTab:CreateToggle({ Name = "🛑 Bobber Aura (Spam Posisi Kail Server-Side)", CurrentValue = false, Callback = function(V) getgenv().MizuConfig.AuraCast = V end }, "TglAura")
TrollTab:CreateToggle({ Name = "🛑 Spam Global Fake Catch (Sesuai Mode)", CurrentValue = false, Callback = function(V) getgenv().MizuConfig.SpamFakeChat = V end }, "TglSpamChat")

TrollTab:CreateSlider({
    Name = "Jeda Spam Chat (Detik)",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 2,
    Flag = "SliderChat",
    Callback = function(Value) getgenv().MizuConfig.ChatSpamDelay = Value end,
})

TrollTab:CreateButton({ Name = "📢 Broadcast 1x Chat Palsu", Callback = function() SendFakeChat() end })
TrollTab:CreateButton({ Name = "♻️ Reset Error Kail (Cleanup)", Callback = function() Remotes.CleanupCast:FireServer() end })

-- 🏃 TAB 4: PLAYER MODS
local PlayerTab = Window:CreateTab({ Name = "LocalPlayer", Icon = "user", ShowTitle = true })
PlayerTab:CreateSection("🏃 Modifikasi Fisik")
PlayerTab:CreateToggle({ Name = "🚀 Infinite Jump (Terbang Bebas)", CurrentValue = false, Callback = function(V) getgenv().MizuConfig.InfiniteJump = V end }, "TglInfJ")

PlayerTab:CreateSlider({
    Name = "WalkSpeed Custom",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Flag = "SliderWS",
    Callback = function(Value) getgenv().MizuConfig.WalkSpeed = Value end,
})

PlayerTab:CreateSlider({
    Name = "JumpPower Custom",
    Range = {50, 200},
    Increment = 1,
    CurrentValue = 50,
    Flag = "SliderJP",
    Callback = function(Value) getgenv().MizuConfig.JumpPower = Value end,
})

-- 🎨 TAB 5: THEME & CONFIG
Window:CreateTab({ Name = "Theme", Icon = "palette", ShowTitle = true }):BuildThemeSection()
local ConfigTab = Window:CreateTab({ Name = "Config", Icon = "settings", ShowTitle = true })
ConfigTab:BuildConfigSection()

ConfigTab:CreateButton({ 
    Name = "🛑 Hancurkan GUI", 
    Callback = function() 
        getgenv().MizuConfig.IsRunning = false
        getgenv().MizuSoreLoaded = false
        Luna:Destroy() 
    end 
})

Luna:Notification({ Title = "Mizu-OS v14.3", Content = "Ultimate Randomizer Modules Loaded!", Duration = 3 })