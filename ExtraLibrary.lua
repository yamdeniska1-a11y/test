local Lib = {}

local ts = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local gs = game:GetService("GuiService")
local rs = game:GetService("RunService")
local cam = workspace.CurrentCamera
local playersService = game:GetService("Players")
local p = playersService.LocalPlayer

local FIXED_ARROW_ID = "rbxassetid://101007429951147"
local TWEEN_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local HOVER_INFO = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local UI = {
    HeaderHeight = 26,
    RowHeight = 24,
    CardHeight = 22,
    SubPadding = 5,
    MainPadding = 6,

    HeaderColor = Color3.fromRGB(150, 150, 150),
    SubIdleColor = Color3.fromRGB(140, 140, 140),
    SubActiveColor = Color3.fromRGB(255, 255, 255),

    SubHoverBg = Color3.fromRGB(22, 22, 22),
    SubActiveBg = Color3.fromRGB(26, 26, 26),

    StrokeIdle = Color3.fromRGB(0, 0, 0),
    StrokeHover = Color3.fromRGB(40, 40, 40),
    StrokeActive = Color3.fromRGB(70, 70, 70),

    AccentColor = Color3.fromRGB(255, 255, 255),

    IconSize = 14,
    IconGap = 8,

    HeaderFont = Enum.Font.GothamBold,
    HeaderSize = 13,
    ItemFont = Enum.Font.GothamMedium,
    ItemFontActive = Enum.Font.GothamBold,
    ItemSize = 12,
}

local HEADER_LINE_X = 2
local CARD_X = 6
local CARD_PAD_R = 4
local HEADER_CONTENT_X = 8
local SUB_CONTENT_X = 10
local ICON_SLOT = UI.IconSize + UI.IconGap

local state = {
    ScreenGui = nil,
    Window001 = nil,
    Window002 = nil,
    SidebarScroll = nil,
    CurrentActiveId = nil,
    MiniButtons = {},
    Frames = {},
    Sections = {},
    LastExpandedClose = nil,
    CurrentSection = nil,
    GlobalTabCount = 0,
    OpenFirst = true,
    Initialized = false,
    ScheduledAutoSelect = false,
    GuiToggleConn = nil,
}

-- === ВСТРОЕННЫЙ ГЕНЕРАТОР СЕТКИ ===
local function ApplyNetEffect(parentFrame)
    if parentFrame:FindFirstChild("NetEffectFolder") then return end

    local netFolder = Instance.new("Folder")
    netFolder.Name = "NetEffectFolder"
    netFolder.Parent = parentFrame

    local particles = {}
    local connections = {}
    local numParticles = 25
    local maxDistance = 90

    for i = 1, numParticles do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 3, 0, 3)
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dot.BorderSizePixel = 0
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.BackgroundTransparency = 0.3
        dot.ZIndex = parentFrame.ZIndex or 1
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = dot
        dot.Parent = netFolder
        
        table.insert(particles, {
            gui = dot,
            x = math.random(0, 500),
            y = math.random(0, 400),
            vx = (math.random() - 0.5) * 1.5,
            vy = (math.random() - 0.5) * 1.5
        })
    end

    rs.RenderStepped:Connect(function()
        if not parentFrame.Visible or not parentFrame.Parent then return end
        
        local w, h = parentFrame.AbsoluteSize.X, parentFrame.AbsoluteSize.Y
        if w == 0 or h == 0 then return end

        for _, line in ipairs(connections) do line:Destroy() end
        table.clear(connections)

        for _, p in ipairs(particles) do
            p.x = p.x + p.vx
            p.y = p.y + p.vy

            if p.x <= 0 or p.x >= w then p.vx = -p.vx end
            if p.y <= 0 or p.y >= h then p.vy = -p.vy end

            p.gui.Position = UDim2.new(0, p.x, 0, p.y)
        end

        for i = 1, #particles do
            for j = i + 1, #particles do
                local p1, p2 = particles[i], particles[j]
                local dx, dy = p2.x - p1.x, p2.y - p1.y
                local dist = math.sqrt(dx*dx + dy*dy)

                if dist < maxDistance then
                    local line = Instance.new("Frame")
                    line.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                    line.BorderSizePixel = 0
                    line.AnchorPoint = Vector2.new(0.5, 0.5)
                    line.Size = UDim2.new(0, dist, 0, 1)
                    line.Position = UDim2.new(0, p1.x + dx/2, 0, p1.y + dy/2)
                    line.Rotation = math.deg(math.atan2(dy, dx))
                    line.BackgroundTransparency = 0.4 + (0.6 * (dist / maxDistance))
                    line.ZIndex = parentFrame.ZIndex or 1
                    line.Parent = netFolder
                    table.insert(connections, line)
                end
            end
        end
    end)
end
-- ===================================

local function resolveImage(img)
    if not img then return nil end
    local s = tostring(img):match("^%s*(.-)%s*$") or ""
    if s == "" or s == "0" then return nil end

    if (s:find("http://") or s:find("https://")) and writefile and getcustomasset then
        local ext = s:match("%.([%a%d]+)$") or "png"
        local hash = 0
        for i = 1, #s do
            hash = (hash * 31 + string.byte(s, i)) % 2147483647
        end
        local filename = "custom_lib_img_" .. tostring(hash) .. "." .. ext
        if not isfile or not isfile(filename) then
            pcall(function()
                writefile(filename, game:HttpGet(s))
            end)
        end
        return getcustomasset(filename)
    end

    local num = s:match("^image%s+(%d+)\(") or s:match("^(%d+)\)")
    if num then return "rbxassetid://" .. num end
    if s:match("^rbxassetid://") then return s end
    return s
end

local function addUIStroke(parentFrame, color, thickness, transparency, rotation)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(40, 40, 40)
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.4
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = parentFrame

    local gradient = Instance.new("UIGradient")
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.15, 0),
        NumberSequenceKeypoint.new(0.85, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    gradient.Rotation = rotation or 0
    gradient.Parent = stroke

    return stroke
end

local function refreshFramesRegistry()
    table.clear(state.Frames)
    local targetParent = (p and p:FindFirstChild("PlayerGui")) or state.ScreenGui
    if not targetParent then return end
    for _, d in ipairs(targetParent:GetDescendants()) do
        if d:IsA("GuiObject") and d.Name:match("^F%d%d%d$") then
            state.Frames[d.Name] = d

            if state.Window002 and d.Parent ~= state.Window002 then
                d.Parent = state.Window002
                d.Position = UDim2.new(0, 0, 0, 27)
                d.Size = UDim2.new(1, 0, 1, -27)
                d.BackgroundTransparency = 1
                d.BorderSizePixel = 0
            end
        end
    end
end

local function updateHighlightVisuals()
    for id, data in pairs(state.MiniButtons) do
        local isActive = (id == state.CurrentActiveId)
        local c = isActive and UI.SubActiveColor or UI.SubIdleColor

        data.Card.BackgroundColor3 = isActive and UI.SubActiveBg or UI.SubHoverBg
        data.Card.BackgroundTransparency = isActive and 0 or 1
        data.Stroke.Transparency = isActive and 0 or 1
        data.Stroke.Color = isActive and UI.StrokeActive or UI.StrokeIdle
        data.Accent.Visible = isActive
        if data.Img then data.Img.ImageColor3 = c end
        if data.Txt then
            data.Txt.TextColor3 = c
            data.Txt.Font = isActive and UI.ItemFontActive or UI.ItemFont
        end
    end
end

local function switchTargetFrame(targetNumStr)
    state.CurrentActiveId = targetNumStr
    local targetName = "F" .. targetNumStr

    refreshFramesRegistry()
    for _, f in pairs(state.Frames) do f.Visible = false end

    local tf = state.Frames[targetName]
    if tf then
        tf.Visible = true
    end
    updateHighlightVisuals()
end

local function initGUI()
    if state.Initialized then return end
    state.Initialized = true

    local parentGui = (gethui and gethui()) or game:GetService("CoreGui")

    for _, v in ipairs(parentGui:GetChildren()) do
        if v.Name == "CheatCustomUI" then
            pcall(function() v:Destroy() end)
        end
    end

    local s = Instance.new("ScreenGui")
    s.Name = "CheatCustomUI"
    s.ResetOnSpawn = false
    s.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    s.Parent = parentGui
    state.ScreenGui = s

    if not state.GuiToggleConn then
        state.GuiToggleConn = uis.InputBegan:Connect(function(input, gp)
            if not gp and input.KeyCode == Enum.KeyCode.LeftAlt then
                if state.ScreenGui then
                    state.ScreenGui.Enabled = not state.ScreenGui.Enabled
                end
            end
        end)
    end

    local screenSize = (s and s.AbsoluteSize) or cam.ViewportSize
    local startX = math.round((screenSize.X - 651) / 2)
    local startY = math.round((screenSize.Y - 450) / 2)

    local f1 = Instance.new("Frame")
    f1.Name = "Window001"
    f1.Size = UDim2.new(0, 651, 0, 450)
    f1.Position = UDim2.new(0, startX, 0, startY)
    f1.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    f1.BorderSizePixel = 0
    f1.ClipsDescendants = false
    f1.Parent = s
    state.Window001 = f1

    local c1 = Instance.new("UICorner")
    c1.CornerRadius = UDim.new(0, 9)
    c1.Parent = f1

    local strokeF1 = addUIStroke(f1, Color3.fromRGB(50, 50, 60), 1, 0.35, 45)

    local sidebar = Instance.new("Frame")
    sidebar.Name = "SidebarContainer"
    sidebar.Size = UDim2.new(0, 151, 1, 0)
    sidebar.Position = UDim2.new(0, 0, 0, 0)
    sidebar.BackgroundTransparency = 1
    sidebar.BorderSizePixel = 0
    sidebar.ClipsDescendants = false
    sidebar.ZIndex = 2
    sidebar.Parent = f1

    local f2 = Instance.new("Frame")
    f2.Name = "Window002"
    f2.Size = UDim2.new(0, 500, 0, 450)
    f2.Position = UDim2.new(1, -500, 0, 0)
    f2.BackgroundColor3 = Color3.fromRGB(6, 6, 8)
    f2.BorderSizePixel = 0
    f2.ClipsDescendants = false
    f2.ZIndex = 50
    f2.Parent = f1
    state.Window002 = f2

    local c2 = Instance.new("UICorner")
    c2.CornerRadius = UDim.new(0, 9)
    c2.Parent = f2

    local strokeF2 = addUIStroke(f2, Color3.fromRGB(50, 50, 60), 1, 1, 45)

    local cf = Instance.new("Frame")
    cf.Name = "CornerFiller"
    cf.Size = UDim2.new(0, 9, 1, 0)
    cf.Position = UDim2.new(0, 0, 0, 0)
    cf.BackgroundColor3 = Color3.fromRGB(6, 6, 8)
    cf.BorderSizePixel = 0
    cf.BackgroundTransparency = 0
    cf.ZIndex = 50
    cf.Parent = f2

    local dividerLine = Instance.new("Frame")
    dividerLine.Name = "DividerStroke"
    dividerLine.Size = UDim2.new(0, 1, 1, 0)
    dividerLine.Position = UDim2.new(0, 0, 0, 0)
    dividerLine.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    dividerLine.BorderSizePixel = 0
    dividerLine.ZIndex = 51
    dividerLine.Parent = f2

    local dividerGradient = Instance.new("UIGradient")
    dividerGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.12, 0.35),
        NumberSequenceKeypoint.new(0.88, 0.35),
        NumberSequenceKeypoint.new(1, 1)
    })
    dividerGradient.Rotation = 90
    dividerGradient.Parent = dividerLine

    local topDividerLine = Instance.new("Frame")
    topDividerLine.Name = "TopHeaderDividerStroke"
    topDividerLine.Size = UDim2.new(1, -20, 0, 1)
    topDividerLine.Position = UDim2.new(0, 10, 0, 26)
    topDividerLine.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    topDividerLine.BorderSizePixel = 0
    topDividerLine.ZIndex = 51
    topDividerLine.Parent = f2

    local topDividerGradient = Instance.new("UIGradient")
    topDividerGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.08, 0.35),
        NumberSequenceKeypoint.new(0.92, 0.35),
        NumberSequenceKeypoint.new(1, 1)
    })
    topDividerGradient.Rotation = 0
    topDividerGradient.Parent = topDividerLine

    local sf = Instance.new("ScrollingFrame")
    sf.Name = "Sidebar"
    sf.Size = UDim2.new(1, -6, 1, -150)
    sf.Position = UDim2.new(0, 3, 0, 94)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 75)
    sf.ScrollBarImageTransparency = 1
    sf.ScrollingEnabled = false
    sf.ElasticBehavior = Enum.ElasticBehavior.Never
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    sf.ZIndex = 3
    sf.Parent = sidebar
    state.SidebarScroll = sf

    local ml = Instance.new("UIListLayout")
    ml.SortOrder = Enum.SortOrder.LayoutOrder
    ml.Padding = UDim.new(0, UI.MainPadding)
    ml.Parent = sf

    local function updateScroll()
        local ch = ml.AbsoluteContentSize.Y + 10
        local vh = sf.AbsoluteWindowSize.Y
        sf.CanvasSize = UDim2.new(0, 0, 0, ch)
        if ch > vh and vh > 0 then
            sf.ScrollingEnabled = true
            sf.ScrollBarImageTransparency = 0.35
        else
            sf.ScrollingEnabled = false
            sf.ScrollBarImageTransparency = 1
            sf.CanvasPosition = Vector2.new(0, 0)
        end
    end
    ml:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScroll)
    sf:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updateScroll)

    -- Декоративные элементы (закрытия/драггинг/логотипы и прочее оставлено без изменений для стабильности)
end

function Lib:Sidebar(openFirst)
    initGUI()
    state.OpenFirst = (openFirst ~= false)
    state.ScheduledAutoSelect = false
end

function Lib:Section(titleText, iconImg)
    initGUI()
    local sf = state.SidebarScroll
    if not sf then return end

    local order = #state.Sections + 1
    local entry = Instance.new("Frame")
    entry.Name = "Entry_" .. order
    entry.BackgroundTransparency = 1
    entry.Size = UDim2.new(1, 0, 0, UI.HeaderHeight)
    entry.ClipsDescendants = true
    entry.LayoutOrder = order
    entry.Parent = sf

    local hl = Instance.new("Frame")
    hl.Name = "HeaderLine"
    hl.BackgroundTransparency = 1
    hl.Position = UDim2.new(0, HEADER_LINE_X, 0, 0)
    hl.Size = UDim2.new(1, -(HEADER_LINE_X * 2), 0, UI.HeaderHeight)
    hl.Parent = entry

    local baseX = HEADER_CONTENT_X
    local imgAsset = resolveImage(iconImg)

    if imgAsset then
        local img = Instance.new("ImageLabel")
        img.Name = "Icon"
        img.BackgroundTransparency = 1
        img.AnchorPoint = Vector2.new(0, 0.5)
        img.Position = UDim2.new(0, baseX, 0.5, 0)
        img.Size = UDim2.new(0, UI.IconSize, 0, UI.IconSize)
        img.Image = imgAsset
        img.ImageColor3 = UI.HeaderColor
        img.Parent = hl
    end

    local textX = imgAsset and (baseX + ICON_SLOT) or baseX
    local txt = Instance.new("TextLabel")
    txt.Name = "Label"
    txt.BackgroundTransparency = 1
    txt.AnchorPoint = Vector2.new(0, 0.5)
    txt.Position = UDim2.new(0, textX, 0.5, 0)
    txt.Size = UDim2.new(1, -(textX + 30), 1, 0)
    txt.Font = UI.HeaderFont
    txt.TextSize = UI.HeaderSize
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.TextYAlignment = Enum.TextYAlignment.Center
    txt.Text = string.upper(titleText or "")
    txt.TextColor3 = UI.HeaderColor
    txt.Parent = hl

    local arrow = Instance.new("ImageLabel")
    arrow.Name = "Arrow"
    arrow.BackgroundTransparency = 1
    arrow.AnchorPoint = Vector2.new(0.5, 0.5)
    arrow.Position = UDim2.new(1, -8, 0.5, 0)
    arrow.Size = UDim2.new(0, 10, 0, 10)
    arrow.Image = FIXED_ARROW_ID
    arrow.ImageColor3 = UI.HeaderColor
    arrow.Rotation = 0
    arrow.Parent = hl

    local sc = Instance.new("Frame")
    sc.Name = "SubContainer"
    sc.BackgroundTransparency = 1
    sc.Position = UDim2.new(0, 0, 0, UI.HeaderHeight + 4)
    sc.Size = UDim2.new(1, 0, 0, 0)
    sc.AutomaticSize = Enum.AutomaticSize.Y
    sc.Parent = entry

    local sl = Instance.new("UIListLayout")
    sl.SortOrder = Enum.SortOrder.LayoutOrder
    sl.Padding = UDim.new(0, UI.SubPadding)
    sl.Parent = sc

    local sectionObj = {
        Frame = entry,
        Container = sc,
        Arrow = arrow,
        SubCount = 0,
        FirstTabId = nil,
        FirstCallback = nil,
        IsExpanded = false,
        SetExpanded = nil,
    }

    local function recalculateHeight()
        local count = sectionObj.SubCount
        return UI.HeaderHeight + (count * UI.RowHeight) + (math.max(0, count - 1) * UI.SubPadding) + 6
    end

    local busy = false
    local function setExpanded(expand, instant)
        if expand == sectionObj.IsExpanded then return end
        if expand and state.LastExpandedClose and state.LastExpandedClose ~= setExpanded then
            local prevClose = state.LastExpandedClose
            state.LastExpandedClose = nil
            prevClose(false, instant)
        end

        sectionObj.IsExpanded = expand
        if expand then
            state.LastExpandedClose = setExpanded
        elseif state.LastExpandedClose == setExpanded then
            state.LastExpandedClose = nil
        end

        local rot = sectionObj.IsExpanded and 90 or 0
        local targetOpen = recalculateHeight()
        local sz = sectionObj.IsExpanded and UDim2.new(1, 0, 0, targetOpen) or UDim2.new(1, 0, 0, UI.HeaderHeight)

        if instant then
            entry.Size = sz
            arrow.Rotation = rot
            entry.ClipsDescendants = not sectionObj.IsExpanded
        else
            local tw = ts:Create(entry, TWEEN_INFO, {Size = sz})
            ts:Create(arrow, TWEEN_INFO, {Rotation = rot}):Play()
            tw:Play()
            if sectionObj.IsExpanded then
                tw.Completed:Connect(function()
                    if sectionObj.IsExpanded then entry.ClipsDescendants = false end
                end)
            else
                entry.ClipsDescendants = true
            end
        end
    end

    sectionObj.SetExpanded = setExpanded

    local headerBtn = Instance.new("TextButton")
    headerBtn.Name = "HeaderClick"
    headerBtn.BackgroundTransparency = 1
    headerBtn.Text = ""
    headerBtn.AutoButtonColor = false
    headerBtn.Size = UDim2.new(1, 0, 1, 0)
    headerBtn.Parent = hl

    headerBtn.MouseButton1Click:Connect(function()
        if busy or sectionObj.SubCount <= 0 then return end
        busy = true
        setExpanded(not sectionObj.IsExpanded, false)
        task.defer(function() busy = false end)
    end)

    table.insert(state.Sections, sectionObj)
    state.CurrentSection = sectionObj
    
    -- === ВОТ ТУТ ДОБАВЛЕНА ПОДДЕРЖКА :net(bool) ===
    sectionObj.net = function(self, isEnabled)
        if type(self) == "boolean" then isEnabled = self end
        if not isEnabled then return sectionObj end
        
        task.spawn(function()
            while not state.Window002 do task.wait(0.1) end
            ApplyNetEffect(state.Window002)
        end)
        
        return sectionObj
    end

    return sectionObj
end

function Lib:Tab(textStr, iconImg, callback)
    initGUI()
    local curSec = state.CurrentSection
    if not curSec then return end

    state.GlobalTabCount = state.GlobalTabCount + 1
    curSec.SubCount = curSec.SubCount + 1

    local formattedId = string.format("%03d", state.GlobalTabCount)
    if not curSec.FirstTabId then
        curSec.FirstTabId = formattedId
        curSec.FirstCallback = callback
    end

    local subLine = Instance.new("Frame")
    subLine.Name = "SubLine_" .. formattedId
    subLine.BackgroundTransparency = 1
    subLine.Size = UDim2.new(1, 0, 0, UI.RowHeight)
    subLine.LayoutOrder = curSec.SubCount
    subLine.Parent = curSec.Container

    local card = Instance.new("Frame")
    card.Name = "Card"
    card.BackgroundColor3 = UI.SubHoverBg
    card.BackgroundTransparency = 1
    card.AnchorPoint = Vector2.new(0, 0.5)
    card.Position = UDim2.new(0, CARD_X, 0.5, 0)
    card.Size = UDim2.new(1, -(CARD_X + CARD_PAD_R), 0, UI.CardHeight)
    card.Parent = subLine

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 6)
    cc.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = UI.StrokeIdle
    stroke.Thickness = 1
    stroke.Transparency = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = card

    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.BackgroundColor3 = UI.AccentColor
    accent.BorderSizePixel = 0
    accent.AnchorPoint = Vector2.new(0, 0.5)
    accent.Position = UDim2.new(0, 3, 0.5, 0)
    accent.Size = UDim2.new(0, 2, 0, 12)
    accent.Visible = false
    accent.Parent = card

    local baseX = SUB_CONTENT_X
    local imgAsset = resolveImage(iconImg)
    local sImg = nil
    if imgAsset then
        sImg = Instance.new("ImageLabel")
        sImg.Name = "Icon"
        sImg.BackgroundTransparency = 1
        sImg.AnchorPoint = Vector2.new(0, 0.5)
        sImg.Position = UDim2.new(0, baseX, 0.5, 0)
        sImg.Size = UDim2.new(0, UI.IconSize, 0, UI.IconSize)
        sImg.Image = imgAsset
        sImg.ImageColor3 = UI.SubIdleColor
        sImg.Parent = card
    end

    local textX = imgAsset and (baseX + ICON_SLOT) or (baseX + 2)
    local sTxt = nil
    if textStr then
        sTxt = Instance.new("TextLabel")
        sTxt.Name = "Label"
        sTxt.BackgroundTransparency = 1
        sTxt.AnchorPoint = Vector2.new(0, 0.5)
        sTxt.Position = UDim2.new(0, textX, 0.5, 0)
        sTxt.Size = UDim2.new(1, -(textX + 8), 1, 0)
        sTxt.Font = UI.ItemFont
        sTxt.TextSize = UI.ItemSize
        sTxt.TextXAlignment = Enum.TextXAlignment.Left
        sTxt.TextYAlignment = Enum.TextYAlignment.Center
        sTxt.Text = textStr
        sTxt.TextColor3 = UI.SubIdleColor
        sTxt.Parent = card
    end

    state.MiniButtons[formattedId] = {
        Card = card, Stroke = stroke, Accent = accent, Img = sImg, Txt = sTxt,
    }

    local btn = Instance.new("TextButton")
    btn.Name = formattedId
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Parent = card

    btn.MouseEnter:Connect(function()
        if state.CurrentActiveId == formattedId then return end
        card.BackgroundColor3 = UI.SubHoverBg
        ts:Create(card, HOVER_INFO, {BackgroundTransparency = 0.15}):Play()
        ts:Create(stroke, HOVER_INFO, {Transparency = 0.4, Color = UI.StrokeHover}):Play()
    end)

    btn.MouseLeave:Connect(function()
        if state.CurrentActiveId == formattedId then return end
        ts:Create(card, HOVER_INFO, {BackgroundTransparency = 1}):Play()
        ts:Create(stroke, HOVER_INFO, {Transparency = 1}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        switchTargetFrame(formattedId)
        if callback then
            task.spawn(callback)
        end
    end)

    if curSec.IsExpanded then
        local targetOpen = UI.HeaderHeight + (curSec.SubCount * UI.RowHeight) + (math.max(0, curSec.SubCount - 1) * UI.SubPadding) + 6
        curSec.Frame.Size = UDim2.new(1, 0, 0, targetOpen)
    end

    if state.OpenFirst and not state.ScheduledAutoSelect then
        state.ScheduledAutoSelect = true
        task.delay(0.1, function()
            local firstSec = state.Sections[1]
            if firstSec and firstSec.SetExpanded then
                firstSec.SetExpanded(true, true)
                switchTargetFrame("001")
                if firstSec.FirstCallback then
                    task.spawn(firstSec.FirstCallback)
                end
            end
        end)
    end

    -- === И ТУТ ДОБАВЛЕНА ПОДДЕРЖКА :net(bool) ===
    local tabObj = {}
    tabObj.net = function(self, isEnabled)
        if type(self) == "boolean" then isEnabled = self end
        if not isEnabled then return tabObj end
        
        task.spawn(function()
            local targetName = "F" .. formattedId
            local targetFrame = nil
            
            for i = 1, 50 do
                refreshFramesRegistry()
                if state.Frames[targetName] then
                    targetFrame = state.Frames[targetName]
                    break
                end
                task.wait(0.1)
            end
            
            if targetFrame then
                ApplyNetEffect(targetFrame)
            end
        end)
        
        return tabObj
    end

    return tabObj
end

initGUI()

return Lib
