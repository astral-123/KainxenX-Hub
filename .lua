local library = {flags = {}, items = {}}
local players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local tweenservice = game:GetService("TweenService")
local coregui = game:GetService("CoreGui")
local player = players.LocalPlayer
local mouse = player:GetMouse()

library.theme = {
	font = Enum.Font.GothamMedium,
	fontBold = Enum.Font.GothamBold,
	windowBg = Color3.fromRGB(15, 17, 26),
	sidebarBg = Color3.fromRGB(20, 23, 34),
	sectorBg = Color3.fromRGB(22, 26, 38),
	sidebarWidth = 140,
	tabActive = Color3.fromRGB(28, 32, 48),
	accent = Color3.fromRGB(100, 130, 255),
	textPrimary = Color3.fromRGB(255, 255, 255),
	textSecondary = Color3.fromRGB(130, 135, 155),
	textLabel = Color3.fromRGB(80, 85, 105),
	toggleOff = Color3.fromRGB(35, 40, 55),
	toggleOn = Color3.fromRGB(100, 130, 255),
	sliderBg = Color3.fromRGB(35, 40, 55),
	sliderFill = Color3.fromRGB(100, 130, 255),
	buttonBg = Color3.fromRGB(28, 32, 48),
	divider = Color3.fromRGB(40, 45, 60),
}

local function makeTween(obj, props, t)
	tweenservice:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function makeCorner(parent, radius)
	local c = Instance.new("UICorner", parent)
	c.CornerRadius = UDim.new(0, radius or 4)
	return c
end

local function makeStroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke", parent)
	s.Color = color or Color3.fromRGB(50, 58, 82)
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	return s
end

local mouse_buttons = {
	[Enum.UserInputType.MouseButton1] = "MB1",
	[Enum.UserInputType.MouseButton2] = "MB2",
	[Enum.UserInputType.MouseButton3] = "MB3",
}

function library:CreateWindow(name, size, hidekey)
	local th = library.theme
	local window = {Tabs = {}, hidekey = hidekey or Enum.KeyCode.RightShift}
	window.Main = Instance.new("ScreenGui", coregui)
	window.Main.Name = "MaxHubUI"
	if getgenv().uilib then getgenv().uilib:Destroy() end
	getgenv().uilib = window.Main
	local W, H = (size and size.X) or 600, (size and size.Y) or 400
	window.Frame = Instance.new("Frame", window.Main)
	window.Frame.Size = UDim2.fromOffset(W, H)
	window.Frame.Position = UDim2.fromScale(0.5, 0.5)
	window.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	window.Frame.BackgroundColor3 = th.windowBg
	window.Frame.BorderSizePixel = 0
	makeCorner(window.Frame, 6)
	makeStroke(window.Frame, Color3.fromRGB(255, 255, 255), 1, 0.8)
	local topControls = Instance.new("Frame", window.Frame)
	topControls.Size = UDim2.fromOffset(60, 30)
	topControls.Position = UDim2.new(1, -65, 0, 5)
	topControls.BackgroundTransparency = 1
	topControls.ZIndex = 10
	local closeBtn = Instance.new("TextButton", topControls)
	closeBtn.Size = UDim2.fromOffset(25, 25)
	closeBtn.Position = UDim2.fromOffset(30, 0)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "x"
	closeBtn.TextColor3 = th.textSecondary
	closeBtn.TextSize = 20
	closeBtn.Font = th.fontBold
	closeBtn.MouseButton1Down:Connect(function() window.Main:Destroy() end)
	local minBtn = Instance.new("TextButton", topControls)
	minBtn.Size = UDim2.fromOffset(25, 25)
	minBtn.Position = UDim2.fromOffset(0, 0)
	minBtn.BackgroundTransparency = 1
	minBtn.Text = "-"
	minBtn.TextColor3 = th.textSecondary
	minBtn.TextSize = 20
	minBtn.Font = th.fontBold
	local minimized = false
	minBtn.MouseButton1Down:Connect(function()
		minimized = not minimized
		makeTween(window.Frame, {Size = minimized and UDim2.fromOffset(W, 40) or UDim2.fromOffset(W, H)}, 0.3)
		window.ContentArea.Visible = not minimized
		window.Sidebar.Visible = not minimized
	end)
	window.Sidebar = Instance.new("Frame", window.Frame)
	window.Sidebar.Size = UDim2.new(0, th.sidebarWidth, 1, 0)
	window.Sidebar.BackgroundColor3 = th.sidebarBg
	window.Sidebar.BorderSizePixel = 0
	makeCorner(window.Sidebar, 6)
	local sideTitle = Instance.new("TextLabel", window.Sidebar)
	sideTitle.Size = UDim2.new(1, 0, 0, 40)
	sideTitle.Position = UDim2.fromOffset(15, 10)
	sideTitle.BackgroundTransparency = 1
	sideTitle.Font = th.fontBold
	sideTitle.TextSize = 16
	sideTitle.Text = name
	sideTitle.TextColor3 = th.textPrimary
	sideTitle.TextXAlignment = Enum.TextXAlignment.Left
	window.TabContainer = Instance.new("ScrollingFrame", window.Sidebar)
	window.TabContainer.Size = UDim2.new(1, 0, 1, -50)
	window.TabContainer.Position = UDim2.fromOffset(0, 50)
	window.TabContainer.BackgroundTransparency = 1
	window.TabContainer.BorderSizePixel = 0
	window.TabContainer.ScrollBarThickness = 0
	local tabLayout = Instance.new("UIListLayout", window.TabContainer)
	tabLayout.Padding = UDim.new(0, 2)
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	window.ContentArea = Instance.new("Frame", window.Frame)
	window.ContentArea.Position = UDim2.fromOffset(th.sidebarWidth, 0)
	window.ContentArea.Size = UDim2.new(1, -th.sidebarWidth, 1, 0)
	window.ContentArea.BackgroundTransparency = 1
	local dragging, dragStart, startPos
	window.Frame.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 and i.Position.Y - window.Frame.AbsolutePosition.Y < 40 then
			dragging = true; dragStart = i.Position; startPos = window.Frame.Position
			i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	uis.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = i.Position - dragStart
			window.Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
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
	function window:CreateTab(name)
		local tab = {name = name}
		tab.TabBtn = Instance.new("TextButton", window.TabContainer)
		tab.TabBtn.Size = UDim2.new(1, -10, 0, 32)
		tab.TabBtn.BackgroundTransparency = 1
		tab.TabBtn.Text = ""
		tab.TabBtn.AutoButtonColor = false
		makeCorner(tab.TabBtn, 4)
		local nameLabel = Instance.new("TextLabel", tab.TabBtn)
		nameLabel.Size = UDim2.new(1, -10, 1, 0)
		nameLabel.Position = UDim2.fromOffset(10, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = th.font
		nameLabel.TextSize = 13
		nameLabel.Text = name
		nameLabel.TextColor3 = th.textSecondary
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
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
		local underline = Instance.new("Frame", tab.PageTitle)
		underline.Size = UDim2.fromOffset(30, 2)
		underline.Position = UDim2.new(0, 0, 1, -5)
		underline.BackgroundColor3 = th.accent
		underline.BorderSizePixel = 0
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
		local pad = Instance.new("UIPadding", tab.Container)
		pad.PaddingLeft = UDim.new(0, 20)
		function tab:Select()
			for _, t in pairs(window.Tabs) do
				t.TabBtn.BackgroundTransparency = 1
				t.Container.Visible = false
				t.PageTitle.Visible = false
				t._name.TextColor3 = th.textSecondary
			end
			tab.TabBtn.BackgroundTransparency = 0
			tab.TabBtn.BackgroundColor3 = th.tabActive
			tab.Container.Visible = true
			tab.PageTitle.Visible = true
			nameLabel.TextColor3 = th.textPrimary
		end
		tab._name = nameLabel
		tab.TabBtn.MouseButton1Down:Connect(function() tab:Select() end)
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
			function sector:FixSize() sector.Main.Size = UDim2.fromOffset(sW, iLayout.AbsoluteContentSize.Y + 45) end
			function sector:AddParagraph(text)
				local lbl = Instance.new("TextLabel", sector.Items)
				lbl.Size = UDim2.new(1, -20, 0, 0)
				lbl.AutomaticSize = Enum.AutomaticSize.Y
				lbl.BackgroundTransparency = 1
				lbl.Font = th.font
				lbl.TextSize = 11
				lbl.Text = text
				lbl.TextColor3 = th.textSecondary
				lbl.TextWrapped = true
				lbl.TextXAlignment = Enum.TextXAlignment.Left
				Instance.new("UIPadding", lbl).PaddingLeft = UDim.new(0, 10)
				sector:FixSize()
			end
			function sector:AddToggle(text, default, callback)
				local toggle = {value = default or false}
				local row = Instance.new("Frame", sector.Items)
				row.Size = UDim2.new(1, 0, 0, 30)
				row.BackgroundTransparency = 1
				local lbl = Instance.new("TextLabel", row)
				lbl.Size = UDim2.new(1, -70, 1, 0)
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
				btn.Size = UDim2.new(1, -45, 1, 0)
				btn.BackgroundTransparency = 1
				btn.Text = ""
				function toggle:Set(v)
					toggle.value = v
					makeTween(track, {BackgroundColor3 = v and th.toggleOn or th.toggleOff}, 0.15)
					makeTween(knob, {Position = v and UDim2.fromOffset(18, 2) or UDim2.fromOffset(2, 2)}, 0.15)
					pcall(callback, v)
				end
				btn.MouseButton1Down:Connect(function() toggle:Set(not toggle.value) end)
				toggle:Set(toggle.value)
				function toggle:AddSettings()
					local sBtn = Instance.new("TextButton", row)
					sBtn.Size = UDim2.fromOffset(20, 20)
					sBtn.Position = UDim2.new(1, -68, 0.5, -10)
					sBtn.BackgroundTransparency = 1
					sBtn.Text = "S"
					sBtn.TextColor3 = th.textSecondary
					sBtn.TextSize = 12
					local sFrame = Instance.new("Frame", window.Main)
					sFrame.Size = UDim2.fromOffset(150, 100)
					sFrame.BackgroundColor3 = th.sectorBg
					sFrame.Visible = false
					makeCorner(sFrame, 4)
					makeStroke(sFrame, th.accent, 1)
					local sLayout = Instance.new("UIListLayout", sFrame)
					Instance.new("UIPadding", sFrame).PaddingTop = UDim.new(0, 5)
					sBtn.MouseButton1Down:Connect(function()
						sFrame.Visible = not sFrame.Visible
						sFrame.Position = UDim2.fromOffset(sBtn.AbsolutePosition.X + 25, sBtn.AbsolutePosition.Y)
					end)
					local sObj = {Main = sFrame}
					function sObj:AddSlider(stext, smin, sdef, smax, scallback)
						local sl = sector:AddSlider(stext, smin, sdef, smax, scallback)
						sl.Row.Parent = sFrame
						sl.Row.Size = UDim2.new(1, 0, 0, 40)
						sFrame.Size = UDim2.fromOffset(150, sLayout.AbsoluteContentSize.Y + 10)
					end
					return sObj
				end
				sector:FixSize()
				return toggle
			end
			function sector:AddSlider(text, min, default, max, callback)
				local slider = {value = default or min}
				local row = Instance.new("Frame", sector.Items)
				row.Size = UDim2.new(1, 0, 0, 45)
				row.BackgroundTransparency = 1
				slider.Row = row
				local lbl = Instance.new("TextLabel", row)
				lbl.Size = UDim2.new(1, -50, 0, 20)
				lbl.Position = UDim2.fromOffset(10, 2)
				lbl.BackgroundTransparency = 1
				lbl.Font = th.font; lbl.TextSize = 12
				lbl.Text = text; lbl.TextColor3 = th.textSecondary; lbl.TextXAlignment = Enum.TextXAlignment.Left
				local valLbl = Instance.new("TextLabel", row)
				valLbl.Size = UDim2.new(0, 40, 0, 20)
				valLbl.Position = UDim2.new(1, -50, 0, 2)
				valLbl.BackgroundTransparency = 1
				valLbl.Font = th.font; valLbl.TextSize = 12
				valLbl.Text = tostring(slider.value); valLbl.TextColor3 = th.textSecondary; valLbl.TextXAlignment = Enum.TextXAlignment.Right
				local track = Instance.new("Frame", row)
				track.Size = UDim2.new(1, -20, 0, 4)
				track.Position = UDim2.fromOffset(10, 28)
				track.BackgroundColor3 = th.sliderBg; makeCorner(track, 2)
				local fill = Instance.new("Frame", track)
				fill.Size = UDim2.fromScale((slider.value-min)/(max-min), 1)
				fill.BackgroundColor3 = th.sliderFill; makeCorner(fill, 2)
				local btn = Instance.new("TextButton", track)
				btn.Size = UDim2.new(1, 0, 0, 20); btn.Position = UDim2.fromOffset(0, -8)
				btn.BackgroundTransparency = 1; btn.Text = ""
				local dragging = false
				local function update()
					local pct = math.clamp((mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					slider.value = math.floor(min + (max - min) * pct)
					fill.Size = UDim2.fromScale(pct, 1)
					valLbl.Text = tostring(slider.value)
					pcall(callback, slider.value)
				end
				btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update() end end)
				uis.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
				uis.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update() end end)
				sector:FixSize()
				return slider
			end
			function sector:AddTextbox(text, default, callback)
				local row = Instance.new("Frame", sector.Items)
				row.Size = UDim2.new(1, 0, 0, 50)
				row.BackgroundTransparency = 1
				local lbl = Instance.new("TextLabel", row)
				lbl.Size = UDim2.new(1, -20, 0, 20)
				lbl.Position = UDim2.fromOffset(10, 2)
				lbl.BackgroundTransparency = 1
				lbl.Font = th.font; lbl.TextSize = 12
				lbl.Text = text; lbl.TextColor3 = th.textSecondary; lbl.TextXAlignment = Enum.TextXAlignment.Left
				local box = Instance.new("TextBox", row)
				box.Size = UDim2.new(1, -20, 0, 22)
				box.Position = UDim2.fromOffset(10, 22)
				box.BackgroundColor3 = th.tabActive
				box.Font = th.font; box.TextSize = 12
				box.TextColor3 = th.textPrimary
				box.Text = default or ""
				box.PlaceholderText = "Type here..."
				makeCorner(box, 4)
				makeStroke(box, th.divider, 1)
				box.FocusLost:Connect(function() pcall(callback, box.Text) end)
				sector:FixSize()
			end
			function sector:AddKeybind(text, default, callback)
				local kb = {value = default}
				local row = Instance.new("Frame", sector.Items)
				row.Size = UDim2.new(1, 0, 0, 30)
				row.BackgroundTransparency = 1
				local lbl = Instance.new("TextLabel", row)
				lbl.Size = UDim2.new(1, -80, 1, 0)
				lbl.Position = UDim2.fromOffset(10, 0)
				lbl.BackgroundTransparency = 1
				lbl.Font = th.font; lbl.TextSize = 12
				lbl.Text = text; lbl.TextColor3 = th.textSecondary; lbl.TextXAlignment = Enum.TextXAlignment.Left
				local btn = Instance.new("TextButton", row)
				btn.Size = UDim2.fromOffset(60, 20)
				btn.Position = UDim2.new(1, -70, 0.5, -10)
				btn.BackgroundColor3 = th.tabActive
				btn.Font = th.font; btn.TextSize = 11
				btn.TextColor3 = th.textPrimary
				btn.Text = typeof(kb.value) == "EnumItem" and kb.value.Name or tostring(kb.value):gsub("Enum.UserInputType.", "")
				makeCorner(btn, 4)
				local listening = false
				btn.MouseButton1Down:Connect(function() listening = true; btn.Text = "..." end)
				uis.InputBegan:Connect(function(i)
					if listening then
						local key = i.KeyCode ~= Enum.KeyCode.Unknown and i.KeyCode or i.UserInputType
						if key == Enum.KeyCode.Keyboard then return end
						listening = false
						kb.value = key
						btn.Text = mouse_buttons[key] or tostring(key):gsub("Enum.UserInputType.", ""):gsub("Enum.KeyCode.", "")
						pcall(callback, key)
					end
				end)
				sector:FixSize()
			end
			function sector:AddButton(text, callback)
				local row = Instance.new("Frame", sector.Items)
				row.Size = UDim2.new(1, 0, 0, 35)
				row.BackgroundTransparency = 1
				local btn = Instance.new("TextButton", row)
				btn.Size = UDim2.new(1, -20, 0, 26)
				btn.Position = UDim2.fromOffset(10, 4)
				btn.BackgroundColor3 = th.buttonBg
				btn.Font = th.font; btn.TextSize = 12
				btn.Text = text; btn.TextColor3 = th.textSecondary
				btn.AutoButtonColor = false; makeCorner(btn, 4); makeStroke(btn, th.divider, 1)
				btn.MouseButton1Down:Connect(function() pcall(callback) end)
				sector:FixSize()
			end
			return sector
		end
		table.insert(window.Tabs, tab)
		if #window.Tabs == 1 then tab:Select() end
		return tab
	end
	return window
end
