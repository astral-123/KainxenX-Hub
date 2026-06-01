-- MaxHub Style Library
-- Inspired by MaxHub Free UI
-- Compatible avec EchoLabs API (même structure)

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
local camera = game.Workspace.CurrentCamera

-- ============================================================
-- KEYBIND HELPERS
-- ============================================================
local shorter_keycodes = {
	["LeftShift"]    = "LSHIFT",
	["RightShift"]   = "RSHIFT",
	["LeftControl"]  = "LCTRL",
	["RightControl"] = "RCTRL",
	["LeftAlt"]      = "LALT",
	["RightAlt"]     = "RALT",
}

local mouse_buttons = {
	[Enum.UserInputType.MouseButton1] = "MB1",
	[Enum.UserInputType.MouseButton2] = "MB2",
	[Enum.UserInputType.MouseButton3] = "MB3",
}

local function keybindToText(value)
	if value == "None" or value == nil then return "[None]" end
	if mouse_buttons[value] then return "[" .. mouse_buttons[value] .. "]" end
	if typeof(value) == "EnumItem" then
		return "[" .. (shorter_keycodes[value.Name] or value.Name) .. "]"
	end
	return "[" .. tostring(value) .. "]"
end

local function inputMatchesKeybind(input, value)
	if value == "None" or value == nil then return false end
	if mouse_buttons[value] then return input.UserInputType == value end
	if typeof(value) == "EnumItem" then
		return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == value
	end
	return false
end

local function inputToKeybindValue(input)
	if mouse_buttons[input.UserInputType] then return input.UserInputType
	elseif input.UserInputType == Enum.UserInputType.Keyboard then return input.KeyCode
	end
	return "None"
end

-- ============================================================
-- THEME — MaxHub style
-- ============================================================
library.theme = {
	font           = Enum.Font.GothamMedium,
	fontBold       = Enum.Font.GothamBold,
	fontsize       = 13,
	titlesize      = 14,

	-- Sidebar
	sidebarBg      = Color3.fromRGB(18, 20, 28),
	sidebarWidth   = 160,
	tabBg          = Color3.fromRGB(24, 27, 38),
	tabHover       = Color3.fromRGB(30, 34, 48),
	tabActive      = Color3.fromRGB(35, 40, 58),
	tabActiveBar   = Color3.fromRGB(88, 120, 255),  -- accent bleu

	-- Contenu
	contentBg      = Color3.fromRGB(22, 25, 35),
	sectorBg       = Color3.fromRGB(26, 30, 42),
	sectorHeader   = Color3.fromRGB(30, 35, 50),

	-- Texte
	textPrimary    = Color3.fromRGB(230, 232, 245),
	textSecondary  = Color3.fromRGB(140, 148, 175),
	textAccent     = Color3.fromRGB(88, 120, 255),
	textLabel      = Color3.fromRGB(100, 110, 140),

	-- Accent
	accent         = Color3.fromRGB(88, 120, 255),
	accentDark     = Color3.fromRGB(55, 80, 185),
	accentHover    = Color3.fromRGB(110, 140, 255),

	-- Toggle
	toggleOff      = Color3.fromRGB(40, 45, 62),
	toggleOn       = Color3.fromRGB(88, 120, 255),
	toggleKnob     = Color3.fromRGB(220, 225, 240),

	-- Slider
	sliderBg       = Color3.fromRGB(35, 40, 58),
	sliderFill     = Color3.fromRGB(88, 120, 255),

	-- Button
	buttonBg       = Color3.fromRGB(32, 37, 52),
	buttonHover    = Color3.fromRGB(40, 46, 65),
	buttonBorder   = Color3.fromRGB(50, 58, 82),

	-- Dropdown
	dropdownBg     = Color3.fromRGB(28, 32, 46),
	dropdownItem   = Color3.fromRGB(32, 38, 54),
	dropdownSel    = Color3.fromRGB(40, 50, 80),

	-- Divider
	divider        = Color3.fromRGB(35, 40, 58),

	-- Window
	windowBg       = Color3.fromRGB(18, 20, 28),
	topbarBg       = Color3.fromRGB(20, 23, 32),
	topbarHeight   = 44,
	windowW        = 640,
	windowH        = 440,

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
	c.CornerRadius = UDim.new(0, radius or 6)
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
-- NOTIFY
-- ============================================================
function library:Notify(title, description, duration)
	if type(description) == "number" then duration = description ; description = nil end
	duration = duration or 4

	local gui = Instance.new("ScreenGui", coregui)
	gui.Name = "MHNotif"
	gui.DisplayOrder = 50
	if syn then pcall(function() syn.protect_gui(gui) end) end

	local h = description and 64 or 44
	local frame = Instance.new("Frame", gui)
	frame.Size     = UDim2.fromOffset(280, h)
	frame.Position = UDim2.new(1, 290, 1, -80)
	frame.BackgroundColor3 = library.theme.sectorBg
	frame.BorderSizePixel  = 0
	frame.ClipsDescendants = true
	makeCorner(frame, 8)
	makeStroke(frame, library.theme.accent, 1, 0.5)

	local bar = Instance.new("Frame", frame)
	bar.Size = UDim2.fromOffset(3, h)
	bar.BackgroundColor3 = library.theme.accent
	bar.BorderSizePixel = 0
	makeCorner(bar, 2)

	local tl = Instance.new("TextLabel", frame)
	tl.Position = UDim2.fromOffset(12, description and 8 or 14)
	tl.Size     = UDim2.fromOffset(260, 16)
	tl.BackgroundTransparency = 1
	tl.Font = library.theme.fontBold
	tl.TextSize = 13
	tl.Text = title or ""
	tl.TextColor3 = library.theme.textPrimary
	tl.TextXAlignment = Enum.TextXAlignment.Left

	if description then
		local dl = Instance.new("TextLabel", frame)
		dl.Position = UDim2.fromOffset(12, 28)
		dl.Size     = UDim2.fromOffset(260, 28)
		dl.BackgroundTransparency = 1
		dl.Font = library.theme.font
		dl.TextSize = 12
		dl.Text = description
		dl.TextColor3 = library.theme.textSecondary
		dl.TextXAlignment = Enum.TextXAlignment.Left
		dl.TextWrapped = true
	end

	local prog = Instance.new("Frame", frame)
	prog.Size = UDim2.fromOffset(280, 2)
	prog.Position = UDim2.new(0, 0, 1, -2)
	prog.BackgroundColor3 = library.theme.accent
	prog.BorderSizePixel = 0

	makeTween(frame, { Position = UDim2.new(1, -292, 1, -80) }, 0.3, Enum.EasingStyle.Quint):Play()
	wait(0.35)
	makeTween(prog, { Size = UDim2.fromOffset(0, 2) }, duration, Enum.EasingStyle.Linear):Play()

	delay(duration, function()
		makeTween(frame, { Position = UDim2.new(1, 290, 1, -80) }, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In):Play()
		wait(0.3)
		gui:Destroy()
	end)
end

-- ============================================================
-- CREATE WINDOW
-- ============================================================
function library:CreateWindow(name, size, hidebutton)
	local th = library.theme
	local window = {}
	window.name      = name or "Hub"
	window.hidekey   = hidebutton or th.hidebutton
	window.Tabs      = {}
	window.OpenedColorPickers = {}
	window.theme     = th

	local updateEvent = Instance.new("BindableEvent")
	function window:UpdateTheme(newTheme)
		library.theme = newTheme or th
		window.theme  = library.theme
		updateEvent:Fire(library.theme)
	end

	-- ScreenGui
	window.Main = Instance.new("ScreenGui", coregui)
	window.Main.Name = name
	window.Main.DisplayOrder = 15
	if syn then pcall(function() syn.protect_gui(window.Main) end) end
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
	makeCorner(window.Frame, 10)
	makeStroke(window.Frame, Color3.fromRGB(40, 46, 65), 1)

	-- Shadow (frame légèrement plus grande derrière)
	local shadow = Instance.new("Frame", window.Frame)
	shadow.ZIndex = 0
	shadow.Size = UDim2.fromOffset(W + 20, H + 20)
	shadow.Position = UDim2.fromOffset(-10, -10)
	shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadow.BackgroundTransparency = 0.6
	shadow.BorderSizePixel = 0
	makeCorner(shadow, 14)

	-- TopBar
	local topbar = Instance.new("Frame", window.Frame)
	topbar.Name = "TopBar"
	topbar.Size = UDim2.fromOffset(W, th.topbarHeight)
	topbar.BackgroundColor3 = th.topbarBg
	topbar.BorderSizePixel  = 0
	topbar.ZIndex = 3
	makeCorner(topbar, 10)

	-- Fix bottom corners topbar
	local topbarFix = Instance.new("Frame", topbar)
	topbarFix.Size = UDim2.fromOffset(W, 10)
	topbarFix.Position = UDim2.new(0, 0, 1, -10)
	topbarFix.BackgroundColor3 = th.topbarBg
	topbarFix.BorderSizePixel  = 0
	topbarFix.ZIndex = 3

	-- Divider sous topbar
	local topDiv = Instance.new("Frame", window.Frame)
	topDiv.Size = UDim2.fromOffset(W, 1)
	topDiv.Position = UDim2.fromOffset(0, th.topbarHeight)
	topDiv.BackgroundColor3 = th.divider
	topDiv.BorderSizePixel  = 0
	topDiv.ZIndex = 3

	-- Icon (point coloré)
	local iconDot = Instance.new("Frame", topbar)
	iconDot.Size = UDim2.fromOffset(8, 8)
	iconDot.Position = UDim2.fromOffset(14, 18)
	iconDot.BackgroundColor3 = th.accent
	iconDot.BorderSizePixel  = 0
	iconDot.ZIndex = 4
	makeCorner(iconDot, 4)

	-- Titre
	local titleLabel = Instance.new("TextLabel", topbar)
	titleLabel.Size = UDim2.fromOffset(300, th.topbarHeight)
	titleLabel.Position = UDim2.fromOffset(30, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = th.fontBold
	titleLabel.TextSize = 14
	titleLabel.Text = window.name
	titleLabel.TextColor3 = th.textPrimary
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 4

	-- Bouton fermer
	window.CloseBtn = Instance.new("TextButton", topbar)
	window.CloseBtn.Size = UDim2.fromOffset(20, 20)
	window.CloseBtn.Position = UDim2.new(1, -32, 0, 12)
	window.CloseBtn.BackgroundTransparency = 1
	window.CloseBtn.Font = th.fontBold
	window.CloseBtn.Text = "×"
	window.CloseBtn.TextSize = 18
	window.CloseBtn.TextColor3 = th.textSecondary
	window.CloseBtn.BorderSizePixel = 0
	window.CloseBtn.ZIndex = 5
	window.CloseBtn.AutoButtonColor = false

	window.CloseBtn.MouseEnter:Connect(function()
		makeTween(window.CloseBtn, { TextColor3 = Color3.fromRGB(255, 80, 80) }, 0.1):Play()
	end)
	window.CloseBtn.MouseLeave:Connect(function()
		makeTween(window.CloseBtn, { TextColor3 = th.textSecondary }, 0.1):Play()
	end)
	window.CloseBtn.MouseButton1Down:Connect(function()
		for _, v in pairs(library.items) do
			pcall(function()
				if v.Set and type(v.value) == "boolean" and v.value == true then v:Set(false) end
			end)
		end
		window.Main:Destroy()
	end)

	-- Bouton minimize
	window.MinBtn = Instance.new("TextButton", topbar)
	window.MinBtn.Size = UDim2.fromOffset(20, 20)
	window.MinBtn.Position = UDim2.new(1, -56, 0, 12)
	window.MinBtn.BackgroundTransparency = 1
	window.MinBtn.Font = th.fontBold
	window.MinBtn.Text = "−"
	window.MinBtn.TextSize = 16
	window.MinBtn.TextColor3 = th.textSecondary
	window.MinBtn.BorderSizePixel = 0
	window.MinBtn.ZIndex = 5
	window.MinBtn.AutoButtonColor = false

	local minimized = false
	window.MinBtn.MouseEnter:Connect(function()  makeTween(window.MinBtn, { TextColor3 = th.textPrimary }, 0.1):Play() end)
	window.MinBtn.MouseLeave:Connect(function()  makeTween(window.MinBtn, { TextColor3 = th.textSecondary }, 0.1):Play() end)
	window.MinBtn.MouseButton1Down:Connect(function()
		minimized = not minimized
		if minimized then
			window.Frame:TweenSize(UDim2.fromOffset(W, th.topbarHeight), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2)
		else
			window.Frame:TweenSize(UDim2.fromOffset(W, H), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2)
		end
	end)

	-- Drag
	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging  = true
			dragStart = input.Position
			startPos  = window.Frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
	end)
	uis.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			window.Frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	uis.InputBegan:Connect(function(key)
		if key.KeyCode == window.hidekey then
			window.Frame.Visible = not window.Frame.Visible
		end
	end)

	-- ============================================================
	-- SIDEBAR (gauche, largeur fixe)
	-- ============================================================
	local sideW = th.sidebarWidth

	window.Sidebar = Instance.new("Frame", window.Frame)
	window.Sidebar.Name = "Sidebar"
	window.Sidebar.Size = UDim2.fromOffset(sideW, H - th.topbarHeight)
	window.Sidebar.Position = UDim2.fromOffset(0, th.topbarHeight)
	window.Sidebar.BackgroundColor3 = th.sidebarBg
	window.Sidebar.BorderSizePixel  = 0
	window.Sidebar.ZIndex = 2
	makeCorner(window.Sidebar, 10)

	-- Fix corners droite sidebar
	local sidebarFix = Instance.new("Frame", window.Sidebar)
	sidebarFix.Size = UDim2.fromOffset(10, H - th.topbarHeight)
	sidebarFix.Position = UDim2.new(1, -10, 0, 0)
	sidebarFix.BackgroundColor3 = th.sidebarBg
	sidebarFix.BorderSizePixel  = 0
	sidebarFix.ZIndex = 2

	-- Divider droite sidebar
	local sideDiv = Instance.new("Frame", window.Frame)
	sideDiv.Size = UDim2.fromOffset(1, H - th.topbarHeight)
	sideDiv.Position = UDim2.fromOffset(sideW, th.topbarHeight)
	sideDiv.BackgroundColor3 = th.divider
	sideDiv.BorderSizePixel  = 0
	sideDiv.ZIndex = 3

	-- Layout sidebar
	local sideList = Instance.new("UIListLayout", window.Sidebar)
	sideList.FillDirection = Enum.FillDirection.Vertical
	sideList.SortOrder     = Enum.SortOrder.LayoutOrder
	sideList.Padding       = UDim.new(0, 2)

	local sidePad = Instance.new("UIPadding", window.Sidebar)
	sidePad.PaddingTop   = UDim.new(0, 10)
	sidePad.PaddingLeft  = UDim.new(0, 8)
	sidePad.PaddingRight = UDim.new(0, 8)

	-- Section label sidebar
	local function makeSideLabel(text)
		local lbl = Instance.new("TextLabel", window.Sidebar)
		lbl.Size = UDim2.fromOffset(sideW - 16, 18)
		lbl.BackgroundTransparency = 1
		lbl.Font = th.fontBold
		lbl.TextSize = 10
		lbl.Text = text:upper()
		lbl.TextColor3 = th.textLabel
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.ZIndex = 3
		local pad = Instance.new("UIPadding", lbl)
		pad.PaddingLeft = UDim.new(0, 4)
		return lbl
	end

	-- Zone contenu (droite)
	window.Content = Instance.new("Frame", window.Frame)
	window.Content.Name = "Content"
	window.Content.Size = UDim2.fromOffset(W - sideW - 1, H - th.topbarHeight)
	window.Content.Position = UDim2.fromOffset(sideW + 1, th.topbarHeight)
	window.Content.BackgroundColor3 = th.contentBg
	window.Content.BorderSizePixel  = 0
	window.Content.ZIndex = 2
	makeCorner(window.Content, 10)

	local contentFix = Instance.new("Frame", window.Content)
	contentFix.Size = UDim2.fromOffset(10, H - th.topbarHeight)
	contentFix.BackgroundColor3 = th.contentBg
	contentFix.BorderSizePixel  = 0
	contentFix.ZIndex = 2

	-- ============================================================
	-- CREATE TAB
	-- ============================================================
	local firstTab = true
	local sideSection = nil -- label courant

	function window:AddSidebarSection(text)
		sideSection = makeSideLabel(text)
	end

	function window:CreateTab(name, icon)
		local tab = {}
		tab.name = name or ""

		-- Bouton sidebar
		tab.TabBtn = Instance.new("TextButton", window.Sidebar)
		tab.TabBtn.Size = UDim2.fromOffset(sideW - 16, 32)
		tab.TabBtn.BackgroundColor3 = th.tabBg
		tab.TabBtn.BackgroundTransparency = 1
		tab.TabBtn.BorderSizePixel = 0
		tab.TabBtn.Text = ""
		tab.TabBtn.AutoButtonColor = false
		tab.TabBtn.ZIndex = 4
		makeCorner(tab.TabBtn, 6)

		-- Barre active (gauche)
		tab.ActiveBar = Instance.new("Frame", tab.TabBtn)
		tab.ActiveBar.Size = UDim2.fromOffset(3, 18)
		tab.ActiveBar.Position = UDim2.fromOffset(0, 7)
		tab.ActiveBar.BackgroundColor3 = th.tabActiveBar
		tab.ActiveBar.BorderSizePixel  = 0
		tab.ActiveBar.Visible = false
		tab.ActiveBar.ZIndex = 5
		makeCorner(tab.ActiveBar, 2)

		-- Icône (texte) ou point
		local iconLabel = Instance.new("TextLabel", tab.TabBtn)
		iconLabel.Size = UDim2.fromOffset(18, 32)
		iconLabel.Position = UDim2.fromOffset(8, 0)
		iconLabel.BackgroundTransparency = 1
		iconLabel.Font = th.fontBold
		iconLabel.TextSize = 14
		iconLabel.Text = icon or "•"
		iconLabel.TextColor3 = th.textSecondary
		iconLabel.ZIndex = 5

		local nameLabel = Instance.new("TextLabel", tab.TabBtn)
		nameLabel.Size = UDim2.fromOffset(sideW - 50, 32)
		nameLabel.Position = UDim2.fromOffset(30, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = th.font
		nameLabel.TextSize = 13
		nameLabel.Text = tab.name
		nameLabel.TextColor3 = th.textSecondary
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.ZIndex = 5

		-- Container du contenu de ce tab
		tab.Container = Instance.new("ScrollingFrame", window.Content)
		tab.Container.Size = UDim2.fromScale(1, 1)
		tab.Container.BackgroundTransparency = 1
		tab.Container.BorderSizePixel = 0
		tab.Container.ScrollBarThickness = 3
		tab.Container.ScrollBarImageColor3 = th.accent
		tab.Container.ScrollingDirection = Enum.ScrollingDirection.Y
		tab.Container.Visible = false
		tab.Container.ZIndex = 3

		local contLayout = Instance.new("UIListLayout", tab.Container)
		contLayout.FillDirection = Enum.FillDirection.Horizontal
		contLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		contLayout.VerticalAlignment   = Enum.VerticalAlignment.Top
		contLayout.Wraps = true
		contLayout.SortOrder = Enum.SortOrder.LayoutOrder
		contLayout.Padding  = UDim.new(0, 10)

		local contPad = Instance.new("UIPadding", tab.Container)
		contPad.PaddingTop    = UDim.new(0, 12)
		contPad.PaddingLeft   = UDim.new(0, 12)
		contPad.PaddingRight  = UDim.new(0, 12)
		contPad.PaddingBottom = UDim.new(0, 12)

		tab.Sectors = {}

		-- Sélection
		function tab:SelectTab()
			for _, t in pairs(window.Tabs) do
				if t ~= tab then
					t.Container.Visible = false
					t.TabBtn.BackgroundTransparency = 1
					t.ActiveBar.Visible = false
					makeTween(t._nameLabel, { TextColor3 = th.textSecondary }, 0.15):Play()
					makeTween(t._iconLabel, { TextColor3 = th.textSecondary }, 0.15):Play()
				end
			end
			tab.Container.Visible = true
			tab.TabBtn.BackgroundTransparency = 0
			tab.TabBtn.BackgroundColor3 = th.tabActive
			tab.ActiveBar.Visible = true
			makeTween(nameLabel, { TextColor3 = th.textPrimary }, 0.15):Play()
			makeTween(iconLabel, { TextColor3 = th.accent }, 0.15):Play()
		end

		tab._nameLabel = nameLabel
		tab._iconLabel = iconLabel

		tab.TabBtn.MouseEnter:Connect(function()
			if tab.Container.Visible then return end
			makeTween(tab.TabBtn, { BackgroundTransparency = 0, BackgroundColor3 = th.tabHover }, 0.1):Play()
		end)
		tab.TabBtn.MouseLeave:Connect(function()
			if tab.Container.Visible then return end
			makeTween(tab.TabBtn, { BackgroundTransparency = 1 }, 0.1):Play()
		end)
		tab.TabBtn.MouseButton1Down:Connect(function() tab:SelectTab() end)

		if firstTab then firstTab = false ; tab:SelectTab() end
		table.insert(window.Tabs, tab)

		-- ============================================================
		-- CREATE SECTOR
		-- ============================================================
		function tab:CreateSector(sectorName)
			local sector = {}
			sector.name = sectorName or ""

			local cW = (W - sideW - 1 - 34) / 2  -- largeur d'un sector (2 colonnes)

			sector.Main = Instance.new("Frame", tab.Container)
			sector.Main.Name = sectorName:gsub(" ", "") .. "Sector"
			sector.Main.Size = UDim2.fromOffset(cW, 20)
			sector.Main.BackgroundColor3 = th.sectorBg
			sector.Main.BorderSizePixel  = 0
			sector.Main.ZIndex = 4
			makeCorner(sector.Main, 8)
			makeStroke(sector.Main, th.divider, 1)

			-- Header du sector
			local header = Instance.new("Frame", sector.Main)
			header.Size = UDim2.fromOffset(cW, 32)
			header.BackgroundColor3 = th.sectorHeader
			header.BorderSizePixel  = 0
			header.ZIndex = 5
			makeCorner(header, 8)

			-- Fix bottom corners header
			local headerFix = Instance.new("Frame", header)
			headerFix.Size = UDim2.fromOffset(cW, 10)
			headerFix.Position = UDim2.new(0, 0, 1, -10)
			headerFix.BackgroundColor3 = th.sectorHeader
			headerFix.BorderSizePixel  = 0
			headerFix.ZIndex = 5

			-- Barre accent en haut du sector
			local sectorBar = Instance.new("Frame", header)
			sectorBar.Size = UDim2.fromOffset(cW, 2)
			sectorBar.BackgroundColor3 = th.accent
			sectorBar.BorderSizePixel  = 0
			sectorBar.ZIndex = 6
			makeCorner(sectorBar, 8)

			-- Fix bottom corners bar
			local sectorBarFix = Instance.new("Frame", sectorBar)
			sectorBarFix.Size = UDim2.fromOffset(cW, 4)
			sectorBarFix.Position = UDim2.new(0, 0, 1, -4)
			sectorBarFix.BackgroundColor3 = th.accent
			sectorBarFix.BorderSizePixel  = 0

			local sectorTitle = Instance.new("TextLabel", header)
			sectorTitle.Size = UDim2.fromOffset(cW - 10, 32)
			sectorTitle.Position = UDim2.fromOffset(10, 0)
			sectorTitle.BackgroundTransparency = 1
			sectorTitle.Font = th.fontBold
			sectorTitle.TextSize = 12
			sectorTitle.Text = sector.name:upper()
			sectorTitle.TextColor3 = th.textSecondary
			sectorTitle.TextXAlignment = Enum.TextXAlignment.Left
			sectorTitle.ZIndex = 6

			-- Items frame
			sector.Items = Instance.new("Frame", sector.Main)
			sector.Items.Name = "Items"
			sector.Items.BackgroundTransparency = 1
			sector.Items.Position = UDim2.fromOffset(0, 34)
			sector.Items.Size = UDim2.fromOffset(cW, 10)
			sector.Items.AutomaticSize = Enum.AutomaticSize.Y
			sector.Items.BorderSizePixel = 0
			sector.Items.ZIndex = 5

			local itemsList = Instance.new("UIListLayout", sector.Items)
			itemsList.FillDirection = Enum.FillDirection.Vertical
			itemsList.SortOrder     = Enum.SortOrder.LayoutOrder
			itemsList.Padding       = UDim.new(0, 0)

			local itemsPad = Instance.new("UIPadding", sector.Items)
			itemsPad.PaddingBottom = UDim.new(0, 8)

			sector.ListLayout = itemsList

			function sector:FixSize()
				local h = sector.ListLayout.AbsoluteContentSize.Y + 34 + 8
				sector.Main.Size = UDim2.fromOffset(cW, h)
				-- Recalcule CanvasSize du container
				local total = 0
				for _, c in pairs(tab.Container:GetChildren()) do
					if c:IsA("Frame") then
						total = math.max(total, c.AbsolutePosition.Y + c.AbsoluteSize.Y - tab.Container.AbsolutePosition.Y)
					end
				end
				tab.Container.CanvasSize = UDim2.fromOffset(0, total + 20)
			end

			-- Item row helper
			local function makeRow(parent, label)
				local row = Instance.new("Frame", parent)
				row.Size = UDim2.fromOffset(cW, 30)
				row.BackgroundTransparency = 1
				row.BorderSizePixel = 0
				row.ZIndex = 6

				if label and label ~= "" then
					local lbl = Instance.new("TextLabel", row)
					lbl.Size = UDim2.fromOffset(cW * 0.55, 30)
					lbl.Position = UDim2.fromOffset(10, 0)
					lbl.BackgroundTransparency = 1
					lbl.Font = th.font
					lbl.TextSize = 13
					lbl.Text = label
					lbl.TextColor3 = th.textPrimary
					lbl.TextXAlignment = Enum.TextXAlignment.Left
					lbl.ZIndex = 7
				end

				return row
			end

			-- ================================================================
			-- AddLabel
			-- ================================================================
			function sector:AddLabel(text, color, centered)
				local lbl = {}
				local row = makeRow(sector.Items, "")
				row.Size = UDim2.fromOffset(cW, 24)

				lbl.Text = Instance.new("TextLabel", row)
				lbl.Text.Size = UDim2.fromOffset(cW - 20, 24)
				lbl.Text.Position = UDim2.fromOffset(10, 0)
				lbl.Text.BackgroundTransparency = 1
				lbl.Text.Font = th.font
				lbl.Text.TextSize = 12
				lbl.Text.Text = text or ""
				lbl.Text.TextColor3 = color or th.textSecondary
				lbl.Text.TextXAlignment = centered and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
				lbl.Text.TextWrapped = true
				lbl.Text.AutomaticSize = Enum.AutomaticSize.Y
				lbl.Text.ZIndex = 7

				lbl.Main = row
				function lbl:Set(v)    lbl.Text.Text = tostring(v) ; sector:FixSize() end
				function lbl:Get()     return lbl.Text.Text end
				function lbl:SetColor(c) lbl.Text.TextColor3 = c end
				function lbl:SetVisible(v) row.Visible = v ; sector:FixSize() end

				sector:FixSize()
				return lbl
			end

			-- ================================================================
			-- AddButton
			-- ================================================================
			function sector:AddButton(text, callback)
				local btn = {}
				btn.callback = callback or function() end

				local row = Instance.new("Frame", sector.Items)
				row.Size = UDim2.fromOffset(cW, 36)
				row.BackgroundTransparency = 1
				row.BorderSizePixel = 0
				row.ZIndex = 6

				btn.Main = Instance.new("TextButton", row)
				btn.Main.Size = UDim2.fromOffset(cW - 20, 22)
				btn.Main.Position = UDim2.fromOffset(10, 7)
				btn.Main.BackgroundColor3 = th.buttonBg
				btn.Main.BorderSizePixel  = 0
				btn.Main.Font = th.fontBold
				btn.Main.Text = text or ""
				btn.Main.TextSize = 12
				btn.Main.TextColor3 = th.textPrimary
				btn.Main.AutoButtonColor = false
				btn.Main.ZIndex = 7
				makeCorner(btn.Main, 5)
				makeStroke(btn.Main, th.buttonBorder, 1)

				btn.Main.MouseEnter:Connect(function()
					makeTween(btn.Main, { BackgroundColor3 = th.buttonHover }, 0.1):Play()
				end)
				btn.Main.MouseLeave:Connect(function()
					makeTween(btn.Main, { BackgroundColor3 = th.buttonBg }, 0.1):Play()
				end)
				btn.Main.MouseButton1Down:Connect(function()
					makeTween(btn.Main, { BackgroundColor3 = th.accentDark }, 0.05):Play()
					pcall(btn.callback)
				end)
				btn.Main.MouseButton1Up:Connect(function()
					makeTween(btn.Main, { BackgroundColor3 = th.buttonHover }, 0.1):Play()
				end)

				sector:FixSize()
				return btn
			end

			-- ================================================================
			-- AddToggle
			-- ================================================================
			function sector:AddToggle(text, default, callback, flag)
				local toggle = {}
				toggle.text     = text or ""
				toggle.value    = default or false
				toggle.callback = callback or function() end
				toggle.flag     = flag or text or ""

				if toggle.flag ~= "" then library.flags[toggle.flag] = toggle.value end

				local row = makeRow(sector.Items, text)
				row.Size = UDim2.fromOffset(cW, 30)

				-- Switch track
				local track = Instance.new("Frame", row)
				track.Size = UDim2.fromOffset(32, 16)
				track.Position = UDim2.new(1, -42, 0.5, -8)
				track.BackgroundColor3 = th.toggleOff
				track.BorderSizePixel  = 0
				track.ZIndex = 7
				makeCorner(track, 8)

				-- Knob
				local knob = Instance.new("Frame", track)
				knob.Size = UDim2.fromOffset(12, 12)
				knob.Position = UDim2.fromOffset(2, 2)
				knob.BackgroundColor3 = th.toggleKnob
				knob.BorderSizePixel  = 0
				knob.ZIndex = 8
				makeCorner(knob, 6)

				-- Valeur affichée
				local valLabel = Instance.new("TextLabel", row)
				valLabel.Size = UDim2.fromOffset(30, 30)
				valLabel.Position = UDim2.new(1, -78, 0, 0)
				valLabel.BackgroundTransparency = 1
				valLabel.Font = th.font
				valLabel.TextSize = 12
				valLabel.Text = toggle.value and "On" or "Off"
				valLabel.TextColor3 = toggle.value and th.accent or th.textSecondary
				valLabel.TextXAlignment = Enum.TextXAlignment.Right
				valLabel.ZIndex = 7

				toggle.Items = Instance.new("Frame", row)
				toggle.Items.Size = UDim2.fromOffset(0, 30)
				toggle.Items.Position = UDim2.new(1, -42, 0, 0)
				toggle.Items.BackgroundTransparency = 1
				toggle.Items.BorderSizePixel = 0
				toggle.Items.ZIndex = 7

				local innerList = Instance.new("UIListLayout", toggle.Items)
				innerList.FillDirection = Enum.FillDirection.Horizontal
				innerList.HorizontalAlignment = Enum.HorizontalAlignment.Right
				innerList.SortOrder = Enum.SortOrder.LayoutOrder
				innerList.Padding   = UDim.new(0, 4)

				function toggle:Set(value)
					toggle.value = value
					if toggle.flag ~= "" then library.flags[toggle.flag] = value end
					if value then
						makeTween(track, { BackgroundColor3 = th.toggleOn }, 0.15):Play()
						makeTween(knob,  { Position = UDim2.fromOffset(18, 2) }, 0.15):Play()
						makeTween(valLabel, { TextColor3 = th.accent }, 0.15):Play()
						valLabel.Text = "On"
					else
						makeTween(track, { BackgroundColor3 = th.toggleOff }, 0.15):Play()
						makeTween(knob,  { Position = UDim2.fromOffset(2, 2) }, 0.15):Play()
						makeTween(valLabel, { TextColor3 = th.textSecondary }, 0.15):Play()
						valLabel.Text = "Off"
					end
					pcall(toggle.callback, value)
				end
				function toggle:Get() return toggle.value end
				toggle:Set(toggle.value)

				local clickable = Instance.new("TextButton", row)
				clickable.Size = UDim2.fromScale(1, 1)
				clickable.BackgroundTransparency = 1
				clickable.Text = ""
				clickable.ZIndex = 9
				clickable.MouseButton1Down:Connect(function() toggle:Set(not toggle.value) end)

				-- Hover row
				row.MouseEnter = nil
				local rowHoverBtn = Instance.new("Frame", row)
				rowHoverBtn.Size = UDim2.fromScale(1, 1)
				rowHoverBtn.BackgroundTransparency = 1
				rowHoverBtn.ZIndex = 6

				-- ============================================================
				-- toggle:AddKeybind
				-- ============================================================
				function toggle:AddKeybind(default, flag2)
					local kb = {}
					kb.value = default or "None"
					kb.flag  = flag2 or (toggle.text .. "_kb")
					if kb.flag ~= "" then library.flags[kb.flag] = kb.value end

					kb.Btn = Instance.new("TextButton", toggle.Items)
					kb.Btn.BackgroundTransparency = 1
					kb.Btn.BorderSizePixel = 0
					kb.Btn.Font = th.font
					kb.Btn.TextSize = 11
					kb.Btn.Text = keybindToText(kb.value)
					kb.Btn.TextColor3 = th.textSecondary
					kb.Btn.AutoButtonColor = false
					kb.Btn.ZIndex = 10
					kb.Btn.Size = UDim2.fromOffset(60, 30)
					kb.Btn.TextXAlignment = Enum.TextXAlignment.Right

					kb.Btn.MouseButton1Down:Connect(function()
						kb.Btn.Text = "[...]"
						kb.Btn.TextColor3 = th.accent
					end)

					function kb:Set(v)
						kb.value = v
						kb.Btn.Text = keybindToText(v)
						kb.Btn.TextColor3 = th.textSecondary
						if kb.flag ~= "" then library.flags[kb.flag] = v end
					end
					function kb:Get() return kb.value end

					uis.InputBegan:Connect(function(input, gp)
						if not gp then
							if kb.Btn.Text == "[...]" then
								kb:Set(inputToKeybindValue(input))
							elseif inputMatchesKeybind(input, kb.value) then
								toggle:Set(not toggle.value)
							end
						end
					end)

					table.insert(library.items, kb)
					return kb
				end

				-- ============================================================
				-- toggle:AddColorpicker
				-- ============================================================
				function toggle:AddColorpicker(default, callback2, flag2)
					local cp = {}
					cp.value    = default or Color3.fromRGB(255, 255, 255)
					cp.callback = callback2 or function() end
					cp.flag     = flag2 or (toggle.text .. "_cp")
					if cp.flag ~= "" then library.flags[cp.flag] = cp.value end

					cp.Preview = Instance.new("TextButton", toggle.Items)
					cp.Preview.Size = UDim2.fromOffset(16, 16)
					-- Centré verticalement dans la row
					cp.Preview.BackgroundColor3 = cp.value
					cp.Preview.BorderSizePixel  = 0
					cp.Preview.Text = ""
					cp.Preview.AutoButtonColor = false
					cp.Preview.ZIndex = 10
					makeCorner(cp.Preview, 4)
					makeStroke(cp.Preview, th.divider, 1)

					-- Picker popup (simplifié HSV)
					cp.MainPicker = Instance.new("Frame", cp.Preview)
					cp.MainPicker.Size = UDim2.fromOffset(180, 196)
					cp.MainPicker.Position = UDim2.fromOffset(-162, 22)
					cp.MainPicker.BackgroundColor3 = th.dropdownBg
					cp.MainPicker.BorderSizePixel  = 0
					cp.MainPicker.Visible = false
					cp.MainPicker.ZIndex = 120
					makeCorner(cp.MainPicker, 8)
					makeStroke(cp.MainPicker, th.accent, 1, 0.5)

					window.OpenedColorPickers[cp.MainPicker] = false

					cp.hue = Instance.new("ImageLabel", cp.MainPicker)
					cp.hue.ZIndex = 121
					cp.hue.Position = UDim2.fromOffset(6, 6)
					cp.hue.Size = UDim2.fromOffset(168, 158)
					cp.hue.Image = "rbxassetid://4155801252"
					cp.hue.ScaleType = Enum.ScaleType.Stretch
					cp.hue.BackgroundColor3 = Color3.new(1, 0, 0)
					cp.hue.BorderSizePixel  = 0
					makeCorner(cp.hue, 4)

					cp.hueselectorpointer = Instance.new("ImageLabel", cp.MainPicker)
					cp.hueselectorpointer.ZIndex = 122
					cp.hueselectorpointer.BackgroundTransparency = 1
					cp.hueselectorpointer.BorderSizePixel = 0
					cp.hueselectorpointer.Size = UDim2.fromOffset(8, 8)
					cp.hueselectorpointer.Image = "rbxassetid://6885856475"

					cp.selector = Instance.new("Frame", cp.MainPicker)
					cp.selector.ZIndex = 121
					cp.selector.Position = UDim2.fromOffset(6, 172)
					cp.selector.Size = UDim2.fromOffset(168, 12)
					cp.selector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					cp.selector.BorderSizePixel  = 0
					makeCorner(cp.selector, 4)

					cp.gradient = Instance.new("UIGradient", cp.selector)
					cp.gradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0,    Color3.new(1,0,0)),
						ColorSequenceKeypoint.new(0.17, Color3.new(1,0,1)),
						ColorSequenceKeypoint.new(0.33, Color3.new(0,0,1)),
						ColorSequenceKeypoint.new(0.5,  Color3.new(0,1,1)),
						ColorSequenceKeypoint.new(0.67, Color3.new(0,1,0)),
						ColorSequenceKeypoint.new(0.83, Color3.new(1,1,0)),
						ColorSequenceKeypoint.new(1,    Color3.new(1,0,0))
					})

					cp.pointer = Instance.new("Frame", cp.selector)
					cp.pointer.ZIndex = 122
					cp.pointer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					cp.pointer.Position = UDim2.fromOffset(0, 0)
					cp.pointer.Size = UDim2.fromOffset(3, 12)
					cp.pointer.BorderSizePixel = 0
					makeCorner(cp.pointer, 2)

					function cp:RefreshHue()
						local x = math.clamp((mouse.X - cp.hue.AbsolutePosition.X) / cp.hue.AbsoluteSize.X, 0, 1)
						local y = math.clamp((mouse.Y - cp.hue.AbsolutePosition.Y) / cp.hue.AbsoluteSize.Y, 0, 1)
						cp.hueselectorpointer:TweenPosition(UDim2.new(x, -4, y, -4), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.05)
						cp:Set(Color3.fromHSV(cp.color or 0, x, 1 - y))
					end

					function cp:RefreshSelector()
						local pos = math.clamp((mouse.X - cp.selector.AbsolutePosition.X) / cp.selector.AbsoluteSize.X, 0, 1)
						cp.color = 1 - pos
						cp.pointer:TweenPosition(UDim2.new(pos, -1, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.05)
						cp.hue.BackgroundColor3 = Color3.fromHSV(1 - pos, 1, 1)
					end

					function cp:Set(value)
						local c = Color3.new(math.clamp(value.R, 0, 1), math.clamp(value.G, 0, 1), math.clamp(value.B, 0, 1))
						cp.value = c
						cp.Preview.BackgroundColor3 = c
						if cp.flag ~= "" then library.flags[cp.flag] = c end
						pcall(cp.callback, c)
					end
					function cp:Get() return cp.value end
					cp:Set(cp.value)

					local dragging_hue, dragging_sel = false, false
					cp.hue.InputBegan:Connect(function(i)      if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging_hue = true ; cp:RefreshHue() end end)
					cp.hue.InputEnded:Connect(function(i)      if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging_hue = false end end)
					cp.selector.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging_sel = true ; cp:RefreshSelector() end end)
					cp.selector.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging_sel = false end end)
					uis.InputChanged:Connect(function(i)
						if dragging_hue and i.UserInputType == Enum.UserInputType.MouseMovement then cp:RefreshHue() end
						if dragging_sel and i.UserInputType == Enum.UserInputType.MouseMovement then cp:RefreshSelector() end
					end)

					cp.Preview.MouseButton1Down:Connect(function()
						local vis = not cp.MainPicker.Visible
						for k, v in pairs(window.OpenedColorPickers) do
							if v then k.Visible = false ; window.OpenedColorPickers[k] = false end
						end
						cp.MainPicker.Visible = vis
						window.OpenedColorPickers[cp.MainPicker] = vis
					end)

					table.insert(library.items, cp)
					return cp
				end

				sector:FixSize()
				table.insert(library.items, toggle)
				return toggle
			end

			-- ================================================================
			-- AddSlider
			-- ================================================================
			function sector:AddSlider(text, min, default, max, decimals, callback, flag)
				local slider = {}
				slider.text     = text or ""
				slider.min      = min or 0
				slider.max      = max or 100
				slider.decimals = decimals or 1
				slider.default  = default or min or 0
				slider.value    = slider.default
				slider.flag     = flag or text or ""
				slider.callback = callback or function() end
				if slider.flag ~= "" then library.flags[slider.flag] = slider.value end

				local dragging = false

				local wrapper = Instance.new("Frame", sector.Items)
				wrapper.Size = UDim2.fromOffset(cW, 44)
				wrapper.BackgroundTransparency = 1
				wrapper.BorderSizePixel = 0
				wrapper.ZIndex = 6

				-- Label + valeur
				local lbl = Instance.new("TextLabel", wrapper)
				lbl.Size = UDim2.fromOffset(cW * 0.6 - 10, 16)
				lbl.Position = UDim2.fromOffset(10, 4)
				lbl.BackgroundTransparency = 1
				lbl.Font = th.font
				lbl.TextSize = 13
				lbl.Text = text
				lbl.TextColor3 = th.textPrimary
				lbl.TextXAlignment = Enum.TextXAlignment.Left
				lbl.ZIndex = 7

				slider.ValLabel = Instance.new("TextLabel", wrapper)
				slider.ValLabel.Size = UDim2.fromOffset(cW * 0.4 - 10, 16)
				slider.ValLabel.Position = UDim2.new(0.6, 0, 0, 4)
				slider.ValLabel.BackgroundTransparency = 1
				slider.ValLabel.Font = th.font
				slider.ValLabel.TextSize = 12
				slider.ValLabel.Text = tostring(slider.default)
				slider.ValLabel.TextColor3 = th.textSecondary
				slider.ValLabel.TextXAlignment = Enum.TextXAlignment.Right
				slider.ValLabel.ZIndex = 7

				-- Track
				local track = Instance.new("TextButton", wrapper)
				track.Size = UDim2.fromOffset(cW - 20, 6)
				track.Position = UDim2.fromOffset(10, 26)
				track.BackgroundColor3 = th.sliderBg
				track.BorderSizePixel  = 0
				track.Text = ""
				track.AutoButtonColor = false
				track.ZIndex = 7
				makeCorner(track, 3)

				-- Fill
				slider.Fill = Instance.new("Frame", track)
				slider.Fill.Size = UDim2.fromOffset(0, 6)
				slider.Fill.BackgroundColor3 = th.sliderFill
				slider.Fill.BorderSizePixel  = 0
				slider.Fill.ZIndex = 8
				makeCorner(slider.Fill, 3)

				-- Thumb
				slider.Thumb = Instance.new("Frame", track)
				slider.Thumb.Size = UDim2.fromOffset(10, 10)
				slider.Thumb.Position = UDim2.fromOffset(-5, -2)
				slider.Thumb.BackgroundColor3 = th.accent
				slider.Thumb.BorderSizePixel  = 0
				slider.Thumb.ZIndex = 9
				makeCorner(slider.Thumb, 5)

				function slider:Set(value)
					slider.value = math.clamp(math.floor(value * slider.decimals + 0.5) / slider.decimals, slider.min, slider.max)
					local pct = (slider.value - slider.min) / (slider.max - slider.min)
					local fillW = pct * track.AbsoluteSize.X
					makeTween(slider.Fill, { Size = UDim2.fromOffset(fillW, 6) }, 0.05):Play()
					slider.Thumb.Position = UDim2.fromOffset(fillW - 5, -2)
					slider.ValLabel.Text = tostring(slider.value)
					if slider.flag ~= "" then library.flags[slider.flag] = slider.value end
					pcall(slider.callback, slider.value)
				end
				function slider:Get() return slider.value end
				slider:Set(slider.default)

				local function refresh()
					local pct = math.clamp((mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					slider:Set(slider.min + (slider.max - slider.min) * pct)
				end

				track.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true ; refresh() end
				end)
				track.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
				end)
				uis.InputChanged:Connect(function(i)
					if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then refresh() end
				end)
				uis.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
				end)

				sector:FixSize()
				table.insert(library.items, slider)
				return slider
			end

			-- ================================================================
			-- AddTextbox
			-- ================================================================
			function sector:AddTextbox(text, default, callback, flag)
				local tb = {}
				tb.callback = callback or function() end
				tb.default  = default or ""
				tb.value    = ""
				tb.flag     = flag or text or ""
				if tb.flag ~= "" then library.flags[tb.flag] = tb.default end

				local row = Instance.new("Frame", sector.Items)
				row.Size = UDim2.fromOffset(cW, 48)
				row.BackgroundTransparency = 1
				row.BorderSizePixel = 0
				row.ZIndex = 6

				local lbl = Instance.new("TextLabel", row)
				lbl.Size = UDim2.fromOffset(cW - 20, 16)
				lbl.Position = UDim2.fromOffset(10, 4)
				lbl.BackgroundTransparency = 1
				lbl.Font = th.font
				lbl.TextSize = 13
				lbl.Text = text or ""
				lbl.TextColor3 = th.textPrimary
				lbl.TextXAlignment = Enum.TextXAlignment.Left
				lbl.ZIndex = 7

				tb.Box = Instance.new("TextBox", row)
				tb.Box.Size = UDim2.fromOffset(cW - 20, 20)
				tb.Box.Position = UDim2.fromOffset(10, 22)
				tb.Box.BackgroundColor3 = th.dropdownBg
				tb.Box.BorderSizePixel  = 0
				tb.Box.Font = th.font
				tb.Box.TextSize = 12
				tb.Box.TextColor3 = th.textPrimary
				tb.Box.PlaceholderText = text or ""
				tb.Box.PlaceholderColor3 = th.textSecondary
				tb.Box.Text = ""
				tb.Box.ClearTextOnFocus = false
				tb.Box.MultiLine = false
				tb.Box.ZIndex = 7
				local pad = Instance.new("UIPadding", tb.Box)
				pad.PaddingLeft = UDim.new(0, 6)
				makeCorner(tb.Box, 5)
				makeStroke(tb.Box, th.divider, 1)

				tb.Box.Focused:Connect(function()
					makeStroke(tb.Box, th.accent, 1)
				end)
				tb.Box.FocusLost:Connect(function()
					makeStroke(tb.Box, th.divider, 1)
					tb:Set(tb.Box.Text)
				end)

				function tb:Set(v)
					tb.value = v ; tb.Box.Text = v
					if tb.flag ~= "" then library.flags[tb.flag] = v end
					pcall(tb.callback, v)
				end
				function tb:Get() return tb.value end
				if tb.default and tb.default ~= "" then tb:Set(tb.default) end

				sector:FixSize()
				table.insert(library.items, tb)
				return tb
			end

			-- ================================================================
			-- AddDropdown
			-- ================================================================
			function sector:AddDropdown(text, items, default, multichoice, callback, flag)
				local dd = {}
				dd.text         = text or ""
				dd.defaultitems = items or {}
				dd.default      = default
				dd.multichoice  = multichoice or false
				dd.callback     = callback or function() end
				dd.values       = {}
				dd.flag         = flag or text or ""
				dd.items        = {}
				if dd.flag ~= "" then
					library.flags[dd.flag] = dd.multichoice and {} or (dd.default or "")
				end

				local wrapper = Instance.new("Frame", sector.Items)
				wrapper.Size = UDim2.fromOffset(cW, 48)
				wrapper.BackgroundTransparency = 1
				wrapper.BorderSizePixel = 0
				wrapper.ZIndex = 6

				local lbl = Instance.new("TextLabel", wrapper)
				lbl.Size = UDim2.fromOffset(cW - 20, 16)
				lbl.Position = UDim2.fromOffset(10, 4)
				lbl.BackgroundTransparency = 1
				lbl.Font = th.font
				lbl.TextSize = 13
				lbl.Text = text
				lbl.TextColor3 = th.textPrimary
				lbl.TextXAlignment = Enum.TextXAlignment.Left
				lbl.ZIndex = 7

				-- Button
				dd.Btn = Instance.new("TextButton", wrapper)
				dd.Btn.Size = UDim2.fromOffset(cW - 20, 20)
				dd.Btn.Position = UDim2.fromOffset(10, 22)
				dd.Btn.BackgroundColor3 = th.dropdownBg
				dd.Btn.BorderSizePixel  = 0
				dd.Btn.Text = ""
				dd.Btn.AutoButtonColor = false
				dd.Btn.ZIndex = 7
				makeCorner(dd.Btn, 5)
				makeStroke(dd.Btn, th.divider, 1)

				dd.SelLabel = Instance.new("TextLabel", dd.Btn)
				dd.SelLabel.Size = UDim2.fromOffset(cW - 50, 20)
				dd.SelLabel.Position = UDim2.fromOffset(6, 0)
				dd.SelLabel.BackgroundTransparency = 1
				dd.SelLabel.Font = th.font
				dd.SelLabel.TextSize = 12
				dd.SelLabel.Text = dd.default or text
				dd.SelLabel.TextColor3 = th.textSecondary
				dd.SelLabel.TextXAlignment = Enum.TextXAlignment.Left
				dd.SelLabel.ZIndex = 8

				local arrow = Instance.new("TextLabel", dd.Btn)
				arrow.Size = UDim2.fromOffset(16, 20)
				arrow.Position = UDim2.new(1, -20, 0, 0)
				arrow.BackgroundTransparency = 1
				arrow.Font = th.fontBold
				arrow.TextSize = 10
				arrow.Text = "▾"
				arrow.TextColor3 = th.textSecondary
				arrow.ZIndex = 8

				-- Dropdown list
				dd.List = Instance.new("ScrollingFrame", dd.Btn)
				dd.List.Size = UDim2.fromOffset(cW - 20, 0)
				dd.List.Position = UDim2.fromOffset(0, 24)
				dd.List.BackgroundColor3 = th.dropdownBg
				dd.List.BorderSizePixel  = 0
				dd.List.ScrollBarThickness = 2
				dd.List.ScrollBarImageColor3 = th.accent
				dd.List.ScrollingDirection = Enum.ScrollingDirection.Y
				dd.List.Visible = false
				dd.List.ZIndex = 10
				dd.List.CanvasSize = UDim2.fromOffset(0, 0)
				makeCorner(dd.List, 5)
				makeStroke(dd.List, th.accent, 1, 0.5)

				local listLayout = Instance.new("UIListLayout", dd.List)
				listLayout.FillDirection = Enum.FillDirection.Vertical
				listLayout.SortOrder = Enum.SortOrder.LayoutOrder

				dd.Changed = Instance.new("BindableEvent")

				function dd:updateText(t)
					if #t >= 22 then t = t:sub(1, 20) .. ".." end
					dd.SelLabel.Text = t
					dd.SelLabel.TextColor3 = th.textPrimary
				end

				function dd:isSelected(item)
					for _, v in pairs(dd.values) do if v == item then return true end end
					return false
				end

				function dd:Set(value)
					if type(value) == "table" then
						dd.values = value
						dd:updateText(table.concat(value, ", "))
						pcall(dd.callback, value)
					else
						dd.values = { value }
						dd:updateText(value)
						pcall(dd.callback, value)
					end
					dd.Changed:Fire(value)
					if dd.flag ~= "" then
						library.flags[dd.flag] = dd.multichoice and dd.values or dd.values[1]
					end
				end
				function dd:Get() return dd.multichoice and dd.values or dd.values[1] end
				function dd:GetOptions() return dd.values end

				function dd:Add(v)
					local item = Instance.new("TextButton", dd.List)
					item.Size = UDim2.fromOffset(cW - 20, 22)
					item.BackgroundColor3 = th.dropdownItem
					item.BackgroundTransparency = 0
					item.BorderSizePixel = 0
					item.Font = th.font
					item.TextSize = 12
					item.Text = " " .. v
					item.Name = v
					item.TextColor3 = th.textPrimary
					item.TextXAlignment = Enum.TextXAlignment.Left
					item.AutoButtonColor = false
					item.ZIndex = 11

					item.MouseEnter:Connect(function()
						makeTween(item, { BackgroundColor3 = th.dropdownSel }, 0.08):Play()
					end)
					item.MouseLeave:Connect(function()
						if not dd:isSelected(v) then
							makeTween(item, { BackgroundColor3 = th.dropdownItem }, 0.08):Play()
						end
					end)

					item.MouseButton1Down:Connect(function()
						if dd.multichoice then
							if dd:isSelected(v) then
								for i2, v2 in pairs(dd.values) do
									if v2 == v then table.remove(dd.values, i2) end
								end
								dd:Set(dd.values)
							else
								table.insert(dd.values, v)
								dd:Set(dd.values)
							end
						else
							dd.List.Visible = false
							dd:Set(v)
						end
					end)

					runservice.RenderStepped:Connect(function()
						if dd:isSelected(v) then
							item.BackgroundColor3 = th.dropdownSel
							item.TextColor3 = th.accent
						else
							item.TextColor3 = th.textPrimary
						end
					end)

					table.insert(dd.items, v)
					local h = math.clamp(#dd.items * 22, 22, 132)
					dd.List.Size = UDim2.fromOffset(cW - 20, h)
					dd.List.CanvasSize = UDim2.fromOffset(0, #dd.items * 22)
					wrapper.Size = UDim2.fromOffset(cW, 48 + (dd.List.Visible and h + 4 or 0))
					sector:FixSize()
				end

				function dd:Remove(value)
					local item = dd.List:FindFirstChild(value)
					if item then
						for i, v in pairs(dd.items) do if v == value then table.remove(dd.items, i) end end
						item:Destroy()
						local h = math.clamp(#dd.items * 22, 22, 132)
						dd.List.Size = UDim2.fromOffset(cW - 20, h)
						dd.List.CanvasSize = UDim2.fromOffset(0, #dd.items * 22)
						sector:FixSize()
					end
				end

				local open = false
				dd.Btn.MouseButton1Down:Connect(function()
					open = not open
					dd.List.Visible = open
					arrow.Text = open and "▴" or "▾"
					local h = open and (math.clamp(#dd.items * 22, 22, 132) + 4) or 0
					wrapper.Size = UDim2.fromOffset(cW, 48 + h)
					sector:FixSize()
				end)

				for _, v in pairs(dd.defaultitems) do dd:Add(v) end
				if dd.default then dd:Set(dd.default) end

				sector:FixSize()
				table.insert(library.items, dd)
				return dd
			end

			-- ================================================================
			-- AddKeybind
			-- ================================================================
			function sector:AddKeybind(text, default, newkeycallback, callback, flag)
				local kb = {}
				kb.text           = text or ""
				kb.value          = default or "None"
				kb.callback       = callback or function() end
				kb.newkeycallback = newkeycallback or function() end
				kb.flag           = flag or text or ""
				if kb.flag ~= "" then library.flags[kb.flag] = kb.value end

				local row = makeRow(sector.Items, text)

				kb.Bind = Instance.new("TextButton", row)
				kb.Bind.Size = UDim2.fromOffset(70, 20)
				kb.Bind.Position = UDim2.new(1, -80, 0.5, -10)
				kb.Bind.BackgroundColor3 = th.buttonBg
				kb.Bind.BorderSizePixel  = 0
				kb.Bind.Font = th.font
				kb.Bind.TextSize = 11
				kb.Bind.Text = keybindToText(kb.value)
				kb.Bind.TextColor3 = th.textSecondary
				kb.Bind.AutoButtonColor = false
				kb.Bind.ZIndex = 7
				makeCorner(kb.Bind, 4)
				makeStroke(kb.Bind, th.buttonBorder, 1)

				kb.Bind.MouseButton1Down:Connect(function()
					kb.Bind.Text = "[...]"
					kb.Bind.TextColor3 = th.accent
				end)

				function kb:Set(value)
					kb.value = value
					kb.Bind.Text = keybindToText(value)
					kb.Bind.TextColor3 = th.textSecondary
					if kb.flag ~= "" then library.flags[kb.flag] = value end
					pcall(kb.newkeycallback, value)
				end
				function kb:Get() return kb.value end

				uis.InputBegan:Connect(function(input, gp)
					if not gp then
						if kb.Bind.Text == "[...]" then
							kb:Set(inputToKeybindValue(input))
						elseif inputMatchesKeybind(input, kb.value) then
							pcall(kb.callback)
						end
					end
				end)

				sector:FixSize()
				table.insert(library.items, kb)
				return kb
			end

			-- ================================================================
			-- AddColorpicker (sector level)
			-- ================================================================
			function sector:AddColorpicker(text, default, callback, flag)
				local cp = {}
				cp.text     = text or ""
				cp.value    = default or Color3.fromRGB(255, 255, 255)
				cp.callback = callback or function() end
				cp.flag     = flag or text or ""
				if cp.flag ~= "" then library.flags[cp.flag] = cp.value end

				local row = makeRow(sector.Items, text)

				cp.Preview = Instance.new("TextButton", row)
				cp.Preview.Size = UDim2.fromOffset(20, 16)
				cp.Preview.Position = UDim2.new(1, -30, 0.5, -8)
				cp.Preview.BackgroundColor3 = cp.value
				cp.Preview.BorderSizePixel  = 0
				cp.Preview.Text = ""
				cp.Preview.AutoButtonColor = false
				cp.Preview.ZIndex = 7
				makeCorner(cp.Preview, 4)
				makeStroke(cp.Preview, th.divider, 1)

				cp.MainPicker = Instance.new("Frame", cp.Preview)
				cp.MainPicker.Size = UDim2.fromOffset(180, 196)
				cp.MainPicker.Position = UDim2.fromOffset(-162, 22)
				cp.MainPicker.BackgroundColor3 = th.dropdownBg
				cp.MainPicker.BorderSizePixel  = 0
				cp.MainPicker.Visible = false
				cp.MainPicker.ZIndex = 120
				makeCorner(cp.MainPicker, 8)
				makeStroke(cp.MainPicker, th.accent, 1, 0.5)
				window.OpenedColorPickers[cp.MainPicker] = false

				cp.hue = Instance.new("ImageLabel", cp.MainPicker)
				cp.hue.ZIndex = 121 ; cp.hue.Position = UDim2.fromOffset(6, 6)
				cp.hue.Size = UDim2.fromOffset(168, 158)
				cp.hue.Image = "rbxassetid://4155801252"
				cp.hue.ScaleType = Enum.ScaleType.Stretch
				cp.hue.BackgroundColor3 = Color3.new(1, 0, 0)
				cp.hue.BorderSizePixel  = 0 ; makeCorner(cp.hue, 4)

				cp.hueselectorpointer = Instance.new("ImageLabel", cp.MainPicker)
				cp.hueselectorpointer.ZIndex = 122
				cp.hueselectorpointer.BackgroundTransparency = 1
				cp.hueselectorpointer.BorderSizePixel = 0
				cp.hueselectorpointer.Size = UDim2.fromOffset(8, 8)
				cp.hueselectorpointer.Image = "rbxassetid://6885856475"

				cp.selector = Instance.new("Frame", cp.MainPicker)
				cp.selector.ZIndex = 121 ; cp.selector.Position = UDim2.fromOffset(6, 172)
				cp.selector.Size = UDim2.fromOffset(168, 12)
				cp.selector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				cp.selector.BorderSizePixel  = 0 ; makeCorner(cp.selector, 4)

				cp.gradient2 = Instance.new("UIGradient", cp.selector)
				cp.gradient2.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(1,0,0)), ColorSequenceKeypoint.new(0.17, Color3.new(1,0,1)),
					ColorSequenceKeypoint.new(0.33, Color3.new(0,0,1)), ColorSequenceKeypoint.new(0.5, Color3.new(0,1,1)),
					ColorSequenceKeypoint.new(0.67, Color3.new(0,1,0)), ColorSequenceKeypoint.new(0.83, Color3.new(1,1,0)),
					ColorSequenceKeypoint.new(1, Color3.new(1,0,0))
				})

				cp.pointer2 = Instance.new("Frame", cp.selector)
				cp.pointer2.ZIndex = 122
				cp.pointer2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				cp.pointer2.Position = UDim2.fromOffset(0, 0)
				cp.pointer2.Size = UDim2.fromOffset(3, 12)
				cp.pointer2.BorderSizePixel = 0 ; makeCorner(cp.pointer2, 2)

				function cp:RefreshHue()
					local x = math.clamp((mouse.X - cp.hue.AbsolutePosition.X) / cp.hue.AbsoluteSize.X, 0, 1)
					local y = math.clamp((mouse.Y - cp.hue.AbsolutePosition.Y) / cp.hue.AbsoluteSize.Y, 0, 1)
					cp.hueselectorpointer:TweenPosition(UDim2.new(x, -4, y, -4), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.05)
					cp:Set(Color3.fromHSV(cp.color or 0, x, 1 - y))
				end
				function cp:RefreshSelector()
					local pos = math.clamp((mouse.X - cp.selector.AbsolutePosition.X) / cp.selector.AbsoluteSize.X, 0, 1)
					cp.color = 1 - pos
					cp.pointer2:TweenPosition(UDim2.new(pos, -1, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.05)
					cp.hue.BackgroundColor3 = Color3.fromHSV(1 - pos, 1, 1)
				end
				function cp:Set(value)
					local c = Color3.new(math.clamp(value.R, 0, 1), math.clamp(value.G, 0, 1), math.clamp(value.B, 0, 1))
					cp.value = c ; cp.Preview.BackgroundColor3 = c
					if cp.flag ~= "" then library.flags[cp.flag] = c end
					pcall(cp.callback, c)
				end
				function cp:Get() return cp.value end
				cp:Set(cp.value)

				local dh, ds = false, false
				cp.hue.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dh = true ; cp:RefreshHue() end end)
				cp.hue.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dh = false end end)
				cp.selector.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then ds = true ; cp:RefreshSelector() end end)
				cp.selector.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then ds = false end end)
				uis.InputChanged:Connect(function(i)
					if dh and i.UserInputType == Enum.UserInputType.MouseMovement then cp:RefreshHue() end
					if ds and i.UserInputType == Enum.UserInputType.MouseMovement then cp:RefreshSelector() end
				end)

				cp.Preview.MouseButton1Down:Connect(function()
					local vis = not cp.MainPicker.Visible
					for k, v in pairs(window.OpenedColorPickers) do
						if v then k.Visible = false ; window.OpenedColorPickers[k] = false end
					end
					cp.MainPicker.Visible = vis
					window.OpenedColorPickers[cp.MainPicker] = vis
				end)

				sector:FixSize()
				table.insert(library.items, cp)
				return cp
			end

			-- ================================================================
			-- AddSeperator
			-- ================================================================
			function sector:AddSeperator(text)
				local sep = {}

				local row = Instance.new("Frame", sector.Items)
				row.Size = UDim2.fromOffset(cW, 20)
				row.BackgroundTransparency = 1
				row.BorderSizePixel = 0
				row.ZIndex = 6

				local line = Instance.new("Frame", row)
				line.Size = UDim2.fromOffset(cW - 20, 1)
				line.Position = UDim2.fromOffset(10, 10)
				line.BackgroundColor3 = th.divider
				line.BorderSizePixel  = 0
				line.ZIndex = 7

				if text and text ~= "" then
					local lbl = Instance.new("TextLabel", row)
					lbl.Size = UDim2.fromOffset(cW - 20, 20)
					lbl.Position = UDim2.fromOffset(10, 0)
					lbl.BackgroundTransparency = 1
					lbl.Font = th.fontBold
					lbl.TextSize = 10
					lbl.Text = text:upper()
					lbl.TextColor3 = th.textLabel
					lbl.TextXAlignment = Enum.TextXAlignment.Center
					lbl.ZIndex = 7

					-- Fond blanc derrière le texte
					local bg = Instance.new("Frame", row)
					bg.Size = UDim2.fromOffset(textservice:GetTextSize(text:upper(), 10, th.fontBold, Vector2.new(200,200)).X + 12, 12)
					bg.Position = UDim2.new(0.5, -bg.Size.X.Offset/2, 0, 4)
					bg.BackgroundColor3 = th.sectorBg
					bg.BorderSizePixel  = 0
					bg.ZIndex = 6
				end

				sep.Main = row
				sector:FixSize()
				return sep
			end

			table.insert(sector, sector)
			return sector
		end

		return tab
	end

	-- ============================================================
	-- Onglet Settings automatique
	-- ============================================================
	window:AddSidebarSection("SYSTEM")
	local settingsTab = window:CreateTab("Settings", "⚙")
	local settingsSector = settingsTab:CreateSector("Keybind")
	settingsSector:AddKeybind("Hide / Show", window.hidekey,
		function(k) if k ~= "None" then window.hidekey = k end end,
		function() end, "settings_hide_key"
	)

	local colorSector = settingsTab:CreateSector("UI Colors")
	colorSector:AddColorpicker("Accent Color",    th.accent,         function(c) library.theme.accent = c end, "settings_accent")
	colorSector:AddColorpicker("Background",      th.contentBg,      function(c) library.theme.contentBg = c end, "settings_contentbg")
	colorSector:AddColorpicker("Sidebar",         th.sidebarBg,      function(c) library.theme.sidebarBg = c end, "settings_sidebarbg")

	return window
end

return library
