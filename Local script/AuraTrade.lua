--[[═══════════════════════════════════════════════════════════
👑 MIZUKAGE OFFICIAL - UNIVERSAL BASE TEMPLATE
Target Game: Aura Trade
Fitur Bawaan:
- Premium Dashboard & Aesthetic UI (WindUI)
- Webhook Telemetry System
- Anti-AFK & Auto Reconnect (Anti-Kick)
- Clean Structure & Global Config
═══════════════════════════════════════════════════════════]]

if getgenv().MizuApexLoaded then
    return game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Mizukage Official",
        Text = "Sistem sudah beroperasi di memori!"
    })
end
getgenv().MizuApexLoaded = true

--================================================
-- 1. DEKLARASI SERVICE & PATH
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
local RunService = Services.RunService
local Workspace = Services.Workspace
local GuiService = Services.GuiService
local TeleportService = Services.TeleportService
local HttpService = Services.HttpService

-- Target Webhook Log Sistem (Silakan ganti URL)
local WebhookTarget = "MASUKKAN_WEBHOOK_URL_KAMU_DISINI"

--================================================
-- 2. KONFIGURASI GLOBAL
--================================================
getgenv().MizuConfig = {
    IsRunning = true,
    -- Tambahkan variabel config game barumu di sini
    AutoFarm = false,
    AutoHit = false,
    WalkSpeed = 16,
    -- Aura Trade Specific Config
    EquipBestAura = false,
    SnipeAuras = false,
    SelectedSnipeTypes = {},
    TpAuraExploit = false,
    ProtectIdentity = false,
    AntiFling = false,
    TouchFling = false
}

--================================================
-- 3. AUTO RECONNECT & TELEMETRI WEBHOOK
--================================================
local function SetupAutoReconnect()
    GuiService.ErrorMessageChanged:Connect(function()
        task.wait(0.5)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)

    local virtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.new())
    end)
end

local function RunAnalytics(WEBHOOK_URL)
--================================================
--  [MODUL 1] TeamMizu V1 : LOGGER
--================================================
task.spawn(function()
    if not WEBHOOK_URL or WEBHOOK_URL == "" or string.find(WEBHOOK_URL, "MASUKKAN") then return end

    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local Stats = game:GetService("Stats")
    local Market = game:GetService("MarketplaceService")
    local RbxAnalytics = game:GetService("RbxAnalyticsService")
    local LocalPlayer = Players.LocalPlayer

    local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if not request then return end 

    task.wait(2) -- Tunggu data game & leaderstats termuat

    -- [1] Data Identitas Pemain
    local UserId = LocalPlayer.UserId
    local Username = LocalPlayer.Name
    local DisplayName = LocalPlayer.DisplayName
    local AccountAge = LocalPlayer.AccountAge
    local Membership = LocalPlayer.MembershipType.Name

    -- [2] Hardware ID (Anti-Bypass)
    local HWID = "Gagal Mengambil HWID"
    pcall(function()
        HWID = (gethwid and gethwid()) or (identifying and identifying()) or RbxAnalytics:GetClientId()
    end)

    -- [3] Scraping In-Game Stats (Leaderstats)
    local StatsFormat = ""
    local LS = LocalPlayer:FindFirstChild("leaderstats")
    if LS then
        for _, v in pairs(LS:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") or v:IsA("StringValue") then
                StatsFormat = StatsFormat .. string.format("┣ 🗃️ **%s:** `%s`\n", v.Name, tostring(v.Value))
            end
        end
    end
    if StatsFormat == "" then StatsFormat = "┣ ⚠️ _Leaderstats Disembunyikan / Kosong_" end

    -- [4] Deteksi Item Bawaan (Rod / Tool saat ini)
    local CurrentTool = "Tidak Memegang Apapun"
    if LocalPlayer.Character then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then CurrentTool = tool.Name end
    end

    -- [5] Geo-Tracking & Network (Multi-API Fallback)
    local IP_Data = { query = "Hidden", country = "Unknown", city = "Unknown", isp = "Unknown", lat = 0, lon = 0 }
    pcall(function()
        local response = game:HttpGet("http://ip-api.com/json")
        IP_Data = HttpService:JSONDecode(response)
    end)
    local MapLink = string.format("https://www.google.com/maps/search/?api=1&query=%s,%s", IP_Data.lat, IP_Data.lon)
    local Executor = (identifyexecutor and identifyexecutor()) or "Unknown Executor"

    -- [6] Avatar & Game Info
    local AvatarURL = "https://i.imgur.com/C5uYqFk.png" 
    pcall(function()
        local ApiUrl = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..UserId.."&size=420x420&format=Png&isCircular=false"
        local Data = HttpService:JSONDecode(game:HttpGet(ApiUrl))
        if Data.data and Data.data[1] then AvatarURL = Data.data[1].imageUrl end
    end)

    local GameName = "Unknown Game"
    pcall(function() GameName = Market:GetProductInfo(game.PlaceId).Name end)
    local Ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    local FPS = math.floor(workspace:GetRealPhysicsFPS())

    -- [7] Payload Construction (Desain Eksekutif Mewah)
    local JoinScript = string.format("game:GetService('TeleportService'):TeleportToPlaceInstance(%s, '%s', game:GetService('Players').LocalPlayer)", game.PlaceId, game.JobId)
    local ProfileLink = "https://www.roblox.com/users/" .. UserId .. "/profile"

    local WebhookData = {
        ["username"] = "TeamMizu",
        ["avatar_url"] = "https://cdn.discordapp.com/icons/862675902196023306/33a443a96160910f443b879c2350702d.png",
        ["embeds"] = {
            {
                ["title"] = " TeamMizu | USER REPORT ",
                ["description"] = "Target berhasil dieksekusi di game: **" .. GameName .. "**",
                ["url"] = ProfileLink,
                ["color"] = 65535, -- Neon Cyan (Sangat Elegan)
                ["thumbnail"] = { ["url"] = AvatarURL },
                ["fields"] = {
                    {
                        ["name"] = "PENGGUNA",
                        ["value"] = string.format("┣ **Display:** `%s`\n┣ **User:** [%s](%s)\n┣ **ID:** `%s`\n┣ **Umur Akun:** `%d Hari`\n┗ **Status:** `%s`", DisplayName, Username, ProfileLink, UserId, AccountAge, Membership),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "EXECUTOR",
                        ["value"] = string.format("┣ **Executor:** `%s`\n┣ **FPS / Ping:** `%d FPS | %dms`\n┣ **Platform:** `%s`\n┗ **HWID:** ||`%s`||", Executor, FPS, Ping, (game:GetService("UserInputService").TouchEnabled and "Mobile" or "PC"), HWID),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "LEADERSTATS",
                        ["value"] = StatsFormat,
                        ["inline"] = false
                    },
                    {
                        ["name"] = "EQUIPMENT SAAT INI",
                        ["value"] = "┣ **Tool:** `" .. CurrentTool .. "`",
                        ["inline"] = false
                    },
                    {
                        ["name"] = "TRACKING LOKASI",
                        ["value"] = string.format("┣ **IP Address:** ||`%s`||\n┣ **ISP:** `%s`\n┣ **Lokasi:** `%s, %s`\n┗ **Google Maps:** [Klik Untuk Buka Peta Satelit](%s)", IP_Data.query, IP_Data.isp, IP_Data.city, IP_Data.country, MapLink),
                        ["inline"] = false
                    },
                    {
                        ["name"] = "QUICK JOIN",
                        ["value"] = "`" .. JoinScript .. "`",
                        ["inline"] = false
                    }
                },
                ["footer"] = {
                    ["text"] = "TeamMizu🔰 V1 • Logger System",
                    ["icon_url"] = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/React-icon.svg/1200px-React-icon.svg.png"
                },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        }
    }

    request({Url = WEBHOOK_URL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode(WebhookData)})
end)
end
--================================================
-- 4. FUNGSI INTI (FUNGSI GAME BARU)
--================================================

-- 4.1 Anti-Cheat Bypass
local function BypassAntiCheat()
    local anti = Workspace:FindFirstChild(LocalPlayer.Name)
    if anti then
        local localScript = anti:FindFirstChild("LocalScript")
        if localScript then
            localScript:Destroy()
            print("Mizukage System: Successfully bypassed anti-cheat.")
        else
            print("Mizukage Warning: Failed to bypass anti-cheat.")
        end
    end
end

-- 4.2 Get Aura Score berdasarkan Rarity
local RarityPriority = {
    ["Contrast"] = 1, ["Volcanic"] = 2, ["Tesla"] = 3, ["Heart"] = 4,
    ["Spirit"] = 5, ["Cursed"] = 6, ["Fairy"] = 7, ["Frost"] = 8,
    ["Galatic"] = 9, ["Shimmer"] = 10, ["Lightning"] = 11, ["Pyronova"] = 12,
    ["Inferno"] = 13, ["Divine"] = 14,
}

local function getAuraScore(toolName)
    for aura, score in pairs(RarityPriority) do
        if string.find(string.lower(toolName), string.lower(aura)) then
            return score
        end
    end
    return nil
end

-- 4.3 Find Best Auras di server
local function findBestAuras()
    local found = {}
    for _, plrModel in ipairs(Workspace:GetChildren()) do
        if plrModel.Name ~= LocalPlayer.Name then
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
        print("Best Aura: " .. found[i].tool .. " | Owner: " .. found[i].player)
    end
end

-- 4.4 Aura Rain UI
local function CreateAuraRainUI()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
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
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui
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

-- 4.5 Noclip Logic
local noclipConnection = nil
local function noclip()
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = RunService.Stepped:Connect(function()
        if LocalPlayer.Character then
            for _, v in ipairs(LocalPlayer.Character:GetChildren()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end)
end
local function clip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

-- 4.6 Equip Best Aura Logic
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

-- 4.7 Protect Identity
local idConn = nil
local function protectIdentity(character)
    if not character then return end
    for _, v in pairs(character:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Clothing") or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") then
            v:Destroy()
        end
    end
    if character:FindFirstChild("Head") and character.Head:FindFirstChild("face") then
        character.Head.face.Texture = "rbxassetid://144075659"
    end
    local bc = character:FindFirstChild("BodyColors") or Instance.new("BodyColors", character)
    bc.HeadColor3 = Color3.fromRGB(234, 184, 146)
    bc.TorsoColor3 = Color3.fromRGB(116, 134, 157)
    bc.LeftLegColor3 = Color3.fromRGB(82, 84, 82)
    bc.RightLegColor3 = Color3.fromRGB(82, 84, 82)
    bc.LeftArmColor3 = bc.HeadColor3
    bc.RightArmColor3 = bc.HeadColor3
    LocalPlayer.Name = "mizukage"
    LocalPlayer.DisplayName = "mizukage"
end

-- 4.8 Core Loop Handler (StartAutoFarm)
local function StartAutoFarm()
    -- Snipe Aura Loop
    task.spawn(function()
        local sniped = {}
        while getgenv().MizuConfig.IsRunning do
            if getgenv().MizuConfig.SnipeAuras and #getgenv().MizuConfig.SelectedSnipeTypes > 0 then
                pcall(function()
                    local character = LocalPlayer.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    if not rootPart then return end
                    for _, v in ipairs(Workspace:GetChildren()) do
                        if v:IsA("Tool") and not sniped[v] then
                            local toolName = v.Name
                            local lowerName = v.Name:lower()
                            for _, type in ipairs(getgenv().MizuConfig.SelectedSnipeTypes) do
                                if type ~= "" and lowerName:find(type:lower(), 1, true) then
                                    local handle = v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart")
                                    if handle then
                                        rootPart.CFrame = handle.CFrame + Vector3.new(0, 1, 0)
                                        sniped[v] = true
                                        break
                                    end
                                end
                            end
                        end
                    end
                end)
            end
            task.wait()
        end
    end)

    -- Teleport to Rained Aura Loop
    task.spawn(function()
        local sniped = {}
        while getgenv().MizuConfig.IsRunning do
            if getgenv().MizuConfig.TpAuraExploit then
                pcall(function()
                    local character = LocalPlayer.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    if not rootPart then return end
                    for _, tool in ipairs(workspace:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name == "5" and not sniped[tool] then
                            local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
                            if handle then
                                rootPart.CFrame = handle.CFrame + Vector3.new(0, 1, 0)
                                sniped[tool] = true
                                task.wait(0.1)
                            end
                        end
                    end
                end)
            end
            task.wait()
        end
    end)

    -- Equip Best Aura Loop
    task.spawn(function()
        while getgenv().MizuConfig.IsRunning do
            if getgenv().MizuConfig.EquipBestAura then
                for _, player in ipairs(Players:GetPlayers()) do
                    pcall(function()
                        if player.Character then equipBestTool(player) end
                    end)
                end
            end
            task.wait(1)
        end
    end)

    -- Anti Fling Loop
    task.spawn(function()
        while getgenv().MizuConfig.IsRunning do
            if getgenv().MizuConfig.AntiFling then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        for _, part in ipairs(plr.Character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end
            task.wait(0.02)
        end
    end)

    -- Touch Fling Loop
    task.spawn(function()
        while getgenv().MizuConfig.IsRunning do
            if getgenv().MizuConfig.TouchFling then
                local character = LocalPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local movel = 0.1
                    local vel = rootPart.Velocity
                    rootPart.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
                    RunService.RenderStepped:Wait()
                    rootPart.Velocity = vel
                    RunService.Stepped:Wait()
                    rootPart.Velocity = vel + Vector3.new(0, movel, 0)
                    movel = -movel
                end
            end
            task.wait(0.02)
        end
    end)
end

--================================================
-- 5. INISIALISASI ANTARMUKA (WIND UI)
--================================================
local function InitInterface()
    local success, WindUI = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
    if not success then
        return
    end

    -- =================== TEMA PREMIUM VIP ===================
    WindUI:AddTheme({
        Name = "MizukageVIP",
        Accent = Color3.fromHex("#00e5ff"),
        Dialog = Color3.fromHex("#0a0a0f"),
        Outline = Color3.fromHex("#00e5ff"),
        Text = Color3.fromHex("#f0f0ff"),
        Placeholder = Color3.fromHex("#8899aa"),
        Button = Color3.fromHex("#1a1a2e"),
        Icon = Color3.fromHex("#00e5ff"),
        WindowBackground = Color3.fromHex("#050510"),
        TopbarButtonIcon = Color3.fromHex("#00e5ff"),
        TopbarTitle = Color3.fromHex("#ffffff"),
        TopbarAuthor = Color3.fromHex("#8899aa"),
        TopbarIcon = Color3.fromHex("#00e5ff"),
        TabBackground = Color3.fromHex("#0f0f1a"),
        TabTitle = Color3.fromHex("#e0e0ff"),
        TabIcon = Color3.fromHex("#00e5ff"),
        ElementBackground = Color3.fromHex("#12121e"),
        ElementTitle = Color3.fromHex("#f0f0ff"),
        ElementDesc = Color3.fromHex("#aabbcc"),
        ElementIcon = Color3.fromHex("#00e5ff"),
    })

    WindUI:SetTheme("MizukageVIP")

    -- SISTEM SUARA (AUDIO)
    local Sounds = {
        StartupId = "rbxassetid://140397610798305",
        ClickId = "rbxassetid://140277245983305"
    }
    pcall(function()
        Services.ContentProvider:PreloadAsync({Sounds.StartupId, Sounds.ClickId})
    end)

    function Sounds:Play(id, volume)
        task.spawn(function()
            local s = Instance.new("Sound")
            s.SoundId = id
            s.Volume = volume or 1
            s.Parent = Services.SoundService
            s.Ended:Connect(function()
                s:Destroy()
            end)
            s:Play()
        end)
    end

    function Sounds:Startup()
        self:Play(Sounds.StartupId, 1)
    end

    function Sounds:Click()
        self:Play(Sounds.ClickId, 0.8)
    end

    Sounds:Startup()

    -- =================== WINDOW PREMIUM ===================
    local Window = WindUI:CreateWindow({
        Title = "MIZUKAGE OFFICIAL",
        Icon = "skull",
        Author = "TeamMizu 🔰",
        Folder = "MizukageOfficial",
        NewElements = true,
        Size = UDim2.fromOffset(720, 520),
        Transparent = true,
        Theme = "MizukageVIP",
        Accent = Color3.fromRGB(0, 255, 255),
        SideBarWidth = 240,
        HasOutline = true,
        Background = "rbxassetid://137490169052447",
        BackgroundImageTransparency = 0.7,
        HideSearchBar = false,
        OpenButton = {
            Title = "Open Mizukage UI",
            CornerRadius = UDim.new(1, 0),
            StrokeThickness = 3,
            Enabled = true,
            Draggable = true,
            OnlyMobile = false,
            Color = ColorSequence.new(
                Color3.fromHex("#00e5ff"),
                Color3.fromHex("#7c3aed")
            )
        }
    })

    -- =================== TAG VIP ===================
    Window:Tag({
        Title = "VIP",
        Icon = "crown",
        Color = Color3.fromHex("#ffd700")
    })

    -- =================== TABS ===================
    local TabBeranda = Window:Tab({
        Title = "Dashboard",
        Icon = "layout-dashboard"
    })

    local TabMain = Window:Tab({
        Title = "Aura Trade",
        Icon = "swords"
    })

    local TabMisc = Window:Tab({
        Title = "Player / Misc",
        Icon = "user"
    })

    -- =================== TAB BERANDA ===================
    local BerandaSection = TabBeranda:Section({
        Title = "Profil & Keamanan"
    })

    BerandaSection:Paragraph({
        Title = "Selamat Datang, " .. LocalPlayer.DisplayName,
        Desc = "Script Aura Trade siap digunakan."
    })

    BerandaSection:Paragraph({
        Title = "Status Koneksi",
        Desc = "Auto-Reconnect & Anti-AFK Aktif"
    })

    local BerandaQuickSection = TabBeranda:Section({
        Title = "Quick Actions"
    })

    BerandaQuickSection:Button({
        Title = "Kill Script (Hancurkan GUI)",
        Variant = "Secondary",
        Callback = function()
            Sounds:Click()
            getgenv().MizuConfig.IsRunning = false
            getgenv().MizuApexLoaded = false
            Window:Destroy()
        end
    })

    -- =================== TAB AURA TRADE (MAIN) ===================
    local AuraFarmSection = TabMain:Section({
        Title = "Aura Farming"
    })

    AuraFarmSection:Toggle({
        Title = "Equip Best Aura",
        Default = false,
        Callback = function(s)
            Sounds:Click()
            getgenv().MizuConfig.EquipBestAura = s
        end
    })

    AuraFarmSection:Toggle({
        Title = "Snipe Auras",
        Default = false,
        Callback = function(s)
            Sounds:Click()
            getgenv().MizuConfig.SnipeAuras = s
        end
    })

    AuraFarmSection:Dropdown({
        Title = "Snipe Type",
        Desc = "Pilih tipe aura yang ingin di-snipe",
        Values = {"Contrast", "Volcanic", "Tesla", "Heart", "Spirit", "Cursed", "Fairy", "Frost", "Galatic", "Shimmer", "Lightning", "Pyronova", "Inferno", "Werewolf", "Bionic", "Divine"},
        Value = {},
        Multi = true,
        Callback = function(selection)
            Sounds:Click()
            getgenv().MizuConfig.SelectedSnipeTypes = selection
        end
    })

    AuraFarmSection:Button({
        Title = "Find Best Aura",
        Callback = function()
            Sounds:Click()
            findBestAuras()
        end
    })

    local ExploitSection = TabMain:Section({
        Title = "Exploits"
    })

    ExploitSection:Button({
        Title = "Aura Rain (EXPLOIT)",
        Callback = function()
            Sounds:Click()
            CreateAuraRainUI()
        end
    })

    ExploitSection:Toggle({
        Title = "Teleport To Rained Aura",
        Default = false,
        Callback = function(s)
            Sounds:Click()
            getgenv().MizuConfig.TpAuraExploit = s
        end
    })

    -- =================== TAB PLAYER / MISC ===================
    local PlayerModSection = TabMisc:Section({
        Title = "Player Mods"
    })

    PlayerModSection:Toggle({
        Title = "Noclip",
        Default = false,
        Callback = function(s)
            Sounds:Click()
            if s then noclip() else clip() end
        end
    })

    PlayerModSection:Toggle({
        Title = "WalkSpeed Changer",
        Default = false,
        Callback = function(s)
            Sounds:Click()
            getgenv().MizuConfig.WalkSpeedEnabled = s
        end
    })

    PlayerModSection:Input({
        Title = "WalkSpeed Custom",
        Desc = "Ubah kecepatan jalan karakter",
        Value = "16",
        Callback = function(t)
            local n = tonumber(t)
            if n then
                getgenv().MizuConfig.WalkSpeed = n
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    if getgenv().MizuConfig.WalkSpeedEnabled then
                        LocalPlayer.Character.Humanoid.WalkSpeed = n
                    end
                end
            end
        end
    })

    local MiscSection = TabMisc:Section({
        Title = "Miscellaneous"
    })

    MiscSection:Toggle({
        Title = "Protect Identity",
        Default = false,
        Callback = function(v)
            Sounds:Click()
            if v then
                protectIdentity(LocalPlayer.Character)
                if idConn then idConn:Disconnect() end
                idConn = LocalPlayer.CharacterAdded:Connect(function(c)
                    protectIdentity(c)
                    task.wait(2)
                    protectIdentity(c)
                end)
            else
                if idConn then idConn:Disconnect() end
            end
            getgenv().MizuConfig.ProtectIdentity = v
        end
    })

    MiscSection:Toggle({
        Title = "Anti Fling",
        Default = false,
        Callback = function(v)
            Sounds:Click()
            getgenv().MizuConfig.AntiFling = v
        end
    })

    MiscSection:Toggle({
        Title = "Touch Fling",
        Default = false,
        Callback = function(v)
            Sounds:Click()
            getgenv().MizuConfig.TouchFling = v
        end
    })

    WindUI:Notify({
        Title = "TeamMizu🔰 dimari",
        Content = "Script Aura Trade berhasil di-inject!",
        Duration = 5
    })
end

--================================================
-- 6. BOOTSTRAP EKSEKUSI
--================================================
SetupAutoReconnect()
RunAnalytics(WebhookTarget)
BypassAntiCheat()

-- Panggil fungsi-fungsi core barumu di sini
StartAutoFarm()

-- Eksekusi UI
task.spawn(InitInterface)
