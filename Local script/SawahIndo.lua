--[[═══════════════════════════════════════════════════════════
👑 MIZUKAGE OFFICIAL - UNIVERSAL BASE TEMPLATE
Target Game: Sawah Indo
Fitur Bawaan:
- Premium Dashboard & Aesthetic UI (WindUI)
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
local MarketplaceService = Services.MarketplaceService
local TweenService = Services.TweenService
local VirtualUser = Services.VirtualUser

--================================================
-- 2. KONFIGURASI GLOBAL
--================================================
getgenv().MizuConfig = {
    IsRunning = true,
    -- Sawah Indo Specific Config
    Farm = false,
    Egg = false,
    Milk = false,
    AllFarm = false,
    AllFarmPhase = "IDLE",
    Selling = true,
    SellEgg = false,
    SellMilk = false,
    SellFruit = false,
    NoDelay = false,
    AutoBuy = false,
    PlantAmount = 15,
    BurstAmount = 5,
    SellDelay = 60,
    MaxCrop = 15,
    SelectedCrop = "Padi",
    ActivePlot = nil,
    MemoryPos = nil,
    TPMode = "Memory",
    MyPlots = {},
    Session = { StartTime = os.clock(), TotalSold = 0, TotalEarned = 0 },
    PlantPause = 0,
    LastAutoTp = 0,
    AntiAFK = false,
    PadiPos = nil,
    SawitPos = nil,
    CoopPos = nil,
    BarnPos = nil
}

--================================================
-- 3. AUTO RECONNECT & ANTI-AFK
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

--================================================
-- 4. FUNGSI INTI (FUNGSI GAME BARU)
--================================================

-- 4.1 Remotes & Config Modules
local GameRemotes = ReplicatedStorage:WaitForChild("Remotes")
local TutorialRemotes = GameRemotes:WaitForChild("TutorialRemotes")
local CropConfig = require(ReplicatedStorage.Modules:WaitForChild("CropConfig"))

-- 4.2 File Constants
local FAV_PLOT_FILE = "mizu_sawah_plots.txt"
local ALL_FARM_FILE = "mizu_allfarm_pos.txt"

-- 4.3 Character Refs
local character = nil
local hum = nil
local root = nil

local function UpdateCharacter(char)
    character = char
    root = character and character:FindFirstChild("HumanoidRootPart")
    hum = character and character:FindFirstChildOfClass("Humanoid")
end

UpdateCharacter(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
LocalPlayer.CharacterAdded:Connect(UpdateCharacter)

-- 4.4 Helper Functions
local function FormatNumber(num)
    local str = tostring(math.floor(tonumber(num) or 0))
    local k
    while true do
        str, k = str:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
        if k == 0 then break end
    end
    return str
end

local function FirePrompt(prompt)
    if not prompt then return end
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            prompt:InputHoldBegin()
            task.wait(0.1)
            prompt:InputHoldEnd()
        end
    end)
end

local function TeleportTo(position)
    if root then
        root.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
        task.wait(0.4)
    end
end

local function SaveMemoryPosition()
    if root then
        getgenv().MizuConfig.MemoryPos = { pos = root.Position, savedAt = os.clock() }
        return true
    end
    return false
end

local function GetTeleportPosition()
    local cfg = getgenv().MizuConfig
    if cfg.TPMode == "Plot" and cfg.ActivePlot then
        return cfg.ActivePlot.pos
    end
    if cfg.TPMode == "Memory" and cfg.MemoryPos then
        return cfg.MemoryPos.pos
    end
    return nil
end

-- 4.5 File Load/Save
local function LoadFavPlots()
    local success, data = pcall(readfile, FAV_PLOT_FILE)
    if not success or not data or data == "" then return { favPlots = {} } end
    local plots = { favPlots = {} }
    for line in data:gmatch("[^\n]+") do
        local label, x, y, z = line:match("^(.+)|([%-%.%d]+)|([%-%.%d]+)|([%-%.%d]+)$")
        if label and x and y and z then
            table.insert(plots.favPlots, { label = label, pos = Vector3.new(tonumber(x), tonumber(y), tonumber(z)) })
        end
    end
    return plots
end

local function SaveFavPlots(data)
    local lines = {}
    for _, plot in ipairs(data.favPlots) do
        table.insert(lines, string.format("%s|%.3f|%.3f|%.3f", plot.label, plot.pos.X, plot.pos.Y, plot.pos.Z))
    end
    pcall(writefile, FAV_PLOT_FILE, table.concat(lines, "\n"))
end

local function SaveAllFarmPos(data)
    local lines = {}
    for key, pos in pairs(data) do
        if pos then
            table.insert(lines, string.format("%s|%.3f|%.3f|%.3f", key, pos.X, pos.Y, pos.Z))
        end
    end
    pcall(writefile, ALL_FARM_FILE, table.concat(lines, "\n"))
end

local function LoadAllFarmPos()
    local result = { padiPos = nil, sawitPos = nil, coopPos = nil, barnPos = nil }
    local success, data = pcall(readfile, ALL_FARM_FILE)
    if not success or not data or data == "" then return result end
    for line in data:gmatch("[^\n]+") do
        local key, x, y, z = line:match("^(.+)|([%-%.%d]+)|([%-%.%d]+)|([%-%.%d]+)$")
        if key then
            result[key] = Vector3.new(tonumber(x), tonumber(y), tonumber(z))
        end
    end
    return result
end

local SavedPlots = LoadFavPlots()
local SavedFarmPos = LoadAllFarmPos()

getgenv().MizuConfig.PadiPos = getgenv().MizuConfig.PadiPos or SavedFarmPos.padiPos
getgenv().MizuConfig.SawitPos = getgenv().MizuConfig.SawitPos or SavedFarmPos.sawitPos
getgenv().MizuConfig.CoopPos = getgenv().MizuConfig.CoopPos or SavedFarmPos.coopPos
getgenv().MizuConfig.BarnPos = getgenv().MizuConfig.BarnPos or SavedFarmPos.barnPos

-- 4.6 Crop Database
local CropList = {}
local CropDropdownList = {}
local CropKeyMap = {}

for seedName, data in pairs(CropConfig.Seeds) do
    local cropName = seedName
    if seedName == "Bibit Padi" then cropName = "Padi"
    elseif seedName == "Bibit Jagung" then cropName = "Jagung"
    elseif seedName == "Bibit Tomat" then cropName = "Tomat"
    elseif seedName == "Bibit Terong" then cropName = "Terong"
    elseif seedName == "Bibit Strawberry" then cropName = "Strawberry"
    elseif seedName == "Bibit Sawit" then cropName = "Sawit"
    elseif seedName == "Bibit Durian" then cropName = "Durian"
    end
    if data.HarvestItem then
        CropList[cropName] = {
            SeedName = seedName,
            HarvestItem = data.HarvestItem,
            Price = CropConfig.SellableItems and CropConfig.SellableItems[data.HarvestItem] and CropConfig.SellableItems[data.HarvestItem].SellPrice or 10,
            MinLevel = data.MinLevel or 1,
            Icon = data.Icon or "🌾"
        }
    end
end

local sortedCrops = {}
for key, data in pairs(CropList) do
    table.insert(sortedCrops, { key = key, level = data.MinLevel })
end
table.sort(sortedCrops, function(a, b) return a.level < b.level end)

for _, v in ipairs(sortedCrops) do
    local display = string.format("%s [lv.%d] %s", v.key, CropList[v.key].MinLevel, CropList[v.key].Icon)
    table.insert(CropDropdownList, display)
    CropKeyMap[display] = v.key
end

-- 4.7 Scan Functions
local function ScanCoopBarn()
    local coop, barn = nil, nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local owner = obj:GetAttribute("OwnerId") or obj:GetAttribute("Owner") or obj:GetAttribute("OwnerUserId")
        if owner and tostring(owner) == tostring(LocalPlayer.UserId) then
            local nameLower = string.lower(obj.Name or "")
            if string.find(nameLower, "coop") then
                if obj:IsA("Model") then
                    local primaryPart = obj.PrimaryPart
                    coop = primaryPart and primaryPart.Position or obj:GetBoundingBox().Position
                else
                    coop = obj.Position
                end
            elseif string.find(nameLower, "barn") then
                if obj:IsA("Model") then
                    local primaryPart = obj.PrimaryPart
                    barn = primaryPart and primaryPart.Position or obj:GetBoundingBox().Position
                else
                    barn = obj.Position
                end
            end
        end
    end
    return coop, barn
end

-- 4.8 Crop Counting
local function CountActiveCrops()
    local active = Workspace:FindFirstChild("ActiveCrops")
    if not active then return 0 end
    local count = 0
    local userId = tostring(LocalPlayer.UserId)
    for _, crop in ipairs(active:GetChildren()) do
        if string.match(crop.Name, "Crop_(%d+)_") == userId then
            count = count + 1
        end
    end
    return count
end

local function IsCropReady(crop)
    if crop:GetAttribute("IsReady") == true then return true end
    if crop:GetAttribute("Phase") == 3 then return true end
    for _, desc in ipairs(crop:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and desc.Enabled then
            local action = string.lower(desc.ActionText or "")
            if action == "panen" or action == "harvest" then return true end
        end
    end
    return false
end

-- 4.9 Seed Management
local function CountSeeds(cropData)
    if not cropData then return 0 end
    local count = 0
    local function checkContainer(container)
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") and string.find(item.Name, cropData.SeedName) then
                local qty = string.match(item.Name, "(%d+)$")
                count = count + (tonumber(qty) or 1)
            end
        end
    end
    if character then checkContainer(character) end
    checkContainer(LocalPlayer.Backpack)
    return count
end

local function BuySeeds(cropData, amount)
    if amount <= 0 or not cropData then return end
    pcall(function()
        TutorialRemotes.RequestShop:InvokeServer("BUY", cropData.SeedName, amount)
    end)
    task.wait(0.5)
end

local function EquipSeed(cropData)
    if not cropData or not hum then return false end
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") and string.find(tool.Name, cropData.SeedName) then return true end
        end
    end
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, cropData.SeedName) then
            hum:EquipTool(tool)
            task.wait(0.2)
            return true
        end
    end
    return false
end

-- 4.10 Planting
local function RandomOffset(center, radius)
    local angle = math.rad(math.random(0, 360))
    local dist = math.random() * (radius or 18) + 2
    return center + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
end

local function PlantCrop(cropName, centerPos)
    local cfg = getgenv().MizuConfig
    local cropData = CropList[cropName]
    if not cropData then return end
    if os.clock() < cfg.PlantPause then return end
    if CountActiveCrops() >= cfg.MaxCrop then return end
    if not centerPos then
        if not SaveMemoryPosition() then return end
        centerPos = GetTeleportPosition()
        if not centerPos then return end
    end
    local seedCount = CountSeeds(cropData)
    if seedCount < cfg.BurstAmount then
        if cfg.AutoBuy then BuySeeds(cropData, cfg.PlantAmount - seedCount) end
        if CountSeeds(cropData) == 0 then return end
    end
    if not EquipSeed(cropData) then return end
    local toPlant = math.min(cfg.BurstAmount, math.max(cfg.MaxCrop - CountActiveCrops(), 0))
    if toPlant == 0 then return end
    for i = 1, toPlant do
        if CountSeeds(cropData) == 0 then
            if cfg.AutoBuy then
                BuySeeds(cropData, cfg.PlantAmount)
                if not EquipSeed(cropData) then break end
            else
                break
            end
        end
        pcall(function()
            TutorialRemotes.PlantCrop:FireServer(RandomOffset(centerPos))
        end)
        task.wait(cfg.NoDelay and 0.1 or 0.3)
    end
end

-- 4.11 Harvest
local function HarvestInRadius(center, radius)
    if not root then return end
    local active = Workspace:FindFirstChild("ActiveCrops")
    if not active then return end
    local userId = tostring(LocalPlayer.UserId)
    for _, crop in ipairs(active:GetChildren()) do
        if string.match(crop.Name, "Crop_(%d+)_") == userId and IsCropReady(crop) then
            for _, prompt in ipairs(crop:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                    local promptParent = prompt.Parent
                    if promptParent and promptParent:IsA("BasePart") then
                        local distance = (promptParent.Position - center).Magnitude
                        if distance < radius then
                            FirePrompt(prompt)
                            task.wait(0.15)
                        end
                    end
                end
            end
        end
    end
end

-- 4.12 Selling
local function SellCrop(cropName)
    if not CropList[cropName] then return 0 end
    local success, result = pcall(function()
        return TutorialRemotes.RequestSell:InvokeServer("GET_LIST")
    end)
    if not success or type(result) ~= "table" or type(result.Items) ~= "table" then return 0 end
    for _, item in pairs(result.Items) do
        if type(item) == "table" and tonumber(item.Owned) then
            local name = item.Name or item.DisplayName or ""
            if string.find(name, CropList[cropName].HarvestItem) then
                local qty = tonumber(item.Owned)
                local price = tonumber(item.SellPrice) or CropList[cropName].Price or 0
                if qty and qty > 0 then
                    pcall(function()
                        TutorialRemotes.RequestSell:InvokeServer("SELL", name, qty)
                    end)
                    getgenv().MizuConfig.Session.TotalSold = getgenv().MizuConfig.Session.TotalSold + qty
                    getgenv().MizuConfig.Session.TotalEarned = getgenv().MizuConfig.Session.TotalEarned + (qty * price)
                    task.wait(0.2)
                end
                return qty or 0
            end
        end
    end
    return 0
end

local function SellAll()
    local cfg = getgenv().MizuConfig
    for cropName in pairs(CropList) do
        pcall(SellCrop, cropName)
    end
    if cfg.SellEgg then pcall(function() TutorialRemotes.RequestSell:InvokeServer("GET_EGG_LIST") end) end
    if cfg.SellMilk then pcall(function() TutorialRemotes.RequestSell:InvokeServer("GET_MILK_LIST") end) end
    if cfg.SellFruit then pcall(function() TutorialRemotes.RequestSell:InvokeServer("GET_FRUIT_LIST") end) end
end

-- 4.13 Animal Functions
local FastInteractCache = {}
local EggVisualCache = {}
local MilkVisualCache = {}

local function FeedAnimals(center, radius)
    if not root then return end
    for prompt in pairs(FastInteractCache) do
        if prompt and prompt.Parent and prompt.Enabled then
            local action = string.lower(prompt.ActionText or "")
            if string.find(action, "feed") then
                local parent = prompt.Parent
                if parent and parent:IsA("BasePart") then
                    local distance = (parent.Position - center).Magnitude
                    if distance < radius then
                        TeleportTo(parent.Position)
                        task.wait(0.1)
                        FirePrompt(prompt)
                        task.wait(0.5)
                    end
                end
            end
        end
    end
    TeleportTo(center)
end

local function CollectAnimals(center, radius)
    if not root then return end
    for prompt in pairs(FastInteractCache) do
        if prompt and prompt.Parent and prompt.Enabled then
            local action = string.lower(prompt.ActionText or "")
            if string.find(action, "collect") then
                local parent = prompt.Parent
                if parent and parent:IsA("BasePart") then
                    local distance = (parent.Position - center).Magnitude
                    if distance < radius then
                        TeleportTo(parent.Position)
                        task.wait(0.1)
                        FirePrompt(prompt)
                        task.wait(0.5)
                    end
                end
            end
        end
    end
    TeleportTo(center)
end

-- 4.14 Auto Collect Loops
local function AutoEggLoop()
    if not root then return end
    for egg in pairs(EggVisualCache) do
        if egg and egg.Parent then
            local prompt = egg:FindFirstChildOfClass("ProximityPrompt")
            if prompt and prompt.Enabled then
                if root and (root.Position - egg.Position).Magnitude < 35 then
                    FirePrompt(prompt)
                    task.wait(0.15)
                end
            end
        else
            EggVisualCache[egg] = nil
        end
    end
end

local function AutoMilkLoop()
    if not root then return end
    for milk in pairs(MilkVisualCache) do
        if milk and milk.Parent then
            local prompt = milk:FindFirstChildOfClass("ProximityPrompt")
            if prompt and prompt.Enabled then
                if root and (root.Position - milk.Position).Magnitude < 35 then
                    FirePrompt(prompt)
                    task.wait(0.15)
                end
            end
        else
            MilkVisualCache[milk] = nil
        end
    end
end

-- 4.15 Main Loops
local function StartPlantLoop(flagName, cropName, centerPos)
    task.spawn(function()
        while getgenv().MizuConfig[flagName] do
            PlantCrop(cropName, centerPos)
            task.wait(0.3)
        end
    end)
end

local function StartHarvestLoop(flagName)
    task.spawn(function()
        while getgenv().MizuConfig[flagName] do
            pcall(function()
                local pos = GetTeleportPosition()
                if pos then HarvestInRadius(pos, 80) end
            end)
            task.wait(0.4)
        end
    end)
end

local function StartSellLoop(flagName)
    task.spawn(function()
        while getgenv().MizuConfig[flagName] do
            if getgenv().MizuConfig.Selling then
                SellCrop(getgenv().MizuConfig.SelectedCrop)
            end
            if getgenv().MizuConfig.SellEgg then pcall(function() TutorialRemotes.RequestSell:InvokeServer("GET_EGG_LIST") end) end
            if getgenv().MizuConfig.SellMilk then pcall(function() TutorialRemotes.RequestSell:InvokeServer("GET_MILK_LIST") end) end
            if getgenv().MizuConfig.SellFruit then pcall(function() TutorialRemotes.RequestSell:InvokeServer("GET_FRUIT_LIST") end) end
            for i = 1, (getgenv().MizuConfig.SellDelay or 60) do
                if not getgenv().MizuConfig[flagName] then return end
                task.wait(1)
            end
        end
    end)
end

local function StartEggLoop(flagName)
    task.spawn(function()
        while getgenv().MizuConfig[flagName] do
            pcall(AutoEggLoop)
            task.wait(0.8)
        end
    end)
end

local function StartMilkLoop(flagName)
    task.spawn(function()
        while getgenv().MizuConfig[flagName] do
            pcall(AutoMilkLoop)
            task.wait(0.8)
        end
    end)
end

local function StartAutoTP(flagName)
    task.spawn(function()
        while getgenv().MizuConfig[flagName] do
            if not getgenv().MizuConfig.AllFarm then
                local pos = GetTeleportPosition()
                if pos and os.clock() - getgenv().MizuConfig.LastAutoTp > 60 then
                    TeleportTo(pos)
                    getgenv().MizuConfig.LastAutoTp = os.clock()
                end
            end
            task.wait(5)
        end
    end)
end

-- 4.16 All Farm Loop
local function AllFarmLoop()
    task.spawn(function()
        while getgenv().MizuConfig.AllFarm do
            pcall(SellAll)
            for i = 1, 60 do
                if not getgenv().MizuConfig.AllFarm then return end
                task.wait(1)
            end
        end
    end)
    
    while getgenv().MizuConfig.AllFarm do
        local cfg = getgenv().MizuConfig
        -- Phase 1: Padi
        local padiPos = cfg.PadiPos
        if padiPos then
            cfg.AllFarmPhase = "PADI"
            TeleportTo(padiPos)
            local start = os.clock()
            while os.clock() - start < 2 and cfg.AllFarm do
                pcall(PlantCrop, cfg.SelectedCrop, padiPos)
                pcall(HarvestInRadius, padiPos, 80)
                task.wait(0.15)
            end
        end
        
        if not cfg.AllFarm then break end
        
        -- Phase 2: Sawit + Durian
        local sawitPos = cfg.SawitPos
        if sawitPos then
            cfg.AllFarmPhase = "SAWIT"
            TeleportTo(sawitPos)
            task.wait(0.3)
            pcall(function()
                local cropData = CropList["Sawit"]
                if cropData and CountSeeds(cropData) > 0 and EquipSeed(cropData) then
                    TutorialRemotes.PlantCrop:FireServer(root.Position)
                end
            end)
            task.wait(0.3)
            if root then
                root.CFrame = root.CFrame + Vector3.new(4, 0, 0)
                task.wait(0.2)
                pcall(function()
                    local cropData = CropList["Durian"]
                    if cropData and CountSeeds(cropData) > 0 and EquipSeed(cropData) then
                        TutorialRemotes.PlantCrop:FireServer(root.Position)
                    end
                end)
                task.wait(0.3)
            end
            pcall(HarvestInRadius, sawitPos, 80)
            task.wait(0.3)
            TeleportTo(sawitPos)
        end
        
        if not cfg.AllFarm then break end
        
        -- Phase 3: Coop
        local coopPos = cfg.CoopPos
        if coopPos then
            cfg.AllFarmPhase = "COOP"
            TeleportTo(coopPos)
            task.wait(0.3)
            pcall(FeedAnimals, coopPos, 70)
            task.wait(0.3)
            pcall(CollectAnimals, coopPos, 70)
        end
        
        if not cfg.AllFarm then break end
        
        -- Phase 4: Barn
        local barnPos = cfg.BarnPos
        if barnPos then
            cfg.AllFarmPhase = "BARN"
            TeleportTo(barnPos)
            task.wait(0.3)
            pcall(FeedAnimals, barnPos, 70)
            task.wait(0.3)
            pcall(CollectAnimals, barnPos, 70)
        end
    end
    
    getgenv().MizuConfig.AllFarmPhase = "IDLE"
end

-- 4.17 Auto Click Confirm
local function SetupConfirmClicker()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local function WatchConfirm(gui)
        task.spawn(function()
            task.wait(0.05)
            pcall(function()
                local overlay = gui:FindFirstChild("ConfirmOverlay")
                if not overlay or not overlay.Visible then return end
                local card = overlay:FindFirstChild("ConfirmCard")
                if not card or not card.Visible then return end
                local yesBtn = card:FindFirstChild("YesButton")
                if not yesBtn or not yesBtn.Visible then return end
                pcall(function() yesBtn.MouseButton1Click:Fire() end)
                pcall(function() yesBtn.Activated:Fire() end)
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(yesBtn.AbsolutePosition + yesBtn.AbsoluteSize / 2)
            end)
        end)
    end
    local confirmGui = playerGui:FindFirstChild("ConfirmGui")
    if confirmGui then WatchConfirm(confirmGui) end
    playerGui.ChildAdded:Connect(function(child)
        if child.Name == "ConfirmGui" then WatchConfirm(child) end
    end)
end

-- 4.18 Prompt Cache Setup
local function SetupPromptCache()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            FastInteractCache[obj] = true
            if getgenv().MizuConfig.NoDelay and obj.HoldDuration > 0 then
                obj.HoldDuration = 0
            end
        elseif obj:IsA("BasePart") then
            local name = obj.Name or ""
            if string.find(name, "EggVisual") then
                EggVisualCache[obj] = true
            elseif string.find(name, "MilkVisual") then
                MilkVisualCache[obj] = true
            end
        end
    end
end

-- 4.19 Event Connections
local function SetupEventConnections()
    TutorialRemotes.Notification.OnClientEvent:Connect(function(msg)
        if type(msg) ~= "string" then return end
        if string.find(msg, "Maximum 15 crops") then
            getgenv().MizuConfig.PlantPause = os.clock() + 30
        end
    end)
    
    Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("ProximityPrompt") then
            FastInteractCache[obj] = true
            if getgenv().MizuConfig.NoDelay and obj.HoldDuration > 0 then
                obj.HoldDuration = 0
            end
        elseif obj:IsA("BasePart") then
            local name = obj.Name or ""
            if string.find(name, "EggVisual") then
                EggVisualCache[obj] = true
            elseif string.find(name, "MilkVisual") then
                MilkVisualCache[obj] = true
            end
        end
    end)
    
    Workspace.DescendantRemoving:Connect(function(obj)
        FastInteractCache[obj] = nil
        EggVisualCache[obj] = nil
        MilkVisualCache[obj] = nil
    end)
    
    task.spawn(function()
        while task.wait(10) do
            if getgenv().MizuConfig.NoDelay then
                for prompt in pairs(FastInteractCache) do
                    if prompt and prompt.HoldDuration > 0 then
                        prompt.HoldDuration = 0
                    end
                end
            end
        end
    end)
end

-- 4.20 Core Loop Handler (StartAutoFarm)
local function StartAutoFarm()
    -- All Farm Loop
    task.spawn(function()
        while getgenv().MizuConfig.IsRunning do
            if getgenv().MizuConfig.AllFarm then
                AllFarmLoop()
            end
            task.wait(1)
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

    local TabAllFarm = Window:Tab({
        Title = "All Farm",
        Icon = "rocket"
    })

    local TabTanaman = Window:Tab({
        Title = "Tanaman",
        Icon = "grass"
    })

    local TabTernak = Window:Tab({
        Title = "Ternak",
        Icon = "pets"
    })

    local TabTP = Window:Tab({
        Title = "TP Manager",
        Icon = "map"
    })

    local TabPlot = Window:Tab({
        Title = "Plot Manager",
        Icon = "list"
    })

    local TabUtil = Window:Tab({
        Title = "Utilities",
        Icon = "settings"
    })

    -- =================== TAB BERANDA ===================
    local BerandaSection = TabBeranda:Section({
        Title = "Profil & Keamanan"
    })

    BerandaSection:Paragraph({
        Title = "Selamat Datang, " .. LocalPlayer.DisplayName,
        Desc = "Script Sawah Indo siap digunakan."
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

    -- =================== TAB ALL FARM ===================
    local AllFarmSetup = TabAllFarm:Section({ Title = "Setup Koordinat" })
    AllFarmSetup:Paragraph({ Title = "SETUP KOORDINAT", Desc = "Pergi ke setiap lokasi lalu klik tombol Simpan" })

    AllFarmSetup:Dropdown({
        Title = "Pilih Tanaman (Phase 1)",
        Values = CropDropdownList,
        Value = {CropDropdownList[1] or "Padi [lv.1] 🌾"},
        Callback = function(choice)
            Sounds:Click()
            getgenv().MizuConfig.SelectedCrop = CropKeyMap[choice[1]] or "Padi"
        end
    })

    AllFarmSetup:Button({
        Title = "Simpan Koordinat Tanam",
        Callback = function()
            Sounds:Click()
            if not root then return end
            getgenv().MizuConfig.PadiPos = root.Position
            SavedFarmPos.padiPos = root.Position
            SaveAllFarmPos(SavedFarmPos)
        end
    })

    AllFarmSetup:Button({
        Title = "Simpan Koordinat Sawit",
        Callback = function()
            Sounds:Click()
            if not root then return end
            getgenv().MizuConfig.SawitPos = root.Position
            SavedFarmPos.sawitPos = root.Position
            SaveAllFarmPos(SavedFarmPos)
        end
    })

    AllFarmSetup:Button({
        Title = "Refresh Kandang",
        Callback = function()
            Sounds:Click()
            task.spawn(function()
                local coop, barn = ScanCoopBarn()
                if coop then
                    getgenv().MizuConfig.CoopPos = coop
                    SavedFarmPos.coopPos = coop
                end
                if barn then
                    getgenv().MizuConfig.BarnPos = barn
                    SavedFarmPos.barnPos = barn
                end
                SaveAllFarmPos(SavedFarmPos)
            end)
        end
    })

    local AllFarmControl = TabAllFarm:Section({ Title = "Kontrol All Farm" })

    AllFarmControl:Toggle({
        Title = "AUTO FARM ALL",
        Default = false,
        Callback = function(state)
            Sounds:Click()
            local cfg = getgenv().MizuConfig
            cfg.AllFarm = state
            cfg.Farm = false
            cfg.Egg = false
            cfg.Milk = false
            if state and not cfg.PadiPos then
                cfg.AllFarm = false
            end
        end
    })

    AllFarmControl:Button({
        Title = "Jual Semua Sekarang",
        Callback = function()
            Sounds:Click()
            task.spawn(SellAll)
        end
    })

    -- =================== TAB TANAMAN ===================
    local TanamanConfig = TabTanaman:Section({ Title = "Konfigurasi Tanaman" })

    TanamanConfig:Dropdown({
        Title = "Target Tanaman",
        Values = CropDropdownList,
        Value = {CropDropdownList[1] or "Padi [lv.1] 🌾"},
        Callback = function(choice)
            Sounds:Click()
            getgenv().MizuConfig.SelectedCrop = CropKeyMap[choice[1]] or "Padi"
        end
    })

    TanamanConfig:Input({
        Title = "Maks Bibit di Tas",
        Value = "15",
        Callback = function(v) getgenv().MizuConfig.PlantAmount = tonumber(v) or 15 end
    })

    TanamanConfig:Input({
        Title = "Max Crop Aktif",
        Value = "15",
        Callback = function(v) getgenv().MizuConfig.MaxCrop = tonumber(v) or 15 end
    })

    TanamanConfig:Input({
        Title = "Seed per Burst",
        Value = "5",
        Callback = function(v) getgenv().MizuConfig.BurstAmount = tonumber(v) or 5 end
    })

    TanamanConfig:Input({
        Title = "Auto Sell Delay",
        Value = "60",
        Callback = function(v) getgenv().MizuConfig.SellDelay = math.floor(tonumber(v) or 60) end
    })

    local TanamanControl = TabTanaman:Section({ Title = "Kontrol Tanaman" })

    TanamanControl:Toggle({
        Title = "Auto Farm Tanaman",
        Default = false,
        Callback = function(state)
            Sounds:Click()
            local cfg = getgenv().MizuConfig
            cfg.Farm = state
            if state and cfg.AllFarm then
                cfg.Farm = false
                return
            end
            if state then
                SaveMemoryPosition()
                StartPlantLoop("Farm", cfg.SelectedCrop, GetTeleportPosition())
                StartHarvestLoop("Farm")
                StartSellLoop("Farm")
                StartAutoTP("Farm")
            end
        end
    })

    TanamanControl:Toggle({ Title = "Auto Beli Bibit", Default = false, Callback = function(v) getgenv().MizuConfig.AutoBuy = v end })
    TanamanControl:Toggle({ Title = "Auto Jual Tanaman", Default = true, Callback = function(v) getgenv().MizuConfig.Selling = v end })
    TanamanControl:Button({ Title = "Jual Tanaman Sekarang", Callback = function() Sounds:Click(); task.spawn(function() SellCrop(getgenv().MizuConfig.SelectedCrop) end) end })

    -- =================== TAB TERNAK ===================
    local TernakEgg = TabTernak:Section({ Title = "Auto Egg" })
    TernakEgg:Toggle({
        Title = "Auto Collect Telur",
        Default = false,
        Callback = function(state)
            Sounds:Click()
            local cfg = getgenv().MizuConfig
            cfg.Egg = state
            if state and cfg.AllFarm then cfg.Egg = false; return end
            if state then StartEggLoop("Egg") end
        end
    })
    TernakEgg:Toggle({ Title = "Auto Jual Telur", Default = false, Callback = function(v) getgenv().MizuConfig.SellEgg = v end })
    TernakEgg:Button({ Title = "Jual Telur Sekarang", Callback = function() Sounds:Click(); task.spawn(function() TutorialRemotes.RequestSell:InvokeServer("GET_EGG_LIST") end) end })

    local TernakMilk = TabTernak:Section({ Title = "Auto Milk" })
    TernakMilk:Toggle({
        Title = "Auto Collect Susu",
        Default = false,
        Callback = function(state)
            Sounds:Click()
            local cfg = getgenv().MizuConfig
            cfg.Milk = state
            if state and cfg.AllFarm then cfg.Milk = false; return end
            if state then StartMilkLoop("Milk") end
        end
    })
    TernakMilk:Toggle({ Title = "Auto Jual Susu", Default = false, Callback = function(v) getgenv().MizuConfig.SellMilk = v end })
    TernakMilk:Button({ Title = "Jual Susu Sekarang", Callback = function() Sounds:Click(); task.spawn(function() TutorialRemotes.RequestSell:InvokeServer("GET_MILK_LIST") end) end })

    local TernakFruit = TabTernak:Section({ Title = "Auto Fruit" })
    TernakFruit:Toggle({ Title = "Auto Jual Buah", Default = false, Callback = function(v) getgenv().MizuConfig.SellFruit = v end })
    TernakFruit:Button({ Title = "Jual Buah Sekarang", Callback = function() Sounds:Click(); task.spawn(function() TutorialRemotes.RequestSell:InvokeServer("GET_FRUIT_LIST") end) end })

    -- =================== TAB TP MANAGER ===================
    local TPMode = TabTP:Section({ Title = "Mode Auto TP" })
    TPMode:Toggle({
        Title = "Smart Memory TP",
        Default = true,
        Callback = function(state)
            Sounds:Click()
            getgenv().MizuConfig.TPMode = state and "Memory" or "Plot"
            if state and not getgenv().MizuConfig.MemoryPos then SaveMemoryPosition() end
        end
    })

    local TPPlot = TabTP:Section({ Title = "Plot Aktif" })
    local plotList = { "(pilih plot)" }
    for _, plot in ipairs(SavedPlots.favPlots) do
        table.insert(plotList, plot.label)
    end
    TPPlot:Dropdown({
        Title = "Pilih Plot Aktif",
        Values = plotList,
        Value = {"(pilih plot)"},
        Callback = function(choice)
            Sounds:Click()
            if choice[1] == "(pilih plot)" then
                getgenv().MizuConfig.ActivePlot = nil
                return
            end
            for _, plot in ipairs(SavedPlots.favPlots) do
                if plot.label == choice[1] then
                    getgenv().MizuConfig.ActivePlot = plot
                    TeleportTo(plot.pos)
                    getgenv().MizuConfig.LastAutoTp = os.clock()
                    break
                end
            end
        end
    })

    local TPMem = TabTP:Section({ Title = "Memory Position" })
    TPMem:Button({
        Title = "Update Memory Position",
        Callback = function()
            Sounds:Click()
            SaveMemoryPosition()
        end
    })
    TPMem:Button({
        Title = "TP ke Memory Position",
        Callback = function()
            Sounds:Click()
            if getgenv().MizuConfig.MemoryPos then
                TeleportTo(getgenv().MizuConfig.MemoryPos.pos)
            end
        end
    })

    -- =================== TAB PLOT MANAGER ===================
    local PlotDel = TabPlot:Section({ Title = "Hapus Plot" })
    PlotDel:Dropdown({
        Title = "Pilih Plot untuk Dihapus",
        Values = plotList,
        Value = {"(pilih plot)"},
        Callback = function() end
    })
    PlotDel:Button({
        Title = "Hapus Plot Dipilih",
        Callback = function()
            Sounds:Click()
        end
    })

    local PlotAdd = TabPlot:Section({ Title = "Tambah Plot Baru" })
    PlotAdd:Input({ Title = "Nama Plot (opsional)", Value = "", Placeholder = "Nama plot...", Callback = function() end })
    PlotAdd:Button({
        Title = "Simpan Posisi Sekarang",
        Callback = function()
            Sounds:Click()
            if not root then return end
            local name = "Plot " .. (#SavedPlots.favPlots + 1)
            table.insert(SavedPlots.favPlots, { label = name, pos = root.Position })
            SaveFavPlots(SavedPlots)
        end
    })

    -- =================== TAB UTILITIES ===================
    local UtilMain = TabUtil:Section({ Title = "Utilitas" })
    UtilMain:Toggle({ Title = "Fast Interact", Default = false, Callback = function(v) getgenv().MizuConfig.NoDelay = v end })
    UtilMain:Toggle({ Title = "Anti AFK", Default = false, Callback = function(v) getgenv().MizuConfig.AntiAFK = v end })
    UtilMain:Button({
        Title = "Reset Statistik",
        Callback = function()
            Sounds:Click()
            getgenv().MizuConfig.Session = { StartTime = os.clock(), TotalSold = 0, TotalEarned = 0 }
            getgenv().MizuConfig.MyPlots = {}
        end
    })

    WindUI:Notify({
        Title = "TeamMizu🔰 dimari",
        Content = "Script Sawah Indo berhasil di-inject!",
        Duration = 5
    })
end

--================================================
-- 6. BOOTSTRAP EKSEKUSI
--================================================
SetupAutoReconnect()
SetupPromptCache()
SetupEventConnections()
SetupConfirmClicker()

task.spawn(function()
    task.wait(2)
    if not getgenv().MizuConfig.MemoryPos then SaveMemoryPosition() end
end)

-- Panggil fungsi-fungsi core barumu di sini
StartAutoFarm()

-- Eksekusi UI
task.spawn(InitInterface)
