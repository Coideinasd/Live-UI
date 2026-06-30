--[[
	FluentLib - Windows 11 Inspired CoreGui Library
	Tác giả: Claude
	Mô tả: Thư viện UI lấy cảm hứng từ Windows 11 (Fluent Design / Mica / Acrylic)
	       với animation mượt cho mọi thành phần.

	Thành phần hỗ trợ:
		- Window / Tab (có thanh tìm kiếm riêng cho từng Tab)
		- Toggle (có mũi tên mở rộng Config Toggle con)
		- Dropdown (Single / Multi) dùng List_Table làm nguồn dữ liệu
		- Slider
		- Textbox
		- Button

	Cách dùng cơ bản ở cuối file (phần Example, có thể xoá khi dùng thật).
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

----------------------------------------------------------------
-- THEME (Windows 11 Fluent Palette)
----------------------------------------------------------------
local Theme = {
	Accent          = Color3.fromRGB(0, 120, 215),
	AccentLight     = Color3.fromRGB(76, 169, 255),
	Background      = Color3.fromRGB(32, 32, 32),
	Mica            = Color3.fromRGB(40, 40, 40),
	Card            = Color3.fromRGB(45, 45, 45),
	CardHover       = Color3.fromRGB(54, 54, 54),
	Stroke          = Color3.fromRGB(63, 63, 63),
	TextPrimary     = Color3.fromRGB(245, 245, 245),
	TextSecondary   = Color3.fromRGB(170, 170, 170),
	Success         = Color3.fromRGB(108, 203, 95),
	Danger          = Color3.fromRGB(232, 17, 35),
	Font            = Enum.Font.GothamMedium,
	FontBold        = Enum.Font.GothamBold,
}

----------------------------------------------------------------
-- UTIL
----------------------------------------------------------------
local function create(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	for _, c in ipairs(children or {}) do
		c.Parent = inst
	end
	return inst
end

local function tween(obj, info, props)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local EASE = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local EASE_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local EASE_SPRING = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function corner(parent, radius)
	create("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = parent })
end

local function stroke(parent, color, thickness, transparency)
	create("UIStroke", {
		Color = color or Theme.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		Parent = parent,
	})
end

local function padding(parent, all)
	create("UIPadding", {
		PaddingTop = UDim.new(0, all), PaddingBottom = UDim.new(0, all),
		PaddingLeft = UDim.new(0, all), PaddingRight = UDim.new(0, all),
		Parent = parent,
	})
end

-- Ripple effect (Win11 click feedback)
local function ripple(button, x, y)
	local rip = create("Frame", {
		Name = "Ripple",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.7,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(0, 0),
		ZIndex = 50,
		Parent = button,
	})
	corner(rip, 999)
	local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
	tween(rip, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(maxSize, maxSize),
		BackgroundTransparency = 1,
	})
	task.delay(0.5, function() rip:Destroy() end)
end

local function hoverFeedback(obj, baseColor, hoverColor)
	obj.MouseEnter:Connect(function()
		tween(obj, EASE_FAST, { BackgroundColor3 = hoverColor })
	end)
	obj.MouseLeave:Connect(function()
		tween(obj, EASE_FAST, { BackgroundColor3 = baseColor })
	end)
end

----------------------------------------------------------------
-- LIBRARY ROOT
----------------------------------------------------------------
local Library = {}
Library.__index = Library

function Library.new(title)
	local self = setmetatable({}, Library)

	local gui = create("ScreenGui", {
		Name = "FluentLib_" .. tostring(math.random(1, 99999)),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	})

	local ok = pcall(function()
		gui.Parent = game:GetService("CoreGui")
	end)
	if not ok then
		gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end

	self.Gui = gui
	self.Tabs = {}
	self.ActiveTab = nil

	-- MAIN WINDOW (Mica acrylic look)
	local main = create("Frame", {
		Name = "Main",
		Size = UDim2.fromOffset(620, 420),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Background,
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = gui,
	})
	corner(main, 12)
	stroke(main, Theme.Stroke, 1, 0.2)
	self.Main = main

	-- Subtle mica noise overlay
	create("Frame", {
		Name = "MicaOverlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Mica,
		BackgroundTransparency = 0.4,
		ZIndex = 0,
		Parent = main,
	})

	-- TITLEBAR
	local titleBar = create("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
		Parent = main,
	})
	create("TextLabel", {
		Text = title or "Fluent Library",
		Font = Theme.FontBold,
		TextSize = 16,
		TextColor3 = Theme.TextPrimary,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.new(1, -120, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = titleBar,
	})

	local closeBtn = create("TextButton", {
		Text = "✕",
		Font = Theme.Font,
		TextSize = 14,
		TextColor3 = Theme.TextSecondary,
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(32, 32),
		Position = UDim2.new(1, -42, 0, 6),
		Parent = titleBar,
	})
	corner(closeBtn, 6)
	hoverFeedback(closeBtn, Theme.Background, Theme.Danger)
	closeBtn.MouseButton1Click:Connect(function()
		tween(main, EASE, { Size = UDim2.fromOffset(620, 0), BackgroundTransparency = 1 })
		task.wait(0.3)
		gui:Destroy()
	end)

	-- DRAG
	do
		local dragging, dragStart, startPos
		titleBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = main.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	end

	-- SIDEBAR (Tab list)
	local sidebar = create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 150, 1, -44),
		Position = UDim2.fromOffset(0, 44),
		BackgroundTransparency = 1,
		Parent = main,
	})
	local sidebarList = create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = sidebar,
	})
	padding(sidebar, 10)
	self.Sidebar = sidebar

	create("Frame", {
		Name = "Divider",
		Size = UDim2.new(0, 1, 1, -44),
		Position = UDim2.fromOffset(150, 44),
		BackgroundColor3 = Theme.Stroke,
		BackgroundTransparency = 0.5,
		Parent = main,
	})

	-- CONTENT AREA
	local content = create("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -151, 1, -44),
		Position = UDim2.fromOffset(151, 44),
		BackgroundTransparency = 1,
		Parent = main,
	})
	self.Content = content

	-- Opening animation
	main.Size = UDim2.fromOffset(620, 0)
	tween(main, EASE_SPRING, { Size = UDim2.fromOffset(620, 420), BackgroundTransparency = 0 })

	-- Toggle UI with key
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Enum.KeyCode.RightShift then
			self.Main.Visible = not self.Main.Visible
		end
	end)

	return self
end

----------------------------------------------------------------
-- TAB
----------------------------------------------------------------
function Library:CreateTab(name, icon)
	local self_ = self
	local tabBtn = create("TextButton", {
		Name = name,
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 1,
		Parent = self.Sidebar,
	})
	corner(tabBtn, 8)
	local label = create("TextLabel", {
		Text = (icon and (icon .. "  ") or "") .. name,
		Font = Theme.Font,
		TextSize = 14,
		TextColor3 = Theme.TextSecondary,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = tabBtn,
	})
	local indicator = create("Frame", {
		Name = "Indicator",
		Size = UDim2.new(0, 3, 0, 0),
		Position = UDim2.fromOffset(0, 18),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Theme.Accent,
		Parent = tabBtn,
	})
	corner(indicator, 2)

	-- Page (scrolling frame)
	local page = create("Frame", {
		Name = name .. "_Page",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = self.Content,
	})

	-- Search bar for this tab
	local searchBox = create("TextBox", {
		Name = "Search",
		PlaceholderText = "🔍 Tìm kiếm trong " .. name .. "...",
		Text = "",
		Font = Theme.Font,
		TextSize = 13,
		TextColor3 = Theme.TextPrimary,
		PlaceholderColor3 = Theme.TextSecondary,
		BackgroundColor3 = Theme.Card,
		Size = UDim2.new(1, -20, 0, 34),
		Position = UDim2.fromOffset(10, 10),
		ClearTextOnFocus = false,
		Parent = page,
	})
	corner(searchBox, 8)
	stroke(searchBox, Theme.Stroke, 1, 0.3)
	padding(searchBox, 8)

	local scroller = create("ScrollingFrame", {
		Name = "Scroller",
		Size = UDim2.new(1, -20, 1, -56),
		Position = UDim2.fromOffset(10, 52),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = page,
	})
	local layout = create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = scroller,
	})

	local Tab = {
		Button = tabBtn,
		Page = page,
		Scroller = scroller,
		Elements = {}, -- {Frame, searchableText}
	}

	-- Search filter logic (lọc các phần tử trong tab theo tên)
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local q = searchBox.Text:lower()
		for _, el in ipairs(Tab.Elements) do
			local match = q == "" or el.SearchText:lower():find(q, 1, true)
			el.Frame.Visible = match and true or false
		end
	end)

	local function selectTab()
		for _, t in pairs(self_.Tabs) do
			t.Page.Visible = false
			tween(t.Button, EASE_FAST, { BackgroundTransparency = 1 })
			tween(t.Button.Indicator, EASE_FAST, { Size = UDim2.new(0, 3, 0, 0) })
			tween(t.Button:FindFirstChildOfClass("TextLabel"), EASE_FAST, { TextColor3 = Theme.TextSecondary })
		end
		page.Visible = true
		page.Position = UDim2.fromOffset(10, 0)
		page.BackgroundTransparency = 1
		tween(tabBtn, EASE_FAST, { BackgroundTransparency = 0.4, BackgroundColor3 = Theme.CardHover })
		tween(indicator, EASE_FAST, { Size = UDim2.new(0, 3, 0, 20) })
		tween(label, EASE_FAST, { TextColor3 = Theme.TextPrimary })
		self_.ActiveTab = Tab
	end

	tabBtn.MouseButton1Click:Connect(selectTab)
	hoverFeedback(tabBtn, Theme.Card, Theme.CardHover)
	tabBtn.BackgroundTransparency = 1

	table.insert(self.Tabs, Tab)
	if #self.Tabs == 1 then selectTab() end

	----------------------------------------------------------------
	-- helper: tạo card chuẩn Win11 cho mỗi element
	----------------------------------------------------------------
	local function newCard(height)
		local card = create("Frame", {
			Size = UDim2.new(1, 0, 0, height),
			BackgroundColor3 = Theme.Card,
			ClipsDescendants = true,
			Parent = scroller,
		})
		corner(card, 10)
		stroke(card, Theme.Stroke, 1, 0.4)
		return card
	end

	----------------------------------------------------------------
	-- TOGGLE (với mũi tên mở Config Toggle con)
	----------------------------------------------------------------
	function Tab:CreateToggle(opts)
		opts = opts or {}
		local name = opts.Name or "Toggle"
		local default = opts.Default or false
		local callback = opts.Callback or function() end
		local hasConfig = opts.Config ~= nil -- opts.Config = { {Name=, Type="Slider"/"Textbox"/"Dropdown", ...} }

		local state = default
		local expanded = false

		local card = newCard(44)

		local row = create("Frame", {
			Size = UDim2.new(1, 0, 0, 44),
			BackgroundTransparency = 1,
			Parent = card,
		})

		create("TextLabel", {
			Text = name,
			Font = Theme.Font,
			TextSize = 14,
			TextColor3 = Theme.TextPrimary,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -110, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})

		-- Switch (Win11 toggle style)
		local switchBg = create("Frame", {
			Size = UDim2.fromOffset(42, 22),
			Position = UDim2.new(1, hasConfig and -76 or -56, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = state and Theme.Accent or Theme.Stroke,
			Parent = row,
		})
		corner(switchBg, 11)
		local knob = create("Frame", {
			Size = UDim2.fromOffset(16, 16),
			Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = switchBg,
		})
		corner(knob, 8)

		local switchBtn = create("TextButton", {
			Text = "",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(42, 22),
			Position = switchBg.Position,
			AnchorPoint = Vector2.new(0, 0.5),
			Parent = row,
		})

		local function setState(v, fireCallback)
			state = v
			tween(switchBg, EASE_FAST, { BackgroundColor3 = state and Theme.Accent or Theme.Stroke })
			tween(knob, EASE_FAST, { Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) })
			if fireCallback ~= false then
				task.spawn(callback, state)
			end
		end

		switchBtn.MouseButton1Click:Connect(function() setState(not state) end)

		-- Config arrow
		local configFrame
		if hasConfig then
			local arrowBtn = create("TextButton", {
				Text = "▾",
				Font = Theme.FontBold,
				TextSize = 14,
				TextColor3 = Theme.TextSecondary,
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(28, 28),
				Position = UDim2.new(1, -30, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Parent = row,
			})

			configFrame = create("Frame", {
				Size = UDim2.new(1, -20, 0, 0),
				Position = UDim2.fromOffset(10, 44),
				BackgroundColor3 = Theme.Background,
				BackgroundTransparency = 0.2,
				ClipsDescendants = true,
				Parent = card,
			})
			corner(configFrame, 8)
			local configLayout = create("UIListLayout", {
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = configFrame,
			})
			padding(configFrame, 8)

			-- Build inner config controls (sub toggle / slider / textbox / dropdown)
			for _, c in ipairs(opts.Config or {}) do
				local sub = create("Frame", {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 1,
					Parent = configFrame,
				})
				create("TextLabel", {
					Text = c.Name or "Sub option",
					Font = Theme.Font,
					TextSize = 13,
					TextColor3 = Theme.TextSecondary,
					BackgroundTransparency = 1,
					Size = UDim2.new(0.5, 0, 1, 0),
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = sub,
				})

				if c.Type == "Toggle" then
					local subState = c.Default or false
					local subSwitchBg = create("Frame", {
						Size = UDim2.fromOffset(36, 18),
						Position = UDim2.new(1, -36, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = subState and Theme.Accent or Theme.Stroke,
						Parent = sub,
					})
					corner(subSwitchBg, 9)
					local subKnob = create("Frame", {
						Size = UDim2.fromOffset(14, 14),
						Position = subState and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = Color3.new(1, 1, 1),
						Parent = subSwitchBg,
					})
					corner(subKnob, 7)
					local subBtn = create("TextButton", {
						Text = "", BackgroundTransparency = 1, Size = UDim2.fromOffset(36, 18),
						Position = subSwitchBg.Position, AnchorPoint = Vector2.new(0, 0.5), Parent = sub,
					})
					subBtn.MouseButton1Click:Connect(function()
						subState = not subState
						tween(subSwitchBg, EASE_FAST, { BackgroundColor3 = subState and Theme.Accent or Theme.Stroke })
						tween(subKnob, EASE_FAST, { Position = subState and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) })
						if c.Callback then task.spawn(c.Callback, subState) end
					end)

				elseif c.Type == "Slider" then
					local min, max = c.Min or 0, c.Max or 100
					local val = c.Default or min
					local track = create("Frame", {
						Size = UDim2.new(0.45, 0, 0, 6),
						Position = UDim2.new(1, -0, 0.5, 0),
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundColor3 = Theme.Stroke,
						Parent = sub,
					})
					corner(track, 3)
					local fill = create("Frame", {
						Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
						BackgroundColor3 = Theme.Accent,
						Parent = track,
					})
					corner(fill, 3)
					local dragging = false
					track.InputBegan:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
					end)
					UserInputService.InputEnded:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
					end)
					RunService.RenderStepped:Connect(function()
						if dragging then
							local rel = math.clamp((Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
							val = math.floor(min + (max - min) * rel)
							fill.Size = UDim2.new(rel, 0, 1, 0)
							if c.Callback then task.spawn(c.Callback, val) end
						end
					end)

				elseif c.Type == "Textbox" then
					local tb = create("TextBox", {
						Text = c.Default or "",
						PlaceholderText = c.Placeholder or "",
						Font = Theme.Font, TextSize = 12, TextColor3 = Theme.TextPrimary,
						BackgroundColor3 = Theme.Card,
						Size = UDim2.new(0.45, 0, 0, 24),
						Position = UDim2.new(1, 0, 0.5, 0),
						AnchorPoint = Vector2.new(1, 0.5),
						Parent = sub,
					})
					corner(tb, 6)
					padding(tb, 4)
					tb.FocusLost:Connect(function()
						if c.Callback then task.spawn(c.Callback, tb.Text) end
					end)
				end
			end

			local targetHeight = 0
			local arrowOpen = false
			arrowBtn.MouseButton1Click:Connect(function()
				arrowOpen = not arrowOpen
				local listH = configFrame.UIListLayout and 0 or 0
				local contentHeight = #(opts.Config or {}) * 36 + 16
				tween(arrowBtn, EASE_FAST, { Rotation = arrowOpen and 180 or 0 })
				tween(configFrame, EASE, { Size = UDim2.new(1, -20, 0, arrowOpen and contentHeight or 0) })
				tween(card, EASE, { Size = UDim2.new(1, 0, 0, arrowOpen and (44 + contentHeight) or 44) })
			end)
		end

		setState(default, false)

		local frameRef = card
		table.insert(self.Elements, { Frame = frameRef, SearchText = name })
		return {
			Set = function(_, v) setState(v) end,
			Get = function() return state end,
		}
	end

	----------------------------------------------------------------
	-- DROPDOWN (Single / Multi) dùng List_Table
	----------------------------------------------------------------
	function Tab:CreateDropdown(opts)
		opts = opts or {}
		local name = opts.Name or "Dropdown"
		local list = opts.List_Table or opts.List or {}
		local multi = opts.Multi or false
		local callback = opts.Callback or function() end
		local selected = {}

		if opts.Default then
			if multi and typeof(opts.Default) == "table" then
				for _, v in ipairs(opts.Default) do selected[v] = true end
			elseif not multi then
				selected[opts.Default] = true
			end
		end

		local card = newCard(44)
		local header = create("TextButton", {
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 44),
			BackgroundTransparency = 1,
			Parent = card,
		})
		create("TextLabel", {
			Text = name,
			Font = Theme.Font, TextSize = 14, TextColor3 = Theme.TextPrimary,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -160, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = header,
		})
		local selectedLabel = create("TextLabel", {
			Text = "Chọn...",
			Font = Theme.Font, TextSize = 13, TextColor3 = Theme.TextSecondary,
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -150, 0, 0),
			Size = UDim2.new(0, 110, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = header,
		})
		local arrow = create("TextLabel", {
			Text = "▾",
			Font = Theme.FontBold, TextSize = 14, TextColor3 = Theme.TextSecondary,
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -28, 0, 0),
			Size = UDim2.new(0, 28, 1, 0),
			Parent = header,
		})

		local listFrame = create("Frame", {
			Size = UDim2.new(1, -20, 0, 0),
			Position = UDim2.fromOffset(10, 44),
			BackgroundColor3 = Theme.Background,
			BackgroundTransparency = 0.2,
			ClipsDescendants = true,
			Parent = card,
		})
		corner(listFrame, 8)
		local listLayout = create("UIListLayout", {
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = listFrame,
		})
		padding(listFrame, 6)

		local function refreshLabel()
			local names = {}
			for k, v in pairs(selected) do
				if v then table.insert(names, tostring(k)) end
			end
			selectedLabel.Text = (#names == 0) and "Chọn..." or table.concat(names, ", ")
		end

		local optionButtons = {}
		local function buildOptions()
			for _, b in ipairs(optionButtons) do b:Destroy() end
			optionButtons = {}
			for _, item in ipairs(list) do
				local optBtn = create("TextButton", {
					Text = "",
					AutoButtonColor = false,
					Size = UDim2.new(1, 0, 0, 28),
					BackgroundColor3 = Theme.Card,
					BackgroundTransparency = selected[item] and 0.2 or 1,
					Parent = listFrame,
				})
				corner(optBtn, 6)
				create("TextLabel", {
					Text = tostring(item),
					Font = Theme.Font, TextSize = 13,
					TextColor3 = selected[item] and Theme.AccentLight or Theme.TextSecondary,
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(8, 0),
					Size = UDim2.new(1, -16, 1, 0),
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = optBtn,
				})
				optBtn.MouseButton1Click:Connect(function()
					if multi then
						selected[item] = not selected[item]
					else
						for k in pairs(selected) do selected[k] = false end
						selected[item] = true
					end
					buildOptions()
					refreshLabel()
					local result
					if multi then
						result = {}
						for k, v in pairs(selected) do if v then table.insert(result, k) end end
					else
						result = item
					end
					task.spawn(callback, result)
				end)
				table.insert(optionButtons, optBtn)
			end
		end
		buildOptions()
		refreshLabel()

		local open = false
		header.MouseButton1Click:Connect(function()
			open = not open
			local h = #list * 32 + 12
			tween(arrow, EASE_FAST, { Rotation = open and 180 or 0 })
			tween(listFrame, EASE, { Size = UDim2.new(1, -20, 0, open and h or 0) })
			tween(card, EASE, { Size = UDim2.new(1, 0, 0, open and (44 + h) or 44) })
		end)

		table.insert(self.Elements, { Frame = card, SearchText = name })
		return {
			Refresh = function(_, newList)
				list = newList
				buildOptions()
			end,
			Get = function() return selected end,
		}
	end

	----------------------------------------------------------------
	-- SLIDER
	----------------------------------------------------------------
	function Tab:CreateSlider(opts)
		opts = opts or {}
		local name = opts.Name or "Slider"
		local min, max = opts.Min or 0, opts.Max or 100
		local default = math.clamp(opts.Default or min, min, max)
		local suffix = opts.Suffix or ""
		local callback = opts.Callback or function() end

		local card = newCard(50)
		create("TextLabel", {
			Text = name,
			Font = Theme.Font, TextSize = 14, TextColor3 = Theme.TextPrimary,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 6),
			Size = UDim2.new(1, -100, 0, 18),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = card,
		})
		local valueLabel = create("TextLabel", {
			Text = tostring(default) .. suffix,
			Font = Theme.Font, TextSize = 13, TextColor3 = Theme.Accent,
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -80, 0, 6),
			Size = UDim2.new(0, 66, 0, 18),
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = card,
		})

		local track = create("Frame", {
			Size = UDim2.new(1, -28, 0, 8),
			Position = UDim2.fromOffset(14, 32),
			BackgroundColor3 = Theme.Stroke,
			Parent = card,
		})
		corner(track, 4)
		local fill = create("Frame", {
			Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
			BackgroundColor3 = Theme.Accent,
			Parent = track,
		})
		corner(fill, 4)
		local knob = create("Frame", {
			Size = UDim2.fromOffset(16, 16),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			ZIndex = 2,
			Parent = track,
		})
		corner(knob, 8)
		stroke(knob, Theme.Accent, 2)

		local dragging = false
		local value = default

		local function update(rel)
			rel = math.clamp(rel, 0, 1)
			value = math.floor(min + (max - min) * rel + 0.5)
			tween(fill, EASE_FAST, { Size = UDim2.new(rel, 0, 1, 0) })
			tween(knob, EASE_FAST, { Position = UDim2.new(rel, 0, 0.5, 0) })
			valueLabel.Text = tostring(value) .. suffix
			task.spawn(callback, value)
		end

		track.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				local rel = (Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
				update(rel)
				tween(knob, EASE_FAST, { Size = UDim2.fromOffset(20, 20) })
			end
		end)
		UserInputService.InputEnded:Connect(function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
				dragging = false
				tween(knob, EASE_FAST, { Size = UDim2.fromOffset(16, 16) })
			end
		end)
		RunService.RenderStepped:Connect(function()
			if dragging then
				local rel = (Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
				update(rel)
			end
		end)

		table.insert(self.Elements, { Frame = card, SearchText = name })
		return {
			Set = function(_, v) update((v - min) / (max - min)) end,
			Get = function() return value end,
		}
	end

	----------------------------------------------------------------
	-- TEXTBOX
	----------------------------------------------------------------
	function Tab:CreateTextbox(opts)
		opts = opts or {}
		local name = opts.Name or "Textbox"
		local placeholder = opts.Placeholder or "Nhập..."
		local callback = opts.Callback or function() end

		local card = newCard(44)
		create("TextLabel", {
			Text = name,
			Font = Theme.Font, TextSize = 14, TextColor3 = Theme.TextPrimary,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(0.4, 0, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = card,
		})
		local box = create("TextBox", {
			Text = opts.Default or "",
			PlaceholderText = placeholder,
			PlaceholderColor3 = Theme.TextSecondary,
			Font = Theme.Font, TextSize = 13, TextColor3 = Theme.TextPrimary,
			BackgroundColor3 = Theme.Background,
			ClearTextOnFocus = false,
			Size = UDim2.new(0.5, -10, 0, 30),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Parent = card,
		})
		corner(box, 6)
		stroke(box, Theme.Stroke, 1, 0.4)
		padding(box, 6)

		box.Focused:Connect(function()
			tween(box.UIStroke, EASE_FAST, { Color = Theme.Accent, Transparency = 0 })
		end)
		box.FocusLost:Connect(function(enter)
			tween(box.UIStroke, EASE_FAST, { Color = Theme.Stroke, Transparency = 0.4 })
			task.spawn(callback, box.Text, enter)
		end)

		table.insert(self.Elements, { Frame = card, SearchText = name })
		return {
			Set = function(_, v) box.Text = v end,
			Get = function() return box.Text end,
		}
	end

	----------------------------------------------------------------
	-- BUTTON
	----------------------------------------------------------------
	function Tab:CreateButton(opts)
		opts = opts or {}
		local name = opts.Name or "Button"
		local callback = opts.Callback or function() end

		local card = newCard(40)
		local btn = create("TextButton", {
			Text = name,
			AutoButtonColor = false,
			Font = Theme.FontBold, TextSize = 14, TextColor3 = Theme.TextPrimary,
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -16, 1, -10),
			Position = UDim2.fromOffset(8, 5),
			ClipsDescendants = true,
			Parent = card,
		})
		corner(btn, 8)

		btn.MouseEnter:Connect(function()
			tween(btn, EASE_FAST, { BackgroundColor3 = Theme.CardHover })
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, EASE_FAST, { BackgroundColor3 = Theme.Accent })
		end)
		btn.MouseButton1Down:Connect(function()
			tween(btn, EASE_FAST, { Size = UDim2.new(1, -20, 1, -14), Position = UDim2.fromOffset(10, 7) })
		end)
		btn.MouseButton1Up:Connect(function()
			tween(btn, EASE_FAST, { Size = UDim2.new(1, -16, 1, -10), Position = UDim2.fromOffset(8, 5) })
		end)
		btn.MouseButton1Click:Connect(function(x, y)
			ripple(btn, Mouse.X - btn.AbsolutePosition.X, Mouse.Y - btn.AbsolutePosition.Y)
			task.spawn(callback)
		end)
		btn.BackgroundTransparency = 0

		table.insert(self.Elements, { Frame = card, SearchText = name })
		return { }
	end

	return Tab
end

return Library
