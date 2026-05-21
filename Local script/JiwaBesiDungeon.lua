--[[═══════════════════════════════════════════════════════════
🌊 MIZUKAGE OFFICIAL - CLOUD HUB SCRIPT
Target Game: Jiwa Besi: Dungeon / Hutan Tanpa Bintang
Place ID: 108187800843065
Engine: Mizu-OS v14.0 | Luna Interface Suite
Status: UNDETECTED | FORGE GLITCH ACTIVE
═══════════════════════════════════════════════════════════]]

if getgenv().MizuCloudLoaded then
    return game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Mizukage Cloud Hub",
        Text = "Sistem sudah beroperasi di memori!",
        Duration = 3
    })
end
getgenv().MizuCloudLoaded = true

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
local HttpService = Services.HttpService

--================================================
-- 2. DEKLARASI REMOTES (ANTI-CRASH WRAPPED)
--================================================
local Framework = ReplicatedStorage:FindFirstChild("Framework")
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")

local PlayerActionRE = Remotes and Remotes:FindFirstChild("PlayerActionRE")
local StatsRE = Remotes and Remotes:FindFirstChild("StatsRE")
local TaskRE = Framework and Framework:FindFirstChild("Features") and Framework.Features:FindFirstChild("TaskSystem") and Framework.Features.TaskSystem:FindFirstChild("TaskRE")
local ForgeRF = Framework and Framework:FindFirstChild("Features") and Framework.Features:FindFirstChild("ForgeSystem") and Framework.Features.ForgeSystem:FindFirstChild("ForgeRF")
local RedPointRE = Framework and Framework:FindFirstChild("Systems") and Framework.Systems:FindFirstChild("RedPointSystem") and Framework.Systems.RedPointSystem.RedPointUtil:FindFirstChild("RemoteEvent")
local LeaderboardRF = Framework and Framework:FindFirstChild("Features") and Framework.Features:FindFirstChild("LeaderboardSystem") and Framework.Features.LeaderboardSystem:FindFirstChild("RF")

--================================================
-- 3. KONFIGURASI GLOBAL & DATABASE MATERIAL
--================================================
getgenv().MizuConfig = {
    IsRunning = true,
    AutoAttack = false,
    AutoSkill = false,
    AutoDoor = false,
    AntiPing = false,
    WalkSpeed = 16,
    AutoQTE = false,
    ForgeType = "Weapon",
    ManualMats = {
        {Name = "None", Amount = 0},
        {Name = "None", Amount = 0},
        {Name = "None", Amount = 0},
        {Name = "None", Amount = 0}
    },
    ScanResult = "Belum melakukan scan...",
    TopPlayers = {}
}

local MaterialDatabase = {
    "None", "Hellstone2", "IgneousCore", "Hellstone1", "IceCrystalOre",
    "SmokyQuartz", "AmethystCluster", "Sunstone", "ObsidianChunk",
    "Epidote", "Pyrite", "Sandstone", "CrystalFlake", "CrystalPrism"
}

--================================================
-- 4. FUNGSI INTI LOGIKA GAME & BYPASS
--================================================
local function StartGameLogic()

    -- [A] LOOPING COMBAT & PORTAL
    task.spawn(function()
        local combo = 1
        while getgenv().MizuConfig.IsRunning do
            if getgenv().MizuConfig.AutoAttack and PlayerActionRE then
                pcall(function()
                    PlayerActionRE:FireServer("SkillAction", "BaseAttack", combo)
                end)
                combo = combo >= 4 and 1 or combo + 1
            end
            if getgenv().MizuConfig.AutoSkill and PlayerActionRE then
                pcall(function()
                    PlayerActionRE:FireServer("SkillAction", "Skill1", 1)
                    PlayerActionRE:FireServer("SkillAction", "Skill2", 1)
                    PlayerActionRE:FireServer("SkillAction", "SkillU", 1)
                end)
            end
            if getgenv().MizuConfig.AutoDoor then
                pcall(function()
                    local roundDoor = Workspace:FindFirstChild("RoundDoor")
                    if roundDoor then
                        local doorRoot = roundDoor:FindFirstChild("Door") and roundDoor.Door:FindFirstChild("Root")
                        local portalRoot = roundDoor:FindFirstChild("Portal") and roundDoor.Portal:FindFirstChild("Root")
                        if doorRoot and doorRoot:FindFirstChild("RE") then
                            doorRoot.RE:FireServer()
                        end
                        if portalRoot and portalRoot:FindFirstChild("RF") then
                            portalRoot.RF:InvokeServer()
                        end
                    end
                    local normalPortal = Workspace:FindFirstChild("Portal")
                    if normalPortal and normalPortal:FindFirstChild("Root") and normalPortal.Root:FindFirstChild("RF") then
                        normalPortal.Root.RF:InvokeServer()
                    end
                end)
            end
            task.wait(0.1)
        end
    end)

    -- [B] ANTI-AFK PING SPOOF
    task.spawn(function()
        local pingId = 100
        while getgenv().MizuConfig.IsRunning do
            task.wait(5)
            if getgenv().MizuConfig.AntiPing and StatsRE then
                pcall(function()
                    StatsRE:FireServer("ping", {Id = pingId, Time = tick()})
                end)
                pingId = pingId + 1
            end
        end
    end)

    -- [C] AUTO QTE PERFECT HOOK
    if ForgeRF then
        pcall(function()
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                if not checkcaller() and self == ForgeRF and method == "InvokeServer" then
                    if args[1] == "QTE" and getgenv().MizuConfig.AutoQTE then
                        args[2].Rating = 15
                        return oldNamecall(self, unpack(args))
                    end
                end
                return oldNamecall(self, ...)
            end)
        end)
    end
end

--================================================
-- 5. LUNA INTERFACE SUITE INITIALIZATION
--================================================
local function InitInterface()
    local success, Luna = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()
    end)
    if not success then return end

    local Window = Luna:CreateWindow({
        Name = "Mizukage Official",
        Subtitle = "Jiwa Besi: Dungeon / Hutan Tanpa Bintang",
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
        Icon = "swords",
        ImageSource = "Material",
        ShowTitle = true
    })

    MainTab:CreateSection({ Name = "⚔️ Combat Automation" })
    MainTab:CreateToggle({
        Name = "Auto Base Attack (Combo)",
        CurrentValue = false,
        Callback = function(V) getgenv().MizuConfig.AutoAttack = V end
    }, "TglAutoAttack")
    MainTab:CreateToggle({
        Name = "Auto All Skills (1, 2, Ultimate)",
        CurrentValue = false,
        Callback = function(V) getgenv().MizuConfig.AutoSkill = V end
    }, "TglAutoSkill")

    MainTab:CreateSection({ Name = "🚪 Dungeon Automation" })
    MainTab:CreateToggle({
        Name = "Auto Enter Portals & Doors",
        CurrentValue = false,
        Callback = function(V) getgenv().MizuConfig.AutoDoor = V end
    }, "TglAutoDoor")
    MainTab:CreateButton({
        Name = "Clear Loot Notifications",
        Callback = function()
            if RedPointRE then
                pcall(function()
                    RedPointRE:FireServer("Clear", "Ores", "IceCrystalOre")
                    RedPointRE:FireServer("Clear", "Weapon", "cB2If13nFaFYahVPo00U4Yam")
                end)
            end
        end
    })

    MainTab:CreateSection({ Name = "⚙️ Utilities" })
    MainTab:CreateToggle({
        Name = "Anti-AFK (Spoof Ping)",
        CurrentValue = false,
        Callback = function(V) getgenv().MizuConfig.AntiPing = V end
    }, "TglAntiPing")
    MainTab:CreateButton({
        Name = "Bypass UI Tasks (Selesaikan Misi)",
        Callback = function()
            if TaskRE then
                local menus = {"ScreenForge", "ScreenBackpack", "ScreenGuidebook", "ScreenSettlement", "ScreenPlayerStatistics", "ScreenSeasonPass"}
                for _, menu in pairs(menus) do
                    pcall(function() TaskRE:FireServer("UpdateTaskProgress", "OpenGUIWindow", menu) end)
                end
            end
        end
    })
    MainTab:CreateSlider({
        Name = "Walkspeed Custom",
        CurrentValue = 16,
        MinValue = 16,
        MaxValue = 200,
        Callback = function(V)
            getgenv().MizuConfig.WalkSpeed = V
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = V
            end
        end
    }, "SldWalkSpeed")

    --==========================
    -- TAB DEEPSCAN SERVER
    --==========================
    local ScanTab = Window:CreateTab({
        Name = "DeepScan Server",
        Icon = "radar",
        ImageSource = "Material",
        ShowTitle = true
    })

    ScanTab:CreateSection({ Name = "📡 Live Server Scanner" })
    ScanTab:CreateLabel({
        Name = "Hasil Scan Player & Material",
        Text = "Belum melakukan scan..."
    }, "LblScanResult")
    ScanTab:CreateButton({
        Name = "Mulai Deep Scan Server!",
        Callback = function()
            task.spawn(function()
                local resultText = "👑 TOP PLAYERS (Level):\n"
                if LeaderboardRF then
                    local success, data = pcall(function() return LeaderboardRF:InvokeServer("GetLeaderBoard", "Level") end)
                    if success and data then
                        for i, v in pairs(data) do
                            if i <= 5 then
                                resultText = resultText .. i .. ". " .. tostring(v.Name) .. " (Lv." .. tostring(v.Value) .. ")\n"
                            end
                        end
                    else
                        resultText = resultText .. "Gagal mengambil data Leaderboard.\n"
                    end
                else
                    resultText = resultText .. "[Data Disimulasikan]\n1. Raihanmaulanana (Lv. Max)\n2. Yibo0427 (Lv. Max)\n"
                end
                resultText = resultText .. "\n💎 MATERIAL META (Drop Tertinggi):\n"
                resultText = resultText .. "- Hellstone2 (Tier SSS - Weapon)\n- IgneousCore (Tier SS - Weapon/Armor)\n- IceCrystalOre (Tier S - Armor Utama)\n- SmokyQuartz (Tier A)\n- CrystalPrism (Tier A - Aksesoris)\n"

                getgenv().MizuConfig.ScanResult = resultText
                local lbl = Window:GetElement("LblScanResult")
                if lbl then lbl:UpdateText(resultText) end
            end)
        end
    })

    --==========================
    -- TAB FORGE GLITCH
    --==========================
    local ForgeTab = Window:CreateTab({
        Name = "Forge Glitch",
        Icon = "hammer",
        ImageSource = "Material",
        ShowTitle = true
    })

    ForgeTab:CreateSection({ Name = "🛠️ Sistem Racikan Presisi" })
    ForgeTab:CreateLabel({
        Name = "Peringatan Racikan",
        Text = "BACA: Bahan sama = Senjata SAMA. Gunakan variasi bahan untuk hasil berbeda!\nContoh Armor: IceCrystalOre + SmokyQuartz."
    }, "LblForgeWarning")

    ForgeTab:CreateToggle({
        Name = "Bypass QTE (Auto Perfect Rating 15)",
        CurrentValue = false,
        Callback = function(V) getgenv().MizuConfig.AutoQTE = V end
    }, "TglAutoQTE")

    ForgeTab:CreateDropdown({
        Name = "Pilih Target Tempa",
        CurrentValue = {"Weapon"},
        List = {"Weapon", "Armor"},
        Callback = function(V)
            getgenv().MizuConfig.ForgeType = V
        end
    }, "DdForgeType")

    ForgeTab:CreateSection({ Name = "🧬 Slot Bahan (Pilih Kombinasi Berbeda)" })
    for i = 1, 4 do
        ForgeTab:CreateDropdown({
            Name = "Slot " .. i .. " - Material",
            CurrentValue = {"None"},
            List = MaterialDatabase,
            Callback = function(V)
                getgenv().MizuConfig.ManualMats[i].Name = V
            end
        }, "DdMatSlot" .. i)
        ForgeTab:CreateInput({
            Name = "Slot " .. i .. " - Jumlah",
            PlaceholderText = "0",
            Callback = function(V)
                local n = tonumber(V)
                if n then getgenv().MizuConfig.ManualMats[i].Amount = n end
            end
        }, "InpMatSlot" .. i)
    end

    ForgeTab:CreateButton({
        Name = "⚡ FORGE SEKARANG (GLITCH SERVER) ⚡",
        Callback = function()
            if not ForgeRF then return end
            local customMats = {}
            local totalItems = 0
            for i = 1, 4 do
                local mat = getgenv().MizuConfig.ManualMats[i]
                if mat.Name ~= "None" and mat.Amount > 0 then
                    customMats[mat.Name] = mat.Amount
                    totalItems = totalItems + 1
                end
            end
            if totalItems == 0 then return end
            task.spawn(function()
                pcall(function()
                    ForgeRF:InvokeServer("DropOres", customMats, getgenv().MizuConfig.ForgeType)
                    task.wait(0.2)
                    ForgeRF:InvokeServer("ForgeFinish")
                    task.wait(0.1)
                    ForgeRF:InvokeServer("ForgeResult", true)
                end)
            end)
        end
    })

    ForgeTab:CreateSection({ Name = "💡 Contoh Resep Rahasia" })
    ForgeTab:CreateLabel({
        Name = "Resep Weapon S-Tier",
        Text = "Slot 1: Hellstone2 (1) | Slot 2: SmokyQuartz (1) | Slot 3: Hellstone1 (2)"
    }, "LblResepWeapon")
    ForgeTab:CreateLabel({
        Name = "Resep Armor S-Tier",
        Text = "Slot 1: AmethystCluster (4) | Slot 2: SmokyQuartz (2) | Slot 3: IceCrystalOre (10) | Slot 4: IgneousCore (2)"
    }, "LblResepArmor")

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
            getgenv().MizuCloudLoaded = false
            Luna:Destroy()
        end
    })
end

--================================================
-- 6. BOOTSTRAP EKSEKUSI
--================================================
StartGameLogic()
task.spawn(InitInterface)
