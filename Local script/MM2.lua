-- Mizukage Official | TeamMizu🔰 - All rights reserved
-- Game: Murder Mystery 2
-- Script rebuilt by MIZU-OS v14.0
-- ⚠️ WAJIB DIISI: Place ID game Murder Mystery 2

-- LOAD LUNA (WAJIB)
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- BUAT WINDOW UTAMA
local Window = Luna:CreateWindow({
    Name = "Mizukage Official",
    Subtitle = "Murder Mystery 2 - TeamMizu🔰",
    LogoID = "104266190557772",
    LoadingEnabled = true,
    LoadingTitle = "Mizukage System",
    LoadingSubtitle = "by @MizukageOfficial",
    ConfigSettings = {
        RootFolder = nil,
        ConfigFolder = "MizukageHub/MM2"
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
    killAuraToggle = false,
    killAuraRadius = 15,
    autoKillToggle = false,
    autoShootToggle = false,
    predictionToggle = false,
    autoFarmToggle = false,
    autoGrabToggle = false,
    autoFarmAvoidToggle = false,
    autoFarmMethod = "Closest",
    walkToggle = false,
    currentSpeed = 28,
    noclipToggle = false,
    antiAfkToggle = false,
    flingToggle = false,
    antiFlingToggle = false,
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
                if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
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
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end
    end
end)

-- ============================================
-- AUTO GRAB GUN
-- ============================================
local function autograb()
    task.spawn(function()
        while State.autoGrabToggle do
            local gun = workspace:FindFirstChild("GunDrop", true)
            if gun and gun:IsA("BasePart") and root then
                local oldPos = root.CFrame
                root.CFrame = gun.CFrame
                task.wait(0.3)
                root.CFrame = oldPos
                task.wait(1)
            end
            task.wait(0.5)
        end
    end)
end

-- ============================================
-- AUTO SHOOT
-- ============================================
local function autoshoot()
    task.spawn(function()
        while State.autoShootToggle do
            local gun = lp.Character and lp.Character:FindFirstChild("Gun")
            if gun and gun:FindFirstChild("Shoot") then
                local murderer = nil
                local targetHRP = nil
                
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= lp and p.Character then
                        local char = p.Character
                        local isMrd = char:FindFirstChild("Footsteps") or char:FindFirstChild("Sleight") or
                                       char:FindFirstChild("Decoy") or char:FindFirstChild("Ghost") or
                                       char:FindFirstChild("Fake Gun") or char:FindFirstChild("Xray") or
                                       char:FindFirstChild("Haste") or char:FindFirstChild("Trap") or
                                       char:FindFirstChild("Sprint") or char:FindFirstChild("Ninja")
                        if isMrd then
                            targetHRP = char:FindFirstChild("HumanoidRootPart")
                            murderer = char
                            break
                        end
                    end
                end

                if targetHRP and root then
                    local origin = root.Position
                    local direction = (targetHRP.Position - origin)
                    local rayParams = RaycastParams.new()
                    rayParams.FilterDescendantsInstances = {lp.Character, workspace.CurrentCamera}
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    local result = workspace:Raycast(origin, direction, rayParams)

                    if result and result.Instance:IsDescendantOf(murderer) then
                        local finalTargetCFrame = targetHRP.CFrame
                        if State.predictionToggle then
                            local velocity = targetHRP.Velocity
                            local predictionOffset = velocity * 0.15
                            finalTargetCFrame = targetHRP.CFrame + predictionOffset
                        end
                        local args = { root.CFrame, finalTargetCFrame }
                        gun.Shoot:FireServer(unpack(args))
                        task.wait(0.5)
                    end
                end
            end
            task.wait()
        end
    end)
end

-- ============================================
-- KILL AURA
-- ============================================
local function loopkillaura()
    task.spawn(function()
        while State.killAuraToggle do
            local isMurderer = character and (character:FindFirstChild("Footsteps") or character:FindFirstChild("Sleight") or
                                character:FindFirstChild("Decoy") or character:FindFirstChild("Ghost") or
                                character:FindFirstChild("Fake Gun") or character:FindFirstChild("Xray") or
                                character:FindFirstChild("Haste") or character:FindFirstChild("Trap") or
                                character:FindFirstChild("Sprint") or character:FindFirstChild("Ninja"))
            if isMurderer and root then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local targetRoot = plr.Character.HumanoidRootPart
                        local distance = (root.Position - targetRoot.Position).Magnitude
                        if distance <= State.killAuraRadius then
                            local targetPos = root.CFrame:ToWorldSpace(CFrame.new(0, 0, -1.5))
                            targetRoot.CFrame = CFrame.new(targetPos.Position) * targetRoot.CFrame.Rotation
                        end
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end

-- ============================================
-- KILL EVERYONE
-- ============================================
local function killplayers()
    task.spawn(function()
        while State.autoKillToggle do
            local isMurderer = character and (character:FindFirstChild("Footsteps") or character:FindFirstChild("Sleight") or
                                character:FindFirstChild("Decoy") or character:FindFirstChild("Ghost") or
                                character:FindFirstChild("Fake Gun") or character:FindFirstChild("Xray") or
                                character:FindFirstChild("Haste") or character:FindFirstChild("Trap") or
                                character:FindFirstChild("Sprint") or character:FindFirstChild("Ninja"))
            if isMurderer and root then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local targetRoot = plr.Character.HumanoidRootPart
                        local targetPos = root.CFrame:ToWorldSpace(CFrame.new(0, 0, -1.5))
                        targetRoot.CFrame = CFrame.new(targetPos.Position) * targetRoot.CFrame.Rotation
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end

-- ============================================
-- AUTO FARM COINS
-- ============================================
local function autofarm()
    task.spawn(function()
        while State.autoFarmToggle do
            local isMurderer = character and (character:FindFirstChild("Footsteps") or character:FindFirstChild("Sleight") or
                                character:FindFirstChild("Decoy") or character:FindFirstChild("Ghost") or
                                character:FindFirstChild("Fake Gun") or character:FindFirstChild("Xray") or
                                character:FindFirstChild("Haste") or character:FindFirstChild("Trap") or
                                character:FindFirstChild("Sprint") or character:FindFirstChild("Ninja"))
            
            local CoinContainer = workspace:FindFirstChild("CoinContainer", true)
            
            if CoinContainer then
                local currentMurderer = nil
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= lp and p.Character then
                        local char = p.Character
                        if char:FindFirstChild("Footsteps") or char:FindFirstChild("Decoy") or char:FindFirstChild("Sleight") or
                           char:FindFirstChild("Ghost") or char:FindFirstChild("Ninja") or char:FindFirstChild("Fake Gun") or
                           char:FindFirstChild("Xray") or char:FindFirstChild("Haste") or char:FindFirstChild("Trap") or
                           char:FindFirstChild("Sprint") then
                            currentMurderer = char:FindFirstChild("HumanoidRootPart")
                            break
                        end
                    end
                end

                local allCoins = {}
                for _, c in ipairs(CoinContainer:GetChildren()) do
                    if c:IsA("BasePart") and string.find(c.Name, "Coin_Server") then
                        local isDangerous = false
                        if State.autoFarmAvoidToggle and currentMurderer then
                            if (c.Position - currentMurderer.Position).Magnitude < 15 then
                                isDangerous = true
                            end
                        end
                        if not isDangerous then table.insert(allCoins, c) end
                    end
                end

                local targetCoin = nil
                local tweenTime = 1
                local waitTime = 1.1

                if #allCoins > 0 then
                    if State.autoFarmMethod == "Closest" and root then
                        local closestDist = math.huge
                        for _, coin in ipairs(allCoins) do
                            local dist = (root.Position - coin.Position).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                targetCoin = coin
                            end
                        end
                    elseif State.autoFarmMethod == "Randomized" then
                        targetCoin = allCoins[math.random(1, #allCoins)]
                        tweenTime = 3
                        waitTime = 3.1
                    end
                end

                if targetCoin and root then
                    local distance = (root.Position - targetCoin.Position).Magnitude
                    if distance > 10 then
                        tweenTime = tweenTime + 0.5
                        waitTime = waitTime + 0.6
                    elseif distance < 5 then
                        tweenTime = 0.3
                        waitTime = 0.4
                    end

                    local tween = TweenService:Create(root, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), { CFrame = CFrame.new(targetCoin.Position) })
                    tween:Play()

                    local start = tick()
                    local cancelled = false
                    while tick() - start < waitTime do
                        if not State.autoFarmToggle then tween:Cancel(); break end
                        if State.autoFarmAvoidToggle and currentMurderer and not isMurderer then
                            if (root.Position - currentMurderer.Position).Magnitude < 7 then
                                tween:Cancel()
                                cancelled = true
                                break
                            end
                        end
                        task.wait(0.1)
                    end

                    if not cancelled and targetCoin and targetCoin.Parent then
                        targetCoin:Destroy()
                    end
                else
                    task.wait(0.5)
                end
            else
                task.wait(1)
            end
        end
    end)
end

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

local function isMurderObject(obj)
    local child = obj:FindFirstChild("Footsteps") or obj:FindFirstChild("Sleight") or obj:FindFirstChild("Decoy") or
                   obj:FindFirstChild("Ghost") or obj:FindFirstChild("Fake Gun") or obj:FindFirstChild("Xray") or
                   obj:FindFirstChild("Haste") or obj:FindFirstChild("Trap") or obj:FindFirstChild("Sprint") or obj:FindFirstChild("Ninja")
    return child and child:IsA("Folder")
end

local function isSheriffObject(obj)
    return obj.Name == "Gun" and obj:IsA("Tool")
end

local function isPlayerObject(obj)
    if obj:IsA("Model") and obj:FindFirstChild("Head") and obj.Name ~= lp.Name then
        if not isMurderObject(obj) and not isSheriffObject(obj) then return true end
    end
    return false
end

local function isGunObject(obj)
    return obj.Name == "GunDrop" and obj:IsA("BasePart")
end

local function passesDropdownFilter(obj)
    if not State.selectedEspTypes or #State.selectedEspTypes == 0 then return false end
    if contains(State.selectedEspTypes, "Murderer") and isMurderObject(obj) then return true end
    if contains(State.selectedEspTypes, "Sheriff") and isSheriffObject(obj) then return true end
    if contains(State.selectedEspTypes, "Players") and isPlayerObject(obj) then return true end
    if contains(State.selectedEspTypes, "Gun") and isGunObject(obj) then return true end
    return false
end

local function getObjColor(obj)
    if isPlayerObject(obj) then return Color3.fromRGB(0, 255, 0) end
    if isSheriffObject(obj) then return Color3.fromRGB(0, 0, 255) end
    if isMurderObject(obj) then return Color3.fromRGB(255, 0, 0) end
    if isGunObject(obj) then return Color3.fromRGB(0, 0, 255) end
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

local function removeESP(obj)
    if esp[obj] and esp[obj].highlight then
        pcall(function() esp[obj].highlight:Destroy() end)
        esp[obj] = nil
    end
end

local lastUpdate = 0
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastUpdate > 1.5 then
        lastUpdate = now
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj ~= lp.Character and passesDropdownFilter(obj) then
                ensureHighlight(obj)
            end
        end
        local dropgun = workspace:FindFirstChild("GunDrop", true)
        if dropgun and passesDropdownFilter(dropgun) then ensureHighlight(dropgun) end
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

local MainTab = Window:CreateTab({ Name = "Main", Icon = "rocket", ImageSource = "Material", ShowTitle = true })
local EspTab = Window:CreateTab({ Name = "ESP", Icon = "visibility", ImageSource = "Material", ShowTitle = true })
local PlayerTab = Window:CreateTab({ Name = "Player", Icon = "person", ImageSource = "Material", ShowTitle = true })
local MiscTab = Window:CreateTab({ Name = "Misc", Icon = "more_horiz", ImageSource = "Material", ShowTitle = true })

-- Main Tab - Murderer Section
MainTab:CreateParagraph({ Title = "MURDERER", Text = "Fitur untuk murderer" })
MainTab:CreateToggle({ Name = "Kill Aura", CurrentValue = false, Callback = function(v) State.killAuraToggle = v; if v then loopkillaura() end end })
MainTab:CreateSlider({ Name = "Kill Aura Radius", Range = {1, 50}, Increment = 1, CurrentValue = 15, Callback = function(v) State.killAuraRadius = v end })
MainTab:CreateToggle({ Name = "Kill Everyone", CurrentValue = false, Callback = function(v) State.autoKillToggle = v; if v then killplayers() end end })

MainTab:CreateDivider()
MainTab:CreateParagraph({ Title = "SHERIFF", Text = "Fitur untuk sheriff" })
MainTab:CreateToggle({ Name = "Auto Shoot Murder", CurrentValue = false, Callback = function(v) State.autoShootToggle = v; if v then autoshoot() end end })
MainTab:CreateToggle({ Name = "Auto Shoot Prediction", CurrentValue = false, Callback = function(v) State.predictionToggle = v end })

MainTab:CreateDivider()
MainTab:CreateParagraph({ Title = "INNOCENT", Text = "Fitur untuk innocent" })
MainTab:CreateToggle({ Name = "Auto Grab", CurrentValue = false, Callback = function(v) State.autoGrabToggle = v; if v then autograb() end end })

MainTab:CreateDivider()
MainTab:CreateParagraph({ Title = "FARMING", Text = "Auto farm coins" })
MainTab:CreateToggle({ Name = "Auto Farm Coins", CurrentValue = false, Callback = function(v)
    State.autoFarmToggle = v
    if v then
        State.noclipToggle = true
        autofarm()
        noclip()
    else
        State.noclipToggle = false
        clip()
    end
end })
MainTab:CreateToggle({ Name = "Avoid Murder?", CurrentValue = false, Callback = function(v) State.autoFarmAvoidToggle = v end })
MainTab:CreateDropdown({ Name = "Farm Method", Options = { "Closest", "Randomized" }, CurrentOption = {"Closest"}, Callback = function(v) State.autoFarmMethod = v[1] end })

-- ESP Tab
EspTab:CreateParagraph({ Title = "VISUAL", Text = "Pengaturan visual" })
EspTab:CreateButton({ Name = "Full Bright", Callback = function()
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.Brightness = 2
    Lighting.ShadowSoftness = 0
    Lighting.GlobalShadows = false
end })
EspTab:CreateDropdown({ Name = "ESP Types", Options = { "Murderer", "Sheriff", "Players", "Gun" }, CurrentOption = {}, Multi = true, Callback = function(v) State.selectedEspTypes = v end })
EspTab:CreateToggle({ Name = "Highlight objects", CurrentValue = false, Callback = function(v) State.espHighlight = v end })

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
-- GLITCH PROOF REMOVER
-- ============================================
task.spawn(function()
    while true do
        task.wait(1)
        local target = workspace:FindFirstChild("GlitchProof", true)
        if target then target:Destroy() end
    end
end)

-- ============================================
-- INITIALIZATION
-- ============================================
Luna:Notification({
    Title = "Mizukage System",
    Content = "Murder Mystery 2 loaded!",
    Icon = "verified",
    ImageSource = "Material"
})