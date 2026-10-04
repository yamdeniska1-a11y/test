local Lib = {}

local ts = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local gs = game:GetService("GuiService")
local cam = workspace.CurrentCamera
local playersService = game:GetService("Players")
local p = playersService.LocalPlayer

local FIXED_ARROW_ID = "rbxassetid://101007429951147"
local CHECK_ICON_ID = "rbxassetid://6031091004"
local CHEVRON_ID = "rbxassetid://10709791039"
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
    SectionBottomPad = 6,

    GroupBg = Color3.fromRGB(22, 22, 24),
    GroupStroke = Color3.fromRGB(42, 42, 46),
    GroupHeaderColor = Color3.fromRGB(235, 235, 240),
    GroupDivider = Color3.fromRGB(52, 52, 57),
    RowLabelColor = Color3.fromRGB(220, 220, 225),
    RowValueColor = Color3.fromRGB(240, 240, 245),
    ControlBg = Color3.fromRGB(30, 30, 34),
    ControlBorder = Color3.fromRGB(70, 70, 78),
    ControlActiveBg = Color3.fromRGB(240, 240, 245),
    TrackBg = Color3.fromRGB(45, 45, 50),

    HeaderFont = Enum.Font.GothamBold,
    HeaderSize = 13,
    ItemFont = Enum.Font.GothamMedium,
    ItemFontActive = Enum.Font.GothamBold,
    ItemSize = 12,
    RowFont = Enum.Font.GothamMedium,
    RowFontBold = Enum.Font.GothamBold,
    RowSize = 12,
}

local HEADER_LINE_X = 2
local CARD_X = 6
local CARD_PAD_R = 4
local HEADER_CONTENT_X = 8
local SUB_CONTENT_X = 10
local ICON_SLOT = UI.IconSize + UI.IconGap

local PAD_SIDES = 10
local PAD_TOP = 8
local PAD_BOTTOM = 8

local state = {
    ScreenGui = nil,
    Window001 = nil,
    Window002 = nil,
    SidebarScroll = nil,
    CurrentActiveId = nil,
    MiniButtons = {},
    Frames = {},
    Sections = {},
    CurrentSectionTabIds = {},
    LastExpandedClose = nil,
    CurrentSection = nil,
    GlobalTabCount = 0,
    OpenFirst = true,
    Initialized = false,
    ScheduledAutoSelect = false,
    GuiToggleConn = nil,
    CurrentTabFrame = nil,
    CurrentGroup = nil,
    IsGrid = false,
    TabCallbacksRan = {},
}

local env = getgenv and getgenv() or _G
env.net = function(isEnabled)
    state.IsGrid = isEnabled
end

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
    if state.CurrentActiveId == targetNumStr then return end
    state.CurrentActiveId = targetNumStr
    local targetName = "F" .. targetNumStr

    for _, f in pairs(state.Frames) do
        if f.Visible then f.Visible = false end
    end

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

    local logo = Instance.new("Frame")
    logo.Name = "Logo"
    logo.Size = UDim2.new(0, 135, 0, 70)
    logo.Position = UDim2.new(0, 8, 0, 10)
    logo.BackgroundTransparency = 1
    logo.BorderSizePixel = 0
    logo.ZIndex = 2
    logo.Parent = sidebar

    local logoDivider = Instance.new("Frame")
    logoDivider.Name = "LogoDividerStroke"
    logoDivider.Size = UDim2.new(0, 125, 0, 1)
    logoDivider.Position = UDim2.new(0, 13, 0, 88)
    logoDivider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    logoDivider.BorderSizePixel = 0
    logoDivider.ZIndex = 2
    logoDivider.Parent = sidebar

    local logoDivGradient = Instance.new("UIGradient")
    logoDivGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.15, 0.4),
        NumberSequenceKeypoint.new(0.85, 0.4),
        NumberSequenceKeypoint.new(1, 1)
    })
    logoDivGradient.Rotation = 0
    logoDivGradient.Parent = logoDivider

    local shadowRoot = Instance.new("Frame")
    shadowRoot.Name = "E_ShadowRoot"
    shadowRoot.BackgroundTransparency = 1
    shadowRoot.Size = UDim2.new(0, 70, 0, 70)
    shadowRoot.Position = UDim2.new(0.5, -34, 0.5, -33)
    shadowRoot.ZIndex = 2
    shadowRoot.Parent = logo

    local root = Instance.new("Frame")
    root.Name = "E_Root"
    root.BackgroundTransparency = 1
    root.Size = UDim2.new(0, 70, 0, 70)
    root.Position = UDim2.new(0.5, -35, 0.5, -35)
    root.ZIndex = 3
    root.Parent = logo

    local function buildLogoE(parentContainer, boxColor, triColor, zIdx)
        local function makeBox(name, x, y, w, h)
            local f = Instance.new("Frame")
            f.Name = name
            f.BackgroundColor3 = boxColor
            f.BorderSizePixel = 0
            f.Position = UDim2.new(0, x, 0, y)
            f.Size = UDim2.new(0, w, 0, h)
            f.ZIndex = zIdx
            f.Parent = parentContainer
            return f
        end

        local function makeTriangle(name, x, y, size, rotation)
            local tri = Instance.new("ImageLabel")
            tri.Name = name
            tri.BackgroundTransparency = 1
            tri.BorderSizePixel = 0
            tri.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
            tri.ImageColor3 = triColor
            tri.Position = UDim2.new(0, x, 0, y)
            tri.Size = UDim2.new(0, size, 0, size)
            tri.ZIndex = zIdx

            local grad = Instance.new("UIGradient")
            grad.Rotation = rotation
            grad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0.0, 0),
                NumberSequenceKeypoint.new(0.5, 0),
                NumberSequenceKeypoint.new(0.501, 1),
                NumberSequenceKeypoint.new(1.0, 1)
            })
            grad.Parent = tri
            tri.Parent = parentContainer
            return tri
        end

        local spineX = 14
        local spineY = 10
        local spineW = 12
        local spineH = 50
        local barH = 10

        local function makeCutBar(prefix, y, totalLen)
            local bodyLen = totalLen - barH
            makeBox(prefix .. "_Bar", spineX + spineW, y, bodyLen, barH)
            makeTriangle(prefix .. "_Slope", spineX + spineW + bodyLen, y, barH, 45)
        end

        makeBox("E_Spine", spineX, spineY, spineW, spineH)
        makeTriangle("E_WingSlope", spineX - barH, spineY, barH, 135)
        makeCutBar("E_Top", spineY, 40)

        local midY = spineY + math.floor((spineH - barH) / 2)
        makeCutBar("E_Mid", midY, 30)

        local botY = spineY + spineH - barH
        makeCutBar("E_Bot", botY, 20)
    end

    buildLogoE(shadowRoot, Color3.fromRGB(25, 25, 30), Color3.fromRGB(25, 25, 30), 2)
    buildLogoE(root, Color3.fromRGB(240, 240, 245), Color3.fromRGB(255, 255, 255), 3)

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

    local profileCard = Instance.new("Frame")
    profileCard.Name = "ProfileCard"
    profileCard.Size = UDim2.new(0, 135, 0, 44)
    profileCard.Position = UDim2.new(0, 8, 1, -52)
    profileCard.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    profileCard.BackgroundTransparency = 0.5
    profileCard.BorderSizePixel = 0
    profileCard.ClipsDescendants = true
    profileCard.ZIndex = 3
    profileCard.Parent = sidebar

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = profileCard
    addUIStroke(profileCard, Color3.fromRGB(45, 45, 55), 1, 0.3, 0)

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "PortAvatar"
    avatarImg.Size = UDim2.new(0, 32, 0, 32)
    avatarImg.Position = UDim2.new(0, 6, 0.5, 0)
    avatarImg.AnchorPoint = Vector2.new(0, 0.5)
    avatarImg.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    avatarImg.BorderSizePixel = 0
    avatarImg.ScaleType = Enum.ScaleType.Fit
    avatarImg.ZIndex = 4
    avatarImg.Parent = profileCard

    local avatarCorner = Instance.new("UICorner")
    avatarCorner.CornerRadius = UDim.new(1, 0)
    avatarCorner.Parent = avatarImg

    local helloLabel = Instance.new("TextLabel")
    helloLabel.Name = "HelloLabel"
    helloLabel.Size = UDim2.new(1, -50, 0, 14)
    helloLabel.Position = UDim2.new(0, 44, 0, 7)
    helloLabel.BackgroundTransparency = 1
    helloLabel.Font = Enum.Font.GothamMedium
    helloLabel.Text = "Hello"
    helloLabel.TextColor3 = Color3.fromRGB(110, 110, 120)
    helloLabel.TextSize = 12
    helloLabel.TextXAlignment = Enum.TextXAlignment.Left
    helloLabel.ZIndex = 4
    helloLabel.Parent = profileCard

    local nickLabel = Instance.new("TextLabel")
    nickLabel.Name = "Nick"
    nickLabel.Size = UDim2.new(1, -52, 0, 16)
    nickLabel.Position = UDim2.new(0, 44, 0, 21)
    nickLabel.BackgroundTransparency = 1
    nickLabel.Font = Enum.Font.GothamBold
    nickLabel.Text = (p and p.Name) or "Player"
    nickLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
    nickLabel.TextScaled = true
    nickLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nickLabel.TextXAlignment = Enum.TextXAlignment.Left
    nickLabel.ZIndex = 4
    nickLabel.Parent = profileCard

    local nickSizeConstraint = Instance.new("UITextSizeConstraint")
    nickSizeConstraint.MaxTextSize = 13
    nickSizeConstraint.MinTextSize = 8
    nickSizeConstraint.Parent = nickLabel

    task.spawn(function()
        pcall(function()
            local success, thumbnail = pcall(function()
                return playersService:GetUserThumbnailAsync(
                    p.UserId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size150x150
                )
            end)
            if success and thumbnail then
                avatarImg.Image = thumbnail
            end
        end)
    end)

    local fone = Instance.new("Frame")
    fone.Name = "Fone"
    fone.Size = UDim2.new(0, 115, 0, 15)
    fone.AnchorPoint = Vector2.new(0.5, 0)
    fone.Position = UDim2.new(0.5, 0, 1, 0)
    fone.BackgroundColor3 = Color3.fromRGB(6, 6, 8)
    fone.BorderSizePixel = 0
    fone.ZIndex = 60
    fone.Parent = f2

    local c3 = Instance.new("UICorner")
    c3.CornerRadius = UDim.new(0, 9)
    c3.Parent = fone
    addUIStroke(fone, Color3.fromRGB(45, 45, 55), 1, 0.4, 0)

    local cffone = Instance.new("Frame")
    cffone.Size = UDim2.new(1, 0, 0, 9)
    cffone.Position = UDim2.new(0, 0, 0, 0)
    cffone.BackgroundColor3 = Color3.fromRGB(6, 6, 8)
    cffone.BorderSizePixel = 0
    cffone.ZIndex = 60
    cffone.Parent = fone

    local closeFrame = Instance.new("Frame")
    closeFrame.Name = "Close"
    closeFrame.Size = UDim2.new(0, 30, 1, 0)
    closeFrame.Position = UDim2.new(0, 0, 0, 0)
    closeFrame.BackgroundTransparency = 1
    closeFrame.ZIndex = 61
    closeFrame.Parent = fone

    local closeImg = Instance.new("ImageLabel")
    closeImg.AnchorPoint = Vector2.new(0, 0.5)
    closeImg.Position = UDim2.new(0, 7, 0.5, 0)
    closeImg.Size = UDim2.new(0, 11, 0, 11)
    closeImg.BackgroundTransparency = 1
    closeImg.Image = "rbxassetid://116396312853810"
    closeImg.ScaleType = Enum.ScaleType.Fit
    closeImg.ZIndex = 61
    closeImg.Parent = closeFrame

    local hitBoxC = Instance.new("TextButton")
    hitBoxC.Name = "CloseHitbox"
    hitBoxC.BackgroundTransparency = 1
    hitBoxC.Text = ""
    hitBoxC.Size = UDim2.new(1, 0, 1, 0)
    hitBoxC.ZIndex = 62
    hitBoxC.Parent = closeFrame
    hitBoxC.Activated:Connect(function()
        if s then s:Destroy() end
    end)

    s.Destroying:Connect(function()
        if state.GuiToggleConn then
            state.GuiToggleConn:Disconnect()
            state.GuiToggleConn = nil
        end
        state.Initialized = false
        state.ScreenGui = nil
        state.Window001 = nil
        state.Window002 = nil
        state.SidebarScroll = nil
        state.CurrentActiveId = nil
        table.clear(state.MiniButtons)
        table.clear(state.Frames)
        table.clear(state.Sections)
        table.clear(state.CurrentSectionTabIds)
        table.clear(state.TabCallbacksRan)
        state.LastExpandedClose = nil
        state.CurrentSection = nil
        state.GlobalTabCount = 0
        state.OpenFirst = true
        state.ScheduledAutoSelect = false
        state.CurrentTabFrame = nil
        state.CurrentGroup = nil
    end)

    local minusFrame = Instance.new("Frame")
    minusFrame.Name = "Minus"
    minusFrame.Size = UDim2.new(0, 30, 1, 0)
    minusFrame.Position = UDim2.new(1, -30, 0, 0)
    minusFrame.BackgroundTransparency = 1
    minusFrame.ZIndex = 61
    minusFrame.Parent = fone

    local minusImg = Instance.new("ImageLabel")
    minusImg.AnchorPoint = Vector2.new(1, 0.5)
    minusImg.Position = UDim2.new(1, -7, 0.5, 0)
    minusImg.Size = UDim2.new(0, 11, 0, 11)
    minusImg.BackgroundTransparency = 1
    minusImg.Image = "rbxassetid://95070996149109"
    minusImg.ScaleType = Enum.ScaleType.Fit
    minusImg.ZIndex = 61
    minusImg.Parent = minusFrame

    local hitBoxMinus = Instance.new("TextButton")
    hitBoxMinus.Name = "MinusHitbox"
    hitBoxMinus.BackgroundTransparency = 1
    hitBoxMinus.Text = ""
    hitBoxMinus.Size = UDim2.new(1, 0, 1, 0)
    hitBoxMinus.ZIndex = 62
    hitBoxMinus.Parent = minusFrame

    local isCollapsed = false
    local tweenBusy = false
    local animInfo = TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

    hitBoxMinus.Activated:Connect(function()
        if tweenBusy then return end
        tweenBusy = true

        local targetWidth = isCollapsed and 651 or 500
        local targetCfTransparency = isCollapsed and 0 or 1
        local targetStrokeF2 = isCollapsed and 1 or 0.35
        local targetStrokeF1 = isCollapsed and 0.35 or 1

        local curX = f1.Position.X.Offset
        local curY = f1.Position.Y.Offset
        local rightEdge = curX + f1.Size.X.Offset
        local targetX = math.max(0, rightEdge - targetWidth)

        local twFrame = ts:Create(f1, animInfo, {
            Size = UDim2.new(0, targetWidth, 0, 450),
            Position = UDim2.new(0, targetX, 0, curY)
        })
        local twCorner = ts:Create(cf, animInfo, {BackgroundTransparency = targetCfTransparency})
        local twStrokeF1 = ts:Create(strokeF1, animInfo, {Transparency = targetStrokeF1})
        local twStrokeF2 = ts:Create(strokeF2, animInfo, {Transparency = targetStrokeF2})

        twFrame:Play()
        twCorner:Play()
        twStrokeF1:Play()
        twStrokeF2:Play()

        twFrame.Completed:Connect(function()
            isCollapsed = not isCollapsed
            tweenBusy = false
        end)
    end)

    local moveFrame = Instance.new("Frame")
    moveFrame.Name = "Move"
    moveFrame.Size = UDim2.new(0, 30, 1, 0)
    moveFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    moveFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    moveFrame.BackgroundTransparency = 1
    moveFrame.ZIndex = 61
    moveFrame.Parent = fone

    local moveImg = Instance.new("ImageLabel")
    moveImg.AnchorPoint = Vector2.new(0.5, 0.5)
    moveImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    moveImg.Size = UDim2.new(0, 11, 0, 11)
    moveImg.BackgroundTransparency = 1
    moveImg.Image = "rbxassetid://77028714324861"
    moveImg.ScaleType = Enum.ScaleType.Fit
    moveImg.ZIndex = 61
    moveImg.Parent = moveFrame

    local hitBoxM = Instance.new("TextButton")
    hitBoxM.Name = "DragHitbox"
    hitBoxM.BackgroundTransparency = 1
    hitBoxM.Text = ""
    hitBoxM.Size = UDim2.new(1, 0, 1, 0)
    hitBoxM.ZIndex = 62
    hitBoxM.Parent = moveFrame

    local isDragging = false
    local dragStartMouse = nil
    local dragStartFrame = nil

    local function updateDrag(input)
        local delta = input.Position - dragStartMouse
        local targetX = math.round(dragStartFrame.X + delta.X)
        local targetY = math.round(dragStartFrame.Y + delta.Y)

        local scrSize = (s and s.AbsoluteSize) or cam.ViewportSize
        local inset = gs:GetGuiInset()
        local screenW = scrSize.X
        local screenH = scrSize.Y - inset.Y

        local frameW = f1.Size.X.Offset
        local frameH = f1.Size.Y.Offset

        local clampedX = math.clamp(targetX, 0, math.max(0, screenW - frameW))
        local clampedY = math.clamp(targetY, 0, math.max(0, screenH - frameH))

        f1.Position = UDim2.new(0, clampedX, 0, clampedY)
    end

    hitBoxM.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStartMouse = input.Position
            dragStartFrame = Vector2.new(f1.Position.X.Offset, f1.Position.Y.Offset)

            local moveConn
            local endConn

            moveConn = uis.InputChanged:Connect(function(moveInput)
                if (moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch) and isDragging then
                    updateDrag(moveInput)
                end
            end)

            endConn = uis.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                    if moveConn then moveConn:Disconnect() end
                    if endConn then endConn:Disconnect() end
                end
            end)
        end
    end)
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

    state.CurrentSectionTabIds = {}

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
        return UI.HeaderHeight + (count * UI.RowHeight) + (math.max(0, count - 1) * UI.SubPadding) + UI.SectionBottomPad
    end

    local busy = false
    local function setExpanded(expand, instant)
        if expand == sectionObj.IsExpanded then
            busy = false
            return
        end
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
            busy = false
        else
            local tw = ts:Create(entry, TWEEN_INFO, {Size = sz})
            ts:Create(arrow, TWEEN_INFO, {Rotation = rot}):Play()
            if sectionObj.IsExpanded then
                tw.Completed:Connect(function()
                    if sectionObj.IsExpanded then entry.ClipsDescendants = false end
                    busy = false
                end)
            else
                entry.ClipsDescendants = true
                tw.Completed:Connect(function()
                    busy = false
                end)
            end
            tw:Play()
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
    end)

    table.insert(state.Sections, sectionObj)
    state.CurrentSection = sectionObj

    return sectionObj
end

function Lib:Tab(textStr, iconImg, callback)
    initGUI()
    local curSec = state.CurrentSection
    if not curSec then return end

    state.GlobalTabCount = state.GlobalTabCount + 1
    curSec.SubCount = curSec.SubCount + 1

    local formattedId = string.format("%03d", state.GlobalTabCount)
    table.insert(state.CurrentSectionTabIds, formattedId)

    if not curSec.FirstTabId then
        curSec.FirstTabId = formattedId
        curSec.FirstCallback = callback
    end

    local targetName = "F" .. formattedId
    if not state.Frames[targetName] then
        local targetFrame = Instance.new("ScrollingFrame")
        targetFrame.Name = targetName
        targetFrame.Size = UDim2.new(1, 0, 1, -27)
        targetFrame.Position = UDim2.new(0, 0, 0, 27)
        targetFrame.BackgroundTransparency = 1
        targetFrame.BorderSizePixel = 0
        targetFrame.ScrollBarThickness = 3
        targetFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 75)
        targetFrame.ScrollBarImageTransparency = 0.5
        targetFrame.ScrollingEnabled = true
        targetFrame.ElasticBehavior = Enum.ElasticBehavior.Never
        targetFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        targetFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        targetFrame.Visible = false

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.Wraps = true
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = targetFrame

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, PAD_SIDES)
        padding.PaddingRight = UDim.new(0, PAD_SIDES)
        padding.PaddingTop = UDim.new(0, PAD_TOP)
        padding.PaddingBottom = UDim.new(0, PAD_BOTTOM)
        padding.Parent = targetFrame

        if state.Window002 then
            targetFrame.Parent = state.Window002
        end
        state.Frames[targetName] = targetFrame
    end

    state.CurrentTabFrame = state.Frames[targetName]

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

    local grad = Instance.new("UIGradient")
    grad.Rotation = 90
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20)),
    })
    grad.Parent = card

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

    local ac = Instance.new("UICorner")
    ac.CornerRadius = UDim.new(1, 0)
    ac.Parent = accent

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
        if callback and not state.TabCallbacksRan[formattedId] then
            state.TabCallbacksRan[formattedId] = true
            task.spawn(callback)
        end
    end)

    if curSec.IsExpanded then
        local targetOpen = UI.HeaderHeight + (curSec.SubCount * UI.RowHeight) + (math.max(0, curSec.SubCount - 1) * UI.SubPadding) + UI.SectionBottomPad
        curSec.Frame.Size = UDim2.new(1, 0, 0, targetOpen)
    end

    if state.OpenFirst and not state.ScheduledAutoSelect then
        state.ScheduledAutoSelect = true
        task.delay(0.1, function()
            switchTargetFrame("001")
            local firstSec = state.Sections[1]
            if firstSec and firstSec.FirstCallback and not state.TabCallbacksRan["001"] then
                state.TabCallbacksRan["001"] = true
                task.spawn(firstSec.FirstCallback)
            end
        end)
    end
end

function Lib:Button(textStr, iconImg, callback)
    initGUI()
    if type(iconImg) == "function" then
        callback = iconImg
        iconImg = nil
    end

    local curSec = state.CurrentSection
    if not curSec then return end

    curSec.SubCount = curSec.SubCount + 1

    local subLine = Instance.new("Frame")
    subLine.Name = "ButtonLine"
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
    local sTxt = Instance.new("TextLabel")
    sTxt.Name = "Label"
    sTxt.BackgroundTransparency = 1
    sTxt.AnchorPoint = Vector2.new(0, 0.5)
    sTxt.Position = UDim2.new(0, textX, 0.5, 0)
    sTxt.Size = UDim2.new(1, -(textX + 8), 1, 0)
    sTxt.Font = UI.ItemFont
    sTxt.TextSize = UI.ItemSize
    sTxt.TextXAlignment = Enum.TextXAlignment.Left
    sTxt.TextYAlignment = Enum.TextYAlignment.Center
    sTxt.Text = textStr or ""
    sTxt.TextColor3 = UI.SubIdleColor
    sTxt.Parent = card

    local btn = Instance.new("TextButton")
    btn.Name = "ActionBtn"
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Parent = card

    btn.MouseEnter:Connect(function()
        ts:Create(card, HOVER_INFO, {BackgroundTransparency = 0.2}):Play()
        ts:Create(stroke, HOVER_INFO, {Transparency = 0.4, Color = UI.StrokeHover}):Play()
    end)

    btn.MouseLeave:Connect(function()
        ts:Create(card, HOVER_INFO, {BackgroundTransparency = 1}):Play()
        ts:Create(stroke, HOVER_INFO, {Transparency = 1}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        ts:Create(card, TweenInfo.new(0.08), {BackgroundTransparency = 0}):Play()
        task.delay(0.08, function()
            ts:Create(card, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
        end)
        if callback then
            task.spawn(callback)
        end
    end)

    if curSec.IsExpanded then
        local targetOpen = UI.HeaderHeight + (curSec.SubCount * UI.RowHeight) + (math.max(0, curSec.SubCount - 1) * UI.SubPadding) + UI.SectionBottomPad
        curSec.Frame.Size = UDim2.new(1, 0, 0, targetOpen)
    end
end

function Lib:Text(textStr)
    initGUI()
    local curSec = state.CurrentSection
    if not curSec then return end

    curSec.SubCount = curSec.SubCount + 1

    local subLine = Instance.new("Frame")
    subLine.Name = "TextLine"
    subLine.BackgroundTransparency = 1
    subLine.Size = UDim2.new(1, 0, 0, UI.RowHeight - 4)
    subLine.LayoutOrder = curSec.SubCount
    subLine.Parent = curSec.Container

    local txt = Instance.new("TextLabel")
    txt.Name = "Label"
    txt.BackgroundTransparency = 1
    txt.AnchorPoint = Vector2.new(0, 0.5)
    txt.Position = UDim2.new(0, SUB_CONTENT_X + 2, 0.5, 0)
    txt.Size = UDim2.new(1, -SUB_CONTENT_X, 1, 0)
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 11
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.TextYAlignment = Enum.TextYAlignment.Center
    txt.Text = textStr or ""
    txt.TextColor3 = Color3.fromRGB(110, 110, 120)
    txt.Parent = subLine

    if curSec.IsExpanded then
        local targetOpen = UI.HeaderHeight + (curSec.SubCount * UI.RowHeight) + (math.max(0, curSec.SubCount - 1) * UI.SubPadding) + UI.SectionBottomPad
        curSec.Frame.Size = UDim2.new(1, 0, 0, targetOpen)
    end

    local obj = {}
    function obj:SetText(newText)
        txt.Text = newText
    end
    return obj
end

local function CreateInternalGroup(tabFrame, titleText)
    if not tabFrame then return end

    local groupFrame = Instance.new("Frame")
    groupFrame.Name = "Group_" .. tostring(titleText)
    groupFrame.Size = state.IsGrid and UDim2.new(0.5, -5, 0, 0) or UDim2.new(1, 0, 0, 0)
    groupFrame.AutomaticSize = Enum.AutomaticSize.Y
    groupFrame.BackgroundColor3 = UI.GroupBg
    groupFrame.BorderSizePixel = 0
    groupFrame.ClipsDescendants = false
    groupFrame.Parent = tabFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = groupFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = UI.GroupStroke
    stroke.Thickness = 1
    stroke.Transparency = 0.35
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = groupFrame

    local header = Instance.new("TextLabel")
    header.Name = "Header"
    header.Size = UDim2.new(1, -(PAD_SIDES * 2) - 20, 0, 30)
    header.Position = UDim2.new(0, PAD_SIDES, 0, 0)
    header.BackgroundTransparency = 1
    header.Font = Enum.Font.GothamBold
    header.TextSize = 13
    header.TextColor3 = UI.GroupHeaderColor
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.TextYAlignment = Enum.TextYAlignment.Center
    header.Text = tostring(titleText)
    header.Parent = groupFrame

    local arrow = Instance.new("ImageLabel")
    arrow.Name = "Arrow"
    arrow.BackgroundTransparency = 1
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.Position = UDim2.new(1, -PAD_SIDES, 0, 15)
    arrow.Size = UDim2.new(0, 10, 0, 10)
    arrow.Image = FIXED_ARROW_ID
    arrow.ImageColor3 = Color3.fromRGB(160, 160, 170)
    arrow.Rotation = -90
    arrow.Parent = groupFrame

    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(1, -(PAD_SIDES * 2), 0, 1)
    divider.Position = UDim2.new(0, PAD_SIDES, 0, 30)
    divider.BackgroundColor3 = UI.GroupDivider
    divider.BorderSizePixel = 0
    divider.Parent = groupFrame

    local divGrad = Instance.new("UIGradient")
    divGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.1, 0.35),
        NumberSequenceKeypoint.new(0.9, 0.35),
        NumberSequenceKeypoint.new(1, 1)
    })
    divGrad.Parent = divider

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.Position = UDim2.new(0, 0, 0, 31)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = groupFrame

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, PAD_SIDES)
    padding.PaddingRight = UDim.new(0, PAD_SIDES)
    padding.PaddingTop = UDim.new(0, PAD_TOP)
    padding.PaddingBottom = UDim.new(0, PAD_BOTTOM)
    padding.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container

    state.CurrentGroup = container
end

function Lib:Group(titleText)
    CreateInternalGroup(state.CurrentTabFrame, titleText)
end

for i = 1, 50 do
    Lib["Group" .. i] = function(self, titleText)
        local targetTabId = state.CurrentSectionTabIds[i]
        local targetTabFrame = targetTabId and state.Frames["F" .. targetTabId] or state.CurrentTabFrame
        CreateInternalGroup(targetTabFrame, titleText)
    end
end

function Lib:GroupAt(index, titleText)
    local targetTabId = state.CurrentSectionTabIds[index]
    local targetTabFrame = targetTabId and state.Frames["F" .. targetTabId] or state.CurrentTabFrame
    CreateInternalGroup(targetTabFrame, titleText)
end

local function makeRow(parent, labelText)
    local row = Instance.new("Frame")
    row.Name = "Row_" .. tostring(labelText)
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Name = "Label"
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.Font = UI.RowFont
    lbl.TextSize = UI.RowSize
    lbl.TextColor3 = UI.RowLabelColor
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.Text = tostring(labelText or "")
    lbl.Parent = row

    return row, lbl
end

function Lib:Toggle(textStr, default, callback)
    if not state.CurrentGroup then return end

    local row = makeRow(state.CurrentGroup, textStr)

    local boxSize = 16
    local box = Instance.new("Frame")
    box.Name = "Checkbox"
    box.AnchorPoint = Vector2.new(1, 0.5)
    box.Position = UDim2.new(1, 0, 0.5, 0)
    box.Size = UDim2.new(0, boxSize, 0, boxSize)
    box.BackgroundColor3 = UI.ControlBg
    box.BorderSizePixel = 0
    box.Parent = row

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = box

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = UI.ControlBorder
    boxStroke.Thickness = 1
    boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    boxStroke.Parent = box

    local check = Instance.new("ImageLabel")
    check.Name = "Check"
    check.BackgroundTransparency = 1
    check.AnchorPoint = Vector2.new(0.5, 0.5)
    check.Position = UDim2.new(0.5, 0, 0.5, 0)
    check.Size = UDim2.new(0, 10, 0, 10)
    check.Image = CHECK_ICON_ID
    check.ImageColor3 = Color3.fromRGB(20, 20, 24)
    check.Visible = false
    check.Parent = box

    local isOn = default and true or false

    local function updateVisuals()
        if isOn then
            box.BackgroundColor3 = UI.ControlActiveBg
            boxStroke.Color = UI.ControlActiveBg
            check.Visible = true
        else
            box.BackgroundColor3 = UI.ControlBg
            boxStroke.Color = UI.ControlBorder
            check.Visible = false
        end
    end
    updateVisuals()

    local btn = Instance.new("TextButton")
    btn.Name = "ToggleBtn"
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        updateVisuals()
        if callback then task.spawn(callback, isOn) end
    end)

    local obj = {}
    function obj:Set(value)
        isOn = value and true or false
        updateVisuals()
    end
    function obj:Get()
        return isOn
    end
    return obj
end

function Lib:Slider(textStr, minVal, maxVal, default, callback)
    if not state.CurrentGroup then return end

    local row = Instance.new("Frame")
    row.Name = "Slider_" .. tostring(textStr)
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundTransparency = 1
    row.Parent = state.CurrentGroup

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(0.6, 0, 0, 16)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.Font = UI.RowFont
    lbl.TextSize = UI.RowSize
    lbl.TextColor3 = UI.RowLabelColor
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.Text = tostring(textStr or "")
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.BackgroundTransparency = 1
    valLbl.AnchorPoint = Vector2.new(1, 0)
    valLbl.Position = UDim2.new(1, 0, 0, 0)
    valLbl.Size = UDim2.new(0.4, 0, 0, 16)
    valLbl.Font = UI.RowFontBold
    valLbl.TextSize = UI.RowSize
    valLbl.TextColor3 = UI.RowValueColor
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.TextYAlignment = Enum.TextYAlignment.Center
    valLbl.Text = tostring(math.floor(default or minVal))
    valLbl.Parent = row

    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Position = UDim2.new(0, 0, 0, 24)
    track.Size = UDim2.new(1, 0, 0, 4)
    track.BackgroundColor3 = UI.TrackBg
    track.BorderSizePixel = 0
    track.Parent = row

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local currentValue = math.clamp(default or minVal, minVal, maxVal)
    local initialAlpha = (currentValue - minVal) / math.max(0.0001, (maxVal - minVal))

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(initialAlpha, 0, 1, 0)
    fill.BackgroundColor3 = UI.ControlActiveBg
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local function setValue(v, fire)
        currentValue = math.clamp(v, minVal, maxVal)
        local alpha = (currentValue - minVal) / math.max(0.0001, (maxVal - minVal))
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        valLbl.Text = tostring(math.floor(currentValue + 0.5))
        if fire and callback then task.spawn(callback, currentValue) end
    end

    local btn = Instance.new("TextButton")
    btn.Name = "SliderHitbox"
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Size = UDim2.new(1, 0, 0, 14)
    btn.Position = UDim2.new(0, 0, 0, 18)
    btn.Parent = row

    local dragging = false
    local function updateFromInput(input)
        local relX = input.Position.X - track.AbsolutePosition.X
        local alpha = math.clamp(relX / math.max(1, track.AbsoluteSize.X), 0, 1)
        local v = minVal + alpha * (maxVal - minVal)
        setValue(v, true)
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
        end
    end)

    uis.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)

    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local obj = {}
    function obj:Set(v) setValue(v, false) end
    function obj:Get() return currentValue end
    return obj
end

function Lib:Dropdown(textStr, options, default, callback)
    if not state.CurrentGroup then return end

    local row = Instance.new("Frame")
    row.Name = "Dropdown_" .. tostring(textStr)
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundTransparency = 1
    row.ClipsDescendants = false
    row.ZIndex = 5
    row.Parent = state.CurrentGroup

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.AnchorPoint = Vector2.new(0, 0.5)
    lbl.Position = UDim2.new(0, 0, 0.5, 0)
    lbl.Size = UDim2.new(0.42, 0, 1, 0)
    lbl.Font = UI.RowFont
    lbl.TextSize = UI.RowSize
    lbl.TextColor3 = UI.RowLabelColor
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.Text = tostring(textStr or "")
    lbl.Parent = row

    local dropdown = Instance.new("Frame")
    dropdown.Name = "Box"
    dropdown.AnchorPoint = Vector2.new(1, 0.5)
    dropdown.Position = UDim2.new(1, 0, 0.5, 0)
    dropdown.Size = UDim2.new(0.55, 0, 0, 26)
    dropdown.BackgroundColor3 = UI.ControlBg
    dropdown.BorderSizePixel = 0
    dropdown.ZIndex = 6
    dropdown.Parent = row

    local ddCorner = Instance.new("UICorner")
    ddCorner.CornerRadius = UDim.new(0, 5)
    ddCorner.Parent = dropdown

    local ddStroke = Instance.new("UIStroke")
    ddStroke.Color = UI.ControlBorder
    ddStroke.Thickness = 1
    ddStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ddStroke.Parent = dropdown

    local ddText = Instance.new("TextLabel")
    ddText.Name = "Value"
    ddText.BackgroundTransparency = 1
    ddText.AnchorPoint = Vector2.new(0, 0.5)
    ddText.Position = UDim2.new(0, 8, 0.5, 0)
    ddText.Size = UDim2.new(1, -30, 1, 0)
    ddText.Font = UI.RowFont
    ddText.TextSize = UI.RowSize
    ddText.TextColor3 = UI.RowValueColor
    ddText.TextXAlignment = Enum.TextXAlignment.Left
    ddText.TextYAlignment = Enum.TextYAlignment.Center
    ddText.Text = tostring(default or (options and options[1]) or "")
    ddText.ZIndex = 7
    ddText.Parent = dropdown

    local chev = Instance.new("ImageLabel")
    chev.Name = "Chevron"
    chev.BackgroundTransparency = 1
    chev.AnchorPoint = Vector2.new(1, 0.5)
    chev.Position = UDim2.new(1, -8, 0.5, 0)
    chev.Size = UDim2.new(0, 10, 0, 10)
    chev.Image = FIXED_ARROW_ID
    chev.ImageColor3 = Color3.fromRGB(160, 160, 170)
    chev.Rotation = 90
    chev.ZIndex = 7
    chev.Parent = dropdown

    local btn = Instance.new("TextButton")
    btn.Name = "DropdownBtn"
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.ZIndex = 8
    btn.Parent = dropdown

    local currentValue = tostring(default or (options and options[1]) or "")

    local menu = Instance.new("Frame")
    menu.Name = "Menu"
    menu.AnchorPoint = Vector2.new(1, 0)
    menu.Position = UDim2.new(1, 0, 1, 2)
    menu.Size = UDim2.new(0.55, 0, 0, 0)
    menu.AutomaticSize = Enum.AutomaticSize.Y
    menu.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    menu.BorderSizePixel = 0
    menu.Visible = false
    menu.ZIndex = 20
    menu.Parent = dropdown

    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 5)
    menuCorner.Parent = menu

    local menuStroke = Instance.new("UIStroke")
    menuStroke.Color = UI.ControlBorder
    menuStroke.Thickness = 1
    menuStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    menuStroke.Parent = menu

    local menuPadding = Instance.new("UIPadding")
    menuPadding.PaddingTop = UDim.new(0, 4)
    menuPadding.PaddingBottom = UDim.new(0, 4)
    menuPadding.Parent = menu

    local menuLayout = Instance.new("UIListLayout")
    menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
    menuLayout.Padding = UDim.new(0, 2)
    menuLayout.Parent = menu

    local optionButtons = {}
    local function closeMenu()
        menu.Visible = false
        for _, b in ipairs(optionButtons) do b.Visible = false end
    end

    if options then
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Name = "Opt_" .. tostring(opt)
            optBtn.BackgroundTransparency = 1
            optBtn.Text = ""
            optBtn.Size = UDim2.new(1, 0, 0, 22)
            optBtn.LayoutOrder = i
            optBtn.Visible = false
            optBtn.ZIndex = 21
            optBtn.Parent = menu

            local optPad = Instance.new("UIPadding")
            optPad.PaddingLeft = UDim.new(0, 8)
            optPad.PaddingRight = UDim.new(0, 8)
            optPad.Parent = optBtn

            local optLbl = Instance.new("TextLabel")
            optLbl.BackgroundTransparency = 1
            optLbl.Size = UDim2.new(1, 0, 1, 0)
            optLbl.Font = UI.RowFont
            optLbl.TextSize = UI.RowSize
            optLbl.TextColor3 = Color3.fromRGB(210, 210, 215)
            optLbl.TextXAlignment = Enum.TextXAlignment.Left
            optLbl.TextYAlignment = Enum.TextYAlignment.Center
            optLbl.Text = tostring(opt)
            optLbl.ZIndex = 22
            optLbl.Parent = optBtn

            optBtn.MouseEnter:Connect(function()
                optLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            end)
            optBtn.MouseLeave:Connect(function()
                optLbl.TextColor3 = Color3.fromRGB(210, 210, 215)
            end)

            optBtn.MouseButton1Click:Connect(function()
                currentValue = tostring(opt)
                ddText.Text = currentValue
                closeMenu()
                if callback then task.spawn(callback, currentValue) end
            end)

            table.insert(optionButtons, optBtn)
        end
    end

    local menuOpen = false
    btn.MouseButton1Click:Connect(function()
        menuOpen = not menuOpen
        if menuOpen then
            for _, b in ipairs(optionButtons) do b.Visible = true end
            menu.Visible = true
        else
            closeMenu()
        end
    end)

    uis.InputBegan:Connect(function(input, gp)
        if not gp and menuOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local pos = input.Position
            local abs = menu.AbsolutePosition
            local size = menu.AbsoluteSize
            local inMenu = pos.X >= abs.X and pos.X <= abs.X + size.X and pos.Y >= abs.Y and pos.Y <= abs.Y + size.Y
            local dAbs = dropdown.AbsolutePosition
            local dSize = dropdown.AbsoluteSize
            local inBox = pos.X >= dAbs.X and pos.X <= dAbs.X + dSize.X and pos.Y >= dAbs.Y and pos.Y <= dAbs.Y + dSize.Y
            if not inMenu and not inBox then
                menuOpen = false
                closeMenu()
            end
        end
    end)

    local obj = {}
    function obj:Set(value)
        currentValue = tostring(value)
        ddText.Text = currentValue
    end
    function obj:Get()
        return currentValue
    end
    return obj
end

function Lib:ColorPreview(textStr, color, callback)
    if not state.CurrentGroup then return end

    local row = makeRow(state.CurrentGroup, textStr)

    local swatch = Instance.new("Frame")
    swatch.Name = "Swatch"
    swatch.AnchorPoint = Vector2.new(1, 0.5)
    swatch.Position = UDim2.new(1, 0, 0.5, 0)
    swatch.Size = UDim2.new(0, 22, 0, 16)
    swatch.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
    swatch.BorderSizePixel = 0
    swatch.Parent = row

    local swCorner = Instance.new("UICorner")
    swCorner.CornerRadius = UDim.new(0, 4)
    swCorner.Parent = swatch

    local swStroke = Instance.new("UIStroke")
    swStroke.Color = Color3.fromRGB(60, 60, 68)
    swStroke.Thickness = 1
    swStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    swStroke.Parent = swatch

    local btn = Instance.new("TextButton")
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        if callback then task.spawn(callback) end
    end)

    local obj = {}
    function obj:Set(c)
        swatch.BackgroundColor3 = c
    end
    return obj
end

function Lib:More(textStr, callback)
    if not state.CurrentGroup then return end

    local row = makeRow(state.CurrentGroup, textStr)

    local moreBtn = Instance.new("TextButton")
    moreBtn.Name = "MoreBtn"
    moreBtn.AnchorPoint = Vector2.new(1, 0.5)
    moreBtn.Position = UDim2.new(1, 0, 0.5, 0)
    moreBtn.Size = UDim2.new(0, 22, 0, 16)
    moreBtn.BackgroundTransparency = 1
    moreBtn.Text = "..."
    moreBtn.Font = Enum.Font.GothamBold
    moreBtn.TextSize = 12
    moreBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
    moreBtn.AutoButtonColor = false
    moreBtn.Parent = row

    moreBtn.MouseEnter:Connect(function()
        moreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    moreBtn.MouseLeave:Connect(function()
        moreBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
    end)

    moreBtn.MouseButton1Click:Connect(function()
        if callback then task.spawn(callback) end
    end)
end

function Lib:RowLabel(textStr)
    if not state.CurrentGroup then return end

    local row = Instance.new("Frame")
    row.Name = "RowLabel_" .. tostring(textStr)
    row.Size = UDim2.new(1, 0, 0, 18)
    row.BackgroundTransparency = 1
    row.Parent = state.CurrentGroup

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.Font = UI.RowFont
    lbl.TextSize = 11
    lbl.TextColor3 = Color3.fromRGB(150, 150, 160)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.Text = tostring(textStr or "")
    lbl.Parent = row

    local obj = {}
    function obj:SetText(newText) lbl.Text = newText end
    return obj
end

function Lib:Label(textStr)
    if not state.CurrentGroup then return end

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = textStr
    lbl.Parent = state.CurrentGroup
end

function Lib:SetGrid(enabled)
    state.IsGrid = tostring(enabled) == "true" or enabled == true
end

initGUI()

return Lib
