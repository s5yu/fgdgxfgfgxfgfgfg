--// 67 FF3 | discord.gg/67scripts
--// UI: LinoriaLib (violin-suzutsuki)
--// v2.0 — SmartFit (BETA), Detectors, Reworked Auto Rush

--// 67 FF3 STAFF PANEL — standalone
--// Usage: loadstring(...)() with Key="YOURKEY" appended
--// OR: set _G.FF3_StaffKey = "YOURKEY" before running
if not game:IsLoaded() then game.Loaded:Wait() end
if getgenv and getgenv().FF3_67_Unload then pcall(getgenv().FF3_67_Unload) end
--// ── Key check ──────────────────────────────────────────────────────
local VALID_KEY = "FF3STAFF2025"  -- FILL: change this

-- Accept key from three sources:
-- 1. _G.FF3_StaffKey = "key" set before executing
-- 2. Key="key" parsed out of the script source (via getscriptbytecode stub)
-- 3. prompt on load (fallback)
local function getKey()
    if _G.FF3_StaffKey then return tostring(_G.FF3_StaffKey) end
    -- Try to extract Key= from shared _G namespace (set by loader wrapper)
    if _G.FF3_StaffKeyParam then return tostring(_G.FF3_StaffKeyParam) end
    return nil
end

local inputKey = getKey()
if not inputKey or inputKey ~= VALID_KEY then
    -- Silent fail — no UI, no error, nothing rendered
    return
end

--// ── Services ──────────────────────────────────────────────────────
local Players      = game:GetService('Players')
local RunService   = game:GetService('RunService')
local TweenService = game:GetService('TweenService')
local UIS          = game:GetService('UserInputService')
local lp           = Players.LocalPlayer

while not lp do task.wait() end

--// ── Shared registry (same _G table FF3 v3 writes to) ──────────────
if not _G.FF3_Staff_Registry then _G.FF3_Staff_Registry = {} end
local Registry = _G.FF3_Staff_Registry

--// ── Helpers ────────────────────────────────────────────────────────
local function isEnemy(plr)
    local tc = 0 pcall(function() tc = #game:GetService('Teams'):GetTeams() end)
    return not (tc > 1 and lp.Team ~= nil and plr.Team ~= nil and lp.Team == plr.Team)
end

--// ── GUI Construction ────────────────────────────────────────────────
local sg = Instance.new('ScreenGui')
sg.Name            = 'FF3_StaffPanel'
sg.ResetOnSpawn    = false
sg.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
sg.DisplayOrder    = 999
pcall(function() sg.Parent = (gethui and gethui()) or game:GetService('CoreGui') end)
if not sg.Parent then sg.Parent = lp:WaitForChild('PlayerGui', 10) end

-- ── Theme ──────────────────────────────────────────────────────────
local BG       = Color3.fromRGB(12, 12, 14)
local SURFACE  = Color3.fromRGB(20, 20, 24)
local BORDER   = Color3.fromRGB(45, 45, 52)
local ACCENT   = Color3.fromRGB(90, 180, 255)
local ACCENT2  = Color3.fromRGB(255, 80, 80)
local TEXT     = Color3.fromRGB(220, 220, 230)
local DIM      = Color3.fromRGB(100, 100, 115)
local GREEN    = Color3.fromRGB(80, 220, 120)
local ORANGE   = Color3.fromRGB(255, 160, 60)

local function corner(p, r) Instance.new('UICorner', p).CornerRadius = UDim.new(0, r or 4) end
local function stroke(p, c, t)
    local s = Instance.new('UIStroke', p)
    s.Color = c or BORDER; s.Thickness = t or 1
end
local function setFont(inst, font) pcall(function() inst.Font = font end) end

local function makeFrame(parent, size, pos, bg, bgTrans)
    local f = Instance.new('Frame', parent)
    f.Size = size; f.Position = pos
    f.BackgroundColor3 = bg or SURFACE
    f.BackgroundTransparency = bgTrans or 0
    f.BorderSizePixel = 0
    return f
end

local function makeLabel(parent, text, size, pos, color, textSize, xAlign)
    local l = Instance.new('TextLabel', parent)
    l.Size = size; l.Position = pos; l.BackgroundTransparency = 1
    l.Text = text; l.TextColor3 = color or TEXT; l.TextSize = textSize or 12
    l.TextXAlignment = xAlign or Enum.TextXAlignment.Left
    setFont(l, Enum.Font.Code)
    return l
end

local function makeBtn(parent, text, size, pos, bg, textColor)
    local b = Instance.new('TextButton', parent)
    b.Size = size; b.Position = pos
    b.BackgroundColor3 = bg or SURFACE
    b.BorderSizePixel = 0
    b.Text = text; b.TextColor3 = textColor or TEXT; b.TextSize = 11
    b.AutoButtonColor = false
    setFont(b, Enum.Font.Code)
    corner(b, 3)
    stroke(b)
    -- hover tween
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35,35,42)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = bg or SURFACE}):Play()
    end)
    return b
end

-- ── Main window ────────────────────────────────────────────────────
local WIN_W, WIN_H = 540, 400
local win = makeFrame(sg,
    UDim2.new(0, WIN_W, 0, WIN_H),
    UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
    BG)
corner(win, 6)
stroke(win, BORDER, 1)

-- Title bar
local titleBar = makeFrame(win, UDim2.new(1,0,0,32), UDim2.new(0,0,0,0), Color3.fromRGB(18,18,22))
corner(titleBar, 6)
-- fill bottom corners of title bar
local titleFill = makeFrame(win, UDim2.new(1,0,0,8), UDim2.new(0,0,0,24), Color3.fromRGB(18,18,22))
titleFill.ZIndex = 1

local titleLabel = makeLabel(titleBar, '⚙  67 FF3  STAFF PANEL', UDim2.new(1,-60,1,0), UDim2.new(0,10,0,0), ACCENT, 13)
titleLabel.ZIndex = 2

-- Close button
local closeBtn = makeBtn(titleBar, '✕', UDim2.new(0,26,0,20), UDim2.new(1,-32,0,6), BG, ACCENT2)
closeBtn.ZIndex = 3
closeBtn.MouseButton1Click:Connect(function() win.Visible = false end)

-- Drag
local dragging, dragStart, startPos = false, nil, nil
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position
        startPos = win.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        win.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- ── Tab bar ────────────────────────────────────────────────────────
local TAB_Y = 36
local tabBar = makeFrame(win, UDim2.new(1,0,0,28), UDim2.new(0,0,0,TAB_Y), Color3.fromRGB(15,15,18))
local tabLayout = Instance.new('UIListLayout', tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0,2)

local CONTENT_Y = TAB_Y + 28
local contentArea = makeFrame(win,
    UDim2.new(1,-16,1,-(CONTENT_Y+8)),
    UDim2.new(0,8,0,CONTENT_Y+4),
    BG)
contentArea.ClipsDescendants = true

-- Tab system
local tabs = {}
local activeTab = nil

local function makeTab(name)
    local btn2 = Instance.new('TextButton', tabBar)
    btn2.Size = UDim2.new(0, 120, 1, 0)
    btn2.BackgroundColor3 = Color3.fromRGB(15,15,18)
    btn2.BorderSizePixel = 0
    btn2.Text = name; btn2.TextSize = 11; btn2.TextColor3 = DIM
    setFont(btn2, Enum.Font.Code)
    btn2.AutoButtonColor = false

    local page = makeFrame(contentArea, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), BG)
    page.Visible = false

    local function activate()
        for _, t in next, tabs do
            t.btn.TextColor3 = DIM
            t.btn.BackgroundColor3 = Color3.fromRGB(15,15,18)
            t.page.Visible = false
        end
        btn2.TextColor3 = ACCENT
        btn2.BackgroundColor3 = Color3.fromRGB(22,22,28)
        page.Visible = true
        activeTab = name
    end

    btn2.MouseButton1Click:Connect(activate)
    local entry = {btn=btn2, page=page, activate=activate}
    tabs[name] = entry

    if not activeTab then activate() end
    return page
end

-- ── PAGE: Users ─────────────────────────────────────────────────────
local usersPage = makeTab('Users')

-- Column headers
local function colHead(parent, text, x, w)
    local l = makeLabel(parent, text,
        UDim2.new(0,w,0,14), UDim2.new(0,x,0,2),
        DIM, 10)
    l.TextXAlignment = Enum.TextXAlignment.Left
end
colHead(usersPage, 'NAME',     4,   100)
colHead(usersPage, 'EXECUTOR', 108, 90)
colHead(usersPage, 'FEATURES', 202, 160)
colHead(usersPage, 'JOINED',   366, 60)
colHead(usersPage, 'STATUS',   430, 50)

local divider = makeFrame(usersPage, UDim2.new(1,0,0,1), UDim2.new(0,0,0,17), BORDER)

-- Scroll frame for rows
local scroll = Instance.new('ScrollingFrame', usersPage)
scroll.Size = UDim2.new(1,0,1,-20)
scroll.Position = UDim2.new(0,0,0,19)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = ACCENT
scroll.CanvasSize = UDim2.new(0,0,0,0)
local rowLayout = Instance.new('UIListLayout', scroll)
rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
rowLayout.Padding = UDim.new(0,2)

local selectedName = nil
local rowObjs = {}

local function makeRow(entry, index)
    local row = makeFrame(scroll, UDim2.new(1,-4,0,28), UDim2.new(0,2,0,0),
        index%2==0 and Color3.fromRGB(17,17,21) or Color3.fromRGB(14,14,17))
    row.LayoutOrder = index
    corner(row, 3)

    local function col(text, x, w, color)
        local l = makeLabel(row, text,
            UDim2.new(0,w,0,14), UDim2.new(0,x,0,7),
            color or TEXT, 11)
        l.TextTruncate = Enum.TextTruncate.AtEnd
        return l
    end

    col(entry.name, 4, 100, entry.active and TEXT or DIM)
    col(entry.executor or '?', 108, 90, DIM)

    local feats = {}
    for k, v in next, (entry.features or {}) do if v then feats[#feats+1] = k end end
    col(#feats > 0 and table.concat(feats, ' · ') or '—', 202, 160, ORANGE)
    col(entry.joinTime or '?', 366, 60, DIM)

    local statusColor = entry.active and GREEN or ACCENT2
    local statusText  = entry.active and '● live' or '○ off'
    col(statusText, 430, 60, statusColor)

    -- Click to select
    local overlay = Instance.new('TextButton', row)
    overlay.Size = UDim2.new(1,0,1,0)
    overlay.BackgroundTransparency = 1
    overlay.Text = ''; overlay.ZIndex = 5
    overlay.MouseButton1Click:Connect(function()
        selectedName = entry.name
        -- Highlight selected
        for _, r in next, rowObjs do
            r.BackgroundColor3 = r.LayoutOrder % 2 == 0
                and Color3.fromRGB(17,17,21) or Color3.fromRGB(14,14,17)
        end
        row.BackgroundColor3 = Color3.fromRGB(28,36,48)
    end)

    rowObjs[index] = row
    return row
end

local function refreshUsers()
    -- Clear old rows
    for _, r in next, rowObjs do r:Destroy() end
    rowObjs = {}

    local i = 0
    for _, entry in next, Registry do
        i = i + 1
        makeRow(entry, i)
    end
    -- Also scan in-game players not yet in registry
    for _, plr in next, Players:GetPlayers() do
        local found = false
        for _, e in next, Registry do if e.name == plr.Name then found = true break end end
        if not found then
            i = i + 1
            makeRow({
                name     = plr.Name,
                userId   = plr.UserId,
                executor = 'unregistered',
                joinTime = '?',
                features = {},
                active   = true,
            }, i)
        end
    end

    scroll.CanvasSize = UDim2.new(0, 0, 0, i * 30 + 4)
end

-- ── PAGE: Controls ──────────────────────────────────────────────────
local ctrlPage = makeTab('Controls')

local function ctrlLabel(text, y)
    makeLabel(ctrlPage, text, UDim2.new(1,-8,0,14), UDim2.new(0,6,0,y), DIM, 10)
end
local function ctrlBtn(text, y, color, fn)
    local b = makeBtn(ctrlPage, text,
        UDim2.new(0,160,0,24), UDim2.new(0,6,0,y),
        SURFACE, color or TEXT)
    b.MouseButton1Click:Connect(fn)
    return b
end
local function ctrlBtn2(text, y, color, fn)
    local b = makeBtn(ctrlPage, text,
        UDim2.new(0,160,0,24), UDim2.new(0,180,0,y),
        SURFACE, color or TEXT)
    b.MouseButton1Click:Connect(fn)
    return b
end

local selectedInfo = makeLabel(ctrlPage, 'selected: none', UDim2.new(1,-8,0,14), UDim2.new(0,6,0,4), ACCENT, 11)

local function notify(msg, color)
    local n = makeLabel(ctrlPage, msg,
        UDim2.new(1,-8,0,14), UDim2.new(0,6,0,340), color or GREEN, 11)
    task.delay(3, function() if n and n.Parent then n:Destroy() end end)
end

local function getSelected()
    if not selectedName then notify('no user selected', ACCENT2) return nil end
    selectedInfo.Text = 'selected: ' .. selectedName
    return selectedName
end

local function getSelectedEntry()
    local n = getSelected(); if not n then return nil end
    for _, e in next, Registry do if e.name == n then return e end end
    -- Fall back to in-game player with a stub entry
    local plr = Players:FindFirstChild(n)
    if plr then
        return {name=plr.Name, userId=plr.UserId, executor='unregistered', features={}, active=true}
    end
    notify('user not found in registry', ACCENT2)
    return nil
end

ctrlLabel('── Target ──', 22)
ctrlLabel('Type username from Users tab, or click a row first.', 36)

local nameBox = Instance.new('TextBox', ctrlPage)
nameBox.Size = UDim2.new(0,200,0,22)
nameBox.Position = UDim2.new(0,6,0,52)
nameBox.BackgroundColor3 = Color3.fromRGB(22,22,28)
nameBox.BorderSizePixel = 0
nameBox.Text = ''
nameBox.PlaceholderText = 'username…'
nameBox.TextColor3 = TEXT
nameBox.TextSize = 11
nameBox.ClearTextOnFocus = false
setFont(nameBox, Enum.Font.Code)
corner(nameBox, 3); stroke(nameBox)
nameBox:GetPropertyChangedSignal('Text'):Connect(function()
    selectedName = nameBox.Text ~= '' and nameBox.Text or selectedName
end)

ctrlLabel('── In-game Actions ──', 84)
ctrlBtn('🥾  Kick', 100, ACCENT2, function()
    local n = getSelected(); if not n then return end
    for _, plr in next, Players:GetPlayers() do
        if plr.Name == n then
            pcall(function() plr:Kick('[67 FF3 Staff]') end)
            local r = game:GetService('ReplicatedStorage'):FindFirstChild('Remotes')
            local kr = r and r:FindFirstChild('KickPlayer')
            if kr then pcall(function() kr:FireServer(plr) end) end
            notify('kick sent to ' .. n)
            return
        end
    end
    notify('not in this server', ACCENT2)
end)

ctrlBtn('🌀  Fling', 130, ORANGE, function()
    local n = getSelected(); if not n then return end
    for _, plr in next, Players:GetPlayers() do
        if plr.Name == n and plr.Character then
            local hrp = plr.Character:FindFirstChild('HumanoidRootPart')
            if hrp then
                local bv = Instance.new('BodyVelocity')
                bv.Velocity  = Vector3.new(math.random(-1,1)*9999, 9999, math.random(-1,1)*9999)
                bv.MaxForce  = Vector3.new(math.huge, math.huge, math.huge)
                bv.P         = math.huge
                bv.Parent    = hrp
                game:GetService('Debris'):AddItem(bv, 0.18)
                notify('flung ' .. n)
            end
            return
        end
    end
    notify('not in this server', ACCENT2)
end)

ctrlBtn('🔴  Disable Cheats', 160, ACCENT2, function()
    local n = getSelected(); if not n then return end
    for _, e in next, Registry do
        if e.name == n then
            e.active = false
            notify('disabled cheats for ' .. n)
            return
        end
    end
    notify('not in registry', ACCENT2)
end)

ctrlBtn('✅  Re-enable', 190, GREEN, function()
    local n = getSelected(); if not n then return end
    for _, e in next, Registry do
        if e.name == n then
            e.active = true
            notify('re-enabled ' .. n)
            return
        end
    end
    notify('not in registry', ACCENT2)
end)

ctrlBtn2('🚪  Join Game', 100, ACCENT, function()
    local e = getSelectedEntry(); if not e then return end
    pcall(function()
        game:GetService('TeleportService'):Teleport(e.placeId or game.PlaceId, lp)
    end)
end)

ctrlLabel('── Remote Execute ──', 224)
local execBox = Instance.new('TextBox', ctrlPage)
execBox.Size = UDim2.new(1,-12,0,56)
execBox.Position = UDim2.new(0,6,0,240)
execBox.BackgroundColor3 = Color3.fromRGB(16,16,20)
execBox.BorderSizePixel = 0
execBox.Text = ''
execBox.PlaceholderText = 'print("hello from staff")'
execBox.TextColor3 = TEXT
execBox.TextSize = 11
execBox.MultiLine = true
execBox.ClearTextOnFocus = false
execBox.TextXAlignment = Enum.TextXAlignment.Left
execBox.TextYAlignment = Enum.TextYAlignment.Top
setFont(execBox, Enum.Font.Code)
corner(execBox, 3); stroke(execBox)

ctrlBtn('▶  Send to Target', 304, ACCENT, function()
    local n = getSelected(); if not n then return end
    local code = execBox.Text
    if code == '' then notify('no code entered', ACCENT2) return end
    _G['FF3_Staff_Exec_' .. n] = code
    notify('code pushed to ' .. n)
end)

ctrlBtn2('▶  Send to All', 304, ORANGE, function()
    local code = execBox.Text
    if code == '' then notify('no code entered', ACCENT2) return end
    for _, e in next, Registry do
        if e.active then _G['FF3_Staff_Exec_' .. e.name] = code end
    end
    notify('pushed to all active clients')
end)

-- Remote exec poller — staff client also runs the poller
task.spawn(function()
    while true do
        task.wait(1)
        local key2 = 'FF3_Staff_Exec_' .. lp.Name
        local code = _G[key2]
        if type(code) == 'string' and code ~= '' then
            _G[key2] = nil
            local fn, err = loadstring(code)
            if fn then pcall(fn) else warn('[FF3 Staff] exec error: ' .. tostring(err)) end
        end
    end
end)

-- ── PAGE: Log ───────────────────────────────────────────────────────
local logPage = makeTab('Detect Log')

local logScroll = Instance.new('ScrollingFrame', logPage)
logScroll.Size = UDim2.new(1,0,1,0)
logScroll.Position = UDim2.new(0,0,0,0)
logScroll.BackgroundTransparency = 1
logScroll.BorderSizePixel = 0
logScroll.ScrollBarThickness = 3
logScroll.ScrollBarImageColor3 = ACCENT
logScroll.CanvasSize = UDim2.new(0,0,0,0)
local logRowLayout = Instance.new('UIListLayout', logScroll)
logRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
logRowLayout.Padding = UDim.new(0,1)

local logRows = {}
local MAX_LOG_ROWS = 60

local function pushLog(msg, color)
    if #logRows >= MAX_LOG_ROWS then
        logRows[1]:Destroy()
        table.remove(logRows, 1)
    end
    local l = makeLabel(logScroll, msg,
        UDim2.new(1,-4,0,14), UDim2.new(0,2,0,0),
        color or ORANGE, 10)
    l.LayoutOrder = #logRows + 1
    l.TextTruncate = Enum.TextTruncate.AtEnd
    table.insert(logRows, l)
    logScroll.CanvasSize = UDim2.new(0,0,0,#logRows*15+4)
    logScroll.CanvasPosition = Vector2.new(0, math.huge)
end

-- Hook into detector log if FF3 is loaded
if _G.FF3_DetectorLog then
    task.spawn(function()
        local seen = 0
        while true do
            task.wait(0.5)
            local log = _G.FF3_DetectorLog
            if log then
                for i = seen+1, #log do
                    pushLog(log[i])
                    seen = i
                end
            end
        end
    end)
end

-- ── Toolbar bottom ──────────────────────────────────────────────────
local toolbar = makeFrame(win, UDim2.new(1,0,0,28), UDim2.new(0,0,1,-28), Color3.fromRGB(15,15,18))
makeLabel(toolbar, '67 FF3 STAFF  •  key: ••••••••  •  ' .. lp.Name,
    UDim2.new(1,-100,1,0), UDim2.new(0,8,0,0), DIM, 10)

local refreshBtn = makeBtn(toolbar, '↻ Refresh',
    UDim2.new(0,70,0,20), UDim2.new(1,-78,0,4), SURFACE, ACCENT)
refreshBtn.MouseButton1Click:Connect(function()
    refreshUsers()
    pushLog('[' .. os.date('%H:%M:%S') .. '] manual refresh')
end)

-- ── Auto-refresh users every 3s ─────────────────────────────────────
task.spawn(function()
    while sg and sg.Parent do
        task.wait(3)
        refreshUsers()
    end
end)

-- Initial load
refreshUsers()
pushLog('[' .. os.date('%H:%M:%S') .. '] staff panel loaded — ' .. lp.Name, ACCENT)



------------------------------------------------------------------------
-- AC BYPASS LAYER
------------------------------------------------------------------------

-- 1. firetouchinterest jitter
if firetouchinterest then
    local _orig_fti = firetouchinterest
    local _fti_calls = 0
    local _genv = getgenv and getgenv()
    if _genv then
        _genv.firetouchinterest = function(part, touchPart, toggle)
            _fti_calls = _fti_calls + 1
            if toggle == 0 then
                local jitter = math.random(1, 4) / 1000
                task.delay(jitter, function()
                    _orig_fti(part, touchPart, 0)
                    task.delay(math.random(1,3)/1000, function()
                        _orig_fti(part, touchPart, 1)
                    end)
                end)
            elseif toggle ~= 1 then
                _orig_fti(part, touchPart, toggle)
            end
        end
    end
end

-- 2. AssemblyLinearVelocity write throttle + noise
do
    local _genv = getgenv and getgenv()
    if _genv then
        local _velWriteTick = 0
        local _velNoiseMag  = 0.18
        _genv.FF3_SetVelocity = function(hrp, vel)
            if not hrp or not hrp.Parent then return end
            local now = tick()
            if now - _velWriteTick < 0.008 then return end
            _velWriteTick = now
            local noise = Vector3.new(
                (math.random()-0.5)*_velNoiseMag, 0,
                (math.random()-0.5)*_velNoiseMag)
            hrp.AssemblyLinearVelocity = vel + noise
        end
    end
end

-- 3. CharacterSoundEvent FireServer rate limiter
do
    local RS  = game:GetService('ReplicatedStorage')
    local lp  = game:GetService('Players').LocalPlayer
    task.spawn(function()
        local remote
        while not remote do
            local r = RS:FindFirstChild('Remotes')
            remote = r and r:FindFirstChild('CharacterSoundEvent')
            if not remote then task.wait(0.5) end
        end
        local mt = getrawmetatable and getrawmetatable(remote)
        if mt and setreadonly then
            setreadonly(mt, false)
            local _orig_index = mt.__index
            local _queue = {}
            local MIN_INTERVAL = 1/12
            local _wrapped = false
            mt.__index = function(self, key)
                if key == 'FireServer' and self == remote and not _wrapped then
                    return function(self2, ...)
                        local args = {...}
                        local now  = tick()
                        local sig  = table.concat(args, '|')
                        for _, q in next, _queue do
                            if q.sig == sig and now - q.t < 0.05 then return end
                        end
                        table.insert(_queue, {sig=sig, args=args, t=now})
                    end
                end
                return _orig_index(self, key)
            end
            setreadonly(mt, true)
            _wrapped = true
            task.spawn(function()
                local _orig_fire = remote.FireServer
                while true do
                    task.wait(MIN_INTERVAL + math.random()*0.02)
                    if #_queue > 0 then
                        local item = table.remove(_queue, 1)
                        pcall(function() _orig_fire(remote, table.unpack(item.args)) end)
                    end
                end
            end)
        end
    end)
end

-- 4. Ball attribute tag obfuscation
do
    local _genv = getgenv and getgenv()
    if _genv then
        local _attrKey = 'local_' .. tostring(math.random(100000, 999999))
        _genv.FF3_BallAttrKey = _attrKey
        _genv.FF3_TagBall = function(ball)
            if ball and ball.Parent then
                pcall(function() ball:SetAttribute(_attrKey, true) end)
            end
        end
        _genv.FF3_IsBall = function(ball)
            if not ball then return false end
            local ok, res = pcall(function() return ball:GetAttribute(_attrKey) == true end)
            return ok and res or false
        end
    end
end

-- 5. Execution fingerprint scrambler (FIXED: wrapped in task.spawn, getgenv guarded)
task.spawn(function()
    task.wait(math.random(5, 25) / 100)
    local _genv = getgenv and getgenv()
    local dummies = {'PlayerData','GameSettings','LocalCache','UIHandler','SoundController','DataManager'}
    for _, k in next, dummies do
        if not _G[k] then _G[k] = {_init = tick()} end
    end
end)

print('[67 FF3] AC bypass loaded')

------------------------------------------------------------------------
-- Library  (FIXED: assert replaced with hard error + retry fallback)
------------------------------------------------------------------------
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local function fetchModule(path)
    for attempt = 1, 3 do
        local ok, res = pcall(function() return loadstring(game:HttpGet(repo .. path))() end)
        if ok and res then return res end
        warn('[67 FF3] attempt ' .. attempt .. ' failed loading ' .. path .. ': ' .. tostring(res))
        if attempt < 3 then task.wait(1) end
    end
    return nil
end

local Library = fetchModule('Library.lua')
if not Library then
    -- LinoriaLib hard failed after 3 tries — surface the error, don't hang silently
    local sg2 = Instance.new('ScreenGui')
    pcall(function() sg2.Parent = game:GetService('CoreGui') end)
    if not sg2.Parent then sg2.Parent = game:GetService('Players').LocalPlayer:WaitForChild('PlayerGui',10) end
    local lbl2 = Instance.new('TextLabel', sg2)
    lbl2.Size = UDim2.new(0,400,0,40)
    lbl2.Position = UDim2.new(0.5,-200,0.5,-20)
    lbl2.BackgroundColor3 = Color3.fromRGB(30,0,0)
    lbl2.TextColor3 = Color3.fromRGB(255,80,80)
    lbl2.Text = '[67 FF3] LinoriaLib failed to load — check console (F9)'
    lbl2.TextSize = 13
    return
end
local ThemeManager = fetchModule('addons/ThemeManager.lua')
local SaveManager  = fetchModule('addons/SaveManager.lua')

local T = (getgenv and getgenv().Toggles) or Library.Toggles
local O = (getgenv and getgenv().Options)  or Library.Options
if not T or not O then
    warn('[67 FF3] Toggles/Options missing — LinoriaLib version mismatch')
    return
end

------------------------------------------------------------------------
-- Library
------------------------------------------------------------------------
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local function fetchModule(path)
    local ok, res = pcall(function() return loadstring(game:HttpGet(repo .. path))() end)
    if not ok then warn('[67 FF3] failed to load ' .. path .. ': ' .. tostring(res)) return nil end
    return res
end

local Library     = assert(fetchModule('Library.lua'), '[67 FF3] LinoriaLib failed')
local ThemeManager = fetchModule('addons/ThemeManager.lua')
local SaveManager  = fetchModule('addons/SaveManager.lua')

local T = (getgenv and getgenv().Toggles) or Library.Toggles
local O = (getgenv and getgenv().Options)  or Library.Options
assert(T and O, '[67 FF3] Toggles/Options missing')

------------------------------------------------------------------------
-- Services
------------------------------------------------------------------------
local Players        = game:GetService('Players')
local RS             = game:GetService('ReplicatedStorage')
local TweenService   = game:GetService('TweenService')
local UIS            = game:GetService('UserInputService')
local RunService     = game:GetService('RunService')
local Stats          = game:GetService('Stats')
local Lighting       = game:GetService('Lighting')

while not Players.LocalPlayer do task.wait() end
local lp          = Players.LocalPlayer
local isPractice  = (game.PlaceId == 81310542478972)
local Alive       = true
local Janitor     = {}

local function track(obj) Janitor[#Janitor+1] = obj return obj end
local function Run(name, fn)
    local ok, err = pcall(fn)
    if not ok then warn('[67 FF3] "' .. name .. '" error: ' .. tostring(err)) end
end
local function loop(delay, fn)
    task.spawn(function()
        while Alive do
            if delay then task.wait(delay) else task.wait() end
            if not Alive then break end
            pcall(fn)
        end
    end)
end
local function teamCount()
    local n = 0 pcall(function() n = #game:GetService('Teams'):GetTeams() end) return n
end
local function isEnemy(plr)
    return not (teamCount() > 1 and lp.Team ~= nil and plr.Team ~= nil and lp.Team == plr.Team)
end
local function isMate(plr)
    return not (teamCount() > 1 and lp.Team ~= nil and plr.Team ~= nil and lp.Team ~= plr.Team)
end
local function findClosestBall()
    local c = lp.Character
    local hrp = c and c:FindFirstChild('HumanoidRootPart')
    if not hrp then return end
    local dist, ball = math.huge, nil
    for _, v in next, workspace:GetChildren() do
        if v:IsA('BasePart') and v.Name == 'Football' then
            local d = (v.Position - hrp.Position).Magnitude
            if d < dist then dist, ball = d, v end
        end
    end
    return ball
end
local function getFieldPos()
    local m = workspace:FindFirstChild('Models')
    local f = m and m:FindFirstChild('Field')
    local g = f and f:FindFirstChild('Ground')
    return g and g.Position or Vector3.zero
end
local function charParts()
    local c = lp.Character
    if not c then return end
    return c, c:FindFirstChildOfClass('Humanoid'), c:FindFirstChild('HumanoidRootPart')
end
local function fireSound(...)
    local r = RS:FindFirstChild('Remotes')
    local ev = r and r:FindFirstChild('CharacterSoundEvent')
    if ev then ev:FireServer(...) end
end

------------------------------------------------------------------------
-- UI helpers
------------------------------------------------------------------------
local function tog(box, id, text, tip, default, cb)
    return box:AddToggle(id, { Text = text, Default = default or false, Tooltip = tip, Callback = cb })
end
local function sld(box, id, text, tip, mn, mx, default, rounding)
    return box:AddSlider(id, { Text = text, Tooltip = tip, Min = mn, Max = mx, Default = default, Rounding = rounding or 1 })
end
local function key(box, id, text, default)
    return box:AddLabel(text):AddKeyPicker(id, { Default = default, Mode = 'Toggle', Text = text, NoUI = true })
end
local function drop(box, id, text, tip, values, default)
    return box:AddDropdown(id, { Values = values, Default = default or 1, Multi = false, Text = text, Tooltip = tip })
end
local function lbl(box, text) return box:AddLabel(text) end
local function btn(box, text, tip, fn) return box:AddButton({ Text = text, Tooltip = tip, Func = fn }) end

------------------------------------------------------------------------
-- Window + TABS  (consolidated: 7 tabs instead of 9)
------------------------------------------------------------------------
local Window = Library:CreateWindow({
    Title       = '67 FF3 | discord.gg/67scripts',
    Center      = true,
    AutoShow    = true,
    TabPadding  = 8,
    MenuFadeTime = 0.2,
})

local Tabs = {
    QB         = Window:AddTab('QB Aimbot'),
    Catching   = Window:AddTab('Catching'),
    Player     = Window:AddTab('Player'),
    Defense    = Window:AddTab('Defense'),    -- merged Physics here too
    Automatics = Window:AddTab('Automatics'),
    Detectors  = Window:AddTab('Detectors'), -- NEW
    Misc       = Window:AddTab('Misc / Visual'),
    Settings   = Window:AddTab('UI Settings'),
}

------------------------------------------------------------------------
-- UI: QB Aimbot
------------------------------------------------------------------------
Run('UI: QB Aimbot', function()
    local L = Tabs.QB:AddLeftGroupbox('QB Aimbot')
    tog(L, 'EnableQbAimbot',     'Enable QB Aimbot',              'Automatically aims passes at the best target.')
    tog(L, 'ThrowAimbot',        'Throw To Mouse Aimbot',         'Aims passes toward your mouse position.')
    tog(L, 'AutoChooseWr',       'Auto Choose Open Receiver',     'Selects the most open receiver each throw.')
    tog(L, 'AutoSelectThrowMode','Auto Select Throw Type',        'Chooses the best throw type automatically.')
    tog(L, 'AutoPower',          'Auto Power',                    'Sets optimal throw power automatically.')
    tog(L, 'AutoAngle',          'Auto Angle',                    'Adjusts throw angle for accuracy.')
    tog(L, 'HighPowerOnly',      'High Power Only',               'Only uses high-power throws.')
    tog(L, 'AntiDB',             'Anti DB',                       'Avoids throws defenders can intercept.')
    sld(L, 'AntiDBThreshold',    'Anti DB Threshold',             'Defender avoidance aggressiveness.', 0, 15, 0, 1)
    tog(L, 'AntiOOB',            'Anti OOB',                      'Prevents throws near sidelines.')
    sld(L, 'AntiOOBThreshold',   'Anti OOB Threshold',            'Sideline buffer distance.', 0, 15, 0, 1)
    sld(L, 'ThrowLeadOffset',    'Throw Lead Offset',             'How far ahead passes are led.', -10, 10, 0, 1)
    sld(L, 'ThrowHeightOffset',  'Throw Height Offset',           'Height of targeted throws.', -10, 10, 0, 1)

    local R = Tabs.QB:AddRightGroupbox('Throw Extras')
    tog(R, 'AutoJuke',           'Auto Juke Rusher',              'Jukes nearby rushers before throwing.')
    tog(R, 'HideCards',          'Hide QB Aimbot Cards',          'Hides HUD cards.')
    tog(R, 'AutoChangePowerUI',  'Auto Change Power UI',          'Updates power UI to match throws.')
    tog(R, 'AutoJumpWhenThrow',  'Auto Jump Before Throw',        'Jumps before releasing the ball.')
    tog(R, 'AutoThrowAfterSack', 'Auto Throw Before Sacked',      'Throws when sack is imminent.')

    local S = Tabs.QB:AddRightGroupbox('SmartFit [BETA]')
    lbl(S, 'Improves QB decisions via route & coverage scoring')
    tog(S, 'SmartFit',           'Enable SmartFit [BETA]',        'Uses advanced receiver scoring (BETA — may affect performance).')
    tog(S, 'SmartFitDebug',      'SmartFit Debug Labels',         'Shows SmartFit scores on HUD cards.')
    sld(S, 'SmartFitOpenBonus',  'Open Receiver Bonus',           'Score bonus for uncovered receivers.', 0, 10, 5, 1)
    sld(S, 'SmartFitDistPenalty','Distance Penalty',              'Score penalty per stud of distance.', 0, 1, 0.1, 2)
    sld(S, 'SmartFitDeepBonus',  'Deep Route Bonus',              'Score bonus for deep routes.', 0, 10, 3, 1)
    sld(S, 'SmartFitModeWeight', 'Mode Confidence Weight',        'How much route-mode matching shifts the score.', 0, 5, 2, 1)

    local K = Tabs.QB:AddRightGroupbox('Keybinds')
    key(K, 'DimeKey',     'Dime Mode',       'One')
    key(K, 'MagKey',      'Mag Mode',        'Two')
    key(K, 'DiveKey',     'Dive Mode',       'Three')
    key(K, 'JumpKey',     'Jump Mode',       'Four')
    key(K, 'BulletKey',   'Bullet Mode',     'Five')
    key(K, 'ThrowAwayKey','Throw Ball Away', 'T')
    key(K, 'IncAngleKey', 'Increase Angle',  'R')
    key(K, 'DecAngleKey', 'Decrease Angle',  'F')
    key(K, 'LockKey',     'Lock To Target',  'Z')
end)

------------------------------------------------------------------------
-- UI: Catching
------------------------------------------------------------------------
Run('UI: Catching', function()
    local L = Tabs.Catching:AddLeftGroupbox('Football Magnets')
    tog(L, 'FootballMagnets', 'Enable Football Magnets', 'Pulls footballs into catch range.')
    tog(L, 'FreeFallCheck',   'Magnets Freefall Check',  'Only active while airborne.')
    tog(L, 'ShowCatchHitbox', 'Show Magnets Radius',     'Displays catch radius.')
    sld(L, 'MagnetsRadius',   'Catch Distance',          'Max catch distance.', 0, 25, 0, 1)
    sld(L, 'MagnetsDelay',    'Catch Delay',             'Delay before magnets activate.', 0, 1, 0, 1)
    drop(L, 'MagsType',       'Magnets Type',            'Behavior preset.', {'Custom','Blatant','League','Legit'}, 1)

    local E = Tabs.Catching:AddRightGroupbox('Mag Enhancer')
    tog(E, 'MagEnhancer',        'Enable Mag Enhancer',  'Enhances in-range catches.')
    sld(E, 'MagEnhancerRadius',  'Catch Distance',       'Enhancer max distance.', 0, 25, 0, 1)
    sld(E, 'MagEnhancerMaxAngle','Max Angle',            'Max catch angle.', 50, 70, 50, 1)

    local P = Tabs.Catching:AddLeftGroupbox('Pull Vector')
    tog(P, 'PullVector',      'Enable Pull Vector', 'Pulls footballs toward you.')
    sld(P, 'PullVectorRadius','Pull Radius',        'Max pull distance.', 0, 45, 0, 1)
    sld(P, 'PullVectorPower', 'Pull Power',         'Pull strength.', 0, 5, 0, 1)

    local A = Tabs.Catching:AddRightGroupbox('Arms')
    tog(A, 'IncreaseArmSize', 'Increase Arm Size', 'Increases catch reach.')
    sld(A, 'ArmSizeValue',    'Arm Size',          'Size applied to arms.', 2, 25, 2, 1)
end)

------------------------------------------------------------------------
-- UI: Player
------------------------------------------------------------------------
Run('UI: Player', function()
    local L = Tabs.Player:AddLeftGroupbox('Movement')
    tog(L, 'CustomWalkSpeed', 'Custom WalkSpeed',  'Override movement speed.')
    sld(L, 'WalkSpeedValue',  'WalkSpeed',         'Speed value.', 20, 23, 20, 1)
    drop(L,'WalkspeedType',   'WalkSpeed Type',    'How speed is applied.', {'Normal','CFrame'}, 1)
    tog(L, 'CustomJumpPower', 'Custom JumpPower',  'Override jump power.')
    sld(L, 'JumpPowerValue',  'JumpPower',         'Jump power value.', 50, 70, 50, 1)

    local R = Tabs.Player:AddRightGroupbox('Air Control')
    tog(R, 'AngleEnhancer',          'Angle Enhancer',            'Boosts jump on look change.')
    tog(R, 'AngleEnhancerIndicator', 'Angle Enhancer Indicator',  'Shows "Angled!" notification.')
    tog(R, 'AutoFlip',               'Auto Flip Before Landing',  'Adjusts orientation before landing.')
    sld(R, 'AngleEnhanceBoost',      'Boost Value',               'Vertical velocity during boost.', 50, 70, 50, 1)

    local G = Tabs.Player:AddRightGroupbox('Misc')
    btn(G, 'Unlock All Gamepass', 'Unlocks gamepass features locally.', function()
        local ok, res = pcall(function()
            local m = game:GetService('ReplicatedFirst'):FindFirstChild('LocalSave')
            if not m then return false end
            local mod = require(m)
            if type(mod) ~= 'table' then return false end
            mod.PlayerOwnsPass = function() return true end
            return true
        end)
        Library:Notify(ok and res and 'Gamepasses unlocked (local).' or 'Could not find LocalSave.', 3)
    end)
end)

------------------------------------------------------------------------
-- UI: Defense  (merged with Physics)
------------------------------------------------------------------------
local ApplySkyBox  -- forward-declared, used in Misc tab
Run('UI: Defense + Physics', function()
    -- Defense
    local DL = Tabs.Defense:AddLeftGroupbox('Swat')
    tog(DL, 'SwatReach',         'Swat Reach',            'Extends swat range.')
    sld(DL, 'SwatReachDistance', 'Swat Radius',           'Max swat distance.', 0, 25, 0, 1)

    local DR = Tabs.Defense:AddRightGroupbox('Tackle')
    tog(DR, 'TackleReach',       'Extend Tackle Reach',   'Extends tackle range.')
    tog(DR, 'TackleAimbot',      'Tackle Aimbot',         'Targets ball carriers automatically.')
    sld(DR, 'TackleAimbotRange', 'Aimbot Distance',       'Max targeting distance.', 0, 25, 0, 1)

    -- Physics / Anti (merged here)
    local PL = Tabs.Defense:AddLeftGroupbox('Anti / Physics')
    tog(PL, 'AntiBoundaries',  'Anti OOB',           'Prevents OOB triggers.', false, function(v)
        if isPractice then return end
        local m = workspace:FindFirstChild('Models')
        local bound = m and m:FindFirstChild('Boundaries')
        if bound then
            for _, b in next, bound:GetChildren() do
                b.Parent = (not v) and bound or nil
            end
        end
    end)
    tog(PL, 'AntiBench',       'Anti Bench',         'Prevents auto-bench.')
    tog(PL, 'AntiJam',         'Anti Jam',           'Reduces collision while moving.')
    tog(PL, 'AntiJumpCooldown','Anti Jump Cooldown', 'Removes jump delay.')
    tog(PL, 'AntiFreeze',      'Anti Freeze',        'Prevents speed reduction.')
    tog(PL, 'AntiBlock',       'Anti Block',         'Removes body velocity blockers.')

    local PR = Tabs.Defense:AddRightGroupbox('Quick TP / Head')
    tog(PR, 'QuickTP',      'Quick TP',          'Teleports forward.')
    sld(PR, 'QuickTPPower', 'TP Power',          'Teleport distance.', 0, 5, 0, 1)
    key(PR, 'QuickTPKey',   'Quick TP Key',      'Q')
    tog(PR, 'BigHead',      'Big Head Players',  'Enlarges other player heads.')
    sld(PR, 'BigHeadSize',  'Head Size',         'Head size multiplier.', 1, 6, 1, 1)
end)

------------------------------------------------------------------------
-- UI: Automatics
------------------------------------------------------------------------
Run('UI: Automatics', function()
    local L = Tabs.Automatics:AddLeftGroupbox('Auto Rush [Reworked]')
    tog(L, 'AutoRush',               'Auto Rush',           'Rushes the ball carrier intelligently.')
    tog(L, 'WalkToLine',             'Walk To Line',        'Moves to line before play.')
    tog(L, 'AutoRushZoneAware',      'Zone Aware',          'Avoids rushing from bad field positions.')
    tog(L, 'AutoRushPredictCut',     'Predict Cut Routes',  'Anticipates cuts and jukes.')
    sld(L, 'AutoRushReactionTime',   'Reaction Time',       'Response delay.', 0, 1, 0.1, 2)
    sld(L, 'AutoRushEngageDistance', 'Engage Distance',     'Max distance to engage carrier.', 10, 80, 40, 1)

    local C = Tabs.Automatics:AddRightGroupbox('Auto Catch / Swat')
    tog(C, 'AutoCatch',       'Auto Catch',     'Catches nearby balls.')
    sld(C, 'AutoCatchRadius', 'Catch Distance', 'Detection range.', 0, 25, 0, 1)
    tog(C, 'AutoSwat',        'Auto Swat',      'Swats nearby balls.')
    sld(C, 'AutoSwatRadius',  'Swat Distance',  'Detection range.', 0, 25, 0, 1)

    local M = Tabs.Automatics:AddLeftGroupbox('Auto Utility')
    tog(M, 'AutoCaptain',   'Auto Win Captain', 'Rushes finish line in captain.')
    tog(M, 'AutoFreeze',    'Auto Freeze',      'Anchors on key press.')
    sld(M, 'FreezeDuration','Freeze Duration',  'Freeze time.', 0, 3, 0, 1)
    key(M, 'FreezeKey',     'Freeze Key',       'None')
    tog(M, 'AutoQb',        'Auto QB',          'Positions for QB play.')
    drop(M,'AutoQbMethod',  'QB Method',        'Positioning method.', {'Walk','Teleport'}, 1)

    local B = Tabs.Automatics:AddRightGroupbox('Auto Boost')
    tog(B, 'AutoBoost',             'Auto Boost',            'Assists aerial movement.')
    tog(B, 'TargetClosestPlayer',   'Target Closest To Ball','Prioritizes nearest player to ball.')
    sld(B, 'BoostStrength', 'Boost Strength', 'Boost effect strength.', 0, 3, 1.5, 1)
    sld(B, 'BoostRadius',   'Boost Radius',   'Activation distance.', 0, 15, 0, 1)
    sld(B, 'BoostPower',    'Boost Power',    'Upward force.', 50, 70, 50, 1)
end)

------------------------------------------------------------------------
-- UI: Detectors (NEW TAB)
------------------------------------------------------------------------
Run('UI: Detectors', function()
    local L = Tabs.Detectors:AddLeftGroupbox('Mag Detector')
    lbl(L, 'Flags players who may be using mags')
    tog(L, 'MagDetector',         'Enable Mag Detector',       'Detects suspicious firetouchinterest patterns.')
    tog(L, 'MagDetectorNotify',   'Show Notification',         'Pops a notification when mags are detected.')
    tog(L, 'MagDetectorChat',     'Print To Console',          'Prints detections to developer console.')
    sld(L, 'MagDetectorThreshold','Detection Sensitivity',     'How many catches/s triggers a flag.', 1, 20, 6, 0)

    local WS = Tabs.Detectors:AddRightGroupbox('WalkSpeed Detector')
    lbl(WS, 'Flags players moving faster than allowed')
    tog(WS, 'WalkSpeedDetector',         'Enable WalkSpeed Detector',  'Compares velocity to max allowed speed.')
    tog(WS, 'WalkSpeedDetectorNotify',   'Show Notification',          'Pops notification on detection.')
    tog(WS, 'WalkSpeedDetectorChat',     'Print To Console',           'Logs to console.')
    sld(WS, 'WalkSpeedDetectorLimit',    'Speed Limit (studs/s)',      'Flag if velocity exceeds this.', 20, 60, 26, 1)

    local CF = Tabs.Detectors:AddLeftGroupbox('CFrame Detector')
    lbl(CF, 'Flags players who teleport suddenly')
    tog(CF, 'CFrameDetector',         'Enable CFrame Detector',  'Detects sudden position deltas (teleport hacks).')
    tog(CF, 'CFrameDetectorNotify',   'Show Notification',       'Pops notification on detection.')
    tog(CF, 'CFrameDetectorChat',     'Print To Console',        'Logs to console.')
    sld(CF, 'CFrameDetectorThreshold','Teleport Threshold (studs)','Flag if delta/frame exceeds this.', 5, 60, 18, 1)

    local LOG = Tabs.Detectors:AddRightGroupbox('Detection Log')
    lbl(LOG, 'Last 5 detections shown below')
    -- We create 5 static labels and update them at runtime
    for i = 1, 5 do
        lbl(LOG, 'det_log_' .. i)
    end
    -- We'll store label references in a global table for runtime updates
    -- (LinoriaLib labels are updated via :SetText)
end)

------------------------------------------------------------------------
-- UI: Misc / Visual  (merged Visual + Misc)
------------------------------------------------------------------------
Run('UI: Misc + Visual', function()
    local L = Tabs.Misc:AddLeftGroupbox('Visuals')
    tog(L, 'JumpSpot',    'Visualise Jump Spot',  'Shows predicted ball landing.')
    tog(L, 'ThrowSpot',   'Visualise Throw Spot', 'Shows thrown ball path.')
    tog(L, 'EnableGloves','Enable Uniform Gloves','Toggles glove visibility.', true)
    tog(L, 'NoBallTrail', 'No Ball Trail',         'Removes ball trail effects.')
    tog(L, 'HideStadium', 'Hide Stadium',          'Hides stadium structures.', false, function(v)
        if _G.__FF3_67_HideStadium then _G.__FF3_67_HideStadium(v) end
    end)

    local Sky = Tabs.Misc:AddRightGroupbox('Skyboxes')
    local skyNames = {'Golden Twilight','Infernal Horizon','Nebula Peaks','Rose Glow','Night Sky','Northern Lights'}
    for _, name in ipairs(skyNames) do
        local n = name
        btn(Sky, n, 'Apply ' .. n .. ' skybox.', function() if ApplySkyBox then ApplySkyBox(n) end end)
    end

    local P = Tabs.Misc:AddLeftGroupbox('Performance')
    sld(P, 'FpsCap',     'Uncap FPS',       'Maximum FPS cap.', 30, 240, 240, 0)
    tog(P, 'AntiAdmin',  'Anti Admin',      'Kicks when admin detected.')
    tog(P, 'SmoothReplay','Smooth Replay',  'Smoother replay playback.')
    sld(P, 'ReplayFPS',  'Replay FPS',      'Replay frame rate.', 9, 120, 9, 0)
end)

------------------------------------------------------------------------
-- LOGIC: QB Aimbot
------------------------------------------------------------------------
Run('LOGIC: QB Aimbot', function()
    local mouse = lp:GetMouse()
    local function cam() return workspace.CurrentCamera end

    local targetLocked, lockedTarget = false, nil
    local HUDCards, numCards = {}, 0
    local lead  = {Dime=8.5, Mag=8.6, Dive=8.5, Jump=8.4, Bullet=2.5}
    local yLead = {Dime=1.2, Mag=1.0, Dive=1.5, Jump=2.0, Bullet=-0.8}
    local ModeOrder  = {'Bullet','Dime','Dive','Jump','Mag'}
    local keyModes   = {{'DimeKey','Dime'},{'MagKey','Mag'},{'DiveKey','Dive'},{'JumpKey','Jump'},{'BulletKey','Bullet'}}
    local chestRoutes = {['slant']=true,['drag']=true,['in/out']=true,['flat']=true,['hitch']=true,['curl/comeback']=true}
    local customHeight = 0

    local target, lastValidTarget, targetLeadPos, highlight = nil, nil, nil, nil
    local direction = Vector3.new(0,1,0)
    local power, angle, airtime = 60, 45, 0
    local isThrowing, isThrowingAway = false, false
    local modeIndex = 1
    local smoothedJukeDir = Vector3.zero
    local lockedMousePos = nil
    local LockToggleBtn, LockedLabel = nil, nil

    ----------------------------------------------------------------
    -- Beam / marker setup
    ----------------------------------------------------------------
    local attach0 = track(Instance.new('Attachment', workspace.Terrain))
    local attach1 = track(Instance.new('Attachment', workspace.Terrain))

    local function makeBeam(a0, a1)
        local b = Instance.new('Beam')
        b.Attachment0, b.Attachment1 = a0, a1
        b.Segments, b.Width0, b.Width1 = 7500, 1, 1
        b.FaceCamera = true
        b.Color = ColorSequence.new(Color3.fromRGB(255,255,255))
        b.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.01, 0),
            NumberSequenceKeypoint.new(1, 0),
        })
        b.Parent = workspace.Terrain
        return b
    end
    local function makeBall()
        local p = Instance.new('Part')
        p.Anchored, p.CanCollide, p.CastShadow = true, false, false
        p.Size = Vector3.new(3,3,3)
        p.Shape = Enum.PartType.Ball
        p.Color = Color3.fromRGB(0,0,0)
        p.Parent = workspace.Terrain
        return p
    end

    local beam    = track(makeBeam(attach0, attach1))
    local posPart = track(makeBall())

    ----------------------------------------------------------------
    -- HUD
    ----------------------------------------------------------------
    local sg = track(Instance.new('ScreenGui'))
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local ok = pcall(function() sg.Parent = (gethui and gethui()) or game:GetService('CoreGui') end)
    if not ok or not sg.Parent then sg.Parent = lp:WaitForChild('PlayerGui', 10) end

    local container = Instance.new('CanvasGroup')
    container.Size = UDim2.new(1,0,0,100)
    container.Position = UDim2.new(0.5,0,0.05,0)
    container.AnchorPoint = Vector2.new(0.5,0)
    container.BackgroundTransparency = 1
    container.GroupTransparency = 1
    container.Parent = sg

    local containerScale = Instance.new('UIScale', container)
    local function updateScale()
        local vp = cam().ViewportSize
        containerScale.Scale = math.clamp(vp.X/1100, 0.5, 1.2)
    end
    track(cam():GetPropertyChangedSignal('ViewportSize'):Connect(updateScale))
    updateScale()

    local layout = Instance.new('UIListLayout')
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment   = Enum.VerticalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding   = UDim.new(0, 10)
    layout.Parent    = container

    local hudVisible = false
    local function updateHUDVisibility(show)
        if show == hudVisible then return end
        hudVisible = show
        TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {GroupTransparency = show and 0 or 1}):Play()
    end
    local function setFont(inst, font) pcall(function() inst.Font = font end) end
    local function hasBall()
        local c = lp.Character
        return c and c:FindFirstChild('Football')
    end

    local cardBg   = Color3.fromRGB(10,10,10)
    local cardText = Color3.fromRGB(235,235,235)
    local cardDim  = Color3.fromRGB(130,130,130)

    local function createCard(titleTxt)
        local card = Instance.new('Frame')
        card.BackgroundColor3    = cardBg
        card.BackgroundTransparency = 0.12
        card.BorderSizePixel     = 0
        card.Size = titleTxt=='Throw Type' and UDim2.new(0,118,0,62) or UDim2.new(0,100,0,62)
        card.ClipsDescendants    = true
        card.LayoutOrder         = numCards
        card.Parent              = container

        Instance.new('UICorner', card).CornerRadius = UDim.new(0,3)
        local stroke = Instance.new('UIStroke', card)
        stroke.Color = Color3.fromRGB(55,55,55)
        stroke.Thickness = 1

        local bar = Instance.new('Frame')
        bar.Size = UDim2.new(0,2,1,0)
        bar.BackgroundColor3 = cardText
        bar.BorderSizePixel  = 0
        bar.ZIndex = 2
        bar.Parent = card

        local ghost = Instance.new('TextLabel')
        ghost.Size = UDim2.new(0,60,0,50)
        ghost.Position = UDim2.new(1,-52,1,-38)
        ghost.BackgroundTransparency = 1
        ghost.Text = '67'
        ghost.TextColor3 = Color3.fromRGB(255,255,255)
        ghost.TextTransparency = 0.93
        ghost.TextSize = 46
        setFont(ghost, Enum.Font.GothamBlack)
        ghost.ZIndex = 1
        ghost.Parent = card

        local title = Instance.new('TextLabel')
        title.BackgroundTransparency = 1
        title.Position = UDim2.new(0,10,0,6)
        title.Size     = UDim2.new(1,-16,0,12)
        title.Text     = string.upper(titleTxt)
        title.TextColor3 = cardDim
        title.TextSize   = 10
        title.TextXAlignment = Enum.TextXAlignment.Left
        setFont(title, Enum.Font.Code)
        title.ZIndex = 2
        title.Parent = card

        local valBtn = Instance.new('TextButton')
        valBtn.BackgroundTransparency = 1
        valBtn.BorderSizePixel = 0
        valBtn.Position = UDim2.new(0,10,0,20)
        valBtn.Size     = UDim2.new(1,-16,0,34)
        valBtn.Text     = '-'
        valBtn.TextColor3 = cardText
        valBtn.TextScaled = true
        valBtn.TextXAlignment = Enum.TextXAlignment.Left
        valBtn.AutoButtonColor = false
        setFont(valBtn, Enum.Font.Code)
        valBtn.ZIndex = 3
        valBtn.Parent = card
        Instance.new('UITextSizeConstraint', valBtn).MaxTextSize = 26

        if titleTxt == 'Throw Type' then
            local uiScale = Instance.new('UIScale', card)
            valBtn.MouseButton1Down:Connect(function()
                if not hasBall() then return end
                TweenService:Create(uiScale, TweenInfo.new(0.08), {Scale=0.95}):Play()
            end)
            valBtn.MouseButton1Up:Connect(function()
                if not hasBall() then return end
                TweenService:Create(uiScale, TweenInfo.new(0.08), {Scale=1}):Play()
                modeIndex = modeIndex + 1
                if modeIndex > #ModeOrder then modeIndex = 1 end
            end)
        end

        if titleTxt == 'Player' then
            local lockedLbl = Instance.new('TextLabel')
            lockedLbl.Size  = UDim2.new(0,50,0,12)
            lockedLbl.Position = UDim2.new(1,-56,0,6)
            lockedLbl.BackgroundTransparency = 1
            lockedLbl.Text   = 'LOCKED'
            lockedLbl.TextColor3 = Color3.fromRGB(255,70,70)
            lockedLbl.TextSize   = 10
            lockedLbl.TextXAlignment = Enum.TextXAlignment.Right
            setFont(lockedLbl, Enum.Font.Code)
            lockedLbl.Visible = false
            lockedLbl.ZIndex  = 4
            lockedLbl.Parent  = card
            LockedLabel = lockedLbl

            local overlay = Instance.new('TextButton')
            overlay.Size = UDim2.new(1,0,1,0)
            overlay.BackgroundTransparency = 1
            overlay.Text   = ''
            overlay.ZIndex = 6
            overlay.Parent = card
            overlay.MouseButton1Click:Connect(function()
                if not hasBall() then return end
                if target or targetLocked then
                    targetLocked = not targetLocked
                    lockedTarget = targetLocked and target or nil
                    if LockedLabel then LockedLabel.Visible = targetLocked end
                end
            end)
            LockToggleBtn = valBtn
        end

        HUDCards[titleTxt] = valBtn
        numCards = numCards + 1
    end

    createCard('Angle')
    createCard('Throw Type')
    createCard('Player')
    createCard('Airtime')
    createCard('Power')

    ----------------------------------------------------------------
    -- Core QB helpers
    ----------------------------------------------------------------
    local function getActiveBots()
        local bots = {}
        local npcwr = workspace:FindFirstChild('npcwr')
        if npcwr then
            local a = npcwr:FindFirstChild('a')
            local b1 = a and a:FindFirstChild('bot 1')
            if b1 and b1:IsA('Model') then bots[#bots+1] = b1 end
            local b = npcwr:FindFirstChild('b')
            local b3 = b and b:FindFirstChild('bot 3')
            if b3 and b3:IsA('Model') then bots[#bots+1] = b3 end
        end
        return bots
    end

    local function performThrow()
        if not T.EnableQbAimbot.Value then return end
        local character = lp.Character
        if not character then return end
        local football = character:FindFirstChildOfClass('Tool')
        local handle   = football and football:FindFirstChild('Handle')
        local remote   = handle and handle:FindFirstChild('RemoteEvent')
        local head     = character:FindFirstChild('Head')
        local root     = character:FindFirstChild('HumanoidRootPart')
        if not remote or not head or not root then return end
        local dir = direction or Vector3.new(0,1,0)
        local pwr = tonumber(power) or 0
        if isPractice then
            remote:FireServer('Clicked', head.Position, head.Position + dir*10000, pwr)
        else
            remote:FireServer('Clicked', (root.CFrame*CFrame.new(0,1.5,0)).Position + Vector3.new(70000000),
                head.Position + dir*10000, pwr, 1)
        end
    end

    local function findRoute(character)
        if not character then return 'stationary', Vector3.zero end
        local humanoid  = character:FindFirstChild('Humanoid')
        local targetHRP = character:FindFirstChild('HumanoidRootPart')
        local qbChar    = lp.Character
        local qbHRP     = qbChar and qbChar:FindFirstChild('HumanoidRootPart')
        if not humanoid or not targetHRP or not qbHRP then return 'stationary', Vector3.zero end

        local moveDirection
        if Players:GetPlayerFromCharacter(character) then
            moveDirection = humanoid.MoveDirection
        else
            local d = humanoid.WalkToPoint - targetHRP.Position
            moveDirection = d.Magnitude > 0.01 and d.Unit or Vector3.zero
        end

        local toWR   = targetHRP.Position - qbHRP.Position
        local distance = toWR.Magnitude
        local toWRDir = Vector3.new(toWR.X,0,toWR.Z)
        toWRDir = toWRDir.Magnitude > 0.01 and toWRDir.Unit or Vector3.new(0,0,1)
        local mdFlat = Vector3.new(moveDirection.X,0,moveDirection.Z)
        if mdFlat.Magnitude < 0.01 then return 'stationary', moveDirection end
        mdFlat = mdFlat.Unit
        local dot = mdFlat:Dot(toWRDir)

        if dot > 0.75 then return 'go/fade', moveDirection
        elseif dot >= 0.25 then
            if distance <= 120 then return 'slant', moveDirection
            elseif distance <= 160 then return 'seam', moveDirection
            else return 'post/corner', moveDirection end
        elseif dot > -0.25 then
            if distance <= 60 then return 'drag', moveDirection
            elseif distance <= 130 then return 'in/out', moveDirection
            else return 'flat', moveDirection end
        else
            if distance <= 50 then return 'hitch', moveDirection
            else return 'curl/comeback', moveDirection end
        end
    end

    local function isWROpen(wrChar)
        if not wrChar then return false end
        local hrp = wrChar:FindFirstChild('HumanoidRootPart')
        if not hrp then return false end
        local _, moveDir = findRoute(wrChar)

        local function checkDB(dbHRP)
            local toDB = dbHRP.Position - hrp.Position
            if toDB.Magnitude < 5 then
                local rd = Vector3.new(moveDir.X, 0, moveDir.Z)
                return rd.Magnitude > 0.01 and toDB.Unit:Dot(rd.Unit) > -0.7 or true
            end
            return false
        end
        local function checkPR(dbHRP)
            local qbHRP = lp.Character and lp.Character:FindFirstChild('HumanoidRootPart')
            if not qbHRP then return false end
            local toPR  = dbHRP.Position - qbHRP.Position
            local toWR  = hrp.Position   - qbHRP.Position
            local wMag  = toWR.Magnitude
            if wMag < 0.01 then return false end
            local proj = toPR:Dot(toWR.Unit)
            if proj > 2 and proj < wMag * 0.6 then
                return (toPR - toWR.Unit * proj).Magnitude < 5.5
            end
            return false
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character and isEnemy(plr) then
                local d = plr.Character:FindFirstChild('HumanoidRootPart')
                if d and (checkDB(d) or checkPR(d)) then return false end
            end
        end
        for _, bot in ipairs(getActiveBots()) do
            if bot ~= wrChar then
                local d = bot:FindFirstChild('HumanoidRootPart')
                if d and (checkDB(d) or checkPR(d)) then return false end
            end
        end
        return true
    end

    ----------------------------------------------------------------
    -- SmartFit: score each potential receiver
    ----------------------------------------------------------------
    local deepRoutes  = {['go/fade']=true,['post/corner']=true,['seam']=true}
    local shortRoutes = {['slant']=true,['drag']=true,['hitch']=true,['in/out']=true,['flat']=true}

    local function smartFitScore(char, qbPos)
        -- Returns a score; higher = better target
        local hrp = char:FindFirstChild('HumanoidRootPart')
        if not hrp then return -math.huge end

        local dist    = (hrp.Position - qbPos).Magnitude
        local open    = isWROpen(char)
        local route   = findRoute(char)
        local _, onScreen = cam():WorldToViewportPoint(hrp.Position)
        if not onScreen then return -math.huge end

        local score = 0
        if open then score = score + (O.SmartFitOpenBonus.Value or 5) end
        score = score - dist * (O.SmartFitDistPenalty.Value or 0.1)
        if deepRoutes[route]  then score = score + (O.SmartFitDeepBonus.Value or 3) end
        if shortRoutes[route] then score = score + 1 end

        -- Mode confidence: prefer receiver whose route matches current mode
        local mName = ModeOrder[modeIndex]
        local modeMatch = (mName=='Bullet' and shortRoutes[route]) or
                          (mName=='Dime'   and deepRoutes[route])  or
                          (mName=='Mag'    and route=='go/fade')
        if modeMatch then score = score + (O.SmartFitModeWeight.Value or 2) end

        -- Coverage pressure (how many defenders nearby)
        local coverage = 0
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character and isEnemy(plr) then
                local eh = plr.Character:FindFirstChild('HumanoidRootPart')
                if eh and (eh.Position - hrp.Position).Magnitude < 12 then
                    coverage = coverage + 1
                end
            end
        end
        score = score - coverage * 2

        return score
    end

    ----------------------------------------------------------------
    -- getTarget (SmartFit aware)
    ----------------------------------------------------------------
    local function getTarget()
        if isThrowing and target then return target end
        if targetLocked and lockedTarget and lockedTarget:FindFirstChild('HumanoidRootPart') then
            return lockedTarget
        elseif targetLocked then
            targetLocked, lockedTarget = false, nil
        end

        local pool = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character and plr.Character:FindFirstChild('HumanoidRootPart') and isMate(plr) then
                local h = plr.Character:FindFirstChildOfClass('Humanoid')
                if not h or not h.Sit then pool[#pool+1] = plr.Character end
            end
        end
        for _, bot in ipairs(getActiveBots()) do
            if bot:FindFirstChild('HumanoidRootPart') then
                local h = bot:FindFirstChildOfClass('Humanoid')
                if not h or not h.Sit then pool[#pool+1] = bot end
            end
        end
        if #pool == 0 then return nil end

        local qbHRP = lp.Character and lp.Character:FindFirstChild('HumanoidRootPart')
        local qbPos  = qbHRP and qbHRP.Position or Vector3.zero

        -- SmartFit path
        if T.SmartFit.Value then
            local best, bestScore = nil, -math.huge
            for _, char in ipairs(pool) do
                local score = smartFitScore(char, qbPos)
                if score > bestScore then bestScore, best = score, char end
            end
            if best then
                if T.SmartFitDebug.Value and HUDCards['Player'] then
                    HUDCards['Player'].Text = (best.Name or '?') .. ' [' .. string.format('%.0f', bestScore) .. ']'
                end
                return best
            end
        end

        -- Auto-choose open WR
        if T.AutoChooseWr.Value then
            local best, bestDist = nil, math.huge
            for _, char in ipairs(pool) do
                local hrp = char:FindFirstChild('HumanoidRootPart')
                if hrp then
                    local _, onScreen = cam():WorldToViewportPoint(hrp.Position)
                    if onScreen and isWROpen(char) then
                        local d = (hrp.Position - qbPos).Magnitude
                        if d < bestDist then bestDist, best = d, char end
                    end
                end
            end
            if best then return best end
        end

        -- Mouse-closest fallback
        local mousePos = UIS:GetMouseLocation()
        local best, bestDist = nil, math.huge
        for _, char in ipairs(pool) do
            local hrp = char:FindFirstChild('HumanoidRootPart')
            if hrp then
                local sp, onScreen = cam():WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local d = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                    if d < bestDist then bestDist, best = d, char end
                end
            end
        end
        return best
    end

    local function calculateRouteDirection(targetChar)
        if not targetChar then return 'Mag' end
        local tHRP  = targetChar:FindFirstChild('HumanoidRootPart')
        local lpHRP = lp.Character and lp.Character:FindFirstChild('HumanoidRootPart')
        if not tHRP or not lpHRP then return 'Mag' end
        local route = findRoute(targetChar)
        if (tHRP.Position - lpHRP.Position).Magnitude < 40 then return 'Bullet' end

        local dbDistance = math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character and isEnemy(plr) then
                local e = plr.Character:FindFirstChild('HumanoidRootPart')
                if e and e ~= tHRP then
                    dbDistance = math.min(dbDistance, (e.Position - tHRP.Position).Magnitude)
                end
            end
        end
        for _, bot in ipairs(getActiveBots()) do
            local b = bot:FindFirstChild('HumanoidRootPart')
            if b and b ~= tHRP then
                dbDistance = math.min(dbDistance, (b.Position - tHRP.Position).Magnitude)
            end
        end

        local forward  = {['go/fade']=true,['post/corner']=true,['seam']=true,['curl/comeback']=true,['stationary']=true}
        local sideways = {['in/out']=true,['flat']=true,['wheel']=true}
        if chestRoutes[route] then return 'Bullet'
        elseif forward[route] then
            if dbDistance > 5  then return (angle < 40) and 'Jump' or 'Dime' end
            if dbDistance > 2  then return 'Dive' end
            return 'Mag'
        elseif sideways[route] then
            return dbDistance > 4 and 'Dime' or 'Jump'
        end
        return 'Dime'
    end

    local function getPing()
        local net = 0 pcall(function() net = tonumber(lp:GetNetworkPing()) or 0 end)
        local data = 0 pcall(function() data = (tonumber(Stats.Network.ServerStatsItem['Data Ping']:GetValue()) or 0)/1000 end)
        if data == 0 then data = net end
        return net + data
    end

    local function solveKinematics(origin, targetPos, g)
        g = tonumber(g) or 28
        local disp = targetPos - origin
        local x = Vector3.new(disp.X,0,disp.Z).Magnitude
        local y = disp.Y
        local root = math.sqrt(math.max(x^2 + y^2, 0))
        local angleRad = math.rad(45)
        if x > 0.01 then
            local a = math.atan((y + root) / x)
            if a == a then angleRad = a end
        end
        angleRad = math.clamp(angleRad * 0.85, math.rad(-15), math.rad(65))
        local cosA, tanA = math.cos(angleRad), math.tan(angleRad)
        local v0 = 95
        local denom = 2 * (cosA^2) * (x * tanA - y)
        if denom > 0.001 then
            local res = math.sqrt((g * x^2) / denom)
            if res == res and res ~= math.huge then v0 = res end
        end
        return v0, math.deg(angleRad)
    end

    ----------------------------------------------------------------
    -- autoAim (same as original, split into sub-functions)
    ----------------------------------------------------------------
    local routeMultipliers = {
        ['slant']=0.45,['drag']=0.6,['in/out']=0.65,['flat']=0.65,['wheel']=0.9,
        ['go/fade']=1.0,['post/corner']=0.85,['seam']=0.85,['hitch']=0.1,
        ['curl/comeback']=0.1,['stationary']=0.0,
    }

    local function getMoveDir(targetChar, targetHRP)
        local tHum = targetChar and targetChar:FindFirstChildOfClass('Humanoid')
        if not tHum then return Vector3.zero end
        if targetChar:FindFirstAncestor('npcwr') ~= nil then
            local w = tHum.WalkToPoint - targetHRP.Position
            local d = Vector3.new(w.X,0,w.Z)
            return d.Magnitude > 0.1 and d.Unit or Vector3.zero
        end
        local md = tHum.MoveDirection
        local f  = Vector3.new(md.X,0,md.Z)
        return f.Magnitude > 0.01 and f.Unit or Vector3.zero
    end

    local function adjustLeadPos(leadPos)
        if T.AntiDB.Value then
            local push = Vector3.zero
            local thr  = tonumber(O.AntiDBThreshold.Value) or 15
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character and isEnemy(plr) then
                    local e = plr.Character:FindFirstChild('HumanoidRootPart')
                    if e then
                        local dist = Vector3.new(e.Position.X-leadPos.X, 0, e.Position.Z-leadPos.Z).Magnitude
                        if dist < thr then
                            local away = leadPos - e.Position
                            away = Vector3.new(away.X, 0, away.Z)
                            if away.Magnitude > 0 then push = push + (away.Unit * (thr - dist)) end
                        end
                    end
                end
            end
            leadPos = leadPos + push
        end
        local fPos = getFieldPos()
        if T.AntiOOB.Value and fPos ~= Vector3.zero then
            local thr = tonumber(O.AntiOOBThreshold.Value) or 5
            leadPos = Vector3.new(
                math.clamp(leadPos.X, fPos.X-75+thr, fPos.X+75-thr),
                leadPos.Y,
                math.clamp(leadPos.Z, fPos.Z-175+thr, fPos.Z+175-thr)
            )
        end
        return leadPos
    end

    local function computeLead(info)
        if info.standingStill then return info.targetHead end
        local modeName, routeStr = info.modeName, info.routeStr
        local activePower = tonumber(power) or 60
        if modeName=='Bullet' or (T.AutoPower.Value and info.isChestPass) or T.HighPowerOnly.Value then activePower = 95 end
        local lDivisor = 60
        if activePower > 75 then lDivisor = 60 + ((activePower-75)*1.5) end
        local estFlightTime = info.dist / lDivisor
        local rMult = routeMultipliers[routeStr] or 1.0
        local modeLeadScale = (lead[modeName] or 8.6) * 3.05
        local yl = yLead[modeName] or 0
        local dirUnit  = info.moveDir.Magnitude > 0.01 and info.moveDir.Unit or Vector3.zero
        local chest    = info.isChestPass or modeName=='Bullet'
        local base     = chest and info.targetHRP.Position or info.targetHead
        local pos = base
            + (info.moveDir * 20 * estFlightTime * rMult)
            + (info.moveDir * 20 * getPing() * rMult)
            + (dirUnit * modeLeadScale * rMult)
            + (dirUnit * (tonumber(O.ThrowLeadOffset.Value) or 0))
        if chest then pos = Vector3.new(pos.X, info.targetHead.Y, pos.Z); yl = 0 end
        pos = pos + Vector3.new(0, yl + (tonumber(O.ThrowHeightOffset.Value) or 0), 0)
        if routeStr=='curl/comeback' or routeStr=='hitch' then pos = pos - Vector3.new(0,5,0) end
        return pos
    end

    local function applyThrowSolution(info, leadPos, forceAutoAngle)
        local gMag = 28
        local calcPower, calcAngle = solveKinematics(info.origin, leadPos, gMag)
        if info.standingStill and info.modeName ~= 'Bullet' and not T.HighPowerOnly.Value then
            local dyn = math.clamp(4 + info.dist*0.08, 5, 14)
            if calcAngle > dyn then
                local disp = leadPos - info.origin
                local x = Vector3.new(disp.X,0,disp.Z).Magnitude
                local aRad = math.rad(dyn)
                local denom = 2*(math.cos(aRad)^2)*(x*math.tan(aRad)-disp.Y)
                if denom > 0.001 then
                    local np = math.sqrt((gMag*x^2)/denom)
                    if np == np and np ~= math.huge then calcAngle, calcPower = dyn, np end
                end
            end
        end
        if T.HighPowerOnly.Value then
            power = 95
            local disp = leadPos - info.origin
            local x = Vector3.new(disp.X,0,disp.Z).Magnitude
            local v2 = 95^2
            local disc = v2^2 - gMag*(gMag*x^2 + 2*disp.Y*v2)
            angle = (disc >= 0 and x > 0.01)
                and math.clamp(math.deg(math.atan((v2-math.sqrt(disc))/(gMag*x)))*0.94, -15, 85)
                or 45
        elseif info.modeName=='Bullet' or (T.AutoPower.Value and info.isChestPass) then
            power = 95
            local disp = leadPos - info.origin
            local h = Vector3.new(disp.X,0,disp.Z).Magnitude
            local drop = 0.5*gMag*(h/95)^2
            angle = math.clamp(math.deg(math.atan2(disp.Y+drop, h)), -15, 45)
        else
            if T.AutoPower.Value then power = math.clamp(calcPower, 0, 95) end
            if T.AutoAngle.Value  then angle = math.clamp(calcAngle, -15, 90) end
        end
        if not T.AutoAngle.Value and not forceAutoAngle then
            angle = math.clamp(calcAngle, -15, 90)
        end
    end

    local function finishDirection(origin, leadPos, fallbackLook)
        local sp  = tonumber(power) or 60
        local aRad = math.rad(tonumber(angle) or 45)
        local hRaw = Vector3.new(leadPos.X-origin.X, 0, leadPos.Z-origin.Z)
        local hDir = hRaw.Magnitude > 0.01 and hRaw.Unit or fallbackLook
        direction  = (hDir*math.cos(aRad) + Vector3.new(0,math.sin(aRad),0)) * sp
        airtime    = math.max(sp*math.cos(aRad), 0.01) > 0.1
            and hRaw.Magnitude / (sp*math.cos(aRad)) or 0
    end

    local function autoAim(targetHRP)
        local char = lp.Character
        local head = char and char:FindFirstChild('Head')
        local myHRP = char and char:FindFirstChild('HumanoidRootPart')
        if not myHRP then return end
        local targetChar = targetHRP.Parent
        local tHeadObj = targetChar and targetChar:FindFirstChild('Head')
        local info = {
            origin       = head and head.Position or myHRP.Position,
            targetHRP    = targetHRP,
            targetHead   = tHeadObj and tHeadObj.Position or targetHRP.Position + Vector3.new(0,1.5,0),
            moveDir      = getMoveDir(targetChar, targetHRP),
            modeName     = ModeOrder[modeIndex],
            routeStr     = target and findRoute(target) or 'go/fade',
            dist         = (targetHRP.Position - (head and head.Position or myHRP.Position)).Magnitude,
        }
        info.isChestPass  = (info.modeName=='Bullet') or (target ~= nil and chestRoutes[info.routeStr] == true)
        info.standingStill = (info.routeStr=='stationary')

        local leadPos = computeLead(info)
        local forceAutoAngle = (info.modeName=='Bullet' or info.isChestPass or (tonumber(power) or 60)==95 or T.HighPowerOnly.Value)
        if not T.AutoAngle.Value and not forceAutoAngle then
            leadPos = leadPos + Vector3.new(0, customHeight, 0)
        end
        leadPos = adjustLeadPos(leadPos)
        targetLeadPos = leadPos
        applyThrowSolution(info, leadPos, forceAutoAngle)
        finishDirection(info.origin, leadPos, head and head.CFrame.LookVector or myHRP.CFrame.LookVector)
    end

    local function beamProjectile(g, v0, x0, t1)
        local c = 0.5*0.5*0.5
        t1 = tonumber(t1) or 0.1
        local p3 = 0.5*g*t1*t1 + v0*t1 + x0
        local p2 = p3 - (g*t1*t1 + v0*t1)/3
        local p1 = (c*g*t1*t1 + 0.5*v0*t1 + x0 - c*(x0+p3))/(3*c) - p2
        local c0 = (p1-x0).Magnitude
        local c1 = (p2-p3).Magnitude
        local b  = (x0-p3).Unit
        local r1 = (p1-x0).Unit; local u1 = r1:Cross(b).Unit
        local r2 = (p2-p3).Unit; local u2 = r2:Cross(b).Unit
        b = u1:Cross(r1).Unit
        local cf1 = CFrame.new(x0.X,x0.Y,x0.Z, r1.X,u1.X,b.X, r1.Y,u1.Y,b.Y, r1.Z,u1.Z,b.Z)
        local cf2 = CFrame.new(p3.X,p3.Y,p3.Z, r2.X,u2.X,b.X, r2.Y,u2.Y,b.Y, r2.Z,u2.Z,b.Z)
        return c0, -c1, cf1, cf2
    end

    ----------------------------------------------------------------
    -- Input
    ----------------------------------------------------------------
    track(UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not hasBall() then return end
        local char = lp.Character
        local kc   = input.KeyCode.Name

        if kc == O.ThrowAwayKey.Value then
            local fPos = getFieldPos()
            local side = math.random(1,2)==1 and -1 or 1
            local tgt  = fPos + Vector3.new(side*120, 0, math.random(-100,100))
            local head = char:FindFirstChild('Head')
            local orig = head and head.Position or char.HumanoidRootPart.Position
            isThrowingAway = true; power, angle = 95, 25
            local aRad = math.rad(25)
            local flat = Vector3.new(tgt.X-orig.X, 0, tgt.Z-orig.Z)
            direction = ((flat.Unit*math.cos(aRad) + Vector3.new(0,math.sin(aRad),0))*95).Unit*95
            airtime = flat.Magnitude / (95*math.cos(aRad))
            return
        end
        if kc == O.IncAngleKey.Value then customHeight = customHeight + 5
        elseif kc == O.DecAngleKey.Value then customHeight = customHeight - 5 end

        if not T.AutoSelectThrowMode.Value then
            for _, km in ipairs(keyModes) do
                if O[km[1]].Value == kc then
                    for i = 1, #ModeOrder do
                        if ModeOrder[i] == km[2] then modeIndex = i break end
                    end
                end
            end
        end

        if kc == O.LockKey.Value then
            if target or targetLocked then
                targetLocked = not targetLocked
                lockedTarget = targetLocked and target or nil
                if LockToggleBtn then
                    LockToggleBtn.TextColor3 = targetLocked and Color3.fromRGB(255,50,50) or Color3.fromRGB(255,255,255)
                end
                if LockedLabel then LockedLabel.Visible = targetLocked end
            end
        end
    end))

    ----------------------------------------------------------------
    -- Throw animation + sack handler
    ----------------------------------------------------------------
    local function triggerThrowJump()
        if not T.AutoJumpWhenThrow.Value then return end
        task.delay(0.05, function()
            local c   = lp.Character
            local hum = c and c:FindFirstChildOfClass('Humanoid')
            if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end

    local function startThrow()
        if isThrowing then return end
        isThrowing = true
        triggerThrowJump()
        task.delay(0.12, performThrow)
    end

    local function bindAnimation(char)
        local humanoid = char:WaitForChild('Humanoid', 5)
        if not humanoid then return end
        local animator = humanoid:WaitForChild('Animator', 5)
        if not animator then return end
        track(animator.AnimationPlayed:Connect(function(animTrack)
            local anims    = RS:FindFirstChild('Animations')
            local throwAnim = anims and anims:FindFirstChild('Throw')
            if not throwAnim then return end
            if not (animTrack.Animation and (animTrack.Animation == throwAnim or animTrack.Animation.AnimationId == throwAnim.AnimationId)) then return end
            animTrack:GetPropertyChangedSignal('IsPlaying'):Connect(function()
                if animTrack.IsPlaying then startThrow()
                else isThrowing = false; isThrowingAway = false end
            end)
            if animTrack.IsPlaying then startThrow() end
        end))
    end

    task.spawn(function()
        if lp.Character then bindAnimation(lp.Character) end
        track(lp.CharacterAdded:Connect(bindAnimation))
    end)

    local function setupSackHandler(character)
        track(character.ChildAdded:Connect(function(v)
            if not T.AutoThrowAfterSack.Value then return end
            if not v:IsA('LocalScript') or not v.Name:lower():find('tackle') then return end
            task.wait()
            local humanoid = character:FindFirstChildOfClass('Humanoid')
            if not humanoid then return end
            if T.AutoChooseWr.Value or T.SmartFit.Value then
                local best, bestDist = nil, math.huge
                local mPos = UIS:GetMouseLocation()
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= lp and plr.Character and isMate(plr) then
                        local eHrp = plr.Character:FindFirstChild('HumanoidRootPart')
                        local eHum = plr.Character:FindFirstChildOfClass('Humanoid')
                        if eHrp and (not eHum or not eHum.Sit) and isWROpen(plr.Character) then
                            local sp, on = cam():WorldToViewportPoint(eHrp.Position)
                            if on then
                                local d = (Vector2.new(sp.X,sp.Y)-mPos).Magnitude
                                if d < bestDist then bestDist, best = d, plr.Character end
                            end
                        end
                    end
                end
                if best then target, targetLocked, lockedTarget = best, true, best end
            end
            if target then
                local anims    = RS:FindFirstChild('Animations')
                local throwAnim = anims and anims:FindFirstChild('Throw')
                local animator = humanoid:FindFirstChild('Animator')
                if throwAnim and animator then animator:LoadAnimation(throwAnim):Play() end
            end
        end))
    end
    if lp.Character then setupSackHandler(lp.Character) end
    track(lp.CharacterAdded:Connect(setupSackHandler))

    ----------------------------------------------------------------
    -- Highlights / beam ChildAdded
    ----------------------------------------------------------------
    local function updateHighlights(active)
        if not active then
            if highlight then highlight:Destroy(); highlight = nil end return
        end
        if target then
            if not highlight then highlight = Instance.new('Highlight') end
            highlight.Adornee = target; highlight.Parent = target
            highlight.FillTransparency  = 1
            highlight.OutlineColor      = targetLocked and Color3.new(0,0,0) or Color3.fromRGB(255,255,255)
            highlight.OutlineTransparency = 0
        elseif highlight then highlight:Destroy(); highlight = nil end
    end
    track({Destroy = function() if highlight then highlight:Destroy() end end})

    track(workspace.ChildAdded:Connect(function(v)
        if not T.EnableQbAimbot.Value then return end
        if not (v:IsA('BasePart') and v.Name=='Football') then return end
        task.wait()
        local lpHead = lp.Character and lp.Character:FindFirstChild('Head')
        if not lpHead then return end
        if not (v:GetAttribute('LocalAimbotBall') or (v.Position-lpHead.Position).Magnitude < 15) then return end
        local a0 = Instance.new('Attachment', workspace.Terrain)
        local a1 = Instance.new('Attachment', workspace.Terrain)
        local tb  = makeBeam(a0, a1)
        local tp  = makeBall()
        local dir = direction or Vector3.new(0,1,0)
        local t   = math.max(tonumber(airtime) or 0.1, 0.1)
        local c0,c1,cf1,cf2 = beamProjectile(Vector3.new(0,-28,0), dir, lpHead.Position + dir.Unit*5, t)
        tb.CurveSize0 = c0; tb.CurveSize1 = c1
        a0.WorldCFrame = cf1; a1.WorldCFrame = cf2
        tp.Position = cf2.Position
        task.delay(t, function() tb:Destroy(); a0:Destroy(); a1:Destroy(); tp:Destroy() end)
    end))

    ----------------------------------------------------------------
    -- Main RenderStepped loop
    ----------------------------------------------------------------
    local function hideVisuals()
        beam.Enabled = false
        local off = Vector3.new(0,-9999,0)
        posPart.Position = off; attach0.WorldPosition = off; attach1.WorldPosition = off
    end

    local function runJuke(char, hrp, hasFootball, ballGui)
        if not (T.AutoJuke.Value and not isPractice and hasFootball and ballGui) then return end
        local fPos = getFieldPos()
        local dodgeVec, threatCount = Vector3.zero, 0
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character and isEnemy(plr) then
                local eHrp = plr.Character:FindFirstChild('HumanoidRootPart')
                if eHrp then
                    local distToMe = (eHrp.Position - hrp.Position).Magnitude
                    if distToMe < 45 then
                        local eVel = eHrp.AssemblyLinearVelocity
                        local eSpd = Vector3.new(eVel.X,0,eVel.Z).Magnitude
                        local ft   = math.min(distToMe/math.max(eSpd,1), 1)
                        local futDist = (eHrp.Position+eVel*ft - hrp.Position - hrp.AssemblyLinearVelocity*ft)
                        futDist = Vector3.new(futDist.X,0,futDist.Z).Magnitude
                        if futDist < 20 or distToMe < 25 then
                            threatCount = threatCount + 1
                            local away = hrp.Position + hrp.AssemblyLinearVelocity*ft - eHrp.Position - eVel*ft
                            away = Vector3.new(away.X,0,away.Z)
                            if away.Magnitude < 0.1 then away = hrp.CFrame.RightVector end
                            dodgeVec = dodgeVec + away.Unit * math.clamp(45-distToMe,0,45)
                        end
                    end
                end
            end
        end
        local hum = char:FindFirstChildOfClass('Humanoid')
        if not hum then return end
        local p = hrp.Position
        local oob = Vector3.zero
        if p.X < fPos.X-77.5+5 then oob = oob + Vector3.new(1,0,0) end
        if p.X > fPos.X+77.5-5 then oob = oob - Vector3.new(1,0,0) end
        if p.Z < fPos.Z-177.5+5 then oob = oob + Vector3.new(0,0,1) end
        if p.Z > fPos.Z+177.5-5 then oob = oob - Vector3.new(0,0,1) end
        local jukeDir = Vector3.zero
        if threatCount > 0 and dodgeVec.Magnitude > 0 then
            jukeDir = dodgeVec.Unit
            if oob.Magnitude > 0 then jukeDir = (jukeDir + oob*2).Unit end
        elseif oob.Magnitude > 0 then jukeDir = oob.Unit end
        if jukeDir.Magnitude > 0 then
            smoothedJukeDir = smoothedJukeDir:Lerp(jukeDir, 0.25)
            hum:Move(smoothedJukeDir, false)
        else smoothedJukeDir = Vector3.zero end
    end

    local function updateAim(head, hrp)
        if not isThrowingAway then
            local newTarget = getTarget()
            if newTarget then lastValidTarget = newTarget
            elseif lastValidTarget and not lastValidTarget:FindFirstChild('HumanoidRootPart') then
                lastValidTarget = nil end

            if T.ThrowAimbot.Value then
                target = lastValidTarget; updateHighlights(false)
                local tgtPos
                if isThrowing and lockedMousePos then tgtPos = lockedMousePos
                else tgtPos = mouse.Hit.Position; lockedMousePos = tgtPos end
                local headPos = head.Position
                local calcP, calcA = solveKinematics(headPos, tgtPos, 28)
                if T.AutoPower.Value then power = math.clamp(calcP, 0, 95) end
                angle = T.AutoAngle.Value and math.clamp(calcA,-15,90) or math.clamp(customHeight,-15,90)
                local sp, aRad = tonumber(power) or 60, math.rad(tonumber(angle) or 45)
                local hRaw = Vector3.new(tgtPos.X-headPos.X, 0, tgtPos.Z-headPos.Z)
                local hDir = hRaw.Magnitude > 0.01 and hRaw.Unit or hrp.CFrame.LookVector
                direction = ((hDir*math.cos(aRad) + Vector3.new(0,math.sin(aRad),0))*sp).Unit*sp
                airtime = sp*math.cos(aRad) > 0.1 and hRaw.Magnitude/(sp*math.cos(aRad)) or 0
                targetLeadPos = tgtPos
            else
                target = newTarget or lastValidTarget; updateHighlights(true)
                if target then
                    local tHRP = target:FindFirstChild('HumanoidRootPart')
                    if tHRP then
                        if T.AutoSelectThrowMode.Value then
                            local m = calculateRouteDirection(target)
                            for i=1,#ModeOrder do if ModeOrder[i]==m then modeIndex=i break end end
                            local r = findRoute(target)
                            if ModeOrder[modeIndex]=='Bullet' and (r=='go/fade' or r=='post/corner') then
                                for i=1,#ModeOrder do if ModeOrder[i]=='Mag' then modeIndex=i break end end
                            end
                        end
                        autoAim(tHRP)
                    end
                end
            end
        else target = nil; updateHighlights(false) end
    end

    local function updateCards()
        local sp = tonumber(power) or 60; if sp ~= sp then sp = 60 end
        if HUDCards['Angle'] then
            local mName = ModeOrder[modeIndex]
            local r = target and findRoute(target) or 'go/fade'
            local forceAuto = (mName=='Bullet') or (target ~= nil and chestRoutes[r]) or sp==95 or T.HighPowerOnly.Value
            HUDCards['Angle'].Text = tostring(math.floor(not T.AutoAngle.Value and not forceAuto and customHeight or (tonumber(angle) or 45)))
        end
        if HUDCards['Power']     then HUDCards['Power'].Text     = string.format('%.0f', sp) end
        if HUDCards['Airtime']   then HUDCards['Airtime'].Text   = string.format('%.1fs', tonumber(airtime) or 0) end
        if HUDCards['Throw Type']then HUDCards['Throw Type'].Text = tostring(ModeOrder[modeIndex] or 'N/A') end
        if HUDCards['Player'] and not T.SmartFitDebug.Value then
            HUDCards['Player'].Text = T.ThrowAimbot.Value and 'MOUSE' or ((target and target.Name) or 'NONE')
        end
    end

    local function updatePowerUI(ballGui)
        if not (T.AutoChangePowerUI.Value and ballGui and ballGui:FindFirstChild('Frame0')) then return end
        local frame0 = ballGui.Frame0
        local sp = tonumber(power) or 60; if sp ~= sp then sp = 60 end
        local dp = math.round(sp/5)*5
        local txt = frame0:FindFirstChildOfClass('TextLabel')
        if txt then txt.Text = tostring(math.floor(dp)) end
        for _, frame in ipairs(frame0:GetChildren()) do
            if frame.Name ~= 'Disp' then
                pcall(function() frame.BackgroundTransparency = (tonumber(frame.Name) or 0) <= dp and 0 or 0.9 end)
            end
        end
    end

    track(RunService.RenderStepped:Connect(function()
        if not Alive then return end
        if not T.EnableQbAimbot.Value then
            updateHUDVisibility(false); updateHighlights(false); hideVisuals(); target = nil return
        end
        local char = lp.Character
        if not char then return end
        local head = char:FindFirstChild('Head')
        local hrp  = char:FindFirstChild('HumanoidRootPart')
        if not head or not hrp then return end

        local football  = char:FindFirstChild('Football')
        local hasFootball = football ~= nil
        if hasFootball then
            football:SetAttribute('LocalAimbotBall', true)
            local fh = football:FindFirstChild('Handle')
            if fh then fh:SetAttribute('LocalAimbotBall', true) end
        end

        local playerGui = lp:FindFirstChild('PlayerGui')
        local ballGui   = playerGui and playerGui:FindFirstChild('BallGui')
        runJuke(char, hrp, hasFootball, ballGui)

        local isTracking = hasFootball and (ballGui ~= nil)
        if isTracking then
            updateHUDVisibility(not T.HideCards.Value)
            updateAim(head, hrp)
            updatePowerUI(ballGui)
            updateCards()
        else
            updateHUDVisibility(false); updateHighlights(false)
            target, lastValidTarget = nil, nil
        end

        if isTracking then
            beam.Enabled = true
            local sp = tonumber(power) or 60
            local drawDir = direction or Vector3.new(0,1,0)
            if T.ThrowAimbot.Value then
                if drawDir.Magnitude < 0.1 then drawDir = Vector3.new(0,1,0)*sp end
            elseif not target or not targetLeadPos then
                local ray = cam():ScreenPointToRay(mouse.X, mouse.Y)
                drawDir = ray.Direction.Unit*sp; direction = drawDir
            elseif drawDir.Magnitude < 0.1 then drawDir = Vector3.new(0,1,0)*sp end
            local t2 = math.max(tonumber(airtime) or 0.1, 0.1)
            local c0,c1,cf1,cf2 = beamProjectile(Vector3.new(0,-28,0), drawDir, head.Position+drawDir.Unit*5, t2)
            beam.CurveSize0=c0; beam.CurveSize1=c1
            attach0.WorldCFrame=cf1; attach1.WorldCFrame=cf2
            posPart.Position = cf2.Position
        else hideVisuals() end
    end))
end)

------------------------------------------------------------------------
-- LOGIC: Catching  (unchanged from v1)
------------------------------------------------------------------------
Run('LOGIC: Catching', function()
    local part = track(Instance.new('Part'))
    part.Color = Color3.fromRGB(255,255,255); part.Shape = Enum.PartType.Ball
    part.Material = Enum.Material.ForceField; part.CastShadow = false
    part.Anchored = true; part.CanCollide = false

    local function selectedRange()
        local r = tonumber(O.MagnetsRadius.Value) or 0
        local m = tostring(O.MagsType.Value or 'Custom'):lower()
        if m=='legit' then return r/2 elseif m=='league' then return r/1.4
        elseif m=='blatant' then return r*1.5 end return r
    end

    loop(nil, function()
        local character, humanoid = charParts()
        if not character or not humanoid then return end
        local ball = findClosestBall()
        if not ball then part.Parent = nil return end
        local range = selectedRange()
        part.Size = Vector3.new(range,range,range)
        part.CFrame = CFrame.new(ball.Position)
        part.Parent = (T.FootballMagnets.Value and T.ShowCatchHitbox.Value) and workspace.Terrain or nil
        if not T.FootballMagnets.Value then return end
        if T.FreeFallCheck.Value and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then return end
        for _, v in next, character:GetChildren() do
            if v:IsA('BasePart') and v.Name:lower():find('catch') then
                if (ball.Position-v.Position).Magnitude < range then
                    TweenService:Create(v, TweenInfo.new(O.MagnetsDelay.Value), {Position=ball.Position}):Play()
                    pcall(function() firetouchinterest(v,ball,0); firetouchinterest(v,ball,1) end)
                end
            end
        end
    end)

    loop(0.1, function()
        if not T.MagEnhancer.Value then return end
        local character, _, hrp = charParts()
        if not hrp then return end
        local ball = findClosestBall()
        if not ball then return end
        if ball.Position.Y - hrp.Position.Y > O.MagEnhancerMaxAngle.Value then return end
        local diff = ball.Position - hrp.Position
        if diff.Magnitude < 0.001 then return end
        local dot = hrp.CFrame.LookVector:Dot(diff.Unit)
        for _, v in next, character:GetChildren() do
            if v:IsA('BasePart') and v.Name:lower():find('catch') then
                if dot > 0 and (ball.Position-v.Position).Magnitude <= O.MagEnhancerRadius.Value then
                    TweenService:Create(v, TweenInfo.new(0), {Position=ball.Position}):Play()
                    pcall(function() firetouchinterest(v,ball,0); firetouchinterest(v,ball,1) end)
                end
            end
        end
    end)

    loop(nil, function()
        if not T.PullVector.Value then return end
        local _, _, hrp = charParts()
        if not hrp then return end
        local ball = findClosestBall()
        if not ball then return end
        local diff = ball.Position - hrp.Position
        if diff.Magnitude > O.PullVectorRadius.Value or diff.Magnitude < 0.001 then return end
        hrp.AssemblyLinearVelocity = diff.Unit * (O.PullVectorPower.Value * 25)
    end)

    loop(nil, function()
        local character = lp.Character
        if not character then return end
        for _, v in next, character:GetChildren() do
            if v:IsA('BasePart') and v.Name:lower():find('t arm') then
                v.Size = Vector3.new(v.Size.X, T.IncreaseArmSize.Value and O.ArmSizeValue.Value or 2, v.Size.Z)
            end
        end
    end)
end)

------------------------------------------------------------------------
-- LOGIC: Player
------------------------------------------------------------------------
Run('LOGIC: Player', function()
    loop(nil, function()
        if not T.CustomWalkSpeed.Value then return end
        local _, humanoid, root = charParts()
        if not humanoid or not root then return end
        if humanoid.PlatformStand or humanoid.WalkSpeed == 0 then return end
        local dir = Vector3.new(humanoid.MoveDirection.X,0,humanoid.MoveDirection.Z)
        if dir.Magnitude <= 0 then return end
        local cframeMode = (O.WalkspeedType.Value == 'CFrame')
        local vel = dir.Unit * (cframeMode and (O.WalkSpeedValue.Value/75) or O.WalkSpeedValue.Value)
        if humanoid:GetState() == Enum.HumanoidStateType.Running then
            local scale = O.WalkSpeedValue.Value / math.max(humanoid.WalkSpeed, 1)
            local anim  = humanoid:FindFirstChildOfClass('Animator')
            if anim then for _, tr in next, anim:GetPlayingAnimationTracks() do tr:AdjustSpeed(scale) end end
        end
        if not cframeMode then root.AssemblyLinearVelocity = Vector3.new(vel.X, root.AssemblyLinearVelocity.Y, vel.Z)
        else root.CFrame = root.CFrame + vel end
    end)

    loop(nil, function()
        if not T.CustomJumpPower.Value then return end
        local _, humanoid, root = charParts()
        if not humanoid or not root then return end
        if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then return end
        task.wait()
        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, O.JumpPowerValue.Value, root.AssemblyLinearVelocity.Z)
    end)
end)

Run('Angle enhancer', function()
    local lastTick, oldLook = 0, nil
    loop(nil, function()
        if not T.AngleEnhancer.Value then return end
        local _, humanoid, hrp = charParts()
        if not humanoid or not hrp then oldLook = nil return end
        if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then return end
        local now = tick(); local newLook = hrp.CFrame.LookVector
        if not oldLook then oldLook, lastTick = newLook, now return end
        local angleDelta = math.acos(math.clamp(oldLook:Dot(newLook),-1,1))
        if now - lastTick >= 0.2 and angleDelta > math.rad(5) then lastTick, oldLook = now, newLook end
        if angleDelta > math.rad(25) and now - lastTick <= 2.5 then
            lastTick, oldLook = now, newLook
            task.wait()
            local vel = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, O.AngleEnhanceBoost.Value, vel.Z)
            if T.AngleEnhancerIndicator.Value then Library:Notify('Angled!', 2.5) end
        end
    end)
end)

Run('Auto flip', function()
    local runtime, jumptime, hittime = 0, 0, 0
    local arm, vLine, used, prevPs = false, nil, false, false
    local seq, pack = 0, nil
    local function xz(v)
        local f = Vector3.new(v.X,0,v.Z); return f.Magnitude > 0.001 and f.Unit or nil
    end
    local function reset()
        if not pack then return end
        for _, o in next, {pack.spin,pack.ra,pack.pivot,pack.ha} do if o then o:Destroy() end end
        pack = nil
    end
    local function flip(root, head)
        reset()
        local m = math.max(root.AssemblyMass, 1)
        local ha = Instance.new('Attachment', head)
        local pivot = Instance.new('AlignPosition', head)
        pivot.Mode = Enum.PositionAlignmentMode.OneAttachment
        pivot.Attachment0 = ha; pivot.Position = head.Position + Vector3.new(0,0.15,0)
        pivot.MaxForce = 180000; pivot.Responsiveness = 120
        pivot.RigidityEnabled = false; pivot.ApplyAtCenterOfMass = false
        local ra   = Instance.new('Attachment', root)
        local spin = Instance.new('AngularVelocity', root)
        spin.Attachment0 = ra; spin.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
        spin.AngularVelocity = Vector3.new(-9,0,0); spin.MaxTorque = 50000
        root:ApplyAngularImpulse(root.CFrame.RightVector*(-16*m))
        pack = {ha=ha,pivot=pivot,ra=ra,spin=spin}
    end
    track({Destroy = reset})
    loop(nil, function()
        if not T.AutoFlip.Value then return end
        local char = lp.Character
        if not char then reset(); arm,vLine,used,prevPs = false,nil,false,false return end
        local hum = char:FindFirstChildOfClass('Humanoid')
        local hrp = char:FindFirstChild('HumanoidRootPart')
        local head = char:FindFirstChild('Head')
        if not hum or not hrp or not head then return end
        local now = tick()
        if hum:GetState()==Enum.HumanoidStateType.Running then runtime = now end
        if hum:GetState()==Enum.HumanoidStateType.Jumping then jumptime = now end
        local ps = hum.PlatformStand
        if ps ~= prevPs then
            if ps then
                arm  = (now-runtime<=0.5) and (now-jumptime<=0.7)
                vLine = xz(hrp.AssemblyLinearVelocity) or xz(hrp.CFrame.LookVector); used = false
            else arm,vLine,used = false,nil,false; seq += 1; reset() end
            prevPs = ps
        end
        if not ps or not arm or pack then return end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {char}
        local result = workspace:Raycast(head.Position, Vector3.new(0,-3,0), params)
        if used or not (result and result.Instance) or now-hittime < 0.12 then return end
        if result and (head.Position-result.Position).Magnitude > 1.6 then return end
        local move = xz(hrp.AssemblyLinearVelocity) or vLine
        local face = xz(hrp.CFrame.LookVector)
        if not move or not face or face:Dot(move) < 0.78 then return end
        hittime = now; used = true; seq += 1; local k = seq
        flip(hrp, head)
        task.delay(0.24, function() if k == seq then reset() end end)
    end)
end)

------------------------------------------------------------------------
-- LOGIC: Defense / Physics
------------------------------------------------------------------------
Run('LOGIC: Defense + Physics', function()
    track(UIS.InputBegan:Connect(function(input, gpe)
        if gpe or not T.QuickTP.Value then return end
        if input.KeyCode.Name ~= O.QuickTPKey.Value then return end
        local _, _, hrp = charParts()
        if not hrp then return end
        hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * O.QuickTPPower.Value
    end))

    loop(nil, function()
        local _, humanoid = charParts()
        if humanoid then
            if T.AntiJumpCooldown.Value then humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) end
            if T.AntiFreeze.Value and humanoid.WalkSpeed ~= 20 then humanoid.WalkSpeed = 20 end
        end
        if T.AntiBench.Value then
            local pg = lp:FindFirstChild('PlayerGui')
            local bb = pg and pg:FindFirstChild('Benched', true)
            if bb and bb.BackgroundColor3 == Color3.fromRGB(120,120,120) then fireSound('Game','ToggleBench') end
        end
        for _, plr in next, Players:GetPlayers() do
            if plr ~= lp and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass('Humanoid')
                if hum then
                    for _, p in next, plr.Character:GetChildren() do
                        if p:IsA('BasePart') and (p.Name=='Head' or p.Name=='Torso') then
                            p.CanCollide = not (T.AntiJam.Value and hum:GetState()==Enum.HumanoidStateType.Running)
                        end
                    end
                end
            end
        end
    end)

    loop(nil, function()
        if not T.AntiBlock.Value then return end
        local character, humanoid = charParts()
        if not character or not humanoid then return end
        for _, v in next, character:GetDescendants() do
            if v:IsA('BodyVelocity') then
                v.Velocity = Vector3.zero; v.MaxForce = Vector3.zero
                humanoid.WalkSpeed = 20
                pcall(function() v:Destroy() end)
            end
        end
    end)

    local origHeads = setmetatable({}, {__mode='k'})
    loop(nil, function()
        for _, v in next, Players:GetPlayers() do
            if v ~= lp and v.Character then
                local head = v.Character:FindFirstChild('Head')
                if head then
                    if T.BigHead.Value then
                        if not origHeads[head] then origHeads[head] = head.Size end
                        local s = O.BigHeadSize.Value
                        head.Size = Vector3.new(s,s,s)
                    elseif origHeads[head] then
                        head.Size = origHeads[head]; origHeads[head] = nil
                    end
                end
            end
        end
    end)

    -- Swat
    loop(nil, function()
        if not T.SwatReach.Value then return end
        local character = lp.Character
        if not character then return end
        local ball = findClosestBall()
        if not ball then return end
        for _, v in next, character:GetChildren() do
            if v:IsA('BasePart') and v.Name:lower():find('catch') then
                if (ball.Position-v.Position).Magnitude < O.SwatReachDistance.Value and v.Size.X > 2 then
                    pcall(function() firetouchinterest(v,ball,0); firetouchinterest(v,ball,1) end)
                end
            end
        end
    end)

    local bodyParts = {'Torso','Head','HumanoidRootPart','Left Arm','Left Leg','Right Arm','Right Leg'}
    loop(nil, function()
        local character, _, hrp = charParts()
        if not character or not hrp then return end
        for _, v in next, Players:GetPlayers() do
            local c = v.Character
            local h = c and c:FindFirstChildOfClass('Humanoid')
            local r = c and c:FindFirstChild('HumanoidRootPart')
            if v ~= lp and v.Team ~= lp.Team and h and r then
                if T.TackleReach.Value and c:FindFirstChild('Football') then
                    local pick = bodyParts[math.random(1,#bodyParts)]
                    fireSound('Game','TackleTouch',pick,pick)
                end
                if T.TackleAimbot.Value and h.WalkSpeed > 0 and c:FindFirstChild('Football') then
                    if (r.Position-hrp.Position).Magnitude < O.TackleAimbotRange.Value then
                        hrp.CFrame = r.CFrame
                    end
                end
            end
        end
    end)
end)

------------------------------------------------------------------------
-- LOGIC: Detectors  (NEW)
------------------------------------------------------------------------
Run('LOGIC: Detectors', function()
    -- Shared state
    local detectionLog = {}  -- {time, player, reason}
    local MAX_LOG = 5

    local function addLog(plrName, reason)
        table.insert(detectionLog, 1, string.format('[%s] %s — %s', os.date('%H:%M:%S'), plrName, reason))
        while #detectionLog > MAX_LOG do table.remove(detectionLog) end
    end

    local function notifyDetection(plrName, reason, key)
        local msg = '⚠ ' .. plrName .. ' — ' .. reason
        if T[key .. 'Notify'].Value then Library:Notify(msg, 5) end
        if T[key .. 'Chat'].Value   then print('[67 FF3 Detector] ' .. msg) end
        addLog(plrName, reason)
    end

    -- Per-player detection state
    local playerState = setmetatable({}, {__mode='k'})
    local function getState(plr)
        if not playerState[plr] then
            playerState[plr] = {
                magCount   = 0,
                magTimer   = 0,
                lastPos    = nil,
                lastPosTime = 0,
                flagCooldown = 0,
            }
        end
        return playerState[plr]
    end

    -- ── Mag Detector ────────────────────────────────────────────────
    -- Logic: detect firetouchinterest via proxy — watch for rapid catch
    -- part hits from the same player's character in a short window.
    -- Since we can't hook firetouchinterest directly in-game, we detect
    -- the outcome: a player catching balls that are far from their catch
    -- parts at an impossible rate, or landing catches while their catch
    -- parts are nowhere near the ball.
    --
    -- Implementation: poll every 0.1s, count how many times per second
    -- a ball is within X studs of the player's root but their catch
    -- part is NOT touching it — indicates the ball was pulled to them.

    local MAG_SAMPLE_WINDOW = 1.0  -- seconds

    loop(0.1, function()
        if not T.MagDetector.Value then return end
        local now = tick()
        local ball = findClosestBall()
        if not ball then return end

        for _, plr in next, Players:GetPlayers() do
            if plr == lp then continue end
            local c = plr.Character
            local hrp = c and c:FindFirstChild('HumanoidRootPart')
            if not hrp then continue end

            local st = getState(plr)

            -- Look for a catch part being suspiciously far from the ball
            -- but the ball being within the player's general area (mag range)
            local ballDist = (ball.Position - hrp.Position).Magnitude
            if ballDist > 30 then continue end  -- too far, not interesting

            local catchPartFound = false
            local catchPartNearBall = false
            for _, v in next, c:GetChildren() do
                if v:IsA('BasePart') and v.Name:lower():find('catch') then
                    catchPartFound = true
                    if (ball.Position - v.Position).Magnitude < 4 then
                        catchPartNearBall = true
                        break
                    end
                end
            end

            -- Suspicious: ball near player root, but catch part far away
            -- This means firetouchinterest was likely used
            if catchPartFound and not catchPartNearBall and ballDist < 15 then
                st.magCount = st.magCount + 1
                st.magTimer = now
            end

            -- Reset old counts
            if now - st.magTimer > MAG_SAMPLE_WINDOW then
                st.magCount = 0
            end

            local threshold = O.MagDetectorThreshold.Value or 6
            if st.magCount >= threshold and now - st.flagCooldown > 10 then
                st.flagCooldown = now
                st.magCount = 0
                notifyDetection(plr.Name, 'possible mag use (' .. threshold .. ' hits/s)', 'MagDetector')
            end
        end
    end)

    -- ── WalkSpeed Detector ──────────────────────────────────────────
    -- Logic: measure actual velocity magnitude vs max allowed WalkSpeed.
    -- We take the XZ component of AssemblyLinearVelocity each frame and
    -- compare it to the server-visible WalkSpeed. A consistent surplus
    -- over the limit for 0.5s triggers a flag.

    local wsBuffer = setmetatable({}, {__mode='k'})  -- plr -> {count, total}

    loop(0.1, function()
        if not T.WalkSpeedDetector.Value then return end
        local limit = O.WalkSpeedDetectorLimit.Value or 26
        local now   = tick()

        for _, plr in next, Players:GetPlayers() do
            if plr == lp then continue end
            local c   = plr.Character
            local hrp = c and c:FindFirstChild('HumanoidRootPart')
            local hum = c and c:FindFirstChildOfClass('Humanoid')
            if not hrp or not hum then continue end

            local vel = hrp.AssemblyLinearVelocity
            local xzSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude

            if not wsBuffer[plr] then wsBuffer[plr] = {over = 0, start = now} end
            local buf = wsBuffer[plr]

            if xzSpeed > limit then
                buf.over = buf.over + 1
            else
                buf.over = math.max(buf.over - 1, 0)
            end

            local st = getState(plr)
            -- 5 consecutive over-limit samples in ~0.5s = flag
            if buf.over >= 5 and now - st.flagCooldown > 10 then
                st.flagCooldown = now
                buf.over = 0
                local overage = string.format('%.1f studs/s (limit: %d)', xzSpeed, limit)
                notifyDetection(plr.Name, 'speed hack — ' .. overage, 'WalkSpeedDetector')
            end
        end
    end)

    -- ── CFrame Detector ─────────────────────────────────────────────
    -- Logic: track position each frame, compute delta vs expected
    -- displacement from velocity*dt. A spike larger than threshold
    -- that can't be explained by physics = teleport.

    local lastPositions = setmetatable({}, {__mode='k'})  -- plr -> {pos, time}

    loop(nil, function()
        if not T.CFrameDetector.Value then return end
        local now       = tick()
        local threshold = O.CFrameDetectorThreshold.Value or 18

        for _, plr in next, Players:GetPlayers() do
            if plr == lp then continue end
            local c   = plr.Character
            local hrp = c and c:FindFirstChild('HumanoidRootPart')
            if not hrp then continue end

            local pos = hrp.Position
            local prev = lastPositions[plr]

            if prev then
                local dt       = now - prev.time
                if dt > 0 and dt < 0.5 then
                    local actualDelta   = (pos - prev.pos).Magnitude
                    -- Expected max delta = velocity * dt + small physics buffer
                    local vel           = hrp.AssemblyLinearVelocity
                    local expectedMax   = vel.Magnitude * dt + 6  -- 6 stud buffer for physics
                    local unexplained   = actualDelta - expectedMax

                    if unexplained > threshold then
                        local st = getState(plr)
                        if now - st.flagCooldown > 10 then
                            st.flagCooldown = now
                            local info = string.format('teleported %.0f studs (expected %.0f)', actualDelta, expectedMax)
                            notifyDetection(plr.Name, info, 'CFrameDetector')
                        end
                    end
                end
            end

            lastPositions[plr] = {pos = pos, time = now}
        end
    end)

    -- ── Update detection log labels in UI ───────────────────────────
    -- LinoriaLib labels are found in the Detectors tab. We rebuild them.
    -- Since we can't reference the label objects created in the UI block
    -- (they're in a different Run scope), we update via a simple ScreenGui.

    local logSg = track(Instance.new('ScreenGui'))
    logSg.ResetOnSpawn = false
    logSg.DisplayOrder = 5
    pcall(function() logSg.Parent = (gethui and gethui()) or game:GetService('CoreGui') end)
    if not logSg.Parent then logSg.Parent = lp:WaitForChild('PlayerGui', 10) end

    local logFrame = Instance.new('Frame', logSg)
    logFrame.BackgroundColor3 = Color3.fromRGB(10,10,10)
    logFrame.BackgroundTransparency = 0.3
    logFrame.BorderSizePixel = 0
    logFrame.Size = UDim2.new(0, 300, 0, 115)
    logFrame.Position = UDim2.new(0, 8, 1, -125)
    logFrame.Visible  = false
    Instance.new('UICorner', logFrame).CornerRadius = UDim.new(0,4)

    local logTitle = Instance.new('TextLabel', logFrame)
    logTitle.Size = UDim2.new(1,0,0,16)
    logTitle.Position = UDim2.new(0,6,0,4)
    logTitle.BackgroundTransparency = 1
    logTitle.Text = '67 DETECTOR LOG'
    logTitle.TextColor3 = Color3.fromRGB(200,200,200)
    logTitle.TextSize   = 11
    logTitle.TextXAlignment = Enum.TextXAlignment.Left
    pcall(function() logTitle.Font = Enum.Font.Code end)

    local logLines = {}
    for i = 1, 5 do
        local l = Instance.new('TextLabel', logFrame)
        l.Size = UDim2.new(1,-8,0,16)
        l.Position = UDim2.new(0,6,0,16+(i-1)*19)
        l.BackgroundTransparency = 1
        l.Text = ''
        l.TextColor3 = Color3.fromRGB(255,120,60)
        l.TextSize   = 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextTruncate = Enum.TextTruncate.AtEnd
        pcall(function() l.Font = Enum.Font.Code end)
        logLines[i] = l
    end

    -- Show log only when at least one detector is on
    loop(0.5, function()
        local any = T.MagDetector.Value or T.WalkSpeedDetector.Value or T.CFrameDetector.Value
        logFrame.Visible = any
        for i = 1, 5 do
            logLines[i].Text = detectionLog[i] or ''
        end
    end)
end)

------------------------------------------------------------------------
-- LOGIC: Automatics — REWORKED Auto Rush
------------------------------------------------------------------------
Run('Auto rush [reworked]', function()
    -- State
    local rushTarget = nil
    local lastEngageTime = 0
    local predictedPos = Vector3.zero

    local function getFieldBounds()
        local fPos = getFieldPos()
        if fPos == Vector3.zero then
            return {minX=-80,maxX=80,minZ=-180,maxZ=180}
        end
        return {
            minX = fPos.X - 77,
            maxX = fPos.X + 77,
            minZ = fPos.Z - 177,
            maxZ = fPos.Z + 177,
        }
    end

    local function inField(pos)
        local b = getFieldBounds()
        return pos.X > b.minX and pos.X < b.maxX and pos.Z > b.minZ and pos.Z < b.maxZ
    end

    -- Score a carrier as a rush target
    local function carrierScore(char, myHRP)
        local hrp = char:FindFirstChild('HumanoidRootPart')
        local hum = char:FindFirstChildOfClass('Humanoid')
        if not hrp or not hum or not char:FindFirstChild('Football') then return -math.huge end
        if hum.WalkSpeed <= 0 or hum.PlatformStand then return -math.huge end

        local dist = (hrp.Position - myHRP.Position).Magnitude
        local limit = O.AutoRushEngageDistance.Value or 40
        if dist > limit then return -math.huge end

        local score = 100 - dist  -- closer = higher base score
        -- Penalize if we're not in a good rush angle (behind or to the side = better)
        local toCarrier = (hrp.Position - myHRP.Position).Unit
        local myFacing  = myHRP.CFrame.LookVector
        local dot = myFacing:Dot(toCarrier)
        score = score + dot * 10

        -- Bonus if carrier is moving toward us (intercept opportunity)
        local cVel = hrp.AssemblyLinearVelocity
        local cDir = Vector3.new(cVel.X,0,cVel.Z)
        if cDir.Magnitude > 0.5 then
            local toward = -(hrp.Position - myHRP.Position).Unit
            local approach = cDir.Unit:Dot(toward)
            score = score + approach * 15
        end

        return score
    end

    -- Predict where the carrier will be accounting for cuts
    local function predictCarrierPos(char, myHRP, ping)
        local hrp = char:FindFirstChild('HumanoidRootPart')
        local hum = char:FindFirstChildOfClass('Humanoid')
        if not hrp or not hum then return hrp and hrp.Position or Vector3.zero end

        local vel    = hrp.AssemblyLinearVelocity
        local speed  = hum.WalkSpeed
        local moveDir = hum.MoveDirection
        local xzVel   = Vector3.new(vel.X, 0, vel.Z)

        -- Base prediction: linear extrapolation
        local reactionTotal = ping + (O.AutoRushReactionTime.Value or 0.1)
        local dist  = (hrp.Position - myHRP.Position).Magnitude
        local mySpd = math.max(lp.Character and lp.Character:FindFirstChild('HumanoidRootPart') and
                     lp.Character.HumanoidRootPart.AssemblyLinearVelocity.Magnitude or 16, 8)
        local timeToArrive = dist / mySpd

        local basePred = hrp.Position + moveDir * speed * (reactionTotal + timeToArrive * 0.5)

        -- Cut prediction: if ZoneAware, check if carrier might turn
        if T.AutoRushPredictCut.Value then
            -- If the carrier's velocity doesn't match move direction, they may be cutting
            local velDir = xzVel.Magnitude > 1 and xzVel.Unit or moveDir
            local movFlat = Vector3.new(moveDir.X,0,moveDir.Z)
            if movFlat.Magnitude > 0.01 and velDir.Magnitude > 0.01 then
                local cutDot = velDir:Dot(movFlat.Unit)
                if cutDot < 0.7 then
                    -- They're cutting — lead toward where velocity is pointing
                    basePred = hrp.Position + velDir * speed * (reactionTotal + timeToArrive * 0.3)
                end
            end
        end

        -- Zone awareness: don't rush past the field boundary
        if T.AutoRushZoneAware.Value then
            local bounds = getFieldBounds()
            basePred = Vector3.new(
                math.clamp(basePred.X, bounds.minX + 5, bounds.maxX - 5),
                basePred.Y,
                math.clamp(basePred.Z, bounds.minZ + 5, bounds.maxZ - 5)
            )
        end

        return basePred
    end

    loop(nil, function()
        if not T.AutoRush.Value then rushTarget = nil return end
        local character, humanoid, hrp = charParts()
        if not humanoid or not hrp then return end

        -- Walk to line pre-play
        if T.WalkToLine.Value and lp.Team then
            local flags = RS:FindFirstChild('Flags')
            local poss  = flags and flags:FindFirstChild('PossessionTag')
            local status = flags and flags:FindFirstChild('Status')
            if poss and status and poss.Value ~= lp.Team.Name and status.Value == 'PrePlay' then
                local line = workspace:FindFirstChild('LineDown')
                if line then humanoid:MoveTo(line.Position) return end
            end
        end

        local ping = 0
        pcall(function() ping = Stats.Network.ServerStatsItem['Data Ping']:GetValue()/1000 end)

        -- Find best carrier to rush
        local bestChar, bestScore = nil, -math.huge
        for _, v in next, Players:GetPlayers() do
            if v ~= lp and v.Team ~= lp.Team and v.Character then
                local s = carrierScore(v.Character, hrp)
                if s > bestScore then bestScore, bestChar = s, v.Character end
            end
        end

        if not bestChar then rushTarget = nil return end

        rushTarget = bestChar
        predictedPos = predictCarrierPos(bestChar, hrp, ping)

        -- Zone check: only rush if we're in a sensible field zone
        if T.AutoRushZoneAware.Value then
            if not inField(hrp.Position) then return end
        end

        humanoid:MoveTo(predictedPos)
    end)
end)

Run('Auto catch / swat / QB / captain / freeze / boost', function()
    -- Auto Catch / Swat
    loop(nil, function()
        if not T.AutoCatch.Value and not T.AutoSwat.Value then return end
        local _, _, hrp = charParts()
        if not hrp then return end
        local ball = findClosestBall()
        if not ball then return end
        local d = (ball.Position-hrp.Position).Magnitude
        if T.AutoCatch.Value and d <= O.AutoCatchRadius.Value then fireSound('PlayerActions', isPractice and 'catch ' or 'catch') end
        if T.AutoSwat.Value  and d <= O.AutoSwatRadius.Value  then fireSound('PlayerActions', 'swat') end
    end)

    -- Auto Captain
    local hooked = setmetatable({}, {__mode='k'})
    loop(nil, function()
        if not T.AutoCaptain.Value or lp.Team then return end
        local _, _, hrp = charParts()
        if not hrp then return end
        local m = workspace:FindFirstChild('Models')
        local room = m and m:FindFirstChild('LockerRoomA')
        if not room then return end
        for _, v in next, room:GetChildren() do
            if v:IsA('BasePart') and v.Name:lower():find('finishline') and not hooked[v] then
                hooked[v] = true
                track(v:GetPropertyChangedSignal('CFrame'):Connect(function()
                    if not T.AutoCaptain.Value or lp.Team then return end
                    for _ = 1, 4 do task.wait() local _,_,r = charParts() if r then r.CFrame = v.CFrame end end
                end))
            end
        end
    end)

    -- Auto Freeze
    track(UIS.InputBegan:Connect(function(input, gpe)
        if gpe or not T.AutoFreeze.Value then return end
        local bind = O.FreezeKey.Value
        if not bind or bind == 'None' or input.KeyCode.Name ~= bind then return end
        local _, _, hrp = charParts()
        if not hrp then return end
        hrp.Anchored = true
        task.delay(O.FreezeDuration.Value, function() if hrp then hrp.Anchored = false end end)
    end))

    -- Auto QB
    loop(nil, function()
        if not T.AutoQb.Value then return end
        local _, humanoid, hrp = charParts()
        if not humanoid or not hrp then return end
        local ball = findClosestBall()
        if not ball then return end
        local flags  = RS:FindFirstChild('Flags')
        local poss   = flags and flags:FindFirstChild('PossessionTag')
        local status = flags and flags:FindFirstChild('Status')
        if poss and status and lp.Team and poss.Value == lp.Team.Name and status.Value == 'PrePlay' then
            if O.AutoQbMethod.Value == 'Walk' then humanoid:MoveTo(ball.Position)
            else hrp.CFrame = ball.CFrame end
        else pcall(function() ball.CFrame = hrp.CFrame end) end
    end)

    -- Auto Boost
    local activeTween
    local function cancelTween() if activeTween then activeTween:Cancel(); activeTween = nil end end
    track({Destroy = cancelTween})
    loop(nil, function()
        if not T.AutoBoost.Value then cancelTween() return end
        local char, hum, hrp = charParts()
        if not hum or not hrp then return end
        if hum:GetState() == Enum.HumanoidStateType.Landed then cancelTween() return end
        local myHead = char:FindFirstChild('Head')
        if not myHead then return end
        local myState = hum:GetState()
        if myState ~= Enum.HumanoidStateType.Jumping and myState ~= Enum.HumanoidStateType.Freefall then return end

        local targetP
        if T.TargetClosestPlayer.Value then
            local nb, nd = nil, math.huge
            for _, b in next, workspace:GetChildren() do
                if b:IsA('BasePart') and b.Name:lower():find('ball') then
                    local d = (b.Position-myHead.Position).Magnitude
                    if d < nd then nd,nb = d,b end
                end
            end
            if not nb then return end
            local cd, cp = math.huge, nil
            for _, v in next, Players:GetPlayers() do
                local h = v ~= lp and v.Character and v.Character:FindFirstChild('Head')
                if h then local d = (h.Position-nb.Position).Magnitude if d < cd then cd,cp = d,v end end
            end
            targetP = cp
        else
            local cd, cp = math.huge, nil
            for _, v in next, Players:GetPlayers() do
                local h = v ~= lp and v.Character and v.Character:FindFirstChild('Head')
                if h then local d = (h.Position-myHead.Position).Magnitude if d < cd then cd,cp = d,v end end
            end
            targetP = cp
        end

        if not targetP or not targetP.Character then return end
        local tHead = targetP.Character:FindFirstChild('Head')
        local tHum  = targetP.Character:FindFirstChildOfClass('Humanoid')
        if not tHead or not tHum then return end
        local tState = tHum:GetState()
        if tState ~= Enum.HumanoidStateType.Jumping and tState ~= Enum.HumanoidStateType.Freefall then return end
        if (tHead.Position-myHead.Position).Magnitude > O.BoostRadius.Value then return end

        local spd = math.max(hum.WalkSpeed * O.BoostStrength.Value, 1)
        local dur = math.max((hrp.Position-tHead.Position).Magnitude/spd, 0.01)
        cancelTween()
        activeTween = TweenService:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame=CFrame.new(tHead.Position)})
        activeTween:Play()
        activeTween.Completed:Once(function(s)
            if s ~= Enum.PlaybackState.Completed then return end
            local vel = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, O.BoostPower.Value, vel.Z)
        end)
    end)
end)

------------------------------------------------------------------------
-- LOGIC: Visual
------------------------------------------------------------------------
Run('Jump spot', function()
    track(workspace.ChildAdded:Connect(function(v)
        if not T.JumpSpot.Value then return end
        if not v:IsA('BasePart') or v.Name ~= 'Football' then return end
        task.wait()
        local position = v.Position; local velocity = v.AssemblyLinearVelocity
        local gravity  = Vector3.new(0,-28,0); local dt = 1/30
        local positions = {position}
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances = {v}
        rp.IgnoreWater = true
        for _ = 1, 300 do
            local nxt = position + velocity*dt + 0.5*gravity*dt^2
            velocity = velocity + gravity*dt
            if velocity.Y < 0 then
                local result = workspace:Raycast(position, (nxt-position)+Vector3.new(0,-14.4,0), rp)
                if result then positions[#positions+1]=result.Position break end
            end
            positions[#positions+1]=nxt; position=nxt
        end
        local opt = positions[#positions]
        local model = Instance.new('Model', workspace)
        local baseY, underY = opt.Y-1.5, opt.Y-1.5-6
        local function meshPart(id, sz, pos)
            local mp = Instance.new('MeshPart'); mp.MeshId='rbxassetid://'..id
            mp.Material=Enum.Material.Neon; mp.Color=Color3.fromRGB(255,255,255)
            mp.Size=sz; mp.Rotation=Vector3.new(180,0,180); mp.Transparency=1
            mp.Anchored=true; mp.CanCollide=false; mp.Position=pos; mp.Parent=model
            return mp
        end
        local cyl  = meshPart('8091779363', Vector3.new(2,4,2), Vector3.new(opt.X,underY,opt.Z))
        cyl.Material = Enum.Material.Plastic
        for _, face in next, {Enum.NormalId.Front,Enum.NormalId.Back,Enum.NormalId.Left,Enum.NormalId.Right} do
            local d=Instance.new('Decal',cyl); d.Face=face; d.Texture='rbxassetid://8097185954'; d.Color3=Color3.fromRGB(255,255,255)
        end
        local glow = meshPart('8091848285', Vector3.new(3.731,0.031,3.731), Vector3.new(opt.X,underY,opt.Z))
        local bp = Instance.new('Part',model); bp.Size=Vector3.new(0.311,0.311,0.311)
        bp.Transparency=1; bp.Anchored=true; bp.CanCollide=false; bp.Position=Vector3.new(opt.X,underY,opt.Z)
        local pl=Instance.new('PointLight',bp); pl.Color=Color3.fromRGB(255,255,255); pl.Range=12; pl.Brightness=2
        local ti = TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local up = {Position=Vector3.new(opt.X,baseY,opt.Z)}
        local dn = {Position=Vector3.new(opt.X,underY,opt.Z)}
        for _, p in next, {cyl,glow,bp} do TweenService:Create(p,ti,up):Play() end
        task.spawn(function()
            while v and v.Parent and v.AssemblyLinearVelocity.Magnitude > 1 do task.wait() end
            for _, p in next, {cyl,glow,bp} do TweenService:Create(p,ti,dn):Play() end
            task.wait(0.4); if model.Parent then model:Destroy() end
        end)
    end))
end)

Run('Throw spot', function()
    track(workspace.ChildAdded:Connect(function(v)
        if not T.ThrowSpot.Value then return end
        if not v:IsA('BasePart') or v.Name ~= 'Football' then return end
        task.wait()
        local pos = v.Position; local vel = v.AssemblyLinearVelocity
        local gravity = Vector3.new(0,-28,0); local positions, parts = {}, {}
        local lastPos, spawnY = pos, pos.Y
        for t = 0, 8, 0.05 do
            local p = pos + vel*t + 0.5*gravity*t*t
            positions[#positions+1]=p
            if p.Y < spawnY then break end
            local ray = workspace:Raycast(lastPos, p-lastPos)
            if ray then positions[#positions]=ray.Position break end
            lastPos = p
        end
        local endPos = positions[#positions]
        if not endPos then return end
        local marker = Instance.new('Part', workspace.Terrain)
        marker.Anchored=true; marker.CanCollide=false; marker.CastShadow=false
        marker.Size=Vector3.new(3,3,3); marker.Shape=Enum.PartType.Ball
        marker.Color=Color3.fromRGB(0,0,0); marker.Position=endPos
        for i = 1, #positions-1 do
            local p0,p1 = positions[i],positions[i+1]
            local seg = Instance.new('Part', workspace.Terrain)
            seg.Anchored=true; seg.CanCollide=false; seg.CastShadow=false
            seg.Material=Enum.Material.Neon; seg.Color=Color3.fromRGB(255,255,255)
            local d = (p1-p0).Magnitude
            seg.Size=Vector3.new(0.4,0.4,math.max(d,0.05))
            if d > 0.001 then seg.CFrame=CFrame.lookAt((p0+p1)/2, p1) else seg.Position=p0 end
            parts[#parts+1]=seg
        end
        task.spawn(function()
            local dl = math.clamp(300/math.max(vel.Magnitude,1), 0.01, 0.04)
            for _, p in next, parts do task.wait(dl) if p.Parent then p:Destroy() end end
            if marker.Parent then marker:Destroy() end
        end)
    end))
end)

Run('Gloves / trail / stadium', function()
    local gloveDebounce = 0
    loop(nil, function()
        local character = lp.Character
        local uniform = character and character:FindFirstChild('Uniform')
        if not uniform then return end
        local gloveVis
        for _, v in next, uniform:GetDescendants() do
            if v:IsA('BasePart') and v.Name:lower():find('glove') then gloveVis = v.Transparency==0 break end
        end
        if gloveVis == nil then return end
        if T.EnableGloves.Value ~= gloveVis and tick()-gloveDebounce > 0.3 then
            gloveDebounce = tick()
            fireSound('Game','Customization','Toggle','LeftGlove')
            fireSound('Game','Customization','Toggle','RightGlove')
        end
    end)

    track(workspace.ChildAdded:Connect(function(v)
        if not T.NoBallTrail.Value then return end
        if v:IsA('BasePart') and v.Name=='Football' then
            local t = v:FindFirstChildOfClass('Trail')
            if t then t:Destroy() end
        end
    end))

    local stadiumParts = {}
    local models = workspace:FindFirstChild('Models')
    local stadium = models and models:FindFirstChild('Stadium')
    if stadium then
        for _, v in next, stadium:GetDescendants() do
            if v:IsA('BasePart') then stadiumParts[#stadiumParts+1]={Part=v,Transparency=v.Transparency,CanCollide=v.CanCollide} end
        end
    end
    local function setStadium(hidden)
        for _, p in next, stadiumParts do
            if p.Part and p.Part.Parent then
                p.Part.Transparency = hidden and 1 or p.Transparency
                p.Part.CanCollide   = hidden and false or p.CanCollide
            end
        end
    end
    _G.__FF3_67_HideStadium = setStadium
    track({Destroy = function() setStadium(false); _G.__FF3_67_HideStadium = nil end})
end)

Run('Skyboxes', function()
    local function asset(id) return 'rbxassetid://'..tostring(id) end
    local skies = {
        ['Golden Twilight']  = {541743453,541743443,541743446,541743436,541743435,541743441},
        ['Infernal Horizon'] = {169210090,169210108,169210121,169210133,169210143,169210149},
        ['Nebula Peaks']     = {17124357467,17124359797,17124362093,17124365127,17124367200,17124369657},
        ['Rose Glow']        = {109305193,58372722,109305200,109305185,109305189,109305207},
        ['Night Sky']        = {12064107,12064152,12064121,12063984,12064115,12064131},
        ['Northern Lights']  = {16563478983,16563481302,16563484084,16563485362,16563487078,16563489821},
    }
    ApplySkyBox = function(name)
        local ids = skies[name]
        if not ids then return end
        for _, v in next, Lighting:GetChildren() do
            if v:IsA('Sky') or v:IsA('PostEffect') or v:IsA('Atmosphere') then v:Destroy() end
        end
        local sky = Instance.new('Sky')
        sky.Name = name
        sky.SkyboxBk,sky.SkyboxDn,sky.SkyboxFt = asset(ids[1]),asset(ids[2]),asset(ids[3])
        sky.SkyboxLf,sky.SkyboxRt,sky.SkyboxUp = asset(ids[4]),asset(ids[5]),asset(ids[6])
        if name=='Infernal Horizon' then
            sky.StarCount=100; sky.SunTextureId=' '
            local bl=Instance.new('BlurEffect',Lighting); bl.Size=6
            local cc=Instance.new('ColorCorrectionEffect',Lighting)
            cc.Brightness,cc.Contrast,cc.Saturation=0.01,0.15,0.4
            cc.TintColor=Color3.new(0.815686,0.776471,0.690196)
        elseif name=='Nebula Peaks' then
            sky.CelestialBodiesShown=false
            local cc=Instance.new('ColorCorrectionEffect',Lighting)
            cc.Brightness,cc.Contrast,cc.Saturation=0.1,0.3,0.2; cc.TintColor=Color3.fromRGB(140,190,255)
            local bl=Instance.new('BloomEffect',Lighting); bl.Intensity,bl.Threshold,bl.Size=1.2,0.8,56
            local atm=Instance.new('Atmosphere',Lighting)
            atm.Density,atm.Offset,atm.Glare,atm.Haze=0.25,0.2,0.3,1
            atm.Color=Color3.fromRGB(80,110,150); atm.Decay=Color3.fromRGB(25,30,35)
        elseif name=='Night Sky' then
            sky.CelestialBodiesShown=false; sky.StarCount=0
        elseif name ~= 'Golden Twilight' then
            sky.CelestialBodiesShown=false
        end
        sky.Parent = Lighting
    end
end)

------------------------------------------------------------------------
-- LOGIC: Misc
------------------------------------------------------------------------
Run('FPS cap', function()
    loop(0.5, function()
        if not setfpscap then return end
        setfpscap(math.floor(O.FpsCap.Value))
    end)
end)

Run('Anti admin', function()
    loop(nil, function()
        if not T.AntiAdmin.Value then return end
        local pg = lp:FindFirstChild('PlayerGui')
        local mt = pg and pg:FindFirstChild('MiscText')
        local iv = mt and mt:FindFirstChild('IsVIP')
        if iv and iv.Visible then return end
        for _, admin in next, Players:GetPlayers() do
            if admin ~= lp then
                local d  = admin:FindFirstChild('SwagData')
                local at = d and d:FindFirstChild('Admin')
                if at and at.Value ~= '' then
                    lp:Kick('[67 FF3] Detected Admin\nName: '..admin.Name..'\nID: '..admin.UserId)
                    return
                end
            end
        end
    end)
end)

Run('Smooth replay', function()
    if not isPractice then
        task.spawn(function()
            local remote     = RS:WaitForChild('Remotes'):WaitForChild('CharacterSoundEvent')
            local heartbeat  = RunService.Heartbeat
            local playerGui  = lp:WaitForChild('PlayerGui')
            local transition = playerGui:WaitForChild('MainGui'):WaitForChild('Transition')
            local homeCamera = CFrame.Angles(-0.2617993877991494, 0, 0)
            local awayCamera = CFrame.Angles(0.2617993877991494, math.pi, 0)
            local camOffset  = CFrame.new(0, 0, 19)
            local limbs = {'Torso','Left Arm','Right Arm','Left Leg','Right Leg','Head'}

            loop(nil, function()
                local scripts = lp:FindFirstChild('PlayerScripts')
                local rs = scripts and scripts:FindFirstChild('ClientReplay')
                if rs then rs.Enabled = not T.SmoothReplay.Value end
            end)

            local function stepChar(character, frame1, frame2, alpha)
                local cd = data and data.limbs and data.limbs[character.Name]
                if not cd then character.Parent=nil return end
                local ld, ad = cd[1], cd[2]
                if not ld[1] then character.Parent=nil return end
                local t1d, t2d = ld[1][2][frame1], ld[1][2][frame2]
                if not t1d or not t2d then character.Parent=nil return end
                local torso = t1d:Lerp(t2d, alpha)
                for i, lname in next, limbs do
                    local limb, rl = character:FindFirstChild(lname), ld[i]
                    if limb and rl then
                        local cf1, cf2 = rl[2][frame1], rl[2][frame2]
                        if i==4 then
                            if cf1 and cf2 then local a=cf1+((cf2-cf1)*alpha); limb.CFrame=torso*CFrame.new(-0.5,-1,0)*CFrame.fromOrientation(a,0,0)*CFrame.new(0,-1,0) end
                        elseif i==5 then
                            if cf1 and cf2 then local a=cf1+((cf2-cf1)*alpha); limb.CFrame=torso*CFrame.new(0.5,-1,0)*CFrame.fromOrientation(a,0,0)*CFrame.new(0,-1,0) end
                        else
                            if cf1 and cf2 then limb.CFrame=cf1:Lerp(cf2,alpha)
                            elseif i==6 then limb.CFrame=torso*CFrame.new(0,1.5,0) end
                        end
                    end
                end
                local uniform = character:FindFirstChild('Uniform')
                if ad and uniform then
                    for name, info in next, ad do
                        if uniform:FindFirstChild(name) and character:FindFirstChild(info[1]) then
                            uniform[name].CFrame = character[info[1]].CFrame * info[2]
                        end
                    end
                end
            end

            local data
            local function replay(rdata, characters)
                data = rdata
                local replayBall = workspace:WaitForChild('ReplayBall')
                local camera     = workspace.CurrentCamera
                camera.CameraType = Enum.CameraType.Scriptable
                local camRot  = data.changes[1].poss=='h' and homeCamera or awayCamera
                local curChange, highestY, camTilt = 1, 18, true
                local playback, recFPS = 1, data.fps
                local accum, last = 0, tick()
                local function gf(i) return math.clamp(i,1,#data.ball) end

                while playback < #data.ball do
                    if RS.Flags.StatusTag.Value ~= 'REPLAY' then break end
                    if camera.CameraType ~= Enum.CameraType.Scriptable then break end
                    local fps = O.ReplayFPS.Value
                    local rdelta = 1/fps
                    local now = tick(); accum = accum + (now-last); last = now
                    while accum >= rdelta do playback = playback + recFPS/fps; accum = accum-rdelta end
                    local f1 = gf(math.floor(playback)); local f2 = gf(math.ceil(playback)); local alpha = playback-f1
                    for _, ch in next, characters do stepChar(ch, f1, f2, alpha) end
                    local b1,b2 = data.ball[f1], data.ball[f2]
                    if b1 and b2 then replayBall.CFrame = b1:Lerp(b2, alpha) end
                    if highestY < replayBall.Position.Y then highestY = replayBall.Position.Y
                    elseif highestY > 49 and camTilt then
                        local x = select(1, camRot:ToOrientation())
                        camRot = camRot * CFrame.Angles(x*3*math.clamp((highestY-50)/99,0,1),0,0)
                        camTilt = false
                    end
                    local targetCam
                    if highestY > 49 and camTilt then
                        local x = select(1, camRot:ToOrientation())
                        targetCam = CFrame.new(replayBall.Position)*camRot*CFrame.Angles(x*3*math.clamp((highestY-50)/99,0,1),0,0)*camOffset
                    else targetCam = CFrame.new(replayBall.Position)*camRot*camOffset end
                    camera.CFrame = targetCam
                    local change = data.changes[curChange]
                    if change and change.frame <= f1 then
                        curChange = curChange + 1
                        if change.frame == f1 then
                            if change.poss and (f1 > 9 and (change.turnover or highestY > 49)) then
                                local nextRot = change.poss=='h' and homeCamera or awayCamera
                                local dur = (change.turnover or replayBall.Position.Y >= 13) and 0.5 or highestY/500
                                local elaps, startRot = 0, camRot
                                while elaps < dur do
                                    elaps = elaps + heartbeat:Wait()
                                    camRot = startRot:Lerp(nextRot, math.clamp(elaps/dur,0,1))
                                    camera.CFrame = CFrame.new(replayBall.Position)*camRot*camOffset
                                end
                                camRot = nextRot
                            elseif change.freeze then task.wait(change.freeze) end
                        end
                    end
                    heartbeat:Wait()
                end
                remote:FireServer('ReplayFinished')
                if RS.Flags.StatusTag.Value == 'REPLAY' then RS.Flags.StatusTag.Value = '' end
                task.wait(0.2); replayBall:Destroy()
                for _, ch in next, characters do ch:Destroy() end
                data.t,data.limbs,data.ball = nil,nil,nil
                camera.CameraType = Enum.CameraType.Custom
                if lp.Character and lp.Character:FindFirstChild('Humanoid') then
                    camera.CameraSubject = lp.Character.Humanoid
                end
                data = nil
            end

            track(remote.OnClientEvent:Connect(function(action, ...)
                if action == 'ClientReplay' then
                    while transition.Position.X.Scale > -2 and transition.Position.X.Scale < -0.5 do task.wait() end
                    replay(...)
                end
            end))
        end)
    end
end)

------------------------------------------------------------------------
-- UI Settings
------------------------------------------------------------------------
Run('UI Settings', function()
    local Menu = Tabs.Settings:AddLeftGroupbox('Menu')

    btn(Menu, 'Copy Discord Invite', 'Copies discord.gg/67scripts to clipboard.', function()
        if setclipboard then setclipboard('discord.gg/67scripts'); Library:Notify('Copied discord.gg/67scripts', 3)
        else Library:Notify('discord.gg/67scripts', 6) end
    end)
    btn(Menu, 'Unload', 'Closes the UI.', function() Library:Unload() end)

    Menu:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {Default='End', NoUI=true, Text='Menu keybind'})
    Library.ToggleKeybind = O.MenuKeybind
    Library:SetWatermarkVisibility(true)
    Library:SetWatermark('67 FF3 v2 | discord.gg/67scripts')

    if ThemeManager and SaveManager then
        ThemeManager:SetLibrary(Library)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({'MenuKeybind'})
        ThemeManager:SetFolder('67Scripts')
        SaveManager:SetFolder('67Scripts/FF3')
        SaveManager:BuildConfigSection(Tabs.Settings)
        ThemeManager:ApplyToTab(Tabs.Settings)
        pcall(function() SaveManager:LoadAutoloadConfig() end)
    end
end)

------------------------------------------------------------------------
-- Unload
------------------------------------------------------------------------
Library:OnUnload(function()
    Alive = false
    for _, obj in ipairs(Janitor) do
        pcall(function()
            if typeof(obj) == 'RBXScriptConnection' then obj:Disconnect()
            elseif typeof(obj) == 'Instance' then obj:Destroy()
            elseif type(obj) == 'table' and obj.Destroy then obj.Destroy() end
        end)
    end
    if getgenv then getgenv().FF3_67_Unload = nil end
end)

if getgenv then
    getgenv().FF3_67_Unload = function() Library:Unload() end
end

Library:Notify('67 FF3 v2 loaded | discord.gg/67scripts', 5)
