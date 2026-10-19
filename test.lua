local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Library = {}
Library.__index = Library

local function resolveAsset(assetInput)
	if not assetInput or assetInput == "" then return "" end
	local str = tostring(assetInput)
	if type(assetInput) == "number" or not str:find("://") then
		local num = str:gsub("%D", "")
		if #num > 0 then
			return "rbxassetid://" .. num
		end
	end
	if str:find("^rbxassetid://") then
		return str
	end
	if str:find("^http://") or str:find("^https://") then
		local ok, res = pcall(function()
			local getcustomasset = getcustomasset or getsynasset
			local req = (syn and syn.request) or (http and http.request) or http_request or request
			if getcustomasset and req and writefile and isfile then
				local hash = "asset_" .. string.sub(HttpService:GenerateGUID(false), 1, 8) .. ".png"
				if not isfile(hash) then
					local response = req({Url = str, Method = "GET"})
					if response and response.Body then
						writefile(hash, response.Body)
					end
				end
				if isfile(hash) then
					return getcustomasset(hash)
				end
			end
			return nil
		end)
		if ok and res then return res end
	end
	return ""
end

function Library:CreateWindow(config)
	config = config or {}

	local LocalPlayer = Players.LocalPlayer
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

	local BlurEffect = Instance.new("BlurEffect")
	BlurEffect.Name = "GuiBlur"
	BlurEffect.Size = 12
	BlurEffect.Enabled = true
	BlurEffect.Parent = Lighting

	local OverlayGui = Instance.new("ScreenGui")
	OverlayGui.Name = "CustomLibraryGui"
	OverlayGui.ResetOnSpawn = false
	OverlayGui.IgnoreGuiInset = true
	OverlayGui.Parent = PlayerGui

	local BlackOverlay = Instance.new("Frame")
	BlackOverlay.Name = "BlackOverlay"
	BlackOverlay.Size = UDim2.new(1, 0, 1, 0)
	BlackOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	BlackOverlay.BackgroundTransparency = 0.5
	BlackOverlay.BorderSizePixel = 0
	BlackOverlay.Parent = OverlayGui

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 860, 0, 540)

	local cam = workspace.CurrentCamera
	local viewSize = (cam and cam.ViewportSize) or Vector2.new(1920, 1080)
	local initX = math.max(0, math.floor((viewSize.X - 860) / 2))
	local initY = math.max(0, math.floor((viewSize.Y - 540) / 2))
	MainFrame.Position = UDim2.new(0, initX, 0, initY)
	MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true
	MainFrame.Active = true
	MainFrame.Parent = OverlayGui

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 12)
	MainCorner.Parent = MainFrame

	local MainStroke = Instance.new("UIStroke")
	MainStroke.Color = Color3.fromRGB(30, 30, 35)
	MainStroke.Thickness = 1
	MainStroke.Parent = MainFrame

	-- Зона перетаскивания (смещена вправо от сайдбара, чтобы не блокировать клики по титулам)
	local HeaderDrag = Instance.new("TextButton")
	HeaderDrag.Name = "HeaderDrag"
	HeaderDrag.Size = UDim2.new(1, -385, 0, 48)
	HeaderDrag.Position = UDim2.new(0, 215, 0, 0)
	HeaderDrag.BackgroundTransparency = 1
	HeaderDrag.Text = ""
	HeaderDrag.AutoButtonColor = false
	HeaderDrag.ZIndex = 5
	HeaderDrag.Parent = MainFrame

	-- Сайдбар
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 205, 1, -12)
	Sidebar.Position = UDim2.new(0, 6, 0, 6)
	Sidebar.BackgroundColor3 = Color3.fromRGB(17, 17, 19)
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = MainFrame

	local SidebarCorner = Instance.new("UICorner")
	SidebarCorner.CornerRadius = UDim.new(0, 8)
	SidebarCorner.Parent = Sidebar

	local SidebarStroke = Instance.new("UIStroke")
	SidebarStroke.Color = Color3.fromRGB(40, 40, 48)
	SidebarStroke.Thickness = 1
	SidebarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	SidebarStroke.Parent = Sidebar

	local NavScroll = Instance.new("ScrollingFrame")
	NavScroll.Name = "NavScroll"
	NavScroll.Size = UDim2.new(1, -8, 1, -66)
	NavScroll.Position = UDim2.new(0, 4, 0, 8)
	NavScroll.BackgroundTransparency = 1
	NavScroll.BorderSizePixel = 0
	NavScroll.ScrollBarThickness = 2
	NavScroll.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 65)
	NavScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	NavScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	NavScroll.Parent = Sidebar

	local NavList = Instance.new("UIListLayout")
	NavList.SortOrder = Enum.SortOrder.LayoutOrder
	NavList.Padding = UDim.new(0, 6)
	NavList.Parent = NavScroll

	-- Профиль
	local Profile = Instance.new("Frame")
	Profile.Name = "ProfilePanel"
	Profile.Size = UDim2.new(1, -8, 0, 48)
	Profile.Position = UDim2.new(0, 4, 1, -52)
	Profile.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
	Profile.BorderSizePixel = 0
	Profile.Parent = Sidebar

	local ProfileCorner = Instance.new("UICorner")
	ProfileCorner.CornerRadius = UDim.new(0, 6)
	ProfileCorner.Parent = Profile

	local ProfileStroke = Instance.new("UIStroke")
	ProfileStroke.Color = Color3.fromRGB(30, 30, 35)
	ProfileStroke.Thickness = 1
	ProfileStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ProfileStroke.Parent = Profile

	local AvatarHolder = Instance.new("Frame")
	AvatarHolder.Size = UDim2.new(0, 38, 0, 38)
	AvatarHolder.Position = UDim2.new(0, 5, 0.5, -19)
	AvatarHolder.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AvatarHolder.ClipsDescendants = true
	AvatarHolder.BorderSizePixel = 0
	AvatarHolder.Parent = Profile

	local AvatarCorner = Instance.new("UICorner")
	AvatarCorner.CornerRadius = UDim.new(0, 19)
	AvatarCorner.Parent = AvatarHolder

	local AvatarImage = Instance.new("ImageLabel")
	AvatarImage.Size = UDim2.new(1, 0, 1, 0)
	AvatarImage.BackgroundTransparency = 1
	AvatarImage.Parent = AvatarHolder

	task.spawn(function()
		local s, thumb = pcall(function()
			return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if s then AvatarImage.Image = thumb end
	end)

	local HelloText = Instance.new("TextLabel")
	HelloText.Size = UDim2.new(1, -54, 0, 14)
	HelloText.Position = UDim2.new(0, 48, 0.5, -14)
	HelloText.BackgroundTransparency = 1
	HelloText.Font = Enum.Font.GothamMedium
	HelloText.Text = "Hello,"
	HelloText.TextSize = 11
	HelloText.TextColor3 = Color3.fromRGB(150, 150, 155)
	HelloText.TextXAlignment = Enum.TextXAlignment.Left
	HelloText.Parent = Profile

	local NicknameText = Instance.new("TextLabel")
	NicknameText.Size = UDim2.new(1, -54, 0, 16)
	NicknameText.Position = UDim2.new(0, 48, 0.5, 0)
	NicknameText.BackgroundTransparency = 1
	NicknameText.Font = Enum.Font.GothamBold
	NicknameText.Text = LocalPlayer.DisplayName
	NicknameText.TextSize = 13
	NicknameText.TextColor3 = Color3.fromRGB(255, 255, 255)
	NicknameText.TextXAlignment = Enum.TextXAlignment.Left
	NicknameText.TextTruncate = Enum.TextTruncate.AtEnd
	NicknameText.Parent = Profile

	-- Верхняя панель справа
	local TopRightContainer = Instance.new("Frame")
	TopRightContainer.Name = "TopRightContainer"
	TopRightContainer.Size = UDim2.new(0, 150, 0, 30)
	TopRightContainer.Position = UDim2.new(1, -165, 0, 14)
	TopRightContainer.BackgroundTransparency = 1
	TopRightContainer.ZIndex = 10
	TopRightContainer.Parent = MainFrame

	local TopLayout = Instance.new("UIListLayout")
	TopLayout.FillDirection = Enum.FillDirection.Horizontal
	TopLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	TopLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	TopLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TopLayout.Padding = UDim.new(0, 12)
	TopLayout.Parent = TopRightContainer

	local function setupHover(button, defCol, hovCol)
		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {ImageColor3 = hovCol}):Play()
		end)
		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {ImageColor3 = defCol}):Play()
		end)
	end

	local SettingsBtn = Instance.new("ImageButton")
	SettingsBtn.Name = "SettingsBtn"
	SettingsBtn.Size = UDim2.new(0, 20, 0, 20)
	SettingsBtn.BackgroundTransparency = 1
	SettingsBtn.Image = "rbxassetid://106205298246017"
	SettingsBtn.ImageColor3 = Color3.fromRGB(150, 150, 155)
	SettingsBtn.Parent = TopRightContainer
	setupHover(SettingsBtn, Color3.fromRGB(150, 150, 155), Color3.fromRGB(255, 255, 255))

	local FolderBtn = Instance.new("ImageButton")
	FolderBtn.Name = "FolderBtn"
	FolderBtn.Size = UDim2.new(0, 20, 0, 20)
	FolderBtn.BackgroundTransparency = 1
	FolderBtn.Image = "rbxassetid://127866486547434"
	FolderBtn.ImageColor3 = Color3.fromRGB(150, 150, 155)
	FolderBtn.Parent = TopRightContainer
	setupHover(FolderBtn, Color3.fromRGB(150, 150, 155), Color3.fromRGB(255, 255, 255))

	local Divider = Instance.new("Frame")
	Divider.Name = "Divider"
	Divider.Size = UDim2.new(0, 1, 0, 14)
	Divider.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	Divider.BorderSizePixel = 0
	Divider.Parent = TopRightContainer

	local CloseBtn = Instance.new("ImageButton")
	CloseBtn.Name = "CloseBtn"
	CloseBtn.Size = UDim2.new(0, 20, 0, 20)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Image = "rbxassetid://116396312853810"
	CloseBtn.ImageColor3 = Color3.fromRGB(180, 180, 185)
	CloseBtn.Parent = TopRightContainer
	setupHover(CloseBtn, Color3.fromRGB(180, 180, 185), Color3.fromRGB(255, 255, 255))

	local ResizeBtn = Instance.new("ImageButton")
	ResizeBtn.Name = "ResizeBtn"
	ResizeBtn.Size = UDim2.new(0, 16, 0, 16)
	ResizeBtn.Position = UDim2.new(1, -20, 1, -20)
	ResizeBtn.BackgroundTransparency = 1
	ResizeBtn.Image = "rbxassetid://128492050787735"
	ResizeBtn.ImageColor3 = Color3.fromRGB(120, 120, 125)
	ResizeBtn.ZIndex = 10
	ResizeBtn.Parent = MainFrame
	setupHover(ResizeBtn, Color3.fromRGB(120, 120, 125), Color3.fromRGB(255, 255, 255))

	local ContentContainer = Instance.new("Frame")
	ContentContainer.Name = "ContentContainer"
	ContentContainer.Size = UDim2.new(1, -228, 1, -54)
	ContentContainer.Position = UDim2.new(0, 218, 0, 46)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Parent = MainFrame

	-- Синхронный реестр для плавного затухания интерфейса
	local FadeElements = {}
	local function registerFade(obj, prop, defVal)
		table.insert(FadeElements, {obj = obj, prop = prop, default = defVal})
	end

	registerFade(MainFrame, "BackgroundTransparency", 0)
	registerFade(MainStroke, "Transparency", 0)
	registerFade(Sidebar, "BackgroundTransparency", 0)
	registerFade(SidebarStroke, "Transparency", 0)
	registerFade(Profile, "BackgroundTransparency", 0)
	registerFade(ProfileStroke, "Transparency", 0)
	registerFade(AvatarHolder, "BackgroundTransparency", 0)
	registerFade(AvatarImage, "ImageTransparency", 0)
	registerFade(HelloText, "TextTransparency", 0)
	registerFade(NicknameText, "TextTransparency", 0)
	registerFade(Divider, "BackgroundTransparency", 0)
	registerFade(SettingsBtn, "ImageTransparency", 0)
	registerFade(FolderBtn, "ImageTransparency", 0)
	registerFade(CloseBtn, "ImageTransparency", 0)
	registerFade(ResizeBtn, "ImageTransparency", 0)

	-- Shatter effect (разлет на осколки)
	local isDestroying = false
	local function shatterAndDestroy()
		if isDestroying then return end
		isDestroying = true

		local framePos = MainFrame.AbsolutePosition
		local frameSize = MainFrame.AbsoluteSize
		MainFrame.Visible = false

		TweenService:Create(BlackOverlay, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		}):Play()

		TweenService:Create(BlurEffect, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = 0
		}):Play()

		local piecesFolder = Instance.new("Folder")
		piecesFolder.Name = "ShatterPieces"
		piecesFolder.Parent = OverlayGui

		local blockSize = 32
		local cols = math.clamp(math.floor(frameSize.X / blockSize), 8, 28)
		local rows = math.clamp(math.floor(frameSize.Y / blockSize), 6, 18)
		local cellW = frameSize.X / cols
		local cellH = frameSize.Y / rows
		local centerX = framePos.X + frameSize.X / 2

		for r = 0, rows - 1 do
			for c = 0, cols - 1 do
				local piece = Instance.new("Frame")
				piece.BorderSizePixel = 0
				local posX = framePos.X + c * cellW
				local posY = framePos.Y + r * cellH
				piece.Position = UDim2.new(0, posX, 0, posY)
				piece.Size = UDim2.new(0, cellW - 1, 0, cellH - 1)

				local shade = math.random(14, 26)
				piece.BackgroundColor3 = Color3.fromRGB(shade, shade, shade + 2)
				piece.Parent = piecesFolder

				local isLeft = (posX + cellW / 2) < centerX
				local dirX = isLeft and -1 or 1
				local spreadX = math.random(120, 360) * dirX
				local spreadY = math.random(-90, 160)
				local rot = math.random(-140, 140)
				local dur = math.random(110, 160) / 100

				TweenService:Create(piece, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = UDim2.new(0, posX + spreadX, 0, posY + spreadY),
					Rotation = rot,
					Size = UDim2.new(0, 0, 0, 0),
					BackgroundTransparency = 1
				}):Play()
			end
		end

		task.wait(1.5)
		BlurEffect:Destroy()
		OverlayGui:Destroy()
	end
	CloseBtn.MouseButton1Click:Connect(shatterAndDestroy)

	-- Плавная анимация скрытия/показа (Left Alt)
	local isGuiOpen = true
	local isAnimating = false
	local fadeInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

	local function toggleGui()
		if isAnimating or isDestroying then return end
		isAnimating = true
		isGuiOpen = not isGuiOpen

		if isGuiOpen then
			MainFrame.Visible = true
			BlackOverlay.Visible = true
			BlurEffect.Enabled = true

			for _, item in ipairs(FadeElements) do
				item.obj[item.prop] = 1
				TweenService:Create(item.obj, fadeInfo, {[item.prop] = item.default}):Play()
			end

			TweenService:Create(BlackOverlay, fadeInfo, {BackgroundTransparency = 0.5}):Play()
			local tBlur = TweenService:Create(BlurEffect, fadeInfo, {Size = 12})
			tBlur.Completed:Connect(function()
				isAnimating = false
			end)
			tBlur:Play()
		else
			for _, item in ipairs(FadeElements) do
				TweenService:Create(item.obj, fadeInfo, {[item.prop] = 1}):Play()
			end

			TweenService:Create(BlackOverlay, fadeInfo, {BackgroundTransparency = 1}):Play()
			local tBlur = TweenService:Create(BlurEffect, fadeInfo, {Size = 0})
			tBlur.Completed:Connect(function()
				if not isGuiOpen then
					MainFrame.Visible = false
					BlackOverlay.Visible = false
					BlurEffect.Enabled = false
				end
				isAnimating = false
			end)
			tBlur:Play()
		end
	end

	UserInputService.InputBegan:Connect(function(input, gp)
		if input.KeyCode == Enum.KeyCode.LeftAlt and not gp then
			toggleGui()
		end
	end)

	-- Перемещение и ресайз
	local isDragging, isResizing = false, false
	local dragStartMouse, startFramePos = Vector2.new(), Vector2.new()
	local targetPos = Vector2.new(initX, initY)
	local resizeStartMouse, startFrameSize = Vector2.new(), Vector2.new()

	HeaderDrag.InputBegan:Connect(function(input)
		if isDestroying then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			dragStartMouse = UserInputService:GetMouseLocation()
			startFramePos = Vector2.new(MainFrame.Position.X.Offset, MainFrame.Position.Y.Offset)
			targetPos = startFramePos
		end
	end)

	ResizeBtn.InputBegan:Connect(function(input)
		if isDestroying then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isResizing = true
			isDragging = false
			resizeStartMouse = UserInputService:GetMouseLocation()
			startFrameSize = Vector2.new(MainFrame.AbsoluteSize.X, MainFrame.AbsoluteSize.Y)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isDestroying then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local currentMouse = UserInputService:GetMouseLocation()

			if isDragging then
				local delta = currentMouse - dragStartMouse
				local screen = OverlayGui.AbsoluteSize
				if screen.X <= 0 or screen.Y <= 0 then
					local c = workspace.CurrentCamera
					screen = (c and c.ViewportSize) or Vector2.new(1920, 1080)
				end

				local frameSize = MainFrame.AbsoluteSize
				local minX, maxX = 0, math.max(0, screen.X - frameSize.X)
				local minY, maxY = 0, math.max(0, screen.Y - frameSize.Y)

				targetPos = Vector2.new(
					math.clamp(startFramePos.X + delta.X, minX, maxX),
					math.clamp(startFramePos.Y + delta.Y, minY, maxY)
				)

			elseif isResizing then
				local delta = currentMouse - resizeStartMouse
				local screen = OverlayGui.AbsoluteSize
				if screen.X <= 0 or screen.Y <= 0 then
					local c = workspace.CurrentCamera
					screen = (c and c.ViewportSize) or Vector2.new(1920, 1080)
				end

				local curPos = Vector2.new(MainFrame.Position.X.Offset, MainFrame.Position.Y.Offset)
				local maxW = math.max(480, screen.X - curPos.X)
				local maxH = math.max(320, screen.Y - curPos.Y)

				MainFrame.Size = UDim2.new(
					0, math.clamp(startFrameSize.X + delta.X, 480, maxW),
					0, math.clamp(startFrameSize.Y + delta.Y, 320, maxH)
				)
			end
		end
	end)

	RunService.RenderStepped:Connect(function(dt)
		if isDestroying then return end
		local cur = Vector2.new(MainFrame.Position.X.Offset, MainFrame.Position.Y.Offset)
		if (cur - targetPos).Magnitude > 0.4 then
			local factor = math.clamp(dt * 26, 0, 1)
			local nextPos = cur:Lerp(targetPos, factor)
			MainFrame.Position = UDim2.new(0, math.round(nextPos.X), 0, math.round(nextPos.Y))
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = false
			isResizing = false
		end
	end)

	local WindowObj = {
		Tabs = {},
		Sections = {},
	}

	function WindowObj:CreateSection(secConfig)
		local title = secConfig.Title or "Section"
		local rawIcon = secConfig.Icon
		local iconAsset = resolveAsset(rawIcon)

		local SectionFrame = Instance.new("Frame")
		SectionFrame.Name = title .. "_Section"
		SectionFrame.Size = UDim2.new(1, 0, 0, 32)
		SectionFrame.BackgroundTransparency = 1
		SectionFrame.ClipsDescendants = true
		SectionFrame.Parent = NavScroll

		local HeaderBtn = Instance.new("TextButton")
		HeaderBtn.Name = "HeaderBtn"
		HeaderBtn.Size = UDim2.new(1, 0, 0, 32)
		HeaderBtn.BackgroundTransparency = 1
		HeaderBtn.Text = ""
		HeaderBtn.AutoButtonColor = false
		HeaderBtn.Parent = SectionFrame

		local textStart = 10
		local IconImg = nil
		if iconAsset and iconAsset ~= "" then
			IconImg = Instance.new("ImageLabel")
			IconImg.Name = "TitleIcon"
			IconImg.Size = UDim2.new(0, 16, 0, 16)
			IconImg.Position = UDim2.new(0, 8, 0.5, -8)
			IconImg.BackgroundTransparency = 1
			IconImg.Image = iconAsset
			IconImg.ImageColor3 = Color3.fromRGB(150, 150, 160)
			IconImg.Parent = HeaderBtn
			registerFade(IconImg, "ImageTransparency", 0)
			textStart = 30
		end

		local TitleLabel = Instance.new("TextLabel")
		TitleLabel.Name = "TitleLabel"
		TitleLabel.Size = UDim2.new(1, -(textStart + 28), 1, 0)
		TitleLabel.Position = UDim2.new(0, textStart, 0, 0)
		TitleLabel.BackgroundTransparency = 1
		TitleLabel.Font = Enum.Font.GothamMedium
		TitleLabel.Text = title
		TitleLabel.TextSize = 13
		TitleLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		TitleLabel.Parent = HeaderBtn
		registerFade(TitleLabel, "TextTransparency", 0)

		-- Шеврон: -90° смотрит строго вправо (>), 0° смотрит строго вниз (v)
		local ArrowImg = Instance.new("ImageLabel")
		ArrowImg.Name = "Arrow"
		ArrowImg.Size = UDim2.new(0, 14, 0, 14)
		ArrowImg.Position = UDim2.new(1, -22, 0.5, -7)
		ArrowImg.BackgroundTransparency = 1
		ArrowImg.Image = "rbxassetid://10709790948"
		ArrowImg.ImageColor3 = Color3.fromRGB(120, 120, 135)
		ArrowImg.Rotation = -90
		ArrowImg.Parent = HeaderBtn
		registerFade(ArrowImg, "ImageTransparency", 0)

		local SubContent = Instance.new("Frame")
		SubContent.Name = "SubContent"
		SubContent.Size = UDim2.new(1, 0, 0, 0)
		SubContent.Position = UDim2.new(0, 0, 0, 34)
		SubContent.BackgroundTransparency = 1
		SubContent.Parent = SectionFrame

		-- Базовая серая линия дерева
		local TreeLine = Instance.new("Frame")
		TreeLine.Name = "TreeLine"
		TreeLine.Size = UDim2.new(0, 1, 0, 0)
		TreeLine.Position = UDim2.new(0, 16, 0, 0)
		TreeLine.BackgroundColor3 = Color3.fromRGB(50, 52, 65)
		TreeLine.BorderSizePixel = 0
		TreeLine.Parent = SubContent
		registerFade(TreeLine, "BackgroundTransparency", 0)

		-- Белая активная полоса (строго до выбранного пункта)
		local ActiveTreeLine = Instance.new("Frame")
		ActiveTreeLine.Name = "ActiveTreeLine"
		ActiveTreeLine.Size = UDim2.new(0, 1, 0, 0)
		ActiveTreeLine.Position = UDim2.new(0, 16, 0, 0)
		ActiveTreeLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ActiveTreeLine.BorderSizePixel = 0
		ActiveTreeLine.ZIndex = 2
		ActiveTreeLine.Parent = SubContent
		registerFade(ActiveTreeLine, "BackgroundTransparency", 0)

		local SubItems = Instance.new("Frame")
		SubItems.Name = "SubItems"
		SubItems.Size = UDim2.new(1, 0, 1, 0)
		SubItems.BackgroundTransparency = 1
		SubItems.Parent = SubContent

		local SubLayout = Instance.new("UIListLayout")
		SubLayout.SortOrder = Enum.SortOrder.LayoutOrder
		SubLayout.Padding = UDim.new(0, 4)
		SubLayout.Parent = SubItems

		local SectionObj = {
			IsOpen = false,
			Items = {},
			HasActiveChild = false,
			TreeLine = TreeLine,
			ActiveTreeLine = ActiveTreeLine,
			ArrowImg = ArrowImg,
			HeaderBtn = HeaderBtn,
			TitleLabel = TitleLabel,
			IconImg = IconImg
		}

		function SectionObj:UpdateVisuals()
			if self.HasActiveChild then
				TweenService:Create(TitleLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				TweenService:Create(ArrowImg, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				if IconImg then
					TweenService:Create(IconImg, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				end
			else
				TweenService:Create(TitleLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 160)}):Play()
				TweenService:Create(ArrowImg, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(120, 120, 135)}):Play()
				TweenService:Create(ActiveTreeLine, TweenInfo.new(0.2), {Size = UDim2.new(0, 1, 0, 0)}):Play()
				if IconImg then
					TweenService:Create(IconImg, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(150, 150, 160)}):Play()
				end
			end
		end

		HeaderBtn.MouseEnter:Connect(function()
			if not SectionObj.HasActiveChild then
				TweenService:Create(TitleLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(220, 220, 230)}):Play()
				TweenService:Create(ArrowImg, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(200, 200, 215)}):Play()
				if IconImg then
					TweenService:Create(IconImg, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(220, 220, 230)}):Play()
				end
			end
		end)

		HeaderBtn.MouseLeave:Connect(function()
			SectionObj:UpdateVisuals()
		end)

		local function recalcDimensions()
			local count = #SectionObj.Items
			local subH = count * 26 + math.max(0, count - 1) * 4
			SubContent.Size = UDim2.new(1, 0, 0, subH)
			TreeLine.Size = UDim2.new(0, 1, 0, math.max(0, subH - 13))

			if SectionObj.IsOpen then
				SectionFrame.Size = UDim2.new(1, 0, 0, 34 + subH + 4)
			else
				SectionFrame.Size = UDim2.new(1, 0, 0, 32)
			end
		end

		function SectionObj:Toggle()
			self.IsOpen = not self.IsOpen
			local rot = self.IsOpen and 0 or -90
			local count = #self.Items
			local subH = count * 26 + math.max(0, count - 1) * 4
			local totalH = self.IsOpen and (34 + subH + 4) or 32

			TweenService:Create(ArrowImg, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = rot}):Play()
			TweenService:Create(SectionFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = UDim2.new(1, 0, 0, totalH)
			}):Play()
		end

		HeaderBtn.MouseButton1Click:Connect(function()
			SectionObj:Toggle()
		end)

		function SectionObj:CreateItem(itemConfig)
			local itemTitle = itemConfig.Title or "SubItem"
			local itemAsset = resolveAsset(itemConfig.Icon)

			local itemIndex = #SectionObj.Items + 1

			local ItemWrapper = Instance.new("Frame")
			ItemWrapper.Name = itemTitle .. "_Wrapper"
			ItemWrapper.Size = UDim2.new(1, 0, 0, 26)
			ItemWrapper.BackgroundTransparency = 1
			ItemWrapper.Parent = SubItems

			local Branch = Instance.new("Frame")
			Branch.Name = "Branch"
			Branch.Size = UDim2.new(0, 12, 0, 1)
			Branch.Position = UDim2.new(0, 16, 0.5, 0)
			Branch.BackgroundColor3 = Color3.fromRGB(50, 52, 65)
			Branch.BorderSizePixel = 0
			Branch.Parent = ItemWrapper
			registerFade(Branch, "BackgroundTransparency", 0)

			local ItemBtn = Instance.new("TextButton")
			ItemBtn.Name = "Btn"
			ItemBtn.Size = UDim2.new(1, -30, 1, 0)
			ItemBtn.Position = UDim2.new(0, 28, 0, 0)
			ItemBtn.BackgroundTransparency = 1
			ItemBtn.Text = ""
			ItemBtn.AutoButtonColor = false
			ItemBtn.Parent = ItemWrapper

			local subOffset = 6
			local SubIconImg = nil
			if itemAsset and itemAsset ~= "" then
				SubIconImg = Instance.new("ImageLabel")
				SubIconImg.Name = "SubIcon"
				SubIconImg.Size = UDim2.new(0, 14, 0, 14)
				SubIconImg.Position = UDim2.new(0, 4, 0.5, -7)
				SubIconImg.BackgroundTransparency = 1
				SubIconImg.Image = itemAsset
				SubIconImg.ImageColor3 = Color3.fromRGB(130, 135, 145)
				SubIconImg.Parent = ItemBtn
				registerFade(SubIconImg, "ImageTransparency", 0)
				subOffset = 22
			end

			local SubLabel = Instance.new("TextLabel")
			SubLabel.Name = "SubLabel"
			SubLabel.Size = UDim2.new(1, -subOffset, 1, 0)
			SubLabel.Position = UDim2.new(0, subOffset, 0, 0)
			SubLabel.BackgroundTransparency = 1
			SubLabel.Font = Enum.Font.Gotham
			SubLabel.Text = itemTitle
			SubLabel.TextSize = 12
			SubLabel.TextColor3 = Color3.fromRGB(130, 135, 145)
			SubLabel.TextXAlignment = Enum.TextXAlignment.Left
			SubLabel.Parent = ItemBtn
			registerFade(SubLabel, "TextTransparency", 0)

			local Page = Instance.new("ScrollingFrame")
			Page.Name = itemTitle .. "_Page"
			Page.Size = UDim2.new(1, 0, 1, 0)
			Page.BackgroundTransparency = 1
			Page.BorderSizePixel = 0
			Page.ScrollBarThickness = 2
			Page.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 65)
			Page.Visible = false
			Page.Parent = ContentContainer

			local TabInfo = {
				Btn = ItemBtn,
				Label = SubLabel,
				Branch = Branch,
				Icon = SubIconImg,
				Page = Page,
				ParentSection = SectionObj,
				Index = itemIndex,
				IsSelected = false
			}

			ItemBtn.MouseEnter:Connect(function()
				if not TabInfo.IsSelected then
					TweenService:Create(SubLabel, TweenInfo.new(0.18), {TextColor3 = Color3.fromRGB(210, 210, 220)}):Play()
					TweenService:Create(Branch, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(200, 200, 215)}):Play()
					if SubIconImg then
						TweenService:Create(SubIconImg, TweenInfo.new(0.18), {ImageColor3 = Color3.fromRGB(210, 210, 220)}):Play()
					end
				end
			end)

			ItemBtn.MouseLeave:Connect(function()
				if not TabInfo.IsSelected then
					TweenService:Create(SubLabel, TweenInfo.new(0.18), {TextColor3 = Color3.fromRGB(130, 135, 145)}):Play()
					TweenService:Create(Branch, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(50, 52, 65)}):Play()
					if SubIconImg then
						TweenService:Create(SubIconImg, TweenInfo.new(0.18), {ImageColor3 = Color3.fromRGB(130, 135, 145)}):Play()
					end
				end
			end)

			local function selectTab()
				for _, tab in ipairs(WindowObj.Tabs) do
					tab.IsSelected = false
					tab.Page.Visible = false
					TweenService:Create(tab.Label, TweenInfo.new(0.18), {TextColor3 = Color3.fromRGB(130, 135, 145)}):Play()
					TweenService:Create(tab.Branch, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(50, 52, 65)}):Play()
					if tab.Icon then
						TweenService:Create(tab.Icon, TweenInfo.new(0.18), {ImageColor3 = Color3.fromRGB(130, 135, 145)}):Play()
					end
					tab.ParentSection.HasActiveChild = false
					tab.ParentSection:UpdateVisuals()
				end

				TabInfo.IsSelected = true
				Page.Visible = true

				-- Белая подсветка выбранного пункта и его ветки
				TweenService:Create(SubLabel, TweenInfo.new(0.18), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				TweenService:Create(Branch, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				if SubIconImg then
					TweenService:Create(SubIconImg, TweenInfo.new(0.18), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				end

				-- Белая полоса дерева идет только до выбранного подпункта
				local activeHeight = (TabInfo.Index - 1) * (26 + 4) + 13
				TweenService:Create(ActiveTreeLine, TweenInfo.new(0.2), {Size = UDim2.new(0, 1, 0, activeHeight)}):Play()

				SectionObj.HasActiveChild = true
				SectionObj:UpdateVisuals()

				if not SectionObj.IsOpen then
					SectionObj:Toggle()
				end
			end

			ItemBtn.MouseButton1Click:Connect(selectTab)

			table.insert(SectionObj.Items, TabInfo)
			table.insert(WindowObj.Tabs, TabInfo)

			recalcDimensions()
			return Page
		end

		table.insert(WindowObj.Sections, SectionObj)
		return SectionObj
	end

	return WindowObj
end

return Library
