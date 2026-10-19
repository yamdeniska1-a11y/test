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

	-- Безопасная загрузка внешней веб-картинки (GitHub/URL)
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
	
	return "rbxassetid://101007429951147"
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
	MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true
	MainFrame.Active = true
	MainFrame.Parent = OverlayGui

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 12)
	MainCorner.Parent = MainFrame

	local MainStroke = Instance.new("UIStroke")
	MainStroke.Color = Color3.fromRGB(32, 32, 38)
	MainStroke.Thickness = 1
	MainStroke.Parent = MainFrame

	-- Сайдбар
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 195, 1, -12)
	Sidebar.Position = UDim2.new(0, 6, 0, 6)
	Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = MainFrame

	local SidebarCorner = Instance.new("UICorner")
	SidebarCorner.CornerRadius = UDim.new(0, 10)
	SidebarCorner.Parent = Sidebar

	local SidebarStroke = Instance.new("UIStroke")
	SidebarStroke.Color = Color3.fromRGB(38, 38, 46)
	SidebarStroke.Thickness = 1
	SidebarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	SidebarStroke.Parent = Sidebar

	local NavScroll = Instance.new("ScrollingFrame")
	NavScroll.Name = "NavScroll"
	NavScroll.Size = UDim2.new(1, -8, 1, -68)
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
	Profile.Name = "Profile"
	Profile.Size = UDim2.new(1, -8, 0, 48)
	Profile.Position = UDim2.new(0, 4, 1, -52)
	Profile.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
	Profile.BorderSizePixel = 0
	Profile.Parent = Sidebar

	local ProfCorner = Instance.new("UICorner")
	ProfCorner.CornerRadius = UDim.new(0, 8)
	ProfCorner.Parent = Profile

	local ProfStroke = Instance.new("UIStroke")
	ProfStroke.Color = Color3.fromRGB(32, 32, 38)
	ProfStroke.Thickness = 1
	ProfStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ProfStroke.Parent = Profile

	local AvHolder = Instance.new("Frame")
	AvHolder.Size = UDim2.new(0, 34, 0, 34)
	AvHolder.Position = UDim2.new(0, 7, 0.5, -17)
	AvHolder.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
	AvHolder.ClipsDescendants = true
	AvHolder.BorderSizePixel = 0
	AvHolder.Parent = Profile

	local AvCorner = Instance.new("UICorner")
	AvCorner.CornerRadius = UDim.new(0, 17)
	AvCorner.Parent = AvHolder

	local AvImg = Instance.new("ImageLabel")
	AvImg.Size = UDim2.new(1, 0, 1, 0)
	AvImg.BackgroundTransparency = 1
	AvImg.Parent = AvHolder

	task.spawn(function()
		local s, thumb = pcall(function()
			return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if s then AvImg.Image = thumb end
	end)

	local HiTxt = Instance.new("TextLabel")
	HiTxt.Size = UDim2.new(1, -52, 0, 13)
	HiTxt.Position = UDim2.new(0, 48, 0.5, -14)
	HiTxt.BackgroundTransparency = 1
	HiTxt.Font = Enum.Font.GothamMedium
	HiTxt.Text = "Hello,"
	HiTxt.TextSize = 11
	HiTxt.TextColor3 = Color3.fromRGB(140, 140, 150)
	HiTxt.TextXAlignment = Enum.TextXAlignment.Left
	HiTxt.Parent = Profile

	local NickTxt = Instance.new("TextLabel")
	NickTxt.Size = UDim2.new(1, -52, 0, 16)
	NickTxt.Position = UDim2.new(0, 48, 0.5, 0)
	NickTxt.BackgroundTransparency = 1
	NickTxt.Font = Enum.Font.GothamBold
	NickTxt.Text = LocalPlayer.DisplayName
	NickTxt.TextSize = 13
	NickTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
	NickTxt.TextXAlignment = Enum.TextXAlignment.Left
	NickTxt.TextTruncate = Enum.TextTruncate.AtEnd
	NickTxt.Parent = Profile

	-- Контейнер для вкладок
	local ContentContainer = Instance.new("Frame")
	ContentContainer.Name = "ContentContainer"
	ContentContainer.Size = UDim2.new(1, -218, 1, -54)
	ContentContainer.Position = UDim2.new(0, 208, 0, 46)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Parent = MainFrame

	local CloseBtn = Instance.new("ImageButton")
	CloseBtn.Size = UDim2.new(0, 18, 0, 18)
	CloseBtn.Position = UDim2.new(1, -28, 0, 14)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Image = "rbxassetid://116396312853810"
	CloseBtn.ImageColor3 = Color3.fromRGB(160, 160, 170)
	CloseBtn.Parent = MainFrame
	CloseBtn.MouseButton1Click:Connect(function()
		BlurEffect:Destroy()
		OverlayGui:Destroy()
	end)

	local ResizeBtn = Instance.new("ImageButton")
	ResizeBtn.Size = UDim2.new(0, 16, 0, 16)
	ResizeBtn.Position = UDim2.new(1, -20, 1, -20)
	ResizeBtn.BackgroundTransparency = 1
	ResizeBtn.Image = "rbxassetid://128492050787735"
	ResizeBtn.ImageColor3 = Color3.fromRGB(120, 120, 130)
	ResizeBtn.Parent = MainFrame

	-- Перемещение и изменение размера
	local isDragging, isResizing = false, false
	local dragStart, startPos = Vector2.new(), Vector2.new()
	local targetPos = Vector2.new(initX, initY)
	local resizeStart, startSize = Vector2.new(), Vector2.new()

	MainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local mouse = UserInputService:GetMouseLocation()
			local sbPos, sbSize = Sidebar.AbsolutePosition, Sidebar.AbsoluteSize
			if mouse.X >= sbPos.X and mouse.X <= sbPos.X + sbSize.X and mouse.Y >= sbPos.Y and mouse.Y <= sbPos.Y + sbSize.Y then
				return
			end
			isDragging = true
			dragStart = mouse
			startPos = Vector2.new(MainFrame.Position.X.Offset, MainFrame.Position.Y.Offset)
			targetPos = startPos
		end
	end)

	ResizeBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isResizing = true
			resizeStart = UserInputService:GetMouseLocation()
			startSize = Vector2.new(MainFrame.AbsoluteSize.X, MainFrame.AbsoluteSize.Y)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local mouse = UserInputService:GetMouseLocation()
			if isDragging then
				local delta = mouse - dragStart
				targetPos = startPos + delta
			elseif isResizing then
				local delta = mouse - resizeStart
				MainFrame.Size = UDim2.new(0, math.clamp(startSize.X + delta.X, 480, 1600), 0, math.clamp(startSize.Y + delta.Y, 320, 1000))
			end
		end
	end)

	RunService.RenderStepped:Connect(function(dt)
		local cur = Vector2.new(MainFrame.Position.X.Offset, MainFrame.Position.Y.Offset)
		if (cur - targetPos).Magnitude > 0.5 then
			local nPos = cur:Lerp(targetPos, math.clamp(dt * 26, 0, 1))
			MainFrame.Position = UDim2.new(0, math.round(nPos.X), 0, math.round(nPos.Y))
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
			isResizing = false
		end
	end)

	local isGuiOpen = true
	UserInputService.InputBegan:Connect(function(input, gp)
		if input.KeyCode == Enum.KeyCode.LeftAlt and not gp then
			isGuiOpen = not isGuiOpen
			MainFrame.Visible = isGuiOpen
			BlackOverlay.Visible = isGuiOpen
			BlurEffect.Enabled = isGuiOpen
		end
	end)

	local WindowObj = {
		Tabs = {},
		Sections = {},
	}

	function WindowObj:CreateSection(secConfig)
		local title = secConfig.Title or "Section"
		local iconAsset = resolveAsset(secConfig.Icon)

		local SectionFrame = Instance.new("Frame")
		SectionFrame.Name = title .. "_Section"
		SectionFrame.Size = UDim2.new(1, 0, 0, 34)
		SectionFrame.BackgroundTransparency = 1
		SectionFrame.ClipsDescendants = true
		SectionFrame.Parent = NavScroll

		local HeaderBtn = Instance.new("TextButton")
		HeaderBtn.Name = "HeaderBtn"
		HeaderBtn.Size = UDim2.new(1, 0, 0, 34)
		HeaderBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
		HeaderBtn.BackgroundTransparency = 1
		HeaderBtn.Text = ""
		HeaderBtn.AutoButtonColor = false
		HeaderBtn.Parent = SectionFrame

		local HeaderCorner = Instance.new("UICorner")
		HeaderCorner.CornerRadius = UDim.new(0, 6)
		HeaderCorner.Parent = HeaderBtn

		local HeaderStroke = Instance.new("UIStroke")
		HeaderStroke.Color = Color3.fromRGB(70, 75, 110)
		HeaderStroke.Thickness = 1
		HeaderStroke.Transparency = 1
		HeaderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		HeaderStroke.Parent = HeaderBtn

		local textOffset = 10
		local IconImg = nil
		if iconAsset and iconAsset ~= "" then
			IconImg = Instance.new("ImageLabel")
			IconImg.Name = "TitleIcon"
			IconImg.Size = UDim2.new(0, 16, 0, 16)
			IconImg.Position = UDim2.new(0, 10, 0.5, -8)
			IconImg.BackgroundTransparency = 1
			IconImg.Image = iconAsset
			IconImg.ImageColor3 = Color3.fromRGB(160, 160, 175)
			IconImg.Parent = HeaderBtn
			textOffset = 32
		end

		local TitleLabel = Instance.new("TextLabel")
		TitleLabel.Name = "TitleLabel"
		TitleLabel.Size = UDim2.new(1, -(textOffset + 28), 1, 0)
		TitleLabel.Position = UDim2.new(0, textOffset, 0, 0)
		TitleLabel.BackgroundTransparency = 1
		TitleLabel.Font = Enum.Font.GothamMedium
		TitleLabel.Text = title
		TitleLabel.TextSize = 13
		TitleLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		TitleLabel.Parent = HeaderBtn

		-- Стрелка аккордеона справа
		local ArrowImg = Instance.new("ImageLabel")
		ArrowImg.Name = "Arrow"
		ArrowImg.Size = UDim2.new(0, 14, 0, 14)
		ArrowImg.Position = UDim2.new(1, -22, 0.5, -7)
		ArrowImg.BackgroundTransparency = 1
		ArrowImg.Image = "rbxassetid://10709790948"
		ArrowImg.ImageColor3 = Color3.fromRGB(120, 120, 130)
		ArrowImg.Rotation = 0
		ArrowImg.Parent = HeaderBtn

		local SubContainer = Instance.new("Frame")
		SubContainer.Name = "SubContainer"
		SubContainer.Size = UDim2.new(1, 0, 0, 0)
		SubContainer.Position = UDim2.new(0, 0, 0, 36)
		SubContainer.BackgroundTransparency = 1
		SubContainer.ClipsDescendants = false
		SubContainer.Parent = SectionFrame

		-- Вертикальная линия ствола дерева
		local TreeStem = Instance.new("Frame")
		TreeStem.Name = "TreeStem"
		TreeStem.Size = UDim2.new(0, 1, 0, 0)
		TreeStem.Position = UDim2.new(0, 17, 0, 0)
		TreeStem.BackgroundColor3 = Color3.fromRGB(50, 52, 65)
		TreeStem.BorderSizePixel = 0
		TreeStem.Parent = SubContainer

		local SubList = Instance.new("UIListLayout")
		SubList.SortOrder = Enum.SortOrder.LayoutOrder
		SubList.Padding = UDim.new(0, 3)
		SubList.Parent = SubContainer

		local SectionObj = {
			IsOpen = false,
			Items = {},
			HasActiveChild = false
		}

		local function refreshSectionVisuals()
			if SectionObj.HasActiveChild then
				TweenService:Create(HeaderBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.82}):Play()
				TweenService:Create(HeaderStroke, TweenInfo.new(0.2), {Transparency = 0.2}):Play()
				TweenService:Create(TitleLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				if IconImg then
					TweenService:Create(IconImg, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				end
			else
				TweenService:Create(HeaderBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
				TweenService:Create(HeaderStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
				TweenService:Create(TitleLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(160, 160, 170)}):Play()
				if IconImg then
					TweenService:Create(IconImg, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(160, 160, 175)}):Play()
				end
			end
		end

		local function updateTreeLines()
			local count = #SectionObj.Items
			if count > 0 then
				local stemHeight = (count - 1) * (26 + 3) + 13
				TreeStem.Size = UDim2.new(0, 1, 0, stemHeight)
			end
		end

		function SectionObj:Toggle()
			self.IsOpen = not self.IsOpen
			local rot = self.IsOpen and 90 or 0
			local count = #self.Items
			local subH = count * 26 + (math.max(0, count - 1) * 3)
			local totalH = self.IsOpen and (38 + subH + 4) or 34

			TweenService:Create(ArrowImg, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Rotation = rot}):Play()
			TweenService:Create(SectionFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
				Size = UDim2.new(1, 0, 0, totalH)
			}):Play()
		end

		HeaderBtn.MouseButton1Click:Connect(function()
			SectionObj:Toggle()
		end)

		function SectionObj:CreateItem(itemConfig)
			local itemTitle = itemConfig.Title or "SubItem"
			local itemAsset = resolveAsset(itemConfig.Icon)

			local ItemBtn = Instance.new("TextButton")
			ItemBtn.Name = itemTitle .. "_Btn"
			ItemBtn.Size = UDim2.new(1, -30, 0, 26)
			ItemBtn.Position = UDim2.new(0, 30, 0, 0)
			ItemBtn.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
			ItemBtn.BackgroundTransparency = 1
			ItemBtn.Text = ""
			ItemBtn.AutoButtonColor = false
			ItemBtn.Parent = SubContainer

			local ItemCorner = Instance.new("UICorner")
			ItemCorner.CornerRadius = UDim.new(0, 5)
			ItemCorner.Parent = ItemBtn

			-- Горизонтальная веточка дерева
			local Branch = Instance.new("Frame")
			Branch.Name = "Branch"
			Branch.Size = UDim2.new(0, 13, 0, 1)
			Branch.Position = UDim2.new(0, -13, 0.5, 0)
			Branch.BackgroundColor3 = Color3.fromRGB(50, 52, 65)
			Branch.BorderSizePixel = 0
			Branch.Parent = ItemBtn

			local subOffset = 8
			local SubIconImg = nil
			if itemAsset and itemAsset ~= "" then
				SubIconImg = Instance.new("ImageLabel")
				SubIconImg.Name = "SubIcon"
				SubIconImg.Size = UDim2.new(0, 14, 0, 14)
				SubIconImg.Position = UDim2.new(0, 6, 0.5, -7)
				SubIconImg.BackgroundTransparency = 1
				SubIconImg.Image = itemAsset
				SubIconImg.ImageColor3 = Color3.fromRGB(130, 135, 148)
				SubIconImg.Parent = ItemBtn
				subOffset = 26
			end

			local SubLabel = Instance.new("TextLabel")
			SubLabel.Name = "SubLabel"
			SubLabel.Size = UDim2.new(1, -subOffset, 1, 0)
			SubLabel.Position = UDim2.new(0, subOffset, 0, 0)
			SubLabel.BackgroundTransparency = 1
			SubLabel.Font = Enum.Font.Gotham
			SubLabel.Text = itemTitle
			SubLabel.TextSize = 12
			SubLabel.TextColor3 = Color3.fromRGB(130, 135, 148)
			SubLabel.TextXAlignment = Enum.TextXAlignment.Left
			SubLabel.Parent = ItemBtn

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
				ParentSection = SectionObj
			}

			local function selectTab()
				for _, tab in ipairs(WindowObj.Tabs) do
					tab.Page.Visible = false
					TweenService:Create(tab.Btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
					TweenService:Create(tab.Label, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(130, 135, 148)}):Play()
					TweenService:Create(tab.Branch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 52, 65)}):Play()
					if tab.Icon then
						TweenService:Create(tab.Icon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(130, 135, 148)}):Play()
					end
					tab.ParentSection.HasActiveChild = false
					tab.ParentSection:Refresh()
				end

				Page.Visible = true
				TweenService:Create(ItemBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.6}):Play()
				TweenService:Create(SubLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				TweenService:Create(Branch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 130, 255)}):Play()
				if SubIconImg then
					TweenService:Create(SubIconImg, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				end

				SectionObj.HasActiveChild = true
				SectionObj:Refresh()

				if not SectionObj.IsOpen then
					SectionObj:Toggle()
				end
			end

			ItemBtn.MouseButton1Click:Connect(selectTab)

			table.insert(SectionObj.Items, TabInfo)
			table.insert(WindowObj.Tabs, TabInfo)

			updateTreeLines()

			if #WindowObj.Tabs == 1 then
				selectTab()
			end

			return Page
		end

		function SectionObj:Refresh()
			refreshSectionVisuals()
		end

		table.insert(WindowObj.Sections, SectionObj)
		return SectionObj
	end

	return WindowObj
end

-- =========================================================================
-- ЗАПУСК И ИНИЦИАЛИЗАЦИЯ ИНТЕРФЕЙСА (С 6 ПОДПУНКТАМИ VISUAL И ВСЕМИ РАЗДЕЛАМИ)
-- =========================================================================

local Window = Library:CreateWindow()

-- VISUAL (6 мини-текстов)
local VisualSection = Window:CreateSection({
	Title = "Visual",
	Icon = "101007429951147"
})
local EspPage       = VisualSection:CreateItem({ Title = "esp",       Icon = "101007429951147" })
local ChamsPage     = VisualSection:CreateItem({ Title = "chams",     Icon = "" })
local TracersPage   = VisualSection:CreateItem({ Title = "tracers",   Icon = "" })
local BoxesPage     = VisualSection:CreateItem({ Title = "boxes",     Icon = "" })
local SkeletonPage  = VisualSection:CreateItem({ Title = "skeleton",  Icon = "" })
local OffscreenPage = VisualSection:CreateItem({ Title = "offscreen", Icon = "" })

-- PLAYER
local PlayerSection = Window:CreateSection({
	Title = "Player",
	Icon = "106205298246017"
})
local SpeedPage  = PlayerSection:CreateItem({ Title = "speed",     Icon = "" })
local JumpPage   = PlayerSection:CreateItem({ Title = "high jump", Icon = "" })
local FlyPage    = PlayerSection:CreateItem({ Title = "fly",       Icon = "" })
local NoclipPage = PlayerSection:CreateItem({ Title = "noclip",    Icon = "" })

-- WORLD
local WorldSection = Window:CreateSection({
	Title = "World",
	Icon = "127866486547434"
})
local AmbientPage = WorldSection:CreateItem({ Title = "ambient",      Icon = "" })
local FogPage     = WorldSection:CreateItem({ Title = "fog remove",   Icon = "" })
local TimePage    = WorldSection:CreateItem({ Title = "time changer", Icon = "" })

-- SERVER
local ServerSection = Window:CreateSection({
	Title = "Server",
	Icon = "116396312853810"
})
local RejoinPage = ServerSection:CreateItem({ Title = "rejoin",     Icon = "" })
local HopPage    = ServerSection:CreateItem({ Title = "server hop", Icon = "" })

return Library
