-- ╔════════════════════════════════════════════════════════════════╗
-- ║ 👑 MIZUKAGE V14.0 - ULTIMATE TAS EXPLOIT (LUNA INTERFACE)
-- ║ 🎮 TARGET   : Sore✨[Ava Gratis + Duyung] (111208180846561)
-- ║ ⚙️ ENGINE   : Cloud Hub Protocol & Ultimate TAS (Sync: TRUE)
-- ╚════════════════════════════════════════════════════════════════╝

--========================================================================
-- [MODUL 1] GLOBAL CONFIGURATION & SERVICE DECLARATION
--========================================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

getgenv().MizuConfig = {
    IsRunning = true,
    -- Farm Settings
    AutoFarmFish = false,
    AutoSell = false,
    FarmDelay = 0.5,
    SelectedFish = "Ancient Relic Crocodile",
    -- Troll & Network Settings
    AuraCast = false,
    SpamFakeChat = false,
    ChatSpamDelay = 2,
    -- Inventory Settings
    SelectedRod = "Owner Rod"
}

-- Database Ekstraksi (Sync: FishingConfig Dump)
local FishDatabase = {
    -- [COMMON]
    ["Boar Fish"] = { Rarity = "Common", minKg = 0.5, maxKg = 50 },
    ["Blackcap Basslet"] = { Rarity = "Common", minKg = 0.5, maxKg = 45 },
    ["Pumpkin Carved Shark"] = { Rarity = "Common", minKg = 1, maxKg = 60 },
    ["Freshwater Piranha"] = { Rarity = "Common", minKg = 1, maxKg = 60 },
    ["Hermit Crab"] = { Rarity = "Common", minKg = 0.8, maxKg = 40 },
    ["Goliath Tiger"] = { Rarity = "Common", minKg = 2, maxKg = 70 },
    ["Fangtooth"] = { Rarity = "Common", minKg = 1.5, maxKg = 55 },
    -- [UNCOMMON]
    ["Dead Spooky Koi Fish"] = { Rarity = "Uncommon", minKg = 5, maxKg = 80 },
    ["Dead Scary Clownfish"] = { Rarity = "Uncommon", minKg = 4, maxKg = 75 },
    ["Jellyfish"] = { Rarity = "Uncommon", minKg = 3, maxKg = 65 },
    -- [RARE]
    ["Lion Fish"] = { Rarity = "Rare", minKg = 10, maxKg = 120 },
    ["Luminous Fish"] = { Rarity = "Rare", minKg = 12, maxKg = 130 },
    ["Zombie Shark"] = { Rarity = "Rare", minKg = 20, maxKg = 150 },
    ["Wraithfin Abyssal"] = { Rarity = "Rare", minKg = 15, maxKg = 140 },
    -- [EPIC]
    ["Loving Shark"] = { Rarity = "Epic", minKg = 30, maxKg = 250 },
    ["Monster Shark"] = { Rarity = "Epic", minKg = 35, maxKg = 280 },
    ["Queen Crab"] = { Rarity = "Epic", minKg = 25, maxKg = 220 },
    ["Pink Dolphin"] = { Rarity = "Epic", minKg = 40, maxKg = 300 },
    -- [LEGENDARY]
    ["Plasma Shark"] = { Rarity = "Legendary", minKg = 80, maxKg = 400 },
    -- [UNKNOWN / MYTHIC]
    ["Ancient Relic Crocodile"] = { Rarity = "Unknown", minKg = 150, maxKg = 600 },
    ["Ancient Whale"] = { Rarity = "Unknown", minKg = 200, maxKg = 800 }
}

local FishNames = {}
for name, _ in pairs(FishDatabase) do table.insert(FishNames, name) end

local RodDatabase = {
    "Basic Rod", "Angelic Rod", "Gold Rod", "Lucky Rod", "Lightning", "Polarized", 
    "Fluorescent Rod", "GhostRod", "Frozen Rod", "LightingPunk Rod", "Pirate Octopus",
    "Aqua Prism", "Flery", "Loving", "ZombieRod", "Forsaken", "Crystalized", "Earthly",
    "Manifest", "Megalofriend", "Purple Saber", "Katanaa", "Umbrella", "Developer Rod",
    "Admin Rod", "Owner Rod"
}

-- Mapping Remotes
local Remotes = {
    FishSys = ReplicatedStorage:WaitForChild("FishingSystem"),
}
Remotes.FishGiver = Remotes.FishSys:WaitForChild("FishGiver")
Remotes.CastRep = Remotes.FishSys:WaitForChild("CastReplication")
Remotes.CleanupCast = Remotes.FishSys:WaitForChild("CleanupCast")
Remotes.SendChat = Remotes.FishSys:WaitForChild("SendChatMessage")

local InvEvents = Remotes.FishSys:WaitForChild("InventoryEvents")
Remotes.SellAll = InvEvents:WaitForChild("Inventory_SellAll")
Remotes.EquipRod = InvEvents:WaitForChild("Inventory_EquipRod")
Remotes.UnequipAll = InvEvents:WaitForChild("Inventory_UnequipAll")
Remotes.GetData = InvEvents:WaitForChild("Inventory_GetData")

--========================================================================
-- [MODUL 2] CORE EXPLOIT LOGIC (BYPASS ALGORITHMS)
--========================================================================

local function GenerateWeight(minKg, maxKg)
    -- Generates exact server-sided random weight formula simulation (1 Decimal)
    local randomRaw = minKg + (math.random() * (maxKg - minKg))
    return math.floor(randomRaw * 10 + 0.5) / 10
end

local function ExecuteFishSpoof()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local fishData = FishDatabase[getgenv().MizuConfig.SelectedFish]
    local randomWeight = GenerateWeight(fishData.minKg, fishData.maxKg)

    -- Vector spoofing to bypass distance checks if applicable
    local HRP = LocalPlayer.Character.HumanoidRootPart
    local fakeHookPos = HRP.Position + (HRP.CFrame.LookVector * 15) - Vector3.new(0, 5, 0)

    local payload = {
        [1] = {
            hookPosition = fakeHookPos,
            rarity = fishData.Rarity,
            name = getgenv().MizuConfig.SelectedFish,
            weight = randomWeight
        }
    }
    Remotes.FishGiver:FireServer(unpack(payload))
end

local function ExecuteFakeChatAnnouncement()
    local fishData = FishDatabase[getgenv().MizuConfig.SelectedFish]
    local fakeWeight = GenerateWeight(fishData.minKg, fishData.maxKg)
    
    local args = {
        [1] = "General",
        [2] = LocalPlayer.Name,
        [3] = getgenv().MizuConfig.SelectedFish,
        [4] = fakeWeight,
        [5] = fishData.Rarity
    }
    Remotes.SendChat:FireServer(unpack(args))
end

local angle = 0
local function ExecuteBobberAura()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local HRP = LocalPlayer.Character.HumanoidRootPart
    
    angle = angle + math.rad(25)
    local radius = 15
    local targetPos = HRP.Position + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
    local originPos = HRP.Position + Vector3.new(0, 5, 0)
    
    local args = {
        [1] = LocalPlayer,
        [2] = targetPos,
        [3] = originPos,
        [4] = getgenv().MizuConfig.SelectedRod,
        [5] = 100 -- Max Power
    }
    Remotes.CastRep:FireServer(unpack(args))
end

--========================================================================
-- [MODUL 3] THREADING & AUTOMATION LOOP (GODSPEED OPTIMIZED)
--========================================================================

task.spawn(function()
    while getgenv().MizuConfig.IsRunning do
        if getgenv().MizuConfig.AutoFarmFish then
            ExecuteFishSpoof()
        end
        if getgenv().MizuConfig.AutoSell then
            task.wait(0.1) -- Limit rate agar tidak lag parah saat SellAll
            Remotes.SellAll:InvokeServer()
        end
        task.wait(getgenv().MizuConfig.FarmDelay)
    end
end)

task.spawn(function()
    RunService.RenderStepped:Connect(function()
        if getgenv().MizuConfig.IsRunning and getgenv().MizuConfig.AuraCast then
            ExecuteBobberAura()
        end
    end)
end)

task.spawn(function()
    while getgenv().MizuConfig.IsRunning do
        if getgenv().MizuConfig.SpamFakeChat then
            ExecuteFakeChatAnnouncement()
        end
        task.wait(getgenv().MizuConfig.ChatSpamDelay)
    end
end)

--========================================================================
-- [MODUL 4] LUNA INTERFACE SUITE (UI RENDER)
--========================================================================
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

local Window = Luna:CreateWindow({
    Name = "Mizukage Official", 
    Subtitle = "Sore✨[Ava Gratis + Duyung]", 
    LogoID = "104266190557772",
    LoadingEnabled = true, 
    LoadingTitle = "Mizukage System v14.0", 
    ConfigSettings = { ConfigFolder = "MizukageHub" }, 
    KeySystem = false
})

Window:CreateHomeTab({ 
    SupportedExecutors = {"Delta", "Codex", "Wave", "Arceus X"}, 
    DiscordInvite = "Mizukage-Official", 
    Icon = 1 
})

-- TAB 1: AUTO FARM
local FarmTab = Window:CreateTab({ Name = "Auto Farm", Icon = "swords", ImageSource = "Material", ShowTitle = true })

FarmTab:CreateDropdown({
    Name = "Select Target Fish",
    Options = FishNames,
    CurrentOption = getgenv().MizuConfig.SelectedFish,
    MultipleOptions = false,
    Flag = "DropFish",
    Callback = function(Option) getgenv().MizuConfig.SelectedFish = Option[1] end,
})

FarmTab:CreateSlider({
    Name = "Spoofer Speed (Seconds)",
    Range = {0.1, 3},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = getgenv().MizuConfig.FarmDelay,
    Flag = "SliderDelay",
    Callback = function(Value) getgenv().MizuConfig.FarmDelay = Value end,
})

FarmTab:CreateToggle({ 
    Name = "Enable Auto Farm (Spoof Logic)", 
    CurrentValue = false, 
    Callback = function(Value) getgenv().MizuConfig.AutoFarmFish = Value end 
}, "TglAutoFarm")

FarmTab:CreateToggle({ 
    Name = "Auto Sell Fish", 
    CurrentValue = false, 
    Callback = function(Value) getgenv().MizuConfig.AutoSell = Value end 
}, "TglAutoSell")

-- TAB 2: INVENTORY & TOOL
local InvTab = Window:CreateTab({ Name = "Inventory", Icon = "backpack", ImageSource = "Material", ShowTitle = true })

InvTab:CreateDropdown({
    Name = "Select Rod to Equip",
    Options = RodDatabase,
    CurrentOption = getgenv().MizuConfig.SelectedRod,
    MultipleOptions = false,
    Flag = "DropRod",
    Callback = function(Option) getgenv().MizuConfig.SelectedRod = Option[1] end,
})

InvTab:CreateButton({ 
    Name = "Force Equip Selected Rod", 
    Callback = function() 
        Remotes.EquipRod:FireServer(getgenv().MizuConfig.SelectedRod)
        Remotes.GetData:InvokeServer()
        Luna:Notification({Title = "Mizu-OS", Icon = "check", Content = "Rod Force Equipped!", Duration = 3})
    end 
})

InvTab:CreateButton({ 
    Name = "Unequip All Tools", 
    Callback = function() Remotes.UnequipAll:FireServer() end 
})

-- TAB 3: NETWORK TROLL & EXPLOITS
local TrollTab = Window:CreateTab({ Name = "Network Troll", Icon = "skull", ImageSource = "Material", ShowTitle = true })

TrollTab:CreateToggle({ 
    Name = "Bobber Aura (Spam Server-Side Visual)", 
    CurrentValue = false, 
    Callback = function(Value) getgenv().MizuConfig.AuraCast = Value end 
}, "TglAura")

TrollTab:CreateToggle({ 
    Name = "Spam Fake Catch (Global Broadcast)", 
    CurrentValue = false, 
    Callback = function(Value) getgenv().MizuConfig.SpamFakeChat = Value end 
}, "TglFakeChat")

TrollTab:CreateSlider({
    Name = "Global Chat Spam Delay",
    Range = {1, 10},
    Increment = 0.5,
    Suffix = "s",
    CurrentValue = getgenv().MizuConfig.ChatSpamDelay,
    Flag = "SliderChatDelay",
    Callback = function(Value) getgenv().MizuConfig.ChatSpamDelay = Value end,
})

TrollTab:CreateButton({ 
    Name = "Cleanup My Casts (Server Reset)", 
    Callback = function() Remotes.CleanupCast:FireServer() end 
})

-- TAB 4: THEME & CONFIG
Window:CreateTab({ Name = "Theme", Icon = "palette", ImageSource = "Material", ShowTitle = true }):BuildThemeSection()

local ConfigTab = Window:CreateTab({ Name = "Config", Icon = "settings", ImageSource = "Material", ShowTitle = true })
ConfigTab:BuildConfigSection()

ConfigTab:CreateButton({ 
    Name = "Shutdown Script", 
    Callback = function() 
        getgenv().MizuConfig.IsRunning = false
        Luna:Destroy() 
    end 
})
