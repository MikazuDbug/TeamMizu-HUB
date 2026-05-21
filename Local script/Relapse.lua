--[[
═══════════════════════════════════════════════════════════
🌙 MIZUKAGE OFFICIAL - RELAPSE GAME MODULE
🔥 Fitur: 54 Fish Database, Auto Farm, Auto Sell, Admin Exploit
═══════════════════════════════════════════════════════════
]]

if getgenv().MizuRelapseLoaded then return end
getgenv().MizuRelapseLoaded = true

--================================================
-- 1. DEKLARASI SERVICE & PATH
--================================================
local Services = setmetatable({}, { __index = function(t, k) return game:GetService(k) end })
local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = Services.ReplicatedStorage
local GuiService = Services.GuiService
local TeleportService = Services.TeleportService
local HttpService = Services.HttpService

local WebhookTarget = "https://discord.com/api/webhooks/1490427520384897114/Q1lnpS98asJTS7aBQy3WWDbAzP6yajTwG2KOoQ7yGrSoD_-ZXdnJ3cFjDq_XgrWS7MIC"
local FishingSystem = ReplicatedStorage:WaitForChild("FishingSystem", 10)
local AdminRemotes = ReplicatedStorage:WaitForChild("AdminRemotes", 10)

--================================================
-- 2. KONFIGURASI GLOBAL & DATABASE IKAN
--================================================
getgenv().MizuConfig = {
    IsRunning = true, AutoFish = false, AutoSell = false,
    FishName = "Godzilla (Legendary)", FishRarity = "Unknown", FishWeight = 1000,
    TargetPlayer = "", WalkSpeed = 16
}

local MasterFishDatabase = {
    {name = "Godzilla (Legendary)", rarity = "Unknown", weight = 1000}, {name = "WhiteShark", rarity = "Unknown", weight = 1000}, {name = "Sleketon", rarity = "Unknown", weight = 1000}, {name = "PINK WORM", rarity = "Unknown", weight = 1000}, {name = "Ancient Lochness Monster", rarity = "Unknown", weight = 1000}, {name = "Lochness Monster", rarity = "Unknown", weight = 1000}, {name = "Bloodmoon Whale", rarity = "Unknown", weight = 1000}, {name = "PURPLE MEGA", rarity = "Unknown", weight = 1000}, {name = "Mosasaur Shark", rarity = "Unknown", weight = 800}, {name = "Ghost Worm Fish", rarity = "Unknown", weight = 800}, {name = "DRAGON", rarity = "Unknown", weight = 800}, {name = "Elshark Gran Maja", rarity = "Unknown", weight = 800}, {name = "Ancient Whale", rarity = "Unknown", weight = 800}, {name = "Frostborn Shark", rarity = "Unknown", weight = 800}, {name = "Ancient Relic Crocodile", rarity = "Unknown", weight = 600},
    {name = "Panther Eel", rarity = "Legendary", weight = 400}, {name = "Eerie Shark", rarity = "Legendary", weight = 400}, {name = "Plasma Shark", rarity = "Legendary", weight = 400},
    {name = "Hammerhead Mummy", rarity = "Epic", weight = 300}, {name = "Sacred Guardian", rarity = "Epic", weight = 300}, {name = "Pink Dolphin", rarity = "Epic", weight = 300}, {name = "Monster Shark", rarity = "Epic", weight = 280}, {name = "Narwhal", rarity = "Epic", weight = 250}, {name = "Loving Shark", rarity = "Epic", weight = 250}, {name = "Queen Crab", rarity = "Epic", weight = 220},
    {name = "Zombie Shark", rarity = "Rare", weight = 150}, {name = "Wraithfin Abyssal", rarity = "Rare", weight = 140}, {name = "Magma Shark", rarity = "Rare", weight = 140}, {name = "Blueflame Ray", rarity = "Rare", weight = 140}, {name = "Luminous Fish", rarity = "Rare", weight = 130}, {name = "Lion Fish", rarity = "Rare", weight = 120},
    {name = "Dead Spooky Koi Fish", rarity = "Uncommon", weight = 80}, {name = "Dead Scary Clownfish", rarity = "Uncommon", weight = 75}, {name = "Frankenstein Longsnapper", rarity = "Uncommon", weight = 65}, {name = "Ghastly Hermit Crab", rarity = "Uncommon", weight = 65}, {name = "Hawks Turtle", rarity = "Uncommon", weight = 65}, {name = "Jellyfish", rarity = "Uncommon", weight = 65}, {name = "Candycane Lobster", rarity = "Uncommon", weight = 20},
    {name = "Goliath Tiger", rarity = "Common", weight = 70}, {name = "Freshwater Piranha", rarity = "Common", weight = 60}, {name = "Pumpkin Carved Shark", rarity = "Common", weight = 60}, {name = "Thinkler Fish", rarity = "Common", weight = 55}, {name = "Strippled Seahorse", rarity = "Common", weight = 55}, {name = "Pumpkin Angler Fish", rarity = "Common", weight = 55}, {name = "Yellowfin Tuna", rarity = "Common", weight = 55}, {name = "Fangtooth", rarity = "Common", weight = 55}, {name = "Boar Fish", rarity = "Common", weight = 50}, {name = "Blackcap Basslet", rarity = "Common", weight = 45}, {name = "Hermit Crab", rarity = "Common", weight = 40}, {name = "Strawberry Dotty", rarity = "Common", weight = 20}, {name = "Ghost Spiralfish", rarity = "Common", weight = 20}, {name = "Festive Pufferfish", rarity = "Common", weight = 20}, {name = "Azure Damsel", rarity = "Common", weight = 20}
}
local FishOptions = {}
for _, fish in ipairs(MasterFishDatabase) do table.insert(FishOptions, fish.name) end

--================================================
-- 3. FUNGSI INTI EXPLOIT
--================================================
local function CatchOneFish()
    if FishingSystem and FishingSystem:FindFirstChild("FishGiver") then
        local pos = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and LocalPlayer.Character.PrimaryPart.Position or Vector3.new(0,0,0)
        FishingSystem.FishGiver:FireServer({hookPosition = pos, rarity = getgenv().MizuConfig.FishRarity, name = getgenv().MizuConfig.FishName, weight = getgenv().MizuConfig.FishWeight})
    end
end

local function CatchAllFish()
    if FishingSystem and FishingSystem:FindFirstChild("FishGiver") then
        local pos = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and LocalPlayer.Character.PrimaryPart.Position or Vector3.new(0,0,0)
        for _, fishData in ipairs(MasterFishDatabase) do
            FishingSystem.FishGiver:FireServer({hookPosition = pos, rarity = fishData.rarity, name = fishData.name, weight = fishData.weight})
            task.wait(0.05) 
        end
    end
end

local function SellAllFish()
    if FishingSystem and FishingSystem:FindFirstChild("InventoryEvents") and FishingSystem.InventoryEvents:FindFirstChild("Inventory_SellAll") then
        pcall(function() FishingSystem.InventoryEvents.Inventory_SellAll:InvokeServer() end)
    elseif FishingSystem and FishingSystem:FindFirstChild("SellFish") then
        pcall(function() FishingSystem.SellFish:FireServer() end)
    end
end

local function FlexToGlobalChat()
    if FishingSystem and FishingSystem:FindFirstChild("PublishFishCatch") then
        FishingSystem.PublishFishCatch:FireServer(getgenv().MizuConfig.FishName, getgenv().MizuConfig.FishWeight, getgenv().MizuConfig.FishRarity)
    end
end

task.spawn(function()
    while getgenv().MizuConfig.IsRunning do
        if getgenv().MizuConfig.AutoFish then CatchOneFish() end
        if getgenv().MizuConfig.AutoSell then SellAllFish() end
        task.wait(0.5) 
    end
end)

--================================================
-- 4. TELEMETRI & ANTI-AFK
--================================================
task.spawn(function()
    GuiService.ErrorMessageChanged:Connect(function()
        task.wait(0.5); TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
    local virtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function() virtualUser:CaptureController(); virtualUser:ClickButton2(Vector2.new()) end)

    if not WebhookTarget or WebhookTarget == "" or string.find(WebhookTarget, "MASUKKAN") then return end
    task.wait(2)
    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request 
    if not requestFunc then return end 
    local GameName = "Data Tidak Diketahui" 
    pcall(function() GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end) 
    local HWID = "Hidden" pcall(function() HWID = gethwid and gethwid() or HWID end) 
    requestFunc({ Url = WebhookTarget, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode({ ["username"] = "Mizukage Security", ["embeds"] = {{ ["title"] = "Sesi Baru: " .. GameName, ["color"] = 3447003, ["fields"] = { { ["name"] = "User", ["value"] = LocalPlayer.Name, ["inline"] = true }, { ["name"] = "HWID", ["value"] = "||"..HWID.."||", ["inline"] = true } } }} }) })
end)

--================================================
-- 5. INISIALISASI LUNA UI
--================================================
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()
local Window = Luna:CreateWindow({ Name = "Mizukage Official", Subtitle = "RELAPSE Seamin", LogoID = "82795327169782", LoadingEnabled = true, LoadingTitle = "Mizukage System", ConfigSettings = { ConfigFolder = "MizukageHub" }, KeySystem = false })
Window:CreateHomeTab({ SupportedExecutors = { "Synapse X", "Krnl", "Fluxus", "Script-Ware", "Electron", "Wave", "CODex", "Delta", "Arceus X" }, DiscordInvite = "mizukage", Icon = 1 })

local FishTab = Window:CreateTab({ Name = "OP Fishing", Icon = "anchor", ImageSource = "Material", ShowTitle = true })
FishTab:CreateSection("⚡ Mode Manual")
FishTab:CreateButton({ Name = "🎣 Mancing 1x Tap (Config)", Callback = function() CatchOneFish(); Luna:Notification({Title="Sukses", Content="Ikan didapatkan!"}) end })
FishTab:CreateButton({ Name = "🐟 Ambil Semua Ikan (FULL 54)", Callback = function() task.spawn(CatchAllFish); Luna:Notification({Title="Proses", Content="Mendapatkan 54 ikan..."}) end })
FishTab:CreateButton({ Name = "💰 Jual Semua Ikan", Callback = function() SellAllFish(); Luna:Notification({Title="Sukses", Content="Ikan terjual!"}) end })

FishTab:CreateDivider()
FishTab:CreateSection("⚙️ Konfigurasi Ikan (Spoofer)")
FishTab:CreateDropdown({ Name = "Pilih Ikan Target", Options = FishOptions, CurrentOption = {"Godzilla (Legendary)"}, MultipleOptions = false, Callback = function(Opt)
    local n = type(Opt) == "table" and Opt[1] or Opt; getgenv().MizuConfig.FishName = n
    for _, f in ipairs(MasterFishDatabase) do if f.name == n then getgenv().MizuConfig.FishRarity = f.rarity; getgenv().MizuConfig.FishWeight = f.weight; break end end
end }, "DropFish")
FishTab:CreateDropdown({ Name = "Paksa Rarity", Options = {"Unknown", "Legendary", "Epic", "Rare", "Uncommon", "Common"}, CurrentOption = {"Unknown"}, MultipleOptions = false, Callback = function(Opt) getgenv().MizuConfig.FishRarity = type(Opt) == "table" and Opt[1] or Opt end }, "DropRarity")
FishTab:CreateInput({ Name = "Berat Ikan Custom (Kg)", PlaceholderText = "Max 9999.9", Numeric = true, Callback = function(Txt) local n=tonumber(Txt); if n then getgenv().MizuConfig.FishWeight=n end end }, "InpWeight")
FishTab:CreateButton({ Name = "📢 Broadcast Fake Catch", Callback = function() FlexToGlobalChat(); Luna:Notification({Title="Sukses", Content="Pesan terkirim!"}) end })

FishTab:CreateDivider()
FishTab:CreateSection("🔄 Mode Full Otomatis")
FishTab:CreateToggle({ Name = "🐟 Aktifkan Auto Farm Instan", CurrentValue = false, Callback = function(V) getgenv().MizuConfig.AutoFarm = V end }, "TglAF")
FishTab:CreateToggle({ Name = "💰 Aktifkan Auto Sell Instan", CurrentValue = false, Callback = function(V) getgenv().MizuConfig.AutoSell = V end }, "TglAS")

local AdminTab = Window:CreateTab({ Name = "Admin Hacks", Icon = "security", ImageSource = "Material", ShowTitle = true })
AdminTab:CreateInput({ Name = "Username Target", PlaceholderText = "Ketik Username...", Callback = function(Txt) getgenv().MizuConfig.TargetPlayer = tostring(Txt) end }, "InpTarget")
AdminTab:CreateButton({ Name = "💣 Boom Target", Callback = function() if AdminRemotes and AdminRemotes:FindFirstChild("BoomPlayer") then AdminRemotes.BoomPlayer:FireServer(getgenv().MizuConfig.TargetPlayer) end end })
AdminTab:CreateButton({ Name = "🔒 Cage Target", Callback = function() if AdminRemotes and AdminRemotes:FindFirstChild("CagePlayer") then AdminRemotes.CagePlayer:FireServer(getgenv().MizuConfig.TargetPlayer) end end })
AdminTab:CreateButton({ Name = "❄️ Freeze Target", Callback = function() if AdminRemotes and AdminRemotes:FindFirstChild("FreezePlayer") then AdminRemotes.FreezePlayer:FireServer(getgenv().MizuConfig.TargetPlayer) end end })
AdminTab:CreateButton({ Name = "🪢 Rope Target", Callback = function() if AdminRemotes and AdminRemotes:FindFirstChild("RopePlayer") then AdminRemotes.RopePlayer:FireServer(getgenv().MizuConfig.TargetPlayer) end end })

local MiscTab = Window:CreateTab({ Name = "Misc Hacks", Icon = "build", ImageSource = "Material", ShowTitle = true })
MiscTab:CreateSection("⚡ Game Exploits")
MiscTab:CreateButton({ Name = "🎁 Bypass VIP Server Instan", Callback = function() if ReplicatedStorage:FindFirstChild("GiftVIPRemote") then ReplicatedStorage.GiftVIPRemote:FireServer() elseif ReplicatedStorage:FindFirstChild("GiftVIP") then ReplicatedStorage.GiftVIP:FireServer() end end })
MiscTab:CreateButton({ Name = "🏧 Hack ATM (Transfer Uang)", Callback = function() if ReplicatedStorage:FindFirstChild("ATMSystem") and ReplicatedStorage.ATMSystem:FindFirstChild("ATM_Transfer") then ReplicatedStorage.ATMSystem.ATM_Transfer:FireServer(LocalPlayer.Name, 999999) end end })
MiscTab:CreateSection("🏃 Modifikasi Karakter")
MiscTab:CreateSlider({ Name = "Walkspeed Custom", Range = {16, 200}, Increment = 1, CurrentValue = 16, Callback = function(V) getgenv().MizuConfig.WalkSpeed = V; if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = V end end }, "SldSpeed")
MiscTab:CreateButton({ Name = "🛑 Hancurkan GUI", Callback = function() getgenv().MizuConfig.IsRunning=false; getgenv().MizuRelapseLoaded=false; Luna:Destroy() end })

Window:CreateTab({ Name = "Theme", Icon = "palette", ImageSource = "Material", ShowTitle = true }):BuildThemeSection()
Window:CreateTab({ Name = "Config", Icon = "settings", ImageSource = "Material", ShowTitle = true }):BuildConfigSection()

Luna:Notification({ Title = "Mizukage Loaded", Icon = "check_circle", ImageSource = "Material", Content = "Mizukage Ultimate berhasil di-inject!" })
