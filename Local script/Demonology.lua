-- Mizukage Official | TeamMizu🔰 - All rights reserved
-- Game: Demonology
-- Script rebuilt by MIZU-OS v14.0
-- ⚠️ WAJIB DIISI: Place ID game Demonology

-- LOAD LUNA (WAJIB)
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- BUAT WINDOW UTAMA
local Window = Luna:CreateWindow({
    Name = "Mizukage Official",
    Subtitle = "Demonology - TeamMizu🔰",
    LogoID = "104266190557772",
    LoadingEnabled = true,
    LoadingTitle = "Mizukage System",
    LoadingSubtitle = "by @MizukageOfficial",
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "MizukageHub/Demonology"
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
    noclipToggle = false,
    antiAfkToggle = false,
    flingToggle = false,
    antiFlingToggle = false,
    ghostToggle = false,
    autoHideToggle = false,
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
-- WALKSPEED BYPASS
-- ============================================
local function applyBypassSpeed()
    task.spawn(function()
        while task.wait(0.2) do
            if not State.walkToggle then continue end
            if hum then
                for _, conn in ipairs(getconnections(hum:GetPropertyChangedSignal("WalkSpeed"))) do
                    conn:Disable()
                end
                hum.WalkSpeed = State.currentSpeed
            end
        end
    end)
end
applyBypassSpeed()

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
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
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
    local child = obj:FindFirstChild("Health")
    return child and child:IsA("Script")
end

local function isGhostObject(obj)
    local ghost = obj:FindFirstChild("VisibleParts")
    return ghost and ghost:IsA("Model")
end

local function isItem(obj)
    return obj:IsA("BasePart") and obj.Name == "Handle" and obj.Parent and obj.Parent.Parent and obj.Parent.Parent.Name == "Items"
end

local function isHandprint(obj)
    return obj:IsA("BasePart") and obj.Parent and obj.Parent.Name == "Handprints"
end

local function isOrb(obj)
    return obj:IsA("BasePart") and obj.Parent and obj.Parent.Name == "Workspace"
end

local function passesDropdownFilter(obj)
    if not State.selectedEspTypes or #State.selectedEspTypes == 0 then return false end
    if contains(State.selectedEspTypes, "Players") and isPlayerObject(obj) then return true end
    if contains(State.selectedEspTypes, "Ghosts") and isGhostObject(obj) then return true end
    if contains(State.selectedEspTypes, "Items") and isItem(obj) then return true end
    if contains(State.selectedEspTypes, "Handprints") and isHandprint(obj) then return true end
    if contains(State.selectedEspTypes, "Ghost Orb") and isOrb(obj) then return true end
    return false
end

local function getObjColor(obj)
    if isItem(obj) then return Color3.fromRGB(255, 255, 0) end
    if isGhostObject(obj) then return Color3.fromRGB(255, 0, 0) end
    if isHandprint(obj) then return Color3.fromRGB(0, 128, 0) end
    if isOrb(obj) then return Color3.fromRGB(0, 0, 0) end
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

-- ESP UPDATE LOOP
local lastUpdate = 0
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastUpdate > 1.5 then
        lastUpdate = now
        for _, obj in ipairs(Workspace:GetChildren()) do
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

-- ============================================
-- ITEM GRAB
-- ============================================
local toolRE = game.ReplicatedStorage.Events.RequestItemPickup

-- ============================================
-- GHOST VISIBLE
-- ============================================
local originalStates = {}
local function cacheGhost()
    local ghost = Workspace:FindFirstChild("Ghost")
    if not ghost then return end
    local visibleParts = ghost:FindFirstChild("VisibleParts")
    if not visibleParts then return end
    for _, obj in ipairs(visibleParts:GetDescendants()) do
        if obj:IsA("BasePart") and not originalStates[obj] then
            originalStates[obj] = { Transparency = obj.Transparency, LocalTransparencyModifier = obj.LocalTransparencyModifier, Decals = {} }
            for _, decal in ipairs(obj:GetDescendants()) do
                if decal:IsA("Decal") then originalStates[obj].Decals[decal] = decal.Transparency end
            end
        end
    end
end

local function restoreOriginal()
    for obj, state in pairs(originalStates) do
        if obj and obj:IsA("BasePart") then
            obj.Transparency = state.Transparency
            obj.LocalTransparencyModifier = state.LocalTransparencyModifier
            for decal, oldT in pairs(state.Decals) do
                if decal and decal:IsA("Decal") then decal.Transparency = oldT end
            end
        end
    end
end

-- ============================================
-- AUTO HIDE ON HAUNT
-- ============================================
local lastDoorState = nil
task.spawn(function()
    while true do
        task.wait(1)
        if State.autoHideToggle then
            local exitDoor = Workspace:FindFirstChild("Doors")
            exitDoor = exitDoor and exitDoor:FindFirstChild("ExitDoor")
            local isLocked = exitDoor and exitDoor:GetAttribute("Locked") or exitDoor and exitDoor:FindFirstChild("Locked")
            
            if exitDoor and lastDoorState == false and isLocked == true then
                local targetLocation = Workspace:FindFirstChild("Map")
                targetLocation = targetLocation and targetLocation:FindFirstChild("Rooms")
                targetLocation = targetLocation and targetLocation:FindFirstChild("Base Camp")
                targetLocation = targetLocation and targetLocation:FindFirstChild("EnergyMonitorFeed")
                if targetLocation and targetLocation:IsA("BasePart") and root then
                    root.CFrame = targetLocation.CFrame + Vector3.new(0, 5, 0)
                end
            end
            lastDoorState = isLocked
        else
            lastDoorState = nil
        end

        if State.ghostToggle then
            local ghost = Workspace:FindFirstChild("Ghost")
            if ghost then
                local visibleParts = ghost:FindFirstChild("VisibleParts")
                if visibleParts then
                    for _, obj in ipairs(visibleParts:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            obj.Transparency = 0
                            obj.LocalTransparencyModifier = 0
                            for _, decal in ipairs(obj:GetDescendants()) do
                                if decal:IsA("Decal") then decal.Transparency = 0 end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================
-- STATUS LABELS
-- ============================================
local orbStatusLabel = nil
local handprintStatusLabel = nil

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

local MainTab = Window:CreateTab({ Name = "Helper", Icon = "hammer", ImageSource = "Material", ShowTitle = true })
local EspTab = Window:CreateTab({ Name = "ESP", Icon = "visibility", ImageSource = "Material", ShowTitle = true })
local PlayerTab = Window:CreateTab({ Name = "Player", Icon = "person", ImageSource = "Material", ShowTitle = true })
local MiscTab = Window:CreateTab({ Name = "Misc", Icon = "more_horiz", ImageSource = "Material", ShowTitle = true })

-- Main Tab - Items Section
MainTab:CreateParagraph({ Title = "ITEMS", Text = "Ambil item dengan cepat" })
MainTab:CreateButton({ Name = "Grab Video Camera", Callback = function() toolRE:FireServer(Workspace:WaitForChild("Items"):WaitForChild("1")) end })
MainTab:CreateButton({ Name = "Grab Thermometer", Callback = function() toolRE:FireServer(Workspace:WaitForChild("Items"):WaitForChild("2")) end })
MainTab:CreateButton({ Name = "Grab Spirit Book", Callback = function() toolRE:FireServer(Workspace:WaitForChild("Items"):WaitForChild("3")) end })
MainTab:CreateButton({ Name = "Grab Blacklight", Callback = function() toolRE:FireServer(Workspace:WaitForChild("Items"):WaitForChild("4")) end })
MainTab:CreateButton({ Name = "Grab Spirit Box", Callback = function() toolRE:FireServer(Workspace:WaitForChild("Items"):WaitForChild("5")) end })
MainTab:CreateButton({ Name = "Grab EMF Reader", Callback = function() toolRE:FireServer(Workspace:WaitForChild("Items"):WaitForChild("6")) end })
MainTab:CreateButton({ Name = "Grab Flashlight", Callback = function() toolRE:FireServer(Workspace:WaitForChild("Items"):WaitForChild("7")) end })
MainTab:CreateButton({ Name = "Grab Laser Projector", Callback = function() toolRE:FireServer(Workspace:WaitForChild("Items"):WaitForChild("8")) end })
MainTab:CreateButton({ Name = "Grab Flower Pot", Callback = function() toolRE:FireServer(Workspace:WaitForChild("Items"):WaitForChild("9")) end })

MainTab:CreateDivider()
MainTab:CreateParagraph({ Title = "GHOST", Text = "Fitur untuk ghost" })
MainTab:CreateToggle({ Name = "Visible Ghost", CurrentValue = false, Callback = function(v) 
    if not v then restoreOriginal() end
    State.ghostToggle = v
end })
MainTab:CreateToggle({ Name = "Auto Hide (Haunt)", CurrentValue = false, Callback = function(v) State.autoHideToggle = v end })

-- Status labels
orbStatusLabel = MainTab:CreateParagraph({ Title = "GhostOrb Status", Text = "GhostOrb Status: NOT FOUND" })
handprintStatusLabel = MainTab:CreateParagraph({ Title = "Handprints Status", Text = "Handprints Status: NOT FOUND" })

task.spawn(function()
    while true do
        task.wait(1)
        local orb = Workspace:FindFirstChild("GhostOrb")
        if orb and orb:IsA("BasePart") then
            orbStatusLabel:Set("GhostOrb Status: FOUND")
        else
            orbStatusLabel:Set("GhostOrb Status: NOT FOUND")
        end

        local hpFolder = Workspace:FindFirstChild("Handprints")
        local foundHandprint = false
        if hpFolder and hpFolder:IsA("Folder") then
            for _, obj in ipairs(hpFolder:GetDescendants()) do
                if obj:IsA("BasePart") then foundHandprint = true; break end
            end
        end
        if foundHandprint then
            handprintStatusLabel:Set("Handprints Status: FOUND")
        else
            handprintStatusLabel:Set("Handprints Status: NOT FOUND")
        end
    end
end)

-- ESP Tab
EspTab:CreateParagraph({ Title = "ESP SETTINGS", Text = "Pengaturan ESP" })
EspTab:CreateButton({ Name = "Full Bright", Callback = function()
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.Brightness = 2
    Lighting.ShadowSoftness = 0
    Lighting.GlobalShadows = false
end })

EspTab:CreateDropdown({ Name = "ESP Types", Options = { "Ghosts", "Players", "Items", "Handprints", "Ghost Orb" }, CurrentOption = {}, Multi = true, Callback = function(v) State.selectedEspTypes = v end })
EspTab:CreateToggle({ Name = "Highlight objects", CurrentValue = false, Callback = function(v) State.espHighlight = v end })
EspTab:CreateToggle({ Name = "Show Tracers", CurrentValue = false, Callback = function(v) State.espTracers = v end })
EspTab:CreateToggle({ Name = "Show Boxes", CurrentValue = false, Callback = function(v) State.espBoxes = v end })
EspTab:CreateToggle({ Name = "Show Names", CurrentValue = false, Callback = function(v) State.espNames = v end })
EspTab:CreateToggle({ Name = "Show Studs", CurrentValue = false, Callback = function(v) State.espStuds = v end })

-- Player Tab
PlayerTab:CreateParagraph({ Title = "PLAYER MODS", Text = "Modifikasi karakter" })
PlayerTab:CreateToggle({ Name = "Noclip", CurrentValue = false, Callback = function(v) State.noclipToggle = v; if v then noclip() else clip() end end })
PlayerTab:CreateToggle({ Name = "WalkSpeed Changer", CurrentValue = false, Callback = function(v) State.walkToggle = v end })
PlayerTab:CreateSlider({ Name = "WalkSpeed", Range = {16, 100}, Increment = 1, CurrentValue = 16, Callback = function(v) State.currentSpeed = v end })

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
cacheGhost()
Luna:Notification({
    Title = "Mizukage System",
    Content = "Demonology loaded!",
    Icon = "verified",
    ImageSource = "Material"
})