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
	if type(assetInput) == "number" or not assetInput:find("://") then
		local num = tostring(assetInput):gsub("%D", "")
		if #num > 0 then
			return "rbxassetid://" .. num
		end
	end
	if assetInput:find("^rbxassetid://") then
		return assetInput
	end
	-- Загрузка внешней картинки (GitHub / Web URL) через функции эксплойта
	if assetInput:find("^http://") or assetInput:find("^https://") then
		local getcustomasset = getcustomasset or getsynasset
		local request = (syn and syn.request) or (http and http.request) or http_request or request
		if getcustomasset and request and writefile and isfile then
			local fileName = "custom_asset_" .. string.sub(HttpService:GenerateGUID(false), 1, 8) .. ".png"
			if not isfile(fileName) then
				local resp = request({Url = assetInput, Method = "GET"})
				if resp and resp.Body then
					writefile(fileName, resp.Body)
				end
			end
			if isfile(fileName) then
				return getcustomasset(fileName)
			end
		end
	end
	return assetInput
end

function Library:CreateWindow(config)
	config = config or {}
	local titleText = config.Title or "Dashboard"

	local LocalPlayer = Players.LocalPlayer
	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

	local BlurEffect = Instance.new("BlurEffect")
	BlurEffect.Name = "GuiBlur"
	BlurEffect.Size = 12
	BlurEffect.Enabled = true
	BlurEffect.Parent = Lighting

	local OverlayGui = Instance.new("ScreenGui")
	OverlayGui.Name = "OverlayGui"
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
	MainFrame.Size = UDim2.new(0, 850, 0, 520)

	local camera = workspace.CurrentCamera
	local initView = (camera and camera.ViewportSize) or Vector2.new(1920, 1080)
	local initX = math.max(0, math.floor((initView.X - 850) / 2))
	local initY = math.max(0, math.floor((initView.Y - 520) / 2))
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

	-- Сайдбар
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 175, 1, -12)
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

	-- Скролл-контейнер для категорий сайдбара
	local NavScroll = Instance.new("ScrollingFrame")
	NavScroll.Name = "NavScroll"
	NavScroll.Size = UDim2.new(1, -12, 1, -72)
	NavScroll.Position = UDim2.new(0, 6, 0, 10)
	NavScroll.BackgroundTransparency = 1
	NavScroll.BorderSizePixel = 0
	NavScroll.ScrollBarThickness = 2
	NavScroll.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
	NavScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	NavScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	NavScroll.Parent = Sidebar

	local NavLayout = Instance.new("UIListLayout")
	NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NavLayout.Padding = UDim.new(0, 6)
	NavLayout.Parent = NavScroll

	-- Профиль внизу сайдбара
	local ProfilePanel = Instance.new("Frame")
	ProfilePanel.Name = "ProfilePanel"
	ProfilePanel.Size = UDim2.new(1, -8, 0, 48)
	ProfilePanel.Position = UDim2.new(0, 4, 1, -52)
	ProfilePanel.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
	ProfilePanel.BorderSizePixel = 0
	ProfilePanel.Parent = Sidebar

	local ProfileCorner = Instance.new("UICorner")
	ProfileCorner.CornerRadius = UDim.new(0, 6)
	ProfileCorner.Parent = ProfilePanel

	local ProfileStroke = Instance.new("UIStroke")
	ProfileStroke.Color = Color3.fromRGB(30, 30, 35)
	ProfileStroke.Thickness = 1
	ProfileStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ProfileStroke.Parent = ProfilePanel

	local AvatarHolder = Instance.new("Frame")
	AvatarHolder.Size = UDim2.new(0, 36, 0, 36)
	AvatarHolder.Position = UDim2.new(0, 6, 0.5, -18)
	AvatarHolder.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	AvatarHolder.ClipsDescendants = true
	AvatarHolder.BorderSizePixel = 0
	AvatarHolder.Parent = ProfilePanel

	local AvatarCorner = Instance.new("UICorner")
	AvatarCorner.CornerRadius = UDim.new(0, 18)
	AvatarCorner.Parent = AvatarHolder

	local AvatarImage = Instance.new("ImageLabel")
	AvatarImage.Size = UDim2.new(1, 0, 1, 0)
	AvatarImage.BackgroundTransparency = 1
	AvatarImage.Parent = AvatarHolder

	task.spawn(function()
		local ok, thumb = pcall(function()
			return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if ok then AvatarImage.Image = thumb end
	end)

	local HelloText = Instance.new("TextLabel")
	HelloText.Size = UDim2.new(1, -52, 0, 14)
	HelloText.Position = UDim2.new(0, 48, 0.5, -14)
	HelloText.BackgroundTransparency = 1
	HelloText.Font = Enum.Font.GothamMedium
	HelloText.Text = "Hello,"
	HelloText.TextSize = 11
	HelloText.TextColor3 = Color3.fromRGB(150, 150, 155)
	HelloText.TextXAlignment = Enum.TextXAlignment.Left
	HelloText.Parent = ProfilePanel

	local NicknameText = Instance.new("TextLabel")
	NicknameText.Size = UDim2.new(1, -52, 0, 16)
	NicknameText.Position = UDim2.new(0, 48, 0.5, 0)
	NicknameText.BackgroundTransparency = 1
	NicknameText.Font = Enum.Font.GothamBold
	NicknameText.Text = LocalPlayer.DisplayName
	NicknameText.TextSize = 13
	NicknameText.TextColor3 = Color3.fromRGB(255, 255, 255)
	NicknameText.TextXAlignment = Enum.TextXAlignment.Left
	NicknameText.TextTruncate = Enum.TextTruncate.AtEnd
	NicknameText.Parent = ProfilePanel

	-- Верхняя панель справа
	local TopRightContainer = Instance.new("Frame")
	TopRightContainer.Size = UDim2.new(0, 150, 0, 30)
	TopRightContainer.Position = UDim2.new(1, -165, 0, 14)
	TopRightContainer.BackgroundTransparency = 1
	TopRightContainer.Parent = MainFrame

	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 12)
	UIListLayout.Parent = TopRightContainer

	local function setupHover(button, defaultColor, hoverColor)
		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {ImageColor3 = hoverColor}):Play()
		end)
		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {ImageColor3 = defaultColor}):Play()
		end)
	end

	local SettingsBtn = Instance.new("ImageButton")
	SettingsBtn.Size = UDim2.new(0, 20, 0, 20)
	SettingsBtn.BackgroundTransparency = 1
	SettingsBtn.Image = "rbxassetid://106205298246017"
	SettingsBtn.ImageColor3 = Color3.fromRGB(150, 150, 155)
	SettingsBtn.Parent = TopRightContainer
	setupHover(SettingsBtn, Color3.fromRGB(150, 150, 155), Color3.fromRGB(255, 255, 255))

	local Divider = Instance.new("Frame")
	Divider.Size = UDim2.new(0, 1, 0, 14)
	Divider.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	Divider.BorderSizePixel = 0
	Divider.Parent = TopRightContainer

	local CloseBtn = Instance.new("ImageButton")
	CloseBtn.Size = UDim2.new(0, 20, 0, 20)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Image = "rbxassetid://116396312853810"
	CloseBtn.ImageColor3 = Color3.fromRGB(180, 180, 185)
	CloseBtn.Parent = TopRightContainer
	setupHover(CloseBtn, Color3.fromRGB(180, 180, 185), Color3.fromRGB(255, 255, 255))

	local ResizeBtn = Instance.new("ImageButton")
	ResizeBtn.Size = UDim2.new(0, 16, 0, 16)
	ResizeBtn.Position = UDim2.new(1, -20, 1, -20)
	ResizeBtn.BackgroundTransparency = 1
	ResizeBtn.Image = "rbxassetid://128492050787735"
	ResizeBtn.ImageColor3 = Color3.fromRGB(120, 120, 125)
	ResizeBtn.Parent = MainFrame
	setupHover(ResizeBtn, Color3.fromRGB(120, 120, 125), Color3.fromRGB(255, 255, 255))

	-- Область страниц контента
	local ContentContainer = Instance.new("Frame")
	ContentContainer.Name = "ContentContainer"
	ContentContainer.Size = UDim2.new(1, -195, 1, -54)
	ContentContainer.Position = UDim2.new(0, 188, 0, 46)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Parent = MainFrame

	-- Логика скрытия / анимации
	local isGuiOpen = true
	local isAnimating = false
	local animInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function toggleGui()
		if isAnimating then return end
		isAnimating = true
		isGuiOpen = not isGuiOpen

		if isGuiOpen then
			MainFrame.Visible = true
			BlackOverlay.Visible = true
			BlurEffect.Enabled = true
			TweenService:Create(MainFrame, animInfo, {BackgroundTransparency = 0}):Play()
			TweenService:Create(BlackOverlay, animInfo, {BackgroundTransparency = 0.5}):Play()
			local tBlur = TweenService:Create(BlurEffect, animInfo, {Size = 12})
			tBlur.Completed:Connect(function() isAnimating = false end)
			tBlur:Play()
		else
			TweenService:Create(MainFrame, animInfo, {BackgroundTransparency = 1}):Play()
			TweenService:Create(BlackOverlay, animInfo, {BackgroundTransparency = 1}):Play()
			local tBlur = TweenService:Create(BlurEffect, animInfo, {Size = 0})
			tBlur.Completed:Connect(function()
				MainFrame.Visible = false
				BlackOverlay.Visible = false
				BlurEffect.Enabled = false
				isAnimating = false
			end)
			tBlur:Play()
		end
	end

	local function shatterAndDestroy()
		BlurEffect:Destroy()
		OverlayGui:Destroy()
	end
	CloseBtn.MouseButton1Click:Connect(shatterAndDestroy)

	UserInputService.InputBegan:Connect(function(input, gp)
		if input.KeyCode == Enum.KeyCode.LeftAlt and not gp then
			toggleGui()
		end
	end)

	-- Перетаскивание и изменение размера
	local isDragging = false
	local dragStartMouse, startFramePos = Vector2.new(), Vector2.new()
	local targetPos = Vector2.new(initX, initY)
	local isResizing = false
	local resizeStartMouse, startFrameSize = Vector2.new(), Vector2.new()

	local function isOverInteractive(pos)
		local trP, trS = TopRightContainer.AbsolutePosition, TopRightContainer.AbsoluteSize
		if pos.X >= trP.X and pos.X <= trP.X + trS.X and pos.Y >= trP.Y and pos.Y <= trP.Y + trS.Y then return true end
		local rbP, rbS = ResizeBtn.AbsolutePosition, ResizeBtn.AbsoluteSize
		if pos.X >= rbP.X and pos.X <= rbP.X + rbS.X and pos.Y >= rbP.Y and pos.Y <= rbP.Y + rbS.Y then return true end
		local sbP, sbS = Sidebar.AbsolutePosition, Sidebar.AbsoluteSize
		if pos.X >= sbP.X and pos.X <= sbP.X + sbS.X and pos.Y >= sbP.Y and pos.Y <= sbP.Y + sbS.Y then return true end
		return false
	end

	MainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if isResizing then return end
			local mouse = UserInputService:GetMouseLocation()
			if isOverInteractive(mouse) then return end
			isDragging = true
			dragStartMouse = mouse
			startFramePos = Vector2.new(MainFrame.Position.X.Offset, MainFrame.Position.Y.Offset)
			targetPos = startFramePos
		end
	end)

	ResizeBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isResizing = true
			isDragging = false
			resizeStartMouse = UserInputService:GetMouseLocation()
			startFrameSize = Vector2.new(MainFrame.AbsoluteSize.X, MainFrame.AbsoluteSize.Y)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local mouse = UserInputService:GetMouseLocation()
			if isDragging then
				local delta = mouse - dragStartMouse
				targetPos = startFramePos + delta
			elseif isResizing then
				local delta = mouse - resizeStartMouse
				MainFrame.Size = UDim2.new(0, math.clamp(startFrameSize.X + delta.X, 450, 1600), 0, math.clamp(startFrameSize.Y + delta.Y, 300, 1000))
			end
		end
	end)

	RunService.RenderStepped:Connect(function(dt)
		local cur = Vector2.new(MainFrame.Position.X.Offset, MainFrame.Position.Y.Offset)
		if (cur - targetPos).Magnitude > 0.5 then
			local nextPos = cur:Lerp(targetPos, math.clamp(dt * 26, 0, 1))
			MainFrame.Position = UDim2.new(0, math.round(nextPos.X), 0, math.round(nextPos.Y))
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = false
			isResizing = false
		end
	end)

	-- Менеджер окон и секций
	local WindowObj = {
		ActiveSection = nil,
		ActiveTab = nil,
		Tabs = {},
		Sections = {},
	}

	function WindowObj:CreateSection(secConfig)
		local secTitle = secConfig.Title or "Category"
		local secIcon = resolveAsset(secConfig.Icon or "101007429951147")

		local SectionContainer = Instance.new("Frame")
		SectionContainer.Name = secTitle .. "_Container"
		SectionContainer.Size = UDim2.new(1, 0, 0, 32)
		SectionContainer.BackgroundTransparency = 1
		SectionContainer.ClipsDescendants = true
		SectionContainer.Parent = NavScroll

		-- Кнопка титула секции
		local TitleBtn = Instance.new("TextButton")
		TitleBtn.Name = "TitleBtn"
		TitleBtn.Size = UDim2.new(1, 0, 0, 32)
		TitleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
		TitleBtn.BackgroundTransparency = 1
		TitleBtn.Text = ""
		TitleBtn.AutoButtonColor = false
		TitleBtn.Parent = SectionContainer

		local TitleCorner = Instance.new("UICorner")
		TitleCorner.CornerRadius = UDim.new(0, 6)
		TitleCorner.Parent = TitleBtn

		local TitleStroke = Instance.new("UIStroke")
		TitleStroke.Color = Color3.fromRGB(70, 70, 95)
		TitleStroke.Thickness = 1
		TitleStroke.Transparency = 1
		TitleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		TitleStroke.Parent = TitleBtn

		-- Иконка титула
		local IconImg = Instance.new("ImageLabel")
		IconImg.Name = "Icon"
		IconImg.Size = UDim2.new(0, 16, 0, 16)
		IconImg.Position = UDim2.new(0, 8, 0.5, -8)
		IconImg.BackgroundTransparency = 1
		IconImg.Image = secIcon
		IconImg.ImageColor3 = Color3.fromRGB(150, 150, 160)
		IconImg.Parent = TitleBtn

		-- Текст титула
		local Label = Instance.new("TextLabel")
		Label.Name = "Label"
		Label.Size = UDim2.new(1, -54, 1, 0)
		Label.Position = UDim2.new(0, 30, 0, 0)
		Label.BackgroundTransparency = 1
		Label.Font = Enum.Font.GothamMedium
		Label.Text = secTitle
		Label.TextSize = 13
		Label.TextColor3 = Color3.fromRGB(160, 160, 165)
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = TitleBtn

		-- Стрелка аккордеона
		local Arrow = Instance.new("ImageLabel")
		Arrow.Name = "Arrow"
		Arrow.Size = UDim2.new(0, 14, 0, 14)
		Arrow.Position = UDim2.new(1, -20, 0.5, -7)
		Arrow.BackgroundTransparency = 1
		Arrow.Image = "rbxassetid://10709790948" -- Иконка шеврона/стрелки вправо
		Arrow.ImageColor3 = Color3.fromRGB(120, 120, 130)
		Arrow.Rotation = 0
		Arrow.Parent = TitleBtn

		-- Контейнер подпунктов (древо)
		local SubItemsFrame = Instance.new("Frame")
		SubItemsFrame.Name = "SubItems"
		SubItemsFrame.Size = UDim2.new(1, 0, 0, 0)
		SubItemsFrame.Position = UDim2.new(0, 0, 0, 34)
		SubItemsFrame.BackgroundTransparency = 1
		SubItemsFrame.Parent = SectionContainer

		-- Вертикальная линия дерева (Stem)
		local TreeLine = Instance.new("Frame")
		TreeLine.Name = "TreeLine"
		TreeLine.Size = UDim2.new(0, 1, 1, -12)
		TreeLine.Position = UDim2.new(0, 16, 0, 2)
		TreeLine.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		TreeLine.BorderSizePixel = 0
		TreeLine.Parent = SubItemsFrame

		local SubLayout = Instance.new("UIListLayout")
		SubLayout.SortOrder = Enum.SortOrder.LayoutOrder
		SubLayout.Padding = UDim.new(0, 4)
		SubLayout.Parent = SubItemsFrame

		local SectionObj = {
			IsOpen = false,
			ItemsCount = 0,
			Container = SectionContainer,
			SubFrame = SubItemsFrame,
			SubLayout = SubLayout,
			TitleBtn = TitleBtn,
			TitleStroke = TitleStroke,
			Label = Label,
			Icon = IconImg,
			Arrow = Arrow,
			HasActiveChild = false
		}

		local function updateHighlight()
			if SectionObj.HasActiveChild then
				TweenService:Create(TitleBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.8}):Play()
				TweenService:Create(TitleStroke, TweenInfo.new(0.2), {Transparency = 0.3}):Play()
				TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				TweenService:Create(IconImg, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			else
				TweenService:Create(TitleBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
				TweenService:Create(TitleStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
				TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(160, 160, 165)}):Play()
				TweenService:Create(IconImg, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(150, 150, 160)}):Play()
			end
		end

		function SectionObj:Toggle()
			self.IsOpen = not self.IsOpen
			local targetRot = self.IsOpen and 90 or 0
			local subHeight = self.SubLayout.AbsoluteContentSize.Y + 6
			local targetHeight = self.IsOpen and (36 + subHeight) or 32

			TweenService:Create(self.Arrow, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Rotation = targetRot}):Play()
			TweenService:Create(self.Container, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
				Size = UDim2.new(1, 0, 0, targetHeight)
			}):Play()
		end

		TitleBtn.MouseButton1Click:Connect(function()
			SectionObj:Toggle()
		end)

		function SectionObj:CreateItem(itemConfig)
			local itemTitle = itemConfig.Title or "Item"
			local itemIcon = resolveAsset(itemConfig.Icon or "")

			SectionObj.ItemsCount = SectionObj.ItemsCount + 1

			local ItemBtn = Instance.new("TextButton")
			ItemBtn.Name = itemTitle .. "_Btn"
			ItemBtn.Size = UDim2.new(1, -26, 0, 24)
			ItemBtn.Position = UDim2.new(0, 26, 0, 0)
			ItemBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
			ItemBtn.BackgroundTransparency = 1
			ItemBtn.Text = ""
			ItemBtn.AutoButtonColor = false
			ItemBtn.Parent = SubItemsFrame

			local ItemCorner = Instance.new("UICorner")
			ItemCorner.CornerRadius = UDim.new(0, 4)
			ItemCorner.Parent = ItemBtn

			-- Горизонтальный отвод дерева к подпункту
			local BranchLine = Instance.new("Frame")
			BranchLine.Name = "Branch"
			BranchLine.Size = UDim2.new(0, 10, 0, 1)
			BranchLine.Position = UDim2.new(0, -10, 0.5, 0)
			BranchLine.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			BranchLine.BorderSizePixel = 0
			BranchLine.Parent = ItemBtn

			local offset = 6
			if itemIcon ~= "" then
				local SubIcon = Instance.new("ImageLabel")
				SubIcon.Name = "SubIcon"
				SubIcon.Size = UDim2.new(0, 14, 0, 14)
				SubIcon.Position = UDim2.new(0, offset, 0.5, -7)
				SubIcon.BackgroundTransparency = 1
				SubIcon.Image = itemIcon
				SubIcon.ImageColor3 = Color3.fromRGB(140, 140, 150)
				SubIcon.Parent = ItemBtn
				offset = offset + 18
			end

			local SubLabel = Instance.new("TextLabel")
			SubLabel.Name = "SubLabel"
			SubLabel.Size = UDim2.new(1, -offset - 4, 1, 0)
			SubLabel.Position = UDim2.new(0, offset, 0, 0)
			SubLabel.BackgroundTransparency = 1
			SubLabel.Font = Enum.Font.Gotham
			SubLabel.Text = itemTitle
			SubLabel.TextSize = 12
			SubLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
			SubLabel.TextXAlignment = Enum.TextXAlignment.Left
			SubLabel.Parent = ItemBtn

			-- Создание страницы для подпункта
			local Page = Instance.new("ScrollingFrame")
			Page.Name = itemTitle .. "_Page"
			Page.Size = UDim2.new(1, 0, 1, 0)
			Page.BackgroundTransparency = 1
			Page.BorderSizePixel = 0
			Page.ScrollBarThickness = 2
			Page.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 55)
			Page.Visible = false
			Page.Parent = ContentContainer

			local TabData = {
				Button = ItemBtn,
				Label = SubLabel,
				Branch = BranchLine,
				Page = Page,
				ParentSection = SectionObj
			}

			local function selectThisTab()
				for _, tab in ipairs(WindowObj.Tabs) do
					tab.Page.Visible = false
					TweenService:Create(tab.Button, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
					TweenService:Create(tab.Label, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(140, 140, 150)}):Play()
					TweenService:Create(tab.Branch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}):Play()
					tab.ParentSection.HasActiveChild = false
					updateHighlight()
				end

				Page.Visible = true
				TweenService:Create(ItemBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
				TweenService:Create(SubLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				TweenService:Create(BranchLine, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(90, 120, 255)}):Play()

				SectionObj.HasActiveChild = true
				updateHighlight()

				if not SectionObj.IsOpen then
					SectionObj:Toggle()
				end
			end

			ItemBtn.MouseButton1Click:Connect(selectThisTab)
			table.insert(WindowObj.Tabs, TabData)

			-- Автоматический выбор первого созданного элемента
			if #WindowObj.Tabs == 1 then
				selectThisTab()
			end

			return Page
		end

		table.insert(WindowObj.Sections, SectionObj)
		return SectionObj
	end

	return WindowObj
end

return Library