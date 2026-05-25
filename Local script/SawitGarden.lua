-- Mizukage Official | TeamMizu🔰 - All rights reserved
-- Game: Sawit Garden
-- Script rebuilt by MIZU-OS v14.0

-- LOAD LUNA (WAJIB)
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- BUAT WINDOW UTAMA
local Window = Luna:CreateWindow({
    Name = "Mizukage Official",
    Subtitle = "Sawit Garden - TeamMizu🔰",
    LogoID = "104266190557772",
    LoadingEnabled = true,
    LoadingTitle = "Mizukage System",
    LoadingSubtitle = "by @MizukageOfficial",
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "MizukageHub/SawitGarden"
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
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local ConfigFile = "MizuAutoSawit_tools.json"

-- ============================================
-- GLOBAL STATE
-- ============================================
local State = {
    isFarming = false,
    moveMode = "TP",           -- "TP" or "Jalan"
    lastActionTime = tick(),
    isStuck = false,
    savedTools = {},
    espEnabled = false,
    espObjects = {}
}

-- Character references
local Character = nil
local HumanoidRootPart = nil
local Humanoid = nil

-- ============================================
-- CHARACTER SETUP
-- ============================================
local function UpdateCharacterReferences(char)
    Character = char
    if Character then
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        Humanoid = Character:WaitForChild("Humanoid")
    end
end

local function GetCharacter()
    local char = LocalPlayer.Character
    if char then
        UpdateCharacterReferences(char)
    end
    return Character
end

GetCharacter()

LocalPlayer.CharacterAdded:Connect(function(char)
    UpdateCharacterReferences(char)
end)

-- ============================================
-- HELPER FUNCTIONS
-- ============================================
local function GetNearestPrompt(actionText)
    if not HumanoidRootPart then return nil end
    
    local nearestPrompt = nil
    local nearestDist = math.huge
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.ActionText == actionText and obj.Enabled then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") then
                local dist = (HumanoidRootPart.Position - parent.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestPrompt = obj
                end
            end
        end
    end
    
    return nearestPrompt
end

local function GetAllPrompts(actionText)
    local prompts = {}
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.ActionText == actionText and obj.Enabled then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") then
                table.insert(prompts, {
                    prompt = obj,
                    dist = (HumanoidRootPart.Position - parent.Position).Magnitude
                })
            end
        end
    end
    
    table.sort(prompts, function(a, b) return a.dist < b.dist end)
    return prompts
end

-- ============================================
-- MOVEMENT FUNCTIONS
-- ============================================
local function MoveToPosition(targetPart)
    if not targetPart or not HumanoidRootPart then return end
    
    State.lastActionTime = tick()
    
    if State.moveMode == "TP" then
        HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.15)
    else
        local targetPos = targetPart.Position
        Humanoid:MoveTo(targetPos)
        
        local timeout = tick() + 20
        local lastPos = HumanoidRootPart.Position
        local stuckCount = 0
        
        repeat
            task.wait(0.2)
            
            local currentPos = HumanoidRootPart.Position
            if (currentPos - lastPos).Magnitude < 0.5 then
                stuckCount = stuckCount + 1
            else
                stuckCount = 0
            end
            
            if stuckCount >= 5 then
                Humanoid.Jump = true
                task.wait(0.15)
                Humanoid:MoveTo(targetPos)
            end
            
            lastPos = currentPos
            
        until (HumanoidRootPart.Position - targetPos).Magnitude <= 5 or tick() > timeout
        
        Humanoid:MoveTo(targetPos)
        task.wait(0.5)
    end
end

-- ============================================
-- TOOLS MANAGEMENT
-- ============================================
local function GetAvailableTools()
    local tools = {}
    local seen = {}
    
    local function scanContainer(container)
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") or item:IsA("HopperBin") then
                local name = item.Name
                local lowerName = string.lower(name)
                
                if not string.match(lowerName, "%d+%s*kg") and not seen[name] then
                    seen[name] = true
                    table.insert(tools, name)
                end
            end
        end
    end
    
    scanContainer(LocalPlayer.Backpack)
    
    if Character then
        scanContainer(Character)
    end
    
    table.sort(tools)
    return tools
end

local function SaveToolsConfig()
    local success, err = pcall(function()
        writefile(ConfigFile, HttpService:JSONEncode(State.savedTools))
    end)
    if not success then
        warn("[MizuSawit] Failed to save config: " .. tostring(err))
    end
end

local function LoadToolsConfig()
    local success, err = pcall(function()
        if isfile(ConfigFile) then
            local data = HttpService:JSONDecode(readfile(ConfigFile))
            if type(data) == "table" then
                State.savedTools = data
            end
        end
    end)
    if not success then
        warn("[MizuSawit] Failed to load config: " .. tostring(err))
    end
end

LoadToolsConfig()

local function EquipSavedTools()
    if #State.savedTools == 0 then return end
    
    for _, toolName in ipairs(State.savedTools) do
        local tool = LocalPlayer.Backpack:FindFirstChild(toolName)
        if tool and (tool:IsA("Tool") or tool:IsA("HopperBin")) then
            Humanoid:EquipTool(tool)
            task.wait(0.15)
        end
    end
end

-- ============================================
-- TOOLS SELECTION UI (FLOATING)
-- ============================================
local function ShowToolsSelectionUI()
    local availableTools = GetAvailableTools()
    
    if #availableTools == 0 then
        Luna:Notification({ Title = "Inventory", Content = "Tidak ada tool yang bisa disimpan!", Icon = "warning", ImageSource = "Material" })
        return
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MizuSaveTools"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")
    
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.45
    background.BorderSizePixel = 0
    background.Parent = screenGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Pilih Tools untuk Disimpan"
    titleLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
    titleLabel.TextSize = 15
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -20, 0, 20)
    infoLabel.Position = UDim2.new(0, 10, 0, 38)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "Item ber-kg sudah difilter otomatis"
    infoLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
    infoLabel.TextSize = 11
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.Parent = mainFrame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 0, 240)
    scrollFrame.Position = UDim2.new(0, 10, 0, 62)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 220, 80)
    scrollFrame.Parent = mainFrame
    Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 6)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = scrollFrame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 6)
    padding.PaddingLeft = UDim.new(0, 6)
    padding.PaddingRight = UDim.new(0, 6)
    padding.Parent = scrollFrame
    
    local selectedTools = {}
    for _, tool in ipairs(State.savedTools) do
        selectedTools[tool] = true
    end
    
    local function UpdateButtonStyle(button, toolName)
        if selectedTools[toolName] then
            button.BackgroundColor3 = Color3.fromRGB(40, 90, 40)
            button.TextColor3 = Color3.fromRGB(120, 255, 120)
        else
            button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            button.TextColor3 = Color3.fromRGB(200, 200, 220)
        end
    end
    
    local toolButtons = {}
    for index, toolName in ipairs(availableTools) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 34)
        button.LayoutOrder = index
        button.BorderSizePixel = 0
        button.TextSize = 13
        button.Font = Enum.Font.Gotham
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.Parent = scrollFrame
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 5)
        
        local btnPadding = Instance.new("UIPadding", button)
        btnPadding.PaddingLeft = UDim.new(0, 10)
        
        button.Text = (selectedTools[toolName] and "✅  " or "⬜  ") .. toolName
        UpdateButtonStyle(button, toolName)
        
        button.MouseButton1Click:Connect(function()
            selectedTools[toolName] = not selectedTools[toolName]
            button.Text = (selectedTools[toolName] and "✅  " or "⬜  ") .. toolName
            UpdateButtonStyle(button, toolName)
        end)
        
        table.insert(toolButtons, {btn = button, name = toolName})
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #availableTools * 38 + 12)
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.48, 0, 0, 36)
    saveBtn.Position = UDim2.new(0.01, 0, 0, 314)
    saveBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 30)
    saveBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
    saveBtn.Text = "Simpan"
    saveBtn.TextSize = 14
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.BorderSizePixel = 0
    saveBtn.Parent = mainFrame
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8)
    
    saveBtn.MouseButton1Click:Connect(function()
        local newTools = {}
        for _, item in ipairs(toolButtons) do
            if selectedTools[item.name] then
                table.insert(newTools, item.name)
            end
        end
        
        State.savedTools = newTools
        SaveToolsConfig()
        
        Luna:Notification({ Title = "Tersimpan", Content = #State.savedTools > 0 and #State.savedTools .. " tool disimpan!" or "Tools dikosongkan.", Icon = "check", ImageSource = "Material" })
        screenGui:Destroy()
    end)
    
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0.48, 0, 0, 36)
    cancelBtn.Position = UDim2.new(0.51, 0, 0, 314)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
    cancelBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    cancelBtn.Text = "Batal"
    cancelBtn.TextSize = 14
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.BorderSizePixel = 0
    cancelBtn.Parent = mainFrame
    Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 8)
    
    cancelBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    background.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            screenGui:Destroy()
        end
    end)
end

-- ============================================
-- SELL SAWIT
-- ============================================
local function SellSawit()
    local sellPrompt = GetNearestPrompt("Jual Sawit")
    
    if not sellPrompt or not sellPrompt.Parent or not sellPrompt.Parent:IsA("BasePart") then
        Luna:Notification({ Title = "Jual", Content = "Tidak ada tempat jual!", Icon = "error", ImageSource = "Material" })
        return
    end
    
    Luna:Notification({ Title = "Jual", Content = "Menuju kios jual...", Icon = "info", ImageSource = "Material" })
    MoveToPosition(sellPrompt.Parent)
    task.wait(0.2)
    
    local finalPrompt = GetNearestPrompt("Jual Sawit")
    if finalPrompt then
        fireproximityprompt(finalPrompt)
        Luna:Notification({ Title = "Jual", Content = "Sawit dijual!", Icon = "check", ImageSource = "Material" })
    else
        Luna:Notification({ Title = "Jual", Content = "Prompt jual tidak ditemukan!", Icon = "error", ImageSource = "Material" })
    end
end

-- ============================================
-- ESP FUNCTIONS
-- ============================================
local ESPColors = {
    Nyawit = {
        fill = Color3.fromRGB(50, 200, 80),
        outline = Color3.fromRGB(0, 255, 60)
    },
    ["Jual Sawit"] = {
        fill = Color3.fromRGB(220, 170, 20),
        outline = Color3.fromRGB(255, 215, 0)
    }
}

local function ClearESP()
    for _, obj in ipairs(State.espObjects) do
        if obj then
            pcall(function() obj:Destroy() end)
        end
    end
    State.espObjects = {}
end

local function UpdateESP()
    ClearESP()
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and ESPColors[obj.ActionText] then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") then
                local model = parent:FindFirstAncestorOfClass("Model")
                if model and not model:FindFirstChildOfClass("SelectionBox") then
                    local colors = ESPColors[obj.ActionText]
                    local box = Instance.new("SelectionBox")
                    box.Adornee = model
                    box.Color3 = colors.outline
                    box.LineThickness = 0.06
                    box.SurfaceTransparency = 0.6
                    box.SurfaceColor3 = colors.fill
                    box.Parent = Workspace
                    table.insert(State.espObjects, box)
                end
            end
        end
    end
end

-- ============================================
-- COLLECT LOOP
-- ============================================
local function CollectSawit()
    if not HumanoidRootPart then return end
    
    local nyawitPrompt = GetNearestPrompt("Nyawit")
    
    if not nyawitPrompt or not nyawitPrompt.Parent then
        if tick() - State.lastActionTime >= 30 then
            Luna:Notification({ Title = "Auto-Reset", Content = "Tidak ada pohon 30 dtk, mencari ulang...", Icon = "warning", ImageSource = "Material" })
            State.lastActionTime = tick()
        end
        task.wait(1)
        return
    end
    
    MoveToPosition(nyawitPrompt.Parent)
    task.wait(0.1)
    
    EquipSavedTools()
    
    if nyawitPrompt.Enabled then
        State.lastActionTime = tick()
        fireproximityprompt(nyawitPrompt)
        Luna:Notification({ Title = "Sawit", Content = "Mulai nyawit...", Icon = "info", ImageSource = "Material" })
        
        local startTime = tick()
        while tick() - startTime < 22 do
            task.wait(1)
            if State.isFarming then
                State.lastActionTime = tick()
            end
        end
        
        local collectPrompts = GetAllPrompts("Ambil")
        for _, item in ipairs(collectPrompts) do
            if item.prompt and item.prompt.Enabled then
                fireproximityprompt(item.prompt)
                task.wait(0.05)
            end
        end
    end
end

-- ============================================
-- ANTI AFK
-- ============================================
task.spawn(function()
    while true do
        task.wait(240)
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end
end)

-- ============================================
-- WATCHDOG
-- ============================================
task.spawn(function()
    local wasStuck = false
    
    while true do
        task.wait(1)
        
        if State.isFarming then
            local idleTime = tick() - State.lastActionTime
            if idleTime >= 30 and not wasStuck then
                wasStuck = true
                Luna:Notification({ Title = "Watchdog", Content = "Diam 30 detik! Restart nyawit...", Icon = "warning", ImageSource = "Material" })
                State.lastActionTime = tick()
                wasStuck = false
            end
        else
            State.lastActionTime = tick()
        end
    end
end)

-- ============================================
-- ESP UPDATE LOOP
-- ============================================
task.spawn(function()
    while true do
        task.wait(3)
        if State.espEnabled then
            pcall(UpdateESP)
        end
    end
end)

-- ============================================
-- MAIN FARM LOOP
-- ============================================
task.spawn(function()
    while true do
        task.wait(0.3)
        
        if not State.isFarming then
            task.wait(1)
        else
            pcall(CollectSawit)
        end
    end
end)

-- ============================================
-- KEYBOARD SHORTCUTS
-- ============================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local key = input.KeyCode
    
    if key == Enum.KeyCode.F5 then
        State.isFarming = not State.isFarming
        Luna:Notification({ Title = "Shortcut", Content = "Auto Sawit: " .. (State.isFarming and "ON" or "OFF"), Icon = State.isFarming and "check" or "warning", ImageSource = "Material" })
    
    elseif key == Enum.KeyCode.F6 then
        task.spawn(SellSawit)
        Luna:Notification({ Title = "Shortcut", Content = "Jual Sawit...", Icon = "info", ImageSource = "Material" })
    
    elseif key == Enum.KeyCode.F7 then
        State.espEnabled = not State.espEnabled
        if State.espEnabled then
            pcall(UpdateESP)
            Luna:Notification({ Title = "Shortcut", Content = "ESP: ON", Icon = "check", ImageSource = "Material" })
        else
            ClearESP()
            Luna:Notification({ Title = "Shortcut", Content = "ESP: OFF", Icon = "warning", ImageSource = "Material" })
        end
    
    elseif key == Enum.KeyCode.F8 then
        State.moveMode = (State.moveMode == "TP" and "Jalan" or "TP")
        Luna:Notification({ Title = "Shortcut", Content = "Mode: " .. State.moveMode, Icon = "info", ImageSource = "Material" })
    end
end)

-- ============================================
-- CREATE TABS (LUNA)
-- ============================================

local MainTab = Window:CreateTab({ Name = "Auto Sawit", Icon = "grass", ImageSource = "Material", ShowTitle = true })
local InfoTab = Window:CreateTab({ Name = "Info", Icon = "info", ImageSource = "Material", ShowTitle = true })

-- Main Tab Content
MainTab:CreateParagraph({ Title = "KONTROL", Text = "Pengaturan auto farm" })

MainTab:CreateToggle({
    Name = "Auto Sawit",
    CurrentValue = false,
    Callback = function(state)
        State.isFarming = state
        if state then State.lastActionTime = tick() end
        Luna:Notification({ Title = "Auto Sawit", Content = state and "Farm dimulai!" or "Farm dihentikan.", Icon = state and "check" or "warning", ImageSource = "Material" })
    end
})

MainTab:CreateDropdown({
    Name = "Mode",
    Options = {"TP", "Jalan"},
    CurrentOption = {"TP"},
    Callback = function(mode)
        State.moveMode = mode[1]
        Luna:Notification({ Title = "Mode", Content = "Mode diubah ke: " .. State.moveMode, Icon = "info", ImageSource = "Material" })
    end
})

MainTab:CreateToggle({
    Name = "ESP Pohon & Kios",
    CurrentValue = false,
    Callback = function(state)
        State.espEnabled = state
        if state then
            pcall(UpdateESP)
            Luna:Notification({ Title = "ESP", Content = "ESP aktif!", Icon = "check", ImageSource = "Material" })
        else
            ClearESP()
            Luna:Notification({ Title = "ESP", Content = "ESP dimatikan.", Icon = "warning", ImageSource = "Material" })
        end
    end
})

MainTab:CreateDivider()
MainTab:CreateParagraph({ Title = "AKSI MANUAL", Text = "Tombol aksi manual" })

MainTab:CreateButton({
    Name = "Jual Sawit Sekarang",
    Callback = function() task.spawn(SellSawit) end
})

MainTab:CreateDivider()
MainTab:CreateParagraph({ Title = "TOOLS", Text = "Manajemen tools" })

MainTab:CreateButton({
    Name = "Save My Tools",
    Callback = function() ShowToolsSelectionUI() end
})

MainTab:CreateButton({
    Name = "Lihat Saved Tools",
    Callback = function()
        if #State.savedTools == 0 then
            Luna:Notification({ Title = "Saved Tools", Content = "Belum ada tool tersimpan.", Icon = "info", ImageSource = "Material" })
        else
            Luna:Notification({ Title = "Saved Tools", Content = table.concat(State.savedTools, ", "), Icon = "info", ImageSource = "Material" })
        end
    end
})

MainTab:CreateDivider()
MainTab:CreateParagraph({ Title = "SHORTCUT KEYBOARD", Text = "Tombol pintas" })
MainTab:CreateParagraph({ Title = "F5", Text = "Toggle Auto Sawit" })
MainTab:CreateParagraph({ Title = "F6", Text = "Jual Sawit Sekarang" })
MainTab:CreateParagraph({ Title = "F7", Text = "Toggle ESP" })
MainTab:CreateParagraph({ Title = "F8", Text = "Select Mode Sawit" })

-- Info Tab Content
InfoTab:CreateParagraph({ Title = "SAVE TOOLS", Text = "Informasi fitur save tools" })
InfoTab:CreateParagraph({ Title = "📌", Text = "Klik 'Save My Tools'" })
InfoTab:CreateParagraph({ Title = "📌", Text = "Centang tool yang mau auto-dipegang" })
InfoTab:CreateParagraph({ Title = "📌", Text = "Tersimpan ke file config otomatis" })
InfoTab:CreateParagraph({ Title = "📌", Text = "Auto-equip tiap siklus farm dimulai" })

InfoTab:CreateDivider()
InfoTab:CreateParagraph({ Title = "SAWIT GARDEN", Text = "Mizukage Official - TeamMizu🔰" })

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
Luna:Notification({
    Title = "Mizukage System",
    Content = "Sawit Garden loaded. Ready, Master.",
    Icon = "verified",
    ImageSource = "Material"
})