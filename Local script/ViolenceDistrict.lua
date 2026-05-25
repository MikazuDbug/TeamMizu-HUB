-- Mizukage Official | TeamMizu🔰 - All rights reserved
-- Game: Violence District
-- Script rebuilt by MIZU-OS v14.0

-- LOAD LUNA (WAJIB)
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- BUAT WINDOW UTAMA
local Window = Luna:CreateWindow({
    Name = "Mizukage Official",
    Subtitle = "Violence District - TeamMizu🔰",
    LogoID = "104266190557772",
    LoadingEnabled = true,
    LoadingTitle = "Mizukage System",
    LoadingSubtitle = "by @MizukageOfficial",
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "MizukageHub/ViolenceDistrict"
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
-- INITIAL SETUP (REBRANDED)
-- ============================================

repeat task.wait() until game:IsLoaded()

-- FPS Unlock
if setfpscap then
    setfpscap(1000000)
    Luna:Notification({ Title = "Violence District", Content = "Mizukage Premium", Icon = "verified", ImageSource = "Material" })
else
    Luna:Notification({ Title = "Violence District", Content = "Your exploit does not support setfpscap.", Icon = "error", ImageSource = "Material" })
end

-- Services
local RunService = game:GetService("RunService")
local Workspace = game.Workspace
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ============================================
-- CREATE ALL TABS
-- ============================================

local InfoTab = Window:CreateTab({ Name = "Information", Icon = "info", ImageSource = "Material", ShowTitle = true })
local SurTab = Window:CreateTab({ Name = "Survivor", Icon = "shield", ImageSource = "Material", ShowTitle = true })
local KillerTab = Window:CreateTab({ Name = "Killer", Icon = "swords", ImageSource = "Material", ShowTitle = true })
local MasTab = Window:CreateTab({ Name = "Xmas", Icon = "celebration", ImageSource = "Material", ShowTitle = true })
local MainTab = Window:CreateTab({ Name = "Main", Icon = "rocket", ImageSource = "Material", ShowTitle = true })
local EspTab = Window:CreateTab({ Name = "Esp", Icon = "visibility", ImageSource = "Material", ShowTitle = true })
local PlayerTab = Window:CreateTab({ Name = "Player", Icon = "person", ImageSource = "Material", ShowTitle = true })
local HitboxTab = Window:CreateTab({ Name = "Hitbox", Icon = "target", ImageSource = "Material", ShowTitle = true })
local TeleportTab = Window:CreateTab({ Name = "Teleport", Icon = "map", ImageSource = "Material", ShowTitle = true })

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
-- ESP SYSTEM (REBRANDED)
-- ============================================

-- Toggle values
local ESP_SURVIVOR = false
local ESP_MURDER = false
local ESP_GENERATOR = false
local ESP_GATE = false
local ESP_PALLET = false
local ESP_WINDOW = false
local ESP_PUMPKIN = false
local ESP_HOOK = false
local ESP_TREE = false
local ESP_GIFT = false

-- Color config
local COLOR_SURVIVOR = Color3.fromRGB(0, 0, 255)
local COLOR_MURDERER = Color3.fromRGB(255, 0, 0)
local COLOR_GENERATOR = Color3.fromRGB(255, 255, 255)
local COLOR_GENERATOR_DONE = Color3.fromRGB(0, 255, 0)
local COLOR_GATE = Color3.fromRGB(255, 255, 255)
local COLOR_PALLET = Color3.fromRGB(255, 255, 0)
local COLOR_TREE = Color3.fromRGB(0, 255, 0)
local COLOR_GIFT = Color3.fromRGB(255, 0, 0)
local COLOR_OUTLINE = Color3.fromRGB(0, 0, 0)
local COLOR_WINDOW = Color3.fromRGB(175, 215, 230)
local COLOR_HOOK = Color3.fromRGB(255, 0, 0)

-- State flags
local espEnabled = false
local ShowName = true
local ShowDistance = true
local ShowHP = true
local ShowHighlight = true
local ShowPercent = true

local espObjects = {}

local function removeESP(obj)
    if espObjects[obj] then
        local data = espObjects[obj]
        if data.highlight then data.highlight:Destroy() end
        if data.nameLabel and data.nameLabel.Parent then
            data.nameLabel.Parent.Parent:Destroy()
        end
        espObjects[obj] = nil
    end
end

local function createESP(obj, baseColor)
    if not obj or obj.Name == "Lobby" then return end
    if espObjects[obj] then
        local data = espObjects[obj]
        if data.highlight then
            data.highlight.FillColor = baseColor
            data.highlight.OutlineColor = baseColor
            data.highlight.Enabled = ShowHighlight
        end
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = obj
    highlight.FillColor = baseColor
    highlight.FillTransparency = 0.8
    highlight.OutlineColor = baseColor
    highlight.OutlineTransparency = 0.1
    highlight.Enabled = ShowHighlight
    highlight.Parent = obj

    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 200, 0, 50)
    bill.Adornee = obj
    bill.AlwaysOnTop = true
    bill.Parent = obj

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = bill

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.33, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 14
    nameLabel.TextColor3 = baseColor
    nameLabel.TextStrokeColor3 = COLOR_OUTLINE
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Text = obj.Name
    nameLabel.Visible = ShowName
    nameLabel.Parent = frame

    local hpLabel = Instance.new("TextLabel")
    hpLabel.Size = UDim2.new(1, 0, 0.33, 0)
    hpLabel.Position = UDim2.new(0, 0, 0.33, 0)
    hpLabel.BackgroundTransparency = 1
    hpLabel.Font = Enum.Font.SourceSansBold
    hpLabel.TextSize = 14
    hpLabel.TextColor3 = baseColor
    hpLabel.TextStrokeColor3 = COLOR_OUTLINE
    hpLabel.TextStrokeTransparency = 0
    hpLabel.Text = ""
    hpLabel.Parent = frame

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(1, 0, 0.33, 0)
    distLabel.Position = UDim2.new(0, 0, 0.66, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Font = Enum.Font.SourceSansBold
    distLabel.TextSize = 14
    distLabel.TextColor3 = baseColor
    distLabel.TextStrokeColor3 = COLOR_OUTLINE
    distLabel.TextStrokeTransparency = 0
    distLabel.Text = ""
    distLabel.Parent = frame

    espObjects[obj] = {
        highlight = highlight,
        nameLabel = nameLabel,
        hpLabel = hpLabel,
        distLabel = distLabel,
        color = baseColor
    }
end

local function getFolderGenerator()
    local folders = {}
    local map = workspace:FindFirstChild("Map")
    if map then
        for _, child in ipairs(map:GetChildren()) do
            if child.Name == "Generator" and child:IsA("Model") then
                table.insert(folders, child)
            end
        end
        local model = map:FindFirstChild("Model")
        if model then
            for _, child in ipairs(model:GetChildren()) do
                if child.Name == "Generator" and child:IsA("Model") then
                    table.insert(folders, child)
                end
            end
        end
        local Maze2 = map:FindFirstChild("Maze2")
        if Maze2 then
            for _, child in ipairs(Maze2:GetChildren()) do
                if child.Name == "Generator" and child:IsA("Model") then
                    table.insert(folders, child)
                end
            end
        end
        local Gens = map:FindFirstChild("Gens")
        if Gens then
            for _, child in ipairs(Gens:GetChildren()) do
                if child.Name == "Generator" and child:IsA("Model") then
                    table.insert(folders, child)
                end
            end
        end
        local rooftop = map:FindFirstChild("Rooftop")
        if rooftop then
            for _, child in ipairs(rooftop:GetChildren()) do
                if child.Name == "Generator" and child:IsA("Model") then
                    table.insert(folders, child)
                end
            end
            local rooftopModel = rooftop:FindFirstChild("Model")
            if rooftopModel then
                for _, child in ipairs(rooftopModel:GetChildren()) do
                    if child.Name == "Generator" and child:IsA("Model") then
                        table.insert(folders, child)
                    end
                end
            end
        end
    end
    if #folders == 0 then
        for _, descendant in ipairs(workspace:GetDescendants()) do
            if descendant.Name == "Generator" and descendant:IsA("Model") then
                table.insert(folders, descendant)
            end
        end
    end
    return folders
end

local function getMapFolders()
    local folders = {}
    local mainMap = workspace:FindFirstChild("Map")
    if not mainMap then return folders end
    table.insert(folders, mainMap)
    local rooftop = mainMap:FindFirstChild("Rooftop")
    if rooftop then
        table.insert(folders, rooftop)
        local rooftopModel = rooftop:FindFirstChild("Model")
        if rooftopModel then table.insert(folders, rooftopModel) end
    end
    local maze2 = mainMap:FindFirstChild("Maze2")
    if maze2 then table.insert(folders, maze2) end
    local model = mainMap:FindFirstChild("Model")
    if model then table.insert(folders, model) end
    local hooks = mainMap:FindFirstChild("Hooks")
    if hooks then table.insert(folders, hooks) end
    local pallets = mainMap:FindFirstChild("Pallets")
    if pallets then table.insert(folders, pallets) end
    local vaults = mainMap:FindFirstChild("Vaults")
    if vaults then table.insert(folders, vaults) end
    local gens = mainMap:FindFirstChild("Gens")
    if gens then table.insert(folders, gens) end
    return folders
end

local function updateWindowESP()
    if not espEnabled then return end
    for _, folder in pairs(getMapFolders()) do
        for _, windowModel in pairs(folder:GetChildren()) do
            if windowModel:IsA("Model") and windowModel.Name == "Window" then
                if ESP_WINDOW then
                    createESP(windowModel, COLOR_WINDOW)
                else
                    removeESP(windowModel)
                end
            end
        end
    end
end

local function getEventFolders()
    local folders = {}
    local map = workspace:FindFirstChild("Map")
    if not map then return folders end
    for _, v in pairs(map:GetChildren()) do
        local name = v.Name:lower()
        if name:find("chris") or name:find("christmas") then
            table.insert(folders, v)
        end
    end
    return folders
end

local function updateEventESP()
    if not espEnabled then return end
    for _, eventFolder in pairs(getEventFolders()) do
        for _, obj in pairs(eventFolder:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Gift" then
                if ESP_GIFT then
                    createESP(obj, COLOR_GIFT)
                else
                    removeESP(obj)
                end
            end
            if obj:IsA("Model") and obj.Name == "Model" then
                local parentName = obj.Parent.Name:lower()
                if parentName:find("tree") or parentName:find("chrismta") then
                    if ESP_TREE then
                        createESP(obj, COLOR_TREE)
                    else
                        removeESP(obj)
                    end
                end
            end
        end
    end
end

local function getGeneratorProgress(gen)
    local progress = 0
    if gen:GetAttribute("Progress") then
        progress = gen:GetAttribute("Progress")
    elseif gen:GetAttribute("RepairProgress") then
        progress = gen:GetAttribute("RepairProgress")
    else
        for _, child in ipairs(gen:GetDescendants()) do
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                local n = child.Name:lower()
                if n:find("progress") or n:find("repair") or n:find("percent") then
                    progress = child.Value
                    break
                end
            end
        end
    end
    progress = (progress > 1) and progress / 100 or progress
    return math.clamp(progress, 0, 1)
end

local function getProgressColor(percent)
    if percent < 0.5 then
        local t = percent / 0.5
        return Color3.fromRGB(255 - (255 - 153) * t, 255, 255 - (255 - 153) * t)
    else
        local t = (percent - 0.5) / 0.5
        return Color3.fromRGB(153 * (1 - t), 255, 153 * (1 - t))
    end
end

local function generatorFinished(gen)
    return getGeneratorProgress(gen) >= 0.99 or gen:FindFirstChild("Finished") or gen:FindFirstChild("Repaired")
end

local lastUpdate = 0
local updateInterval = 0.5

local function updateESP(dt)
    if not espEnabled then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character ~= LocalPlayer.Character and player.Character.Name ~= "Lobby" then
            local isMurderer = player.Character:FindFirstChild("Weapon") ~= nil
            if isMurderer then
                if ESP_MURDER then
                    createESP(player.Character, COLOR_MURDERER)
                else
                    removeESP(player.Character)
                end
            else
                if ESP_SURVIVOR then
                    createESP(player.Character, COLOR_SURVIVOR)
                else
                    removeESP(player.Character)
                end
            end
        end
    end

    for _, folder in pairs(getMapFolders()) do
        for _, obj in pairs(folder:GetChildren()) do
            if obj.Name == "Generator" then
                if ESP_GENERATOR then
                    local progress = getGeneratorProgress(obj)
                    local isFinished = generatorFinished(obj)
                    local baseColor = isFinished and COLOR_GENERATOR_DONE or getProgressColor(progress)
                    createESP(obj, baseColor)
                    local data = espObjects[obj]
                    if data then
                        local targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        if targetPart and hrp then
                            local dist = math.floor((hrp.Position - targetPart.Position).Magnitude)
                            if ShowName and ShowPercent then
                                data.nameLabel.Text = obj.Name .. " | " .. math.floor(progress * 100) .. "%"
                                data.nameLabel.Visible = true
                            elseif ShowName then
                                data.nameLabel.Text = obj.Name
                                data.nameLabel.Visible = true
                            else
                                data.nameLabel.Visible = false
                            end
                            if ShowDistance then
                                data.distLabel.Text = "[ " .. dist .. " MM ]"
                                data.distLabel.Visible = true
                            else
                                data.distLabel.Visible = false
                            end
                            data.hpLabel.Visible = false
                            local textColor = isFinished and COLOR_GENERATOR_DONE or getProgressColor(progress)
                            data.nameLabel.TextColor3 = textColor
                            data.distLabel.TextColor3 = textColor
                        end
                    end
                else
                    removeESP(obj)
                end
            elseif obj.Name == "Gate" then
                if ESP_GATE then
                    createESP(obj, COLOR_GATE)
                else
                    removeESP(obj)
                end
            elseif obj.Name == "Hook" then
                local mdl = obj:FindFirstChild("Model")
                if mdl then
                    if ESP_HOOK then
                        createESP(mdl, COLOR_HOOK)
                    else
                        removeESP(mdl)
                    end
                end
            elseif obj.Name == "Palletwrong" then
                if ESP_PALLET then
                    createESP(obj, COLOR_PALLET)
                else
                    removeESP(obj)
                end
            else
                if espObjects[obj] then
                    removeESP(obj)
                end
            end
        end
    end

    updateWindowESP()
    updateEventESP()

    for obj, data in pairs(espObjects) do
        if obj and obj.Parent and obj.Name ~= "Lobby" then
            local targetPart = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if targetPart then
                local humanoid = obj:FindFirstChildOfClass("Humanoid")
                local isPlayer = humanoid ~= nil
                data.nameLabel.Visible = ShowName
                if isPlayer then
                    if ShowHP and humanoid then
                        data.hpLabel.Text = "[ " .. math.floor(humanoid.Health) .. " HP ]"
                        data.hpLabel.Visible = true
                    else
                        data.hpLabel.Visible = false
                    end
                    if ShowDistance then
                        local dist = math.floor((hrp.Position - targetPart.Position).Magnitude)
                        data.distLabel.Text = "[ " .. dist .. " MM ]"
                        data.distLabel.Visible = true
                    else
                        data.distLabel.Visible = false
                    end
                    if data.hpLabel.Visible then
                        data.hpLabel.Position = UDim2.new(0, 0, 0.33, 0)
                        data.distLabel.Position = UDim2.new(0, 0, 0.66, 0)
                    else
                        data.distLabel.Position = UDim2.new(0, 0, 0.33, 0)
                    end
                else
                    data.hpLabel.Visible = false
                    if ShowDistance then
                        local dist = math.floor((hrp.Position - targetPart.Position).Magnitude)
                        data.distLabel.Text = "[ " .. dist .. " MM ]"
                        data.distLabel.Visible = true
                        data.distLabel.Position = UDim2.new(0, 0, 0.33, 0)
                    else
                        data.distLabel.Visible = false
                    end
                end
                if data.highlight then
                    data.highlight.Enabled = ShowHighlight
                end
            end
        else
            removeESP(obj)
        end
    end
end

RunService.RenderStepped:Connect(function(dt)
    lastUpdate = lastUpdate + dt
    if lastUpdate >= updateInterval then
        lastUpdate = 0
        updateESP(dt)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if player.Character then removeESP(player.Character) end
end)

-- ============================================
-- ESP TAB UI (LUNA)
-- ============================================

EspTab:CreateParagraph({ Title = "Feature Esp", Text = "Toggle ESP features" })
EspTab:CreateToggle({ Name = "Enable ESP", CurrentValue = false, Callback = function(v) espEnabled = v; if not espEnabled then for obj, _ in pairs(espObjects) do removeESP(obj) end else updateESP(0) end end })

EspTab:CreateDivider()
EspTab:CreateParagraph({ Title = "Esp Role", Text = "ESP for player roles" })
EspTab:CreateToggle({ Name = "ESP Survivor", CurrentValue = false, Callback = function(v) ESP_SURVIVOR = v end })
EspTab:CreateToggle({ Name = "ESP Killer", CurrentValue = false, Callback = function(v) ESP_MURDER = v end })

EspTab:CreateDivider()
EspTab:CreateParagraph({ Title = "Esp Engine", Text = "ESP for game objects" })
EspTab:CreateToggle({ Name = "ESP Generator", CurrentValue = false, Callback = function(v) ESP_GENERATOR = v end })
EspTab:CreateToggle({ Name = "ESP Gate", CurrentValue = false, Callback = function(v) ESP_GATE = v end })

EspTab:CreateDivider()
EspTab:CreateParagraph({ Title = "Esp Object", Text = "ESP for interactable objects" })
EspTab:CreateToggle({ Name = "ESP Pallet", CurrentValue = false, Callback = function(v) ESP_PALLET = v end })
EspTab:CreateToggle({ Name = "ESP Hook", CurrentValue = false, Callback = function(v) ESP_HOOK = v end })
EspTab:CreateToggle({ Name = "ESP Window", CurrentValue = false, Callback = function(v) ESP_WINDOW = v; updateWindowESP() end })

EspTab:CreateDivider()
EspTab:CreateParagraph({ Title = "Esp Event", Text = "ESP for Christmas event" })
EspTab:CreateToggle({ Name = "ESP Tree", CurrentValue = false, Callback = function(v) ESP_TREE = v; updateEventESP() end })
EspTab:CreateToggle({ Name = "ESP Gift", CurrentValue = false, Callback = function(v) ESP_GIFT = v; updateEventESP() end })

EspTab:CreateDivider()
EspTab:CreateParagraph({ Title = "Esp Settings", Text = "ESP display options" })
EspTab:CreateToggle({ Name = "Show Name", CurrentValue = ShowName, Callback = function(v) ShowName = v end })
EspTab:CreateToggle({ Name = "Show Distance", CurrentValue = ShowDistance, Callback = function(v) ShowDistance = v end })
EspTab:CreateToggle({ Name = "Show Health", CurrentValue = ShowHP, Callback = function(v) ShowHP = v end })
EspTab:CreateToggle({ Name = "Show Highlight", CurrentValue = ShowHighlight, Callback = function(v) ShowHighlight = v end })
EspTab:CreateToggle({ Name = "Show Percent", CurrentValue = ShowPercent, Callback = function(v) ShowPercent = v end })

-- ============================================
-- BYPASS GATE
-- ============================================

local bypassGateEnabled = false

local function gatherGates()
    local gates = {}
    for _, folder in pairs(getMapFolders()) do
        for _, gate in pairs(folder:GetChildren()) do
            if gate.Name == "Gate" then
                table.insert(gates, gate)
            end
        end
    end
    return gates
end

local function setGateState(enabled)
    local gates = gatherGates()
    for _, gate in pairs(gates) do
        local leftGate = gate:FindFirstChild("LeftGate")
        local rightGate = gate:FindFirstChild("RightGate")
        local leftEnd = gate:FindFirstChild("LeftGate-end")
        local rightEnd = gate:FindFirstChild("RightGate-end")
        local box = gate:FindFirstChild("Box")
        if enabled then
            if leftGate then leftGate.Transparency = 1; leftGate.CanCollide = false end
            if rightGate then rightGate.Transparency = 1; rightGate.CanCollide = false end
            if leftEnd then leftEnd.Transparency = 0; leftEnd.CanCollide = true end
            if rightEnd then rightEnd.Transparency = 0; rightEnd.CanCollide = true end
            if box then box.CanCollide = false end
        else
            if leftGate then leftGate.Transparency = 0; leftGate.CanCollide = true end
            if rightGate then rightGate.Transparency = 0; rightGate.CanCollide = true end
            if leftEnd then leftEnd.Transparency = 1; leftEnd.CanCollide = true end
            if rightEnd then rightEnd.Transparency = 1; rightEnd.CanCollide = true end
            if box then box.CanCollide = true end
        end
    end
end

MainTab:CreateParagraph({ Title = "Feature Bypass", Text = "Bypass game mechanics" })
MainTab:CreateToggle({ Name = "Bypass Gate (Open Gate)", CurrentValue = false, Callback = function(v) bypassGateEnabled = v; setGateState(v) end })

-- ============================================
-- AUTO GENERATOR (SURVIVOR)
-- ============================================

SurTab:CreateParagraph({ Title = "Feature Survivor", Text = "Survivor utilities" })

local autoShoot = false
local autoparry = false

SurTab:CreateToggle({
    Name = "Auto Shoot (DONT USE IN DEV)",
    CurrentValue = false,
    Callback = function(v)
        autoShoot = v
        if autoShoot then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Items"):WaitForChild("Parrying Dagger"):WaitForChild("parry")
                while autoShoot do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Weapon") then
                                local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                                if targetRoot and (root.Position - targetRoot.Position).Magnitude <= 10 then
                                    remote:FireServer()
                                end
                            end
                        end
                    end
                    task.wait(0.001)
                end
            end)
        end
    end
})

SurTab:CreateToggle({
    Name = "Auto Parry (DONT USE IN DEV)",
    CurrentValue = false,
    Callback = function(v)
        autoparry = v
        if autoparry then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Items"):WaitForChild("Parrying Dagger"):WaitForChild("parry")
                while autoparry do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Weapon") then
                                local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                                if targetRoot and (root.Position - targetRoot.Position).Magnitude <= 10 then
                                    remote:FireServer()
                                end
                            end
                        end
                    end
                    task.wait(0.001)
                end
            end)
        end
    end
})

SurTab:CreateDivider()
SurTab:CreateParagraph({ Title = "Feature Generator", Text = "Auto repair generator" })

local autoGeneratorPerfect = false
local autoGeneratorNotPerfect = false

SurTab:CreateToggle({
    Name = "Auto SkillCheck (Perfect)",
    CurrentValue = false,
    Callback = function(v)
        autoGeneratorPerfect = v
        if autoGeneratorPerfect then
            task.spawn(function()
                local playerGui = LocalPlayer:WaitForChild("PlayerGui")
                local skillRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Generator"):WaitForChild("SkillCheckResultEvent")
                local repairRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Generator"):WaitForChild("RepairEvent")
                local lastGenPoint = nil
                local lastGenModel = nil
                while autoGeneratorPerfect do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChild("Humanoid")
                    if root and hum then
                        local isMoving = hum.MoveDirection.Magnitude > 0.05
                        local generators = getFolderGenerator()
                        local closestGen, closestPoint, closestDist = nil, nil, 10
                        for _, gen in ipairs(generators) do
                            for i = 1, 4 do
                                local point = gen:FindFirstChild("GeneratorPoint" .. i)
                                if point then
                                    local dist = (root.Position - point.Position).Magnitude
                                    if dist < closestDist then
                                        closestDist = dist
                                        closestGen = gen
                                        closestPoint = point
                                    end
                                end
                            end
                        end
                        if not lastGenPoint and closestPoint and closestDist < 6 then
                            lastGenModel = closestGen
                            lastGenPoint = closestPoint
                        end
                        if isMoving and lastGenPoint then
                            repairRemote:FireServer(lastGenPoint, false)
                            task.wait(0.2)
                            lastGenPoint = nil
                            lastGenModel = nil
                        end
                        local gui = playerGui:FindFirstChild("SkillCheckPromptGui")
                        if gui then
                            local check = gui:FindFirstChild("Check")
                            if check and check.Visible and lastGenPoint and root then
                                local d = (root.Position - lastGenPoint.Position).Magnitude
                                if d < 6 and lastGenModel and lastGenPoint then
                                    skillRemote:FireServer("success", 1, lastGenModel, lastGenPoint)
                                    check.Visible = false
                                end
                            end
                        end
                    end
                    task.wait(0.15)
                end
            end)
        end
    end
})

SurTab:CreateToggle({
    Name = "Auto SkillCheck (Not Perfect)",
    CurrentValue = false,
    Callback = function(v)
        autoGeneratorNotPerfect = v
        if autoGeneratorNotPerfect then
            task.spawn(function()
                local playerGui = LocalPlayer:WaitForChild("PlayerGui")
                local skillRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Generator"):WaitForChild("SkillCheckResultEvent")
                local repairRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Generator"):WaitForChild("RepairEvent")
                local lastGenPoint = nil
                local lastGenModel = nil
                while autoGeneratorNotPerfect do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChild("Humanoid")
                    if root and hum then
                        local isMoving = hum.MoveDirection.Magnitude > 0.05
                        local generators = getFolderGenerator()
                        local closestGen, closestPoint, closestDist = nil, nil, 10
                        for _, gen in ipairs(generators) do
                            for i = 1, 4 do
                                local point = gen:FindFirstChild("GeneratorPoint" .. i)
                                if point then
                                    local dist = (root.Position - point.Position).Magnitude
                                    if dist < closestDist then
                                        closestDist = dist
                                        closestGen = gen
                                        closestPoint = point
                                    end
                                end
                            end
                        end
                        if not lastGenPoint and closestPoint and closestDist < 6 then
                            lastGenModel = closestGen
                            lastGenPoint = closestPoint
                        end
                        if isMoving and lastGenPoint then
                            repairRemote:FireServer(lastGenPoint, false)
                            task.wait(0.2)
                            lastGenPoint = nil
                            lastGenModel = nil
                        end
                        local gui = playerGui:FindFirstChild("SkillCheckPromptGui")
                        if gui then
                            local check = gui:FindFirstChild("Check")
                            if check and check.Visible and lastGenPoint and root then
                                local d = (root.Position - lastGenPoint.Position).Magnitude
                                if d < 6 and lastGenModel and lastGenPoint then
                                    skillRemote:FireServer("neutral", 0, lastGenModel, lastGenPoint)
                                    check.Visible = false
                                end
                            end
                        end
                    end
                    task.wait(0.15)
                end
            end)
        end
    end
})

SurTab:CreateDivider()
SurTab:CreateParagraph({ Title = "Feature Exit", Text = "Auto lever for exit" })

local autoLeverEnabled = false

SurTab:CreateToggle({
    Name = "Auto Lever (No Hold)",
    CurrentValue = false,
    Callback = function(v)
        autoLeverEnabled = v
        if autoLeverEnabled then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Exit"):WaitForChild("LeverEvent")
                local isTouching = false
                UserInputService.TouchStarted:Connect(function() isTouching = true end)
                UserInputService.TouchEnded:Connect(function() isTouching = false end)
                local function getMapFoldersLocal()
                    local maps = {}
                    for _, obj in ipairs(workspace:GetChildren()) do
                        if obj:FindFirstChild("Gate") then
                            table.insert(maps, obj)
                        end
                    end
                    return maps
                end
                local lastPosition = nil
                while autoLeverEnabled do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if root and hum then
                        local closestMain = nil
                        local shortestDist = nil
                        for _, folder in ipairs(getMapFoldersLocal()) do
                            local gate = folder:FindFirstChild("Gate")
                            if gate and gate:FindFirstChild("ExitLever") then
                                local main = gate.ExitLever:FindFirstChild("Main")
                                if main then
                                    local dist = (root.Position - main.Position).Magnitude
                                    if not shortestDist or dist < shortestDist then
                                        shortestDist = dist
                                        closestMain = main
                                    end
                                end
                            end
                        end
                        local moved = lastPosition and (root.Position - lastPosition).Magnitude > 0.5
                        local tryingToMove = false
                        if UserInputService.KeyboardEnabled then
                            for _, key in ipairs({Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Space}) do
                                if UserInputService:IsKeyDown(key) then tryingToMove = true; break end
                            end
                        end
                        if UserInputService.TouchEnabled and isTouching then tryingToMove = true end
                        if (moved or tryingToMove) and closestMain then
                            remote:FireServer(closestMain, false)
                        elseif closestMain and shortestDist and shortestDist <= 10 then
                            remote:FireServer(closestMain, true)
                        end
                        lastPosition = root.Position
                    end
                    task.wait(0.2)
                end
            end)
        end
    end
})

SurTab:CreateDivider()
SurTab:CreateParagraph({ Title = "Feature Heal (TESTING)", Text = "Auto heal nearby survivors" })

local autoHealPerfect = false
local autoHealNotPerfect = false

SurTab:CreateToggle({
    Name = "Auto SkillCheck (Perfect)",
    CurrentValue = false,
    Callback = function(v)
        autoHealPerfect = v
        if autoHealPerfect then
            task.spawn(function()
                local playerGui = LocalPlayer:WaitForChild("PlayerGui")
                local healRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Healing"):WaitForChild("SkillCheckResultEvent")
                local lastHealTarget = nil
                local function getHealth(plr)
                    if not plr.Character then return 100 end
                    local hum = plr.Character:FindFirstChild("Humanoid")
                    if hum then return hum.Health end
                    local h = plr.Character:FindFirstChild("Health")
                    if h and h.Value then return h.Value end
                    return 100
                end
                while autoHealPerfect do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChild("Humanoid")
                    if root and hum then
                        local isMoving = hum.MoveDirection.Magnitude > 0.05
                        local closest = nil
                        local closestDist = 6
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character then
                                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                                if hrp and getHealth(plr) <= 60 then
                                    local dist = (root.Position - hrp.Position).Magnitude
                                    if dist < closestDist then
                                        closest = plr
                                        closestDist = dist
                                    end
                                end
                            end
                        end
                        if not lastHealTarget and closest then lastHealTarget = closest end
                        if isMoving then lastHealTarget = nil end
                        local gui = playerGui:FindFirstChild("SkillCheckPromptGui")
                        if gui then
                            local check = gui:FindFirstChild("Check")
                            if check and check.Visible and lastHealTarget and getHealth(lastHealTarget) <= 60 then
                                local targetChar = lastHealTarget.Character
                                if targetChar then
                                    healRemote:FireServer("success", 1, targetChar)
                                    check.Visible = false
                                end
                            end
                        end
                    end
                    task.wait(0.15)
                end
            end)
        end
    end
})

SurTab:CreateToggle({
    Name = "Auto SkillCheck (Not Perfect)",
    CurrentValue = false,
    Callback = function(v)
        autoHealNotPerfect = v
        if autoHealNotPerfect then
            task.spawn(function()
                local playerGui = LocalPlayer:WaitForChild("PlayerGui")
                local healRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Healing"):WaitForChild("SkillCheckResultEvent")
                local lastHealTarget = nil
                local function getHealth(plr)
                    if not plr.Character then return 100 end
                    local hum = plr.Character:FindFirstChild("Humanoid")
                    if hum then return hum.Health end
                    local h = plr.Character:FindFirstChild("Health")
                    if h and h.Value then return h.Value end
                    return 100
                end
                while autoHealNotPerfect do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChild("Humanoid")
                    if root and hum then
                        local isMoving = hum.MoveDirection.Magnitude > 0.05
                        local closest = nil
                        local closestDist = 6
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character then
                                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                                if hrp and getHealth(plr) <= 60 then
                                    local dist = (root.Position - hrp.Position).Magnitude
                                    if dist < closestDist then
                                        closest = plr
                                        closestDist = dist
                                    end
                                end
                            end
                        end
                        if not lastHealTarget and closest then lastHealTarget = closest end
                        if isMoving then lastHealTarget = nil end
                        local gui = playerGui:FindFirstChild("SkillCheckPromptGui")
                        if gui then
                            local check = gui:FindFirstChild("Check")
                            if check and check.Visible and lastHealTarget and getHealth(lastHealTarget) <= 60 then
                                local targetChar = lastHealTarget.Character
                                if targetChar then
                                    healRemote:FireServer("success", 1, targetChar)
                                    check.Visible = false
                                end
                            end
                        end
                    end
                    task.wait(0.15)
                end
            end)
        end
    end
})

SurTab:CreateDivider()
SurTab:CreateParagraph({ Title = "Feature Cheat", Text = "Cheat features" })

SurTab:CreateButton({
    Name = "Fling Killer (Spam if killer doesn't fling)",
    Callback = function()
        local Player = LocalPlayer
        local Targets = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Player and plr.Character and plr.Character:FindFirstChild("Weapon") then
                table.insert(Targets, plr.Name)
            end
        end
        local AllBool = false
        local GetPlayer = function(Name)
            Name = Name:lower()
            if Name == "all" or Name == "others" then
                AllBool = true
                return
            elseif Name == "random" then
                local GetPlayers = Players:GetPlayers()
                if table.find(GetPlayers, Player) then table.remove(GetPlayers, table.find(GetPlayers, Player)) end
                return GetPlayers[math.random(#GetPlayers)]
            else
                for _, x in next, Players:GetPlayers() do
                    if x ~= Player then
                        if x.Name:lower():match("^"..Name) or x.DisplayName:lower():match("^"..Name) then
                            return x
                        end
                    end
                end
            end
        end
        local SkidFling = function(TargetPlayer)
            local Character = Player.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            local RootPart = Humanoid and Humanoid.RootPart
            local TCharacter = TargetPlayer.Character
            local THumanoid = TCharacter and TCharacter:FindFirstChildOfClass("Humanoid")
            local TRootPart = THumanoid and THumanoid.RootPart
            local THead = TCharacter and TCharacter:FindFirstChild("Head")
            local Accessory = TCharacter and TCharacter:FindFirstChildOfClass("Accessory")
            local Handle = Accessory and Accessory:FindFirstChild("Handle")
            if Character and Humanoid and RootPart then
                if THumanoid and THumanoid.Sit and not AllBool then return end
                if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end
                local FPos = function(BasePart, Pos, Ang)
                    RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
                    Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
                    RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
                    RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
                end
                local SFBasePart = function(BasePart)
                    local TimeToWait = 2
                    local Time = tick()
                    local Angle = 0
                    repeat
                        if RootPart and THumanoid then
                            if BasePart.Velocity.Magnitude < 50 then
                                Angle += 100
                                FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                                task.wait()
                                FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                                task.wait()
                                FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                                task.wait()
                                FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                                task.wait()
                            else
                                FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                                task.wait()
                            end
                        else
                            break
                        end
                    until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= Players or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
                end
                workspace.FallenPartsDestroyHeight = 0/0
                local BV = Instance.new("BodyVelocity")
                BV.Name = "Mizu-Fling"
                BV.Parent = RootPart
                BV.Velocity = Vector3.new(9e9, 9e9, 9e9)
                BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                if TRootPart and THead then
                    if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then SFBasePart(THead) else SFBasePart(TRootPart) end
                elseif TRootPart then SFBasePart(TRootPart)
                elseif THead then SFBasePart(THead)
                elseif Handle then SFBasePart(Handle) end
                BV:Destroy()
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                getgenv().OldPos = getgenv().OldPos or RootPart.CFrame
                repeat
                    RootPart.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
                    Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
                    Humanoid:ChangeState("GettingUp")
                    for _, x in ipairs(Character:GetChildren()) do
                        if x:IsA("BasePart") then x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new() end
                    end
                    task.wait()
                until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
                workspace.FallenPartsDestroyHeight = getgenv().FPDH
            end
        end
        getgenv().Welcome = true
        if AllBool then
            for _, x in next, Players:GetPlayers() do SkidFling(x) end
        end
        for _, x in next, Targets do
            local TPlayer = GetPlayer(x)
            if TPlayer and TPlayer ~= Player then
                SkidFling(TPlayer)
            end
        end
    end
})

SurTab:CreateButton({
    Name = "Invisible (Not Visual)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/mabdu21/kjandsaddjadbhahayenajhsjbdwa/refs/heads/main/INV.lua"))()
    end
})

SurTab:CreateButton({
    Name = "Self UnHook (Not 100%)",
    Callback = function()
        ReplicatedStorage.Remotes.Carry.SelfUnHookEvent:FireServer()
    end
})

-- ============================================
-- KILLER: AIMBOT (REBRANDED)
-- ============================================

KillerTab:CreateParagraph({ Title = "Killer: The Veil", Text = "Aimbot for The Veil killer" })

local Mizu_AimbotEnabled = false
local Mizu_Aimbot28Enabled = false
local Mizu_LockedTarget = nil
local Mizu_MIN_PITCH = -1
local Mizu_MAX_PITCH = 30
local Mizu_ToughWall = true
local Mizu_Settings = { Aimbot = { SetKeybindLock = "None", SetKeybindLock28 = "None" } }
local Mizu_guiFolder = nil
local Mizu_mobileButton = nil
local Mizu_mobileButton28 = nil

KillerTab:CreateParagraph({
    Title = "Information: The Veil",
    Text = "• Aimbot is currently in BETA.\n• There is a chance of missing the target.\n• Aimbot will not support people at high places."
})

KillerTab:CreateToggle({
    Name = "Enable Aimbot (The Veil)",
    CurrentValue = false,
    Callback = function(state)
        if state and Mizu_Aimbot28Enabled then Mizu_Aimbot28Enabled = false; if Mizu_mobileButton28 then Mizu_mobileButton28.BackgroundColor3 = Color3.fromRGB(255, 60, 60) end end
        Mizu_AimbotEnabled = state
        if Mizu_mobileButton then Mizu_mobileButton.BackgroundColor3 = state and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60) end
    end
})

KillerTab:CreateToggle({
    Name = "Enable Aimbot Charge (The Veil)",
    CurrentValue = false,
    Callback = function(state)
        if state and Mizu_AimbotEnabled then Mizu_AimbotEnabled = false; if Mizu_mobileButton then Mizu_mobileButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60) end end
        Mizu_Aimbot28Enabled = state
        if Mizu_mobileButton28 then Mizu_mobileButton28.BackgroundColor3 = state and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60) end
    end
})

KillerTab:CreateDivider()
KillerTab:CreateParagraph({ Title = "Killer: The Veil Setting", Text = "Aimbot configuration" })

KillerTab:CreateInput({ Name = "Set Pitch Min (Value)", PlaceholderText = "Ex: -1", Callback = function(v) local n = tonumber(v); if n then Mizu_MIN_PITCH = n end end })
KillerTab:CreateInput({ Name = "Set Pitch Max (Value)", PlaceholderText = "Ex: 30", Callback = function(v) local n = tonumber(v); if n then Mizu_MAX_PITCH = n end end })
KillerTab:CreateToggle({ Name = "Tough Wall (The Veil)", CurrentValue = true, Callback = function(v) Mizu_ToughWall = v end })
KillerTab:CreateKeybind({ Name = "Set Keybind Aimbot (PC ONLY)", CurrentKey = "None", Callback = function(v) Mizu_Settings.Aimbot.SetKeybindLock = v end })
KillerTab:CreateKeybind({ Name = "Set Keybind Aimbot Charge (PC ONLY)", CurrentKey = "None", Callback = function(v) Mizu_Settings.Aimbot.SetKeybindLock28 = v end })

local function Mizu_GetLocalRoot()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function Mizu_GetClosestInScreen()
    local closest = nil
    local minDist = math.huge
    local mouse = UserInputService:GetMouseLocation()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = plr
                    end
                end
            end
        end
    end
    return closest
end

local function Mizu_GetClosestByDistance()
    local root = Mizu_GetLocalRoot()
    if not root then return nil end
    local closest, distMin = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local r = plr.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local dist = (root.Position - r.Position).Magnitude
                if dist < distMin then
                    distMin = dist
                    closest = plr
                end
            end
        end
    end
    return closest, distMin
end

local function Mizu_CanSeeTarget(target)
    if Mizu_ToughWall then return true end
    local head = target.Character and target.Character:FindFirstChild("Head")
    local root = Mizu_GetLocalRoot()
    if not head or not root then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = { LocalPlayer.Character or {}, target.Character }
    local result = workspace:Raycast(root.Position + Vector3.new(0, 2, 0), head.Position - root.Position, params)
    return not result
end

local function Mizu_GetAutoPitchMax(distance)
    if distance >= 190 and distance <= 300 then return 45.5
    elseif distance >= 150 and distance <= 185 then return 40.5
    elseif distance >= 90 and distance <= 145 then return 36.5
    else return 30.5 end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local key = input.KeyCode.Name
    if input.UserInputType == Enum.UserInputType.MouseButton1 then key = "MouseLeft"
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then key = "MouseRight" end
    if key == Mizu_Settings.Aimbot.SetKeybindLock then
        Mizu_AimbotEnabled = not Mizu_AimbotEnabled
        if Mizu_AimbotEnabled and Mizu_Aimbot28Enabled then Mizu_Aimbot28Enabled = false; if Mizu_mobileButton28 then Mizu_mobileButton28.BackgroundColor3 = Color3.fromRGB(255, 60, 60) end end
        if Mizu_mobileButton then Mizu_mobileButton.BackgroundColor3 = Mizu_AimbotEnabled and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60) end
    end
    if key == Mizu_Settings.Aimbot.SetKeybindLock28 then
        Mizu_Aimbot28Enabled = not Mizu_Aimbot28Enabled
        if Mizu_Aimbot28Enabled and Mizu_AimbotEnabled then Mizu_AimbotEnabled = false; if Mizu_mobileButton then Mizu_mobileButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60) end end
        if Mizu_mobileButton28 then Mizu_mobileButton28.BackgroundColor3 = Mizu_Aimbot28Enabled and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60) end
    end
end)

local function Mizu_AimAt_Normal(target)
    if not target.Character then return end
    local head = target.Character:FindFirstChild("Head")
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    local localRoot = Mizu_GetLocalRoot()
    if not head or not hrp or not localRoot then return end
    local predictedPos = head.Position + (hrp.Velocity * 0.14)
    local distance = (localRoot.Position - predictedPos).Magnitude
    local autoPitchMax = Mizu_GetAutoPitchMax(distance)
    local alpha = math.clamp((distance - 1) / (250 - 1), 0, 1)
    local pitch = Mizu_MIN_PITCH + (autoPitchMax - Mizu_MIN_PITCH) * alpha
    local dir = (predictedPos - Camera.CFrame.Position).Unit
    local yaw = math.atan2(dir.X, dir.Z)
    local pitchRad = math.rad(pitch)
    local look = Vector3.new(math.sin(yaw) * math.cos(pitchRad), math.sin(pitchRad), math.cos(yaw) * math.cos(pitchRad))
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + look)
end

local function Mizu_GetPitchByDistance(dist)
    if dist < 1 then return 0.09 elseif dist < 10 then return 0.90 elseif dist < 20 then return 1.9
    elseif dist < 30 then return 2.9 elseif dist < 40 then return 3.9 elseif dist < 50 then return 4.9
    elseif dist < 60 then return 5.9 elseif dist < 70 then return 6.9 elseif dist < 80 then return 7.9
    elseif dist < 90 then return 8.9 elseif dist < 100 then return 10.9 elseif dist < 110 then return 11.9
    elseif dist < 120 then return 12.9 elseif dist < 130 then return 13.9 elseif dist < 140 then return 14.9
    elseif dist < 150 then return 15.9 elseif dist < 160 then return 16.9 elseif dist < 170 then return 17.9
    elseif dist < 180 then return 18.9 elseif dist < 190 then return 20.3 elseif dist < 200 then return 22.3
    else return 23.3 end
end

local function Mizu_AimAt_28(target)
    if not target.Character then return end
    local head = target.Character:FindFirstChild("Head")
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    local localRoot = Mizu_GetLocalRoot()
    if not head or not hrp or not localRoot then return end
    local predictedPos = head.Position + (hrp.Velocity * 0.14)
    local dist = (predictedPos - Camera.CFrame.Position).Magnitude
    local pitch = Mizu_GetPitchByDistance(dist)
    local dir = (predictedPos - Camera.CFrame.Position).Unit
    local yaw = math.atan2(dir.X, dir.Z)
    local pitchRad = math.rad(pitch)
    local look = Vector3.new(math.sin(yaw) * math.cos(pitchRad), math.sin(pitchRad), math.cos(yaw) * math.cos(pitchRad))
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + look)
end

RunService.RenderStepped:Connect(function()
    if Mizu_AimbotEnabled then
        Mizu_LockedTarget = Mizu_GetClosestInScreen()
        if Mizu_LockedTarget and Mizu_CanSeeTarget(Mizu_LockedTarget) then
            Mizu_AimAt_Normal(Mizu_LockedTarget)
        end
    elseif Mizu_Aimbot28Enabled then
        Mizu_LockedTarget = Mizu_GetClosestByDistance()
        if Mizu_LockedTarget and Mizu_CanSeeTarget(Mizu_LockedTarget) then
            Mizu_AimAt_28(Mizu_LockedTarget)
        end
    end
end)

-- Mobile GUI for Aimbot
local function Mizu_EnsureGUIFolder()
    if not Mizu_guiFolder then
        Mizu_guiFolder = Instance.new("ScreenGui")
        Mizu_guiFolder.Name = "MizuHub_GUI"
        Mizu_guiFolder.Parent = LocalPlayer:WaitForChild("PlayerGui")
        Mizu_guiFolder.ResetOnSpawn = false
    end
end

local Mizu_AimbotToggleGUIVisible = false
local Mizu_Aimbot28ToggleGUIVisible = false

local function Mizu_CreateMobileButtons()
    if Mizu_mobileButton then Mizu_mobileButton:Destroy() end
    if Mizu_mobileButton28 then Mizu_mobileButton28:Destroy() end
    Mizu_EnsureGUIFolder()
    Mizu_mobileButton = Instance.new("TextButton")
    Mizu_mobileButton.Size = UDim2.new(0, 90, 0, 90)
    Mizu_mobileButton.Position = UDim2.new(1, -40, 1, -40)
    Mizu_mobileButton.AnchorPoint = Vector2.new(1, 1)
    Mizu_mobileButton.BackgroundColor3 = Mizu_AimbotEnabled and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
    Mizu_mobileButton.Text = "🗡️"
    Mizu_mobileButton.TextSize = 36
    Mizu_mobileButton.Font = Enum.Font.GothamBold
    Mizu_mobileButton.TextColor3 = Color3.new(1, 1, 1)
    Mizu_mobileButton.Visible = Mizu_AimbotToggleGUIVisible
    Mizu_mobileButton.Parent = Mizu_guiFolder
    local corner1 = Instance.new("UICorner")
    corner1.CornerRadius = UDim.new(0, 45)
    corner1.Parent = Mizu_mobileButton
    Mizu_mobileButton.MouseButton1Click:Connect(function()
        Mizu_AimbotEnabled = not Mizu_AimbotEnabled
        if Mizu_AimbotEnabled and Mizu_Aimbot28Enabled then Mizu_Aimbot28Enabled = false; if Mizu_mobileButton28 then Mizu_mobileButton28.BackgroundColor3 = Color3.fromRGB(255, 60, 60) end end
        Mizu_mobileButton.BackgroundColor3 = Mizu_AimbotEnabled and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
    end)
    Mizu_mobileButton28 = Instance.new("TextButton")
    Mizu_mobileButton28.Size = UDim2.new(0, 90, 0, 90)
    Mizu_mobileButton28.Position = UDim2.new(1, -140, 1, -40)
    Mizu_mobileButton28.AnchorPoint = Vector2.new(1, 1)
    Mizu_mobileButton28.BackgroundColor3 = Mizu_Aimbot28Enabled and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
    Mizu_mobileButton28.Text = "⚔️"
    Mizu_mobileButton28.TextSize = 36
    Mizu_mobileButton28.Font = Enum.Font.GothamBold
    Mizu_mobileButton28.TextColor3 = Color3.new(1, 1, 1)
    Mizu_mobileButton28.Visible = Mizu_Aimbot28ToggleGUIVisible
    Mizu_mobileButton28.Parent = Mizu_guiFolder
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 45)
    corner2.Parent = Mizu_mobileButton28
    Mizu_mobileButton28.MouseButton1Click:Connect(function()
        Mizu_Aimbot28Enabled = not Mizu_Aimbot28Enabled
        if Mizu_Aimbot28Enabled and Mizu_AimbotEnabled then Mizu_AimbotEnabled = false; if Mizu_mobileButton then Mizu_mobileButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60) end end
        Mizu_mobileButton28.BackgroundColor3 = Mizu_Aimbot28Enabled and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
    end)
end

task.spawn(function()
    while task.wait(1) do
        Mizu_EnsureGUIFolder()
        Mizu_CreateMobileButtons()
        local playergui = LocalPlayer:WaitForChild("PlayerGui")
        local Gui = playergui:FindFirstChild("MizuHub_GUI")
        if Gui and Gui.Enabled == false then Gui.Enabled = true end
    end
end)

KillerTab:CreateDivider()
KillerTab:CreateParagraph({ Title = "Killer: The Veil GUI", Text = "Mobile toggle buttons" })
KillerTab:CreateToggle({ Name = "Enable Aimbot (Toggle GUI)", CurrentValue = false, Callback = function(v) Mizu_AimbotToggleGUIVisible = v; if Mizu_mobileButton then Mizu_mobileButton.Visible = v end end })
KillerTab:CreateToggle({ Name = "Enable Aimbot Charge (Toggle GUI)", CurrentValue = false, Callback = function(v) Mizu_Aimbot28ToggleGUIVisible = v; if Mizu_mobileButton28 then Mizu_mobileButton28.Visible = v end end })

KillerTab:CreateDivider()
KillerTab:CreateParagraph({ Title = "Killer: The Masked", Text = "Mask selection for The Masked killer" })
KillerTab:CreateParagraph({
    Title = "Information: The Masked",
    Text = "• Richard (No Abilities)\n• Tony (One Shot, No hold)\n• Brandon (Speed Boost)\n• Jake (Lunge Range)\n• Richter (Removes terror radius)\n• Graham (Faster Vault)\n• Alex (Chainsaw, One Shot)"
})

local masks = { "Richard", "Tony", "Brandon", "Jake", "Richter", "Graham", "Alex" }
local selectedMask = "Richard"
KillerTab:CreateDropdown({ Name = "Select Mask", Options = masks, CurrentOption = {"Richard"}, Callback = function(v) selectedMask = v[1] end })
KillerTab:CreateButton({ Name = "Choose Mask (Selected)", Callback = function() ReplicatedStorage.Remotes.Killers.Masked.Activatepower:FireServer(selectedMask) end })
KillerTab:CreateButton({ Name = "Random Mask (Legit Mode)", Callback = function() local randomMask = masks[math.random(1, #masks)]; ReplicatedStorage.Remotes.Killers.Masked.Activatepower:FireServer(randomMask) end })

KillerTab:CreateDivider()
KillerTab:CreateParagraph({ Title = "Killer: The Stalker", Text = "Stalker ability" })

local Stalker = false
KillerTab:CreateToggle({
    Name = "Start Stalker (Raycast / Remote)",
    CurrentValue = false,
    Callback = function(v)
        Stalker = v
        task.spawn(function()
            while Stalker do
                task.wait(0.2)
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then continue end
                local weapon = char:FindFirstChild("Weapon") or workspace:FindFirstChild(LocalPlayer.Name) and workspace[LocalPlayer.Name]:FindFirstChild("Weapon")
                if not weapon then continue end
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        local humanoid = plr.Character:FindFirstChild("Humanoid")
                        if hrp and humanoid then
                            local dist = (root.Position - hrp.Position).Magnitude
                            if dist >= 30 and dist <= 70 and humanoid.Health > 20 then
                                local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Killers"):WaitForChild("Stalker"):WaitForChild("StartStalking")
                                remote:FireServer(plr)
                            end
                        end
                    end
                end
            end
        end)
    end
})

KillerTab:CreateDivider()
KillerTab:CreateParagraph({ Title = "Feature Killer", Text = "Killer utilities" })

local killallEnabled = false
KillerTab:CreateToggle({
    Name = "Kill All (Warning: Get Ban)",
    CurrentValue = false,
    Callback = function(v)
        killallEnabled = v
        if killallEnabled then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attacks"):WaitForChild("BasicAttack")
                local startCFrame = nil
                while killallEnabled do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        if not startCFrame then startCFrame = root.CFrame end
                        local targets = {}
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character then
                                local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                                local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                                if targetRoot and humanoid then table.insert(targets, { player = plr, root = targetRoot, humanoid = humanoid }) end
                            end
                        end
                        for _, entry in ipairs(targets) do
                            if not killallEnabled then break end
                            local humanoid = entry.humanoid
                            if humanoid and humanoid.Health > 20 and entry.root and entry.root.Parent then
                                pcall(function()
                                    root.CFrame = entry.root.CFrame * CFrame.new(0, 0, 2)
                                    remote:FireServer()
                                end)
                                task.wait(0.15)
                            end
                        end
                        local allLowHealth = true
                        for _, entry in ipairs(targets) do
                            if entry.humanoid.Health > 20 then allLowHealth = false; break end
                        end
                        if allLowHealth and startCFrame then root.CFrame = startCFrame; task.wait(1) else task.wait(0.2) end
                    else task.wait(0.2) end
                end
            end)
        end
    end
})

local Autocarry = false
KillerTab:CreateToggle({
    Name = "Auto Carry (Nearby Survivor / 2.5s)",
    CurrentValue = false,
    Callback = function(v)
        Autocarry = v
        task.spawn(function()
            while Autocarry do
                task.wait(2.5)
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end
                local candidates = {}
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local hum = plr.Character:FindFirstChild("Humanoid")
                        local otherHrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if hum and otherHrp and hum.Health == 20 then
                            local dist = (hrp.Position - otherHrp.Position).Magnitude
                            if dist <= 10 then table.insert(candidates, plr) end
                        end
                    end
                end
                if #candidates ~= 1 then continue end
                local target = candidates[1]
                if target and target.Character then
                    local tHum = target.Character:FindFirstChild("Humanoid")
                    if tHum and tHum.Health == 20 then
                        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Carry"):WaitForChild("CarrySurvivorEvent"):FireServer(target.Character)
                        task.wait(5)
                    end
                end
            end
        end)
    end
})

local AutoHook = false
KillerTab:CreateToggle({
    Name = "Auto Hook (Nearby Hook / 2.5s)",
    CurrentValue = false,
    Callback = function(v)
        AutoHook = v
        task.spawn(function()
            while AutoHook do
                task.wait(2.5)
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end
                local candidates = {}
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local hum = plr.Character:FindFirstChild("Humanoid")
                        local thrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if hum and thrp and hum.Health == 20 then
                            local dist = (hrp.Position - thrp.Position).Magnitude
                            if dist <= 10 then table.insert(candidates, plr) end
                        end
                    end
                end
                if #candidates ~= 1 then continue end
                local nearestHook = nil
                local nearestDist = 10
                local hookFolder = workspace:WaitForChild("Map"):WaitForChild("Hook")
                for _, hookObj in ipairs(hookFolder:GetChildren()) do
                    local hookPoint = hookObj:FindFirstChild("HookPoint")
                    if hookPoint then
                        local dist = (hrp.Position - hookPoint.Position).Magnitude
                        if dist <= nearestDist then nearestDist = dist; nearestHook = hookPoint end
                    end
                end
                if not nearestHook then continue end
                ReplicatedStorage.Remotes.Carry.HookEvent:FireServer(nearestHook)
                task.wait(5)
            end
        end)
    end
})

KillerTab:CreateDivider()
KillerTab:CreateParagraph({ Title = "Feature Fun", Text = "Fun utilities" })

local GrabKey = "None"
KillerTab:CreateKeybind({ Name = "Set Keybind Grab (PC ONLY)", CurrentKey = "None", Callback = function(v) GrabKey = v end })

local function DoGrab()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local candidates = {}
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= LocalPlayer and target.Character then
            local hum = target.Character:FindFirstChild("Humanoid")
            local thrp = target.Character:FindFirstChild("HumanoidRootPart")
            if hum and thrp then
                local dist = (hrp.Position - thrp.Position).Magnitude
                if dist <= 20 and hum.Health ~= 20 then table.insert(candidates, target) end
            end
        end
    end
    if #candidates ~= 1 then return end
    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Killers"):WaitForChild("Stalker"):WaitForChild("grab"):FireServer(candidates[1].Character)
end

KillerTab:CreateButton({ Name = "Grab (Nearby Survivor/Killer)", Callback = DoGrab })

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not GrabKey or GrabKey == "None" then return end
    local key = input.KeyCode.Name
    if input.UserInputType == Enum.UserInputType.MouseButton1 then key = "MouseLeft"
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then key = "MouseRight" end
    if key == GrabKey then DoGrab() end
end)

local nocooldownskillEnabled = false
KillerTab:CreateToggle({
    Name = "Auto Attack (No Animation)",
    CurrentValue = false,
    Callback = function(v)
        nocooldownskillEnabled = v
        if nocooldownskillEnabled then
            task.spawn(function()
                local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attacks"):WaitForChild("BasicAttack")
                while nocooldownskillEnabled do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local closestTarget = nil
                        local closestDist = 10
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character then
                                local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                                local targetHumanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                                if targetRoot and targetHumanoid then
                                    local dist = (root.Position - targetRoot.Position).Magnitude
                                    if dist <= closestDist and targetHumanoid.Health > 20 then
                                        closestDist = dist
                                        closestTarget = plr.Character
                                    end
                                end
                            end
                        end
                        if closestTarget then remote:FireServer() end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

KillerTab:CreateDivider()
KillerTab:CreateParagraph({ Title = "Feature Cheat", Text = "Cheat features" })

local noFlashlightEnabled = false
KillerTab:CreateToggle({ Name = "No Flashlight", CurrentValue = false, Callback = function(v) noFlashlightEnabled = v end })

task.spawn(function()
    while true do
        task.wait(0.5)
        if noFlashlightEnabled then
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                for _, descendant in pairs(playerGui:GetDescendants()) do
                    if descendant:IsA("GuiObject") and descendant.Name == "Blind" then descendant:Destroy() end
                end
            end
        end
    end
end)

local destroyPalletwrong = false
local function removePalletwrong(parent)
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("Model") and child.Name == "Palletwrong" then child:Destroy() else removePalletwrong(child) end
    end
end
KillerTab:CreateToggle({ Name = "Remove Palletwrong (All)", CurrentValue = false, Callback = function(v) destroyPalletwrong = v; if v then task.spawn(function() while destroyPalletwrong do removePalletwrong(workspace); task.wait(0.69) end end) end end })

KillerTab:CreateButton({ Name = "Fix Cam (3rd Person Camera)", Callback = function()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = humanoid
        LocalPlayer.CameraMinZoomDistance = 0.5
        LocalPlayer.CameraMaxZoomDistance = 400
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        local head = character:FindFirstChild("Head")
        if head then head.Anchored = false end
    end
end })

-- ============================================
-- VISUAL (MAIN TAB)
-- ============================================

MainTab:CreateParagraph({ Title = "Feature Visual", Text = "Visual enhancements" })

local fullBrightEnabled = false
local noFogEnabled = false

MainTab:CreateToggle({
    Name = "Full Bright",
    CurrentValue = false,
    Callback = function(v)
        fullBrightEnabled = v
        if v then
            task.spawn(function()
                while fullBrightEnabled do
                    if Lighting.Brightness ~= 2 then Lighting.Brightness = 2 end
                    if Lighting.ClockTime ~= 14 then Lighting.ClockTime = 14 end
                    if Lighting.Ambient ~= Color3.fromRGB(255, 255, 255) then Lighting.Ambient = Color3.fromRGB(255, 255, 255) end
                    task.wait(0.5)
                end
            end)
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 12
            Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        end
    end
})

MainTab:CreateToggle({
    Name = "No Fog",
    CurrentValue = false,
    Callback = function(v)
        noFogEnabled = v
        if v then
            task.spawn(function()
                while noFogEnabled do
                    if Lighting:FindFirstChild("Atmosphere") and Lighting.Atmosphere.Density ~= 0 then Lighting.Atmosphere.Density = 0 end
                    task.wait(0.5)
                end
            end)
        else
            if Lighting:FindFirstChild("Atmosphere") then Lighting.Atmosphere.Density = 0.5 end
        end
    end
})

MainTab:CreateDivider()
MainTab:CreateParagraph({ Title = "Misc", Text = "Miscellaneous features" })

local AntiAFK = true
MainTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = true,
    Callback = function(v)
        AntiAFK = v
        task.spawn(function()
            local vu = game:GetService("VirtualUser")
            while AntiAFK do
                vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(math.random(150, 270))
                vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(math.random(150, 270))
            end
        end)
    end
})

-- ============================================
-- PLAYER TAB
-- ============================================

PlayerTab:CreateParagraph({ Title = "Feature Player", Text = "Player movement modifiers" })

local speedEnabled, flyNoclipSpeed = false, 3
local speedConnection, noclipConnection = nil, nil

PlayerTab:CreateSlider({ Name = "Set Speed Value", Range = {1, 999}, Increment = 1, CurrentValue = 5, Callback = function(v) flyNoclipSpeed = v end })
PlayerTab:CreateToggle({
    Name = "Enable Speed",
    CurrentValue = false,
    Callback = function(v)
        speedEnabled = v
        if speedEnabled then
            if speedConnection then speedConnection:Disconnect() end
            speedConnection = RunService.RenderStepped:Connect(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.MoveDirection.Magnitude > 0 then
                    char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + char.Humanoid.MoveDirection * flyNoclipSpeed * 0.004
                end
            end)
        else
            if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
        end
    end
})

PlayerTab:CreateDivider()
PlayerTab:CreateParagraph({ Title = "Feature Power", Text = "Character modifiers" })

PlayerTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Callback = function(state)
        if state then
            noclipConnection = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        else
            if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    end
})

local NoFallEnabled = false
local FallRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Mechanics"):WaitForChild("Fall")
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if NoFallEnabled and self == FallRemote and method == "FireServer" then return nil end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

PlayerTab:CreateToggle({ Name = "No Fall (Beta)", CurrentValue = false, Callback = function(v) NoFallEnabled = v end })

-- ============================================
-- HITBOX TAB
-- ============================================

HitboxTab:CreateParagraph({
    Title = "Hitbox System (Killer Only)",
    Text = "• Universal Killer Support\n• Precision Slash Modules\n• Optimized Range Handler"
})

local transparency = 0.95
local hitboxSize = 10
local hitboxEnabled = false
local hitboxConnection = nil

HitboxTab:CreateInput({ Name = "Set Transparency (Visible)", PlaceholderText = "Transparency (Ex: 0.95)", Callback = function(text) local num = tonumber(text); if num then transparency = math.clamp(num, 0, 1) end end })
HitboxTab:CreateInput({ Name = "Set Hitbox (Size)", PlaceholderText = "Range (Ex: 10)", Callback = function(text) local num = tonumber(text); if num then hitboxSize = num end end })

HitboxTab:CreateToggle({
    Name = "Enable Hitbox",
    CurrentValue = false,
    Callback = function(v)
        hitboxEnabled = v
        if hitboxConnection then hitboxConnection:Disconnect(); hitboxConnection = nil end
        if hitboxEnabled then
            hitboxConnection = RunService.RenderStepped:Connect(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local part = player.Character.HumanoidRootPart
                        pcall(function()
                            part.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                            part.Transparency = transparency
                            part.BrickColor = BrickColor.new("Really red")
                            part.Material = Enum.Material.Neon
                            part.CanCollide = false
                        end)
                    end
                end
            end)
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local part = player.Character.HumanoidRootPart
                    pcall(function()
                        part.Size = Vector3.new(2, 2, 1)
                        part.Transparency = 1
                        part.Material = Enum.Material.Plastic
                    end)
                end
            end
        end
    end
})

-- ============================================
-- TELEPORT TAB
-- ============================================

local LOBBY_POSITION = Vector3.new(653.552002, 684.317444, 1577.81934)

local function getCFrame(obj)
    if obj:IsA("BasePart") then return obj.CFrame
    elseif obj:IsA("Model") then
        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        return part and part.CFrame
    end
end

local function getAllGenerators()
    local list, count = {}, 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "Generator" and (obj:IsA("Model") or obj:IsA("BasePart")) then
            count = count + 1
            table.insert(list, { Name = "Generator " .. count, Object = obj })
        end
    end
    return list
end

local function getAllGifts()
    local list, count = {}, 0
    for _, folder in pairs(getEventFolders()) do
        for _, obj in ipairs(folder:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Gift" then
                count = count + 1
                table.insert(list, { Name = "Gift " .. count, Object = obj })
            end
        end
    end
    return list
end

local function getAllTrees()
    local list, count = {}, 0
    for _, folder in pairs(getEventFolders()) do
        for _, obj in ipairs(folder:GetDescendants()) do
            if obj:IsA("Model") and obj.Name == "Model" then
                local parent = obj.Parent.Name:lower()
                if parent:find("tree") or parent:find("chrismta") then
                    count = count + 1
                    table.insert(list, { Name = "Tree " .. count, Object = obj })
                end
            end
        end
    end
    return list
end

TeleportTab:CreateParagraph({ Title = "Teleport: Place", Text = "Teleport to locations" })

local Place
TeleportTab:CreateDropdown({ Name = "Select Place", Options = { "Lobby", "Game" }, Callback = function(v) Place = v[1] end })
TeleportTab:CreateButton({ Name = "Teleport", Callback = function()
    if Place == "Lobby" then LocalPlayer.Character:PivotTo(CFrame.new(LOBBY_POSITION))
    elseif Place == "Game" then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Weapon") then
                LocalPlayer.Character:PivotTo(p.Character.PrimaryPart.CFrame * CFrame.new(0, 0, 200))
                break
            end
        end
    end
end })

TeleportTab:CreateDivider()
TeleportTab:CreateParagraph({ Title = "Teleport: Generator", Text = "Teleport to generators" })

local generatorList = getAllGenerators()
local GenTarget
local GenDropdown = TeleportTab:CreateDropdown({ Name = "Select Generator", Options = (function() local t = {}; for _, g in ipairs(generatorList) do table.insert(t, g.Name) end; return t end)(), Callback = function(v) for _, g in ipairs(generatorList) do if g.Name == v[1] then GenTarget = g.Object end end end })
TeleportTab:CreateButton({ Name = "Teleport", Callback = function() if GenTarget then LocalPlayer.Character:PivotTo(getCFrame(GenTarget)) end end })
TeleportTab:CreateButton({ Name = "Refresh Generator", Callback = function() generatorList = getAllGenerators(); local t = {}; for _, g in ipairs(generatorList) do table.insert(t, g.Name) end; GenDropdown:SetOptions(t) end })

TeleportTab:CreateDivider()
TeleportTab:CreateParagraph({ Title = "Teleport: Gift", Text = "Teleport to gifts" })

local giftList = getAllGifts()
local GiftTarget
local GiftDropdown = TeleportTab:CreateDropdown({ Name = "Select Gift", Options = (function() local t = {}; for _, g in ipairs(giftList) do table.insert(t, g.Name) end; return t end)(), Callback = function(v) for _, g in ipairs(giftList) do if g.Name == v[1] then GiftTarget = g.Object end end end })
TeleportTab:CreateButton({ Name = "Teleport", Callback = function() if GiftTarget then LocalPlayer.Character:PivotTo(getCFrame(GiftTarget)) end end })
TeleportTab:CreateButton({ Name = "Refresh Gifts", Callback = function() giftList = getAllGifts(); local t = {}; for _, g in ipairs(giftList) do table.insert(t, g.Name) end; GiftDropdown:SetOptions(t) end })

TeleportTab:CreateDivider()
TeleportTab:CreateParagraph({ Title = "Teleport: Tree", Text = "Teleport to Christmas trees" })

local treeList = getAllTrees()
local TreeTarget
local TreeDropdown = TeleportTab:CreateDropdown({ Name = "Select Tree", Options = (function() local t = {}; for _, tr in ipairs(treeList) do table.insert(t, tr.Name) end; return t end)(), Callback = function(v) for _, tr in ipairs(treeList) do if tr.Name == v[1] then TreeTarget = tr.Object end end end })
TeleportTab:CreateButton({ Name = "Teleport", Callback = function() if TreeTarget then LocalPlayer.Character:PivotTo(getCFrame(TreeTarget)) end end })
TeleportTab:CreateButton({ Name = "Refresh Trees", Callback = function() treeList = getAllTrees(); local t = {}; for _, tr in ipairs(treeList) do table.insert(t, tr.Name) end; TreeDropdown:SetOptions(t) end })

TeleportTab:CreateDivider()
TeleportTab:CreateButton({ Name = "Refresh All", Callback = function()
    generatorList = getAllGenerators(); local genValues = {}; for _, g in ipairs(generatorList) do table.insert(genValues, g.Name) end; if GenDropdown then GenDropdown:SetOptions(genValues) end; GenTarget = nil
    giftList = getAllGifts(); local giftValues = {}; for _, g in ipairs(giftList) do table.insert(giftValues, g.Name) end; if GiftDropdown then GiftDropdown:SetOptions(giftValues) end; GiftTarget = nil
    treeList = getAllTrees(); local treeValues = {}; for _, tr in ipairs(treeList) do table.insert(treeValues, tr.Name) end; if TreeDropdown then TreeDropdown:SetOptions(treeValues) end; TreeTarget = nil
end })

-- ============================================
-- XMAS FARM
-- ============================================

MasTab:CreateParagraph({
    Title = "Auto Farm: Gift (BETA)",
    Text = "• Warp collect gifts\n• Warp send gifts\n• Skip trees in-game"
})

local AutoFarmGift = false
local AutoSendGift = false
local SendingGift = false
local LastPosition = nil
local SAFE_DISTANCE = 80
local GiftRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Events"):WaitForChild("Christmas"):WaitForChild("gift")

local function Mizu_GetChar() return LocalPlayer.Character end
local function Mizu_GetHRP() local char = Mizu_GetChar(); return char and char:FindFirstChild("HumanoidRootPart") end
local function Mizu_IsAlive() local char = Mizu_GetChar(); local hum = char and char:FindFirstChildOfClass("Humanoid"); return hum and hum.Health > 0 end
local function Mizu_TP(cf) local hrp = Mizu_GetHRP(); if hrp then hrp.CFrame = cf + Vector3.new(0, 3, 0) end end
local function Mizu_HasGift() local char = Mizu_GetChar(); return char and char:FindFirstChild("Gift") ~= nil end

local function Mizu_IsGiftInPlayerCharacter(giftModel)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character and giftModel:IsDescendantOf(plr.Character) then return true end
    end
    return false
end

local function Mizu_IsTreeInLobby(treeObj)
    local lobby = workspace:FindFirstChild("Lobby")
    if not lobby then return false end
    return treeObj:IsDescendantOf(lobby)
end

local function Mizu_PlayerWithWeaponNear(pos)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position - pos).Magnitude <= SAFE_DISTANCE then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then return true end
                end
            end
        end
    end
    return false
end

local function Mizu_GetNearestGift()
    local hrp = Mizu_GetHRP()
    if not hrp then return nil end
    local nearest, dist = nil, math.huge
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "Gift" and obj.PrimaryPart and obj:FindFirstChild("GiftHandle") and not Mizu_IsGiftInPlayerCharacter(obj) then
            local d = (hrp.Position - obj.PrimaryPart.Position).Magnitude
            if d < dist and not Mizu_PlayerWithWeaponNear(obj.PrimaryPart.Position) then
                dist = d
                nearest = obj
            end
        end
    end
    return nearest
end

local function Mizu_GetNearestTree()
    local hrp = Mizu_GetHRP()
    if not hrp then return nil end
    local nearest, dist = nil, math.huge
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == "ChristmasTree" and not Mizu_IsTreeInLobby(obj) then
            local pine = obj:FindFirstChild("TreePine")
            if pine then
                local pos = pine:IsA("BasePart") and pine.Position or (pine:IsA("Model") and pine.PrimaryPart and pine.PrimaryPart.Position)
                if pos then
                    local d = (hrp.Position - pos).Magnitude
                    if d < dist and not Mizu_PlayerWithWeaponNear(pos) then
                        dist = d
                        nearest = pine
                    end
                end
            end
        end
    end
    return nearest
end

task.spawn(function()
    while true do
        task.wait(0.35)
        if not Mizu_IsAlive() or not Mizu_GetHRP() then task.wait(1) continue end
        pcall(function()
            if AutoSendGift and Mizu_HasGift() and not SendingGift then
                SendingGift = true
                LastPosition = Mizu_GetHRP().CFrame
                local tree = Mizu_GetNearestTree()
                if tree then
                    if tree:IsA("BasePart") then Mizu_TP(tree.CFrame)
                    elseif tree:IsA("Model") and tree.PrimaryPart then Mizu_TP(tree.PrimaryPart.CFrame) end
                    repeat task.wait(0.2) until not Mizu_HasGift()
                    task.wait(0.3)
                    Mizu_TP(LastPosition)
                end
                SendingGift = false
            end
            if AutoFarmGift then
                if not Mizu_HasGift() then
                    local gift = Mizu_GetNearestGift()
                    if gift then
                        Mizu_TP(gift.PrimaryPart.CFrame)
                        task.wait(0.25)
                        GiftRemote:FireServer(gift.GiftHandle)
                        task.wait(0.15)
                    end
                end
                if Mizu_HasGift() then
                    local tree = Mizu_GetNearestTree()
                    if tree then
                        if tree:IsA("BasePart") then Mizu_TP(tree.CFrame)
                        elseif tree:IsA("Model") and tree.PrimaryPart then Mizu_TP(tree.PrimaryPart.CFrame) end
                        task.wait(0.15)
                    end
                end
            end
        end)
    end
end)

MasTab:CreateSection({ Title = "Christmas Farm", Text = "Auto farm gifts" })
MasTab:CreateToggle({ Name = "Auto Farm (Collect + Send)", CurrentValue = false, Callback = function(v) AutoFarmGift = v end })
MasTab:CreateSection({ Title = "Feature Xmas", Text = "Additional Christmas features" })
MasTab:CreateToggle({ Name = "Auto Send Gift (Not Legit)", CurrentValue = false, Callback = function(v) AutoSendGift = v end })

LocalPlayer.CharacterAdded:Connect(function() task.wait(3) end)

-- ============================================
-- INFORMATION TAB (REBRANDED)
-- ============================================

InfoTab:CreateDivider()
InfoTab:CreateParagraph({ Title = "Mizukage Information", Text = "Script Information" })
InfoTab:CreateDivider()

InfoTab:CreateParagraph({ Title = "Main Owner", Text = "@MizukageOfficial" })
InfoTab:CreateParagraph({ Title = "Team", Text = "TeamMizu🔰" })
InfoTab:CreateParagraph({ Title = "Version", Text = "v14.0" })

InfoTab:CreateDivider()

InfoTab:CreateButton({ Name = "Copy Discord Link", Callback = function() setclipboard("https://discord.gg/Mizukage-Official") end })

-- ============================================
-- NOTIFICATION
-- ============================================

Luna:Notification({
    Title = "Mizukage System",
    Content = "Violence District script loaded. Ready, Master.",
    Icon = "verified",
    ImageSource = "Material"
})