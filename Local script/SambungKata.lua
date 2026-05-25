-- Mizukage Official | TeamMizu🔰 - All rights reserved
-- Game: Sambung Kata (Word Chain Game)
-- Script rebuilt by MIZU-OS v14.0

-- LOAD LUNA (WAJIB)
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- BUAT WINDOW UTAMA
local Window = Luna:CreateWindow({
    Name = "Mizukage Official",
    Subtitle = "Sambung Kata - TeamMizu🔰",
    LogoID = "104266190557772",
    LoadingEnabled = true,
    LoadingTitle = "Mizukage System",
    LoadingSubtitle = "by @MizukageOfficial",
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "MizukageHub/SambungKata"
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================
-- CONFIGURATION
-- ============================================
local Config = {
    keyDelay = 0.06,
    submitDelay = 0.1,
    autoAnswerDelay = 0.8,
    blacklistFile = "mizu_blacklist.txt",
    manualDictFile = "mizu_kamus_manual.txt"
}

-- ============================================
-- GLOBAL STATE
-- ============================================
local State = {
    wordsByFirstLetter = {},
    allWords = {},
    usedWords = {},
    blacklistedWords = {},
    manualWords = {},
    currentPrefix = "",
    isMyTurn = false,
    isSubmitting = false,
    autoAnswerEnabled = false,
    showAnswerPanel = false,
    antiAFKEnabled = false,
    showNotification = true,
    humanTypingEnabled = false,
    filterMode = "RANDOM",
    mistakeCount = 0,
    turnStatus = false
}

local humanTypingCounter = 0
local humanTypingThreshold = math.random(2, 5)
local AnswerPanel = nil
local AnswerPanelConnection = nil
local AntiAFKTask = nil
local AutoAnswerTask = nil

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function TableLength(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

local function IsValidWord(word)
    return #word >= 2 and #word <= 15
end

-- ============================================
-- REMOTES
-- ============================================
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local SubmitWordRemote = nil
local TurnCameraRemote = nil
local MatchUIRemote = nil
local PlayerHitRemote = nil
local PlayerCorrectRemote = nil
local EndTurnRemote = nil

if Remotes then
    SubmitWordRemote = Remotes:FindFirstChild("SubmitWord")
    TurnCameraRemote = Remotes:FindFirstChild("TurnCamera")
    MatchUIRemote = Remotes:FindFirstChild("MatchUI")
    PlayerHitRemote = Remotes:FindFirstChild("PlayerHit")
    PlayerCorrectRemote = Remotes:FindFirstChild("PlayerCorrect")
    EndTurnRemote = Remotes:FindFirstChild("EndTurn")
end

-- ============================================
-- UI HELPER FUNCTIONS
-- ============================================
local function FindMatchUI()
    return PlayerGui:FindFirstChild("MatchUI")
end

local function FindBottomUI()
    local matchUI = FindMatchUI()
    if not matchUI then return nil end
    return matchUI:FindFirstChild("BottomUI")
end

local function FindKeyboard()
    local bottomUI = FindBottomUI()
    if not bottomUI then return nil end
    return bottomUI:FindFirstChild("Keyboard")
end

local function FindTextBox()
    local bottomUI = FindBottomUI()
    if not bottomUI then return nil end
    return bottomUI:FindFirstChildWhichIsA("TextBox", true)
end

local function IsInputActive()
    if LocalPlayer:GetAttribute("IsTurn") == true then return true end
    if State.turnStatus then return true end
    
    local matchUI = FindMatchUI()
    if not matchUI then return false end
    
    local bottomUI = FindBottomUI()
    if not bottomUI then return false end
    
    local keyboard = FindKeyboard()
    if keyboard and keyboard.Visible then return true end
    
    local textBox = FindTextBox()
    if textBox and textBox.Visible then return true end
    
    return false
end

local function GetCurrentPrefix()
    local matchUI = FindMatchUI()
    if not matchUI then return State.currentPrefix end
    
    local bottomUI = FindBottomUI()
    if not bottomUI then return State.currentPrefix end
    
    local topUI = bottomUI:FindFirstChild("TopUI")
    if not topUI then return State.currentPrefix end
    
    local wordServerFrame = topUI:FindFirstChild("WordServerFrame")
    if not wordServerFrame then return State.currentPrefix end
    
    local wordServer = wordServerFrame:FindFirstChild("WordServer")
    if not wordServer then return State.currentPrefix end
    
    local text = wordServer.Text or ""
    if #text == 0 then return State.currentPrefix end
    
    local cleanText = string.gsub(text, "%s+", "")
    local length = #cleanText
    
    if length >= 5 then
        return string.lower(string.sub(cleanText, -5))
    elseif length >= 4 then
        return string.lower(string.sub(cleanText, -4))
    elseif length >= 3 then
        return string.lower(string.sub(cleanText, -3))
    elseif length >= 2 then
        return string.lower(string.sub(cleanText, -2))
    elseif length >= 1 then
        return string.lower(string.sub(cleanText, -1))
    end
    
    return State.currentPrefix
end

-- ============================================
-- TELEPORT FUNCTIONS
-- ============================================
local function TeleportToTableWithPlayers()
    local tables = Workspace:FindFirstChild("Tables")
    if not tables then
        Luna:Notification({ Title = "Error", Content = "Folder Tables tidak ditemukan!", Icon = "error", ImageSource = "Material" })
        return
    end
    
    local availableTables = {}
    
    for _, tableModel in pairs(tables:GetChildren()) do
        if tableModel:IsA("Model") and string.find(tableModel.Name, "Table") then
            local seats = tableModel:FindFirstChild("Seats")
            if seats then
                local playerCount = 0
                for _, seat in pairs(seats:GetChildren()) do
                    if seat:IsA("Seat") and seat.Occupant then
                        playerCount = playerCount + 1
                    end
                end
                
                if playerCount > 0 then
                    local tablePart = tableModel:FindFirstChild("TablePart")
                    if tablePart then
                        table.insert(availableTables, {
                            model = tableModel,
                            part = tablePart,
                            position = tablePart.Position,
                            playerCount = playerCount,
                            name = tableModel.Name
                        })
                    end
                end
            end
        end
    end
    
    if #availableTables == 0 then
        Luna:Notification({ Title = "Info", Content = "Tidak ada meja dengan pemain!", Icon = "info", ImageSource = "Material" })
        return
    end
    
    table.sort(availableTables, function(a, b) return a.playerCount > b.playerCount end)
    
    local targetTable = availableTables[1]
    local character = LocalPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(targetTable.position + Vector3.new(0, 3, 0))
        Luna:Notification({ Title = "Teleport", Content = "Ke " .. targetTable.name .. " (" .. targetTable.playerCount .. " pemain)", Icon = "check", ImageSource = "Material" })
    else
        Luna:Notification({ Title = "Error", Content = "Character tidak ditemukan!", Icon = "error", ImageSource = "Material" })
    end
end

local function TeleportToRewardParkour()
    local claimPart = Workspace:FindFirstChild("ClaimBambuPart")
    if not claimPart then
        Luna:Notification({ Title = "Error", Content = "ClaimBambuPart tidak ditemukan!", Icon = "error", ImageSource = "Material" })
        return
    end
    
    local character = LocalPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(claimPart.Position + Vector3.new(0, 3, 0))
        Luna:Notification({ Title = "Teleport", Content = "Ke Reward Parkour", Icon = "check", ImageSource = "Material" })
    else
        Luna:Notification({ Title = "Error", Content = "Character tidak ditemukan!", Icon = "error", ImageSource = "Material" })
    end
end

-- ============================================
-- ANTI AFK
-- ============================================
local function StartAntiAFK()
    if AntiAFKTask then task.cancel(AntiAFKTask) end
    
    AntiAFKTask = task.spawn(function()
        while State.antiAFKEnabled do
            pcall(function()
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):ClickButton2(Vector2.new())
            end)
            task.wait(60)
            
            local character = LocalPlayer.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if humanoidRootPart then
                humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(1, 0, 0)
                task.wait(0.1)
                humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position)
            end
        end
    end)
end

local function StopAntiAFK()
    if AntiAFKTask then task.cancel(AntiAFKTask); AntiAFKTask = nil end
end

-- ============================================
-- KEYBOARD TYPING FUNCTIONS
-- ============================================
local function SendKey(key)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait(Config.keyDelay)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

local function SendBackspace()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Backspace, false, game)
    task.wait(0.04)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Backspace, false, game)
end

local function ClearInput()
    for _ = 1, 20 do
        SendBackspace()
        task.wait(0.02)
    end
end

local function TypeWord(word, prefix)
    local wordLength = #word
    local prefixLength = #prefix
    local isHumanTyping = State.humanTypingEnabled
    
    if isHumanTyping then
        humanTypingCounter = humanTypingCounter + 1
        local shouldMakeMistake = false
        local mistakePosition = -1
        
        if humanTypingCounter >= humanTypingThreshold then
            if wordLength - prefixLength + 1 >= 2 then
                shouldMakeMistake = true
                mistakePosition = math.random(prefixLength, wordLength)
            end
            humanTypingCounter = 0
            humanTypingThreshold = math.random(2, 5)
        end
        
        for i = prefixLength, wordLength do
            local char = string.sub(word, i, i)
            local keyCode = Enum.KeyCode[string.upper(char)]
            
            if shouldMakeMistake and i == mistakePosition then
                if keyCode then
                    SendKey(keyCode)
                    task.wait(math.random(10, 15) * 0.01)
                end
                
                local randomChar = string.char(math.random(97, 122))
                local randomKey = Enum.KeyCode[string.upper(randomChar)]
                
                if randomKey then
                    task.wait(math.random(5, 25) * 0.01)
                    SendKey(randomKey)
                    task.wait(math.random(10, 15) * 0.01)
                    SendBackspace()
                    task.wait(0.6)
                end
            else
                if keyCode then
                    SendKey(keyCode)
                    if i < wordLength then
                        task.wait(math.random(10, 15) * 0.01)
                    end
                end
            end
        end
    else
        for i = prefixLength, wordLength do
            local char = string.sub(word, i, i)
            local keyCode = Enum.KeyCode[string.upper(char)]
            if keyCode then
                SendKey(keyCode)
                if i < wordLength then
                    task.wait(Config.keyDelay)
                end
            end
        end
        
        task.wait(Config.submitDelay)
        SendKey(Enum.KeyCode.Return)
    end
end

-- ============================================
-- NOTIFICATION
-- ============================================
local function ShowSubmitNotification(word, status)
    if not State.showNotification then return end
    
    if status == "success" then
        Luna:Notification({ Title = "Submit", Content = "Kata: " .. string.upper(word), Icon = "check", ImageSource = "Material" })
    elseif status == "fail" then
        Luna:Notification({ Title = "Submit", Content = "Gagal submit: " .. string.upper(word), Icon = "error", ImageSource = "Material" })
    end
end

-- ============================================
-- BLACKLIST FUNCTIONS
-- ============================================
local function LoadBlacklistFromFile()
    local success, content = pcall(function() return readfile(Config.blacklistFile) end)
    
    if success and content and #content > 0 then
        for line in string.gmatch(content, "[^\r\n]+") do
            local word = string.match(line, "^%s*(.-)%s*$")
            if word and #word > 0 then
                State.blacklistedWords[string.lower(word)] = true
            end
        end
    end
    
    return TableLength(State.blacklistedWords)
end

local function SaveBlacklistToFile()
    local words = {}
    for word in pairs(State.blacklistedWords) do table.insert(words, word) end
    table.sort(words)
    
    return pcall(function() writefile(Config.blacklistFile, table.concat(words, "\n")) end)
end

local function AddToBlacklist(word)
    word = string.lower(word)
    State.blacklistedWords[word] = true
    SaveBlacklistToFile()
    
    Luna:Notification({ Title = "Auto Blacklist", Content = string.upper(word) .. " diblacklist!", Icon = "warning", ImageSource = "Material" })
    ClearInput()
end

-- ============================================
-- WORD DATABASE FUNCTIONS
-- ============================================
local function InitializeWordIndex()
    for i = 97, 122 do
        State.wordsByFirstLetter[string.char(i)] = {}
    end
end

local function GetWordPriority(word)
    local suffixes = {
        ["if"] = 100, ["ng"] = 95, ["um"] = 92, ["ea"] = 91,
        ["nya"] = 90, ["q"] = 85, ["x"] = 85, ["ik"] = 70,
        ["an"] = 60, ["er"] = 50, ["us"] = 40, ["ud"] = 40
    }
    
    for suffix, priority in pairs(suffixes) do
        if string.sub(word, -#suffix) == suffix then
            return priority
        end
    end
    
    return 0
end

local function SortWordsByPriority(words)
    table.sort(words, function(a, b)
        local priorityA = GetWordPriority(a)
        local priorityB = GetWordPriority(b)
        if priorityA ~= priorityB then return priorityA > priorityB end
        return #a < #b
    end)
    return words
end

local function FilterWordsByMode(words, prefix, limit)
    limit = limit or 20
    local filtered = {}
    
    if State.filterMode == "PRIORITY" then
        filtered = words
    elseif State.filterMode == "SHORTEST" then
        table.sort(words, function(a, b) return #a < #b end)
        filtered = words
    elseif State.filterMode == "LONGEST" then
        table.sort(words, function(a, b) return #a > #b end)
        filtered = words
    elseif State.filterMode == "RANDOM" then
        for i = #words, 2, -1 do
            local j = math.random(i)
            words[i], words[j] = words[j], words[i]
        end
        filtered = words
    else
        local suffixMap = {
            ["IF"] = "if", ["NG"] = "ng", ["NYA"] = "nya",
            ["UM"] = "um", ["EA"] = "ea", ["SM"] = "sm",
            ["KL"] = "kl", ["JM"] = "jm", ["GC"] = "gc",
            ["GY"] = "gy", ["CY"] = "cy", ["LS"] = "ls",
            ["KS"] = "ks", ["MS"] = "ms"
        }
        
        local targetSuffix = suffixMap[State.filterMode]
        if targetSuffix then
            for _, word in ipairs(words) do
                if string.sub(word, -#targetSuffix) == targetSuffix then
                    table.insert(filtered, word)
                end
            end
            table.sort(filtered, function(a, b) return #a < #b end)
        else
            filtered = words
        end
    end
    
    local result = {}
    for i = 1, math.min(#filtered, limit) do
        table.insert(result, filtered[i])
    end
    
    return result
end

local function GetMatchingWords(prefix)
    if not prefix or prefix == "" then return {} end
    
    local firstChar = string.sub(prefix, 1, 1)
    local wordsWithPrefix = State.wordsByFirstLetter[firstChar] or {}
    local matches = {}
    
    for _, word in ipairs(wordsWithPrefix) do
        if string.sub(word, 1, #prefix) == prefix then
            local isUsed = State.usedWords[word]
            local isBlacklisted = State.blacklistedWords[word]
            local isManual = State.manualWords[word]
            
            if not isUsed and not isBlacklisted then
                if isManual then
                    table.insert(matches, 1, word)
                else
                    table.insert(matches, word)
                end
            end
        end
    end
    
    return FilterWordsByMode(matches, prefix, 20)
end

-- ============================================
-- LOAD DATABASE
-- ============================================
local function LoadWordDatabase(urls)
    InitializeWordIndex()
    
    for _, url in ipairs(urls) do
        local success, content = pcall(function() return game:HttpGet(url) end)
        
        if success and content then
            State.allWords = {}
            State.wordsByFirstLetter = {}
            InitializeWordIndex()
            State.usedWords = {}
            State.blacklistedWords = {}
            
            local blacklistCount = LoadBlacklistFromFile()
            if blacklistCount > 0 then
                Luna:Notification({ Title = "Blacklist", Content = blacklistCount .. " kata dimuat dari file!", Icon = "info", ImageSource = "Material" })
            end
            
            for word in string.gmatch(content, "[%a]+") do
                word = string.lower(word)
                if IsValidWord(word) then
                    table.insert(State.allWords, word)
                    
                    local firstChar = string.sub(word, 1, 1)
                    if State.wordsByFirstLetter[firstChar] then
                        table.insert(State.wordsByFirstLetter[firstChar], word)
                    end
                end
            end
            
            for firstChar, words in pairs(State.wordsByFirstLetter) do
                SortWordsByPriority(words)
            end
            
            Luna:Notification({ Title = "Database", Content = #State.allWords .. " kata loaded!", Icon = "check", ImageSource = "Material" })
            return true
        end
    end
    
    return false
end

-- ============================================
-- SUBMIT WORD
-- ============================================
local function SubmitWord(word, prefix, source)
    if not IsInputActive() then
        if source == "auto" then
            Luna:Notification({ Title = "Warning", Content = "Bukan giliran!", Icon = "warning", ImageSource = "Material" })
        end
        return false
    end
    
    if State.isSubmitting then return false end
    
    State.isSubmitting = true
    ClearInput()
    task.wait(0.1)
    
    if not IsInputActive() then
        State.isSubmitting = false
        return false
    end
    
    word = string.lower(word)
    
    TypeWord(word, prefix)
    State.usedWords[word] = true
    ShowSubmitNotification(word, "success")
    
    task.wait(0.2)
    State.isSubmitting = false
    
    return true
end

-- ============================================
-- AUTO ANSWER
-- ============================================
local function StartAutoAnswer()
    if AutoAnswerTask then task.cancel(AutoAnswerTask) end
    
    AutoAnswerTask = task.spawn(function()
        local lastPrefix = ""
        
        while State.autoAnswerEnabled do
            if IsInputActive() then
                local currentPrefix = GetCurrentPrefix()
                
                if currentPrefix ~= "" then
                    if currentPrefix ~= lastPrefix then lastPrefix = currentPrefix end
                    
                    task.wait(Config.autoAnswerDelay)
                    
                    local matches = GetMatchingWords(currentPrefix)
                    local bestMatch = matches[1]
                    
                    if bestMatch then
                        SubmitWord(bestMatch, currentPrefix, "auto")
                        task.wait(Config.autoAnswerDelay)
                    else
                        task.wait(0.8)
                    end
                else
                    task.wait(0.3)
                end
            else
                task.wait(0.3)
            end
        end
    end)
end

local function StopAutoAnswer()
    State.autoAnswerEnabled = false
    if AutoAnswerTask then task.cancel(AutoAnswerTask); AutoAnswerTask = nil end
end

-- ============================================
-- ANSWER PANEL UI (FLOATING)
-- ============================================
local function CreateAnswerPanel()
    if AnswerPanel then pcall(function() AnswerPanel:Destroy() end) end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MizuAnswerPanel"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999998
    screenGui.Parent = PlayerGui
    AnswerPanel = screenGui
    
    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.fromOffset(200, 280)
    mainFrame.Position = UDim2.fromScale(0.02, 0.2)
    mainFrame.BackgroundColor3 = Color3.fromRGB(35, 20, 50)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.Active = true
    mainFrame.ClipsDescendants = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    
    local titleBar = Instance.new("Frame", mainFrame)
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(80, 50, 160)
    titleBar.BackgroundTransparency = 0.1
    titleBar.Active = true
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)
    
    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.Size = UDim2.new(1, -34, 1, 0)
    titleLabel.Position = UDim2.fromOffset(8, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "PILIH JAWABAN"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 11
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Instance.new("TextButton", titleBar)
    closeBtn.Size = UDim2.fromOffset(20, 20)
    closeBtn.Position = UDim2.new(1, -25, 0.5, -10)
    closeBtn.Text = "×"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 80)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.AutoButtonColor = false
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)
    
    closeBtn.MouseButton1Click:Connect(function()
        State.showAnswerPanel = false
        if AnswerPanel then AnswerPanel:Destroy() end
    end)
    
    local infoFrame = Instance.new("Frame", mainFrame)
    infoFrame.Size = UDim2.new(1, -16, 0, 40)
    infoFrame.Position = UDim2.fromOffset(8, 34)
    infoFrame.BackgroundColor3 = Color3.fromRGB(50, 30, 70)
    infoFrame.BackgroundTransparency = 0.2
    Instance.new("UICorner", infoFrame).CornerRadius = UDim.new(0, 8)
    
    local prefixLabel = Instance.new("TextLabel", infoFrame)
    prefixLabel.Size = UDim2.new(1, 0, 0.5, 0)
    prefixLabel.Position = UDim2.fromOffset(0, 3)
    prefixLabel.BackgroundTransparency = 1
    prefixLabel.Text = "Prefix: -"
    prefixLabel.TextColor3 = Color3.fromRGB(230, 220, 255)
    prefixLabel.Font = Enum.Font.GothamBold
    prefixLabel.TextSize = 12
    prefixLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local turnLabel = Instance.new("TextLabel", infoFrame)
    turnLabel.Size = UDim2.new(1, 0, 0.5, 0)
    turnLabel.Position = UDim2.fromOffset(0, 21)
    turnLabel.BackgroundTransparency = 1
    turnLabel.Text = "Giliran: ❌"
    turnLabel.TextColor3 = Color3.fromRGB(200, 180, 255)
    turnLabel.Font = Enum.Font.GothamBold
    turnLabel.TextSize = 11
    turnLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local wordListFrame = Instance.new("Frame", mainFrame)
    wordListFrame.Size = UDim2.new(1, -16, 1, -84)
    wordListFrame.Position = UDim2.fromOffset(8, 80)
    wordListFrame.BackgroundColor3 = Color3.fromRGB(25, 15, 35)
    wordListFrame.BackgroundTransparency = 0.1
    Instance.new("UICorner", wordListFrame).CornerRadius = UDim.new(0, 8)
    
    local scrollFrame = Instance.new("ScrollingFrame", wordListFrame)
    scrollFrame.Name = "WordList"
    scrollFrame.Size = UDim2.new(1, -12, 1, -12)
    scrollFrame.Position = UDim2.fromOffset(6, 6)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(180, 120, 255)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.BorderSizePixel = 0
    
    local listLayout = Instance.new("UIListLayout", scrollFrame)
    listLayout.Padding = UDim.new(0, 4)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local answerWords = {}
    local lastPrefix = ""
    local lastUpdateTime = 0
    
    local function UpdateWordList()
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("TextLabel") then
                if child.Name ~= "Header" then child:Destroy() end
            end
        end
        
        if #answerWords == 0 then
            local emptyLabel = Instance.new("TextLabel", scrollFrame)
            emptyLabel.Size = UDim2.new(1, 0, 0, 40)
            emptyLabel.BackgroundTransparency = 1
            emptyLabel.Text = "Tidak ada kata"
            emptyLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
            emptyLabel.Font = Enum.Font.Gotham
            emptyLabel.TextSize = 12
        else
            for index, word in ipairs(answerWords) do
                local wordButton = Instance.new("TextButton", scrollFrame)
                wordButton.Name = "WordBtn_" .. word
                wordButton.Size = UDim2.new(1, 0, 0, 34)
                wordButton.BackgroundColor3 = Color3.fromRGB(45, 28, 65)
                wordButton.BackgroundTransparency = 0.1
                wordButton.Text = ""
                wordButton.AutoButtonColor = false
                Instance.new("UICorner", wordButton).CornerRadius = UDim.new(0, 6)
                
                local wordLabel = Instance.new("TextLabel", wordButton)
                wordLabel.Size = UDim2.new(0, 140, 1, 0)
                wordLabel.Position = UDim2.fromOffset(8, 0)
                wordLabel.BackgroundTransparency = 1
                wordLabel.Text = string.upper(word)
                wordLabel.TextColor3 = Color3.fromRGB(230, 220, 255)
                wordLabel.Font = Enum.Font.GothamBold
                wordLabel.TextSize = 12
                wordLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local lengthFrame = Instance.new("Frame", wordButton)
                lengthFrame.Size = UDim2.fromOffset(50, 22)
                lengthFrame.Position = UDim2.new(1, -58, 0.5, -11)
                lengthFrame.BackgroundColor3 = Color3.fromRGB(100, 70, 180)
                lengthFrame.BackgroundTransparency = 0.15
                Instance.new("UICorner", lengthFrame).CornerRadius = UDim.new(0, 5)
                
                local lengthLabel = Instance.new("TextLabel", lengthFrame)
                lengthLabel.Size = UDim2.fromScale(1, 1)
                lengthLabel.BackgroundTransparency = 1
                lengthLabel.Text = "+" .. string.sub(word, #lastPrefix + 1)
                lengthLabel.TextColor3 = Color3.new(1, 1, 1)
                lengthLabel.Font = Enum.Font.GothamBold
                lengthLabel.TextSize = 10
                
                wordButton.MouseButton1Click:Connect(function()
                    if not IsInputActive() then
                        Luna:Notification({ Title = "Warning", Content = "Bukan giliran!", Icon = "warning", ImageSource = "Material" })
                        return
                    end
                    
                    if State.isSubmitting then return end
                    
                    SubmitWord(word, lastPrefix, "panel")
                    wordButton:Destroy()
                end)
            end
            task.wait()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
        end
    end
    
    if AnswerPanelConnection then AnswerPanelConnection:Disconnect() end
    
    local wasTurnActive = false
    local currentWords = {}
    
    AnswerPanelConnection = RunService.Heartbeat:Connect(function()
        if not State.showAnswerPanel or not AnswerPanel then return end
        
        local isTurnActive = IsInputActive()
        local currentPrefixValue = GetCurrentPrefix()
        
        prefixLabel.Text = "Prefix: " .. (currentPrefixValue ~= "" and string.upper(currentPrefixValue) or "-")
        turnLabel.Text = "Giliran: " .. (isTurnActive and "AKTIF" or "TIDAK")
        
        if isTurnActive then
            if not wasTurnActive or currentPrefixValue ~= lastPrefix then
                lastPrefix = currentPrefixValue
                answerWords = GetMatchingWords(lastPrefix)
                UpdateWordList()
                wasTurnActive = true
            end
        else
            if wasTurnActive then
                wasTurnActive = false
                answerWords = {}
                UpdateWordList()
            end
        end
    end)
end

local function DestroyAnswerPanel()
    if AnswerPanelConnection then AnswerPanelConnection:Disconnect(); AnswerPanelConnection = nil end
    if AnswerPanel then pcall(function() AnswerPanel:Destroy() end); AnswerPanel = nil end
    State.showAnswerPanel = false
end

-- ============================================
-- EVENT LISTENERS
-- ============================================
local function SetupEventListeners()
    local lastMistakeCount = LocalPlayer:GetAttribute("Mistake") or 0
    
    LocalPlayer:GetAttributeChangedSignal("Mistake"):Connect(function()
        local newMistakeCount = LocalPlayer:GetAttribute("Mistake") or 0
        if newMistakeCount > lastMistakeCount then
            if State.turnStatus then
                local wrongWord = GetCurrentPrefix()
                if wrongWord and #wrongWord > 1 then
                    if not State.usedWords[wrongWord] then
                        ShowSubmitNotification(wrongWord, "fail")
                        AddToBlacklist(wrongWord)
                    end
                end
            end
        end
        lastMistakeCount = newMistakeCount
    end)
    
    LocalPlayer:GetAttributeChangedSignal("IsTurn"):Connect(function()
        State.turnStatus = LocalPlayer:GetAttribute("IsTurn") == true
        if not State.turnStatus then State.currentPrefix = "" end
    end)
    
    State.turnStatus = LocalPlayer:GetAttribute("IsTurn") == true
    
    task.spawn(function()
        local leaderstats = LocalPlayer:WaitForChild("leaderstats", 10)
        if not leaderstats then
            Luna:Notification({ Title = "Warning", Content = "leaderstats tidak ditemukan!", Icon = "warning", ImageSource = "Material" })
            return
        end
        
        local wins = leaderstats:WaitForChild("Wins", 10)
        local losses = leaderstats:WaitForChild("Losses", 10)
        
        if not wins or not losses then
            Luna:Notification({ Title = "Warning", Content = "Wins/Losses stat tidak ditemukan!", Icon = "warning", ImageSource = "Material" })
            return
        end
        
        wins.Changed:Connect(function()
            State.usedWords = {}
            Luna:Notification({ Title = "Match Selesai", Content = "Menang! Kata direset otomatis.", Icon = "check", ImageSource = "Material" })
        end)
        
        losses.Changed:Connect(function()
            State.usedWords = {}
            Luna:Notification({ Title = "Match Selesai", Content = "Kalah! Kata direset otomatis.", Icon = "info", ImageSource = "Material" })
        end)
    end)
end

-- ============================================
-- CREATE TABS (LUNA)
-- ============================================

local MainPage = Window:CreateTab({ Name = "Main", Icon = "rocket", ImageSource = "Material", ShowTitle = true })
local StatsPage = Window:CreateTab({ Name = "Stats", Icon = "analytics", ImageSource = "Material", ShowTitle = true })
local DatabasePage = Window:CreateTab({ Name = "Database", Icon = "database", ImageSource = "Material", ShowTitle = true })

-- Main Page
MainPage:CreateParagraph({ Title = "Filter Kata", Text = "Mode pencarian kata" })

local filterModes = { "RANDOM", "PRIORITY", "IF", "NG", "NYA", "XQ", "UM", "EA", "SM", "KL", "JM", "GC", "GY", "CY", "LS", "KS", "MS", "SHORTEST", "LONGEST" }
MainPage:CreateDropdown({ Name = "Mode Filter", Options = filterModes, CurrentOption = {"RANDOM"}, Callback = function(mode) State.filterMode = mode[1]; Luna:Notification({ Title = "Filter", Content = "Mode: " .. State.filterMode, Icon = "info", ImageSource = "Material" }) end })

MainPage:CreateDivider()
MainPage:CreateParagraph({ Title = "Pengaturan Utama", Text = "Setting auto answer" })

MainPage:CreateToggle({ Name = "Auto Jawab", CurrentValue = false, Callback = function(v) State.autoAnswerEnabled = v; if v then StartAutoAnswer() else StopAutoAnswer() end end })
MainPage:CreateToggle({ Name = "Pilih Jawaban", CurrentValue = false, Callback = function(v) State.showAnswerPanel = v; if v then CreateAnswerPanel() else DestroyAnswerPanel() end end })
MainPage:CreateToggle({ Name = "Anti AFK", CurrentValue = false, Callback = function(v) State.antiAFKEnabled = v; if v then StartAntiAFK() else StopAntiAFK() end end })
MainPage:CreateToggle({ Name = "Notifikasi Submit", CurrentValue = true, Callback = function(v) State.showNotification = v end })
MainPage:CreateToggle({ Name = "Like Human Typing", CurrentValue = false, Callback = function(v) State.humanTypingEnabled = v; Luna:Notification({ Title = "Like Human", Content = v and "Aktif! Kadang salah ketik." or "Nonaktif (normal typing).", Icon = v and "check" or "info", ImageSource = "Material" }) end })

MainPage:CreateDivider()
MainPage:CreateParagraph({ Title = "Pengaturan Delay", Text = "Kecepatan typing" })
MainPage:CreateSlider({ Name = "Delay Antar Huruf", Range = {0.02, 0.3}, Increment = 0.01, CurrentValue = Config.keyDelay, Callback = function(v) Config.keyDelay = v end })
MainPage:CreateSlider({ Name = "Delay Submit", Range = {0.05, 0.5}, Increment = 0.01, CurrentValue = Config.submitDelay, Callback = function(v) Config.submitDelay = v end })
MainPage:CreateSlider({ Name = "Delay Auto Jawab", Range = {0.1, 3}, Increment = 0.1, CurrentValue = Config.autoAnswerDelay, Callback = function(v) Config.autoAnswerDelay = v; if State.autoAnswerEnabled then StartAutoAnswer() end end })

MainPage:CreateDivider()
MainPage:CreateParagraph({ Title = "Teleport", Text = "Teleport ke lokasi" })
MainPage:CreateButton({ Name = "Cari Meja dengan Pemain", Callback = TeleportToTableWithPlayers })
MainPage:CreateButton({ Name = "TP ke Reward Parkour", Callback = TeleportToRewardParkour })

-- Stats Page
StatsPage:CreateParagraph({ Title = "Player Stats", Text = "Informasi pemain" })
StatsPage:CreateParagraph({ Title = "Nama", Text = "Nama: " .. LocalPlayer.Name })
StatsPage:CreateParagraph({ Title = "Display", Text = "Display: " .. LocalPlayer.DisplayName })
StatsPage:CreateParagraph({ Title = "User ID", Text = "User ID: " .. LocalPlayer.UserId })

StatsPage:CreateDivider()
StatsPage:CreateParagraph({ Title = "Keuangan", Text = "Statistik game" })

local moneyLabel = StatsPage:CreateParagraph({ Title = "Money", Text = "Money: Loading..." })
local winsLabel = StatsPage:CreateParagraph({ Title = "Wins", Text = "Wins: Loading..." })
local lossesLabel = StatsPage:CreateParagraph({ Title = "Losses", Text = "Losses: Loading..." })
local winRateLabel = StatsPage:CreateParagraph({ Title = "Win Rate", Text = "Win Rate: Loading..." })

StatsPage:CreateButton({ Name = "Refresh Stats", Callback = function()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local money = leaderstats:FindFirstChild("Money")
        local wins = leaderstats:FindFirstChild("Wins")
        local losses = leaderstats:FindFirstChild("Losses")
        if money then moneyLabel:Set("Money: Rp" .. money.Value) end
        if wins then winsLabel:Set("Wins: " .. wins.Value) end
        if losses then lossesLabel:Set("Losses: " .. losses.Value) end
        if wins and losses then
            local total = wins.Value + losses.Value
            local winRate = total > 0 and math.floor(wins.Value / total * 100) or 0
            winRateLabel:Set("Win Rate: " .. winRate .. "%")
        end
    end
    Luna:Notification({ Title = "Stats", Content = "Diperbarui!", Icon = "check", ImageSource = "Material" })
end })

StatsPage:CreateDivider()
StatsPage:CreateParagraph({ Title = "Performance", Text = "Statistik script" })

local usedWordsLabel = StatsPage:CreateParagraph({ Title = "Kata Terpakai", Text = "Kata Terpakai: 0" })
local blacklistLabel = StatsPage:CreateParagraph({ Title = "Kata Diblacklist", Text = "Kata Diblacklist: 0" })
local totalWordsLabel = StatsPage:CreateParagraph({ Title = "Total Kamus", Text = "Total Kamus: 0" })

StatsPage:CreateButton({ Name = "Reset Kata Terpakai", Callback = function() State.usedWords = {}; Luna:Notification({ Title = "Reset", Content = "Kata terpakai telah direset!", Icon = "check", ImageSource = "Material" }) end })

task.spawn(function()
    while true do
        pcall(function()
            usedWordsLabel:Set("Kata Terpakai: " .. TableLength(State.usedWords))
            blacklistLabel:Set("Kata Diblacklist: " .. TableLength(State.blacklistedWords))
            totalWordsLabel:Set("Total Kamus: " .. #State.allWords)
        end)
        task.wait(5)
    end
end)

-- Database Page
DatabasePage:CreateParagraph({ Title = "Load Kamus", Text = "Muat database kata" })

local dbStatusLabel = DatabasePage:CreateParagraph({ Title = "Status", Text = "Status: Belum dimuat" })

DatabasePage:CreateButton({ Name = "Load Kamus", Callback = function()
    dbStatusLabel:Set("Status: Loading...")
    task.spawn(function()
        local success = LoadWordDatabase({ "https://raw.githubusercontent.com/wasovfree/Wafree/refs/heads/main/list.txt" })
        if success then
            dbStatusLabel:Set("Status: " .. #State.allWords .. " kata")
            totalWordsLabel:Set("Total Kamus: " .. #State.allWords)
        else
            dbStatusLabel:Set("Status: Gagal load")
        end
    end)
end })

DatabasePage:CreateDivider()
DatabasePage:CreateParagraph({ Title = "Manajemen Blacklist", Text = "Kelola kata blacklist" })

DatabasePage:CreateButton({ Name = "Load Blacklist dari File", Callback = function()
    local count = LoadBlacklistFromFile()
    Luna:Notification({ Title = "Blacklist", Content = count .. " kata dimuat dari blacklist.txt", Icon = "info", ImageSource = "Material" })
    blacklistLabel:Set("Kata Diblacklist: " .. TableLength(State.blacklistedWords))
end })

DatabasePage:CreateButton({ Name = "Simpan Blacklist ke File", Callback = function()
    local success = SaveBlacklistToFile()
    if success then
        Luna:Notification({ Title = "Blacklist", Content = TableLength(State.blacklistedWords) .. " kata disimpan!", Icon = "check", ImageSource = "Material" })
    else
        Luna:Notification({ Title = "Error", Content = "Gagal tulis blacklist.txt!", Icon = "error", ImageSource = "Material" })
    end
end })

DatabasePage:CreateButton({ Name = "Reset Blacklist (hapus semua)", Callback = function()
    State.blacklistedWords = {}
    blacklistLabel:Set("Kata Diblacklist: 0")
    SaveBlacklistToFile()
    Luna:Notification({ Title = "Blacklist", Content = "Blacklist direset! File diperbarui.", Icon = "warning", ImageSource = "Material" })
end })

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
SetupEventListeners()

task.spawn(function()
    dbStatusLabel:Set("Status: Auto loading...")
    local success = LoadWordDatabase({ "https://raw.githubusercontent.com/wasovfree/Wafree/refs/heads/main/list.txt" })
    if success then
        dbStatusLabel:Set("Status: " .. #State.allWords .. " kata")
        totalWordsLabel:Set("Total Kamus: " .. #State.allWords)
    else
        dbStatusLabel:Set("Status: Gagal auto-load")
    end
end)

Luna:Notification({
    Title = "Mizukage System",
    Content = "Sambung Kata loaded!",
    Icon = "verified",
    ImageSource = "Material"
})