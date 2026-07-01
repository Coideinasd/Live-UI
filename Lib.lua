local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = LocalPlayer.PlayerGui 

local function MakeDraggable(topbarobject, object)
	-- ... (giữ nguyên, không thay đổi)
end

function CircleClick(Button, X, Y)
	-- ... (giữ nguyên)
end

local FlurioreLib = {}
local TweenService = game:GetService("TweenService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = LocalPlayer.PlayerGui 

function FlurioreLib:MakeNotify(NotifyConfig)
	-- ... (giữ nguyên)
end

function FlurioreLib:MakeGui(GuiConfig)
	-- ... (phần tạo GUI cơ bản, giữ nguyên như code cũ)
	-- Đảm bảo giữ nguyên tất cả, bao gồm search bar cho tab và search bar trong nội dung tab
	-- Vì đây là code dài, tôi sẽ chỉ hiển thị phần đã sửa trong hàm AddToggle và phần bổ sung.
end

-- ========== PHẦN SỬA TRONG HÀM AddToggle ==========
-- Trong hàm Tabs:CreateTab, phần Items:AddToggle được sửa như sau:

function Items:AddToggle(ToggleConfig)
	local ToggleConfig = ToggleConfig or {}
	ToggleConfig.Title = ToggleConfig.Title or "Title"
	ToggleConfig.Content = ToggleConfig.Content or "Content"
	ToggleConfig.Default = ToggleConfig.Default or false
	ToggleConfig.Callback = ToggleConfig.Callback or function() end
	-- Cấu hình cho Config Toggle (mở dropdown)
	ToggleConfig.ConfigToggle = ToggleConfig.ConfigToggle or false
	ToggleConfig.ConfigOptions = ToggleConfig.ConfigOptions or {}   -- danh sách option
	ToggleConfig.ConfigDefault = ToggleConfig.ConfigDefault or nil  -- giá trị mặc định
	ToggleConfig.ConfigCallback = ToggleConfig.ConfigCallback or function() end

	local ToggleFunc = {Value = ToggleConfig.Default, ConfigValue = ToggleConfig.ConfigDefault}

	local Toggle = Instance.new("Frame");
	local UICorner20 = Instance.new("UICorner");
	local ToggleTitle = Instance.new("TextLabel");
	local ToggleContent = Instance.new("TextLabel");
	local ToggleButton = Instance.new("TextButton");
	local FeatureFrame2 = Instance.new("Frame");
	local UICorner22 = Instance.new("UICorner");
	local UIStroke8 = Instance.new("UIStroke");
	local ToggleCircle = Instance.new("Frame");
	local UICorner23 = Instance.new("UICorner");

	-- Tạo các thành phần cơ bản (như cũ)
	Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Toggle.BackgroundTransparency = 0.9350000023841858
	Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Toggle.BorderSizePixel = 0
	Toggle.LayoutOrder = CountItem
	Toggle.Size = UDim2.new(1, 0, 0, 45)
	Toggle.Name = "Toggle"
	Toggle.Parent = SectionAdd
	Toggle.ClipsDescendants = false  -- cho phép dropdown hiển thị bên ngoài

	UICorner20.CornerRadius = UDim.new(0, 4)
	UICorner20.Parent = Toggle

	ToggleTitle.Font = Enum.Font.GothamBold
	ToggleTitle.Text = ToggleConfig.Title
	ToggleTitle.TextSize = 13
	ToggleTitle.TextColor3 = Color3.fromRGB(230.77499270439148, 230.77499270439148, 230.77499270439148)
	ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
	ToggleTitle.TextYAlignment = Enum.TextYAlignment.Top
	ToggleTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ToggleTitle.BackgroundTransparency = 0.9990000128746033
	ToggleTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ToggleTitle.BorderSizePixel = 0
	ToggleTitle.Position = UDim2.new(0, 8, 0, 8)
	ToggleTitle.Size = UDim2.new(1, -100, 0, 13)
	ToggleTitle.Name = "ToggleTitle"
	ToggleTitle.Parent = Toggle

	ToggleContent.Font = Enum.Font.GothamBold
	ToggleContent.Text = ToggleConfig.Content
	ToggleContent.TextColor3 = Color3.fromRGB(255, 255, 255)
	ToggleContent.TextSize = 12
	ToggleContent.TextTransparency = 0.6000000238418579
	ToggleContent.TextXAlignment = Enum.TextXAlignment.Left
	ToggleContent.TextYAlignment = Enum.TextYAlignment.Bottom
	ToggleContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ToggleContent.BackgroundTransparency = 0.9990000128746033
	ToggleContent.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ToggleContent.BorderSizePixel = 0
	ToggleContent.Position = UDim2.new(0, 8, 0, 23)
	ToggleContent.Size = UDim2.new(1, -100, 0, 12)
	ToggleContent.Name = "ToggleContent"
	ToggleContent.Parent = Toggle
	
	ToggleContent.Size = UDim2.new(1, -100, 0, 12 + (12 * (ToggleContent.TextBounds.X // ToggleContent.AbsoluteSize.X)))
	ToggleContent.TextWrapped = true
	Toggle.Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)

	ToggleContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		ToggleContent.TextWrapped = false
		TweenService:Create(
			ToggleContent,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Size = UDim2.new(1, -100, 0, 12 + (12 * (ToggleContent.TextBounds.X // ToggleContent.AbsoluteSize.X)))}
		):Play()
		TweenService:Create(
			Toggle,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Size = UDim2.new(1, 0, 0, ToggleContent.AbsoluteSize.Y + 33)}
		):Play()
		task.wait(0.2)
		ToggleContent.TextWrapped = true
		UpdateSizeSection()
	end)

	ToggleButton.Font = Enum.Font.SourceSans
	ToggleButton.Text = ""
	ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	ToggleButton.TextSize = 14
	ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ToggleButton.BackgroundTransparency = 0.9990000128746033
	ToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ToggleButton.BorderSizePixel = 0
	ToggleButton.Size = UDim2.new(1, 0, 1, 0)
	ToggleButton.Name = "ToggleButton"
	ToggleButton.Parent = Toggle

	-- Main toggle switch
	FeatureFrame2.AnchorPoint = Vector2.new(1, 0.5)
	FeatureFrame2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	FeatureFrame2.BackgroundTransparency = 0.9200000166893005
	FeatureFrame2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	FeatureFrame2.BorderSizePixel = 0
	FeatureFrame2.Position = UDim2.new(1, -30, 0.5, 0)
	FeatureFrame2.Size = UDim2.new(0, 30, 0, 15)
	FeatureFrame2.Name = "FeatureFrame"
	FeatureFrame2.Parent = Toggle

	UICorner22.Parent = FeatureFrame2

	UIStroke8.Color = Color3.fromRGB(255, 255, 255)
	UIStroke8.Thickness = 2
	UIStroke8.Transparency = 0.9
	UIStroke8.Parent = FeatureFrame2

	ToggleCircle.BackgroundColor3 = Color3.fromRGB(230.00000149011612, 230.00000149011612, 230.00000149011612)
	ToggleCircle.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ToggleCircle.BorderSizePixel = 0
	ToggleCircle.Position = UDim2.new(0, 0, 0, 0)
	ToggleCircle.Size = UDim2.new(0, 14, 0, 14)
	ToggleCircle.Name = "ToggleCircle"
	ToggleCircle.Parent = FeatureFrame2

	UICorner23.CornerRadius = UDim.new(0, 15)
	UICorner23.Parent = ToggleCircle

	-- ===== CONFIG TOGGLE (mở dropdown) =====
	if ToggleConfig.ConfigToggle then
		-- Nút config (icon bánh răng)
		local ConfigButton = Instance.new("TextButton")
		ConfigButton.AnchorPoint = Vector2.new(1, 0.5)
		ConfigButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ConfigButton.BackgroundTransparency = 0.999
		ConfigButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ConfigButton.BorderSizePixel = 0
		ConfigButton.Position = UDim2.new(1, -40, 0.5, 0)  -- đặt bên cạnh toggle
		ConfigButton.Size = UDim2.new(0, 25, 0, 25)
		ConfigButton.Name = "ConfigButton"
		ConfigButton.Parent = Toggle

		local ConfigIcon = Instance.new("ImageLabel")
		ConfigIcon.Image = "rbxassetid://10734950309"
		ConfigIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		ConfigIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ConfigIcon.BackgroundTransparency = 0.999
		ConfigIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ConfigIcon.BorderSizePixel = 0
		ConfigIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
		ConfigIcon.Size = UDim2.new(1, -4, 1, -4)
		ConfigIcon.Name = "ConfigIcon"
		ConfigIcon.Parent = ConfigButton

		-- Dropdown frame (ẩn ban đầu)
		local ConfigDropdown = Instance.new("Frame")
		ConfigDropdown.AnchorPoint = Vector2.new(1, 0)
		ConfigDropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		ConfigDropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ConfigDropdown.BorderSizePixel = 0
		ConfigDropdown.Position = UDim2.new(1, -40, 0, 30)  -- nằm bên dưới nút config
		ConfigDropdown.Size = UDim2.new(0, 150, 0, 0)
		ConfigDropdown.Name = "ConfigDropdown"
		ConfigDropdown.Parent = Toggle
		ConfigDropdown.ClipsDescendants = true
		ConfigDropdown.Visible = false

		local DropUICorner = Instance.new("UICorner")
		DropUICorner.CornerRadius = UDim.new(0, 4)
		DropUICorner.Parent = ConfigDropdown

		local DropList = Instance.new("UIListLayout")
		DropList.Padding = UDim.new(0, 2)
		DropList.SortOrder = Enum.SortOrder.LayoutOrder
		DropList.Parent = ConfigDropdown

		-- Hàm cập nhật kích thước dropdown
		local function UpdateDropdownSize()
			local count = 0
			for _, child in ConfigDropdown:GetChildren() do
				if child:IsA("Frame") and child.Name == "ConfigOption" then
					count = count + 1
				end
			end
			local height = count * 30 + 4
			TweenService:Create(ConfigDropdown, TweenInfo.new(0.2), {Size = UDim2.new(0, 150, 0, height)}):Play()
		end

		-- Tạo các option
		local function RefreshConfigOptions(options, default)
			-- Xóa option cũ
			for _, child in ConfigDropdown:GetChildren() do
				if child.Name == "ConfigOption" then
					child:Destroy()
				end
			end

			for i, opt in ipairs(options) do
				local optFrame = Instance.new("Frame")
				optFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				optFrame.BackgroundTransparency = 0.5
				optFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
				optFrame.BorderSizePixel = 0
				optFrame.LayoutOrder = i
				optFrame.Size = UDim2.new(1, -4, 0, 30)
				optFrame.Name = "ConfigOption"
				optFrame.Parent = ConfigDropdown

				local optButton = Instance.new("TextButton")
				optButton.Font = Enum.Font.GothamBold
				optButton.Text = opt
				optButton.TextColor3 = Color3.fromRGB(230, 230, 230)
				optButton.TextSize = 13
				optButton.TextXAlignment = Enum.TextXAlignment.Left
				optButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				optButton.BackgroundTransparency = 0.999
				optButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
				optButton.BorderSizePixel = 0
				optButton.Size = UDim2.new(1, 0, 1, 0)
				optButton.Name = "optButton"
				optButton.Parent = optFrame

				local checkMark = Instance.new("ImageLabel")
				checkMark.Image = "rbxassetid://16932740082"  -- icon check
				checkMark.AnchorPoint = Vector2.new(1, 0.5)
				checkMark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				checkMark.BackgroundTransparency = 0.999
				checkMark.BorderColor3 = Color3.fromRGB(0, 0, 0)
				checkMark.BorderSizePixel = 0
				checkMark.Position = UDim2.new(1, -8, 0.5, 0)
				checkMark.Size = UDim2.new(0, 16, 0, 16)
				checkMark.Name = "CheckMark"
				checkMark.Parent = optFrame
				checkMark.Visible = (opt == ToggleFunc.ConfigValue)

				optButton.MouseButton1Click:Connect(function()
					ToggleFunc.ConfigValue = opt
					-- Cập nhật dấu check
					for _, child in ConfigDropdown:GetChildren() do
						if child.Name == "ConfigOption" then
							local mark = child:FindFirstChild("CheckMark")
							if mark then
								mark.Visible = (child.optButton.Text == opt)
							end
						end
					end
					ToggleConfig.ConfigCallback(opt)
					-- Ẩn dropdown sau khi chọn
					ConfigDropdown.Visible = false
				end)

				local optCorner = Instance.new("UICorner")
				optCorner.CornerRadius = UDim.new(0, 2)
				optCorner.Parent = optFrame
			end
			UpdateDropdownSize()
		end

		-- Xử lý click vào nút config
		ConfigButton.MouseButton1Click:Connect(function()
			CircleClick(ConfigButton, Mouse.X, Mouse.Y)
			-- Nếu dropdown chưa có option, tạo từ ConfigOptions
			if #ConfigDropdown:GetChildren() == 1 then -- chỉ có UIListLayout
				RefreshConfigOptions(ToggleConfig.ConfigOptions, ToggleFunc.ConfigValue)
			end
			ConfigDropdown.Visible = not ConfigDropdown.Visible
		end)

		-- Ẩn dropdown khi click ra ngoài (tùy chọn) - có thể bỏ qua
		-- Điều chỉnh vị trí main toggle để tránh đè lên
		FeatureFrame2.Position = UDim2.new(1, -65, 0.5, 0)  -- dịch sang trái để chừa chỗ cho config
	end
	-- ===== END CONFIG TOGGLE =====

	-- Sự kiện toggle chính
	ToggleButton.MouseButton1Click:Connect(function()
		CircleClick(ToggleButton, Mouse.X, Mouse.Y) 
		ToggleFunc.Value = not ToggleFunc.Value
		ToggleFunc:Set(ToggleFunc.Value)
	end)

	function ToggleFunc:Set(Value)
		ToggleConfig.Callback(Value)
		if Value then
			TweenService:Create(
				ToggleTitle,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{TextColor3 = Color3.fromRGB(255, 0, 255)}
			):Play()
			TweenService:Create(
				ToggleCircle,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{Position = UDim2.new(0, 15, 0, 0)}
			):Play()
			TweenService:Create(
				UIStroke8,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{Color = Color3.fromRGB(255, 0, 255), Transparency = 0}
			):Play()
			TweenService:Create(
				FeatureFrame2,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{BackgroundColor3 = Color3.fromRGB(255, 0, 255), BackgroundTransparency = 0} 
			):Play()
		else
			TweenService:Create(
				ToggleTitle,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{TextColor3 = Color3.fromRGB(230.77499270439148, 230.77499270439148, 230.77499270439148)}
			):Play()
			TweenService:Create(
				ToggleCircle,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{Position = UDim2.new(0, 0, 0, 0)}
			):Play()
			TweenService:Create(
				UIStroke8,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{Color = Color3.fromRGB(255, 255, 255), Transparency = 0.9}
			):Play()
			TweenService:Create(
				FeatureFrame2,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.9200000166893005}
			):Play()
		end
	end
	ToggleFunc:Set(ToggleFunc.Value)
	CountItem = CountItem + 1
	return ToggleFunc
end

-- Phần còn lại của thư viện (các hàm khác) giữ nguyên.
return FlurioreLib
