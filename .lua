-- MaxHub Style Library (VRAIE VERSION FIDÈLE À L'IMAGE)
-- Style: MaxHub Free UI
-- Recréé pour correspondre exactement à la capture d'écran fournie

local library = {
	flags = {},
	items = {}
}

-- Services
local players        = game:GetService("Players")
local uis            = game:GetService("UserInputService")
local runservice     = game:GetService("RunService")
local tweenservice   = game:GetService("TweenService")
local textservice    = game:GetService("TextService")
local coregui        = game:GetService("CoreGui")
local httpservice    = game:GetService("HttpService")

local player = players.LocalPlayer
local mouse  = player:GetMouse()

-- ============================================================
-- THEME — MaxHub Free (Couleurs extraites de l'image)
-- ============================================================
library.theme = {
	font           = Enum.Font.GothamMedium,
	fontBold       = Enum.Font.GothamBold,
	fontsize       = 13,
	titlesize      = 14,

	-- Window & Backgrounds
	windowBg       = Color3.fromRGB(15, 17, 26),    -- Fond très sombre, bleuté
	sidebarBg      = Color3.fromRGB(20, 23, 34),    -- Sidebar légèrement plus claire
	contentBg      = Color3.fromRGB(15, 17, 26),    -- Même que window
	sectorBg       = Color3.fromRGB(22, 26, 38),    -- Cartes/Secteurs (Helper/Movement)
	
	-- Sidebar elements
	sidebarWidth   = 140,
	tabBg          = Color3.fromRGB(28, 32, 48),    -- Tab sélectionné
	tabHover       = Color3.fromRGB(24, 28, 42),
	tabActive      = Color3.fromRGB(28, 32, 48),
	tabActiveBar   = Color3.fromRGB(100, 130, 255), -- Accent bleu
	
	-- Text Colors
	textPrimary    = Color3.fromRGB(255, 255, 255), -- Blanc pur pour titres
	textSecondary  = Color3.fromRGB(130, 135, 155), -- Gris pour labels
	textAccent     = Color3.fromRGB(100, 130, 255), -- Bleu accent
	textLabel      = Color3.fromRGB(80, 85, 105),   -- Gris foncé (COMMON, MAIN, GLOBAL)

	-- Accent
	accent         = Color3.fromRGB(100, 130, 255),
	accentDark     = Color3.fromRGB(70, 90, 180),
	
	-- Elements
	toggleOff      = Color3.fromRGB(35, 40, 55),
	toggleOn       = Color3.fromRGB(100, 130, 255),
	sliderBg       = Color3.fromRGB(35, 40, 55),
	sliderFill     = Color3.fromRGB(100, 130, 255),
	buttonBg       = Color3.fromRGB(28, 32, 48),
	divider        = Color3.fromRGB(40, 45, 60),
	
	windowW        = 600,
	windowH        = 400,
	hidebutton     = Enum.KeyCode.RightShift,
}

-- ============================================================
-- HELPERS UI
-- ============================================================
local function makeTween(obj, props, t, style, dir)
	style = style or Enum.EasingStyle.Quart
	dir   = dir   or Enum.EasingDirection.Out
	return tweenservice:Create(obj, TweenInfo.new(t or 0.15, style, dir), props)
end

local function makeCorner(parent, radius)
	local c = Instance.new("UICorner", parent)
	c.CornerRadius = UDim.new(0, radius or 4)
	return c
end

local function makeStroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke", parent)
	s.Color       = color or Color3.fromRGB(50, 58, 82)
	s.Thickness   = thickness or 1
	s.Transparency = transparency or 0
	return s
end

-- ============================================================
-- CREATE WINDOW
-- ============================================================
function library:CreateWindow(name, size, hidebutton)
	local th = library.theme
	local window = {}
	window.name      = name or "MaxHub Free"
	window.hidekey   = hidebutton or th.hidebutton
	window.Tabs      = {}
	window.theme     = th

	-- ScreenGui
	window.Main = Instance.new("ScreenGui", coregui)
	window.Main.Name = "MaxHubUI"
	if getgenv().uilib then getgenv().uilib:Destroy() end
	getgenv().uilib = window.Main

	local W = (size and size.X) or th.windowW
	local H = (size and size.Y) or th.windowH

	-- Main frame
	window.Frame = Instance.new("Frame", window.Main)
	window.Frame.Size = UDim2.fromOffset(W, H)
	window.Frame.Position = UDim2.fromScale(0.5, 0.5)
	window.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	window.Frame.BackgroundColor3 = th.windowBg
	window.Frame.BorderSizePixel  = 0
	makeCorner(window.Frame, 6)
	makeStroke(window.Frame, Color3.fromRGB(255, 255, 255), 1, 0.8) -- Bordure blanche très fine/transparente comme sur l'image

	-- Sidebar
	window.Sidebar = Instance.new("Frame", window.Frame)
	window.Sidebar.Name = "Sidebar"
	window.Sidebar.Size = UDim2.new(0, th.sidebarWidth, 1, 0)
	window.Sidebar.BackgroundColor3 = th.sidebarBg
	window.Sidebar.BorderSizePixel  = 0
	makeCorner(window.Sidebar, 6)
	
	-- Sidebar Title
	local sideTitle = Instance.new("TextLabel", window.Sidebar)
	sideTitle.Size = UDim2.new(1, 0, 0, 40)
	sideTitle.Position = UDim2.fromOffset(15, 10)
	sideTitle.BackgroundTransparency = 1
	sideTitle.Font = th.fontBold
	sideTitle.TextSize = 16
	sideTitle.Text = window.name
	sideTitle.TextColor3 = th.textPrimary
	sideTitle.TextXAlignment = Enum.TextXAlignment.Left

	-- Sidebar Scroll
	window.TabContainer = Instance.new("ScrollingFrame", window.Sidebar)
	window.TabContainer.Size = UDim2.new(1, 0, 1, -50)
	window.TabContainer.Position = UDim2.fromOffset(0, 50)
	window.TabContainer.BackgroundTransparency = 1
	window.TabContainer.BorderSizePixel = 0
	window.TabContainer.ScrollBarThickness = 0
	
	local tabLayout = Instance.new("UIListLayout", window.TabContainer)
	tabLayout.Padding = UDim.new(0, 2)
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	-- Content Area
	window.ContentArea = Instance.new("Frame", window.Frame)
	window.ContentArea.Position = UDim2.fromOffset(th.sidebarWidth, 0)
	window.ContentArea.Size = UDim2.new(1, -th.sidebarWidth, 1, 0)
	window.ContentArea.BackgroundTransparency = 1

	-- Dragging
	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
	window.Sidebar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true ; dragStart = input.Position ; startPos = window.Frame.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	uis.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			window.Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- ============================================================
	-- SIDEBAR SECTIONS (COMMON, MAIN, GLOBAL)
	-- ============================================================
	function window:AddSidebarSection(text)
		local lbl = Instance.new("TextLabel", window.TabContainer)
		lbl.Size = UDim2.new(1, -20, 0, 25)
		lbl.BackgroundTransparency = 1
		lbl.Font = th.fontBold
		lbl.TextSize = 10
		lbl.Text = text:upper()
		lbl.TextColor3 = th.textLabel
		lbl.TextXAlignment = Enum.TextXAlignment.Left
	end

	-- ============================================================
	-- CREATE TAB
	-- ============================================================
	local firstTab = true
	function window:CreateTab(name, icon)
		local tab = { name = name }
		
		tab.TabBtn = Instance.new("TextButton", window.TabContainer)
		tab.TabBtn.Size = UDim2.new(1, -10, 0, 32)
		tab.TabBtn.BackgroundColor3 = th.tabActive
		tab.TabBtn.BackgroundTransparency = 1
		tab.TabBtn.BorderSizePixel = 0
		tab.TabBtn.Text = ""
		tab.TabBtn.AutoButtonColor = false
		makeCorner(tab.TabBtn, 4)

		local iconLabel = Instance.new("TextLabel", tab.TabBtn)
		iconLabel.Size = UDim2.fromOffset(30, 32)
		iconLabel.Position = UDim2.fromOffset(5, 0)
		iconLabel.BackgroundTransparency = 1
		iconLabel.Font = th.font
		iconLabel.TextSize = 14
		iconLabel.Text = icon or "•"
		iconLabel.TextColor3 = th.textSecondary

		local nameLabel = Instance.new("TextLabel", tab.TabBtn)
		nameLabel.Size = UDim2.new(1, -40, 1, 0)
		nameLabel.Position = UDim2.fromOffset(35, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = th.font
		nameLabel.TextSize = 13
		nameLabel.Text = name
		nameLabel.TextColor3 = th.textSecondary
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left

		-- Page Title (Comme sur l'image: Player en haut à droite)
		tab.PageTitle = Instance.new("TextLabel", window.ContentArea)
		tab.PageTitle.Size = UDim2.new(1, -40, 0, 40)
		tab.PageTitle.Position = UDim2.fromOffset(20, 10)
		tab.PageTitle.BackgroundTransparency = 1
		tab.PageTitle.Font = th.fontBold
		tab.PageTitle.TextSize = 16
		tab.PageTitle.Text = name
		tab.PageTitle.TextColor3 = th.textPrimary
		tab.PageTitle.TextXAlignment = Enum.TextXAlignment.Left
		tab.PageTitle.Visible = false

		-- Blue underline for active tab title
		local underline = Instance.new("Frame", tab.PageTitle)
		underline.Size = UDim2.fromOffset(30, 2)
		underline.Position = UDim2.new(0, 0, 1, -5)
		underline.BackgroundColor3 = th.accent
		underline.BorderSizePixel = 0

		-- Container
		tab.Container = Instance.new("ScrollingFrame", window.ContentArea)
		tab.Container.Size = UDim2.new(1, 0, 1, -50)
		tab.Container.Position = UDim2.fromOffset(0, 50)
		tab.Container.BackgroundTransparency = 1
		tab.Container.BorderSizePixel = 0
		tab.Container.ScrollBarThickness = 0
		tab.Container.Visible = false
		
		local layout = Instance.new("UIListLayout", tab.Container)
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.Padding = UDim.new(0, 15)
		layout.SortOrder = Enum.SortOrder.LayoutOrder

		local pad = Instance.new("UIPadding", tab.Container)
		pad.PaddingLeft = UDim.new(0, 20)
		pad.PaddingTop = UDim.new(0, 5)

		function tab:Select()
			for _, t in pairs(window.Tabs) do
				t.TabBtn.BackgroundTransparency = 1
				t.Container.Visible = false
				t.PageTitle.Visible = false
				makeTween(t._name, { TextColor3 = th.textSecondary }, 0.1):Play()
				makeTween(t._icon, { TextColor3 = th.textSecondary }, 0.1):Play()
			end
			tab.TabBtn.BackgroundTransparency = 0
			tab.Container.Visible = true
			tab.PageTitle.Visible = true
			makeTween(nameLabel, { TextColor3 = th.textPrimary }, 0.1):Play()
			makeTween(iconLabel, { TextColor3 = th.textPrimary }, 0.1):Play()
		end

		tab._name = nameLabel
		tab._icon = iconLabel
		tab.TabBtn.MouseButton1Down:Connect(function() tab:Select() end)

		-- ============================================================
		-- CREATE SECTOR
		-- ============================================================
		function tab:CreateSector(sectorName)
			local sector = {}
			local sW = (W - th.sidebarWidth - 55) / 2

			sector.Main = Instance.new("Frame", tab.Container)
			sector.Main.Size = UDim2.fromOffset(sW, 100)
			sector.Main.BackgroundColor3 = th.sectorBg
			sector.Main.BorderSizePixel = 0
			makeCorner(sector.Main, 4)
			
			local sTitle = Instance.new("TextLabel", sector.Main)
			sTitle.Size = UDim2.new(1, -20, 0, 35)
			sTitle.Position = UDim2.fromOffset(10, 0)
			sTitle.BackgroundTransparency = 1
			sTitle.Font = th.fontBold
			sTitle.TextSize = 13
			sTitle.Text = sectorName
			sTitle.TextColor3 = th.textPrimary
			sTitle.TextXAlignment = Enum.TextXAlignment.Left

			sector.Items = Instance.new("Frame", sector.Main)
			sector.Items.Position = UDim2.fromOffset(0, 35)
			sector.Items.Size = UDim2.new(1, 0, 0, 0)
			sector.Items.BackgroundTransparency = 1
			
			local iLayout = Instance.new("UIListLayout", sector.Items)
			iLayout.Padding = UDim.new(0, 0)

			function sector:FixSize()
				sector.Main.Size = UDim2.fromOffset(sW, iLayout.AbsoluteContentSize.Y + 45)
			end

			-- ============================================================
			-- ELEMENTS (Toggle, Slider, Button)
			-- ============================================================
			function sector:AddToggle(text, default, callback)
				local toggle = { value = default or false }
				local row = Instance.new("Frame", sector.Items)
				row.Size = UDim2.new(1, 0, 0, 30)
				row.BackgroundTransparency = 1
				
				local lbl = Instance.new("TextLabel", row)
				lbl.Size = UDim2.new(1, -50, 1, 0)
				lbl.Position = UDim2.fromOffset(10, 0)
				lbl.BackgroundTransparency = 1
				lbl.Font = th.font
				lbl.TextSize = 12
				lbl.Text = text
				lbl.TextColor3 = th.textSecondary
				lbl.TextXAlignment = Enum.TextXAlignment.Left

				local track = Instance.new("Frame", row)
				track.Size = UDim2.fromOffset(32, 16)
				track.Position = UDim2.new(1, -42, 0.5, -8)
				track.BackgroundColor3 = th.toggleOff
				makeCorner(track, 8)

				local knob = Instance.new("Frame", track)
				knob.Size = UDim2.fromOffset(12, 12)
				knob.Position = UDim2.fromOffset(2, 2)
				knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
				makeCorner(knob, 6)

				local btn = Instance.new("TextButton", row)
				btn.Size = UDim2.fromScale(1, 1)
				btn.BackgroundTransparency = 1
				btn.Text = ""

				function toggle:Set(v)
					toggle.value = v
					makeTween(track, { BackgroundColor3 = v and th.toggleOn or th.toggleOff }, 0.15):Play()
					makeTween(knob, { Position = v and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2) }, 0.15):Play()
					pcall(callback, v)
				end
				btn.MouseButton1Down:Connect(function() toggle:Set(not toggle.value) end)
				toggle:Set(toggle.value)
				sector:FixSize()
				return toggle
			end

			function sector:AddSlider(text, min, default, max, callback)
				local slider = { value = default or min }
				local row = Instance.new("Frame", sector.Items)
				row.Size = UDim2.new(1, 0, 0, 45)
				row.BackgroundTransparency = 1
				
				local lbl = Instance.new("TextLabel", row)
				lbl.Size = UDim2.new(1, -50, 0, 20)
				lbl.Position = UDim2.fromOffset(10, 2)
				lbl.BackgroundTransparency = 1
				lbl.Font = th.font
				lbl.TextSize = 12
				lbl.Text = text
				lbl.TextColor3 = th.textSecondary
				lbl.TextXAlignment = Enum.TextXAlignment.Left

				local valLbl = Instance.new("TextLabel", row)
				valLbl.Size = UDim2.new(0, 40, 0, 20)
				valLbl.Position = UDim2.new(1, -50, 0, 2)
				valLbl.BackgroundTransparency = 1
				valLbl.Font = th.font
				valLbl.TextSize = 12
				valLbl.Text = tostring(slider.value)
				valLbl.TextColor3 = th.textSecondary
				valLbl.TextXAlignment = Enum.TextXAlignment.Right

				local track = Instance.new("Frame", row)
				track.Size = UDim2.new(1, -20, 0, 4)
				track.Position = UDim2.fromOffset(10, 28)
				track.BackgroundColor3 = th.sliderBg
				makeCorner(track, 2)

				local fill = Instance.new("Frame", track)
				fill.Size = UDim2.fromScale(0, 1)
				fill.BackgroundColor3 = th.sliderFill
				makeCorner(fill, 2)

				local knob = Instance.new("Frame", fill)
				knob.Size = UDim2.fromOffset(10, 10)
				knob.AnchorPoint = Vector2.new(0.5, 0.5)
				knob.Position = UDim2.fromScale(1, 0.5)
				knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				makeCorner(knob, 5)

				local btn = Instance.new("TextButton", track)
				btn.Size = UDim2.new(1, 0, 0, 20)
				btn.Position = UDim2.fromOffset(0, -8)
				btn.BackgroundTransparency = 1
				btn.Text = ""

				local dragging = false
				local function update()
					local pct = math.clamp((mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					slider.value = math.floor(min + (max - min) * pct)
					fill.Size = UDim2.fromScale(pct, 1)
					valLbl.Text = tostring(slider.value)
					pcall(callback, slider.value)
				end
				btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true ; update() end end)
				uis.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
				uis.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update() end end)

				local initPct = (slider.value - min) / (max - min)
				fill.Size = UDim2.fromScale(initPct, 1)
				
				sector:FixSize()
				return slider
			end

			function sector:AddButton(text, callback)
				local row = Instance.new("Frame", sector.Items)
				row.Size = UDim2.new(1, 0, 0, 35)
				row.BackgroundTransparency = 1
				
				local btn = Instance.new("TextButton", row)
				btn.Size = UDim2.new(1, -20, 0, 26)
				btn.Position = UDim2.fromOffset(10, 4)
				btn.BackgroundColor3 = th.buttonBg
				btn.Font = th.font
				btn.TextSize = 12
				btn.Text = text
				btn.TextColor3 = th.textSecondary
				btn.AutoButtonColor = false
				makeCorner(btn, 4)
				makeStroke(btn, th.divider, 1)

				btn.MouseEnter:Connect(function() makeTween(btn, { BackgroundColor3 = th.tabHover, TextColor3 = th.textPrimary }, 0.1):Play() end)
				btn.MouseLeave:Connect(function() makeTween(btn, { BackgroundColor3 = th.buttonBg, TextColor3 = th.textSecondary }, 0.1):Play() end)
				btn.MouseButton1Down:Connect(function() pcall(callback) end)
				
				sector:FixSize()
			end

			return sector
		end

		table.insert(window.Tabs, tab)
		if firstTab then firstTab = false ; tab:Select() end
		return tab
	end

	return window
end

return library
