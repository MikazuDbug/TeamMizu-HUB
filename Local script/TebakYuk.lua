-- Mizukage Official | TeamMizu🔰 - All rights reserved
-- Game: Tebak Yuk (Guess the Word)
-- Script rebuilt by MIZU-OS v14.0

-- LOAD LUNA (WAJIB)
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- BUAT WINDOW UTAMA
local Window = Luna:CreateWindow({
    Name = "Mizukage Official",
    Subtitle = "Tebak Yuk - TeamMizu🔰",
    LogoID = "104266190557772",
    LoadingEnabled = true,
    LoadingTitle = "Mizukage System",
    LoadingSubtitle = "by @MizukageOfficial",
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "MizukageHub/TebakYuk"
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
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================
-- CONFIGURATION
-- ============================================
local Config = {
    autoAnswerDelay = 1.5,
    spamDelay = 0.1,
    keyDelay = 0.05,
    submitDelay = 0.1
}

-- ============================================
-- GLOBAL STATE
-- ============================================
local State = {
    currentClue = "",
    possibleAnswers = {},
    isAutoAnswerEnabled = false,
    isSpamming = false,
    spamAnswer = "",
    showAnswerPanel = false,
    antiAFKEnabled = false,
    humanTypingEnabled = false,
    lastAnswers = {}
}

-- References
local AnswerPanel = nil
local AnswerPanelConnection = nil
local AutoAnswerTask = nil
local SpamTask = nil
local AntiAFKTask = nil

-- ============================================
-- REMOTE EVENTS
-- ============================================
local GameRemotes = ReplicatedStorage:FindFirstChild("GameRemotes")
local SendAnswerRemote = nil
local AskQuestionRemote = nil
local UpdateClueRemote = nil

if GameRemotes then
    SendAnswerRemote = GameRemotes:FindFirstChild("SendAnswer")
    AskQuestionRemote = GameRemotes:FindFirstChild("AskQuestion")
    UpdateClueRemote = GameRemotes:FindFirstChild("UpdateClue")
end

if not SendAnswerRemote then
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        SendAnswerRemote = remotes:FindFirstChild("SubmitWord") or remotes:FindFirstChild("SendAnswer")
        AskQuestionRemote = remotes:FindFirstChild("AskQuestion") or remotes:FindFirstChild("GetClue")
    end
end

-- ============================================
-- WORD DATABASE
-- ============================================
local WordDatabase = {
    words = {},
    byFirstLetter = {}
}

local function LoadWordDatabase()
    for i = 97, 122 do
        WordDatabase.byFirstLetter[string.char(i)] = {}
    end
    
    local commonWords = {
        "apel", "jeruk", "mangga", "pisang", "anggur", "semangka", "pepaya", "kelapa",
        "meja", "kursi", "lemari", "kasur", "bantal", "selimut", "karpet", "lampu",
        "mobil", "motor", "sepeda", "bus", "truk", "kereta", "pesawat", "kapal",
        "anjing", "kucing", "ayam", "bebek", "kambing", "sapi", "kerbau", "kelinci",
        "merah", "biru", "kuning", "hijau", "hitam", "putih", "ungu", "jingga",
        "senin", "selasa", "rabu", "kamis", "jumat", "sabtu", "minggu",
        "januari", "februari", "maret", "april", "mei", "juni", "juli", "agustus",
        "september", "oktober", "november", "desember"
    }
    
    for _, word in ipairs(commonWords) do
        local firstChar = string.sub(word, 1, 1)
        if WordDatabase.byFirstLetter[firstChar] then
            table.insert(WordDatabase.words, word)
            table.insert(WordDatabase.byFirstLetter[firstChar], word)
        end
    end
    
    table.sort(WordDatabase.words, function(a, b) return #a < #b end)
    return true
end

local function GetPossibleAnswers(clue)
    if not clue or clue == "" then return {} end
    
    local clueLower = string.lower(clue)
    local matches = {}
    local cleanClue = string.gsub(clueLower, "[^a-z]", "")
    
    for _, word in ipairs(WordDatabase.words) do
        if string.find(word, cleanClue) or string.find(cleanClue, word) then
            local alreadyUsed = false
            for _, used in ipairs(State.lastAnswers) do
                if used == word then alreadyUsed = true; break end
            end
            if not alreadyUsed then table.insert(matches, word) end
        end
        
        if #cleanClue > 0 then
            local pattern = "^" .. string.gsub(cleanClue, "_", ".") .. "$"
            if string.match(word, pattern) then
                local alreadyUsed = false
                for _, used in ipairs(State.lastAnswers) do
                    if used == word then alreadyUsed = true; break end
                end
                if not alreadyUsed then table.insert(matches, word) end
            end
        end
    end
    
    local uniqueMatches = {}
    for _, word in ipairs(matches) do
        local found = false
        for _, u in ipairs(uniqueMatches) do if u == word then found = true; break end end
        if not found then table.insert(uniqueMatches, word) end
    end
    
    table.sort(uniqueMatches, function(a, b) return #a < #b end)
    return uniqueMatches
end

-- ============================================
-- UI HELPER FUNCTIONS
-- ============================================
local function FindClueLabel()
    local matchUI = PlayerGui:FindFirstChild("MatchUI")
    if matchUI then
        local clueLabel = matchUI:FindFirstChild("ClueLabel", true)
        if clueLabel and clueLabel:IsA("TextLabel") then return clueLabel end
    end
    
    local function searchClue(parent, depth)
        depth = depth or 0
        if depth > 10 then return nil end
        for _, child in pairs(parent:GetChildren()) do
            if child.Name == "ClueLabel" and child:IsA("TextLabel") and child.Text ~= "" then return child end
            local found = searchClue(child, depth + 1)
            if found then return found end
        end
        return nil
    end
    
    return searchClue(PlayerGui)
end

local function GetCurrentClue()
    local clueLabel = FindClueLabel()
    if clueLabel and clueLabel.Visible then return clueLabel.Text or "" end
    return State.currentClue
end

local function IsInputActive()
    local matchUI = PlayerGui:FindFirstChild("MatchUI")
    if not matchUI then return false end
    local answerBox = matchUI:FindFirstChild("AnswerBox", true)
    if answerBox and answerBox:IsA("TextBox") and answerBox.Visible then return true end
    local keyboard = matchUI:FindFirstChild("Keyboard", true)
    if keyboard and keyboard.Visible then return true end
    return false
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
    for _ = 1, 15 do SendBackspace(); task.wait(0.02) end
end

local function TypeAnswer(answer)
    ClearInput()
    task.wait(0.1)
    
    if State.humanTypingEnabled then
        for i = 1, #answer do
            local char = string.sub(answer, i, i)
            local keyCode = Enum.KeyCode[string.upper(char)]
            if keyCode then
                SendKey(keyCode)
                local delay = math.random(5, 25) * 0.01
                task.wait(delay)
            end
        end
        task.wait(Config.submitDelay)
        SendKey(Enum.KeyCode.Return)
    else
        for i = 1, #answer do
            local char = string.sub(answer, i, i)
            local keyCode = Enum.KeyCode[string.upper(char)]
            if keyCode then
                SendKey(keyCode)
                task.wait(Config.keyDelay)
            end
        end
        task.wait(Config.submitDelay)
        SendKey(Enum.KeyCode.Return)
    end
end

-- ============================================
-- SEND ANSWER
-- ============================================
local function SendAnswer(answer, source)
    if not answer or answer == "" then return false end
    
    if SendAnswerRemote then
        local success, err = pcall(function() SendAnswerRemote:FireServer(answer) end)
        if success then
            table.insert(State.lastAnswers, answer)
            if #State.lastAnswers > 10 then table.remove(State.lastAnswers, 1) end
            Luna:Notification({ Title = "Jawab", Content = "Terkirim: " .. string.upper(answer), Icon = "send", ImageSource = "Material" })
            return true
        end
    end
    
    if IsInputActive() then
        TypeAnswer(answer)
        table.insert(State.lastAnswers, answer)
        if #State.lastAnswers > 10 then table.remove(State.lastAnswers, 1) end
        Luna:Notification({ Title = "Jawab", Content = "Terkirim: " .. string.upper(answer), Icon = "send", ImageSource = "Material" })
        return true
    end
    
    Luna:Notification({ Title = "Error", Content = "Tidak bisa mengirim jawaban!", Icon = "error", ImageSource = "Material" })
    return false
end

-- ============================================
-- AUTO ANSWER
-- ============================================
local function StartAutoAnswer()
    if AutoAnswerTask then task.cancel(AutoAnswerTask) end
    
    AutoAnswerTask = task.spawn(function()
        while State.isAutoAnswerEnabled do
            local clue = GetCurrentClue()
            if clue and clue ~= "" then
                local answers = GetPossibleAnswers(clue)
                if #answers > 0 then
                    for _, answer in ipairs(answers) do
                        if not State.isAutoAnswerEnabled then break end
                        local currentClue = GetCurrentClue()
                        if currentClue ~= clue then break end
                        SendAnswer(answer, "auto")
                        task.wait(Config.autoAnswerDelay)
                    end
                else
                    task.wait(1)
                end
            else
                task.wait(1)
            end
        end
    end)
end

local function StopAutoAnswer()
    State.isAutoAnswerEnabled = false
    if AutoAnswerTask then task.cancel(AutoAnswerTask); AutoAnswerTask = nil end
end

-- ============================================
-- SPAM ANSWER
-- ============================================
local function StartSpam(answer)
    State.isSpamming = true
    State.spamAnswer = answer
    if SpamTask then task.cancel(SpamTask) end
    
    SpamTask = task.spawn(function()
        while State.isSpamming do
            SendAnswer(State.spamAnswer, "spam")
            task.wait(Config.spamDelay)
        end
    end)
    
    Luna:Notification({ Title = "Spam", Content = "Spam " .. string.upper(answer) .. " dimulai!", Icon = "send", ImageSource = "Material" })
end

local function StopSpam()
    State.isSpamming = false
    State.spamAnswer = ""
    if SpamTask then task.cancel(SpamTask); SpamTask = nil end
    Luna:Notification({ Title = "Spam", Content = "Spam dihentikan!", Icon = "stop", ImageSource = "Material" })
end

-- ============================================
-- ANTI AFK
-- ============================================
local function StartAntiAFK()
    if AntiAFKTask then task.cancel(AntiAFKTask) end
    
    AntiAFKTask = task.spawn(function()
        while State.antiAFKEnabled do
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
            task.wait(60)
            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame + Vector3.new(1, 0, 0)
                task.wait(0.1)
                hrp.CFrame = CFrame.new(hrp.Position)
            end
        end
    end)
end

local function StopAntiAFK()
    if AntiAFKTask then task.cancel(AntiAFKTask); AntiAFKTask = nil end
end

-- ============================================
-- ANSWER PANEL UI (FLOATING)
-- ============================================
local function CreateAnswerPanel()
    if AnswerPanel then pcall(function() AnswerPanel:Destroy() end) end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MizukageAnswerPanel"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999998
    screenGui.Parent = PlayerGui
    AnswerPanel = screenGui
    
    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.fromOffset(220, 350)
    mainFrame.Position = UDim2.fromScale(0.02, 0.15)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 45)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.Active = true
    mainFrame.Draggable = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = Color3.fromRGB(100, 80, 200)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    
    local header = Instance.new("Frame", mainFrame)
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Color3.fromRGB(80, 50, 160)
    header.BackgroundTransparency = 0.1
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)
    
    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = UDim2.new(1, -35, 1, 0)
    titleLabel.Position = UDim2.fromOffset(8, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🔍 KEMUNGKINAN JAWABAN"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 10
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.fromOffset(22, 22)
    closeBtn.Position = UDim2.new(1, -26, 0.5, -11)
    closeBtn.Text = "✕"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 80)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.AutoButtonColor = false
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function()
        State.showAnswerPanel = false
        if AnswerPanel then AnswerPanel:Destroy() end
    end)
    
    local clueFrame = Instance.new("Frame", mainFrame)
    clueFrame.Size = UDim2.new(1, -16, 0, 50)
    clueFrame.Position = UDim2.fromOffset(8, 36)
    clueFrame.BackgroundColor3 = Color3.fromRGB(40, 30, 65)
    clueFrame.BackgroundTransparency = 0.2
    Instance.new("UICorner", clueFrame).CornerRadius = UDim.new(0, 8)
    
    local clueLabel = Instance.new("TextLabel", clueFrame)
    clueLabel.Size = UDim2.new(1, -8, 0.6, 0)
    clueLabel.Position = UDim2.fromOffset(4, 4)
    clueLabel.BackgroundTransparency = 1
    clueLabel.Text = "Clue: -"
    clueLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    clueLabel.Font = Enum.Font.GothamBold
    clueLabel.TextSize = 11
    clueLabel.TextXAlignment = Enum.TextXAlignment.Center
    clueLabel.TextWrapped = true
    
    local countLabel = Instance.new("TextLabel", clueFrame)
    countLabel.Size = UDim2.new(1, -8, 0.4, 0)
    countLabel.Position = UDim2.fromOffset(4, 30)
    countLabel.BackgroundTransparency = 1
    countLabel.Text = "0 kata ditemukan"
    countLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    countLabel.Font = Enum.Font.Gotham
    countLabel.TextSize = 10
    countLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local listFrame = Instance.new("Frame", mainFrame)
    listFrame.Size = UDim2.new(1, -16, 1, -100)
    listFrame.Position = UDim2.fromOffset(8, 92)
    listFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 38)
    listFrame.BackgroundTransparency = 0.1
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 8)
    
    local scrollFrame = Instance.new("ScrollingFrame", listFrame)
    scrollFrame.Size = UDim2.new(1, -12, 1, -12)
    scrollFrame.Position = UDim2.fromOffset(6, 6)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 80, 200)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.BorderSizePixel = 0
    
    local listLayout = Instance.new("UIListLayout", scrollFrame)
    listLayout.Padding = UDim.new(0, 3)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local currentAnswers = {}
    local lastClue = ""
    
    local function UpdateAnswerList()
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        if #currentAnswers == 0 then
            local emptyLabel = Instance.new("TextLabel", scrollFrame)
            emptyLabel.Size = UDim2.new(1, 0, 0, 35)
            emptyLabel.BackgroundTransparency = 1
            emptyLabel.Text = "❌ Tidak ada jawaban ditemukan"
            emptyLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
            emptyLabel.Font = Enum.Font.Gotham
            emptyLabel.TextSize = 10
            emptyLabel.TextXAlignment = Enum.TextXAlignment.Center
        else
            for index, answer in ipairs(currentAnswers) do
                local btn = Instance.new("TextButton", scrollFrame)
                btn.Size = UDim2.new(1, 0, 0, 30)
                btn.BackgroundColor3 = Color3.fromRGB(45, 35, 70)
                btn.BackgroundTransparency = 0.2
                btn.Text = ""
                btn.AutoButtonColor = false
                btn.LayoutOrder = index
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
                
                local numLabel = Instance.new("TextLabel", btn)
                numLabel.Size = UDim2.fromOffset(25, 30)
                numLabel.Position = UDim2.fromOffset(4, 0)
                numLabel.BackgroundTransparency = 1
                numLabel.Text = tostring(index) .. "."
                numLabel.TextColor3 = Color3.fromRGB(150, 120, 220)
                numLabel.Font = Enum.Font.GothamBold
                numLabel.TextSize = 10
                numLabel.TextXAlignment = Enum.TextXAlignment.Right
                
                local ansLabel = Instance.new("TextLabel", btn)
                ansLabel.Size = UDim2.new(1, -35, 1, 0)
                ansLabel.Position = UDim2.fromOffset(32, 0)
                ansLabel.BackgroundTransparency = 1
                ansLabel.Text = string.upper(answer)
                ansLabel.TextColor3 = Color3.new(1, 1, 1)
                ansLabel.Font = Enum.Font.GothamBold
                ansLabel.TextSize = 11
                ansLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(80, 60, 130) end)
                btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(45, 35, 70) end)
                btn.MouseButton1Click:Connect(function()
                    SendAnswer(answer, "panel")
                    btn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
                    task.wait(0.3)
                    btn.BackgroundColor3 = Color3.fromRGB(45, 35, 70)
                end)
            end
            task.wait()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
        end
    end
    
    if AnswerPanelConnection then AnswerPanelConnection:Disconnect() end
    
    AnswerPanelConnection = RunService.Heartbeat:Connect(function()
        if not State.showAnswerPanel or not AnswerPanel then return end
        local currentClueText = GetCurrentClue()
        clueLabel.Text = "Clue: " .. (currentClueText ~= "" and string.upper(currentClueText) or "-")
        if currentClueText ~= lastClue then
            lastClue = currentClueText
            currentAnswers = GetPossibleAnswers(currentClueText)
            countLabel.Text = #currentAnswers .. " kata ditemukan"
            UpdateAnswerList()
        end
    end)
end

local function DestroyAnswerPanel()
    if AnswerPanelConnection then AnswerPanelConnection:Disconnect(); AnswerPanelConnection = nil end
    if AnswerPanel then pcall(function() AnswerPanel:Destroy() end); AnswerPanel = nil end
    State.showAnswerPanel = false
end

-- ============================================
-- CLUE UPDATE EVENT
-- ============================================
if UpdateClueRemote then
    UpdateClueRemote.OnClientEvent:Connect(function(clue)
        State.currentClue = clue or ""
        State.possibleAnswers = GetPossibleAnswers(State.currentClue)
    end)
end

task.spawn(function()
    while true do
        task.wait(1)
        local clue = GetCurrentClue()
        if clue ~= State.currentClue then
            State.currentClue = clue
            State.possibleAnswers = GetPossibleAnswers(clue)
        end
    end
end)

-- ============================================
-- CREATE TABS (LUNA)
-- ============================================

-- Main Tab
local MainTab = Window:CreateTab({ Name = "Main", Icon = "rocket", ImageSource = "Material", ShowTitle = true })

MainTab:CreateParagraph({ Title = "Auto Jawab", Text = "Pengaturan auto answer" })
MainTab:CreateToggle({ Name = "Auto Coba Semua Jawaban", CurrentValue = false, Callback = function(v)
    State.isAutoAnswerEnabled = v
    if v then StartAutoAnswer() else StopAutoAnswer() end
end })
MainTab:CreateSlider({ Name = "Delay Auto Jawab", Range = {0.5, 5}, Increment = 0.1, CurrentValue = Config.autoAnswerDelay, Callback = function(v)
    Config.autoAnswerDelay = v
    if State.isAutoAnswerEnabled then StartAutoAnswer() end
end })

MainTab:CreateDivider()
MainTab:CreateParagraph({ Title = "Panel Jawaban", Text = "Floating panel kemungkinan jawaban" })
MainTab:CreateToggle({ Name = "Tampilkan Kemungkinan Jawaban", CurrentValue = false, Callback = function(v)
    State.showAnswerPanel = v
    if v then CreateAnswerPanel() else DestroyAnswerPanel() end
end })

MainTab:CreateDivider()
MainTab:CreateParagraph({ Title = "Spam Jawaban", Text = "Spam answer terus menerus" })
MainTab:CreateButton({ Name = "Spam YES", Callback = function() StartSpam("Yes") end })
MainTab:CreateButton({ Name = "Spam NO", Callback = function() StartSpam("No") end })
MainTab:CreateButton({ Name = "Spam MAYBE", Callback = function() StartSpam("Maybe") end })
MainTab:CreateButton({ Name = "STOP SPAM", Callback = StopSpam })
MainTab:CreateSlider({ Name = "Delay Spam", Range = {0.05, 2}, Increment = 0.05, CurrentValue = Config.spamDelay, Callback = function(v)
    Config.spamDelay = v
    if State.isSpamming then StartSpam(State.spamAnswer) end
end })

MainTab:CreateDivider()
MainTab:CreateParagraph({ Title = "Pengaturan Lainnya", Text = "Additional settings" })
MainTab:CreateToggle({ Name = "Anti AFK", CurrentValue = false, Callback = function(v)
    State.antiAFKEnabled = v
    if v then StartAntiAFK() else StopAntiAFK() end
end })
MainTab:CreateToggle({ Name = "Like Human Typing", CurrentValue = false, Callback = function(v)
    State.humanTypingEnabled = v
end })
MainTab:CreateSlider({ Name = "Delay Antar Huruf", Range = {0.02, 0.2}, Increment = 0.01, CurrentValue = Config.keyDelay, Callback = function(v) Config.keyDelay = v end })
MainTab:CreateSlider({ Name = "Delay Submit", Range = {0.05, 0.5}, Increment = 0.01, CurrentValue = Config.submitDelay, Callback = function(v) Config.submitDelay = v end })

MainTab:CreateDivider()
MainTab:CreateParagraph({ Title = "Kirim Jawaban Manual", Text = "Kirim jawaban custom" })

local manualAnswer = ""
MainTab:CreateInput({ Name = "Ketik jawaban...", PlaceholderText = "Ketik jawaban disini...", Callback = function(v) manualAnswer = v end })
MainTab:CreateButton({ Name = "Kirim Jawaban", Callback = function()
    if manualAnswer ~= "" then SendAnswer(manualAnswer, "manual") end
end })

-- Stats Tab
local StatsTab = Window:CreateTab({ Name = "Stats", Icon = "analytics", ImageSource = "Material", ShowTitle = true })

StatsTab:CreateParagraph({ Title = "Player Info", Text = "Informasi akun" })
StatsTab:CreateParagraph({ Title = "Nama", Text = "Nama: " .. LocalPlayer.Name })
StatsTab:CreateParagraph({ Title = "Display Name", Text = "Display Name: " .. LocalPlayer.DisplayName })
StatsTab:CreateParagraph({ Title = "User ID", Text = "User ID: " .. LocalPlayer.UserId })

StatsTab:CreateDivider()
StatsTab:CreateParagraph({ Title = "Statistik", Text = "Statistik permainan" })

local answersGivenLabel = StatsTab:CreateParagraph({ Title = "Jawaban Diberikan", Text = "Jawaban Diberikan: 0" })
local lastAnswerLabel = StatsTab:CreateParagraph({ Title = "Jawaban Terakhir", Text = "Jawaban Terakhir: -" })

task.spawn(function()
    while true do
        pcall(function()
            answersGivenLabel:Set("Jawaban Diberikan: " .. #State.lastAnswers)
            if #State.lastAnswers > 0 then
                lastAnswerLabel:Set("Jawaban Terakhir: " .. string.upper(State.lastAnswers[#State.lastAnswers]))
            end
        end)
        task.wait(2)
    end
end)

StatsTab:CreateButton({ Name = "Reset Riwayat Jawaban", Callback = function() State.lastAnswers = {} end })

-- Database Tab
local DbTab = Window:CreateTab({ Name = "Database", Icon = "database", ImageSource = "Material", ShowTitle = true })

DbTab:CreateParagraph({ Title = "Kamus Kata", Text = "Database kata yang tersedia" })

local wordCountLabel = DbTab:CreateParagraph({ Title = "Total Kata", Text = "Total Kata: " .. #WordDatabase.words })
DbTab:CreateButton({ Name = "Reload Database", Callback = function()
    LoadWordDatabase()
    wordCountLabel:Set("Total Kata: " .. #WordDatabase.words)
end })

DbTab:CreateDivider()
DbTab:CreateParagraph({ Title = "Tambah Kata Manual", Text = "Tambahkan kata ke database" })

local newWord = ""
DbTab:CreateInput({ Name = "Kata baru...", PlaceholderText = "Masukkan kata baru...", Callback = function(v)
    newWord = string.lower(string.gsub(v, "[^a-z]", ""))
end })
DbTab:CreateButton({ Name = "Simpan Kata", Callback = function()
    if newWord and #newWord >= 2 then
        local exists = false
        for _, word in ipairs(WordDatabase.words) do if word == newWord then exists = true; break end end
        if not exists then
            table.insert(WordDatabase.words, newWord)
            local firstChar = string.sub(newWord, 1, 1)
            if WordDatabase.byFirstLetter[firstChar] then table.insert(WordDatabase.byFirstLetter[firstChar], newWord) end
            table.sort(WordDatabase.words, function(a, b) return #a < #b end)
            wordCountLabel:Set("Total Kata: " .. #WordDatabase.words)
            Luna:Notification({ Title = "Database", Content = '"' .. newWord .. '" ditambahkan!', Icon = "check", ImageSource = "Material" })
        end
    else
        Luna:Notification({ Title = "Error", Content = "Kata minimal 2 huruf!", Icon = "error", ImageSource = "Material" })
    end
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
LoadWordDatabase()

Luna:Notification({
    Title = "Mizukage System",
    Content = "Tebak Yuk - " .. #WordDatabase.words .. " kata siap!",
    Icon = "verified",
    ImageSource = "Material"
})