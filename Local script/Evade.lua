-- Mizukage Official | TeamMizu🔰 - All rights reserved
-- Game: Evade
-- Script rebuilt by MIZU-OS v14.0
-- ⚠️ WAJIB DIISI: Place ID game Evade

-- LOAD LUNA (WAJIB)
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- BUAT WINDOW UTAMA
local Window = Luna:CreateWindow({
    Name = "Mizukage Official",
    Subtitle = "Evade - TeamMizu🔰",
    LogoID = "104266190557772",
    LoadingEnabled = true,
    LoadingTitle = "Mizukage System",
    LoadingSubtitle = "by @MizukageOfficial",
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "MizukageHub/Evade"
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
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer

-- ============================================
-- PLAYERS FOLDER
-- ============================================
local PlayersFolder = workspace:WaitForChild("Game"):WaitForChild("Players")

-- ============================================
-- TIMER
-- ============================================
local timer = nil
local timerActive = false

local function nextbotsExist()
    if not PlayersFolder then return false end
    for _, model in ipairs(PlayersFolder:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("Hitbox") then
            return true
        end
    end
    return false
end

task.spawn(function()
    while true do
        if nextbotsExist() and not timerActive then
            timer = 180
            timerActive = true
        end
        if timerActive and timer > 0 then
            timer = timer - 1
        elseif timerActive and timer <= 0 then
            timer = nil
            timerActive = false
        end
        task.wait(1)
    end
end)

-- ============================================
-- CHARACTER REFS
-- ============================================
local character = nil
local hum = nil
local root = nil

local function updateChar(char)
    character = char
    root = character and character:FindFirstChild("HumanoidRootPart")
    hum = character and character:FindFirstChild("Humanoid")
end

updateChar(lp.Character or lp.CharacterAdded:Wait())
lp.CharacterAdded:Connect(updateChar)

-- ============================================
-- STATE
-- ============================================
local State = {
    walkToggle = false,
    currentSpeed = 28,
    emoteVSpeed = 40,
    noclipToggle = false,
    antiAfkToggle = false,
    flingToggle = false,
    antiFlingToggle = false,
    antiNextbot = false,
    autoObj = false,
    autoRev = false,
    espHighlight = false,
    espTracers = false,
    espNames = false,
    espBoxes = false,
    espStuds = false,
    selectedEspTypes = {},
    noclipConnection = nil,
    clip = false
}

-- ============================================
-- NOCLIP
-- ============================================
local function noclip()
    State.clip = false
    if State.noclipConnection then State.noclipConnection:Disconnect() end
    State.noclipConnection = RunService.Stepped:Connect(function()
        if State.clip == false and lp.Character then
            for _, v in ipairs(lp.Character:GetChildren()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
    end)
end

local function clip()
    State.clip = true
    if State.noclipConnection then
        State.noclipConnection:Disconnect()
        State.noclipConnection = nil
    end
end

-- ============================================
-- AFK ZONE TELEPORT
-- ============================================
local function teleportAndCreateBase(text)
    if not root then return end
    root.CFrame = CFrame.new(0, 9999, 0)
    
    local basePart = Instance.new("Part")
    basePart.Size = Vector3.new(5000, 1, 5000)
    basePart.Position = root.Position - Vector3.new(0, root.Size.Y/2 + 0.5, 0)
    basePart.Anchored = true
    basePart.CanCollide = true
    basePart.Parent = workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = basePart
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 7, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 5000
    billboard.Parent = basePart

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.6, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "MizuHub\nAFK Zone"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    local timerLabel = Instance.new("TextLabel")
    timerLabel.Size = UDim2.new(1, 0, 0.4, 0)
    timerLabel.Position = UDim2.new(0, 0, 0.6, 0)
    timerLabel.BackgroundTransparency = 1
    timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    timerLabel.TextScaled = true
    timerLabel.Font = Enum.Font.GothamBold
    timerLabel.Text = "Intermission"
    timerLabel.Parent = billboard

    task.spawn(function()
        while basePart.Parent do
            if timer == nil then
                timerLabel.Text = "Intermission"
            else
                timerLabel.Text = "Round end: " .. tostring(timer)
            end
            task.wait(1)
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if State.antiNextbot and root and root.Position.Y < 9990 then
            teleportAndCreateBase("MizuHub\nAFK Zone")
        end
    end
end)

-- ============================================
-- SPEED HACK (BYASS)
-- ============================================
local normalConn = nil
local function applyBypassSpeed()
    if normalConn then normalConn:Disconnect() end
    normalConn = RunService.Heartbeat:Connect(function()
        if not State.walkToggle or not character then return end
        if not hum or not root then return end
        for _, conn in ipairs(getconnections(hum:GetPropertyChangedSignal("WalkSpeed"))) do
            conn:Disable()
        end
        local dir = hum.MoveDirection
        if dir.Magnitude > 0 then
            local speed = root:FindFirstChild("EmoteSound") and State.emoteVSpeed or State.currentSpeed
            local move = Vector3.new(dir.X, 0, dir.Z).Unit * speed
            root.AssemblyLinearVelocity = Vector3.new(move.X, root.AssemblyLinearVelocity.Y, move.Z)
        else
            root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
        end
    end)
end
applyBypassSpeed()

-- ============================================
-- AUTO JUMP UI
-- ============================================
local function createAutoJumpUI()
    if game.CoreGui:FindFirstChild("MizuAutoJump") then
        game.CoreGui:FindFirstChild("MizuAutoJump"):Destroy()
    end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MizuAutoJump"
    ScreenGui.Parent = game.CoreGui

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 140, 0, 40)
    Toggle.Position = UDim2.new(0.68, 0, 0.05, 0)
    Toggle.Text = "Auto Jump: OFF"
    Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Toggle.TextColor3 = Color3.new(1, 1, 1)
    Toggle.Font = Enum.Font.SourceSansBold
    Toggle.TextSize = 18
    Toggle.Parent = ScreenGui
    Toggle.Active = true
    Toggle.Draggable = true

    local autoJump = false
    local conn = nil

    Toggle.MouseButton1Click:Connect(function()
        autoJump = not autoJump
        Toggle.Text = autoJump and "Auto Jump: ON" or "Auto Jump: OFF"
        if conn then conn:Disconnect() end
        if autoJump then
            conn = RunService.Heartbeat:Connect(function()
                if hum and hum.FloorMaterial ~= Enum.Material.Air then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end)
end

-- ============================================
-- GRAVITY UI
-- ============================================
local function createGravityUI()
    if game.CoreGui:FindFirstChild("MizuGravity") then
        game.CoreGui:FindFirstChild("MizuGravity"):Destroy()
    end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MizuGravity"
    ScreenGui.Parent = game.CoreGui

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 140, 0, 40)
    Toggle.Position = UDim2.new(0.68, 0, 0.05, 0)
    Toggle.Text = "Gravity: OFF"
    Toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Toggle.TextColor3 = Color3.new(1, 1, 1)
    Toggle.Font = Enum.Font.SourceSansBold
    Toggle.TextSize = 18
    Toggle.Parent = ScreenGui
    Toggle.Active = true
    Toggle.Draggable = true
    
    local defaultGravity = workspace.Gravity
    local gravity = false
    local conn = nil

    Toggle.MouseButton1Click:Connect(function()
        gravity = not gravity
        Toggle.Text = gravity and "Gravity: ON" or "Gravity: OFF"
        if conn then conn:Disconnect() end
        if gravity then
            conn = RunService.Heartbeat:Connect(function()
                if workspace.Gravity ~= 30 then workspace.Gravity = 30 end
            end)
        else
            workspace.Gravity = defaultGravity
        end
    end)
end

-- ============================================
-- ANTI AFK
-- ============================================
task.spawn(function()
    while true do
        if State.antiAfkToggle and root then
            root.CFrame = root.CFrame + Vector3.new(0, 3, 0)
        end
        task.wait(60)
    end
end)

-- ============================================
-- FLING
-- ============================================
local function fling()
    local movel = 0.1
    while State.flingToggle do
        RunService.Heartbeat:Wait()
        if root then
            local vel = root.Velocity
            root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
            RunService.RenderStepped:Wait()
            root.Velocity = vel
            RunService.Stepped:Wait()
            root.Velocity = vel + Vector3.new(0, movel, 0)
            movel = -movel
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.02)
        if State.flingToggle then fling() end
    end
end)

-- ============================================
-- ANTI FLING
-- ============================================
task.spawn(function()
    while task.wait(0.02) do
        if State.antiFlingToggle then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character then
                    for _, part in ipairs(plr.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end
    end
end)

-- ============================================
-- ESP SYSTEM
-- ============================================
local esp = {}
local tracers = {}
local boxes = {}
local DrawingAvailable = (type(Drawing) == "table" or type(Drawing) == "userdata")

local function contains(tbl, val)
    if not tbl or type(tbl) ~= "table" then return false end
    for _, v in ipairs(tbl) do if v == val then return true end end
    return false
end

local function isPlayerObject(obj)
    return type(obj.Name) == "string" and not obj.Name:find(" ") and not obj:FindFirstChild("Revives") and obj.Parent.Name == "Game"
end

local function isNextbotObject(obj)
    return obj:FindFirstChild("Hitbox") and obj.Hitbox:IsA("BasePart")
end

local function isInjuredPlayer(obj)
    return type(obj.Name) == "string" and not obj.Name:find(" ") and obj:FindFirstChild("Revives")
end

local function passesDropdownFilter(obj)
    if not State.selectedEspTypes or #State.selectedEspTypes == 0 then return false end
    if contains(State.selectedEspTypes, "Players") and isPlayerObject(obj) then return true end
    if contains(State.selectedEspTypes, "Nextbots") and isNextbotObject(obj) then return true end
    if contains(State.selectedEspTypes, "Injured Players") and isInjuredPlayer(obj) then return true end
    return false
end

local function getObjColor(obj)
    if isInjuredPlayer(obj) then return Color3.fromRGB(255, 255, 0) end
    if isNextbotObject(obj) then return Color3.fromRGB(255, 0, 0) end
    return Color3.fromRGB(0, 255, 0)
end

local function getRootPosition(target)
    if target:IsA("BasePart") then return target.Position end
    if target:IsA("Model") then
        if target.PrimaryPart then return target.PrimaryPart.Position end
        local r = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("VisibleParts")
        if r and r:IsA("BasePart") then return r.Position end
        return target:GetPivot().Position
    end
    return Vector3.new(0, 0, 0)
end

local function ensureHighlight(obj)
    if not State.espHighlight then
        if esp[obj] and esp[obj].highlight then
            esp[obj].highlight:Destroy()
            esp[obj].highlight = nil
        end
        return
    end
    if not esp[obj] then esp[obj] = {} end
    if not esp[obj].highlight then
        local h = Instance.new("Highlight")
        h.Adornee = obj
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
        h.FillColor = getObjColor(obj)
        h.OutlineColor = Color3.new(1, 1, 1)
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = obj
        esp[obj].highlight = h
    end
end

local function ensureBillboard(obj)
    if not (State.espNames or State.espStuds) then
        if esp[obj] and esp[obj].billboard then
            esp[obj].billboard:Destroy()
            esp[obj].billboard = nil
        end
        return
    end
    if not esp[obj] then esp[obj] = {} end
    if not esp[obj].billboard then
        local head = obj:FindFirstChild("Head") or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
        if not head then return end
        local b = Instance.new("BillboardGui")
        b.Name = "MizuESP"
        b.Size = UDim2.new(0, 200, 0, 50)
        b.Adornee = head
        b.AlwaysOnTop = true
        b.MaxDistance = 5000
        b.Parent = obj
        local n = Instance.new("TextLabel")
        n.Name = "MainLabel"
        n.Parent = b
        n.BackgroundTransparency = 1
        n.Size = UDim2.new(1, 0, 1, 0)
        n.Text = ""
        n.Font = Enum.Font.SourceSansBold
        n.TextSize = 14
        n.TextStrokeTransparency = 0
        n.RichText = true
        esp[obj].billboard = b
        esp[obj].nameLabel = n
    end
end

local function ensureTracer(obj)
    if not State.espTracers then
        if tracers[obj] then tracers[obj]:Remove(); tracers[obj] = nil end
        return
    end
    if not tracers[obj] and DrawingAvailable then
        local L = Drawing.new("Line")
        L.Thickness = 1
        L.Transparency = 1
        tracers[obj] = L
    end
end

local function ensureBox(obj)
    if not State.espBoxes then
        if boxes[obj] then
            for _, l in pairs(boxes[obj]) do l:Remove() end
            boxes[obj] = nil
        end
        return
    end
    if not boxes[obj] and DrawingAvailable then
        boxes[obj] = {
            tl = Drawing.new("Line"),
            tr = Drawing.new("Line"),
            bl = Drawing.new("Line"),
            br = Drawing.new("Line")
        }
        for _, line in pairs(boxes[obj]) do line.Thickness = 1; line.Transparency = 1 end
    end
end

local function removeESP(obj)
    local d = esp[obj]
    if d then
        if d.highlight then pcall(function() d.highlight:Destroy() end) end
        if d.billboard then pcall(function() d.billboard:Destroy() end) end
        esp[obj] = nil
    end
    if tracers[obj] then pcall(function() tracers[obj]:Remove() end); tracers[obj] = nil end
    if boxes[obj] then
        for _, l in pairs(boxes[obj]) do pcall(function() l:Remove() end) end
        boxes[obj] = nil
    end
end

local lastUpdate = 0
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastUpdate > 1.5 then
        lastUpdate = now
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj ~= lp.Character and passesDropdownFilter(obj) then
                ensureHighlight(obj)
                ensureBillboard(obj)
                ensureTracer(obj)
                ensureBox(obj)
            end
        end
    end

    if not Camera then return end
    local viewportSize = Camera.ViewportSize
    local myRoot = root

    for obj, data in pairs(esp) do
        if not obj or not obj.Parent or not passesDropdownFilter(obj) then
            removeESP(obj)
            continue
        end

        local color = getObjColor(obj)
        local worldPos = getRootPosition(obj)
        local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
        local isVisible = onScreen and screenPos.Z > 0

        if tracers[obj] and isVisible and State.espTracers then
            tracers[obj].Visible = true
            tracers[obj].Color = color
            tracers[obj].From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
            tracers[obj].To = Vector2.new(screenPos.X, screenPos.Y)
        elseif tracers[obj] then
            tracers[obj].Visible = false
        end

        if data.billboard then
            data.billboard.Enabled = isVisible and (State.espNames or State.espStuds)
            if data.billboard.Enabled and myRoot then
                local targetLabel = data.nameLabel
                if targetLabel then
                    local dist = (Camera.CFrame.Position - worldPos).Magnitude
                    if State.espNames and State.espStuds then
                        targetLabel.Text = obj.Name .. " (" .. string.format("%.0fm", dist) .. ")"
                    elseif State.espNames then
                        targetLabel.Text = obj.Name
                    elseif State.espStuds then
                        targetLabel.Text = string.format("%.0fm", dist)
                    end
                    targetLabel.TextColor3 = color
                end
            end
        end

        if boxes[obj] and isVisible and State.espBoxes then
            local box = boxes[obj]
            local size = (1 / screenPos.Z) * 1000
            local w, h = size * 0.6, size
            local x, y = screenPos.X, screenPos.Y
            for _, line in pairs(box) do line.Visible = true; line.Color = color end
            box.tl.From = Vector2.new(x-w, y-h); box.tl.To = Vector2.new(x+w, y-h)
            box.tr.From = Vector2.new(x+w, y-h); box.tr.To = Vector2.new(x+w, y+h)
            box.br.From = Vector2.new(x+w, y+h); box.br.To = Vector2.new(x-w, y+h)
            box.bl.From = Vector2.new(x-w, y+h); box.bl.To = Vector2.new(x-w, y-h)
        elseif boxes[obj] then
            for _, line in pairs(boxes[obj]) do line.Visible = false end
        end

        if data.highlight then data.highlight.FillColor = color end
    end
end)

Workspace.ChildAdded:Connect(function(child)
    task.wait(0.5)
    if passesDropdownFilter(child) then
        ensureHighlight(child)
        ensureBillboard(child)
        ensureTracer(child)
        ensureBox(child)
    end
end)

-- ============================================
-- PROTECT IDENTITY
-- ============================================
local idConn = nil
local function bacon(c)
    if not character then return end
    for _, v in pairs(character:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Clothing") or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") then v:Destroy() end
    end
    if character:FindFirstChild("Head") and character.Head:FindFirstChild("face") then character.Head.face.Texture = "rbxassetid://144075659" end
    local bc = character:FindFirstChild("BodyColors") or Instance.new("BodyColors", c)
    bc.HeadColor3 = Color3.fromRGB(234, 184, 146)
    bc.TorsoColor3 = Color3.fromRGB(116, 134, 157)
    bc.LeftLegColor3 = Color3.fromRGB(82, 84, 82)
    bc.RightLegColor3 = Color3.fromRGB(82, 84, 82)
    bc.LeftArmColor3 = bc.HeadColor3
    bc.RightArmColor3 = bc.HeadColor3
    lp.Name = "mizukage"
    lp.DisplayName = "mizukage"
end

-- ============================================
-- CREATE TABS (LUNA)
-- ============================================

local AutoTab = Window:CreateTab({ Name = "Auto", Icon = "cpu", ImageSource = "Material", ShowTitle = true })
local EspTab = Window:CreateTab({ Name = "ESP", Icon = "visibility", ImageSource = "Material", ShowTitle = true })
local PlayerTab = Window:CreateTab({ Name = "Player", Icon = "person", ImageSource = "Material", ShowTitle = true })
local MiscTab = Window:CreateTab({ Name = "Misc", Icon = "more_horiz", ImageSource = "Material", ShowTitle = true })

-- Auto Tab
AutoTab:CreateParagraph({ Title = "AUTO FEATURES", Text = "Fitur otomatis" })
AutoTab:CreateToggle({ Name = "Auto Objectives", CurrentValue = false, Callback = function(v) State.autoObj = v end })
AutoTab:CreateToggle({ Name = "Auto Revive", CurrentValue = false, Callback = function(v) State.autoRev = v end })
AutoTab:CreateToggle({ Name = "AFK Farm", CurrentValue = false, Callback = function(v) State.antiNextbot = v end })
AutoTab:CreateButton({ Name = "Auto Jump UI", Callback = createAutoJumpUI })
AutoTab:CreateButton({ Name = "Gravity UI", Callback = createGravityUI })
AutoTab:CreateButton({ Name = "Full Bright", Callback = function()
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.Brightness = 2
    Lighting.ShadowSoftness = 0
    Lighting.GlobalShadows = false
end })

-- ESP Tab
EspTab:CreateParagraph({ Title = "ESP SETTINGS", Text = "Pengaturan ESP" })
EspTab:CreateDropdown({ Name = "ESP Types", Options = { "Injured Players", "Players", "Nextbots" }, CurrentOption = {}, Multi = true, Callback = function(v) State.selectedEspTypes = v end })
EspTab:CreateToggle({ Name = "Highlight objects", CurrentValue = false, Callback = function(v) State.espHighlight = v end })
EspTab:CreateToggle({ Name = "Show Tracers", CurrentValue = false, Callback = function(v) State.espTracers = v end })
EspTab:CreateToggle({ Name = "Show Boxes", CurrentValue = false, Callback = function(v) State.espBoxes = v end })
EspTab:CreateToggle({ Name = "Show Names", CurrentValue = false, Callback = function(v) State.espNames = v end })
EspTab:CreateToggle({ Name = "Show Studs", CurrentValue = false, Callback = function(v) State.espStuds = v end })

-- Player Tab
PlayerTab:CreateParagraph({ Title = "PLAYER MODS", Text = "Modifikasi karakter" })
PlayerTab:CreateToggle({ Name = "Noclip", CurrentValue = false, Callback = function(v) State.noclipToggle = v; if v then noclip() else clip() end end })
PlayerTab:CreateToggle({ Name = "WalkSpeed Changer", CurrentValue = false, Callback = function(v) State.walkToggle = v end })
PlayerTab:CreateSlider({ Name = "WalkSpeed", Range = {0, 150}, Increment = 1, CurrentValue = 28, Callback = function(v) State.currentSpeed = v end })
PlayerTab:CreateSlider({ Name = "Emote Speed", Range = {0, 300}, Increment = 1, CurrentValue = 40, Callback = function(v) State.emoteVSpeed = v end })

-- Misc Tab
MiscTab:CreateParagraph({ Title = "MISC", Text = "Fitur tambahan" })
MiscTab:CreateToggle({ Name = "Protect Identity", CurrentValue = false, Callback = function(v)
    if v then
        bacon(character)
        if idConn then idConn:Disconnect() end
        idConn = lp.CharacterAdded:Connect(function(c) bacon(c); task.wait(2); bacon(c) end)
    else
        if idConn then idConn:Disconnect() end
    end
end })
MiscTab:CreateToggle({ Name = "Anti AFK", CurrentValue = false, Callback = function(v) State.antiAfkToggle = v end })
MiscTab:CreateToggle({ Name = "Anti Fling", CurrentValue = false, Callback = function(v) State.antiFlingToggle = v end })
MiscTab:CreateToggle({ Name = "Touch Fling", CurrentValue = false, Callback = function(v) State.flingToggle = v end })
MiscTab:CreateButton({ Name = "Bypass Anti Speed", Callback = function()
    if root then
        for _, obj in ipairs(root:GetChildren()) do
            if obj:IsA("LinearVelocity") then obj:Destroy() end
        end
    end
end })

-- Theme Tab
local ThemeTab = Window:CreateTab({ Name = "Theme", Icon = "palette", ImageSource = "Material", ShowTitle = true })
ThemeTab:BuildThemeSection()

-- Config Tab
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
    Content = "Evade loaded!",
    Icon = "verified",
    ImageSource = "Material"
})