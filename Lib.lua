--[[
	FluentLib - Windows 11 Inspired CoreGui Library (Fixed)
	Tác giả: Claude
	Version: 2.2 - Fixed Icons & UI
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Load icons từ Live-UI
local IconsLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Coideinasd/Live-UI/refs/heads/main/Icons.lua"))()
local Icons = IconsLib.assets

----------------------------------------------------------------
-- THEME
----------------------------------------------------------------
local Theme = {
	Accent          = Color3.fromRGB(0, 120, 215),
	AccentLight     = Color3.fromRGB(76, 169, 255),
	AccentDark      = Color3.fromRGB(0, 80, 180),
	AccentGradient1 = Color3.fromRGB(0, 120, 215),
	AccentGradient2 = Color3.fromRGB(108, 92, 231),
	
	Background      = Color3.fromRGB(28, 28, 30),
	Mica            = Color3.fromRGB(40, 40, 42),
	Glass           = Color3.fromRGB(255, 255, 255),
	
	Card            = Color3.fromRGB(38, 38, 40),
	CardHover       = Color3.fromRGB(48, 48, 50),
	CardActive      = Color3.fromRGB(58, 58, 60),
	CardBorder      = Color3.fromRGB(68, 68, 70),
	
	TextPrimary     = Color3.fromRGB(245, 245, 245),
	TextSecondary   = Color3.fromRGB(180, 180, 185),
	TextMuted       = Color3.fromRGB(130, 130, 135),
	
	Success         = Color3.fromRGB(52, 199, 89),
	Danger          = Color3.fromRGB(255, 69, 58),
	Warning         = Color3.fromRGB(255, 185, 0),
	
	Font            = Enum.Font.GothamMedium,
	FontBold        = Enum.Font.GothamBold,
	FontLight       = Enum.Font.Gotham,
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
	if not obj then return end
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local EASE = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local EASE_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local EASE_SPRING = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function corner(parent, radius)
	if not parent then return end
	return create("UICorner", { 
		CornerRadius = UDim.new(0, radius or 8), 
		Parent = parent 
	})
end

local function gradientBorder(parent, color1, color2)
	if not parent then return end
	local oldStroke = parent:FindFirstChild("UIStroke")
	if oldStroke then oldStroke:Destroy() end
	
	local border = create("Frame", {
		Name = "GradientBorder",
		Size = UDim2.new(1, 2, 1, 2),
		Position = UDim2.fromOffset(-1, -1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		ZIndex = -1,
		Parent = parent,
	})
	
	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color1 or Theme.AccentGradient1),
			ColorSequenceKeypoint.new(0.5, color2 or Theme.AccentGradient2),
			ColorSequenceKeypoint.new(1, color1 or Theme.AccentGradient1),
		}),
		Rotation = 45,
		Parent = border,
	})
	
	corner(border, 8)
	return border
end

local function stroke(parent, color, thickness, transparency)
	if not parent then return end
	create("UIStroke", {
		Color = color or Theme.CardBorder,
		Thickness = thickness or 1,
		Transparency = transparency or 0.3,
		Parent = parent,
	})
end

local function padding(parent, all)
	if not parent then return end
	create("UIPadding", {
		PaddingTop = UDim.new(0, all), PaddingBottom = UDim.new(0, all),
		PaddingLeft = UDim.new(0, all), PaddingRight = UDim.new(0, all),
		Parent = parent,
	})
end

local function ripple(button, x, y, color)
	if not button then return end
	local rip = create("Frame", {
		Name = "Ripple",
		BackgroundColor3 = color or Color3.new(1, 1, 1),
		BackgroundTransparency = 0.8,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(0, 0),
		ZIndex = 50,
		Parent = button,
	})
	corner(rip, 999)
	
	local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
	tween(rip, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(maxSize, maxSize),
		BackgroundTransparency = 1,
	})
	
	task.delay(0.6, function() 
		if rip and rip.Parent then
			tween(rip, EASE_FAST, { BackgroundTransparency = 1 })
			task.delay(0.15, function() 
				if rip and rip.Parent then rip:Destroy() end 
			end)
		end
	end)
end

local function hoverFeedback(obj, baseColor, hoverColor)
	if not obj then return end
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

	-- MAIN WINDOW
	local main = create("Frame", {
		Name = "Main",
		Size = UDim2.fromOffset(720, 520),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Background,
		BackgroundTransparency = 0.1,
		ClipsDescendants = true,
		Parent = gui,
	})
	corner(main, 16)
	
	local glassBg = create("Frame", {
		Name = "GlassBg",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Mica,
		BackgroundTransparency = 0.85,
		ZIndex = -1,
		Parent = main,
	})
	corner(glassBg, 16)
	
	gradientBorder(main, Theme.AccentGradient1, Theme.AccentGradient2)
	
	self.Main = main

	-- TITLEBAR
	local titleBar = create("Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundTransparency = 1,
		Parent = main,
	})
	
	-- Icon
	local titleIcon = create("ImageLabel", {
		Image = Icons["lucide-activity"],
		ImageColor3 = Theme.Accent,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 27),
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.new(0, 24, 0, 24),
		Parent = titleBar,
	})
	
	create("TextLabel", {
		Text = title or "Fluent Library",
		Font = Theme.FontBold,
		TextSize = 17,
		TextColor3 = Theme.TextPrimary,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(52, 0),
		Size = UDim2.new(1, -200, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = titleBar,
	})

	-- Window Controls với icons từ Live-UI
	local controls = create("Frame", {
		Name = "Controls",
		Size = UDim2.new(0, 130, 1, 0),
		Position = UDim2.new(1, -140, 0, 0),
		BackgroundTransparency = 1,
		Parent = titleBar,
	})
	
	local function createControlBtn(icon, hoverColor, callback)
		local btn = create("ImageButton", {
			Image = icon,
			ImageColor3 = Theme.TextSecondary,
			BackgroundColor3 = Theme.Background,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(34, 34),
			Position = UDim2.fromOffset(8, 10),
			Parent = controls,
		})
		corner(btn, 6)
		
		btn.MouseEnter:Connect(function()
			tween(btn, EASE_FAST, { 
				BackgroundTransparency = 0.2,
				BackgroundColor3 = hoverColor or Theme.CardHover,
				ImageColor3 = Theme.TextPrimary,
			})
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, EASE_FAST, { 
				BackgroundTransparency = 1,
				ImageColor3 = Theme.TextSecondary,
			})
		end)
		btn.MouseButton1Click:Connect(callback)
		return btn
	end
	
	-- Minimize
	createControlBtn(Icons["lucide-minus"], nil, function()
		tween(main, EASE, { Size = UDim2.fromOffset(720, 0), BackgroundTransparency = 1 })
		task.wait(0.3)
		self.Main.Visible = false
	end)
	
	-- Maximize
	createControlBtn(Icons["lucide-maximize"], nil, function() end)
	
	-- Close
	createControlBtn(Icons["lucide-x"], Theme.Danger, function()
		tween(main, EASE_SPRING, { Size = UDim2.fromOffset(720, 0), BackgroundTransparency = 1 })
		task.wait(0.35)
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
				tween(main, EASE_FAST, { BackgroundTransparency = 0.05 })
			end
		end)
		titleBar.InputEnded:Connect(function()
			if dragging then
				dragging = false
				tween(main, EASE_FAST, { BackgroundTransparency = 0 })
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	end

	-- SIDEBAR
	local sidebar = create("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 180, 1, -54),
		Position = UDim2.fromOffset(0, 54),
		BackgroundTransparency = 1,
		Parent = main,
	})
	
	local sidebarHeader = create("Frame", {
		Name = "SidebarHeader",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
		Parent = sidebar,
	})
	
	create("TextLabel", {
		Text = "✦ MENU",
		Font = Theme.FontBold,
		TextSize = 11,
		TextColor3 = Theme.TextMuted,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.new(1, -20, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = sidebarHeader,
	})
	
	local sidebarList = create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = sidebar,
	})
	padding(sidebar, 12)
	self.Sidebar = sidebar

	-- Divider
	local divider = create("Frame", {
		Name = "Divider",
		Size = UDim2.new(0, 2, 1, -54),
		Position = UDim2.fromOffset(180, 54),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		Parent = main,
	})
	
	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Theme.AccentGradient1),
			ColorSequenceKeypoint.new(0.5, Theme.AccentGradient2),
			ColorSequenceKeypoint.new(1, Theme.AccentGradient1),
		}),
		Rotation = 90,
		Parent = divider,
	})

	-- CONTENT AREA
	local content = create("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -182, 1, -54),
		Position = UDim2.fromOffset(182, 54),
		BackgroundTransparency = 1,
		Parent = main,
	})
	self.Content = content

	-- Opening animation
	main.Size = UDim2.fromOffset(720, 0)
	tween(main, EASE_SPRING, { Size = UDim2.fromOffset(720, 520), BackgroundTransparency = 0 })

	-- Toggle UI with key
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Enum.KeyCode.RightShift then
			if self.Main.Visible then
				tween(main, EASE, { Size = UDim2.fromOffset(720, 0), BackgroundTransparency = 1 })
				task.wait(0.3)
				self.Main.Visible = false
			else
				self.Main.Visible = true
				tween(main, EASE_SPRING, { Size = UDim2.fromOffset(720, 520), BackgroundTransparency = 0 })
			end
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
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 1,
		Parent = self.Sidebar,
	})
	corner(tabBtn, 10)
	
	local iconText = icon or "📄"
	local label = create("TextLabel", {
		Text = iconText .. "  " .. name,
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
		Position = UDim2.fromOffset(0, 21),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Theme.Accent,
		Parent = tabBtn,
	})
	corner(indicator, 2)
	
	tabBtn.MouseEnter:Connect(function()
		if tabBtn ~= self_.ActiveTab and self_.ActiveTab then
			tween(tabBtn, EASE_FAST, { BackgroundTransparency = 0.7 })
		end
	end)
	tabBtn.MouseLeave:Connect(function()
		if tabBtn ~= self_.ActiveTab and self_.ActiveTab then
			tween(tabBtn, EASE_FAST, { BackgroundTransparency = 1 })
		end
	end)

	-- Page
	local page = create("Frame", {
		Name = name .. "_Page",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = self.Content,
	})

	-- Search bar
	local searchContainer = create("Frame", {
		Name = "SearchContainer",
		Size = UDim2.new(1, -20, 0, 44),
		Position = UDim2.fromOffset(10, 8),
		BackgroundColor3 = Theme.Card,
		BackgroundTransparency = 0.5,
		ClipsDescendants = true,
		Parent = page,
	})
	corner(searchContainer, 12)
	gradientBorder(searchContainer, Theme.AccentGradient1, Theme.AccentGradient2)
	
	-- Search icon
	local searchIcon = create("ImageLabel", {
		Image = Icons["lucide-search"],
		ImageColor3 = Theme.TextMuted,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(0, 20, 1, 0),
		Parent = searchContainer,
	})
	
	local searchBox = create("TextBox", {
		Name = "Search",
		PlaceholderText = "🔎 Tìm kiếm trong " .. name .. "...",
		Text = "",
		Font = Theme.Font,
		TextSize = 14,
		TextColor3 = Theme.TextPrimary,
		PlaceholderColor3 = Theme.TextMuted,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.fromOffset(40, 0),
		ClearTextOnFocus = false,
		Parent = searchContainer,
	})

	local clearBtn = create("TextButton", {
		Text = "✕",
		Font = Theme.Font,
		TextSize = 12,
		TextColor3 = Theme.TextMuted,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(24, 24),
		Position = UDim2.new(1, -30, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Visible = false,
		Parent = searchContainer,
	})
	clearBtn.MouseEnter:Connect(function()
		tween(clearBtn, EASE_FAST, { TextColor3 = Theme.TextPrimary })
	end)
	clearBtn.MouseLeave:Connect(function()
		tween(clearBtn, EASE_FAST, { TextColor3 = Theme.TextMuted })
	end)
	clearBtn.MouseButton1Click:Connect(function()
		searchBox.Text = ""
	end)

	local scroller = create("ScrollingFrame", {
		Name = "Scroller",
		Size = UDim2.new(1, -20, 1, -72),
		Position = UDim2.fromOffset(10, 60),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Accent,
		ScrollBarImageTransparency = 0.5,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = page,
	})
	local layout = create("UIListLayout", {
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = scroller,
	})

	local Tab = {
		Button = tabBtn,
		Page = page,
		Scroller = scroller,
		Elements = {},
	}

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local q = searchBox.Text:lower()
		clearBtn.Visible = q ~= ""
		
		for _, el in ipairs(Tab.Elements) do
			if q == "" then
				el.Frame.Visible = true
			else
				local match = el.SearchText:lower():find(q, 1, true)
				el.Frame.Visible = match and true or false
			end
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
		tween(tabBtn, EASE_FAST, { BackgroundTransparency = 0.3, BackgroundColor3 = Theme.CardHover })
		tween(indicator, EASE_SPRING, { Size = UDim2.new(0, 3, 0, 30) })
		tween(label, EASE_FAST, { TextColor3 = Theme.TextPrimary })
		self_.ActiveTab = Tab
	end

	tabBtn.MouseButton1Click:Connect(selectTab)

	table.insert(self.Tabs, Tab)
	if #self.Tabs == 1 then selectTab() end

	----------------------------------------------------------------
	-- Helper: Card
	----------------------------------------------------------------
	local function newCard(height, hasGradient)
		local card = create("Frame", {
			Size = UDim2.new(1, 0, 0, height or 50),
			BackgroundColor3 = Theme.Card,
			BackgroundTransparency = 0.9,
			ClipsDescendants = true,
			Parent = scroller,
		})
		corner(card, 12)
		
		local glass = create("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Theme.Glass,
			BackgroundTransparency = 0.95,
			ZIndex = -1,
			Parent = card,
		})
		corner(glass, 12)
		
		if hasGradient then
			gradientBorder(card, Theme.AccentGradient1, Theme.AccentGradient2)
		else
			stroke(card, Theme.CardBorder, 1, 0.3)
		end
		
		card.BackgroundTransparency = 0.5
		card.Size = UDim2.new(1, 0, 0, 0)
		tween(card, EASE_SPRING, { 
			Size = UDim2.new(1, 0, 0, height or 50),
			BackgroundTransparency = 0.9 
		})
		
		return card
	end

	----------------------------------------------------------------
	-- PARAGRAPH
	----------------------------------------------------------------
	function Tab:CreateParagraph(opts)
		opts = opts or {}
		local title = opts.Title or "Paragraph"
		local desc = opts.Description or "This is a paragraph. Second line!"
		local highlight = opts.Highlight or "small change"
		
		local displayDesc = desc
		if highlight and desc:find(highlight) then
			displayDesc = desc:gsub(highlight, "✦" .. highlight .. "✦")
		end
		
		local card = newCard(80, true)
		
		create("TextLabel", {
			Text = "📝 " .. title,
			Font = Theme.FontBold,
			TextSize = 15,
			TextColor3 = Theme.TextPrimary,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(16, 10),
			Size = UDim2.new(1, -20, 0, 22),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = card,
		})
		
		local descLabel = create("TextLabel", {
			Text = displayDesc,
			Font = Theme.Font,
			TextSize = 13,
			TextColor3 = Theme.TextSecondary,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(16, 36),
			Size = UDim2.new(1, -20, 0, 34),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			Parent = card,
		})
		
		if highlight and desc:find(highlight) then
			local highlightFrame = create("Frame", {
				Size = UDim2.new(0, 0, 0, 22),
				Position = UDim2.fromOffset(0, 36),
				BackgroundColor3 = Theme.Accent,
				BackgroundTransparency = 0.85,
				Parent = card,
			})
			corner(highlightFrame, 4)
			
			task.defer(function()
				if not descLabel or not descLabel.Parent then return end
				local textBounds = descLabel.TextBounds
				local textBefore = desc:sub(1, desc:find(highlight) - 1)
				local beforeWidth = textBounds.X * (#textBefore / #desc)
				highlightFrame.Position = UDim2.fromOffset(16 + beforeWidth, 36)
				highlightFrame.Size = UDim2.new(0, textBounds.X * (#highlight / #desc) + 8, 0, 22)
				
				tween(highlightFrame, EASE_SLOW or EASE, { BackgroundTransparency = 0.7 })
				tween(highlightFrame, EASE_SLOW or EASE, { BackgroundTransparency = 0.85 })
			end)
		end

		table.insert(self.Elements, { Frame = card, SearchText = title .. " " .. desc, Type = "Paragraph" })
		
		return {
			SetDescription = function(_, newDesc)
				desc = newDesc
				local newDisplay = newDesc
				if highlight and newDesc:find(highlight) then
					newDisplay = newDesc:gsub(highlight, "✦" .. highlight .. "✦")
				end
				descLabel.Text = newDisplay
			end,
			SetHighlight = function(_, newHighlight)
				highlight = newHighlight
				local newDisplay = desc
				if highlight and desc:find(highlight) then
					newDisplay = desc:gsub(highlight, "✦" .. highlight .. "✦")
				end
				descLabel.Text = newDisplay
			end,
			Get = function() return desc end,
		}
	end

	----------------------------------------------------------------
	-- TOGGLE với Config
	----------------------------------------------------------------
	function Tab:CreateToggle(opts)
		opts = opts or {}
		local name = opts.Name or "Toggle"
		local default = opts.Default or false
		local callback = opts.Callback or function() end
		local hasConfig = opts.Config ~= nil and #opts.Config > 0

		local state = default
		local subControls = {}

		local card = newCard(50, hasConfig)

		local row = create("Frame", {
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundTransparency = 1,
			Parent = card,
		})

		create("TextLabel", {
			Text = "⚙️ " .. name,
			Font = Theme.Font,
			TextSize = 14,
			TextColor3 = Theme.TextPrimary,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(16, 0),
			Size = UDim2.new(1, -130, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})

		-- Switch
		local switchBg = create("Frame", {
			Size = UDim2.fromOffset(48, 26),
			Position = UDim2.new(1, hasConfig and -82 or -58, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = state and Theme.Accent or Theme.CardBorder,
			Parent = row,
		})
		corner(switchBg, 13)
		
		local glow = create("Frame", {
			Size = UDim2.fromScale(1.3, 1.3),
			Position = UDim2.fromScale(-0.15, -0.15),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 0.9,
			ZIndex = -1,
			Parent = switchBg,
		})
		corner(glow, 13)
		
		local knob = create("Frame", {
			Size = UDim2.fromOffset(20, 20),
			Position = state and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = switchBg,
		})
		corner(knob, 10)
		
		create("Frame", {
			Name = "KnobShadow",
			Size = UDim2.fromOffset(22, 22),
			Position = UDim2.new(0, -1, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.8,
			ZIndex = -1,
			Parent = knob,
		})
		corner(knob:FindFirstChild("KnobShadow"), 11)

		local switchBtn = create("TextButton", {
			Text = "",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(48, 26),
			Position = switchBg.Position,
			AnchorPoint = Vector2.new(0, 0.5),
			Parent = row,
		})

		local function setState(v, fireCallback)
			state = v
			tween(switchBg, EASE_FAST, { BackgroundColor3 = state and Theme.Accent or Theme.CardBorder })
			tween(glow, EASE_FAST, { BackgroundTransparency = state and 0.7 or 0.9 })
			tween(knob, EASE_SPRING, { Position = state and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) })
			if fireCallback ~= false then
				task.spawn(callback, state)
			end
		end

		switchBtn.MouseButton1Click:Connect(function() 
			setState(not state)
			ripple(switchBtn, Mouse.X - switchBtn.AbsolutePosition.X, Mouse.Y - switchBtn.AbsolutePosition.Y)
		end)

		-- Config
		local configFrame
		local arrowOpen = false
		
		if hasConfig then
			local arrowBtn = create("ImageButton", {
				Image = Icons["lucide-chevron-down"],
				ImageColor3 = Theme.TextSecondary,
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(32, 32),
				Position = UDim2.new(1, -32, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Parent = row,
			})
			arrowBtn.MouseEnter:Connect(function()
				tween(arrowBtn, EASE_FAST, { ImageColor3 = Theme.TextPrimary })
			end)
			arrowBtn.MouseLeave:Connect(function()
				tween(arrowBtn, EASE_FAST, { ImageColor3 = Theme.TextSecondary })
			end)

			configFrame = create("Frame", {
				Size = UDim2.new(1, -20, 0, 0),
				Position = UDim2.fromOffset(10, 50),
				BackgroundColor3 = Theme.Background,
				BackgroundTransparency = 0.5,
				ClipsDescendants = true,
				Parent = card,
			})
			corner(configFrame, 10)
			stroke(configFrame, Theme.CardBorder, 1, 0.2)
			
			local configLayout = create("UIListLayout", {
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = configFrame,
			})
			padding(configFrame, 10)

			-- Build sub-configs
			for _, c in ipairs(opts.Config or {}) do
				local sub = create("Frame", {
					Size = UDim2.new(1, 0, 0, 34),
					BackgroundTransparency = 1,
					Parent = configFrame,
				})
				
				create("TextLabel", {
					Text = "▸ " .. (c.Name or "Option"),
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
						Size = UDim2.fromOffset(38, 20),
						Position = UDim2.new(1, -38, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = subState and Theme.Accent or Theme.CardBorder,
						Parent = sub,
					})
					corner(subSwitchBg, 10)
					
					local subKnob = create("Frame", {
						Size = UDim2.fromOffset(16, 16),
						Position = subState and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = Color3.new(1, 1, 1),
						Parent = subSwitchBg,
					})
					corner(subKnob, 8)
					
					local subBtn = create("TextButton", {
						Text = "", 
						BackgroundTransparency = 1, 
						Size = UDim2.fromOffset(38, 20),
						Position = subSwitchBg.Position, 
						AnchorPoint = Vector2.new(0, 0.5), 
						Parent = sub,
					})
					subBtn.MouseButton1Click:Connect(function()
						subState = not subState
						tween(subSwitchBg, EASE_FAST, { BackgroundColor3 = subState and Theme.Accent or Theme.CardBorder })
						tween(subKnob, EASE_FAST, { Position = subState and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) })
						if c.Callback then task.spawn(c.Callback, subState) end
					end)
					
					table.insert(subControls, { 
						Type = "Toggle", 
						Set = function(v) 
							subState = v
							tween(subSwitchBg, EASE_FAST, { BackgroundColor3 = subState and Theme.Accent or Theme.CardBorder })
							tween(subKnob, EASE_FAST, { Position = subState and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) })
						end 
					})

				elseif c.Type == "Slider" then
					local min, max = c.Min or 0, c.Max or 100
					local val = c.Default or min
					
					local track = create("Frame", {
						Size = UDim2.new(0.4, 0, 0, 6),
						Position = UDim2.new(1, -0, 0.5, 0),
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundColor3 = Theme.CardBorder,
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
					
					table.insert(subControls, { 
						Type = "Slider", 
						Set = function(v) 
							val = math.clamp(v, min, max)
							fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
						end 
					})

				elseif c.Type == "Textbox" then
					local tb = create("TextBox", {
						Text = c.Default or "",
						PlaceholderText = c.Placeholder or "",
						Font = Theme.Font, 
						TextSize = 12, 
						TextColor3 = Theme.TextPrimary,
						BackgroundColor3 = Theme.Background,
						BackgroundTransparency = 0.5,
						Size = UDim2.new(0.4, 0, 0, 26),
						Position = UDim2.new(1, 0, 0.5, 0),
						AnchorPoint = Vector2.new(1, 0.5),
						Parent = sub,
					})
					corner(tb, 6)
					stroke(tb, Theme.CardBorder, 1, 0.2)
					padding(tb, 6)
					
					tb.Focused:Connect(function()
						if tb.UIStroke then
							tween(tb.UIStroke, EASE_FAST, { Color = Theme.Accent, Transparency = 0 })
						end
					end)
					tb.FocusLost:Connect(function()
						if tb.UIStroke then
							tween(tb.UIStroke, EASE_FAST, { Color = Theme.CardBorder, Transparency = 0.2 })
						end
						if c.Callback then task.spawn(c.Callback, tb.Text) end
					end)
					
					table.insert(subControls, { 
						Type = "Textbox", 
						Set = function(v) tb.Text = v end 
					})
				end
			end

			arrowBtn.MouseButton1Click:Connect(function()
				arrowOpen = not arrowOpen
				local contentHeight = #(opts.Config or {}) * 42 + 20
				if contentHeight > 250 then contentHeight = 250 end
				
				tween(arrowBtn, EASE_FAST, { Rotation = arrowOpen and 180 or 0 })
				tween(configFrame, EASE, { Size = UDim2.new(1, -20, 0, arrowOpen and contentHeight or 0) })
				tween(card, EASE, { Size = UDim2.new(1, 0, 0, arrowOpen and (50 + contentHeight) or 50) })
			end)
		end

		setState(default, false)

		table.insert(self.Elements, { Frame = card, SearchText = name .. " " .. (opts.Description or ""), Type = "Toggle" })
		
		return {
			Set = function(_, v) setState(v) end,
			Get = function() return state end,
			Toggle = function() setState(not state) end,
			SetConfig = function(_, key, value)
				for _, c in ipairs(subControls) do
					if c.Type == "Toggle" and key == "toggle" then
						c.Set(value)
					elseif c.Type == "Slider" and key == "slider" then
						c.Set(value)
					elseif c.Type == "Textbox" and key == "textbox" then
						c.Set(value)
					end
				end
			end
		}
	end

	----------------------------------------------------------------
	-- DROPDOWN
	----------------------------------------------------------------
	function Tab:CreateDropdown(opts)
		opts = opts or {}
		local name = opts.Name or "Dropdown"
		local list = opts.List_Table or opts.List or {}
		local multi = opts.Multi or false
		local callback = opts.Callback or function() end
		local selected = {}
		local currentList = list

		if opts.Default then
			if multi and typeof(opts.Default) == "table" then
				for _, v in ipairs(opts.Default) do selected[v] = true end
			elseif not multi then
				selected[opts.Default] = true
			end
		end

		local card = newCard(50, true)
		local header = create("TextButton", {
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundTransparency = 1,
			Parent = card,
		})
		
		create("TextLabel", {
			Text = "📋 " .. name,
			Font = Theme.Font, 
			TextSize = 14, 
			TextColor3 = Theme.TextPrimary,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(16, 0),
			Size = UDim2.new(1, -170, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = header,
		})
		
		local selectedLabel = create("TextLabel", {
			Text = "Chọn...",
			Font = Theme.Font, 
			TextSize = 13, 
			TextColor3 = Theme.TextSecondary,
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -160, 0, 0),
			Size = UDim2.new(0, 120, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = header,
		})
		
		local arrow = create("ImageLabel", {
			Image = Icons["lucide-chevron-down"],
			ImageColor3 = Theme.TextSecondary,
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -32, 0, 0),
			Size = UDim2.new(0, 24, 1, 0),
			Parent = header,
		})

		local listFrame = create("Frame", {
			Size = UDim2.new(1, -20, 0, 0),
			Position = UDim2.fromOffset(10, 50),
			BackgroundColor3 = Theme.Background,
			BackgroundTransparency = 0.5,
			ClipsDescendants = true,
			Parent = card,
		})
		corner(listFrame, 10)
		stroke(listFrame, Theme.CardBorder, 1, 0.2)
		
		local listLayout = create("UIListLayout", {
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = listFrame,
		})
		padding(listFrame, 8)

		local function refreshLabel()
			local names = {}
			for k, v in pairs(selected) do
				if v then table.insert(names, tostring(k)) end
			end
			selectedLabel.Text = (#names == 0) and "Chọn..." or table.concat(names, ", ")
		end

		local optionButtons = {}
		local function buildOptions(newList)
			if newList then currentList = newList end
			for _, b in ipairs(optionButtons) do 
				if b and b.Parent then b:Destroy() end 
			end
			optionButtons = {}
			
			for _, item in ipairs(currentList) do
				local optBtn = create("TextButton", {
					Text = "",
					AutoButtonColor = false,
					Size = UDim2.new(1, 0, 0, 32),
					BackgroundColor3 = Theme.Card,
					BackgroundTransparency = selected[item] and 0.3 or 1,
					Parent = listFrame,
				})
				corner(optBtn, 8)
				
				optBtn.MouseEnter:Connect(function()
					tween(optBtn, EASE_FAST, { BackgroundTransparency = selected[item] and 0.3 or 0.7 })
				end)
				optBtn.MouseLeave:Connect(function()
					tween(optBtn, EASE_FAST, { BackgroundTransparency = selected[item] and 0.3 or 1 })
				end)
				
				local checkmark = create("ImageLabel", {
					Image = Icons["lucide-check"],
					ImageColor3 = Theme.Accent,
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -26, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					Size = UDim2.new(0, 16, 0, 16),
					Visible = selected[item] and true or false,
					Parent = optBtn,
				})
				
				create("TextLabel", {
					Text = tostring(item),
					Font = Theme.Font, 
					TextSize = 13,
					TextColor3 = selected[item] and Theme.AccentLight or Theme.TextSecondary,
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.new(1, -40, 1, 0),
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
			local h = #currentList * 36 + 16
			if h > 200 then h = 200 end
			tween(arrow, EASE_FAST, { Rotation = open and 180 or 0 })
			tween(listFrame, EASE, { Size = UDim2.new(1, -20, 0, open and h or 0) })
			tween(card, EASE, { Size = UDim2.new(1, 0, 0, open and (50 + h) or 50) })
		end)

		table.insert(self.Elements, { Frame = card, SearchText = name, Type = "Dropdown" })
		return {
			Refresh = function(_, newList)
				buildOptions(newList)
			end,
			SetValue = function(_, value)
				if multi then
					selected = {}
					if typeof(value) == "table" then
						for _, v in ipairs(value) do selected[v] = true end
					end
				else
					for k in pairs(selected) do selected[k] = false end
					selected[value] = true
				end
				buildOptions()
				refreshLabel()
			end,
			Get = function() 
				if multi then
					local result = {}
					for k, v in pairs(selected) do if v then table.insert(result, k) end end
					return result
				else
					for k, v in pairs(selected) do if v then return k end end
					return nil
				end
			end,
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

		local card = newCard(60, true)
		
		create("TextLabel", {
			Text = "🎚️ " .. name,
			Font = Theme.Font, 
			TextSize = 14, 
			TextColor3 = Theme.TextPrimary,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(16, 6),
			Size = UDim2.new(1, -120, 0, 20),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = card,
		})
		
		local valueLabel = create("TextLabel", {
			Text = tostring(default) .. suffix,
			Font = Theme.FontBold, 
			TextSize = 16, 
			TextColor3 = Theme.Accent,
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -90, 0, 4),
			Size = UDim2.new(0, 76, 0, 24),
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = card,
		})

		local track = create("Frame", {
			Size = UDim2.new(1, -32, 0, 8),
			Position = UDim2.fromOffset(16, 40),
			BackgroundColor3 = Theme.CardBorder,
			BackgroundTransparency = 0.5,
			Parent = card,
		})
		corner(track, 4)
		
		local trackGlow = create("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 0.9,
			ZIndex = -1,
			Parent = track,
		})
		corner(trackGlow, 4)
		
		local fill = create("Frame", {
			Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
			BackgroundColor3 = Theme.Accent,
			Parent = track,
		})
		corner(fill, 4)
		
		create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Theme.AccentGradient1),
				ColorSequenceKeypoint.new(1, Theme.AccentGradient2),
			}),
			Rotation = 180,
			Parent = fill,
		})
		
		local knob = create("Frame", {
			Size = UDim2.fromOffset(20, 20),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			ZIndex = 2,
			Parent = track,
		})
		corner(knob, 10)
		stroke(knob, Theme.Accent, 2)
		
		local knobGlow = create("Frame", {
			Size = UDim2.fromScale(1.5, 1.5),
			Position = UDim2.fromScale(-0.25, -0.25),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 0.9,
			ZIndex = -1,
			Parent = knob,
		})
		corner(knobGlow, 10)

		local dragging = false
		local value = default

		local function update(rel)
			rel = math.clamp(rel, 0, 1)
			value = math.floor(min + (max - min) * rel + 0.5)
			tween(fill, EASE_FAST, { Size = UDim2.new(rel, 0, 1, 0) })
			tween(knob, EASE_FAST, { Position = UDim2.new(rel, 0, 0.5, 0) })
			tween(knobGlow, EASE_FAST, { BackgroundTransparency = 0.7 })
			valueLabel.Text = tostring(value) .. suffix
			task.spawn(callback, value)
		end

		track.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				local rel = (Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
				update(rel)
				tween(knob, EASE_FAST, { Size = UDim2.fromOffset(26, 26) })
				tween(knobGlow, EASE_FAST, { BackgroundTransparency = 0.5 })
			end
		end)
		UserInputService.InputEnded:Connect(function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
				dragging = false
				tween(knob, EASE_FAST, { Size = UDim2.fromOffset(20, 20) })
				tween(knobGlow, EASE_FAST, { BackgroundTransparency = 0.9 })
			end
		end)
		RunService.RenderStepped:Connect(function()
			if dragging then
				local rel = (Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
				update(rel)
			end
		end)

		table.insert(self.Elements, { Frame = card, SearchText = name, Type = "Slider" })
		return {
			Set = function(_, v) 
				v = math.clamp(v, min, max)
				update((v - min) / (max - min)) 
			end,
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

		local card = newCard(52, true)
		
		create("TextLabel", {
			Text = "✏️ " .. name,
			Font = Theme.Font, 
			TextSize = 14, 
			TextColor3 = Theme.TextPrimary,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(16, 0),
			Size = UDim2.new(0.4, 0, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = card,
		})
		
		local box = create("TextBox", {
			Text = opts.Default or "",
			PlaceholderText = placeholder,
			PlaceholderColor3 = Theme.TextMuted,
			Font = Theme.Font, 
			TextSize = 13, 
			TextColor3 = Theme.TextPrimary,
			BackgroundColor3 = Theme.Background,
			BackgroundTransparency = 0.5,
			ClearTextOnFocus = false,
			Size = UDim2.new(0.5, -10, 0, 34),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Parent = card,
		})
		corner(box, 8)
		stroke(box, Theme.CardBorder, 1, 0.2)
		padding(box, 10)

		box.Focused:Connect(function()
			if box.UIStroke then
				tween(box.UIStroke, EASE_FAST, { Color = Theme.Accent, Transparency = 0 })
			end
			tween(box, EASE_FAST, { BackgroundTransparency = 0.2 })
		end)
		box.FocusLost:Connect(function(enter)
			if box.UIStroke then
				tween(box.UIStroke, EASE_FAST, { Color = Theme.CardBorder, Transparency = 0.2 })
			end
			tween(box, EASE_FAST, { BackgroundTransparency = 0.5 })
			task.spawn(callback, box.Text, enter)
		end)

		table.insert(self.Elements, { Frame = card, SearchText = name, Type = "Textbox" })
		return {
			Set = function(_, v) box.Text = v end,
			Get = function() return box.Text end,
			Clear = function() box.Text = "" end,
		}
	end

	----------------------------------------------------------------
	-- BUTTON
	----------------------------------------------------------------
	function Tab:CreateButton(opts)
		opts = opts or {}
		local name = opts.Name or "Button"
		local callback = opts.Callback or function() end
		local variant = opts.Variant or "primary"

		local cardHeight = opts.Description and 72 or 50
		local card = newCard(cardHeight, true)
		
		if opts.Description then
			create("TextLabel", {
				Text = opts.Description,
				Font = Theme.FontLight,
				TextSize = 12,
				TextColor3 = Theme.TextMuted,
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(16, 6),
				Size = UDim2.new(1, -20, 0, 18),
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = card,
			})
		end
		
		local btnColors = {
			primary = { bg = Theme.Accent, hover = Theme.AccentLight, text = Theme.TextPrimary },
			success = { bg = Theme.Success, hover = Theme.Success, text = Theme.TextPrimary },
			danger = { bg = Theme.Danger, hover = Theme.Danger, text = Theme.TextPrimary },
			secondary = { bg = Theme.CardHover, hover = Theme.CardActive, text = Theme.TextPrimary },
		}
		
		local colors = btnColors[variant] or btnColors.primary
		
		local btn = create("TextButton", {
			Text = name,
			AutoButtonColor = false,
			Font = Theme.FontBold, 
			TextSize = 14, 
			TextColor3 = colors.text,
			BackgroundColor3 = colors.bg,
			BackgroundTransparency = 0.9,
			Size = UDim2.new(1, -16, 0, 36),
			Position = opts.Description and UDim2.fromOffset(8, 30) or UDim2.fromOffset(8, 7),
			ClipsDescendants = true,
			Parent = card,
		})
		corner(btn, 10)

		btn.MouseEnter:Connect(function()
			tween(btn, EASE_FAST, { 
				BackgroundColor3 = colors.hover,
				BackgroundTransparency = 0.7,
			})
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, EASE_FAST, { 
				BackgroundColor3 = colors.bg,
				BackgroundTransparency = 0.9,
			})
		end)
		btn.MouseButton1Down:Connect(function()
			tween(btn, EASE_FAST, { 
				Size = UDim2.new(1, -20, 0, 32), 
				Position = opts.Description and UDim2.fromOffset(10, 32) or UDim2.fromOffset(10, 9),
				BackgroundTransparency = 0.6,
			})
		end)
		btn.MouseButton1Up:Connect(function()
			tween(btn, EASE_SPRING, { 
				Size = UDim2.new(1, -16, 0, 36), 
				Position = opts.Description and UDim2.fromOffset(8, 30) or UDim2.fromOffset(8, 7),
				BackgroundTransparency = 0.9,
			})
		end)
		btn.MouseButton1Click:Connect(function()
			ripple(btn, Mouse.X - btn.AbsolutePosition.X, Mouse.Y - btn.AbsolutePosition.Y, colors.text)
			task.spawn(callback)
		end)

		table.insert(self.Elements, { Frame = card, SearchText = name .. " " .. (opts.Description or ""), Type = "Button" })
		return { 
			SetText = function(_, v) btn.Text = v end,
		}
	end

	return Tab
end

return Library
