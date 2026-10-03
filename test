-- // FF3 Script | 67 FF3 | discord.gg/67scripts
-- // UI: xsx (github.com/Eazvy/UILibs/blob/main/Librarys/Xsx/Example)

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Consistt/Ui/main/UnLeaked"))()

library.rank = "developer"
library.title = "67 FF3"

local Wm = library:Watermark("67 FF3 | v" .. library.version .. " | " .. library:GetUsername() .. " | rank: " .. library.rank)
local FpsWm = Wm:AddWatermark("fps: " .. library.fps)
coroutine.wrap(function()
    while wait(0.75) do
        FpsWm:Text("fps: " .. library.fps)
    end
end)()

local Notif = library:InitNotifications()
local LoadingNotif = Notif:Notify("Loading 67 FF3...", 5, "information")

library:Introduction()
wait(1)
local Init = library:Init()

-- // Services
local players       = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService  = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local runService    = game:GetService("RunService")
local stats         = game:GetService("Stats")
local camera        = workspace.CurrentCamera
local lp            = players.LocalPlayer
if not lp then
    players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    lp = players.LocalPlayer
end
local mouse = lp:GetMouse()
local isPractice = (game.PlaceId == 81310542478972)

-- ============================================================
-- // QB AIMBOT TAB
-- ============================================================
local ThrowingTab = Init:NewTab("QB Aimbot")
local ThrowingSection = ThrowingTab:NewSection("Aimbot Settings")

local enableQbAimbot = ThrowingTab:NewToggle("Enable QB Aimbot", false, function(v) end)
local throwAimbot = ThrowingTab:NewToggle("Throw To Mouse Aimbot", false, function(v) end)
local autoChooseWr = ThrowingTab:NewToggle("Auto Choose Open Receiver", false, function(v) end)
local autoSelectThrowMode = ThrowingTab:NewToggle("Auto Select Throw Type", false, function(v) end)
local autoPower = ThrowingTab:NewToggle("Auto Power", false, function(v) end)
local autoAngle = ThrowingTab:NewToggle("Auto Angle", false, function(v) end)
local highPowerOnly = ThrowingTab:NewToggle("High Power Only", false, function(v) end)
local antiDB = ThrowingTab:NewToggle("Anti DB", false, function(v) end)
local antiOOB = ThrowingTab:NewToggle("Anti OOB", false, function(v) end)
local autoJuke = ThrowingTab:NewToggle("Auto Juke Rusher", isPractice and false or false, function(v) end)
local hideCards = ThrowingTab:NewToggle("Hide QB Aimbot Cards", false, function(v) end)
local autoChangePowerUI = ThrowingTab:NewToggle("Auto Change Power UI", false, function(v) end)
local autoJumpWhenThrow = ThrowingTab:NewToggle("Auto Jump Before Throw", false, function(v) end)
local autoThrowAfterSack = ThrowingTab:NewToggle("Auto Throw Before Getting Sacked", false, function(v) end)

local antiDBThreshold   = ThrowingTab:NewSlider("Anti DB Threshold", "", false, "/", {min=0, max=15, default=0}, function(v) end)
local antiOOBThreshold  = ThrowingTab:NewSlider("Anti OOB Threshold", "", false, "/", {min=0, max=15, default=0}, function(v) end)
local throwLeadOffset   = ThrowingTab:NewSlider("Throw Lead Offset", "", false, "/", {min=-10, max=10, default=0}, function(v) end)
local throwHeightOffset = ThrowingTab:NewSlider("Throw Height Offset", "", false, "/", {min=-10, max=10, default=0}, function(v) end)

local dimeKeybind       = ThrowingTab:NewKeybind("Dime Mode Keybind",     Enum.KeyCode.One,   function() end)
local magKeybind        = ThrowingTab:NewKeybind("Mag Mode Keybind",      Enum.KeyCode.Two,   function() end)
local diveKeybind       = ThrowingTab:NewKeybind("Dive Mode Keybind",     Enum.KeyCode.Three, function() end)
local jumpKeybind       = ThrowingTab:NewKeybind("Jump Mode Keybind",     Enum.KeyCode.Four,  function() end)
local bulletKeybind     = ThrowingTab:NewKeybind("Bullet Mode Keybind",   Enum.KeyCode.Five,  function() end)
local throwBallAwayKeybind  = ThrowingTab:NewKeybind("Throw Ball Away Keybind",    Enum.KeyCode.T, function() end)
local increaseAngleKeybind  = ThrowingTab:NewKeybind("Increase Angle Keybind",     Enum.KeyCode.R, function() end)
local decreaseAngleKeybind  = ThrowingTab:NewKeybind("Decrease Angle Keybind",     Enum.KeyCode.F, function() end)
local lockKeybind           = ThrowingTab:NewKeybind("Lock To Target Keybind",     Enum.KeyCode.Z, function() end)

-- xsx keybind wrapper: .Value holds the current key
local function keybindValue(kb)
    return { Value = kb }
end
-- For xsx NewKeybind, the returned object IS the keybind; wrap for .Value access
-- xsx returns the object; we alias .Value via metatable shim below each keybind
local function wrapKeybind(kbObj, default)
    return setmetatable({}, {
        __index = function(_, k)
            if k == "Value" then
                -- xsx stores current key internally; read from stored default if no API
                return default
            end
            return kbObj[k]
        end
    })
end

-- Shim .Value onto toggle objects (xsx NewToggle state is internal)
local function toggleVal(tObj, default)
    local state = default or false
    tObj:SetFunction(function(v) state = v end)
    return setmetatable({}, {
        __index = function(_, k)
            if k == "Value" then return state end
            return tObj[k]
        end,
        __newindex = function(_, k, v)
            if k == "Value" then state = v end
        end
    })
end

local function sliderVal(sObj, default)
    local val = default or 0
    sObj:SetFunction(function(v) val = v end)  -- note: xsx uses callback on create; re-wire here
    return setmetatable({}, {
        __index = function(_, k)
            if k == "Value" then return val end
            return sObj[k]
        end,
        __newindex = function(_, k, v)
            if k == "Value" then val = v end
        end
    })
end

-- // Rewrap all controls so the logic below reads .Value correctly
enableQbAimbot      = toggleVal(enableQbAimbot, false)
throwAimbot         = toggleVal(throwAimbot, false)
autoChooseWr        = toggleVal(autoChooseWr, false)
autoSelectThrowMode = toggleVal(autoSelectThrowMode, false)
autoPower           = toggleVal(autoPower, false)
autoAngle           = toggleVal(autoAngle, false)
highPowerOnly       = toggleVal(highPowerOnly, false)
antiDB              = toggleVal(antiDB, false)
antiOOB             = toggleVal(antiOOB, false)
autoJuke            = toggleVal(autoJuke, false)
hideCards           = toggleVal(hideCards, false)
autoChangePowerUI   = toggleVal(autoChangePowerUI, false)
autoJumpWhenThrow   = toggleVal(autoJumpWhenThrow, false)
autoThrowAfterSack  = toggleVal(autoThrowAfterSack, false)

antiDBThreshold     = sliderVal(antiDBThreshold, 0)
antiOOBThreshold    = sliderVal(antiOOBThreshold, 0)
throwLeadOffset     = sliderVal(throwLeadOffset, 0)
throwHeightOffset   = sliderVal(throwHeightOffset, 0)

-- Keybind .Value shims (store defaults; xsx doesn't expose current key via property)
local _dimeKey   = Enum.KeyCode.One
local _magKey    = Enum.KeyCode.Two
local _diveKey   = Enum.KeyCode.Three
local _jumpKey   = Enum.KeyCode.Four
local _bulletKey = Enum.KeyCode.Five
local _throwAwayKey = Enum.KeyCode.T
local _incAngleKey  = Enum.KeyCode.R
local _decAngleKey  = Enum.KeyCode.F
local _lockKey      = Enum.KeyCode.Z

dimeKeybind         = { Value = _dimeKey }
magKeybind          = { Value = _magKey }
diveKeybind         = { Value = _diveKey }
jumpKeybind         = { Value = _jumpKey }
bulletKeybind       = { Value = _bulletKey }
throwBallAwayKeybind = { Value = _throwAwayKey }
increaseAngleKeybind = { Value = _incAngleKey }
decreaseAngleKeybind = { Value = _decAngleKey }
lockKeybind          = { Value = _lockKey }

-- ============================================================
-- // CATCHING TAB
-- ============================================================
local CatchingTab = Init:NewTab("Catching")
local CatchingSection = CatchingTab:NewSection("Catching Settings")

local footballMagnets   = toggleVal(CatchingTab:NewToggle("Enable Football Magnets",   false, function() end), false)
local freeFallCheck     = toggleVal(CatchingTab:NewToggle("Magnets Freefall Check",    false, function() end), false)
local showCatchHitbox   = toggleVal(CatchingTab:NewToggle("Show Magnets Radius",       false, function() end), false)
local magnetsRadius     = sliderVal(CatchingTab:NewSlider("Magnets Catch Distance", "", false, "/", {min=0, max=25, default=0}, function() end), 0)
local magnetsDelay      = sliderVal(CatchingTab:NewSlider("Magnets Catch Delay",    "", false, "/", {min=0, max=1,  default=0}, function() end), 0)

local magsTypeOptions = {"Custom", "Blatant", "League", "Legit"}
local magsTypeVal = "Custom"
CatchingTab:NewSelector("Magnets Type", "Custom", magsTypeOptions, function(v) magsTypeVal = v end)
local magsType = { Value = magsTypeVal }
setmetatable(magsType, { __index = function(_, k) if k == "Value" then return magsTypeVal end end })

local magEnhancer       = toggleVal(CatchingTab:NewToggle("Enable Mag Enhancer",   false, function() end), false)
local magEnhancerRadius = sliderVal(CatchingTab:NewSlider("Mag Catch Distance",  "", false, "/", {min=0, max=25, default=0}, function() end), 0)
local magEnhancerMaxAngle = sliderVal(CatchingTab:NewSlider("Mag Max Angle",     "", false, "/", {min=50, max=70, default=50}, function() end), 50)

local pullVector        = toggleVal(CatchingTab:NewToggle("Enable Pull Vector",    false, function() end), false)
local pullVectorRadius  = sliderVal(CatchingTab:NewSlider("Pull Vector Radius", "", false, "/", {min=0, max=45, default=0}, function() end), 0)
local pullVectorPower   = sliderVal(CatchingTab:NewSlider("Pull Vector Power",  "", false, "/", {min=0, max=5,  default=0}, function() end), 0)

local increaseArmSize   = toggleVal(CatchingTab:NewToggle("Increase Arm Size",  false, function() end), false)
local armSizeValue      = sliderVal(CatchingTab:NewSlider("Arm Size Value",  "", false, "/", {min=2, max=25, default=2}, function() end), 2)

-- ============================================================
-- // PLAYER TAB
-- ============================================================
local PlayerTab = Init:NewTab("Player")
local PlayerSection = PlayerTab:NewSection("Player Settings")

local customWalkSpeed   = toggleVal(PlayerTab:NewToggle("Custom WalkSpeed",  false, function() end), false)
local walkSpeedValue    = sliderVal(PlayerTab:NewSlider("WalkSpeed Value", "", false, "/", {min=20, max=23, default=20}, function() end), 20)

local wsTypeOptions = {"Normal", "CFrame"}
local wsTypeVal = "Normal"
PlayerTab:NewSelector("WalkSpeed Type", "Normal", wsTypeOptions, function(v) wsTypeVal = v end)
local walkspeedType = setmetatable({}, { __index = function(_, k) if k == "Value" then return wsTypeVal end end })

local customJumpPower   = toggleVal(PlayerTab:NewToggle("Custom JumpPower",  false, function() end), false)
local jumpPowerValue    = sliderVal(PlayerTab:NewSlider("JumpPower Value", "", false, "/", {min=50, max=70, default=50}, function() end), 50)

local angleEnhancer         = toggleVal(PlayerTab:NewToggle("Angle Enhancer",           false, function() end), false)
local angleEnhancerIndicator= toggleVal(PlayerTab:NewToggle("Angle Enhancer Indicator", false, function() end), false)
local autoFlip              = toggleVal(PlayerTab:NewToggle("Auto Flip Before Landing",  false, function() end), false)
local angleEnhanceBoost     = sliderVal(PlayerTab:NewSlider("Angle Boost Value", "", false, "/", {min=50, max=70, default=50}, function() end), 50)

PlayerTab:NewButton("Unlock All Gamepass", function()
    local replicatedFirst = game:GetService("ReplicatedFirst")
    local module
    local success = pcall(function()
        module = require(replicatedFirst:FindFirstChild("LocalSave"))
    end)
    if not success or not module then return end
    module.PlayerOwnsPass = function(a, b) return true end
end)

-- ============================================================
-- // PHYSICS TAB
-- ============================================================
local PhysicsTab = Init:NewTab("Physics")
local PhysicsSection = PhysicsTab:NewSection("Physics Settings")

local boundaries = {}
if not isPractice then
    for _, v in next, workspace.Models.Boundaries:GetChildren() do
        boundaries[#boundaries + 1] = v
    end
end

local antiBoundaries = toggleVal(PhysicsTab:NewToggle("Anti OOB", false, function(v)
    for _, b in next, boundaries do
        if b then b.Parent = not v and workspace.Models.Boundaries or nil end
    end
end), false)

local antiBench     = toggleVal(PhysicsTab:NewToggle("Anti Bench",          false, function() end), false)
local antiJam       = toggleVal(PhysicsTab:NewToggle("Anti Jam",            false, function() end), false)
local antiJumpCooldown = toggleVal(PhysicsTab:NewToggle("Anti Jump Cooldown", false, function() end), false)
local antiFreeze    = toggleVal(PhysicsTab:NewToggle("Anti Freeze",         false, function() end), false)
local antiBlock     = toggleVal(PhysicsTab:NewToggle("Anti Block",          false, function() end), false)
local quickTP       = toggleVal(PhysicsTab:NewToggle("Quick TP",            false, function() end), false)
local quickTPPower  = sliderVal(PhysicsTab:NewSlider("Quick TP Power",  "", false, "/", {min=0, max=5, default=0}, function() end), 0)
local bigHead       = toggleVal(PhysicsTab:NewToggle("Big Head Players",    false, function() end), false)
local bigHeadSize   = sliderVal(PhysicsTab:NewSlider("Big Head Size",   "", false, "/", {min=1, max=6, default=1}, function() end), 1)

local HideKeybind = { Value = Enum.KeyCode.Q }
PhysicsTab:NewKeybind("Quick TP Keybind", Enum.KeyCode.Q, function(key)
    HideKeybind = { Value = Enum.KeyCode[key] }
end)

-- ============================================================
-- // VISUAL TAB
-- ============================================================
local VisualTab = Init:NewTab("Visual")
local VisualSection = VisualTab:NewSection("Visual Settings")

local jumpSpot      = toggleVal(VisualTab:NewToggle("Visualise Football Jump Spot",  false, function() end), false)
local throwSpot     = toggleVal(VisualTab:NewToggle("Visualise Football Throw Spot", false, function() end), false)
local enableGloves  = toggleVal(VisualTab:NewToggle("Enable Uniform Gloves",         true,  function() end), true)
local noBallTrail   = toggleVal(VisualTab:NewToggle("No Ball Trail",                 false, function() end), false)

local stadiumParts = {}
for _, v in next, workspace.Models.Stadium:GetDescendants() do
    if not v:IsA("BasePart") then continue end
    stadiumParts[#stadiumParts + 1] = { Part = v, Transparency = v.Transparency, CanCollide = v.CanCollide }
end

local hideStadium = toggleVal(VisualTab:NewToggle("Hide Stadium", false, function(v)
    for _, p in next, stadiumParts do
        p.Part.Transparency = v and 1 or p.Transparency
        p.Part.CanCollide   = v and false or p.CanCollide
    end
end), false)

local lighting = game:GetService("Lighting")
local function ApplySkyBox(name)
    for _, v in next, lighting:GetChildren() do
        if v:IsA("Sky") or v:IsA("PostEffect") or v:IsA("Atmosphere") then v:Destroy() end
    end
    if name == "Golden Twilight" then
        local s = Instance.new("Sky"); s.Name = name; s.Parent = lighting
        s.SkyboxBk = "rbxassetid://541743453"; s.SkyboxDn = "rbxassetid://541743443"
        s.SkyboxFt = "rbxassetid://541743446"; s.SkyboxLf = "rbxassetid://541743436"
        s.SkyboxRt = "rbxassetid://541743435"; s.SkyboxUp = "rbxassetid://541743441"
    elseif name == "Infernal Horizon" then
        local s = Instance.new("Sky"); s.Name = name; s.Parent = lighting
        s.SkyboxBk = "http://www.roblox.com/asset/?id=169210090"
        s.SkyboxDn = "http://www.roblox.com/asset/?id=169210108"
        s.SkyboxFt = "http://www.roblox.com/asset/?id=169210121"
        s.SkyboxLf = "http://www.roblox.com/asset/?id=169210133"
        s.SkyboxRt = "http://www.roblox.com/asset/?id=169210143"
        s.SkyboxUp = "http://www.roblox.com/asset/?id=169210149"
        s.StarCount = 100; s.SunTextureId = " "
        local b = Instance.new("BlurEffect"); b.Parent = lighting; b.Size = 6
        local cc = Instance.new("ColorCorrectionEffect"); cc.Parent = lighting
        cc.Brightness = 0.01; cc.Contrast = 0.15; cc.Saturation = 0.4
        cc.TintColor = Color3.new(0.815686, 0.776471, 0.690196)
    elseif name == "Nebula Peaks" then
        local s = Instance.new("Sky"); s.Name = name; s.Parent = lighting
        s.CelestialBodiesShown = false
        s.SkyboxBk = "http://www.roblox.com/asset/?id=17124357467"
        s.SkyboxDn = "http://www.roblox.com/asset/?id=17124359797"
        s.SkyboxFt = "http://www.roblox.com/asset/?id=17124362093"
        s.SkyboxLf = "http://www.roblox.com/asset/?id=17124365127"
        s.SkyboxRt = "http://www.roblox.com/asset/?id=17124367200"
        s.SkyboxUp = "http://www.roblox.com/asset/?id=17124369657"
        local cc = Instance.new("ColorCorrectionEffect"); cc.Parent = lighting
        cc.Brightness = 0.1; cc.Contrast = 0.3; cc.Saturation = 0.2
        cc.TintColor = Color3.fromRGB(140, 190, 255)
        local bloom = Instance.new("BloomEffect"); bloom.Parent = lighting
        bloom.Intensity = 1.2; bloom.Threshold = 0.8; bloom.Size = 56
        local atm = Instance.new("Atmosphere"); atm.Parent = lighting
        atm.Density = 0.25; atm.Offset = 0.2; atm.Glare = 0.3; atm.Haze = 1
        atm.Color = Color3.fromRGB(80, 110, 150); atm.Decay = Color3.fromRGB(25, 30, 35)
    elseif name == "Rose Glow" then
        local s = Instance.new("Sky"); s.Name = name; s.Parent = lighting
        s.CelestialBodiesShown = false
        s.SkyboxBk = "http://www.roblox.com/asset/?id=109305193"
        s.SkyboxDn = "http://www.roblox.com/asset?id=58372722"
        s.SkyboxFt = "http://www.roblox.com/asset/?id=109305200"
        s.SkyboxLf = "http://www.roblox.com/asset/?id=109305185"
        s.SkyboxRt = "http://www.roblox.com/asset/?id=109305189"
        s.SkyboxUp = "http://www.roblox.com/asset/?id=109305207"
    elseif name == "Night Sky" then
        local s = Instance.new("Sky"); s.Name = name; s.Parent = lighting
        s.CelestialBodiesShown = false
        s.SkyboxBk = "http://www.roblox.com/Asset/?ID=12064107"
        s.SkyboxDn = "http://www.roblox.com/Asset/?ID=12064152"
        s.SkyboxFt = "http://www.roblox.com/Asset/?ID=12064121"
        s.SkyboxLf = "http://www.roblox.com/Asset/?ID=12063984"
        s.SkyboxRt = "http://www.roblox.com/Asset/?ID=12064115"
        s.SkyboxUp = "http://www.roblox.com/Asset/?ID=12064131"
        s.StarCount = 0
    elseif name == "Northern Lights" then
        local s = Instance.new("Sky"); s.Name = name; s.Parent = lighting
        s.CelestialBodiesShown = false
        s.SkyboxBk = "http://www.roblox.com/asset/?id=16563478983"
        s.SkyboxDn = "http://www.roblox.com/asset/?id=16563481302"
        s.SkyboxFt = "http://www.roblox.com/asset/?id=16563484084"
        s.SkyboxLf = "http://www.roblox.com/asset/?id=16563485362"
        s.SkyboxRt = "http://www.roblox.com/asset/?id=16563487078"
        s.SkyboxUp = "http://www.roblox.com/asset/?id=16563489821"
    end
end

for _, skyName in next, {"Golden Twilight","Infernal Horizon","Nebula Peaks","Rose Glow","Night Sky","Northern Lights"} do
    VisualTab:NewButton(skyName, function() ApplySkyBox(skyName) end)
end

-- ============================================================
-- // DEFENSE TAB
-- ============================================================
local DefenseTab = Init:NewTab("Defense")
local DefenseSection = DefenseTab:NewSection("Defense Settings")

local swatReach         = toggleVal(DefenseTab:NewToggle("Swat Reach",          false, function() end), false)
local swatReachDistance = sliderVal(DefenseTab:NewSlider("Swat Reach Radius", "", false, "/", {min=0, max=25, default=0}, function() end), 0)
local tackleReach       = toggleVal(DefenseTab:NewToggle("Extend Tackle Reach", false, function() end), false)
local tackleAimbot      = toggleVal(DefenseTab:NewToggle("Tackle Aimbot",       false, function() end), false)
local tackleAimbotRange = sliderVal(DefenseTab:NewSlider("Tackle Aimbot Distance", "", false, "/", {min=0, max=25, default=0}, function() end), 0)

-- ============================================================
-- // AUTOMATICS TAB
-- ============================================================
local AutomaticsTab = Init:NewTab("Automatics")
local AutomaticsSection = AutomaticsTab:NewSection("Automatics Settings")

local autoRush              = toggleVal(AutomaticsTab:NewToggle("Auto Rush",                    false, function() end), false)
local walkToLine            = toggleVal(AutomaticsTab:NewToggle("Walk To Line",                 false, function() end), false)
local autoRushReactionTime  = sliderVal(AutomaticsTab:NewSlider("Reaction Time",  "", false, "/", {min=0, max=1, default=0.15}, function() end), 0.15)
local autoCatch             = toggleVal(AutomaticsTab:NewToggle("Auto Catch",                   false, function() end), false)
local autoCatchRadius       = sliderVal(AutomaticsTab:NewSlider("Auto Catch Distance", "", false, "/", {min=0, max=25, default=0}, function() end), 0)
local autoSwat              = toggleVal(AutomaticsTab:NewToggle("Auto Swat",                    false, function() end), false)
local autoSwatRadius        = sliderVal(AutomaticsTab:NewSlider("Auto Swat Distance", "", false, "/", {min=0, max=25, default=0}, function() end), 0)
local autoCaptain           = toggleVal(AutomaticsTab:NewToggle("Auto Win Captain",             false, function() end), false)
local autoFreeze            = toggleVal(AutomaticsTab:NewToggle("Auto Freeze",                  false, function() end), false)
local freezeDuration        = sliderVal(AutomaticsTab:NewSlider("Freeze Duration", "", false, "/", {min=0, max=3, default=0}, function() end), 0)
local autoQb                = toggleVal(AutomaticsTab:NewToggle("Auto QB",                      false, function() end), false)
local autoBoost             = toggleVal(AutomaticsTab:NewToggle("Auto Boost",                   false, function() end), false)
local targetClosestPlayer   = toggleVal(AutomaticsTab:NewToggle("Target Player Closer To Ball", false, function() end), false)
local boostStrength         = sliderVal(AutomaticsTab:NewSlider("Boost Strength", "", false, "/", {min=0, max=3,   default=1.5}, function() end), 1.5)
local boostRadius           = sliderVal(AutomaticsTab:NewSlider("Boost Radius",   "", false, "/", {min=0, max=15,  default=0},   function() end), 0)
local boostPower            = sliderVal(AutomaticsTab:NewSlider("Boost Power",    "", false, "/", {min=50, max=70, default=50},  function() end), 50)

local freezeKeybindVal = nil
AutomaticsTab:NewKeybind("Freeze Keybind", Enum.KeyCode.Unknown, function(key)
    freezeKeybindVal = Enum.KeyCode[key]
end)
local freezeKeybind = setmetatable({}, { __index = function(_, k) if k == "Value" then return freezeKeybindVal end end })

local aqbTypeOptions = {"Walk", "Teleport"}
local aqbTypeVal = "Walk"
AutomaticsTab:NewSelector("Auto QB Method", "Walk", aqbTypeOptions, function(v) aqbTypeVal = v end)
local autoQbMethod = setmetatable({}, { __index = function(_, k) if k == "Value" then return aqbTypeVal end end })

-- ============================================================
-- // MISC TAB
-- ============================================================
local MiscTab = Init:NewTab("Misc")
local MiscSection = MiscTab:NewSection("Misc Settings")

local fpsCapVal = 240
local fpsCap = MiscTab:NewSlider("Uncap FPS Amount", "", false, "/", {min=30, max=240, default=240}, function(v) fpsCapVal = v end)
fpsCap = setmetatable({}, { __index = function(_, k) if k == "Value" then return fpsCapVal end end })

local antiAdmin     = toggleVal(MiscTab:NewToggle("Anti Admin",    false, function() end), false)
local smoothReplay  = toggleVal(MiscTab:NewToggle("Smooth Replay", false, function() end), false)
local replayFPSVal  = 9
local replayFPSObj  = MiscTab:NewSlider("Replay Frame Per Second", "", false, "/", {min=9, max=120, default=9}, function(v) replayFPSVal = v end)
local replayFPS     = setmetatable({}, { __index = function(_, k) if k == "Value" then return replayFPSVal end end })

-- ============================================================
-- // ALL ORIGINAL LOGIC BELOW — UNMODIFIED
-- ============================================================

local targetLocked = false
local lockedTarget = nil
local RouteData = {}
local HUDCards = {}
local rusherHighlights = {}
local numCards = 0

local leadDime = 8.5; local leadMag = 8.6; local leadDive = 8.5
local leadJump = 8.4; local leadBullet = 2.5
local yLeadDime = 1.2; local yLeadMag = 1.0; local yLeadDive = 1.5
local yLeadJump = 2.0; local yLeadBullet = -0.8
local ModeOrder = {"Bullet","Dime","Dive","Jump","Mag"}

local QBKeybinds = {
    [dimeKeybind.Value]   = "Dime",
    [magKeybind.Value]    = "Mag",
    [diveKeybind.Value]   = "Dive",
    [jumpKeybind.Value]   = "Jump",
    [bulletKeybind.Value] = "Bullet"
}

local customHeight = { Value = 0 }
local target = nil; local lastValidTarget = nil; local targetLeadPos = nil
local highlight = nil; local direction = Vector3.new(0,1,0)
local power = 60; local angle = 45; local airtime = 0
local isThrowing = false; local isThrowingAway = false; local firedRemote = false
local modeIndex = 1; local smoothedJukeDir = Vector3.zero
local lockedMousePos = nil; local LockToggleBtn = nil; local LockedLabel = nil

local attach0 = Instance.new("Attachment", workspace.Terrain)
local attach1 = Instance.new("Attachment", workspace.Terrain)
local beam = Instance.new("Beam")
beam.Attachment0 = attach0; beam.Attachment1 = attach1
beam.Segments = 7500; beam.Width0 = 1; beam.Width1 = 1; beam.FaceCamera = true
beam.Color = ColorSequence.new(Color3.fromRGB(255,255,255))
beam.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,1),
    NumberSequenceKeypoint.new(0.01,0),
    NumberSequenceKeypoint.new(1,0)
})
beam.Enabled = true; beam.Parent = workspace.Terrain

local posPart = Instance.new("Part", workspace.Terrain)
posPart.Anchored = true; posPart.CanCollide = false; posPart.CastShadow = false
posPart.Size = Vector3.new(3,3,3); posPart.Shape = Enum.PartType.Ball
posPart.Color = Color3.fromRGB(0,0,0)

local hudFolder = nil
pcall(function() hudFolder = (gethui and gethui()) or game:GetService("CoreGui") end)
if not hudFolder or (hudFolder.Name == "CoreGui" and not pcall(function() Instance.new("Folder",hudFolder):Destroy() end)) then
    hudFolder = lp:WaitForChild("PlayerGui", 10)
end

local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false; sg.Parent = hudFolder; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local container = Instance.new("CanvasGroup")
container.Size = UDim2.new(1,0,0,100); container.Position = UDim2.new(0.5,0,0.05,0)
container.AnchorPoint = Vector2.new(0.5,0); container.BackgroundTransparency = 1
container.GroupTransparency = 1; container.Visible = true; container.Parent = sg

local hudVisible = false
local updateHUDVisibility = function(show)
    if show and not hudVisible then
        hudVisible = true
        tweenService:Create(container, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {GroupTransparency=0}):Play()
    elseif not show and hudVisible then
        hudVisible = false
        tweenService:Create(container, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {GroupTransparency=1}):Play()
    end
end

local containerScale = Instance.new("UIScale", container)
local updateScale = function()
    local vp = camera.ViewportSize
    containerScale.Scale = math.clamp(vp.X/1100, 0.5, 1.2)
end
camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale); updateScale()

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,10); layout.Parent = container

local assignFont = function(inst, font) pcall(function() inst.Font = font end) end

local createCard = function(titleTxt)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = Color3.fromRGB(255,255,255); card.BackgroundTransparency = 0; card.BorderSizePixel = 0
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(45,45,50)),ColorSequenceKeypoint.new(1,Color3.fromRGB(15,15,18))})
    gradient.Rotation = 90; gradient.Parent = card
    card.Size = (titleTxt == "Throw Type") and UDim2.new(0,110,0,80) or UDim2.new(0,95,0,80)
    card.LayoutOrder = numCards; card.Parent = container
    local corner = Instance.new("UICorner",card); corner.CornerRadius = UDim.new(0,8)
    local stroke = Instance.new("UIStroke",card); stroke.Color = Color3.fromRGB(80,80,85); stroke.Thickness = 1
    local padding = Instance.new("UIPadding",card); padding.PaddingTop = UDim.new(0,5); padding.PaddingBottom = UDim.new(0,5)
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1; title.BorderSizePixel = 0
    title.Position = UDim2.new(0,0,0.70,0); title.Size = UDim2.new(1,0,0,15)
    assignFont(title, Enum.Font.GothamBold); title.Text = titleTxt
    title.TextColor3 = Color3.fromRGB(255,255,255); title.TextScaled = true; title.Parent = card
    local valBtn = Instance.new("TextButton")
    valBtn.BackgroundTransparency = 1; valBtn.BorderSizePixel = 0
    valBtn.Position = UDim2.new(0,0,0.15,0); valBtn.Size = UDim2.new(1,0,0.5,0)
    assignFont(valBtn, Enum.Font.GothamBold); valBtn.Text = "-"
    valBtn.TextColor3 = Color3.fromRGB(255,255,255); valBtn.TextScaled = true
    valBtn.AutoButtonColor = false; valBtn.Parent = card
    if titleTxt == "Throw Type" then
        local uiScale = Instance.new("UIScale",card)
        valBtn.MouseButton1Down:Connect(function()
            local c = lp.Character; if not c or not c:FindFirstChild("Football") then return end
            tweenService:Create(uiScale,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Scale=0.9}):Play()
        end)
        valBtn.MouseButton1Up:Connect(function()
            local c = lp.Character; if not c or not c:FindFirstChild("Football") then return end
            tweenService:Create(uiScale,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Scale=1}):Play()
            modeIndex = modeIndex + 1; if modeIndex > #ModeOrder then modeIndex = 1 end
        end)
    end
    if titleTxt == "Player" then
        local lockedLbl = Instance.new("TextLabel")
        lockedLbl.Size = UDim2.new(1,0,0.25,0); lockedLbl.Position = UDim2.new(0,0,0.05,0)
        lockedLbl.BackgroundTransparency = 1; lockedLbl.Text = "LOCKED"
        lockedLbl.TextColor3 = Color3.fromRGB(255,50,50)
        assignFont(lockedLbl, Enum.Font.GothamBold); lockedLbl.TextSize = 12
        lockedLbl.Visible = false; lockedLbl.ZIndex = 2; lockedLbl.Parent = card
        LockedLabel = lockedLbl
        local lockOverlay = Instance.new("TextButton")
        lockOverlay.Size = UDim2.new(1,0,1,0); lockOverlay.BackgroundTransparency = 1
        lockOverlay.Text = ""; lockOverlay.ZIndex = 5; lockOverlay.Parent = card
        lockOverlay.MouseButton1Click:Connect(function()
            local c = lp.Character; if not c or not c:FindFirstChild("Football") then return end
            if target or targetLocked then
                targetLocked = not targetLocked
                if targetLocked then lockedTarget = target; if LockedLabel then LockedLabel.Visible = true end
                else lockedTarget = nil; if LockedLabel then LockedLabel.Visible = false end end
            end
        end)
        LockToggleBtn = valBtn
    end
    HUDCards[titleTxt] = valBtn; numCards = numCards + 1
end

createCard("Angle"); createCard("Throw Type"); createCard("Player"); createCard("Airtime"); createCard("Power")

local getActiveBots = function()
    local bots = {}
    local npcwr = workspace:FindFirstChild("npcwr")
    if npcwr then
        local a = npcwr:FindFirstChild("a"); if a then local b1 = a:FindFirstChild("bot 1"); if b1 and b1:IsA("Model") then table.insert(bots,b1) end end
        local b = npcwr:FindFirstChild("b"); if b then local b3 = b:FindFirstChild("bot 3"); if b3 and b3:IsA("Model") then table.insert(bots,b3) end end
    end
    return bots
end

local performThrow = function()
    if not enableQbAimbot.Value then return end
    local character = lp.Character; if not character then return end
    local football = character:FindFirstChildOfClass("Tool"); if not football then return end
    local handle = football:FindFirstChild("Handle"); if not handle then return end
    local remote = handle:FindFirstChild("RemoteEvent"); if not remote then return end
    local head = character:FindFirstChild("Head"); if not head then return end
    local root = character:FindFirstChild("HumanoidRootPart"); if not root then return end
    local finalDirection = direction or Vector3.new(0,1,0)
    if isPractice then
        remote:FireServer("Clicked", head.Position, head.Position + finalDirection*10000, tonumber(power) or 0)
    else
        remote:FireServer("Clicked", (root.CFrame*CFrame.new(0,1.5,0)).Position+Vector3.new(70000000), head.Position+finalDirection*10000, tonumber(power) or 0, 1)
    end
end

local findRoute = function(character)
    if not character then return "stationary", Vector3.zero end
    local isPlayer = players:GetPlayerFromCharacter(character)
    local humanoid = character:FindFirstChild("Humanoid")
    local targetHRP = character:FindFirstChild("HumanoidRootPart")
    local qbChar = lp.Character
    local qbHRP = qbChar and qbChar:FindFirstChild("HumanoidRootPart")
    if not humanoid or not targetHRP or not qbHRP then return "stationary", Vector3.zero end
    local moveDirection = Vector3.zero
    if isPlayer then moveDirection = humanoid.MoveDirection
    else
        local wtpDiff = humanoid.WalkToPoint - targetHRP.Position
        moveDirection = wtpDiff.Magnitude > 0.01 and wtpDiff.Unit or Vector3.zero
    end
    local toWR = targetHRP.Position - qbHRP.Position
    local distance = tonumber(toWR.Magnitude) or 0
    local toWRDir = Vector3.new(toWR.X,0,toWR.Z)
    if toWRDir.Magnitude > 0.01 then toWRDir = toWRDir.Unit else toWRDir = Vector3.new(0,0,1) end
    local mdFlat = Vector3.new(moveDirection.X,0,moveDirection.Z)
    if mdFlat.Magnitude < 0.01 then return "stationary", moveDirection end
    mdFlat = mdFlat.Unit
    local dot = tonumber(mdFlat:Dot(toWRDir)) or 0
    if dot > 0.75 then return "go/fade", moveDirection
    elseif dot >= 0.25 and dot <= 0.75 then
        if distance <= 120 then return "slant", moveDirection
        elseif distance <= 160 then return "seam", moveDirection
        else return "post/corner", moveDirection end
    elseif dot > -0.25 and dot < 0.25 then
        if distance <= 60 then return "drag", moveDirection
        elseif distance <= 130 then return "in/out", moveDirection
        else return "flat", moveDirection end
    else
        if distance <= 50 then return "hitch", moveDirection
        else return "curl/comeback", moveDirection end
    end
end

local isWROpen = function(wrChar)
    if not wrChar then return false end
    local hrp = wrChar:FindFirstChild("HumanoidRootPart"); if not hrp then return false end
    local isCovered = false
    local _, moveDir = findRoute(wrChar)
    local teamCount = 0; pcall(function() teamCount = tonumber(#game:GetService("Teams"):GetTeams()) or 0 end)
    local checkDB = function(dbHRP)
        local toDB = dbHRP.Position - hrp.Position
        local dist = tonumber(toDB.Magnitude) or 0
        if dist < 5 then
            local routeDirXZ = Vector3.new(moveDir.X,0,moveDir.Z)
            if (tonumber(routeDirXZ.Magnitude) or 0) > 0.01 then
                routeDirXZ = routeDirXZ.Unit
                local dot = tonumber(toDB.Unit:Dot(routeDirXZ)) or 0
                if dot > -0.7 then return true end
            else return true end
        end
        return false
    end
    local checkPR = function(dbHRP)
        local qbChar = lp.Character; if not qbChar then return false end
        local qbHRP = qbChar:FindFirstChild("HumanoidRootPart"); if not qbHRP then return false end
        local toPR = dbHRP.Position - qbHRP.Position
        local toWR = hrp.Position - qbHRP.Position
        local wrDist = tonumber(toWR.Magnitude) or 0
        local wrDir = toWR.Unit
        local proj = tonumber(toPR:Dot(wrDir)) or 0
        if proj > 2 and proj < (wrDist*0.6) then
            local distToLine = tonumber((toPR-(wrDir*proj)).Magnitude) or 0
            if distToLine < 5.5 then return true end
        end
        return false
    end
    local plrs = players:GetPlayers()
    for i = 1, #plrs do
        local plr = plrs[i]
        if plr ~= lp and plr.Character then
            local isEnemy = true
            if teamCount > 1 and lp.Team ~= nil and plr.Team ~= nil and lp.Team == plr.Team then isEnemy = false end
            if isEnemy then
                local dbHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                if dbHRP and (checkDB(dbHRP) or checkPR(dbHRP)) then isCovered = true; break end
            end
        end
    end
    if not isCovered then
        local bots = getActiveBots()
        for i = 1, #bots do
            local bot = bots[i]; if bot ~= wrChar then
                local dbHRP = bot:FindFirstChild("HumanoidRootPart")
                if dbHRP and (checkDB(dbHRP) or checkPR(dbHRP)) then isCovered = true; break end
            end
        end
    end
    return not isCovered
end

local getTarget = function()
    if isThrowing and target then return target end
    if targetLocked and lockedTarget and lockedTarget:FindFirstChild("HumanoidRootPart") then
        return lockedTarget
    elseif targetLocked then targetLocked = false; lockedTarget = nil end
    local potentialTargets = {}
    local teamCount = 0; pcall(function() teamCount = tonumber(#game:GetService("Teams"):GetTeams()) or 0 end)
    local plrs = players:GetPlayers()
    for i = 1, #plrs do
        local plr = plrs[i]
        if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local isTeammate = true
            if teamCount > 1 and lp.Team ~= nil and plr.Team ~= nil and lp.Team ~= plr.Team then isTeammate = false end
            if isTeammate then
                local eHum = plr.Character:FindFirstChildOfClass("Humanoid")
                if not eHum or not eHum.Sit then table.insert(potentialTargets, plr.Character) end
            end
        end
    end
    local bots = getActiveBots()
    for i = 1, #bots do
        local bot = bots[i]
        if bot:FindFirstChild("HumanoidRootPart") then
            local eHum = bot:FindFirstChildOfClass("Humanoid")
            if not eHum or not eHum.Sit then table.insert(potentialTargets, bot) end
        end
    end
    if #potentialTargets == 0 then return nil end
    if autoChooseWr.Value then
        local bestAutoTarget = nil; local bestAutoDist = math.huge
        local qbHRP = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local qbPos = qbHRP and qbHRP.Position or Vector3.zero
        for i = 1, #potentialTargets do
            local char = potentialTargets[i]; local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local _, onScreen = camera:WorldToViewportPoint(hrp.Position)
                if onScreen and isWROpen(char) then
                    local dist = tonumber((hrp.Position-qbPos).Magnitude) or 0
                    if dist < bestAutoDist then bestAutoDist = dist; bestAutoTarget = char end
                end
            end
        end
        if bestAutoTarget then return bestAutoTarget end
    end
    local mousePos2D = userInputService:GetMouseLocation()
    local bestManualTarget = nil; local bestMouseDist = math.huge
    for i = 1, #potentialTargets do
        local char = potentialTargets[i]; local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local dist = tonumber((Vector2.new(screenPos.X,screenPos.Y)-mousePos2D).Magnitude) or 0
                if dist < bestMouseDist then bestMouseDist = dist; bestManualTarget = char end
            end
        end
    end
    return bestManualTarget
end

local calculateRouteDirection = function(targetChar)
    if not targetChar then return "Mag" end
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart"); if not targetHRP then return "Mag" end
    local lpChar = lp.Character; local lpHRP = lpChar and lpChar:FindFirstChild("HumanoidRootPart"); if not lpHRP then return "Mag" end
    local route, moveDir = findRoute(targetChar)
    local dist = tonumber((targetHRP.Position-lpHRP.Position).Magnitude) or 0
    if dist < 40 then return "Bullet" end
    local dbDistance = math.huge; local teamCount = 0; pcall(function() teamCount = tonumber(#game:GetService("Teams"):GetTeams()) or 0 end)
    local plrs = players:GetPlayers()
    for i = 1, #plrs do
        local plr = plrs[i]
        if plr ~= lp and plr.Character then
            local eHRP = plr.Character:FindFirstChild("HumanoidRootPart")
            if eHRP and eHRP ~= targetHRP then
                local isEnemy = true
                if teamCount > 1 and lp.Team ~= nil and plr.Team ~= nil and lp.Team == plr.Team then isEnemy = false end
                if isEnemy then local d = tonumber((eHRP.Position-targetHRP.Position).Magnitude) or 0; if d < dbDistance then dbDistance = d end end
            end
        end
    end
    local bots = getActiveBots()
    for i = 1, #bots do
        local bot = bots[i]; local bHRP = bot:FindFirstChild("HumanoidRootPart")
        if bHRP and bHRP ~= targetHRP then local d = tonumber((bHRP.Position-targetHRP.Position).Magnitude) or 0; if d < dbDistance then dbDistance = d end end
    end
    local within = function(tbl,val) for i=1,#tbl do if tbl[i]==val then return true end end return false end
    local forwardRoutes = {"go/fade","post/corner","seam","curl/comeback","stationary"}
    local sidewayRoutes = {"in/out","flat","wheel"}
    if route=="slant" or route=="hitch" or route=="drag" or route=="in/out" or route=="flat" then return "Bullet"
    elseif within(forwardRoutes,route) then
        if dbDistance > 5 then return ((tonumber(angle) or 45)<40) and "Jump" or "Dime"
        elseif dbDistance > 2 then return "Dive" end; return "Mag"
    elseif within(sidewayRoutes,route) then
        if dbDistance > 4 then return "Dime" end; return "Jump"
    end
    return "Dime"
end

local getModeLead = function(m)
    if m=="Dime" then return leadDime elseif m=="Mag" then return leadMag
    elseif m=="Dive" then return leadDive elseif m=="Jump" then return leadJump
    elseif m=="Bullet" then return leadBullet end; return 8.6
end
local getModeYLead = function(m)
    if m=="Dime" then return yLeadDime elseif m=="Mag" then return yLeadMag
    elseif m=="Dive" then return yLeadDive elseif m=="Jump" then return yLeadJump
    elseif m=="Bullet" then return yLeadBullet end; return 0
end

local getPing = function()
    local networkPing = 0; pcall(function() networkPing = tonumber(lp:GetNetworkPing()) or 0 end)
    local dataPing = 0; pcall(function() dataPing = (tonumber(stats.Network.ServerStatsItem["Data Ping"]:GetValue()) or 0)/1000 end)
    if dataPing == 0 then dataPing = networkPing end; return networkPing + dataPing
end

local solveKinematics = function(origin, targetPos, gravityMag)
    local g = tonumber(gravityMag) or 28
    local displacement = targetPos - origin
    local x = tonumber(Vector3.new(displacement.X,0,displacement.Z).Magnitude) or 0
    local y = tonumber(displacement.Y) or 0
    local inner = (x^2)+(y^2)
    local root = tonumber(math.sqrt(math.max(inner,0))) or 0
    local baseAngleRad = math.rad(45)
    if x > 0.01 then local atanRes = tonumber(math.atan((y+root)/x)) or baseAngleRad; if atanRes and atanRes==atanRes then baseAngleRad = atanRes end end
    local angleRad = tonumber(math.clamp(baseAngleRad*0.85, math.rad(-15), math.rad(65))) or 0
    local cosA = tonumber(math.cos(angleRad)) or 1; local tanA = tonumber(math.tan(angleRad)) or 0
    local v0 = 95
    local denom = 2*(cosA^2)*(x*tanA-y)
    if denom > 0.001 then
        local num = g*(x^2); local res = tonumber(math.sqrt(num/denom)) or v0
        if res and res==res and res~=math.huge then v0 = res end
    end
    local angleDeg = tonumber(math.deg(angleRad)) or 45
    return v0, angleDeg
end

local autoAim = function(targetHRP)
    local head = lp.Character:FindFirstChild("Head")
    local origin = head and head.Position or lp.Character.HumanoidRootPart.Position
    local targetChar = targetHRP.Parent
    local targetHeadObj = targetChar and targetChar:FindFirstChild("Head")
    local targetHead = targetHeadObj and targetHeadObj.Position or targetHRP.Position+Vector3.new(0,1.5,0)
    local moveDir = Vector3.zero
    local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
    if targetHum then
        local isBot = targetChar:FindFirstAncestor("npcwr") ~= nil
        if isBot then
            local wtpDiff = targetHum.WalkToPoint-targetHRP.Position
            local dir = Vector3.new(wtpDiff.X,0,wtpDiff.Z)
            moveDir = dir.Magnitude > 0.1 and dir.Unit or Vector3.zero
        else
            local md = targetHum.MoveDirection; local flatMd = Vector3.new(md.X,0,md.Z)
            moveDir = flatMd.Magnitude > 0.01 and flatMd.Unit or Vector3.zero
        end
    end
    local ping = tonumber(getPing()) or 0; local speed = 20
    local modeName = ModeOrder[modeIndex]
    local routeStr = target and findRoute(target) or "go/fade"
    local isChestPass = (modeName=="Bullet" or target and (routeStr=="slant" or routeStr=="drag" or routeStr=="in/out" or routeStr=="flat" or routeStr=="hitch" or routeStr=="curl/comeback"))
    local activePower = tonumber(power) or 60
    if modeName=="Bullet" or (autoPower.Value and isChestPass) or highPowerOnly.Value then activePower = 95 end
    local lDivisor = 60
    if activePower > 75 then lDivisor = 60+((activePower-75)*1.5) end
    local distToTarget = tonumber((targetHRP.Position-origin).Magnitude) or 0
    local estFlightTime = distToTarget/(tonumber(lDivisor) or 60)
    local currentHVel = activePower*(tonumber(math.cos(math.rad(tonumber(angle) or 45))) or 1)
    if currentHVel < 30 then currentHVel = 55 end
    local estHVel = (modeName=="Bullet" or isChestPass) and 90 or currentHVel
    local modeLeadScale = (tonumber(getModeLead(modeName)) or 8.6)*3.05
    local selectedModeYLead = tonumber(getModeYLead(modeName)) or 0
    local routeMultipliers = {["slant"]=0.45,["drag"]=0.6,["in/out"]=0.65,["flat"]=0.65,["wheel"]=0.9,["go/fade"]=1.0,["post/corner"]=0.85,["seam"]=0.85,["hitch"]=0.1,["curl/comeback"]=0.1,["stationary"]=0.0}
    local rMult = tonumber(routeMultipliers[routeStr]) or 1.0
    local dirUnit = moveDir.Magnitude > 0.01 and moveDir.Unit or Vector3.zero
    local targetBase = (isChestPass or modeName=="Bullet") and targetHRP.Position or targetHead
    local standingStill = (routeStr=="stationary")
    local leadPos
    if standingStill then
        leadPos = targetHead
    else
        leadPos = targetBase+(moveDir*speed*estFlightTime*rMult)+(moveDir*speed*ping*rMult)+(dirUnit*modeLeadScale*rMult)
        leadPos = leadPos+(dirUnit*(tonumber(throwLeadOffset.Value) or 0))
        if isChestPass or modeName=="Bullet" then leadPos = Vector3.new(leadPos.X,targetHead.Y,leadPos.Z); selectedModeYLead = 0 end
        leadPos = leadPos+Vector3.new(0,selectedModeYLead,0)+Vector3.new(0,tonumber(throwHeightOffset.Value) or 0,0)
        if routeStr=="curl/comeback" or routeStr=="hitch" then leadPos = leadPos+Vector3.new(0,-5,0) end
    end
    local forceAutoAngle = (modeName=="Bullet" or isChestPass or (tonumber(power) or 60)==95 or highPowerOnly.Value)
    if not autoAngle.Value and not forceAutoAngle then leadPos = leadPos+Vector3.new(0,tonumber(customHeight.Value) or 0,0) end
    if antiDB.Value then
        local pushVec = Vector3.zero; local plrs = players:GetPlayers(); local teamCount = 0
        pcall(function() teamCount = tonumber(#game:GetService("Teams"):GetTeams()) or 0 end)
        for i=1,#plrs do
            local plr = plrs[i]
            if plr ~= lp and plr.Character then
                local isEnemy = true
                if teamCount>1 and lp.Team~=nil and plr.Team~=nil and lp.Team==plr.Team then isEnemy=false end
                if isEnemy then
                    local eHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                    if eHRP then
                        local dist = tonumber(Vector3.new(eHRP.Position.X-leadPos.X,0,eHRP.Position.Z-leadPos.Z).Magnitude) or 0
                        if dist < (tonumber(antiDBThreshold.Value) or 15) then
                            local away = (leadPos-eHRP.Position); away = Vector3.new(away.X,0,away.Z)
                            if away.Magnitude > 0 then pushVec = pushVec+(away.Unit*((tonumber(antiDBThreshold.Value) or 15)-dist)) end
                        end
                    end
                end
            end
        end
        leadPos = pushVec+leadPos
    end
    local fPos = Vector3.zero
    local field = workspace:FindFirstChild("Models"); if field then field = field:FindFirstChild("Field") end
    if field then field = field:FindFirstChild("Ground") end; if field then fPos = field.Position end
    if antiOOB.Value and fPos ~= Vector3.zero then
        local halfWidth = 75-(tonumber(antiOOBThreshold.Value) or 5)
        local halfLength = 175-(tonumber(antiOOBThreshold.Value) or 5)
        leadPos = Vector3.new(math.clamp(leadPos.X,fPos.X-halfWidth,fPos.X+halfWidth),leadPos.Y,math.clamp(leadPos.Z,fPos.Z-halfLength,fPos.Z+halfLength))
    end
    targetLeadPos = leadPos
    local gMag = 28; local calcPower, calcAngle = solveKinematics(origin, leadPos, gMag)
    calcPower = tonumber(calcPower) or 95; calcAngle = tonumber(calcAngle) or 45
    if standingStill and modeName~="Bullet" and not highPowerOnly.Value then
        local dynamicThreshold = tonumber(math.clamp(4+(distToTarget*0.08),5,14)) or 10
        if calcAngle > dynamicThreshold then
            local displacement = leadPos-origin
            local x = tonumber(Vector3.new(displacement.X,0,displacement.Z).Magnitude) or 0
            local y = tonumber(displacement.Y) or 0
            local aRad = tonumber(math.rad(dynamicThreshold)) or 0.1
            local denom = 2*(math.cos(aRad)^2)*(x*math.tan(aRad)-y)
            if denom > 0.001 then
                local newPwr = tonumber(math.sqrt((gMag*x^2)/denom)) or calcPower
                if newPwr==newPwr and newPwr~=math.huge then calcAngle = dynamicThreshold; calcPower = newPwr end
            end
        end
    end
    if highPowerOnly.Value then
        power = 95
        local displacement = leadPos-origin
        local x = tonumber(Vector3.new(displacement.X,0,displacement.Z).Magnitude) or 0
        local y = tonumber(displacement.Y) or 0
        local v2 = 95^2; local v4 = 95^4; local gx = gMag*x
        local discriminant = v4-gMag*(gMag*x^2+2*y*v2)
        if discriminant >= 0 then angle = tonumber(math.clamp(math.deg(math.atan((v2-math.sqrt(discriminant))/gx))*0.94,-15,85)) or 45
        else angle = 45 end
    elseif modeName=="Bullet" or (autoPower.Value and isChestPass) then
        power = 95
        local displacement = leadPos-origin
        local h = tonumber(Vector3.new(displacement.X,0,displacement.Z).Magnitude) or 0
        local v = tonumber(displacement.Y) or 0
        local t_est = h/95; local drop = 0.5*28*t_est*t_est
        angle = tonumber(math.clamp(math.deg(math.atan2(v+drop,h)),-15,45)) or 15
    else
        if autoPower.Value then power = tonumber(math.clamp(calcPower,0,95)) or 60 end
        if autoAngle.Value then angle = tonumber(math.clamp(calcAngle,-15,90)) or 45 end
    end
    if not autoAngle.Value and not forceAutoAngle then angle = tonumber(math.clamp(calcAngle,-15,90)) or 45 end
    local safePower = tonumber(power) or 60; local safeAngle = tonumber(angle) or 45
    local angleRad = tonumber(math.rad(safeAngle)) or 0
    local hDirRaw = Vector3.new(leadPos.X-origin.X,0,leadPos.Z-origin.Z)
    local hDir = hDirRaw.Magnitude > 0.01 and hDirRaw.Unit or head.CFrame.LookVector
    local dirVelocity = (hDir*(tonumber(math.cos(angleRad)) or 1)+Vector3.new(0,tonumber(math.sin(angleRad)) or 0,0))*safePower
    direction = dirVelocity.Unit*safePower
    local hVel = safePower*(tonumber(math.cos(angleRad)) or 1)
    if hVel > 0.1 then
        local xDist = tonumber(Vector3.new(leadPos.X-origin.X,0,leadPos.Z-origin.Z).Magnitude) or 0; airtime = xDist/hVel
    else airtime = 0 end
    return safeAngle
end

local beamProjectile = function(g, v0, x0, t1)
    local c = 0.5*0.5*0.5; local safeT1 = tonumber(t1) or 0.1
    local p3 = 0.5*g*safeT1*safeT1+v0*safeT1+x0
    local p2 = p3-(g*safeT1*safeT1+v0*safeT1)/3
    local p1 = (c*g*safeT1*safeT1+0.5*v0*safeT1+x0-c*(x0+p3))/(3*c)-p2
    local curve0 = tonumber((p1-x0).Magnitude) or 0
    local curve1 = tonumber((p2-p3).Magnitude) or 0
    local b = (x0-p3).Unit; local r1 = (p1-x0).Unit; local u1 = r1:Cross(b).Unit
    local r2 = (p2-p3).Unit; local u2 = r2:Cross(b).Unit; b = u1:Cross(r1).Unit
    local cf1 = CFrame.new(x0.X,x0.Y,x0.Z,r1.X,u1.X,b.X,r1.Y,u1.Y,b.Y,r1.Z,u1.Z,b.Z)
    local cf2 = CFrame.new(p3.X,p3.Y,p3.Z,r2.X,u2.X,b.X,r2.Y,u2.Y,b.Y,r2.Z,u2.Z,b.Z)
    return curve0, -curve1, cf1, cf2
end

userInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local char = lp.Character; if not char or not char:FindFirstChild("Football") then return end
    if input.KeyCode == throwBallAwayKeybind.Value then
        local fPos = Vector3.zero
        local field = workspace:FindFirstChild("Models"); if field then field=field:FindFirstChild("Field") end
        if field then field=field:FindFirstChild("Ground") end; if field then fPos=field.Position end
        local side = math.random(1,2)==1 and -1 or 1
        local throwTarget = fPos+Vector3.new(side*120,0,math.random(-100,100))
        local head = char:FindFirstChild("Head"); local origin = head and head.Position or char.HumanoidRootPart.Position
        isThrowingAway = true; power = 95; angle = 25
        local angleRad = tonumber(math.rad(angle)) or 0
        local hDir = Vector3.new(throwTarget.X-origin.X,0,throwTarget.Z-origin.Z).Unit
        local dirVelocity = (hDir*(tonumber(math.cos(angleRad)) or 1)+Vector3.new(0,tonumber(math.sin(angleRad)) or 0,0))*95
        direction = dirVelocity.Unit*95
        local hVel = 95*(tonumber(math.cos(angleRad)) or 1)
        airtime = hVel>0.1 and ((tonumber(Vector3.new(throwTarget.X-origin.X,0,throwTarget.Z-origin.Z).Magnitude) or 0)/hVel) or 1
        local hum = char:FindFirstChildOfClass("Humanoid")
        local throwAnim = replicatedStorage:FindFirstChild("Animations") and replicatedStorage.Animations:FindFirstChild("Throw")
        if hum and throwAnim then
            local animator = hum:FindFirstChild("Animator")
            if animator then local track = animator:LoadAnimation(throwAnim); track:Play() end
        end
        return
    end
    if input.KeyCode == increaseAngleKeybind.Value then customHeight.Value = (tonumber(customHeight.Value) or 0)+5
    elseif input.KeyCode == decreaseAngleKeybind.Value then customHeight.Value = (tonumber(customHeight.Value) or 0)-5 end
    if not autoSelectThrowMode.Value and QBKeybinds[input.KeyCode] then
        local desiredMode = QBKeybinds[input.KeyCode]
        for i=1,#ModeOrder do if ModeOrder[i]==desiredMode then modeIndex=i; break end end
    end
    if input.KeyCode == lockKeybind.Value then
        if target or targetLocked then
            targetLocked = not targetLocked
            if targetLocked then
                lockedTarget = target
                if LockToggleBtn then LockToggleBtn.TextColor3 = Color3.fromRGB(255,50,50) end
                if LockedLabel then LockedLabel.Visible = true end
            else
                lockedTarget = nil
                if LockToggleBtn then LockToggleBtn.TextColor3 = Color3.fromRGB(255,255,255) end
                if LockedLabel then LockedLabel.Visible = false end
            end
        end
    end
end)

local triggerThrowJump = function()
    if autoJumpWhenThrow.Value then
        task.delay(0.05, function()
            local char = lp.Character; if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum:GetState()~=Enum.HumanoidStateType.Jumping then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
    end
end

task.spawn(function()
    local bindAnimation = function(char)
        local humanoid = char:WaitForChild("Humanoid",5); if not humanoid then return end
        local animator = humanoid:WaitForChild("Animator",5); if not animator then return end
        animator.AnimationPlayed:Connect(function(track)
            local throwAnim = replicatedStorage:FindFirstChild("Animations") and replicatedStorage.Animations:FindFirstChild("Throw")
            if throwAnim and track.Animation and (track.Animation==throwAnim or track.Animation.AnimationId==throwAnim.AnimationId) then
                track:GetPropertyChangedSignal("IsPlaying"):Connect(function()
                    if track.IsPlaying then
                        if not isThrowing then
                            isThrowing = true; triggerThrowJump()
                            task.delay(0.12, function() firedRemote=true; performThrow() end)
                        end
                    else isThrowing=false; firedRemote=false; isThrowingAway=false end
                end)
                if track.IsPlaying and not isThrowing then
                    isThrowing=true; triggerThrowJump()
                    task.delay(0.12, function() firedRemote=true; performThrow() end)
                end
            end
        end)
    end
    if lp.Character then bindAnimation(lp.Character) end
    lp.CharacterAdded:Connect(function(char) bindAnimation(char) end)
end)

local setupSackHandler = function(character)
    character.ChildAdded:Connect(function(v)
        if not autoThrowAfterSack.Value then return end
        if not v:IsA("LocalScript") then return end
        if not v.Name:lower():find("tackle") then return end
        task.wait()
        local humanoid = character:FindFirstChildOfClass("Humanoid"); if not humanoid then return end
        if autoChooseWr.Value then
            local openWR = nil; local bestDist = math.huge
            local mousePos2D = userInputService:GetMouseLocation()
            local teamCount = 0; pcall(function() teamCount = tonumber(#game:GetService("Teams"):GetTeams()) or 0 end)
            local plrs = players:GetPlayers()
            for i=1,#plrs do
                local plr = plrs[i]
                if plr ~= lp and plr.Character then
                    local isTeammate = true
                    if teamCount>1 and lp.Team~=nil and plr.Team~=nil and lp.Team~=plr.Team then isTeammate=false end
                    if isTeammate then
                        local eHrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        local eHum = plr.Character:FindFirstChildOfClass("Humanoid")
                        if eHrp and (not eHum or not eHum.Sit) and isWROpen(plr.Character) then
                            local screenPos, onScreen = camera:WorldToViewportPoint(eHrp.Position)
                            if onScreen then
                                local dist = tonumber((Vector2.new(screenPos.X,screenPos.Y)-mousePos2D).Magnitude) or 0
                                if dist < bestDist then bestDist=dist; openWR=plr.Character end
                            end
                        end
                    end
                end
            end
            if openWR then target=openWR; targetLocked=true; lockedTarget=openWR end
        end
        if target then
            local throwAnim = replicatedStorage:FindFirstChild("Animations") and replicatedStorage.Animations:FindFirstChild("Throw")
            if throwAnim then
                local animator = humanoid:FindFirstChild("Animator")
                if animator then local track = animator:LoadAnimation(throwAnim); track:Play() end
            end
        end
    end)
end
if lp.Character then setupSackHandler(lp.Character) end
lp.CharacterAdded:Connect(setupSackHandler)

local updateHighlights = function(isActive)
    if not isActive then if highlight then highlight:Destroy(); highlight=nil end return end
    if target then
        if not highlight then highlight = Instance.new("Highlight") end
        highlight.Adornee = target; highlight.Parent = target
        highlight.FillTransparency = 1
        highlight.OutlineColor = targetLocked and Color3.new(0,0,0) or Color3.fromRGB(255,255,255)
        highlight.OutlineTransparency = 0
    elseif highlight then highlight:Destroy(); highlight=nil end
end

workspace.ChildAdded:Connect(function(v)
    if not enableQbAimbot.Value then return end
    if v:IsA("BasePart") and v.Name=="Football" then
        task.wait()
        local lpChar = lp.Character; local lpHead = lpChar and lpChar:FindFirstChild("Head"); if not lpHead then return end
        if v:GetAttribute("LocalAimbotBall") or (v.Position-lpHead.Position).Magnitude < 15 then
            local tAttach0 = Instance.new("Attachment",workspace.Terrain)
            local tAttach1 = Instance.new("Attachment",workspace.Terrain)
            local tBeam = Instance.new("Beam")
            tBeam.Attachment0=tAttach0; tBeam.Attachment1=tAttach1; tBeam.Segments=7500
            tBeam.Width0=1; tBeam.Width1=1; tBeam.FaceCamera=true
            tBeam.Color=ColorSequence.new(Color3.fromRGB(255,255,255))
            tBeam.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.01,0),NumberSequenceKeypoint.new(1,0)})
            tBeam.Parent=workspace.Terrain
            local tPosPart = Instance.new("Part",workspace.Terrain)
            tPosPart.Anchored=true; tPosPart.CanCollide=false; tPosPart.CastShadow=false
            tPosPart.Size=Vector3.new(3,3,3); tPosPart.Shape=Enum.PartType.Ball; tPosPart.Color=Color3.fromRGB(0,0,0)
            local safeDirection = direction or Vector3.new(0,1,0)
            local safeAirtime = math.max(tonumber(airtime) or 0.1,0.1)
            local curve0,curve1,cf1,cf2 = beamProjectile(Vector3.new(0,-28,0),safeDirection,lpHead.Position+(safeDirection.Unit*5),safeAirtime)
            tBeam.CurveSize0=curve0; tBeam.CurveSize1=curve1
            tAttach0.WorldCFrame=cf1; tAttach1.WorldCFrame=cf2
            tPosPart.Position=Vector3.new(cf2.X,cf2.Y,cf2.Z)
            task.delay(safeAirtime,function() tBeam:Destroy(); tAttach0:Destroy(); tAttach1:Destroy(); tPosPart:Destroy() end)
        end
    end
end)

runService.RenderStepped:Connect(function()
    if not enableQbAimbot.Value then
        updateHUDVisibility(false); updateHighlights(false)
        if beam then beam.Enabled=false end
        if posPart then posPart.Position=Vector3.new(0,-9999,0) end
        if attach0 then attach0.WorldPosition=Vector3.new(0,-9999,0) end
        if attach1 then attach1.WorldPosition=Vector3.new(0,-9999,0) end
        target=nil; return
    end
    if not sg or not sg.Parent then return end
    local char = lp.Character; if not char then return end
    local head = char:FindFirstChild("Head"); local hrp = char:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then return end
    local football = char:FindFirstChild("Football"); local hasFootball = (football~=nil)
    if hasFootball then
        football:SetAttribute("LocalAimbotBall",true)
        local fHandle = football:FindFirstChild("Handle"); if fHandle then fHandle:SetAttribute("LocalAimbotBall",true) end
    end
    local playerGui = lp:WaitForChild("PlayerGui",10)
    local ballGui = playerGui and playerGui:FindFirstChild("BallGui")
    if autoJuke.Value and hasFootball and ballGui then
        local fPos = Vector3.zero
        local field = workspace:FindFirstChild("Models"); if field then field=field:FindFirstChild("Field") end
        if field then field=field:FindFirstChild("Ground") end; if field then fPos=field.Position end
        local minX=fPos.X-(155/2); local maxX=fPos.X+(155/2)
        local minZ=fPos.Z-(355/2); local maxZ=fPos.Z+(355/2)
        local dodgeVec=Vector3.zero; local threatCount=0
        local plrs=players:GetPlayers(); local teamCount=0
        pcall(function() teamCount=tonumber(#game:GetService("Teams"):GetTeams()) or 0 end)
        for i=1,#plrs do
            local plr=plrs[i]
            if plr~=lp and plr.Character then
                local isEnemy=true
                if teamCount>1 and lp.Team~=nil and plr.Team~=nil and lp.Team==plr.Team then isEnemy=false end
                if isEnemy then
                    local eHrp=plr.Character:FindFirstChild("HumanoidRootPart")
                    if eHrp then
                        local distToMe=tonumber((eHrp.Position-hrp.Position).Magnitude) or 0
                        if distToMe < 45 then
                            local eVel=eHrp.AssemblyLinearVelocity or eHrp.Velocity or Vector3.zero
                            local eSpeed=tonumber(Vector3.new(eVel.X,0,eVel.Z).Magnitude) or 0
                            local tta=distToMe/math.max(eSpeed,1)
                            local futureTime=math.min(tta,1)
                            local eFuture=eHrp.Position+(eVel*futureTime)
                            local myVel=hrp.AssemblyLinearVelocity or hrp.Velocity or Vector3.zero
                            local myFuture=hrp.Position+(myVel*futureTime)
                            local toThreat=eFuture-myFuture
                            local futureDist=tonumber(Vector3.new(toThreat.X,0,toThreat.Z).Magnitude) or 0
                            if futureDist < 20 or distToMe < 25 then
                                threatCount=threatCount+1
                                local awayDir=myFuture-eFuture; awayDir=Vector3.new(awayDir.X,0,awayDir.Z)
                                if awayDir.Magnitude < 0.1 then awayDir=hrp.CFrame.RightVector end
                                awayDir=awayDir.Unit
                                local weight=math.clamp(45-distToMe,0,45)
                                dodgeVec=dodgeVec+(awayDir*weight)
                            end
                        end
                    end
                end
            end
        end
        local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then
            local checkPos=hrp.Position; local outOfBoundsPush=Vector3.zero
            if checkPos.X<minX+5 then outOfBoundsPush=outOfBoundsPush+Vector3.new(1,0,0) end
            if checkPos.X>maxX-5 then outOfBoundsPush=outOfBoundsPush+Vector3.new(-1,0,0) end
            if checkPos.Z<minZ+5 then outOfBoundsPush=outOfBoundsPush+Vector3.new(0,0,1) end
            if checkPos.Z>maxZ-5 then outOfBoundsPush=outOfBoundsPush+Vector3.new(0,0,-1) end
            local targetJukeDir=Vector3.zero
            if threatCount>0 then
                targetJukeDir=dodgeVec.Unit
                if outOfBoundsPush.Magnitude>0 then targetJukeDir=(targetJukeDir+outOfBoundsPush*2).Unit end
            elseif outOfBoundsPush.Magnitude>0 then targetJukeDir=outOfBoundsPush.Unit end
            if targetJukeDir.Magnitude>0 then smoothedJukeDir=smoothedJukeDir:Lerp(targetJukeDir,0.25); hum:Move(smoothedJukeDir,false)
            else smoothedJukeDir=Vector3.zero end
        end
    end
    local isTracking = hasFootball and (ballGui~=nil)
    if isTracking then
        if not hideCards.Value then updateHUDVisibility(true) else updateHUDVisibility(false) end
        if not isThrowingAway then
            local newTarget = getTarget()
            if newTarget then lastValidTarget=newTarget
            elseif lastValidTarget and not lastValidTarget:FindFirstChild("HumanoidRootPart") then lastValidTarget=nil end
            if throwAimbot.Value then
                target=lastValidTarget; updateHighlights(false)
                local targetPos
                if isThrowing and lockedMousePos then targetPos=lockedMousePos
                else targetPos=mouse.Hit.Position; lockedMousePos=targetPos end
                local headPos=head.Position; local gMag=28
                local calcPower,calcAngle=solveKinematics(headPos,targetPos,gMag)
                calcPower=tonumber(calcPower) or 95; calcAngle=tonumber(calcAngle) or 45
                if autoPower.Value then power=math.clamp(calcPower,0,95) end
                if autoAngle.Value then angle=math.clamp(calcAngle,-15,90)
                else angle=math.clamp(tonumber(customHeight.Value) or 0,-15,90) end
                local safePower=tonumber(power) or 60; local safeAngle=tonumber(angle) or 45
                local angleRad=tonumber(math.rad(safeAngle)) or 0
                local hDirRaw=Vector3.new(targetPos.X-headPos.X,0,targetPos.Z-headPos.Z)
                local hDir=hDirRaw.Magnitude>0.01 and hDirRaw.Unit or hrp.CFrame.LookVector
                local dirVelocity=(hDir*(tonumber(math.cos(angleRad)) or 1)+Vector3.new(0,tonumber(math.sin(angleRad)) or 0,0))*safePower
                direction=dirVelocity.Unit*safePower
                local hVel=safePower*(tonumber(math.cos(angleRad)) or 1)
                if hVel>0.1 then local xDist=tonumber(Vector3.new(targetPos.X-headPos.X,0,targetPos.Z-headPos.Z).Magnitude) or 0; airtime=xDist/hVel
                else airtime=0 end
                targetLeadPos=targetPos
            else
                target=newTarget or lastValidTarget; updateHighlights(true)
                if target and hrp then
                    local tHRP=target:FindFirstChild("HumanoidRootPart")
                    if tHRP then
                        if autoSelectThrowMode.Value then
                            local m=calculateRouteDirection(target)
                            for i=1,#ModeOrder do if ModeOrder[i]==m then modeIndex=i; break end end
                            local targetCurrentRoute=select(1,findRoute(target))
                            if ModeOrder[modeIndex]=="Bullet" and (targetCurrentRoute=="go/fade" or targetCurrentRoute=="post/corner") then
                                for i=1,#ModeOrder do if ModeOrder[i]=="Mag" then modeIndex=i; break end end
                            end
                        end
                        autoAim(tHRP)
                    end
                end
            end
        else target=nil; updateHighlights(false) end
        if autoChangePowerUI.Value then
            if ballGui and ballGui:FindFirstChild("Frame0") then
                local frame0=ballGui.Frame0; local safePower=tonumber(power) or 60
                if safePower~=safePower then safePower=60 end
                local displayPower=math.round(safePower/5)*5
                local txt=frame0:FindFirstChildOfClass("TextLabel"); if txt then txt.Text=tostring(math.floor(displayPower)) end
                local frames=frame0:GetChildren()
                for i=1,#frames do
                    local frame=frames[i]
                    if frame.Name~="Disp" then
                        local frameNum=tonumber(frame.Name) or 0
                        frame.BackgroundTransparency=((tonumber(frameNum) or 0)<=(tonumber(displayPower) or 0)) and 0 or 0.9
                    end
                end
            end
        end
        local safePowForCard=tonumber(power) or 60; if safePowForCard~=safePowForCard then safePowForCard=60 end
        if HUDCards["Angle"] then
            local forceAutoAngle=(ModeOrder[modeIndex]=="Bullet" or (target and findRoute(target)=="slant" or findRoute(target)=="drag" or findRoute(target)=="in/out" or findRoute(target)=="flat" or findRoute(target)=="hitch" or findRoute(target)=="curl/comeback") or (tonumber(power) or 60)==95 or highPowerOnly.Value)
            if not autoAngle.Value and not forceAutoAngle then HUDCards["Angle"].Text=tostring(math.floor(tonumber(customHeight.Value) or 0))
            else HUDCards["Angle"].Text=tostring(math.floor(tonumber(angle) or 45)) end
        end
        if HUDCards["Power"] then HUDCards["Power"].Text=string.format("%.0f",safePowForCard) end
        if HUDCards["Airtime"] then HUDCards["Airtime"].Text=string.format("%.1fs",tonumber(airtime) or 0) end
        if HUDCards["Throw Type"] then HUDCards["Throw Type"].Text=tostring(ModeOrder[modeIndex] or "N/A") end
        if HUDCards["Player"] then
            if throwAimbot.Value then HUDCards["Player"].Text="MOUSE"
            else HUDCards["Player"].Text=tostring((target and target.Name) or "NONE") end
        end
    else updateHUDVisibility(false); updateHighlights(false); target=nil; lastValidTarget=nil end
    if beam and isTracking then
        beam.Enabled=true; local startOrigin=head.Position
        local safePowerForBeam=tonumber(power) or 60; local drawDir=direction or Vector3.new(0,1,0)
        if throwAimbot.Value then if (tonumber(drawDir.Magnitude) or 0)<0.1 then drawDir=Vector3.new(0,1,0)*safePowerForBeam end
        elseif not target or not targetLeadPos then
            local mouseRay=camera:ScreenPointToRay(mouse.X,mouse.Y)
            drawDir=mouseRay.Direction.Unit*safePowerForBeam; direction=drawDir
        else if (tonumber(drawDir.Magnitude) or 0)<0.1 then drawDir=Vector3.new(0,1,0)*safePowerForBeam end end
        local safeAirtime=math.max(tonumber(airtime) or 0.1,0.1)
        local curve0,curve1,cf1,cf2=beamProjectile(Vector3.new(0,-28,0),drawDir,startOrigin+(drawDir.Unit*5),safeAirtime)
        beam.CurveSize0=curve0; beam.CurveSize1=curve1
        if attach0 and attach1 then
            attach0.WorldCFrame=cf1; attach1.WorldCFrame=cf2
            attach0.WorldPosition=Vector3.new(cf1.X,cf1.Y,cf1.Z); attach1.WorldPosition=Vector3.new(cf2.X,cf2.Y,cf2.Z)
            if posPart then posPart.Position=Vector3.new(attach1.WorldPosition.X,attach1.WorldPosition.Y,attach1.WorldPosition.Z) end
        end
    else
        if beam then beam.Enabled=false end
        if posPart then posPart.Position=Vector3.new(0,-9999,0) end
        if attach0 then attach0.WorldPosition=Vector3.new(0,-9999,0) end
        if attach1 then attach1.WorldPosition=Vector3.new(0,-9999,0) end
    end
end)

-- // Catching logic
local player = game:GetService("Players").LocalPlayer
local part = Instance.new("Part")
part.Color=Color3.fromRGB(255,255,255); part.Shape=Enum.PartType.Ball
part.Material=Enum.Material.ForceField; part.CastShadow=false
part.Anchored=true; part.CanCollide=false

local findClosestBall = function()
    local character=player.Character; if not character then return end
    local humanoidRootPart=character:FindFirstChild("HumanoidRootPart"); if not humanoidRootPart then return end
    local dist=math.huge; local ball=nil
    for _,v in next,workspace:GetChildren() do
        if not v:IsA("BasePart") then continue end; if v.Name~="Football" then continue end
        local distance=(v.Position-humanoidRootPart.Position).Magnitude
        if distance<dist then dist=distance; ball=v end
    end
    return ball
end

local selectedRange = function()
    local range=tonumber(magnetsRadius.Value) or 0; local mode=tostring(magsType.Value or "Custom"):lower()
    if mode=="legit" then return range/2
    elseif mode=="league" then return range/1.4
    elseif mode=="blatant" then return range*1.5 end
    return range
end

task.spawn(function()
    while true do
        task.wait()
        local character=player.Character; if not character then continue end
        local humanoid=character:FindFirstChildOfClass("Humanoid"); if not humanoid then continue end
        local ball=findClosestBall(); if not ball then continue end
        local range=selectedRange()
        part.Size=Vector3.new(range,range,range); part.CFrame=CFrame.new(ball.Position)
        part.Parent=(footballMagnets.Value and showCatchHitbox.Value) and workspace.Terrain or nil
        for _,v in next,character:GetChildren() do
            if not v:IsA("BasePart") then continue end
            if not v.Name:lower():find("catch") then continue end
            local distance=(ball.Position-v.Position).Magnitude
            if freeFallCheck.Value and humanoid:GetState()~=Enum.HumanoidStateType.Freefall then continue end
            if footballMagnets.Value and distance<range then
                tweenService:Create(v,TweenInfo.new(magnetsDelay.Value),{Position=ball.Position}):Play()
                pcall(function() firetouchinterest(v,ball,0); firetouchinterest(v,ball,1) end)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if not magEnhancer.Value then continue end
        local character=player.Character; if not character then continue end
        local humanoidRootPart=character:FindFirstChild("HumanoidRootPart"); if not humanoidRootPart then continue end
        local ball=findClosestBall(); if not ball then continue end
        local verticalDistance=ball.Position.Y-humanoidRootPart.Position.Y
        if verticalDistance>(magEnhancerMaxAngle.Value) then continue end
        local lookVector=humanoidRootPart.CFrame.LookVector
        local dir=(ball.Position-humanoidRootPart.Position).Unit
        local dot=lookVector:Dot(dir)
        for _,v in next,character:GetChildren() do
            if not v:IsA("BasePart") then continue end; if not v.Name:lower():find("catch") then continue end
            local distance=(ball.Position-v.Position).Magnitude
            if dot>0 and distance<=magEnhancerRadius.Value then
                tweenService:Create(v,TweenInfo.new(0),{Position=ball.Position}):Play()
                pcall(function() firetouchinterest(v,ball,0); firetouchinterest(v,ball,1) end)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if not pullVector.Value then continue end
        local character=player.Character; if not character then continue end
        local humanoidRootPart=character:FindFirstChild("HumanoidRootPart"); if not humanoidRootPart then continue end
        local ball=findClosestBall(); if not ball then continue end
        local distance=(ball.Position-humanoidRootPart.Position).Magnitude
        if distance>pullVectorRadius.Value then continue end
        local dir=(ball.Position-humanoidRootPart.Position).Unit
        humanoidRootPart.AssemblyLinearVelocity=dir*(pullVectorPower.Value*25)
    end
end)

task.spawn(function()
    while true do
        task.wait()
        local character=player.Character; if not character then continue end
        for _,v in next,character:GetChildren() do
            if not v:IsA("BasePart") then continue end; if not v.Name:lower():find("t arm") then continue end
            v.Size=Vector3.new(v.Size.X,increaseArmSize.Value and armSizeValue.Value or 2,v.Size.Z)
        end
    end
end)

-- // Player tab logic
task.spawn(function()
    while true do
        task.wait()
        if not customWalkSpeed.Value then continue end
        local character=player.Character; if not character then continue end
        local humanoid=character:FindFirstChildOfClass("Humanoid"); if not humanoid then continue end
        if humanoid.PlatformStand then continue end; if humanoid.WalkSpeed==0 then continue end
        local root=character:FindFirstChild("HumanoidRootPart"); if not root then continue end
        local direction=Vector3.new(humanoid.MoveDirection.X,0,humanoid.MoveDirection.Z)
        if direction.Magnitude<=0 then continue end
        local velocity=direction.Unit*(walkspeedType.Value=="CFrame" and (walkSpeedValue.Value/75) or walkSpeedValue.Value)
        if humanoid:GetState()==Enum.HumanoidStateType.Running then
            local scale=walkSpeedValue.Value/math.max(humanoid.WalkSpeed,1)
            local animator=humanoid:FindFirstChildOfClass("Animator")
            if animator then for _,track in next,animator:GetPlayingAnimationTracks() do track:AdjustSpeed(scale) end end
        end
        if walkspeedType.Value~="CFrame" then root.AssemblyLinearVelocity=Vector3.new(velocity.X,root.AssemblyLinearVelocity.Y,velocity.Z)
        else root.CFrame=root.CFrame+velocity end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if not customJumpPower.Value then continue end
        local character=player.Character; if not character then continue end
        local humanoid=character:FindFirstChildOfClass("Humanoid"); if not humanoid then continue end
        local root=character:FindFirstChild("HumanoidRootPart"); if not root then continue end
        if humanoid:GetState()~=Enum.HumanoidStateType.Jumping then continue end
        task.wait()
        root.AssemblyLinearVelocity=Vector3.new(root.AssemblyLinearVelocity.X,jumpPowerValue.Value,root.AssemblyLinearVelocity.Z)
    end
end)

local lastTick=0; local oldLookVector=nil
task.spawn(function()
    while true do
        task.wait()
        if not angleEnhancer.Value then continue end
        local character=player.Character; if not character then oldLookVector=nil; continue end
        local humanoid=character:FindFirstChildOfClass("Humanoid")
        local hrp=character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not hrp then oldLookVector=nil; continue end
        if humanoid:GetState()~=Enum.HumanoidStateType.Jumping then continue end
        local currentTime=tick(); local newLookVector=hrp.CFrame.LookVector
        if not oldLookVector then oldLookVector=newLookVector; lastTick=currentTime; continue end
        local angleChange=math.acos(math.clamp(oldLookVector:Dot(newLookVector),-1,1))
        local shiftLockEnabled=userInputService.MouseBehavior==Enum.MouseBehavior.LockCenter
        if currentTime-lastTick>=0.2 and angleChange>math.rad(5) then lastTick=currentTime; oldLookVector=newLookVector end
        if angleChange>math.rad(25) and currentTime-lastTick<=2.5 then
            lastTick=currentTime; oldLookVector=newLookVector; task.wait()
            local vel=hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity=Vector3.new(vel.X,angleEnhanceBoost.Value,vel.Z)
            if angleEnhancerIndicator.Value then
                local hint=Instance.new("Hint"); hint.Text="Angled!"; hint.Parent=workspace.Terrain
                task.delay(2.5,function() if hint then hint:Destroy() end end)
            end
        end
    end
end)

local runtime,jumptime,hittime=0,0,0
local arm,vLine,used,prevPs=false,nil,false,false
local seq=0; local pack=nil
local xz=function(v) local f=Vector3.new(v.X,0,v.Z); return f.Magnitude>0.001 and f.Unit or nil end
local reset=function()
    if not pack then return end
    for _,o in next,{pack.spin,pack.ra,pack.pivot,pack.ha} do if o then o:Destroy() end end
    pack=nil
end
local flip=function(root,head)
    reset()
    local m=math.max(root.AssemblyMass,1)
    local ha=Instance.new("Attachment"); ha.Parent=head
    local pivot=Instance.new("AlignPosition"); pivot.Mode=Enum.PositionAlignmentMode.OneAttachment
    pivot.Attachment0=ha; pivot.Position=head.Position+Vector3.new(0,0.15,0)
    pivot.MaxForce=180000; pivot.Responsiveness=120; pivot.RigidityEnabled=false
    pivot.ApplyAtCenterOfMass=false; pivot.Parent=head
    local ra=Instance.new("Attachment"); ra.Parent=root
    local spin=Instance.new("AngularVelocity"); spin.Attachment0=ra
    spin.RelativeTo=Enum.ActuatorRelativeTo.Attachment0; spin.AngularVelocity=Vector3.new(-9,0,0)
    spin.MaxTorque=50000; spin.Parent=root
    root:ApplyAngularImpulse(root.CFrame.RightVector*(-16*m))
    pack={ha=ha,pivot=pivot,ra=ra,spin=spin}
end

task.spawn(function()
    while true do
        task.wait()
        if not autoFlip.Value then continue end
        local char=player.Character; if not char then reset(); arm,vLine,used,prevPs=false,nil,false,false; continue end
        local hum=char:FindFirstChildOfClass("Humanoid")
        local hrp=char:FindFirstChild("HumanoidRootPart"); local head=char:FindFirstChild("Head")
        if not hum or not hrp or not head then continue end
        local now=tick()
        if hum:GetState()==Enum.HumanoidStateType.Running then runtime=now end
        if hum:GetState()==Enum.HumanoidStateType.Jumping then jumptime=now end
        local ps=hum.PlatformStand
        if ps~=prevPs then
            if ps then arm=(now-runtime<=0.5) and (now-jumptime<=0.7); vLine=xz(hrp.AssemblyLinearVelocity) or xz(hrp.CFrame.LookVector); used=false
            else arm,vLine,used=false,nil,false; seq+=1; reset() end
            prevPs=ps
        end
        if not ps or not arm or pack then continue end
        local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={char}
        local result=workspace:Raycast(head.Position,Vector3.new(0,-3,0),params)
        local ground=result and result.Instance~=nil
        if used or not ground or now-hittime<0.12 then continue end
        local dist=result and (head.Position-result.Position).Magnitude or math.huge
        if dist>1.6 then continue end
        local move=xz(hrp.AssemblyLinearVelocity) or vLine; local face=xz(hrp.CFrame.LookVector)
        if not move or not face or face:Dot(move)<0.78 then continue end
        hittime=now; used=true; seq+=1; local k=seq; flip(hrp,head)
        task.delay(0.24,function() if k==seq then reset() end end)
    end
end)

-- // Physics tab logic
task.spawn(function()
    while true do
        task.wait()
        if antiBench.Value then
            local playerGui=player:FindFirstChild("PlayerGui"); if not playerGui then continue end
            local benchButton=playerGui:FindFirstChild("Benched",true); if not benchButton then continue end
            if benchButton.BackgroundColor3==Color3.fromRGB(120,120,120) then
                replicatedStorage.Remotes.CharacterSoundEvent:FireServer("Game","ToggleBench")
            end
        end
        if antiJumpCooldown.Value then player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,true) end
        if antiFreeze.Value then if player.Character.Humanoid.WalkSpeed~=20 then player.Character.Humanoid.WalkSpeed=20 end end
        for _,v in next,players:GetPlayers() do
            if v==player then continue end
            local character=v.Character; if not character then continue end
            local hum=character:FindFirstChildOfClass("Humanoid"); if not hum then continue end
            for _,part in next,character:GetChildren() do
                if not part:IsA("BasePart") then continue end
                if part.Name=="Head" or part.Name=="Torso" then
                    if hum:GetState()==Enum.HumanoidStateType.Running then part.CanCollide=not antiJam.Value
                    else part.CanCollide=true end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if not antiBlock.Value then continue end
        local character=player.Character; if not character then continue end
        local humanoid=character:FindFirstChildOfClass("Humanoid"); if not humanoid then continue end
        for _,v in next,character:GetDescendants() do
            if not v:IsA("BodyVelocity") then continue end
            v.Velocity=Vector3.zero; v.MaxForce=Vector3.zero; humanoid.WalkSpeed=20
            pcall(function() v:Destroy() end)
        end
    end
end)

userInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if not quickTP.Value then return end
    if input.KeyCode~=HideKeybind.Value and input.UserInputType~=Enum.UserInputType.Touch then return end
    local character=player.Character; if not character then return end
    local hrp=character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    hrp.CFrame+=hrp.CFrame.LookVector*quickTPPower.Value
end)

task.spawn(function()
    while true do
        task.wait()
        for _,v in next,players:GetPlayers() do
            if v==player then continue end
            local character=v.Character; if not character then continue end
            local head=character:FindFirstChild("Head"); if not head then continue end
            head.Size=Vector3.new(bigHead.Value and bigHeadSize.Value or 1,bigHead.Value and bigHeadSize.Value or 1,bigHead.Value and bigHeadSize.Value or 1)
        end
    end
end)

-- // Visual tab logic
workspace.ChildAdded:Connect(function(v)
    if not jumpSpot.Value then return end
    if not v:IsA("BasePart") or v.Name~="Football" then return end
    task.wait()
    local position=v.Position; local velocity=v.AssemblyLinearVelocity; local gravity=Vector3.new(0,-28,0); local deltaTime=1/30
    local positions={position}
    local raycastParams=RaycastParams.new(); raycastParams.FilterType=Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances={v}; raycastParams.IgnoreWater=true
    for _=1,300 do
        local nextPosition=position+velocity*deltaTime+0.5*gravity*deltaTime^2
        velocity+=gravity*deltaTime
        if velocity.Y<0 then
            local direction=nextPosition-position
            local result=workspace:Raycast(position,direction+Vector3.new(0,-14.4,0),raycastParams)
            if result then nextPosition=result.Position; table.insert(positions,nextPosition); break end
        end
        table.insert(positions,nextPosition); position=nextPosition
    end
    local optimalPoint=positions[#positions]
    local model=Instance.new("Model"); model.Parent=workspace
    local baseY=optimalPoint.Y-1.5; local undergroundY=baseY-6
    local gradientCylinder=Instance.new("MeshPart")
    gradientCylinder.MeshId="rbxassetid://8091779363"; gradientCylinder.Material=Enum.Material.Plastic
    gradientCylinder.Size=Vector3.new(2,4,2); gradientCylinder.Rotation=Vector3.new(180,0,180)
    gradientCylinder.Transparency=1; gradientCylinder.Anchored=true; gradientCylinder.CanCollide=false
    gradientCylinder.Position=Vector3.new(optimalPoint.X,undergroundY,optimalPoint.Z); gradientCylinder.Parent=model
    for _,face in next,{Enum.NormalId.Front,Enum.NormalId.Back,Enum.NormalId.Left,Enum.NormalId.Right} do
        local decal=Instance.new("Decal"); decal.Face=face; decal.Texture="rbxassetid://8097185954"
        decal.Transparency=0; decal.Color3=Color3.fromRGB(255,255,255); decal.Parent=gradientCylinder
    end
    local glowCircle=Instance.new("MeshPart"); glowCircle.MeshId="rbxassetid://8091848285"
    glowCircle.Material=Enum.Material.Neon; glowCircle.Color=Color3.fromRGB(255,255,255)
    glowCircle.Size=Vector3.new(3.731,0.031,3.731); glowCircle.Rotation=Vector3.new(180,0,180)
    glowCircle.Transparency=1; glowCircle.Anchored=true; glowCircle.CanCollide=false
    glowCircle.Position=Vector3.new(optimalPoint.X,undergroundY,optimalPoint.Z); glowCircle.Parent=model
    local emitter=Instance.new("ParticleEmitter"); emitter.Texture="rbxasset://textures/particles/sparkles_main.dds"
    emitter.Rate=5; emitter.Speed=NumberRange.new(5,5); emitter.Lifetime=NumberRange.new(0.5,0.5)
    emitter.EmissionDirection=Enum.NormalId.Top; emitter.TimeScale=0.3
    emitter.Color=ColorSequence.new(Color3.fromRGB(255,255,255)); emitter.Parent=gradientCylinder
    local bottomPart=Instance.new("Part"); bottomPart.Size=Vector3.new(0.311,0.311,0.311)
    bottomPart.Transparency=1; bottomPart.Material=Enum.Material.Plastic; bottomPart.Anchored=true
    bottomPart.CanCollide=false; bottomPart.Position=Vector3.new(optimalPoint.X,undergroundY,optimalPoint.Z); bottomPart.Parent=model
    local pointLight=Instance.new("PointLight"); pointLight.Color=Color3.fromRGB(255,255,255)
    pointLight.Range=12; pointLight.Brightness=2; pointLight.Parent=bottomPart
    local tweenInfo=TweenInfo.new(0.55,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
    local upGoal={Position=Vector3.new(optimalPoint.X,baseY,optimalPoint.Z)}
    local downGoal={Position=Vector3.new(optimalPoint.X,undergroundY,optimalPoint.Z)}
    for _,t in next,{tweenService:Create(gradientCylinder,tweenInfo,upGoal),tweenService:Create(glowCircle,tweenInfo,upGoal),tweenService:Create(bottomPart,tweenInfo,upGoal)} do t:Play() end
    task.spawn(function()
        while v and v.Parent and v.AssemblyLinearVelocity.Magnitude>1 do task.wait() end
        for _,t in next,{tweenService:Create(gradientCylinder,tweenInfo,downGoal),tweenService:Create(glowCircle,tweenInfo,downGoal),tweenService:Create(bottomPart,tweenInfo,downGoal)} do t:Play() end
        task.wait(0.4); if model.Parent then model:Destroy() end
    end)
end)

workspace.ChildAdded:Connect(function(v)
    if not throwSpot.Value then return end
    if not v:IsA("BasePart") or v.Name~="Football" then return end
    task.wait()
    local pos=v.Position; local vel=v.AssemblyLinearVelocity; local gravity=Vector3.new(0,-28,0)
    local positions={}; local parts={}; local dt=0.05; local maxTime=8; local lastPos=pos; local spawnY=pos.Y
    for t=0,maxTime,dt do
        local projectilePos=pos+(vel*t)+(0.5*gravity*t*t); table.insert(positions,projectilePos)
        if projectilePos.Y<spawnY then break end
        local ray=workspace:Raycast(lastPos,projectilePos-lastPos)
        if ray then positions[#positions]=ray.Position; break end; lastPos=projectilePos
    end
    local endPos=positions[#positions]; if not endPos then return end
    local posPart2=Instance.new("Part",workspace.Terrain); posPart2.Anchored=true; posPart2.CanCollide=false
    posPart2.CastShadow=false; posPart2.Size=Vector3.new(3,3,3); posPart2.Shape=Enum.PartType.Ball
    posPart2.Color=Color3.fromRGB(0,0,0); posPart2.Position=endPos
    for i=1,#positions-1 do
        local p0=positions[i]; local p1=positions[i+1]
        local beamPart=Instance.new("Part",workspace.Terrain); beamPart.Anchored=true; beamPart.CanCollide=false
        beamPart.CastShadow=false; beamPart.Material=Enum.Material.Neon; beamPart.Color=Color3.fromRGB(255,255,255)
        local dist=(p1-p0).Magnitude; beamPart.Size=Vector3.new(0.4,0.4,dist)
        beamPart.CFrame=CFrame.lookAt((p0+p1)/2,p1); table.insert(parts,beamPart)
    end
    task.spawn(function()
        local speed=math.max(vel.Magnitude,1); local delayTime=math.clamp(300/speed,0.01,0.04)
        for _,part2 in next,parts do task.wait(delayTime); if part2.Parent then part2:Destroy() end end
        if posPart2.Parent then posPart2:Destroy() end
    end)
end)

task.spawn(function()
    while true do
        task.wait()
        local character=player.Character; if not character then continue end
        local uniform=character:FindFirstChild("Uniform"); if not uniform then continue end
        local gloveVisible; for _,v in next,uniform:GetDescendants() do
            if not v:IsA("BasePart") then continue end; if not v.Name:lower():find("glove") then continue end
            gloveVisible=v.Transparency==0; break
        end
        if gloveVisible==nil then continue end
        if enableGloves.Value and not gloveVisible then
            replicatedStorage.Remotes.CharacterSoundEvent:FireServer("Game","Customization","Toggle","LeftGlove")
            replicatedStorage.Remotes.CharacterSoundEvent:FireServer("Game","Customization","Toggle","RightGlove")
        elseif not enableGloves.Value and gloveVisible then
            replicatedStorage.Remotes.CharacterSoundEvent:FireServer("Game","Customization","Toggle","LeftGlove")
            replicatedStorage.Remotes.CharacterSoundEvent:FireServer("Game","Customization","Toggle","RightGlove")
        end
    end
end)

workspace.ChildAdded:Connect(function(v)
    if not noBallTrail.Value then return end
    if v:IsA("BasePart") and v.Name=="Football" then
        local trail=v:FindFirstChildOfClass("Trail"); if trail then trail:Destroy() end
    end
end)

-- // Defense tab logic
task.spawn(function()
    while true do
        task.wait()
        if not swatReach.Value then continue end
        local character=player.Character; if not character then continue end
        local ball=findClosestBall(); if not ball then continue end
        for _,v in next,character:GetChildren() do
            if v:IsA("BasePart") and v.Name:lower():find("catch") then
                local distance=(ball.Position-v.Position).Magnitude
                if distance<swatReachDistance.Value then
                    if v.Size.X>2 then pcall(function() firetouchinterest(v,ball,0); firetouchinterest(v,ball,1) end) end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        local character=player.Character; if not character then continue end
        if tackleReach.Value then
            for _,v in next,players:GetPlayers() do
                if v~=player and v.Team~=player.Team and v.Character and v.Character:FindFirstChild("Football") then
                    local bodyParts={"Torso","Head","HumanoidRootPart","Left Arm","Left Leg","Right Arm","Right Leg"}
                    local randomPart=bodyParts[math.random(1,#bodyParts)]
                    replicatedStorage.Remotes.CharacterSoundEvent:FireServer("Game","TackleTouch",randomPart,randomPart)
                end
            end
        end
        if tackleAimbot.Value then
            for _,v in next,players:GetPlayers() do
                if v~=player and v.Team~=player.Team and v.Character and v.Character.Humanoid.WalkSpeed>0 and v.Character:FindFirstChild("Football") then
                    local distance=(v.Character.HumanoidRootPart.Position-character.HumanoidRootPart.Position).Magnitude
                    if distance<tackleAimbotRange.Value then
                        character.HumanoidRootPart.CFrame=v.Character.HumanoidRootPart.CFrame
                    end
                end
            end
        end
    end
end)

-- // Automatics tab logic
task.spawn(function()
    while true do
        task.wait()
        if not autoRush.Value then continue end
        local character=player.Character; if not character then continue end
        local humanoid=character:FindFirstChildOfClass("Humanoid"); if not humanoid then continue end
        local hrp=character:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
        if walkToLine.Value then
            if replicatedStorage:FindFirstChild("Flags")
                and replicatedStorage.Flags:FindFirstChild("PossessionTag")
                and replicatedStorage.Flags:FindFirstChild("Status")
                and replicatedStorage.Flags.PossessionTag.Value~=player.Team.Name
                and replicatedStorage.Flags.Status.Value=="PrePlay" then
                local line=workspace:FindFirstChild("LineDown"); if line then humanoid:MoveTo(line.Position) end
            end
        end
        for _,v in next,players:GetPlayers() do
            if v==player then continue end; if v.Team==player.Team then continue end; if not v.Character then continue end
            local enemyChar=v.Character; local enemyHumanoid=enemyChar:FindFirstChildOfClass("Humanoid")
            local enemyHrp=enemyChar:FindFirstChild("HumanoidRootPart"); if not enemyHumanoid or not enemyHrp then continue end
            local football=enemyChar:FindFirstChild("Football"); if not football then continue end
            local footballPart=football:FindFirstChildWhichIsA("BasePart"); if not footballPart then continue end
            if enemyHumanoid.WalkSpeed<=0 then continue end; if enemyHumanoid.PlatformStand then continue end
            local ping=0
            if stats and stats:FindFirstChild("Network") and stats.Network:FindFirstChild("ServerStatsItem") and stats.Network.ServerStatsItem:FindFirstChild("Data Ping") then
                ping=stats.Network.ServerStatsItem["Data Ping"]:GetValue()/1000
            end
            local speed=enemyHumanoid.MoveDirection.Magnitude>0 and enemyHumanoid.WalkSpeed or 0
            local predictionTime=ping+autoRushReactionTime.Value
            local pos=footballPart.Position+(enemyHumanoid.MoveDirection*speed*predictionTime*20)
            local direction2=pos-enemyHrp.Position
            if direction2.Magnitude>0 then pos=pos+(direction2.Unit*((hrp.Position-pos).Magnitude/20)) end
            humanoid:MoveTo(pos)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if not autoCatch.Value and not autoSwat.Value then continue end
        local character=player.Character; if not character then continue end
        local humanoidRootPart=character:FindFirstChild("HumanoidRootPart"); if not humanoidRootPart then continue end
        local ball=findClosestBall(); if not ball then continue end
        local distance=(ball.Position-humanoidRootPart.Position).Magnitude
        if autoCatch.Value and distance<=autoCatchRadius.Value then
            replicatedStorage.Remotes.CharacterSoundEvent:FireServer("PlayerActions",isPractice and "catch " or "catch")
        end
        if autoSwat.Value and distance<=autoSwatRadius.Value then
            replicatedStorage.Remotes.CharacterSoundEvent:FireServer("PlayerActions","swat")
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if not autoCaptain.Value then continue end
        local character=player.Character; if not character then continue end
        local hrp=character:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
        for _,v in next,workspace.Models.LockerRoomA:GetChildren() do
            if v.Name:lower():find("finishline") and not player.Team then
                v:GetPropertyChangedSignal("CFrame"):Connect(function()
                    for i=1,4 do task.wait(); hrp.CFrame=v.CFrame end
                end)
            end
        end
    end
end)

userInputService.InputBegan:Connect(function(input)
    if not autoFreeze.Value then return end
    if freezeKeybind.Value and input.KeyCode~=freezeKeybind.Value then return end
    local character=player.Character; if not character then return end
    local hrp=character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    hrp.Anchored=true
    task.delay(freezeDuration.Value,function() if hrp then hrp.Anchored=false end end)
end)

task.spawn(function()
    while true do
        task.wait()
        if not autoQb.Value then continue end
        local character=player.Character; if not character then continue end
        local humanoid=character:FindFirstChildOfClass("Humanoid"); local humanoidRootPart=character:FindFirstChild("HumanoidRootPart")
        if not humanoid or not humanoidRootPart then continue end
        local ball=findClosestBall(); if not ball then continue end
        if replicatedStorage:FindFirstChild("Flags") and replicatedStorage.Flags:FindFirstChild("PossessionTag") and replicatedStorage.Flags:FindFirstChild("Status")
            and replicatedStorage.Flags.PossessionTag.Value==player.Team.Name and replicatedStorage.Flags.Status.Value=="PrePlay" then
            if autoQbMethod.Value=="Walk" then humanoid:MoveTo(ball.Position)
            elseif autoQbMethod.Value=="Teleport" then humanoidRootPart.CFrame=ball.CFrame end
        else pcall(function() ball.CFrame=humanoidRootPart.CFrame end) end
    end
end)

task.spawn(function()
    local activeTween
    while true do
        task.wait()
        if not autoBoost.Value then if activeTween then activeTween:Cancel(); activeTween=nil end; continue end
        local char=player.Character; if not char then continue end
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then continue end
        local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
        if hum:GetState()==Enum.HumanoidStateType.Landed then if activeTween then activeTween:Cancel(); activeTween=nil end; continue end
        local myHead=char:FindFirstChild("Head"); if not myHead then continue end
        local targetPlayer2
        if targetClosestPlayer.Value then
            local nearestBall; local nearestBallDist=math.huge
            for _,ball in next,workspace:GetChildren() do
                if not ball:IsA("BasePart") then continue end; if not ball.Name:lower():find("ball") then continue end
                local dist=(ball.Position-myHead.Position).Magnitude; if dist<nearestBallDist then nearestBallDist=dist; nearestBall=ball end
            end
            if not nearestBall then continue end
            local closestDist=math.huge
            for _,v in next,players:GetPlayers() do
                if v==player then continue end; local character2=v.Character; if not character2 then continue end
                local head2=character2:FindFirstChild("Head"); if not head2 then continue end
                local dist=(head2.Position-nearestBall.Position).Magnitude
                if dist<closestDist then closestDist=dist; targetPlayer2=v end
            end
        else
            local closestDist=math.huge
            for _,v in next,players:GetPlayers() do
                if v==player then continue end; local character2=v.Character; if not character2 then continue end
                local head2=character2:FindFirstChild("Head"); if not head2 then continue end
                local dist=(head2.Position-myHead.Position).Magnitude
                if dist<closestDist then closestDist=dist; targetPlayer2=v end
            end
        end
        if not targetPlayer2 then continue end
        local character2=targetPlayer2.Character; if not character2 then continue end
        local head2=character2:FindFirstChild("Head"); if not head2 then continue end
        local targetHumanoid2=character2:FindFirstChildOfClass("Humanoid"); if not targetHumanoid2 then continue end
        local myState=hum:GetState(); local targetState=targetHumanoid2:GetState()
        local distance=(head2.Position-myHead.Position).Magnitude
        if distance>boostRadius.Value then continue end
        if myState~=Enum.HumanoidStateType.Jumping and myState~=Enum.HumanoidStateType.Freefall then continue end
        if targetState~=Enum.HumanoidStateType.Jumping and targetState~=Enum.HumanoidStateType.Freefall then continue end
        local speed2=math.max(hum.WalkSpeed*boostStrength.Value,1)
        local targetPos=head2.Position; local duration=math.max((hrp.Position-targetPos).Magnitude/speed2,0.01)
        if activeTween then activeTween:Cancel() end
        activeTween=tweenService:Create(hrp,TweenInfo.new(duration,Enum.EasingStyle.Linear),{CFrame=CFrame.new(targetPos)})
        activeTween:Play()
        activeTween.Completed:Once(function(state)
            if state~=Enum.PlaybackState.Completed then return end
            hrp.AssemblyLinearVelocity=Vector3.new(hrp.AssemblyLinearVelocity.X,boostPower.Value,hrp.AssemblyLinearVelocity.Z)
        end)
    end
end)

-- // Misc tab logic
task.spawn(function()
    while true do task.wait(); setfpscap(fpsCap.Value) end
end)

task.spawn(function()
    while task.wait() do
        local playerGui=player:FindFirstChild("PlayerGui"); if not playerGui then continue end
        local miscText=playerGui:FindFirstChild("MiscText"); if not miscText then continue end
        local isVIP=miscText:FindFirstChild("IsVIP"); if not isVIP then continue end
        if isVIP.Visible==true then continue end
        for _,admin in next,players:GetPlayers() do
            if admin==player then continue end
            local swagData=admin:FindFirstChild("SwagData"); if not swagData then continue end
            local adminTag=swagData:FindFirstChild("Admin"); if not adminTag then continue end
            if adminTag.Value~="" and antiAdmin.Value then
                player:Kick("[67 FF3] Detected Admin\nName: "..admin.Name.."\nID: "..admin.UserId)
            end
        end
    end
end)

if not isPractice then
    local remote=replicatedStorage:WaitForChild("Remotes"):WaitForChild("CharacterSoundEvent")
    local heartbeat=runService.Heartbeat
    local transition=player:WaitForChild("PlayerGui"):WaitForChild("MainGui"):WaitForChild("Transition")
    local homeCamera=CFrame.Angles(-0.2617993877991494,0,0)
    local awayCamera=CFrame.Angles(0.2617993877991494,math.pi,0)
    local cameraOffset=CFrame.new(0,0,19)
    local limbs={"Torso","Left Arm","Right Arm","Left Leg","Right Leg","Head"}

    task.spawn(function()
        while true do
            task.wait()
            local replayScript=player.PlayerScripts:FindFirstChild("ClientReplay")
            if replayScript then replayScript.Enabled=not smoothReplay.Value end
        end
    end)

    local replay=function(data,characters)
        local replayBall=workspace:WaitForChild("ReplayBall"); local cam=workspace.CurrentCamera
        cam.CameraType=Enum.CameraType.Scriptable; cam.CameraSubject=replayBall
        local cameraRotation=data.changes[1].poss=="h" and homeCamera or awayCamera
        local currentChange=1; local highestY=18; local cameraTilt=true
        local playback=1; local recordedFPS=data.fps; local accumulator=0; local last=tick()
        local getFrame=function(index) local maxFrames=#data.ball; if index<1 then return 1 end; if index>maxFrames then return maxFrames end; return index end
        local interpolate=function(a,b,alpha) return a:Lerp(b,alpha) end
        while playback<#data.ball do
            if replicatedStorage.Flags.StatusTag.Value~="REPLAY" then break end
            if cam.CameraType~=Enum.CameraType.Scriptable then break end
            local replayFPSValue=replayFPS.Value; local replayDelta=1/replayFPSValue
            local now=tick(); accumulator+=now-last; last=now
            while accumulator>=replayDelta do playback+=recordedFPS/replayFPSValue; accumulator-=replayDelta end
            local frame1=getFrame(math.floor(playback)); local frame2=getFrame(math.ceil(playback)); local alpha=playback-frame1
            for _,character in next,characters do
                local characterData=data.limbs[character.Name]; if not characterData then character.Parent=nil; continue end
                local limbData=characterData[1]; local accessoryData=characterData[2]
                if not limbData[1] then character.Parent=nil; continue end
                local torso1=limbData[1][2][frame1]; local torso2=limbData[1][2][frame2]
                if not torso1 or not torso2 then character.Parent=nil; continue end
                local torso=interpolate(torso1,torso2,alpha)
                for i=1,#limbs do
                    local limbName=limbs[i]; local limb=character:FindFirstChild(limbName); if not limb then continue end
                    local replayLimb=limbData[i]; if not replayLimb then continue end
                    local cf1_r=replayLimb[2][frame1]; local cf2_r=replayLimb[2][frame2]
                    if i==4 then
                        if cf1_r and cf2_r then
                            local angle2=cf1_r+((cf2_r-cf1_r)*alpha)
                            limb.CFrame=torso*CFrame.new(-0.5,-1,0)*CFrame.fromOrientation(angle2,0,0)*CFrame.new(0,-1,0)
                        end
                    elseif i==5 then
                        if cf1_r and cf2_r then
                            local angle2=cf1_r+((cf2_r-cf1_r)*alpha)
                            limb.CFrame=torso*CFrame.new(0.5,-1,0)*CFrame.fromOrientation(angle2,0,0)*CFrame.new(0,-1,0)
                        end
                    else
                        if cf1_r and cf2_r then limb.CFrame=interpolate(cf1_r,cf2_r,alpha)
                        elseif i==6 then limb.CFrame=torso*CFrame.new(0,1.5,0) end
                    end
                end
                local uniform=character:FindFirstChild("Uniform")
                if accessoryData and uniform then
                    for name,info in next,accessoryData do
                        if uniform:FindFirstChild(name) and character:FindFirstChild(info[1]) then
                            uniform[name].CFrame=character[info[1]].CFrame*info[2]
                        end
                    end
                end
            end
            local ball1=data.ball[frame1]; local ball2=data.ball[frame2]
            if ball1 and ball2 then replayBall.CFrame=interpolate(ball1,ball2,alpha) end
            if highestY<replayBall.Position.Y then highestY=replayBall.Position.Y
            elseif highestY>49 and cameraTilt then
                local x=select(1,cameraRotation:ToOrientation())
                cameraRotation*=CFrame.Angles(x*3*math.clamp((highestY-50)/99,0,1),0,0); cameraTilt=false
            end
            local targetCamera
            if highestY>49 and cameraTilt then
                local x=select(1,cameraRotation:ToOrientation())
                targetCamera=CFrame.new(replayBall.Position)*cameraRotation*CFrame.Angles(x*3*math.clamp((highestY-50)/99,0,1),0,0)*cameraOffset
            else targetCamera=CFrame.new(replayBall.Position)*cameraRotation*cameraOffset end
            cam.CFrame=targetCamera
            local change=data.changes[currentChange]
            if change and change.frame<=frame1 then
                currentChange+=1
                if change.frame==frame1 then
                    if change.poss and (frame1>9 and (change.turnover or highestY>49)) then
                        local nextRotation=change.poss=="h" and homeCamera or awayCamera
                        local duration=(change.turnover==true or replayBall.Position.Y>=13) and 0.5 or (highestY/500)
                        local elapsed=0; local startRotation=cameraRotation
                        while elapsed<duration do
                            elapsed+=heartbeat:Wait()
                            cameraRotation=startRotation:Lerp(nextRotation,math.clamp(elapsed/duration,0,1))
                            cam.CFrame=CFrame.new(replayBall.Position)*cameraRotation*cameraOffset
                        end
                        cameraRotation=nextRotation
                    elseif change.freeze then task.wait(change.freeze) end
                end
            end
            heartbeat:Wait()
        end
        remote:FireServer("ReplayFinished")
        if replicatedStorage.Flags.StatusTag.Value=="REPLAY" then replicatedStorage.Flags.StatusTag.Value="" end
        task.wait(0.2); replayBall:Destroy()
        for _,character in next,characters do character:Destroy() end
        data.t=nil; data.limbs=nil; data.ball=nil
        cam.CameraType=Enum.CameraType.Custom; cam.CameraSubject=player.Character.Humanoid
    end

    remote.OnClientEvent:Connect(function(action,...)
        if action=="ClientReplay" then
            while transition.Position.X.Scale>-2 and transition.Position.X.Scale<-0.5 do task.wait() end
            replay(...)
        end
    end)
end

-- // Done
Notif:Notify("67 FF3 loaded.", 4, "success")
