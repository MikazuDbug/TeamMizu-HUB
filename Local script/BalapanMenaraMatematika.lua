--[[
    ╔══════════════════════════════════════════════════╗
    ║ 🌊 MIZUKAGE CLOUD HUB - Game Specific Script   ║
    ║ 🎮 Balapan Menara Matematika (17571821642)     ║
    ║ 📅 Generated : 2026-05-21                       ║
    ╚══════════════════════════════════════════════════╝
    
    FEATURES:
    ✅ Auto Answer (God Mode 0ms & Human Delay)
    ✅ Anti Lava (Disable Lava Damage)
    ✅ Auto Collect Gems
    ✅ Solver Mendukung Deret, Aljabar, PEMDAS
    ✅ Luna Interface Suite
]]

-- ==============================================
-- 🔹 PRE-INIT (Anti Duplicate)
-- ==============================================
if getgenv().Mizu_BalapMat_Loaded then return end
getgenv().Mizu_BalapMat_Loaded = true

-- ==============================================
-- 🔹 GLOBAL CONFIG
-- ==============================================
getgenv().MizuConfig = {
    IsRunning = true,
    AutoAnswer = false,
    LegitMode = false,      -- false = God (0ms), true = Human (delay 0.1-1.5s)
    AutoGems = false,
}

-- ==============================================
-- 🔹 SERVICES & REMOTES
-- ==============================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local SubmitAnswerRemote = ReplicatedStorage:WaitForChild("Remotes", 5):WaitForChild("SubmitAnswerRemote", 5)
local CollectGemRemote = ReplicatedStorage:WaitForChild("Remotes", 5):WaitForChild("CollectGemRemote", 5)

-- ==============================================
-- 🔹 MATH SOLVER (Supports deret, aljabar, PEMDAS)
-- ==============================================
local function SolveMath(soalText)
    local clean = soalText:lower()
    clean = clean:gsub("x", "*"):gsub("÷", "/"):gsub("=", ""):gsub("?", ""):gsub(" ", "")
    
    -- Coba ekstrak ekspresi matematika murni
    local expr = clean:match("[%d%.%+%-%*%/%%^%(%)]+")
    if expr and expr:find("%d") then
        local func, err = loadstring("return " .. expr)
        if func then
            local success, result = pcall(func)
            if success and type(result) == "number" and result == result and result ~= math.huge then
                return math.floor(result * 100 + 0.5) / 100  -- bulatkan 2 desimal
            end
        end
    end

    -- Fallback: deret angka (contoh "7, 6, 5, 4" -> angka selanjutnya? 
    -- Tapi biasanya soal deret berupa "7, 6, 5, 4" dan jawaban "3". Kita deteksi koma.
    local numbers = {}
    for num in clean:gmatch("(%d+)") do
        table.insert(numbers, tonumber(num))
    end
    if #numbers >= 3 then
        -- Cek pola selisih konstan
        local diff = numbers[2] - numbers[1]
        local isLinear = true
        for i = 2, #numbers - 1 do
            if numbers[i+1] - numbers[i] ~= diff then isLinear = false break end
        end
        if isLinear then
            return numbers[#numbers] + diff
        end
    end

    return nil
end

-- ==============================================
-- 🔹 SEND ANSWER LOGIC
-- ==============================================
local lastAnswerText = ""
local function SendAnswer(answer, mode)
    if not answer then return end
    local payload = tostring(math.floor(answer)) .. "  "  -- format + 2 spasi
    if mode == "God" then
        task.spawn(function()
            SubmitAnswerRemote:InvokeServer(payload, "Selection_TouchTap")
        end)
    else -- Human mode
        local delayTime = math.random(10, 150) / 100
        task.delay(delayTime, function()
            SubmitAnswerRemote:InvokeServer(payload, "Selection_TouchTap")
        end)
    end
end

-- ==============================================
-- 🔹 AUTO ANSWER LOOP (Scan GUI)
-- ==============================================
local questionLabel = nil
task.spawn(function()
    while getgenv().MizuConfig.IsRunning do
        if getgenv().MizuConfig.AutoAnswer then
            pcall(function()
                -- Cari TextLabel dengan "= ???"
                if not questionLabel or not questionLabel.Parent or not questionLabel.Visible then
                    for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                        if gui:IsA("TextLabel") and gui.Visible and gui.Text:find("= %?%?%?") then
                            questionLabel = gui
                            break
                        end
                    end
                end
                
                if questionLabel and questionLabel.Text ~= lastAnswerText then
                    local currentText = questionLabel.Text
                    local jawaban = SolveMath(currentText)
                    if jawaban then
                        lastAnswerText = currentText
                        SendAnswer(jawaban, getgenv().MizuConfig.LegitMode and "Human" or "God")
                    end
                end
            end)
        else
            lastAnswerText = ""  -- reset jika dimatikan
        end
        task.wait(0.05)  -- responsif
    end
end)

-- ==============================================
-- 🔹 AUTO COLLECT GEMS (Spam remote dengan nilai kecil)
-- ==============================================
task.spawn(function()
    while getgenv().MizuConfig.IsRunning do
        if getgenv().MizuConfig.AutoGems then
            pcall(function()
                CollectGemRemote:FireServer("1")  -- nilai dummy, game menerimanya
            end)
        end
        task.wait(0.8)
    end
end)

-- ==============================================
-- 🔹 ANTI LAVA FUNCTION
-- ==============================================
local function DisableLava()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("lava") or obj.BrickColor.Name == "Bright orange" then
                obj.CanTouch = false
                obj.Transparency = 0.5
            end
        end
    end
end

-- ==============================================
-- 🔹 LOAD LUNA INTERFACE SUITE
-- ==============================================
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

local Window = Luna:CreateWindow({
    Name = "Mizukage Official",
    Subtitle = "Balapan Menara Matematika",
    LogoID = "82795327169782",
    LoadingEnabled = true,
    LoadingTitle = "Mizukage System",
    ConfigSettings = { ConfigFolder = "MizukageHub" },
    KeySystem = false
})

Window:CreateHomeTab({
    SupportedExecutors = {"Delta", "Codex", "Wave", "Arceus X"},
    DiscordInvite = "mizukage",
    Icon = 1
})

-- ==============================================
-- 🔹 MAIN FEATURES TAB
-- ==============================================
local MainTab = Window:CreateTab({
    Name = "Main Features",
    Icon = "swords",
    ImageSource = "Material",
    ShowTitle = true
})

MainTab:CreateToggle({
    Name = "Auto Answer (God)",
    CurrentValue = false,
    Callback = function(V)
        getgenv().MizuConfig.AutoAnswer = V
        if V then
            getgenv().MizuConfig.LegitMode = false
        end
    end
}, "TglGod")

MainTab:CreateToggle({
    Name = "Mode Aman (Delay 0.1-1.5s)",
    CurrentValue = false,
    Callback = function(V)
        getgenv().MizuConfig.LegitMode = V
        if V then
            getgenv().MizuConfig.AutoAnswer = true
        end
    end
}, "TglLegit")

MainTab:CreateToggle({
    Name = "Auto Collect Gems",
    CurrentValue = false,
    Callback = function(V)
        getgenv().MizuConfig.AutoGems = V
    end
}, "TglGems")

MainTab:CreateButton({
    Name = "🌋 Disable Lava (Anti-Mati)",
    Callback = function()
        DisableLava()
        Luna:Notification({
            Title = "Mizukage",
            Content = "Lava berhasil dinonaktifkan!",
            Duration = 3
        })
    end
})

-- ==============================================
-- 🔹 THEME & CONFIG TABS
-- ==============================================
Window:CreateTab({
    Name = "Theme",
    Icon = "palette",
    ImageSource = "Material",
    ShowTitle = true
}):BuildThemeSection()

Window:CreateTab({
    Name = "Config",
    Icon = "settings",
    ImageSource = "Material",
    ShowTitle = true
}):BuildConfigSection()

-- Selesai
Luna:Notification({
    Title = "Mizukage Hub",
    Content = "Script Balapan Menara Matematika siap!",
    Duration = 5
})
