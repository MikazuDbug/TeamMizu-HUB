--[[═══════════════════════════════════════════════════════════
🌊 MIZUKAGE OFFICIAL - CLOUD HUB SCRIPT
Target: KARTA SUNDA - Ruang Riung
Place ID: 131848958487439
Engine: Mizu-OS v14.0 | Luna Interface Suite
Status: UNDETECTED | FISHING GLITCH ACTIVE
═══════════════════════════════════════════════════════════]]

if getgenv().MizuKartaLoaded then
    return game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Mizukage Cloud Hub",
        Text = "Sistem sudah beroperasi di memori!",
        Duration = 3
    })
end
getgenv().MizuKartaLoaded = true

--================================================
-- 1. DEKLARASI SERVICE
--================================================
local Services = setmetatable({}, {
    __index = function(t, k)
        local s = game:GetService(k)
        t[k] = s
        return s
    end
})

local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = Services.ReplicatedStorage
local Workspace = Services.Workspace
local Backpack = LocalPlayer:WaitForChild("Backpack")

--================================================
-- 2. DEKLARASI REMOTES (ANTI-CRASH)
--================================================
local Remotess = ReplicatedStorage:FindFirstChild("Remotess")
local CastEvent = Remotess and Remotess:FindFirstChild("CastEvent")
local MiniGame = Remotess and Remotess:FindFirstChild("MiniGame")
local NotifyClient = Remotess and Remotess:FindFirstChild("NotifyClient")

local AFKSystem = ReplicatedStorage:FindFirstChild("AFKSystem")
local AFKEvent = AFKSystem and AFKSystem:FindFirstChild("AFKEvent")

local RemoteSell = ReplicatedStorage:FindFirstChild("RemoteSell")
local RequestFishList = RemoteSell and RemoteSell:FindFirstChild("RequestFishList")
local SellSelectedFish = RemoteSell and RemoteSell:FindFirstChild("SellSelectedFish")
local OpenSellUI = RemoteSell and RemoteSell:FindFirstChild("OpenSellUI")

local TeleportRequest = ReplicatedStorage:FindFirstChild("TeleportRequest")

--================================================
-- 3. KONFIGURASI GLOBAL
--================================================
getgenv().MizuConfig = {
    IsRunning = true,
    AutoFish = false,
    FishPower = 100,
    AutoSell = false,
    AntiAFK = false,
    TeleportTarget = nil
}

-- Database ikan (dari log NotifyClient)
local FishNames = {
    "Ikan Mas (Common)",
    "PinkKoi (Common)",
    "Lobster (Common)"
    -- tambahkan nama lain sesuai observasi
}

--================================================
-- 4. FUNGSI INTI EKSPLOITASI
--================================================

-- [A] AUTO FISHING LOOP
task.spawn(function()
    while getgenv().MizuConfig.IsRunning do
        if getgenv().MizuConfig.AutoFish then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and CastEvent then
                local root = char.HumanoidRootPart
                local power = getgenv().MizuConfig.FishPower
                pcall(function()
                    CastEvent:FireServer(false, power, root.CFrame)
                end)
            end
        end
        task.wait(3.5) -- interval antar cast
    end
end)

-- [B] HOOK MINIGAME EVENT UNTUK AUTO PERFECT
if MiniGame then
    MiniGame.OnClientEvent:Connect(function(args)
        if getgenv().MizuConfig.AutoFish and type(args) == "table" and args[1] == "Start" then
            task.wait(0.2) -- delay respons natural
            pcall(function()
                MiniGame:FireServer(true)
            end)
        end
    end)
end

-- [C] AUTO SELL FISH
task.spawn(function()
    while getgenv().MizuConfig.IsRunning do
        if getgenv().MizuConfig.AutoSell then
            -- Cek item di backpack yang merupakan ikan
            for _, item in pairs(Backpack:GetChildren()) do
                if item:IsA("Tool") then
                    local name = item.Name
                    -- Jual jika termasuk ikan atau sebutan umum
                    if name:find("Common") or name:find("Uncommon") or name:find("Rare") or name:find("Ikan") or name:find("Lobster") or name:find("Belut") then
                        pcall(function()
                            if SellSelectedFish then
                                SellSelectedFish:FireServer(name)
                            end
                        end)
                        task.wait(0.1)
                    end
                end
            end
        end
        task.wait(5) -- jual setiap 5 detik
    end
end)

-- [D] ANTI-AFK
task.spawn(function()
    while getgenv().MizuConfig.IsRunning do
        if getgenv().MizuConfig.AntiAFK and AFKEvent then
            pcall(function()
                AFKEvent:FireServer()
            end)
        end
        task.wait(60)
    end
end)

-- [E] TELEPORT (jika ada target)
task.spawn(function()
    while getgenv().MizuConfig.IsRunning do
        if getgenv().MizuConfig.TeleportTarget and TeleportRequest then
            local target = getgenv().MizuConfig.TeleportTarget
            -- Asumsi parameter: nama player atau CFrame? Dari observasi, mungkin string player name
            pcall(function()
                TeleportRequest:FireServer(target)
            end)
            getgenv().MizuConfig.TeleportTarget = nil -- reset setelah teleport
        end
        task.wait(1)
    end
end)

--================================================
-- 5. LUNA INTERFACE SUITE
--================================================
local function InitInterface()
    local success, Luna = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()
    end)
    if not success then return end

    local Window = Luna:CreateWindow({
        Name = "Mizukage Official",
        Subtitle = "KARTA SUNDA - Ruang Riung",
        LogoID = "104266190557772",
        LoadingEnabled = true,
        LoadingTitle = "Mizukage System",
        ConfigSettings = { ConfigFolder = "MizukageHub" },
        KeySystem = false
    })

    Window:CreateHomeTab({
        SupportedExecutors = {"Delta", "Codex", "Wave", "Arceus X"},
        DiscordInvite = "Mizukage-Official",
        Icon = 1
    })

    --==========================
    -- TAB MAIN FEATURES
    --==========================
    local MainTab = Window:CreateTab({
        Name = "Main Features",
        Icon = "fish",
        ImageSource = "Material",
        ShowTitle = true
    })

    MainTab:CreateSection({ Name = "🎣 Auto Fishing" })
    MainTab:CreateToggle({
        Name = "Auto Fish",
        CurrentValue = false,
        Callback = function(V) getgenv().MizuConfig.AutoFish = V end
    }, "TglAutoFish")
    MainTab:CreateSlider({
        Name = "Fishing Power",
        CurrentValue = 100,
        MinValue = 1,
        MaxValue = 100,
        Callback = function(V) getgenv().MizuConfig.FishPower = V end
    }, "SldFishPower")

    MainTab:CreateSection({ Name = "💰 Auto Selling" })
    MainTab:CreateToggle({
        Name = "Auto Sell Fish",
        CurrentValue = false,
        Callback = function(V) getgenv().MizuConfig.AutoSell = V end
    }, "TglAutoSell")

    MainTab:CreateSection({ Name = "⚡ Utilities" })
    MainTab:CreateToggle({
        Name = "Anti-AFK (Ping Spoof)",
        CurrentValue = false,
        Callback = function(V) getgenv().MizuConfig.AntiAFK = V end
    }, "TglAntiAFK")

    -- Teleport
    MainTab:CreateSection({ Name = "🚀 Teleport Player" })
    local playerList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(playerList, p.Name)
        end
    end
    MainTab:CreateDropdown({
        Name = "Pilih Pemain",
        CurrentValue = playerList[1] and {playerList[1]} or {},
        List = playerList,
        Callback = function(V) 
            -- simpan target, teleport dijalankan oleh loop
        end
    }, "DdTeleportTarget")
    MainTab:CreateButton({
        Name = "Teleport ke Pemain",
        Callback = function()
            local dd = Window:GetElement("DdTeleportTarget")
            if dd and dd.CurrentValue and dd.CurrentValue[1] then
                getgenv().MizuConfig.TeleportTarget = dd.CurrentValue[1]
            end
        end
    })

    --==========================
    -- TAB THEME & CONFIG
    --==========================
    Window:CreateTab({
        Name = "Theme",
        Icon = "palette",
        ImageSource = "Material",
        ShowTitle = true
    }):BuildThemeSection()

    local ConfigTab = Window:CreateTab({
        Name = "Config",
        Icon = "settings",
        ImageSource = "Material",
        ShowTitle = true
    })
    ConfigTab:BuildConfigSection()
    ConfigTab:CreateButton({
        Name = "Shutdown Script",
        Callback = function()
            getgenv().MizuConfig.IsRunning = false
            getgenv().MizuKartaLoaded = false
            Luna:Destroy()
        end
    })
end

--================================================
-- 6. BOOTSTRAP
--================================================
task.spawn(InitInterface)
