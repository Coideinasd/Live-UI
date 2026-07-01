-- Window.lua (Debug + Dark Mode + Search)
local UserInputService = game:GetService("UserInputService")
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
local Camera = game:GetService("Workspace").CurrentCamera

local Root = script.Parent.Parent
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)
local Acrylic = require(Root.Acrylic)
local Assets = require(script.Parent.Assets)
local Components = script.Parent

local Spring = Flipper.Spring.new
local Instant = Flipper.Instant.new
local New = Creator.New

-- ===== DEBUG HELPER =====
local function debugLog(msg, ...)
    print("[Window Debug] " .. string.format(msg, ...))
end

return function(Config)
    debugLog("Khởi tạo Window với Config: %s", Config and "OK" or "nil")

    -- Kiểm tra Config bắt buộc
    assert(Config, "Config không được nil")
    assert(Config.Parent, "Config.Parent là nil – hãy truyền ScreenGui hợp lệ!")
    assert(Config.Size, "Config.Size bị thiếu")

    local Library = require(Root)  -- có thể gây lỗi nếu Root không đúng

    local Window = {
        Minimized = false,
        Maximized = false,
        Size = Config.Size,
        CurrentPos = 0,
        TabWidth = 0,
        Position = UDim2.fromOffset(
            Camera.ViewportSize.X / 2 - Config.Size.X.Offset / 2,
            Camera.ViewportSize.Y / 2 - Config.Size.Y.Offset / 2
        ),
        DarkMode = false,
        SearchVisible = true,
        SearchCallback = nil,
    }

    local Dragging, DragInput, MousePos, StartPos = false
    local Resizing, ResizePos = false
    local MinimizeNotif = false

    Window.AcrylicPaint = Acrylic.AcrylicPaint()
    Window.TabWidth = Config.TabWidth or 150

    local OldSizeX = Window.Size.X.Offset
    local OldSizeY = Window.Size.Y.Offset

    -- ====== TẠO UI ======
    local Selector = New("Frame", {
        Size = UDim2.fromOffset(4, 0),
        BackgroundColor3 = Color3.fromRGB(76, 194, 255),
        Position = UDim2.fromOffset(0, 17),
        AnchorPoint = Vector2.new(0, 0.5),
        ThemeTag = { BackgroundColor3 = "Accent" },
    }, {
        New("UICorner", { CornerRadius = UDim.new(0, 2) }),
    })

    local ResizeStartFrame = New("Frame", {
        Size = UDim2.fromOffset(20, 20),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 1, -20),
    })

    Window.TabHolder = New("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ScrollBarImageTransparency = 1,
        ScrollBarThickness = 0,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromScale(0, 0),
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, {
        New("UIListLayout", { Padding = UDim.new(0, 4) }),
    })

    local TabFrame = New("Frame", {
        Size = UDim2.new(0, Window.TabWidth, 1, -66),
        Position = UDim2.new(0, 12, 0, 54),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
    }, {
        Window.TabHolder,
        Selector,
    })

    Window.TabDisplay = New("TextLabel", {
        RichText = true,
        Text = "Tab",
        TextTransparency = 0,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        TextSize = 28,
        TextXAlignment = "Left",
        TextYAlignment = "Center",
        Size = UDim2.new(1, -16, 0, 28),
        Position = UDim2.fromOffset(Window.TabWidth + 26, 56),
        BackgroundTransparency = 1,
        ThemeTag = { TextColor3 = "Text" },
    })

    -- ===== SEARCH =====
    local SearchFrame = New("Frame", {
        Size = UDim2.new(0, 200, 0, 30),
        Position = UDim2.new(1, -220, 0, 54),
        BackgroundTransparency = 1,
        Visible = true,
    })

    local SearchBox = New("TextBox", {
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        TextColor3 = Color3.fromRGB(230, 230, 230),
        TextSize = 14,
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        PlaceholderText = "Search...",
        PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ClipsDescendants = true,
        ClearTextOnFocus = false,
    }, {
        New("UICorner", { CornerRadius = UDim.new(0, 4) }),
        New("UIStroke", { Color = Color3.fromRGB(80, 80, 80), Thickness = 1 }),
    })

    local SearchIcon = New("ImageLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -26, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031091010",
        ImageColor3 = Color3.fromRGB(180, 180, 180),
    })
    SearchIcon.Parent = SearchFrame
    SearchBox.Parent = SearchFrame

    -- ===== TOGGLES (Dark Mode & Search) =====
    local ToggleFrame = New("Frame", {
        Size = UDim2.new(0, 70, 0, 30),
        Position = UDim2.new(1, -80, 0, 10),
        BackgroundTransparency = 1,
    })

    local DarkModeToggle = New("ImageButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031091010",
        ImageColor3 = Color3.fromRGB(180, 180, 180),
    })

    local SearchToggle = New("ImageButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -30, 0, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031091010",
        ImageColor3 = Color3.fromRGB(180, 180, 180),
    })

    DarkModeToggle.Parent = ToggleFrame
    SearchToggle.Parent = ToggleFrame

    local function UpdateToggleIcons()
        DarkModeToggle.Image = Window.DarkMode and "rbxassetid://6031091010" or "rbxassetid://6031091010"
        SearchToggle.Image = Window.SearchVisible and "rbxassetid://6031091010" or "rbxassetid://6031091010"
    end
    UpdateToggleIcons()

    local function ApplyDarkMode(enable)
        if enable then
            Window.AcrylicPaint.Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            Window.AcrylicPaint.Frame.BackgroundTransparency = 0.15
        else
            Window.AcrylicPaint.Frame.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
            Window.AcrylicPaint.Frame.BackgroundTransparency = 0.3
        end
        Window.DarkMode = enable
        debugLog("Dark Mode đã được đặt thành: %s", enable)
    end

    Creator.AddSignal(DarkModeToggle.MouseButton1Click, function()
        ApplyDarkMode(not Window.DarkMode)
        UpdateToggleIcons()
    end)

    Creator.AddSignal(SearchToggle.MouseButton1Click, function()
        Window.SearchVisible = not Window.SearchVisible
        SearchFrame.Visible = Window.SearchVisible
        UpdateToggleIcons()
    end)

    Creator.AddSignal(SearchBox.FocusLost, function(EnterPressed)
        if EnterPressed and Window.SearchCallback then
            Window.SearchCallback(SearchBox.Text)
        end
    end)

    Creator.AddSignal(SearchBox.InputBegan, function(Input)
        if Input.KeyCode == Enum.KeyCode.Return and Window.SearchCallback then
            Window.SearchCallback(SearchBox.Text)
        end
    end)

    function Window:SetSearchCallback(callback)
        Window.SearchCallback = callback
        debugLog("Search callback đã đăng ký")
    end

    -- ===== CONTAINERS =====
    Window.ContainerHolder = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    })

    Window.ContainerAnim = New("CanvasGroup", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    })

    Window.ContainerCanvas = New("Frame", {
        Size = UDim2.new(1, -Window.TabWidth - 32, 1, -102),
        Position = UDim2.fromOffset(Window.TabWidth + 26, 90),
        BackgroundTransparency = 1,
    }, {
        Window.ContainerAnim,
        Window.ContainerHolder
    })

    -- ===== ROOT =====
    Window.Root = New("Frame", {
        BackgroundTransparency = 1,
        Size = Window.Size,
        Position = Window.Position,
        Parent = Config.Parent,   -- Đã kiểm tra không nil ở trên
    }, {
        Window.AcrylicPaint.Frame,
        Window.TabDisplay,
        Window.ContainerCanvas,
        TabFrame,
        ResizeStartFrame,
        SearchFrame,
        ToggleFrame,
    })

    debugLog("Root đã được tạo với Parent: %s", tostring(Config.Parent.Name or "unknown"))

    Window.TitleBar = require(script.Parent.TitleBar)({
        Title = Config.Title or "Window",
        SubTitle = Config.SubTitle or "",
        Parent = Window.Root,
        Window = Window,
    })

    if require(Root).UseAcrylic then
        Window.AcrylicPaint.AddParent(Window.Root)
    end

    -- ===== MOTORS =====
    local SizeMotor = Flipper.GroupMotor.new({
        X = Window.Size.X.Offset,
        Y = Window.Size.Y.Offset,
    })
    local PosMotor = Flipper.GroupMotor.new({
        X = Window.Position.X.Offset,
        Y = Window.Position.Y.Offset,
    })

    Window.SelectorPosMotor = Flipper.SingleMotor.new(17)
    Window.SelectorSizeMotor = Flipper.SingleMotor.new(0)
    Window.ContainerBackMotor = Flipper.SingleMotor.new(0)
    Window.ContainerPosMotor = Flipper.SingleMotor.new(94)

    SizeMotor:onStep(function(values)
        Window.Root.Size = UDim2.new(0, values.X, 0, values.Y)
    end)

    PosMotor:onStep(function(values)
        Window.Root.Position = UDim2.new(0, values.X, 0, values.Y)
    end)

    local LastValue = 0
    local LastTime = 0
    Window.SelectorPosMotor:onStep(function(Value)
        Selector.Position = UDim2.new(0, 0, 0, Value + 17)
        local Now = tick()
        local DeltaTime = Now - LastTime
        if LastValue ~= nil then
            Window.SelectorSizeMotor:setGoal(Spring((math.abs(Value - LastValue) / (DeltaTime * 60)) + 16))
            LastValue = Value
        end
        LastTime = Now
    end)

    Window.SelectorSizeMotor:onStep(function(Value)
        Selector.Size = UDim2.new(0, 4, 0, Value)
    end)

    Window.ContainerBackMotor:onStep(function(Value)
        Window.ContainerAnim.GroupTransparency = Value
    end)

    Window.ContainerPosMotor:onStep(function(Value)
        Window.ContainerAnim.Position = UDim2.fromOffset(0, Value)
    end)

    -- ===== MAXIMIZE =====
    Window.Maximize = function(Value, NoPos, NoAnim)
        debugLog("Maximize gọi với Value=%s", Value)
        Window.Maximized = Value
        Window.TitleBar.MaxButton.Frame.Icon.Image = Value and Assets.Restore or Assets.Max

        if Value then
            OldSizeX = Window.Size.X.Offset
            OldSizeY = Window.Size.Y.Offset
        end
        local SizeX = Value and Camera.ViewportSize.X or OldSizeX
        local SizeY = Value and Camera.ViewportSize.Y or OldSizeY

        if NoAnim then
            SizeMotor:setGoal({
                X = Flipper.Instant.new(SizeX),
                Y = Flipper.Instant.new(SizeY),
            })
        else
            SizeMotor:setGoal({
                X = Flipper.Spring.new(SizeX, { frequency = 6 }),
                Y = Flipper.Spring.new(SizeY, { frequency = 6 }),
            })
        end
        Window.Size = UDim2.fromOffset(SizeX, SizeY)

        if not NoPos then
            if NoAnim then
                PosMotor:setGoal({
                    X = Flipper.Instant.new(Value and 0 or Window.Position.X.Offset),
                    Y = Flipper.Instant.new(Value and 0 or Window.Position.Y.Offset),
                })
            else
                PosMotor:setGoal({
                    X = Spring(Value and 0 or Window.Position.X.Offset, { frequency = 6 }),
                    Y = Spring(Value and 0 or Window.Position.Y.Offset, { frequency = 6 }),
                })
            end
        end
    end

    -- ===== EVENTS =====
    Creator.AddSignal(Window.TitleBar.Frame.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            MousePos = Input.Position
            StartPos = Window.Root.Position
            if Window.Maximized then
                StartPos = UDim2.fromOffset(
                    Mouse.X - (Mouse.X * ((OldSizeX - 100) / Window.Root.AbsoluteSize.X)),
                    Mouse.Y - (Mouse.Y * (OldSizeY / Window.Root.AbsoluteSize.Y))
                )
            end
            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    Creator.AddSignal(Window.TitleBar.Frame.InputChanged, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            DragInput = Input
        end
    end)

    Creator.AddSignal(ResizeStartFrame.InputBegan, function(Input)
        if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch)
            and not Window.Maximized then
            Resizing = true
            ResizePos = Input.Position
        end
    end)

    Creator.AddSignal(UserInputService.InputChanged, function(Input)
        if Input == DragInput and Dragging then
            local Delta = Input.Position - MousePos
            Window.Position = UDim2.fromOffset(StartPos.X.Offset + Delta.X, StartPos.Y.Offset + Delta.Y)
            PosMotor:setGoal({
                X = Instant(Window.Position.X.Offset),
                Y = Instant(Window.Position.Y.Offset),
            })
            if Window.Maximized then
                Window.Maximize(false, true, true)
            end
        end

        if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
            and Resizing then
            local Delta = Input.Position - ResizePos
            local StartSize = Window.Size
            local TargetSize = Vector3.new(StartSize.X.Offset, StartSize.Y.Offset, 0) + Vector3.new(1, 1, 0) * Delta
            local TargetSizeClamped = Vector2.new(math.clamp(TargetSize.X, 470, 2048), math.clamp(TargetSize.Y, 380, 2048))
            SizeMotor:setGoal({
                X = Flipper.Instant.new(TargetSizeClamped.X),
                Y = Flipper.Instant.new(TargetSizeClamped.Y),
            })
        end
    end)

    Creator.AddSignal(UserInputService.InputEnded, function(Input)
        if Resizing == true or Input.UserInputType == Enum.UserInputType.Touch then
            Resizing = false
            Window.Size = UDim2.fromOffset(SizeMotor:getValue().X, SizeMotor:getValue().Y)
        end
    end)

    Creator.AddSignal(Window.TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        Window.TabHolder.CanvasSize = UDim2.new(0, 0, 0, Window.TabHolder.UIListLayout.AbsoluteContentSize.Y)
    end)

    Creator.AddSignal(UserInputService.InputBegan, function(Input)
        if type(Library.MinimizeKeybind) == "table"
            and Library.MinimizeKeybind.Type == "Keybind"
            and not UserInputService:GetFocusedTextBox() then
            if Input.KeyCode.Name == Library.MinimizeKeybind.Value then
                Window:Minimize()
            end
        elseif Input.KeyCode == Library.MinimizeKey and not UserInputService:GetFocusedTextBox() then
            Window:Minimize()
        end
    end)

    function Window:Minimize()
        Window.Minimized = not Window.Minimized
        Window.Root.Visible = not Window.Minimized
        if not MinimizeNotif then
            MinimizeNotif = true
            local Key = Library.MinimizeKeybind and Library.MinimizeKeybind.Value or Library.MinimizeKey.Name
            Library:Notify({
                Title = "Interface",
                Content = "Press " .. Key .. " to toggle the interface.",
                Duration = 6
            })
        end
    end

    function Window:Destroy()
        if require(Root).UseAcrylic then
            Window.AcrylicPaint.Model:Destroy()
        end
        Window.Root:Destroy()
        debugLog("Window đã bị hủy")
    end

    -- ===== DIALOG =====
    local DialogModule = require(Components.Dialog):Init(Window)
    function Window:Dialog(Config)
        local Dialog = DialogModule:Create()
        Dialog.Title.Text = Config.Title
        local Content = New("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            Text = Config.Content,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.fromOffset(20, 60),
            BackgroundTransparency = 1,
            Parent = Dialog.Root,
            ClipsDescendants = false,
            ThemeTag = { TextColor3 = "Text" },
        })
        New("UISizeConstraint", {
            MinSize = Vector2.new(300, 165),
            MaxSize = Vector2.new(620, math.huge),
            Parent = Dialog.Root,
        })
        Dialog.Root.Size = UDim2.fromOffset(Content.TextBounds.X + 40, 165)
        if Content.TextBounds.X + 40 > Window.Size.X.Offset - 120 then
            Dialog.Root.Size = UDim2.fromOffset(Window.Size.X.Offset - 120, 165)
            Content.TextWrapped = true
            Dialog.Root.Size = UDim2.fromOffset(Window.Size.X.Offset - 120, Content.TextBounds.Y + 150)
        end
        for _, Button in next, Config.Buttons do
            Dialog:Button(Button.Title, Button.Callback)
        end
        Dialog:Open()
    end

    -- ===== TABS =====
    local TabModule = require(Components.Tab):Init(Window)
    function Window:AddTab(TabConfig)
        return TabModule:New(TabConfig.Title, TabConfig.Icon, Window.TabHolder)
    end

    function Window:SelectTab(Tab)
        TabModule:SelectTab(1)
    end

    Creator.AddSignal(Window.TabHolder:GetPropertyChangedSignal("CanvasPosition"), function()
        LastValue = TabModule:GetCurrentTabPos() + 16
        LastTime = 0
        Window.SelectorPosMotor:setGoal(Instant(TabModule:GetCurrentTabPos()))
    end)

    -- Mặc định bật Dark Mode? (có thể đổi thành true nếu muốn)
    ApplyDarkMode(false)

    debugLog("Window khởi tạo thành công!")
    return Window
end
