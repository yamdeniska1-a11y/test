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
	AvatarHolder.ClipsDescendants = true -- ИСПРАВЛЕНИЕ: аватарка больше не вылезает
	AvatarHolder.BorderSizePixel = 0
	AvatarHolder.Parent = Profile

	local AvatarCorner = Instance.new("UICorner")
	AvatarCorner.CornerRadius = UDim.new(0, 19) -- Круглая аватарка
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
		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {ImageColor3 = hovCol}):Play()
		end)
		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {ImageColor3 = defCol}):Play()
		end)
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

	-- Контейнер для окон (панелей)
	local PanelsContainer = Instance.new("Frame")
	PanelsContainer.Name = "PanelsContainer"
	PanelsContainer.Size = UDim2.new(1, 0, 1, 0)
	PanelsContainer.BackgroundTransparency = 1
	PanelsContainer.ClipsDescendants = true
	PanelsContainer.Parent = ContentContainer

	local isDestroying = false
	CloseBtn.MouseButton1Click:Connect(function()
		if isDestroying then return end
		isDestroying = true
		OverlayGui:Destroy()
		BlurEffect:Destroy()
	end)

	local WindowObj = {
		Panels = {},
		CurrentPanel = nil,
	}

	-- ================= СОЗДАНИЕ ПАНЕЛИ (ОКНА) =================
	function WindowObj:CreatePanel(panelConfig)
		panelConfig = panelConfig or {}
		local title = panelConfig.Title or "Window"

		local PanelFrame = Instance.new("Frame")
		PanelFrame.Name = title .. "_Panel"
		PanelFrame.Size = UDim2.new(1, 0, 1, 0)
		PanelFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 19)
		PanelFrame.BorderSizePixel = 0
		PanelFrame.Visible = false
		PanelFrame.Parent = PanelsContainer

		local PanelCorner = Instance.new("UICorner")
		PanelCorner.CornerRadius = UDim.new(0, 8)
		PanelCorner.Parent = PanelFrame

		local PanelStroke = Instance.new("UIStroke")
		PanelStroke.Color = Color3.fromRGB(40, 40, 48)
		PanelStroke.Thickness = 1
		PanelStroke.Parent = PanelFrame

		-- Заголовок окна (сверху слева)
		local PanelHeader = Instance.new("Frame")
		PanelHeader.Name = "Header"
		PanelHeader.Size = UDim2.new(1, 0, 0, 34)
		PanelHeader.BackgroundTransparency = 1
		PanelHeader.Parent = PanelFrame

		local HeaderTitle = Instance.new("TextLabel")
		HeaderTitle.Size = UDim2.new(1, -20, 1, 0)
		HeaderTitle.Position = UDim2.new(0, 12, 0, 0)
		HeaderTitle.BackgroundTransparency = 1
		HeaderTitle.Font = Enum.Font.GothamBold
		HeaderTitle.Text = title
		HeaderTitle.TextSize = 14
		HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
		HeaderTitle.Parent = PanelHeader

		local HeaderLine = Instance.new("Frame")
		HeaderLine.Size = UDim2.new(1, -24, 0, 1)
		HeaderLine.Position = UDim2.new(0, 12, 1, -1)
		HeaderLine.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
		HeaderLine.BorderSizePixel = 0
		HeaderLine.Parent = PanelFrame

		-- Вкладки внутри панели (Sub-Tabs)
		local SubTabBar = Instance.new("Frame")
		SubTabBar.Name = "SubTabBar"
		SubTabBar.Size = UDim2.new(1, -16, 0, 28)
		SubTabBar.Position = UDim2.new(0, 8, 0, 38)
		SubTabBar.BackgroundTransparency = 1
		SubTabBar.Parent = PanelFrame

		local SubTabList = Instance.new("UIListLayout")
		SubTabList.FillDirection = Enum.FillDirection.Horizontal
		SubTabList.SortOrder = Enum.SortOrder.LayoutOrder
		SubTabList.Padding = UDim.new(0, 6)
		SubTabList.Parent = SubTabBar

		local PanelScroll = Instance.new("ScrollingFrame")
		PanelScroll.Name = "Scroll"
		PanelScroll.Size = UDim2.new(1, -16, 1, -76)
		PanelScroll.Position = UDim2.new(0, 8, 0, 70)
		PanelScroll.BackgroundTransparency = 1
		PanelScroll.BorderSizePixel = 0
		PanelScroll.ScrollBarThickness = 2
		PanelScroll.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 65)
		PanelScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		PanelScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		PanelScroll.Parent = PanelFrame

		local PanelLayout = Instance.new("UIListLayout")
		PanelLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PanelLayout.Padding = UDim.new(0, 6)
		PanelLayout.Parent = PanelScroll

		local PanelInfo = {
			Frame = PanelFrame,
			Scroll = PanelScroll,
			IsVisible = false,
			SubTabs = {},
		}

		function PanelInfo:Show()
			for _, p in pairs(WindowObj.Panels) do
				p.Frame.Visible = false
				p.IsVisible = false
			end
			self.Frame.Visible = true
			self.IsVisible = true
			WindowObj.CurrentPanel = self
		end

		-- ДОБАВЛЕНИЕ ПОД-ВКЛАДОК (например, 4 штуки для ESP)
		function PanelInfo:AddTab(tabName)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(0, 70, 1, 0)
			btn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
			btn.BorderSizePixel = 0
			btn.Font = Enum.Font.GothamMedium
			btn.Text = tabName
			btn.TextSize = 12
			btn.TextColor3 = Color3.fromRGB(150, 150, 160)
			btn.AutoButtonColor = false
			btn.Parent = SubTabBar

			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(0, 4)
			c.Parent = btn

			local tabPage = Instance.new("ScrollingFrame")
			tabPage.Size = UDim2.new(1, 0, 1, 0)
			tabPage.BackgroundTransparency = 1
			tabPage.BorderSizePixel = 0
			tabPage.ScrollBarThickness = 2
			tabPage.Visible = false
			tabPage.Parent = PanelScroll
			
			local pageLayout = Instance.new("UIListLayout")
			pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
			pageLayout.Padding = UDim.new(0, 6)
			pageLayout.Parent = tabPage

			local tabData = { Btn = btn, Page = tabPage, IsSelected = false }

			btn.MouseButton1Click:Connect(function()
				for _, t in pairs(self.SubTabs) do
					t.Page.Visible = false
					t.Btn.TextColor3 = Color3.fromRGB(150, 150, 160)
					TweenService:Create(t.Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(24, 24, 28)}):Play()
				end
				tabData.Page.Visible = true
				btn.TextColor3 = Color3.fromRGB(255, 255, 255)
				TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
			end)

			table.insert(self.SubTabs, tabData)
			
			-- Автоматически открываем первую вкладку
			if #self.SubTabs == 1 then
				btn.MouseButton1Click:Fire()
			end

			return tabData.Page -- Возвращаем страницу, чтобы вешать элементы
		end

		-- Элементы (упрощенные, вешаются на Page)
		function PanelInfo:AddToggle(parentPage, cfg)
			local state = cfg.Default or false
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 30)
			row.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
			row.BorderSizePixel = 0
			row.Parent = parentPage
			Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, -50, 1, 0)
			lbl.Position = UDim2.new(0, 10, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Font = Enum.Font.Gotham
			lbl.Text = cfg.Title
			lbl.TextSize = 12
			lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Parent = row

			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 1, 0)
			btn.BackgroundTransparency = 1
			btn.Text = ""
			btn.Parent = row

			local ind = Instance.new("Frame")
			ind.Size = UDim2.new(0, 16, 0, 16)
			ind.Position = UDim2.new(1, -26, 0.5, -8)
			ind.BackgroundColor3 = state and Color3.fromRGB(80, 170, 255) or Color3.fromRGB(50, 50, 60)
			ind.Parent = row
			Instance.new("UICorner", ind).CornerRadius = UDim.new(0, 4)

			btn.MouseButton1Click:Connect(function()
				state = not state
				ind.BackgroundColor3 = state and Color3.fromRGB(80, 170, 255) or Color3.fromRGB(50, 50, 60)
				if cfg.Callback then cfg.Callback(state) end
			end)
		end

		function PanelInfo:AddButton(parentPage, cfg)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 30)
			btn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
			btn.BorderSizePixel = 0
			btn.Font = Enum.Font.GothamMedium
			btn.Text = cfg.Title
			btn.TextSize = 12
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
