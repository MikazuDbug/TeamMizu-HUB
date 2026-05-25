-- Mizukage Official | TeamMizu🔰 - All rights reserved
-- Game: Sawah Indo
-- Script rebuilt by MIZU-OS v14.0

-- LOAD LUNA (WAJIB)
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- BUAT WINDOW UTAMA
local Window = Luna:CreateWindow({
    Name = "Mizukage Official",
    Subtitle = "Sawah Indo - TeamMizu🔰",
    LogoID = "104266190557772",
    LoadingEnabled = true,
    LoadingTitle = "Mizukage System",
    LoadingSubtitle = "by @MizukageOfficial",
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "MizukageHub/SawahIndo"
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
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local MarketplaceService = game:GetService("MarketplaceService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- ============================================
-- REMOTES
-- ============================================
local GameRemotes = ReplicatedStorage:WaitForChild("Remotes")
local TutorialRemotes = GameRemotes:WaitForChild("TutorialRemotes")

-- ============================================
-- CONFIG MODULES
-- ============================================
local CropConfig = require(ReplicatedStorage.Modules:WaitForChild("CropConfig"))
local EggConfig = require(ReplicatedStorage.Modules:WaitForChild("EggConfig"))

-- ============================================
-- FILE CONSTANTS
-- ============================================
local FAV_PLOT_FILE = "mizu_sawah_plots.txt"
local ALL_FARM_FILE = "mizu_allfarm_pos.txt"

-- ============================================
-- GLOBAL STATE (getgenv)
-- ============================================
local G = getgenv()
G.Mizu_Farm = G.Mizu_Farm or false
G.Mizu_Egg = G.Mizu_Egg or false
G.Mizu_Milk = G.Mizu_Milk or false
G.Mizu_AllFarm = G.Mizu_AllFarm or false
G.Mizu_AllFarmPhase = G.Mizu_AllFarmPhase or "IDLE"
G.Mizu_Selling = G.Mizu_Selling ~= false
G.Mizu_SellEgg = G.Mizu_SellEgg ~= false
G.Mizu_SellMilk = G.Mizu_SellMilk ~= false
G.Mizu_SellFruit = G.Mizu_SellFruit ~= false
G.Mizu_NoDelay = G.Mizu_NoDelay ~= false
G.Mizu_AutoBuy = G.Mizu_AutoBuy ~= false
G.Mizu_PlantAmount = G.Mizu_PlantAmount or 15
G.Mizu_BurstAmount = G.Mizu_BurstAmount or 5
G.Mizu_SellDelay = G.Mizu_SellDelay or 60
G.Mizu_MaxCrop = G.Mizu_MaxCrop or 15
G.Mizu_SelectedCrop = G.Mizu_SelectedCrop or "Padi"
G.Mizu_ActivePlot = G.Mizu_ActivePlot or nil
G.Mizu_MemoryPos = G.Mizu_MemoryPos or nil
G.Mizu_TPMode = G.Mizu_TPMode or "Memory"
G.Mizu_MyPlots = G.Mizu_MyPlots or {}
G.Mizu_Session = G.Mizu_Session or { StartTime = os.clock(), TotalSold = 0, TotalEarned = 0 }
G.Mizu_PlantPause = G.Mizu_PlantPause or 0
G.Mizu_LastAutoTp = G.Mizu_LastAutoTp or 0
G.Mizu_AntiAFK = G.Mizu_AntiAFK or false
G.Mizu_PadiPos = G.Mizu_PadiPos or nil
G.Mizu_SawitPos = G.Mizu_SawitPos or nil
G.Mizu_CoopPos = G.Mizu_CoopPos or nil
G.Mizu_BarnPos = G.Mizu_BarnPos or nil

-- ============================================
-- CHARACTER REFS
-- ============================================
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

-- ============================================
-- HELPER FUNCTIONS
-- ============================================
local function FormatNumber(num)
    local str = tostring(math.floor(tonumber(num) or 0))
    local k
    while true do
        str, k = str:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
        if k == 0 then break end
    end
    return str
end

local function GetHumanoidRootPart()
    return root
end

local function GetHumanoid()
    return hum
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
        G.Mizu_MemoryPos = { pos = root.Position, savedAt = os.clock() }
        return true
    end
    return false
end

local function GetTeleportPosition()
    if G.Mizu_TPMode == "Plot" and G.Mizu_ActivePlot then
        return G.Mizu_ActivePlot.pos
    end
    if G.Mizu_TPMode == "Memory" and G.Mizu_MemoryPos then
        return G.Mizu_MemoryPos.pos
    end
    return nil
end

-- ============================================
-- FILE LOAD/SAVE FUNCTIONS
-- ============================================
local function LoadFavPlots()
    local success, data = pcall(readfile, FAV_PLOT_FILE)
    if not success or not data or data == "" then
        return { favPlots = {} }
    end
    
    local plots = { favPlots = {} }
    for line in data:gmatch("[^\n]+") do
        local label, x, y, z = line:match("^(.+)|([%-%.%d]+)|([%-%.%d]+)|([%-%.%d]+)$")
        if label and x and y and z then
            table.insert(plots.favPlots, {
                label = label,
                pos = Vector3.new(tonumber(x), tonumber(y), tonumber(z))
            })
        end
    end
    return plots
end

local function SaveFavPlots(data)
    local lines = {}
    for _, plot in ipairs(data.favPlots) do
        table.insert(lines, string.format("%s|%.3f|%.3f|%.3f", 
            plot.label, plot.pos.X, plot.pos.Y, plot.pos.Z))
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
    if not success or not data or data == "" then 
        return result 
    end
    
    for line in data:gmatch("[^\n]+") do
        local key, x, y, z = line:match("^(.+)|([%-%.%d]+)|([%-%.%d]+)|([%-%.%d]+)$")
        if key then
            result[key] = Vector3.new(tonumber(x), tonumber(y), tonumber(z))
        end
    end
    return result
end

-- Load saved data
local SavedPlots = LoadFavPlots()
local SavedFarmPos = LoadAllFarmPos()

G.Mizu_PadiPos = G.Mizu_PadiPos or SavedFarmPos.padiPos
G.Mizu_SawitPos = G.Mizu_SawitPos or SavedFarmPos.sawitPos
G.Mizu_CoopPos = G.Mizu_CoopPos or SavedFarmPos.coopPos
G.Mizu_BarnPos = G.Mizu_BarnPos or SavedFarmPos.barnPos

-- ============================================
-- CROP DATABASE
-- ============================================
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
            Price = CropConfig.SellableItems and CropConfig.SellableItems[data.HarvestItem] and 
                    CropConfig.SellableItems[data.HarvestItem].SellPrice or 10,
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

-- ============================================
-- SCAN FUNCTIONS
-- ============================================
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

-- ============================================
-- CROP COUNTING
-- ============================================
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
            if action == "panen" or action == "harvest" then
                return true
            end
        end
    end
    return false
end

-- ============================================
-- SEED MANAGEMENT
-- ============================================
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
            if tool:IsA("Tool") and string.find(tool.Name, cropData.SeedName) then
                return true
            end
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

-- ============================================
-- PLANTING FUNCTIONS
-- ============================================
local function RandomOffset(center, radius)
    local angle = math.rad(math.random(0, 360))
    local dist = math.random() * (radius or 18) + 2
    return center + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
end

local function PlantCrop(cropName, centerPos)
    local cropData = CropList[cropName]
    if not cropData then return end
    
    if os.clock() < G.Mizu_PlantPause then return end
    
    if CountActiveCrops() >= G.Mizu_MaxCrop then return end
    
    if not centerPos then
        if not SaveMemoryPosition() then return end
        centerPos = GetTeleportPosition()
        if not centerPos then return end
    end
    
    local seedCount = CountSeeds(cropData)
    if seedCount < G.Mizu_BurstAmount then
        if G.Mizu_AutoBuy then
            BuySeeds(cropData, G.Mizu_PlantAmount - seedCount)
        end
        if CountSeeds(cropData) == 0 then return end
    end
    
    if not EquipSeed(cropData) then return end
    
    local toPlant = math.min(G.Mizu_BurstAmount, math.max(G.Mizu_MaxCrop - CountActiveCrops(), 0))
    if toPlant == 0 then return end
    
    for i = 1, toPlant do
        if CountSeeds(cropData) == 0 then
            if G.Mizu_AutoBuy then
                BuySeeds(cropData, G.Mizu_PlantAmount)
                if not EquipSeed(cropData) then break end
            else
                break
            end
        end
        
        pcall(function()
            TutorialRemotes.PlantCrop:FireServer(RandomOffset(centerPos))
        end)
        task.wait(G.Mizu_NoDelay and 0.1 or 0.3)
    end
end

-- ============================================
-- HARVEST FUNCTIONS
-- ============================================
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

-- ============================================
-- SELLING FUNCTIONS
-- ============================================
local function SellCrop(cropName)
    if not CropList[cropName] then return 0 end
    
    local success, result = pcall(function()
        return TutorialRemotes.RequestSell:InvokeServer("GET_LIST")
    end)
    
    if not success or type(result) ~= "table" or type(result.Items) ~= "table" then
        return 0
    end
    
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
                    
                    G.Mizu_Session.TotalSold = G.Mizu_Session.TotalSold + qty
                    G.Mizu_Session.TotalEarned = G.Mizu_Session.TotalEarned + (qty * price)
                    task.wait(0.2)
                end
                return qty or 0
            end
        end
    end
    
    return 0
end

local function SellAll()
    for cropName in pairs(CropList) do
        pcall(SellCrop, cropName)
    end
    
    if G.Mizu_SellEgg then 
        pcall(function() 
            TutorialRemotes.RequestSell:InvokeServer("GET_EGG_LIST") 
        end) 
    end
    
    if G.Mizu_SellMilk then 
        pcall(function() 
            TutorialRemotes.RequestSell:InvokeServer("GET_MILK_LIST") 
        end) 
    end
    
    if G.Mizu_SellFruit then 
        pcall(function() 
            TutorialRemotes.RequestSell:InvokeServer("GET_FRUIT_LIST") 
        end) 
    end
end

-- ============================================
-- ANIMAL FUNCTIONS
-- ============================================
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

-- ============================================
-- AUTO COLLECT LOOPS
-- ============================================
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

-- ============================================
-- MAIN LOOPS
-- ============================================
local function StartPlantLoop(flagName, cropName, centerPos)
    task.spawn(function()
        while G[flagName] do
            PlantCrop(cropName, centerPos)
            task.wait(0.3)
        end
    end)
end

local function StartHarvestLoop(flagName)
    task.spawn(function()
        while G[flagName] do
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
        while G[flagName] do
            if G.Mizu_Selling then
                local sold = SellCrop(G.Mizu_SelectedCrop)
                if sold and sold > 0 then
                    Luna:Notification({ Title = "Jual Tanaman", Content = "Terjual " .. sold .. " item", Icon = "check", ImageSource = "Material" })
                end
            end
            
            if G.Mizu_SellEgg then 
                pcall(function() TutorialRemotes.RequestSell:InvokeServer("GET_EGG_LIST") end) 
            end
            
            if G.Mizu_SellMilk then 
                pcall(function() TutorialRemotes.RequestSell:InvokeServer("GET_MILK_LIST") end) 
            end
            
            if G.Mizu_SellFruit then 
                pcall(function() TutorialRemotes.RequestSell:InvokeServer("GET_FRUIT_LIST") end) 
            end
            
            for i = 1, G.Mizu_SellDelay or 60 do
                if not G[flagName] then return end
                task.wait(1)
            end
        end
    end)
end

local function StartEggLoop(flagName)
    task.spawn(function()
        while G[flagName] do
            pcall(AutoEggLoop)
            task.wait(0.8)
        end
    end)
end

local function StartMilkLoop(flagName)
    task.spawn(function()
        while G[flagName] do
            pcall(AutoMilkLoop)
            task.wait(0.8)
        end
    end)
end

local function StartAutoTP(flagName)
    task.spawn(function()
        while G[flagName] do
            if not G.Mizu_AllFarm then
                local pos = GetTeleportPosition()
                if pos and os.clock() - G.Mizu_LastAutoTp > 60 then
                    TeleportTo(pos)
                    G.Mizu_LastAutoTp = os.clock()
                end
            end
            task.wait(5)
        end
    end)
end

-- ============================================
-- ALL FARM LOOP
-- ============================================
local function AllFarmLoop()
    task.spawn(function()
        while G.Mizu_AllFarm do
            pcall(SellAll)
            for i = 1, 60 do
                if not G.Mizu_AllFarm then return end
                task.wait(1)
            end
        end
    end)
    
    while G.Mizu_AllFarm do
        -- Phase 1: Padi
        local padiPos = G.Mizu_PadiPos
        if padiPos then
            G.Mizu_AllFarmPhase = "PADI"
            TeleportTo(padiPos)
            
            local start = os.clock()
            while os.clock() - start < 2 and G.Mizu_AllFarm do
                pcall(PlantCrop, G.Mizu_SelectedCrop, padiPos)
                pcall(HarvestInRadius, padiPos, 80)
                task.wait(0.15)
            end
        else
            Luna:Notification({ Title = "All Farm", Content = "Koordinat Padi belum diset!", Icon = "warning", ImageSource = "Material" })
            task.wait(2)
        end
        
        if not G.Mizu_AllFarm then break end
        
        -- Phase 2: Sawit + Durian
        local sawitPos = G.Mizu_SawitPos
        if sawitPos then
            G.Mizu_AllFarmPhase = "SAWIT"
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
        
        if not G.Mizu_AllFarm then break end
        
        -- Phase 3: Coop
        local coopPos = G.Mizu_CoopPos
        if coopPos then
            G.Mizu_AllFarmPhase = "COOP"
            TeleportTo(coopPos)
            task.wait(0.3)
            pcall(FeedAnimals, coopPos, 70)
            task.wait(0.3)
            pcall(CollectAnimals, coopPos, 70)
        end
        
        if not G.Mizu_AllFarm then break end
        
        -- Phase 4: Barn
        local barnPos = G.Mizu_BarnPos
        if barnPos then
            G.Mizu_AllFarmPhase = "BARN"
            TeleportTo(barnPos)
            task.wait(0.3)
            pcall(FeedAnimals, barnPos, 70)
            task.wait(0.3)
            pcall(CollectAnimals, barnPos, 70)
        end
    end
    
    G.Mizu_AllFarmPhase = "IDLE"
    Luna:Notification({ Title = "All Farm", Content = "Dihentikan", Icon = "warning", ImageSource = "Material" })
end

-- ============================================
-- AUTO CLICK CONFIRM
-- ============================================
local ConfirmTouchOffset = Vector2.new(0, 36)

local function SendTouch(pos)
    pcall(function()
        VirtualUser:CaptureController()
        if VirtualUser.TouchTap then
            VirtualUser:TouchTap(pos, Enum.UserInputType.Touch)
        end
        VirtualUser:ClickButton1(pos)
    end)
end

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
                
                local pos = yesBtn.AbsolutePosition + yesBtn.AbsoluteSize / 2
                
                pcall(function() yesBtn.MouseButton1Click:Fire() end)
                pcall(function() yesBtn.Activated:Fire() end)
                
                SendTouch(pos + ConfirmTouchOffset)
                SendTouch(pos)
            end)
        end)
    end
    
    local confirmGui = playerGui:FindFirstChild("ConfirmGui")
    if confirmGui then WatchConfirm(confirmGui) end
    
    playerGui.ChildAdded:Connect(function(child)
        if child.Name == "ConfirmGui" then WatchConfirm(child) end
    end)
end

-- ============================================
-- PROMPT CACHE SETUP
-- ============================================
local function SetupPromptCache()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            FastInteractCache[obj] = true
            if G.Mizu_NoDelay and obj.HoldDuration > 0 then
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

-- ============================================
-- EVENT CONNECTIONS
-- ============================================
local function SetupEventConnections()
    TutorialRemotes.Notification.OnClientEvent:Connect(function(msg)
        if type(msg) ~= "string" then return end
        
        if string.find(msg, "Maximum 15 crops") then
            G.Mizu_PlantPause = os.clock() + 30
            Luna:Notification({ Title = "Pause Tanam", Content = "Crop penuh, pause 30 detik", Icon = "warning", ImageSource = "Material" })
        end
        
        if string.find(msg, "berhasil") or string.find(msg, "success") then
            Luna:Notification({ Title = "Server", Content = msg, Icon = "check", ImageSource = "Material" })
        elseif string.find(msg, "gagal") or string.find(msg, "fail") then
            Luna:Notification({ Title = "Server", Content = msg, Icon = "error", ImageSource = "Material" })
        end
    end)
    
    Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("ProximityPrompt") then
            FastInteractCache[obj] = true
            if G.Mizu_NoDelay and obj.HoldDuration > 0 then
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
            if G.Mizu_NoDelay then
                for prompt in pairs(FastInteractCache) do
                    if prompt and prompt.HoldDuration > 0 then
                        prompt.HoldDuration = 0
                    end
                end
            end
        end
    end)
end

-- ============================================
-- CREATE TABS (LUNA)
-- ============================================

-- All Farm Tab
local AllFarmTab = Window:CreateTab({ Name = "All Farm", Icon = "rocket", ImageSource = "Material", ShowTitle = true })

AllFarmTab:CreateParagraph({ Title = "SETUP KOORDINAT", Text = "Pergi ke setiap lokasi lalu klik tombol Simpan" })

AllFarmTab:CreateDropdown({
    Name = "Pilih Tanaman (Phase 1)",
    Options = CropDropdownList,
    CurrentOption = {CropDropdownList[1] or "Padi [lv.1] 🌾"},
    Callback = function(choice)
        G.Mizu_SelectedCrop = CropKeyMap[choice[1]] or "Padi"
        Luna:Notification({ Title = "Tanaman", Content = "Phase 1: " .. G.Mizu_SelectedCrop, Icon = "info", ImageSource = "Material" })
    end
})

AllFarmTab:CreateButton({
    Name = "Simpan Koordinat Tanam",
    Callback = function()
        if not root then
            Luna:Notification({ Title = "Error", Content = "Karakter belum spawn", Icon = "error", ImageSource = "Material" })
            return
        end
        G.Mizu_PadiPos = root.Position
        SavedFarmPos.padiPos = root.Position
        SaveAllFarmPos(SavedFarmPos)
        Luna:Notification({ Title = "Tersimpan", Content = string.format("Padi @ %.0f, %.0f, %.0f", root.Position.X, root.Position.Y, root.Position.Z), Icon = "check", ImageSource = "Material" })
    end
})

AllFarmTab:CreateDivider()

AllFarmTab:CreateButton({
    Name = "Simpan Koordinat Sawit",
    Callback = function()
        if not root then
            Luna:Notification({ Title = "Error", Content = "Karakter belum spawn", Icon = "error", ImageSource = "Material" })
            return
        end
        G.Mizu_SawitPos = root.Position
        SavedFarmPos.sawitPos = root.Position
        SaveAllFarmPos(SavedFarmPos)
        Luna:Notification({ Title = "Tersimpan", Content = string.format("Sawit @ %.0f, %.0f, %.0f", root.Position.X, root.Position.Y, root.Position.Z), Icon = "check", ImageSource = "Material" })
    end
})

AllFarmTab:CreateDivider()
AllFarmTab:CreateParagraph({ Title = "KANDANG", Text = "Kandang auto-scan. Klik Refresh untuk update posisi." })

local CoopLabel = AllFarmTab:CreateParagraph({ Title = "Coop", Text = "Coop: Belum di-scan" })
local BarnLabel = AllFarmTab:CreateParagraph({ Title = "Barn", Text = "Barn: Tidak ditemukan" })

AllFarmTab:CreateButton({
    Name = "Refresh Kandang",
    Callback = function()
        task.spawn(function()
            Luna:Notification({ Title = "Scanning...", Content = "Mencari kandang milikmu...", Icon = "info", ImageSource = "Material" })
            local coop, barn = ScanCoopBarn()
            
            if coop then
                G.Mizu_CoopPos = coop
                CoopLabel:Set(string.format("Coop: %.0f, %.0f, %.0f ✅", coop.X, coop.Y, coop.Z))
            else
                CoopLabel:Set("Coop: Tidak ditemukan ❌")
            end
            
            if barn then
                G.Mizu_BarnPos = barn
                BarnLabel:Set(string.format("Barn: %.0f, %.0f, %.0f ✅", barn.X, barn.Y, barn.Z))
            else
                BarnLabel:Set("Barn: Tidak ditemukan ❌")
            end
            
            Luna:Notification({ Title = "Scan Selesai", Content = (coop and "Coop ✅" or "Coop ❌") .. " | " .. (barn and "Barn ✅" or "Barn ❌"), Icon = "check", ImageSource = "Material" })
        end)
    end
})

AllFarmTab:CreateDivider()
AllFarmTab:CreateParagraph({ Title = "KONTROL ALL FARM", Text = "Auto farm semua area" })

local PhaseLabel = AllFarmTab:CreateParagraph({ Title = "Phase", Text = "Phase: IDLE" })

AllFarmTab:CreateToggle({
    Name = "AUTO FARM ALL",
    CurrentValue = false,
    Callback = function(state)
        G.Mizu_AllFarm = state
        G.Mizu_Farm = false
        G.Mizu_Egg = false
        G.Mizu_Milk = false
        
        if state then
            if not G.Mizu_PadiPos then
                Luna:Notification({ Title = "Error", Content = "Koordinat Padi wajib diset dulu!", Icon = "error", ImageSource = "Material" })
                G.Mizu_AllFarm = false
                return
            end
            Luna:Notification({ Title = "ALL FARM", Content = "Loop terpadu dimulai!", Icon = "check", ImageSource = "Material" })
            task.spawn(AllFarmLoop)
        else
            G.Mizu_AllFarmPhase = "IDLE"
            Luna:Notification({ Title = "All Farm", Content = "Dihentikan", Icon = "warning", ImageSource = "Material" })
        end
    end
})

task.spawn(function()
    local phaseMap = { IDLE = "IDLE", PADI = "Tanam Padi", SAWIT = "Sawit", COOP = "Kandang Ayam", BARN = "Kandang Sapi" }
    while task.wait(1) do
        local phase = G.Mizu_AllFarmPhase or "IDLE"
        pcall(function() PhaseLabel:Set("Phase: " .. (phaseMap[phase] or phase)) end)
    end
end)

AllFarmTab:CreateButton({
    Name = "Jual Semua Sekarang",
    Callback = function()
        task.spawn(function()
            Luna:Notification({ Title = "Jual Semua", Content = "Proses jual semua item...", Icon = "info", ImageSource = "Material" })
            local total = 0
            for cropName in pairs(CropList) do
                total = total + (SellCrop(cropName) or 0)
            end
            if G.Mizu_SellEgg then pcall(function() TutorialRemotes.RequestSell:InvokeServer("GET_EGG_LIST") end) end
            if G.Mizu_SellMilk then pcall(function() TutorialRemotes.RequestSell:InvokeServer("GET_MILK_LIST") end) end
            if G.Mizu_SellFruit then pcall(function() TutorialRemotes.RequestSell:InvokeServer("GET_FRUIT_LIST") end) end
            Luna:Notification({ Title = "Jual Semua", Content = "Selesai! Tanaman: " .. total .. " item", Icon = "check", ImageSource = "Material" })
        end)
    end
})

-- Tanaman Tab
local PlantTab = Window:CreateTab({ Name = "Tanaman", Icon = "grass", ImageSource = "Material", ShowTitle = true })

PlantTab:CreateParagraph({ Title = "KONFIGURASI", Text = "Pengaturan auto tanaman" })

PlantTab:CreateDropdown({
    Name = "Target Tanaman",
    Options = CropDropdownList,
    CurrentOption = {CropDropdownList[1] or "Padi [lv.1] 🌾"},
    Callback = function(choice)
        G.Mizu_SelectedCrop = CropKeyMap[choice[1]] or "Padi"
        Luna:Notification({ Title = "Target", Content = "Tanaman: " .. G.Mizu_SelectedCrop, Icon = "info", ImageSource = "Material" })
    end
})

PlantTab:CreateSlider({ Name = "Maks Bibit di Tas", Range = {1, 99}, Increment = 1, CurrentValue = G.Mizu_PlantAmount, Callback = function(v) G.Mizu_PlantAmount = v end })
PlantTab:CreateSlider({ Name = "Max Crop Aktif", Range = {1, 50}, Increment = 1, CurrentValue = G.Mizu_MaxCrop, Callback = function(v) G.Mizu_MaxCrop = v end })
PlantTab:CreateSlider({ Name = "Seed per Burst", Range = {1, 30}, Increment = 1, CurrentValue = G.Mizu_BurstAmount, Callback = function(v) G.Mizu_BurstAmount = v end })
PlantTab:CreateSlider({ Name = "Auto Sell Delay", Range = {10, 300}, Increment = 1, CurrentValue = G.Mizu_SellDelay, Callback = function(v) G.Mizu_SellDelay = math.floor(v) end })

PlantTab:CreateDivider()
PlantTab:CreateParagraph({ Title = "CONTROL", Text = "Auto farm tanaman" })

PlantTab:CreateToggle({
    Name = "Auto Farm Tanaman",
    CurrentValue = false,
    Callback = function(state)
        G.Mizu_Farm = state
        
        if state then
            if G.Mizu_AllFarm then
                Luna:Notification({ Title = "Warning", Content = "Matikan All Farm dulu!", Icon = "warning", ImageSource = "Material" })
                G.Mizu_Farm = false
                return
            end
            
            if SaveMemoryPosition() then
                Luna:Notification({ Title = "Memory", Content = "Posisi tersimpan untuk Auto TP", Icon = "check", ImageSource = "Material" })
            end
            
            StartPlantLoop("Mizu_Farm", G.Mizu_SelectedCrop, GetTeleportPosition())
            StartHarvestLoop("Mizu_Farm")
            StartSellLoop("Mizu_Farm")
            StartAutoTP("Mizu_Farm")
            
            Luna:Notification({ Title = "Auto Farm", Content = "Dimulai! (Mode: " .. G.Mizu_TPMode .. ")", Icon = "check", ImageSource = "Material" })
        else
            Luna:Notification({ Title = "Auto Farm", Content = "Dihentikan", Icon = "warning", ImageSource = "Material" })
        end
    end
})

PlantTab:CreateToggle({ Name = "Auto Beli Bibit", CurrentValue = G.Mizu_AutoBuy, Callback = function(v) G.Mizu_AutoBuy = v end })
PlantTab:CreateToggle({ Name = "Auto Jual Tanaman", CurrentValue = G.Mizu_Selling, Callback = function(v) G.Mizu_Selling = v end })

PlantTab:CreateDivider()
PlantTab:CreateParagraph({ Title = "MANUAL", Text = "Tombol aksi manual" })

PlantTab:CreateButton({
    Name = "Jual Tanaman Sekarang",
    Callback = function()
        task.spawn(function()
            local sold = SellCrop(G.Mizu_SelectedCrop)
            Luna:Notification({ Title = "Jual", Content = sold > 0 and "Terjual " .. sold .. " item" or "Kosong", Icon = sold > 0 and "check" or "warning", ImageSource = "Material" })
        end)
    end
})

-- Ternak Tab
local FarmTab = Window:CreateTab({ Name = "Ternak", Icon = "pets", ImageSource = "Material", ShowTitle = true })

FarmTab:CreateParagraph({ Title = "AUTO EGG", Text = "Auto collect dan jual telur" })

FarmTab:CreateToggle({
    Name = "Auto Collect Telur",
    CurrentValue = false,
    Callback = function(state)
        G.Mizu_Egg = state
        if state then
            if G.Mizu_AllFarm then
                Luna:Notification({ Title = "Warning", Content = "Matikan All Farm dulu!", Icon = "warning", ImageSource = "Material" })
                G.Mizu_Egg = false
                return
            end
            StartEggLoop("Mizu_Egg")
            Luna:Notification({ Title = "Auto Egg", Content = "Dimulai!", Icon = "check", ImageSource = "Material" })
        else
            Luna:Notification({ Title = "Auto Egg", Content = "Dihentikan", Icon = "warning", ImageSource = "Material" })
        end
    end
})

FarmTab:CreateToggle({ Name = "Auto Jual Telur", CurrentValue = G.Mizu_SellEgg, Callback = function(v) G.Mizu_SellEgg = v end })
FarmTab:CreateButton({ Name = "Jual Telur Sekarang", Callback = function() task.spawn(function() TutorialRemotes.RequestSell:InvokeServer("GET_EGG_LIST") end); Luna:Notification({ Title = "Jual Telur", Content = "Selesai", Icon = "check", ImageSource = "Material" }) end })

FarmTab:CreateDivider()
FarmTab:CreateParagraph({ Title = "AUTO MILK", Text = "Auto collect dan jual susu" })

FarmTab:CreateToggle({
    Name = "Auto Collect Susu",
    CurrentValue = false,
    Callback = function(state)
        G.Mizu_Milk = state
        if state then
            if G.Mizu_AllFarm then
                Luna:Notification({ Title = "Warning", Content = "Matikan All Farm dulu!", Icon = "warning", ImageSource = "Material" })
                G.Mizu_Milk = false
                return
            end
            StartMilkLoop("Mizu_Milk")
            Luna:Notification({ Title = "Auto Milk", Content = "Dimulai!", Icon = "check", ImageSource = "Material" })
        else
            Luna:Notification({ Title = "Auto Milk", Content = "Dihentikan", Icon = "warning", ImageSource = "Material" })
        end
    end
})

FarmTab:CreateToggle({ Name = "Auto Jual Susu", CurrentValue = G.Mizu_SellMilk, Callback = function(v) G.Mizu_SellMilk = v end })
FarmTab:CreateButton({ Name = "Jual Susu Sekarang", Callback = function() task.spawn(function() TutorialRemotes.RequestSell:InvokeServer("GET_MILK_LIST") end); Luna:Notification({ Title = "Jual Susu", Content = "Selesai", Icon = "check", ImageSource = "Material" }) end })

FarmTab:CreateDivider()
FarmTab:CreateParagraph({ Title = "AUTO FRUIT", Text = "Auto jual buah" })

FarmTab:CreateToggle({ Name = "Auto Jual Buah", CurrentValue = G.Mizu_SellFruit, Callback = function(v) G.Mizu_SellFruit = v end })
FarmTab:CreateButton({ Name = "Jual Buah Sekarang", Callback = function() task.spawn(function() TutorialRemotes.RequestSell:InvokeServer("GET_FRUIT_LIST") end); Luna:Notification({ Title = "Jual Buah", Content = "Selesai", Icon = "check", ImageSource = "Material" }) end })

-- TP Manager Tab
local TPManagerTab = Window:CreateTab({ Name = "TP Manager", Icon = "map", ImageSource = "Material", ShowTitle = true })

TPManagerTab:CreateParagraph({ Title = "MODE AUTO TP", Text = "Pilih mode teleportasi" })

TPManagerTab:CreateToggle({
    Name = "Smart Memory TP",
    CurrentValue = true,
    Callback = function(state)
        if state then
            G.Mizu_TPMode = "Memory"
            if not G.Mizu_MemoryPos then SaveMemoryPosition() end
            Luna:Notification({ Title = "Mode TP", Content = "Memory Position", Icon = "check", ImageSource = "Material" })
        else
            G.Mizu_TPMode = "Plot"
            Luna:Notification({ Title = "Mode TP", Content = "Plot Aktif", Icon = "info", ImageSource = "Material" })
        end
    end
})

TPManagerTab:CreateDivider()
TPManagerTab:CreateParagraph({ Title = "PLOT AKTIF", Text = "Pilih plot favorit" })

local plotList = { "(pilih plot)" }
for _, plot in ipairs(SavedPlots.favPlots) do
    table.insert(plotList, plot.label)
end

local plotDropdown = TPManagerTab:CreateDropdown({
    Name = "Pilih Plot Aktif",
    Options = plotList,
    CurrentOption = {"(pilih plot)"},
    Callback = function(choice)
        if choice[1] == "(pilih plot)" then
            G.Mizu_ActivePlot = nil
            Luna:Notification({ Title = "Plot Aktif", Content = "Dinonaktifkan", Icon = "warning", ImageSource = "Material" })
            return
        end
        
        for _, plot in ipairs(SavedPlots.favPlots) do
            if plot.label == choice[1] then
                G.Mizu_ActivePlot = plot
                TeleportTo(plot.pos)
                G.Mizu_LastAutoTp = os.clock()
                Luna:Notification({ Title = "Plot Aktif", Content = plot.label .. " dipilih", Icon = "check", ImageSource = "Material" })
                break
            end
        end
    end
})

TPManagerTab:CreateDivider()
TPManagerTab:CreateParagraph({ Title = "MEMORY POSITION", Text = "Simpan posisi memori" })

TPManagerTab:CreateButton({
    Name = "Update Memory Position",
    Callback = function()
        if SaveMemoryPosition() then
            Luna:Notification({ Title = "Memory", Content = "Posisi tersimpan", Icon = "check", ImageSource = "Material" })
        else
            Luna:Notification({ Title = "Gagal", Content = "Karakter tidak ditemukan", Icon = "error", ImageSource = "Material" })
        end
    end
})

TPManagerTab:CreateButton({
    Name = "TP ke Memory Position",
    Callback = function()
        if G.Mizu_MemoryPos then
            TeleportTo(G.Mizu_MemoryPos.pos)
            Luna:Notification({ Title = "TP", Content = "Ke memory position", Icon = "check", ImageSource = "Material" })
        else
            Luna:Notification({ Title = "Error", Content = "Belum ada memory tersimpan", Icon = "warning", ImageSource = "Material" })
        end
    end
})

-- Plot Manager Tab
local PlotManagerTab = Window:CreateTab({ Name = "Plot Manager", Icon = "list", ImageSource = "Material", ShowTitle = true })

PlotManagerTab:CreateParagraph({ Title = "PLOT TERSIMPAN", Text = "Kelola plot favorit" })

local selectedPlotToDelete = "(pilih)"
PlotManagerTab:CreateDropdown({
    Name = "Pilih Plot untuk Dihapus",
    Options = plotList,
    CurrentOption = {"(pilih plot)"},
    Callback = function(choice) selectedPlotToDelete = choice[1] end
})

PlotManagerTab:CreateButton({
    Name = "Hapus Plot Dipilih",
    Callback = function()
        if selectedPlotToDelete == "(pilih)" then
            Luna:Notification({ Title = "Pilih plot dulu", Content = "", Icon = "warning", ImageSource = "Material" })
            return
        end
        
        for i, plot in ipairs(SavedPlots.favPlots) do
            if plot.label == selectedPlotToDelete then
                table.remove(SavedPlots.favPlots, i)
                SaveFavPlots(SavedPlots)
                
                if G.Mizu_ActivePlot and G.Mizu_ActivePlot.label == selectedPlotToDelete then
                    G.Mizu_ActivePlot = nil
                end
                
                Luna:Notification({ Title = "Dihapus", Content = selectedPlotToDelete, Icon = "check", ImageSource = "Material" })
                return
            end
        end
    end
})

PlotManagerTab:CreateDivider()
PlotManagerTab:CreateParagraph({ Title = "TAMBAH PLOT BARU", Text = "Simpan posisi saat ini sebagai plot" })

local newPlotName = ""
PlotManagerTab:CreateInput({ Name = "Nama Plot (opsional)", PlaceholderText = "Nama plot...", Callback = function(v) newPlotName = v end })

PlotManagerTab:CreateButton({
    Name = "Simpan Posisi Sekarang",
    Callback = function()
        if not root then
            Luna:Notification({ Title = "Error", Content = "Karakter belum spawn", Icon = "error", ImageSource = "Material" })
            return
        end
        
        local name = newPlotName
        if name == "" then name = "Plot " .. (#SavedPlots.favPlots + 1) end
        
        table.insert(SavedPlots.favPlots, { label = name, pos = root.Position })
        SaveFavPlots(SavedPlots)
        
        Luna:Notification({ Title = "Tersimpan", Content = name .. " @ " .. string.format("%.0f,%.0f", root.Position.X, root.Position.Z), Icon = "check", ImageSource = "Material" })
    end
})

PlotManagerTab:CreateButton({
    Name = "Reload dari File",
    Callback = function()
        SavedPlots = LoadFavPlots()
        local newList = { "(pilih plot)" }
        for _, plot in ipairs(SavedPlots.favPlots) do
            table.insert(newList, plot.label)
        end
        plotDropdown:SetOptions(newList)
        Luna:Notification({ Title = "Reload", Content = #SavedPlots.favPlots .. " plot dimuat", Icon = "info", ImageSource = "Material" })
    end
})

-- Utilities Tab
local UtilTab = Window:CreateTab({ Name = "Utilities", Icon = "settings", ImageSource = "Material", ShowTitle = true })

UtilTab:CreateParagraph({ Title = "UTILITAS", Text = "Pengaturan tambahan" })
UtilTab:CreateToggle({ Name = "Fast Interact", CurrentValue = G.Mizu_NoDelay, Callback = function(v) G.Mizu_NoDelay = v end })
UtilTab:CreateToggle({ Name = "Anti AFK", CurrentValue = G.Mizu_AntiAFK, Callback = function(v) G.Mizu_AntiAFK = v; Luna:Notification({ Title = "Anti AFK", Content = v and "Aktif" or "Nonaktif", Icon = v and "check" or "warning", ImageSource = "Material" }) end })

UtilTab:CreateDivider()
UtilTab:CreateParagraph({ Title = "SESSION TRACKER", Text = "Statistik sesi saat ini" })

local UptimeLabel = UtilTab:CreateParagraph({ Title = "Uptime", Text = "Uptime: 00:00:00" })
local StatusLabel = UtilTab:CreateParagraph({ Title = "Status", Text = "Status: Idle" })
local CropLabel = UtilTab:CreateParagraph({ Title = "Crop Aktif", Text = "Crop Aktif: 0 / " .. G.Mizu_MaxCrop })
local SoldLabel = UtilTab:CreateParagraph({ Title = "Terjual", Text = "Terjual: 0 item" })
local EarnedLabel = UtilTab:CreateParagraph({ Title = "Earned", Text = "Earned: Rp 0" })
local TPModeLabel = UtilTab:CreateParagraph({ Title = "TP Mode", Text = "TP Mode: Memory" })
local AutoTPLabel = UtilTab:CreateParagraph({ Title = "Auto TP", Text = "Auto TP: 60 detik" })
local AllFarmLabel = UtilTab:CreateParagraph({ Title = "All Farm", Text = "All Farm: IDLE" })

task.spawn(function()
    local phaseMap = { IDLE = "IDLE", PADI = "Tanam Padi", SAWIT = "Sawit", COOP = "Kandang Ayam", BARN = "Kandang Sapi" }
    while task.wait(1) do
        local session = G.Mizu_Session
        if session then
            local uptime = os.clock() - session.StartTime
            local h = math.floor(uptime / 3600)
            local m = math.floor(uptime % 3600 / 60)
            local s = math.floor(uptime % 60)
            
            local status = "Idle"
            if G.Mizu_AllFarm then status = "All Farm: " .. (phaseMap[G.Mizu_AllFarmPhase] or "...")
            elseif G.Mizu_Farm then status = "Farming"
            elseif G.Mizu_Egg then status = "Collecting Egg"
            elseif G.Mizu_Milk then status = "Collecting Milk" end
            
            local cropCount = CountActiveCrops()
            local autoTPLeft = math.max(0, 60 - (os.clock() - G.Mizu_LastAutoTp))
            
            local tpMode = G.Mizu_TPMode == "Plot" and "Plot Aktif" or "Memory"
            if G.Mizu_TPMode == "Plot" and not G.Mizu_ActivePlot then tpMode = tpMode .. " (No Plot)"
            elseif G.Mizu_TPMode == "Memory" and not G.Mizu_MemoryPos then tpMode = tpMode .. " (No Memory)" end
            
            pcall(function()
                UptimeLabel:Set(string.format("Uptime: %02d:%02d:%02d", h, m, s))
                StatusLabel:Set("Status: " .. status)
                CropLabel:Set("Crop Aktif: " .. cropCount .. " / " .. G.Mizu_MaxCrop)
                SoldLabel:Set("Terjual: " .. FormatNumber(session.TotalSold) .. " item")
                EarnedLabel:Set("Earned: Rp " .. FormatNumber(session.TotalEarned))
                TPModeLabel:Set("TP Mode: " .. tpMode)
                AutoTPLabel:Set(string.format("Auto TP: %d detik", math.floor(autoTPLeft)))
                AllFarmLabel:Set("All Farm: " .. (phaseMap[G.Mizu_AllFarmPhase or "IDLE"] or G.Mizu_AllFarmPhase))
            end)
        end
    end
end)

UtilTab:CreateButton({
    Name = "Reset Statistik",
    Callback = function()
        G.Mizu_Session = { StartTime = os.clock(), TotalSold = 0, TotalEarned = 0 }
        G.Mizu_MyPlots = {}
        Luna:Notification({ Title = "Reset", Content = "Statistik direset", Icon = "check", ImageSource = "Material" })
    end
})

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
SetupPromptCache()
SetupEventConnections()
SetupConfirmClicker()

task.spawn(function()
    task.wait(2)
    if not G.Mizu_MemoryPos then SaveMemoryPosition() end
end)

Luna:Notification({
    Title = "Mizukage System",
    Content = "Sawah Indo loaded! " .. #CropList .. " tanaman siap",
    Icon = "verified",
    ImageSource = "Material"
})