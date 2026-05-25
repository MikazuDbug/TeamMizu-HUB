-- Mizukage Official | TeamMizu🔰 - All rights reserved
-- Game: Indo Beach
-- Script rebuilt by MIZU-OS v14.0

-- LOAD LUNA (WAJIB)
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- BUAT WINDOW UTAMA
local Window = Luna:CreateWindow({
    Name = "Mizukage Official",
    Subtitle = "Indo Beach - TeamMizu🔰",
    LogoID = "104266190557772",
    LoadingEnabled = true,
    LoadingTitle = "Mizukage System",
    LoadingSubtitle = "by @MizukageOfficial",
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "MizukageHub"
    },
    KeySystem = false
})

-- HOME TAB (WAJIB)
Window:CreateHomeTab({
    SupportedExecutors = {"Delta", "Codex", "Wave", "Arceus X", "Synapse X", "Krnl", "Fluxus", "Electron", "JJSploit", "Calamari", "SirHurt", "Sentinel", "WEAREDEVS", "Comet", "Cellery", "ProtoSmasher", "Script-Ware", "EasyExploits"},
    DiscordInvite = "Mizukage-Official",
    Icon = 1
})

-- ================================
-- KONFIGURASI
-- ================================
local CONFIG = {
    ROD_TYPES = {
        "NormalRod", "Goth Rod", "Nereus Rod", 
        "Shark Rod", "Tech Rod", "Trident Rod"
    },
    DEFAULT_ROD = "NormalRod",
    COOLDOWN_DURATION = 1.2,
    FISHING_DELAY = 2,
    MINING_INTERVAL = 0.2,
    TELEPORT_OFFSET = Vector3.new(3, 0, 3)
}

-- ================================
-- SERVICE REFERENCES
-- ================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ================================
-- REMOTE REFERENCES
-- ================================
local RemoteThrow = ReplicatedStorage:WaitForChild("RemoteThrow")
local RemoteRetract = ReplicatedStorage:WaitForChild("RemoteRetract")
local GiveCrystal = ReplicatedStorage:WaitForChild("GiveCrystal")
local BloxbizRemotes = ReplicatedStorage:WaitForChild("BloxbizRemotes")
local CatalogApplyOutfit = BloxbizRemotes:WaitForChild("CatalogOnApplyOutfit")

-- ================================
-- STATE VARIABLES (GLOBAL)
-- ================================
getgenv().MizuConfig = getgenv().MizuConfig or {
    IsRunning = true,
    AutoFishing = false,
    InstantOre = false,
    NoClip = false,
    WalkSpeed = 16,
    SelectedRod = CONFIG.DEFAULT_ROD,
    SelectedPlayer = nil
}

local fishingState = "ready" -- ready, waiting, reeling, cooldown
local isCasting = false
local isRetracting = false
local isWaitingForFish = false
local currentFishingDelay = CONFIG.COOLDOWN_DURATION

-- ================================
-- HELPER FUNCTIONS
-- ================================
local function notify(title, content, icon)
    Luna:Notification({
        Title = title,
        Content = content,
        Icon = icon or "info",
        ImageSource = "Material"
    })
end

local function getPlayerCharacter()
    return LocalPlayer.Character
end

local function getPlayerHumanoid()
    local character = getPlayerCharacter()
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function getHumanoidRootPart()
    local character = getPlayerCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function getBackpack()
    return LocalPlayer:FindFirstChild("Backpack")
end

local function getPlayerGui()
    return LocalPlayer:FindFirstChild("PlayerGui")
end

local function getFishingRod()
    local character = getPlayerCharacter()
    local backpack = getBackpack()
    local rod = character and character:FindFirstChild(getgenv().MizuConfig.SelectedRod)
    if not rod and backpack then
        rod = backpack:FindFirstChild(getgenv().MizuConfig.SelectedRod)
    end
    return rod
end

local function getFishingGui()
    local gui = getPlayerGui()
    return gui and gui:FindFirstChild("Fishing")
end

-- ================================
-- WALKSPEED FUNCTION
-- ================================
local function setWalkSpeed(speed)
    local humanoid = getPlayerHumanoid()
    if humanoid then
        humanoid.WalkSpeed = speed
    end
end

-- ================================
-- NO CLIP FUNCTION
-- ================================
local noClipConnection = nil
local function setupNoClip(enabled)
    if noClipConnection then
        noClipConnection:Disconnect()
        noClipConnection = nil
    end
    if enabled then
        noClipConnection = RunService.RenderStepped:Connect(function()
            local character = getPlayerCharacter()
            if not character then return end
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end
end

-- ================================
-- SELL FUNCTIONS
-- ================================
local function sellAllFish()
    local gui = getPlayerGui()
    local sellButton = gui and gui:FindFirstChild("SellFishes")
    if sellButton then
        firesignal(sellButton.MouseButton1Click)
        notify("Sukses", "Semua ikan telah dijual.", "check")
    else
        notify("Error", "Tombol jual ikan tidak ditemukan.", "error")
    end
end

local function sellAllOre()
    local gui = getPlayerGui()
    local sellButton = gui and gui:FindFirstChild("SellOres")
    if sellButton then
        firesignal(sellButton.MouseButton1Click)
        notify("Sukses", "Semua ore telah dijual.", "check")
    else
        notify("Error", "Tombol jual ore tidak ditemukan.", "error")
    end
end

-- ================================
-- AUTO ORE FARMING (LOOP)
-- ================================
task.spawn(function()
    while getgenv().MizuConfig.IsRunning do
        if getgenv().MizuConfig.InstantOre then
            pcall(function()
                GiveCrystal:InvokeServer(5.3574877270148)
            end)
        end
        task.wait(CONFIG.MINING_INTERVAL)
    end
end)

-- ================================
-- AUTO FISHING CORE
-- ================================
local function castFishingRod()
    local rod = getFishingRod()
    if not rod then return false end
    local humanoidRoot = getHumanoidRootPart()
    if not humanoidRoot then return false end
    local humanoid = getPlayerHumanoid()
    if not humanoid then return false end

    if rod.Parent == getBackpack() then
        humanoid:EquipTool(rod)
        task.wait(0.2)
    end

    local maxLength = rod:FindFirstChild("MaxLength") and rod.MaxLength.Value or 50
    local speed = rod:FindFirstChild("Speed") and rod.Speed.Value or 30

    RemoteThrow:FireServer(
        humanoidRoot.Position + humanoidRoot.CFrame.LookVector * maxLength,
        humanoidRoot.CFrame,
        maxLength,
        speed,
        LocalPlayer
    )

    humanoidRoot.Anchored = true
    isCasting = true
    isRetracting = true
    isWaitingForFish = false
    fishingState = "waiting"

    task.delay(CONFIG.FISHING_DELAY, function()
        if isRetracting and not isWaitingForFish then
            local fishingGui = getFishingGui()
            if fishingGui then
                local fishingButton = fishingGui:FindFirstChild("FishingButton")
                if fishingButton then
                    fishingButton.Position = UDim2.new(math.random() * 0.3 + 0.32, 0, math.random() * 0.17 + 0.4, 0)
                    fishingButton.Visible = true
                end
            end
            isWaitingForFish = true
        end
    end)
    return true
end

local function retractFishingRod()
    local humanoidRoot = getHumanoidRootPart()
    if humanoidRoot then
        RemoteRetract:FireServer(nil, humanoidRoot.CFrame, LocalPlayer)
        humanoidRoot.Anchored = false
    end
    isCasting = false
    isRetracting = false
    isWaitingForFish = false
    fishingState = "cooldown"
    task.delay(currentFishingDelay, function()
        fishingState = "ready"
    end)
end

local function handleAutoFishing()
    if not getgenv().MizuConfig.AutoFishing then return end
    local character = getPlayerCharacter()
    if not character then return end
    local humanoid = getPlayerHumanoid()
    local humanoidRoot = getHumanoidRootPart()
    if not humanoid or not humanoidRoot then return end

    if fishingState == "ready" then
        local rod = getFishingRod()
        if rod then castFishingRod() end
    elseif fishingState == "waiting" then
        local fishingGui = getFishingGui()
        if fishingGui then
            local fishingButton = fishingGui:FindFirstChild("FishingButton")
            if fishingButton and fishingButton.Visible then
                firesignal(fishingButton.MouseButton1Click)
                isWaitingForFish = false
                fishingState = "reeling"
            end
        end
    elseif fishingState == "reeling" then
        local fishingGui = getFishingGui()
        if fishingGui then
            local redBar = fishingGui:FindFirstChild("Red")
            local whiteBar = fishingGui:FindFirstChild("White")
            if redBar and whiteBar and fishingGui.Visible then
                -- Auto reeling handled by game? keep as is
            else
                if isWaitingForFish then retractFishingRod() end
            end
        else
            if isWaitingForFish then retractFishingRod() end
        end
    end
end

-- ================================
-- PLAYER FUNCTIONS
-- ================================
local function getPlayerList()
    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    return playerNames
end

local function findPlayerByName(playerName)
    return Players:FindFirstChild(playerName)
end

local function teleportToPlayer(targetPlayer)
    local targetCharacter = targetPlayer and targetPlayer.Character
    local localCharacter = getPlayerCharacter()
    if not targetCharacter or not localCharacter then return false end
    local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end
    local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
    if localRoot then
        localRoot.CFrame = targetRoot.CFrame + CONFIG.TELEPORT_OFFSET
        return true
    end
    return false
end

local function applyAvatarFromPlayer(targetPlayer)
    local targetCharacter = targetPlayer and targetPlayer.Character
    if not targetCharacter then return false end
    local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
    if not targetHumanoid then return false end
    local description = targetHumanoid:GetAppliedDescription()
    if not description then return false end

    local accessories = {}
    for _, child in ipairs(description:GetChildren()) do
        if child:IsA("AccessoryDescription") then
            table.insert(accessories, {
                Rotation = Vector3.zero,
                Position = Vector3.zero,
                Scale = Vector3.one,
                AssetId = child.AssetId,
                IsLayered = false,
                AccessoryType = Enum.AccessoryType.Hat
            })
        end
    end
    if description.Shirt ~= "" then
        table.insert(accessories, { AssetId = tonumber(description.Shirt), AccessoryType = Enum.AccessoryType.Shirt })
    end
    if description.Pants ~= "" then
        table.insert(accessories, { AssetId = tonumber(description.Pants), AccessoryType = Enum.AccessoryType.Pants })
    end

    CatalogApplyOutfit:FireServer({
        Accessories = accessories,
        Head = tonumber(description.Head) or 0,
        LeftArm = tonumber(description.LeftArm) or 0,
        RightArm = tonumber(description.RightArm) or 0,
        LeftLeg = tonumber(description.LeftLeg) or 0,
        RightLeg = tonumber(description.RightLeg) or 0,
        Torso = tonumber(description.Torso) or 0,
        Shirt = tonumber(description.Shirt) or 0,
        Pants = tonumber(description.Pants) or 0,
        GraphicTShirt = tonumber(description.GraphicTShirt) or 0,
        Face = tonumber(description.Face) or 0,
        BodyTypeScale = description.BodyTypeScale,
        DepthScale = description.DepthScale,
        HeightScale = description.HeightScale,
        WidthScale = description.WidthScale,
        ProportionScale = description.ProportionScale,
        HeadScale = description.HeadScale,
        LeftArmColor = description.LeftArmColor,
        RightArmColor = description.RightArmColor,
        LeftLegColor = description.LeftLegColor,
        RightLegColor = description.RightLegColor,
        TorsoColor = description.TorsoColor,
        HeadColor = description.HeadColor,
        IdleAnimation = tonumber(description.IdleAnimation) or 0,
        RunAnimation = tonumber(description.RunAnimation) or 0,
        WalkAnimation = tonumber(description.WalkAnimation) or 0,
        JumpAnimation = tonumber(description.JumpAnimation) or 0,
        ClimbAnimation = tonumber(description.ClimbAnimation) or 0,
        FallAnimation = tonumber(description.FallAnimation) or 0,
        SwimAnimation = tonumber(description.SwimAnimation) or 0
    })
    return true
end

local function resetToDefaultAvatar()
    local defaultDescription = Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId)
    if not defaultDescription then return false end
    CatalogApplyOutfit:FireServer({
        Accessories = {},
        Head = tonumber(defaultDescription.Head) or 0,
        LeftArm = tonumber(defaultDescription.LeftArm) or 0,
        RightArm = tonumber(defaultDescription.RightArm) or 0,
        LeftLeg = tonumber(defaultDescription.LeftLeg) or 0,
        RightLeg = tonumber(defaultDescription.RightLeg) or 0,
        Torso = tonumber(defaultDescription.Torso) or 0,
        Shirt = tonumber(defaultDescription.Shirt) or 0,
        Pants = tonumber(defaultDescription.Pants) or 0,
        GraphicTShirt = tonumber(defaultDescription.GraphicTShirt) or 0,
        Face = tonumber(defaultDescription.Face) or 0,
        BodyTypeScale = defaultDescription.BodyTypeScale,
        DepthScale = defaultDescription.DepthScale,
        HeightScale = defaultDescription.HeightScale,
        WidthScale = defaultDescription.WidthScale,
        ProportionScale = defaultDescription.ProportionScale,
        HeadScale = defaultDescription.HeadScale,
        LeftArmColor = defaultDescription.LeftArmColor,
        RightArmColor = defaultDescription.RightArmColor,
        LeftLegColor = defaultDescription.LeftLegColor,
        RightLegColor = defaultDescription.RightLegColor,
        TorsoColor = defaultDescription.TorsoColor,
        HeadColor = defaultDescription.HeadColor,
        IdleAnimation = tonumber(defaultDescription.IdleAnimation) or 0,
        RunAnimation = tonumber(defaultDescription.RunAnimation) or 0,
        WalkAnimation = tonumber(defaultDescription.WalkAnimation) or 0,
        JumpAnimation = tonumber(defaultDescription.JumpAnimation) or 0,
        ClimbAnimation = tonumber(defaultDescription.ClimbAnimation) or 0,
        FallAnimation = tonumber(defaultDescription.FallAnimation) or 0,
        SwimAnimation = tonumber(defaultDescription.SwimAnimation) or 0
    })
    return true
end

local function loadFlyScript()
    pcall(function()
        loadstring(game:HttpGetAsync("https://pastefy.app/heWTDAEO/raw"))()
    end)
end

local function setupAntiAFK()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new())
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new())
    end)
end

-- ================================
-- AUTO LOOP UNTUK FISHING
-- ================================
task.spawn(function()
    while getgenv().MizuConfig.IsRunning do
        handleAutoFishing()
        task.wait(0.1)
    end
end)

-- ================================
-- WALKSPEED APPLIER LOOP
-- ================================
task.spawn(function()
    while getgenv().MizuConfig.IsRunning do
        setWalkSpeed(getgenv().MizuConfig.WalkSpeed)
        task.wait(0.5)
    end
end)

-- ================================
-- NO CLIP APPLIER
-- ================================
task.spawn(function()
    while getgenv().MizuConfig.IsRunning do
        setupNoClip(getgenv().MizuConfig.NoClip)
        task.wait(0.5)
    end
end)

-- ================================
-- UI CREATION (LUNA)
-- ================================
local MainTab = Window:CreateTab({
    Name = "Main Features",
    Icon = "swords",
    ImageSource = "Material",
    ShowTitle = true
})

-- Farming Section
MainTab:CreateParagraph({
    Title = "Fish Farm",
    Text = "Otomatisasi memancing."
})
MainTab:CreateDropdown({
    Name = "Pilih Pancingan",
    Options = CONFIG.ROD_TYPES,
    CurrentOption = {CONFIG.DEFAULT_ROD},
    Callback = function(opt)
        getgenv().MizuConfig.SelectedRod = opt[1]
    end
})
MainTab:CreateToggle({
    Name = "Auto Fishing",
    CurrentValue = false,
    Callback = function(v)
        getgenv().MizuConfig.AutoFishing = v
        if not v then retractFishingRod() end
    end
})
MainTab:CreateButton({
    Name = "Jual Semua Ikan",
    Callback = sellAllFish
})
MainTab:CreateDivider()
MainTab:CreateParagraph({
    Title = "Ore Farm",
    Text = "Otomatisasi menambang ore."
})
MainTab:CreateToggle({
    Name = "Instant Ore",
    CurrentValue = false,
    Callback = function(v)
        getgenv().MizuConfig.InstantOre = v
    end
})
MainTab:CreateButton({
    Name = "Jual Semua Ore",
    Callback = sellAllOre
})

-- Misc Tab
local MiscTab = Window:CreateTab({
    Name = "Misc",
    Icon = "settings",
    ImageSource = "Material",
    ShowTitle = true
})
MiscTab:CreateParagraph({
    Title = "Pengaturan Karakter",
    Text = "Ubah properti karakter Anda."
})
MiscTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 100},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        getgenv().MizuConfig.WalkSpeed = v
    end
})
MiscTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(v)
        getgenv().MizuConfig.NoClip = v
    end
})
MiscTab:CreateDivider()
MiscTab:CreateParagraph({
    Title = "Utilitas Lain",
    Text = "Alat dan skrip tambahan."
})
MiscTab:CreateButton({
    Name = "Load Fly Script",
    Callback = loadFlyScript
})

-- Player Tab
local PlayerTab = Window:CreateTab({
    Name = "Player",
    Icon = "group",
    ImageSource = "Material",
    ShowTitle = true
})
PlayerTab:CreateParagraph({
    Title = "Pilih Player",
    Text = "Pilih player untuk berinteraksi."
})
local playerDropdown = PlayerTab:CreateDropdown({
    Name = "Pilih Player",
    Options = getPlayerList(),
    CurrentOption = {},
    Callback = function(opt)
        getgenv().MizuConfig.SelectedPlayer = opt[1]
    end
})
PlayerTab:CreateButton({
    Name = "Refresh Daftar Player",
    Callback = function()
        playerDropdown:SetOptions(getPlayerList())
        notify("Refresh", "Daftar player diperbarui.", "refresh")
    end
})
PlayerTab:CreateDivider()
PlayerTab:CreateParagraph({
    Title = "Aksi",
    Text = "Lakukan aksi pada player yang dipilih."
})
PlayerTab:CreateButton({
    Name = "Teleport ke Player",
    Callback = function()
        local target = findPlayerByName(getgenv().MizuConfig.SelectedPlayer)
        if target and teleportToPlayer(target) then
            notify("Teleport", "Berhasil teleport ke " .. target.Name, "move")
        else
            notify("Teleport", "Player tidak ditemukan atau tidak memiliki karakter.", "error")
        end
    end
})
PlayerTab:CreateButton({
    Name = "Salin & Terapkan Avatar",
    Callback = function()
        local target = findPlayerByName(getgenv().MizuConfig.SelectedPlayer)
        if not target then
            notify("Error", "Player tidak ditemukan.", "error")
            return
        end
        if applyAvatarFromPlayer(target) then
            notify("Sukses", "Avatar berhasil diterapkan!", "check")
        else
            notify("Error", "Gagal menyalin avatar.", "error")
        end
    end
})
PlayerTab:CreateButton({
    Name = "Reset ke Avatar Default",
    Callback = function()
        if resetToDefaultAvatar() then
            notify("Sukses", "Avatar berhasil direset!", "check")
        else
            notify("Error", "Gagal mereset avatar.", "error")
        end
    end
})

-- Theme Tab (WAJIB)
local ThemeTab = Window:CreateTab({
    Name = "Theme",
    Icon = "palette",
    ImageSource = "Material",
    ShowTitle = true
})
ThemeTab:BuildThemeSection()

-- Config Tab (WAJIB)
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
        Luna:Destroy()
    end
})

-- ================================
-- INITIALIZATION
-- ================================
setupAntiAFK()
notify("Mizukage System", "Script Indo Beach loaded. Ready, Master.", "verified")