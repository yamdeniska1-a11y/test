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

	local HeaderDrag = Instance.new("TextButton")
	HeaderDrag.Name = "HeaderDrag"
	HeaderDrag.Size = UDim2.new(1, -385, 0, 48)
	HeaderDrag.Position = UDim2.new(0, 215, 0, 0)
	HeaderDrag.BackgroundTransparency = 1
	HeaderDrag.Text = ""
	HeaderDrag.AutoButtonColor = false
	HeaderDrag.ZIndex = 5
	HeaderDrag.Parent = MainFrame

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

	-- ================= ПРОФИЛЬ =================
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
	AvatarHolder.ClipsDescendants = true -- Аватарка теперь не вылезает
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
		button.MouseEnter:Connect(function() TweenService:Create(button, TweenInfo.new(0.2), {ImageColor3 = hovCol}):Play() end)
		button.MouseLeave:Connect(function() TweenService:Create(button, TweenInfo.new(0.2), {ImageColor3 = defCol}):Play() end)
	end

	local CloseBtn = Instance.new("ImageButton")
	CloseBtn.Name = "CloseBtn"
	CloseBtn.Size = UDim2.new(0, 20, 0, 20)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Image = "rbxassetid://116396312853810"
	CloseBtn.ImageColor3 = Color3.fromRGB(180, 180, 185)
	CloseBtn.Parent = TopRightContainer
	setupHover(CloseBtn, Color3.fromRGB(180, 180, 185), Color3.fromRGB(255, 255, 255))

	local ContentContainer = Instance.new("Frame")
	ContentContainer.Name = "ContentContainer"
	ContentContainer.Size = UDim2.new(1, -228, 1, -54)
	ContentContainer.Position = UDim2.new(0, 218, 0, 46)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Parent = MainFrame

	local PanelsContainer = Instance.new("Frame")
	PanelsContainer.Name = "PanelsContainer"
	PanelsContainer.Size = UDim2.new(1, 0, 1, 0)
	PanelsContainer.BackgroundTransparency = 1
	PanelsContainer.Parent = ContentContainer

	local FadeElements = {}
	local function registerFade(obj, prop, defVal)
		table.insert(FadeElements, {obj = obj, prop = prop, default = defVal})
	end

	local isDestroying = false
	CloseBtn.MouseButton1Click:Connect(function()
		if isDestroying then return end
		isDestroying = true
		OverlayGui:Destroy()
		BlurEffect:Destroy()
	end)

	-- Drag & Resize
	local isDragging, isResizing = false, false
	local dragStartMouse, startFramePos = Vector2.new(), Vector2.new()
	local targetPos = Vector2.new(initX, initY)

	HeaderDrag.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			dragStartMouse = UserInputService:GetMouseLocation()
			startFramePos = Vector2.new(MainFrame.Position.X.Offset, MainFrame.Position.Y.Offset)
			targetPos = startFramePos
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = UserInputService:GetMouseLocation() - dragStartMouse
			targetPos = Vector2.new(startFramePos.X + delta.X, startFramePos.Y + delta.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = false
		end
	end)

	RunService.RenderStepped:Connect(function(dt)
		if isDragging then
			local cur = Vector2.new(MainFrame.Position.X.Offset, MainFrame.Position.Y.Offset)
			MainFrame.Position = UDim2.new(0, math.round(cur:Lerp(targetPos, math.clamp(dt * 26, 0, 1)).X), 0, math.round(cur:Lerp(targetPos, math.clamp(dt * 26, 0, 1)).Y))
		end
	end)

	local WindowObj = { Tabs = {}, Sections = {}, Panels = {} }

	-- ================= ВОЗВРАЩАЕМ ДЕРЕВО САЙДБАРА =================
	function WindowObj:CreateSection(secConfig)
		local title = secConfig.Title or "Section"
		local iconAsset = resolveAsset(secConfig.Icon)

		local SectionFrame = Instance.new("Frame")
		SectionFrame.Name = title .. "_Section"
		SectionFrame.Size = UDim2.new(1, 0, 0, 32)
		SectionFrame.BackgroundTransparency = 1
		SectionFrame.ClipsDescendants = true
		SectionFrame.Parent = NavScroll

		local HeaderBtn = Instance.new("TextButton")
		HeaderBtn.Size = UDim2.new(1, 0, 0, 32)
		HeaderBtn.BackgroundTransparency = 1
		HeaderBtn.Text = ""
		HeaderBtn.Parent = SectionFrame

		local IconImg = nil
		local textStart = 10
		if iconAsset ~= "" then
			IconImg = Instance.new("ImageLabel")
			IconImg.Size = UDim2.new(0, 16, 0, 16)
			IconImg.Position = UDim2.new(0, 8, 0.5, -8)
			IconImg.BackgroundTransparency = 1
			IconImg.Image = iconAsset
			IconImg.ImageColor3 = Color3.fromRGB(150, 150, 160)
			IconImg.Parent = HeaderBtn
			textStart = 30
		end

		local TitleLabel = Instance.new("TextLabel")
		TitleLabel.Size = UDim2.new(1, -(textStart + 28), 1, 0)
		TitleLabel.Position = UDim2.new(0, textStart, 0, 0)
		TitleLabel.BackgroundTransparency = 1
		TitleLabel.Font = Enum.Font.GothamMedium
		TitleLabel.Text = title
		TitleLabel.TextSize = 13
		TitleLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		TitleLabel.Parent = HeaderBtn

		local ArrowImg = Instance.new("ImageLabel")
		ArrowImg.Size = UDim2.new(0, 14, 0, 14)
		ArrowImg.Position = UDim2.new(1, -22, 0.5, -7)
		ArrowImg.BackgroundTransparency = 1
		ArrowImg.Image = "rbxassetid://10709790948"
		ArrowImg.ImageColor3 = Color3.fromRGB(120, 120, 135)
		ArrowImg.Rotation = -90
		ArrowImg.Parent = HeaderBtn

		local SubContent = Instance.new("Frame")
		SubContent.Size = UDim2.new(1, 0, 0, 0)
		SubContent.Position = UDim2.new(0, 0, 0, 34)
		SubContent.BackgroundTransparency = 1
		SubContent.Parent = SectionFrame

		local SubItems = Instance.new("Frame")
		SubItems.Size = UDim2.new(1, 0, 1, 0)
		SubItems.BackgroundTransparency = 1
		SubItems.Parent = SubContent
		Instance.new("UIListLayout", SubItems).Padding = UDim.new(0, 4)

		local SectionObj = {
			IsOpen = false,
			Items = {},
			TitleLabel = TitleLabel,
			ArrowImg = ArrowImg,
			IconImg = IconImg
		}

		function SectionObj:Toggle()
			self.IsOpen = not self.IsOpen
			local subH = #self.Items * 30
			TweenService:Create(ArrowImg, TweenInfo.new(0.2), {Rotation = self.IsOpen and 0 or -90}):Play()
			TweenService:Create(SectionFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, self.IsOpen and 34 + subH or 32)}):Play()
		end

		HeaderBtn.MouseButton1Click:Connect(function() SectionObj:Toggle() end)

		function SectionObj:CreateItem(itemConfig)
			local itemTitle = itemConfig.Title or "Item"
			local itemAsset = resolveAsset(itemConfig.Icon)

			local ItemWrapper = Instance.new("Frame")
			ItemWrapper.Size = UDim2.new(1, 0, 0, 26)
			ItemWrapper.BackgroundTransparency = 1
			ItemWrapper.Parent = SubItems

			local ItemBtn = Instance.new("TextButton")
			ItemBtn.Size = UDim2.new(1, -30, 1, 0)
			ItemBtn.Position = UDim2.new(0, 28, 0, 0)
			ItemBtn.BackgroundTransparency = 1
			ItemBtn.Text = ""
			ItemBtn.Parent = ItemWrapper

			local SubLabel = Instance.new("TextLabel")
			SubLabel.Size = UDim2.new(1, 0, 1, 0)
			SubLabel.Position = UDim2.new(0, 6, 0, 0)
			SubLabel.BackgroundTransparency = 1
			SubLabel.Font = Enum.Font.Gotham
			SubLabel.Text = itemTitle
			SubLabel.TextSize = 12
			SubLabel.TextColor3 = Color3.fromRGB(130, 135, 145)
			SubLabel.TextXAlignment = Enum.TextXAlignment.Left
			SubLabel.Parent = ItemBtn

			local TabInfo = { Btn = ItemBtn, Label = SubLabel, ParentSection = SectionObj }

			ItemBtn.MouseEnter:Connect(function()
				TweenService:Create(SubLabel, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(210, 210, 220)}):Play()
			end)
			ItemBtn.MouseLeave:Connect(function()
				if not TabInfo.IsSelected then
					TweenService:Create(SubLabel, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(130, 135, 145)}):Play()
				end
			end)

			function TabInfo:Select()
				for _, tab in pairs(WindowObj.Tabs) do
					tab.IsSelected = false
					TweenService:Create(tab.Label, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(130, 135, 145)}):Play()
				end
				self.IsSelected = true
				TweenService:Create(SubLabel, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			end

			table.insert(SectionObj.Items, TabInfo)
			table.insert(WindowObj.Tabs, TabInfo)
			return TabInfo
		end

		table.insert(WindowObj.Sections, SectionObj)
		return SectionObj
	end

	-- ================= ОКНА (ПАНЕЛИ С ВКЛАДКАМИ) =================
	function WindowObj:CreatePanel(panelConfig)
		local title = panelConfig.Title or "Window"
		local PanelFrame = Instance.new("Frame")
		PanelFrame.Size = UDim2.new(1, 0, 1, 0)
		PanelFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 19)
		PanelFrame.BorderSizePixel = 0
		PanelFrame.Visible = false
		PanelFrame.Parent = PanelsContainer
		Instance.new("UICorner", PanelFrame).CornerRadius = UDim.new(0, 8)
		Instance.new("UIStroke", PanelFrame).Color = Color3.fromRGB(40, 40, 48)

		local HeaderTitle = Instance.new("TextLabel")
		HeaderTitle.Size = UDim2.new(1, -20, 0, 34)
		HeaderTitle.Position = UDim2.new(0, 12, 0, 0)
		HeaderTitle.BackgroundTransparency = 1
		HeaderTitle.Font = Enum.Font.GothamBold
		HeaderTitle.Text = title
		HeaderTitle.TextSize = 14
		HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
		HeaderTitle.Parent = PanelFrame

		local SubTabBar = Instance.new("Frame")
		SubTabBar.Size = UDim2.new(1, -16, 0, 28)
		SubTabBar.Position = UDim2.new(0, 8, 0, 34)
		SubTabBar.BackgroundTransparency = 1
		SubTabBar.Parent = PanelFrame
		Instance.new("UIListLayout", SubTabBar).FillDirection = Enum.FillDirection.Horizontal

		local PanelScroll = Instance.new("ScrollingFrame")
		PanelScroll.Size = UDim2.new(1, -16, 1, -72)
		PanelScroll.Position = UDim2.new(0, 8, 0, 66)
		PanelScroll.BackgroundTransparency = 1
		PanelScroll.BorderSizePixel = 0
		PanelScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		PanelScroll.Parent = PanelFrame

		local PanelInfo = { Frame = PanelFrame, SubTabs = {} }

		function PanelInfo:Show()
			for _, p in pairs(WindowObj.Panels) do p.Frame.Visible = false end
			self.Frame.Visible = true
		end

		function PanelInfo:AddTab(tabName)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(0, 80, 1, 0)
			btn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
			btn.Text = tabName
			btn.TextColor3 = Color3.fromRGB(150, 150, 160)
			btn.Parent = SubTabBar
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

			local tabPage = Instance.new("ScrollingFrame")
			tabPage.Size = UDim2.new(1, 0, 1, 0)
			tabPage.BackgroundTransparency = 1
			tabPage.Visible = false
			tabPage.Parent = PanelScroll
			Instance.new("UIListLayout", tabPage).Padding = UDim.new(0, 6)

			btn.MouseButton1Click:Connect(function()
				for _, t in pairs(self.SubTabs) do
					t.Page.Visible = false
					t.Btn.TextColor3 = Color3.fromRGB(150, 150, 160)
				end
				tabPage.Visible = true
				btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			end)

			table.insert(self.SubTabs, { Btn = btn, Page = tabPage })
			if #self.SubTabs == 1 then btn.MouseButton1Click:Fire() end
			return tabPage
		end

		function PanelInfo:AddToggle(parentPage, cfg)
			local state = cfg.Default or false
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 30)
			row.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
			row.Parent = parentPage
			Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
			
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, -40, 1, 0)
			lbl.Position = UDim2.new(0, 10, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = cfg.Title
			lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Parent = row

			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 1, 0)
			btn.BackgroundTransparency = 1
			btn.Text = ""
			btn.Parent = row
			btn.MouseButton1Click:Connect(function()
				state = not state
				if cfg.Callback then cfg.Callback(state) end
			end)
		end

		function PanelInfo:AddButton(parentPage, cfg)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 30)
			btn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
			btn.Text = cfg.Title
			btn.TextColor3 = Color3.fromRGB(220, 220, 230)
			btn.Parent = parentPage
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
			btn.MouseButton1Click:Connect(function() if cfg.Callback then cfg.Callback() end end)
		end

		table.insert(WindowObj.Panels, PanelInfo)
		return PanelInfo
	end

	return WindowObj
end
return Library
