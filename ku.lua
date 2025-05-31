-- MyUILibrary.lua
local MyUILibrary = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- 默认主题
local Theme = {
    BackgroundColor = Color3.fromRGB(40, 40, 40),
    TextColor = Color3.fromRGB(255, 255, 255),
    ButtonColor = Color3.fromRGB(60, 60, 60),
    AccentColor = Color3.fromRGB(100, 100, 255)
}

-- 配置保存（示例，实际使用 DataStore）
local Config = {}
local function SaveConfig(flag, value)
    Config[flag] = value
end
local function LoadConfig(flag, default)
    return Config[flag] or default
end

-- 动画函数
local function FadeIn(element)
    element.BackgroundTransparency = 1
    local tween = TweenService:Create(element, TweenInfo.new(0.5), {BackgroundTransparency = 0})
    tween:Play()
end

local function SlideIn(element)
    local originalPos = element.Position
    element.Position = UDim2.new(originalPos.X.Scale, originalPos.X.Offset - 50, originalPos.Y.Scale, originalPos.Y.Offset)
    local tween = TweenService:Create(element, TweenInfo.new(0.3), {Position = originalPos})
    tween:Play()
end

-- 创建窗口
function MyUILibrary:CreateWindow(config)
    local window = {}
    window.Name = config.Name or "My UI"
    window.ScreenGui = Instance.new("ScreenGui")
    window.ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    window.ScreenGui.IgnoreGuiInset = true -- 适配移动设备

    -- 使用 UIScale 适配屏幕
    window.UIScale = Instance.new("UIScale")
    window.UIScale.Parent = window.ScreenGui
    window.UIScale.Scale = 1

    -- 动态调整大小
    local screenSize = game:GetService("GuiService"):GetScreenResolution()
    local scale = math.min(screenSize.X / 1920, screenSize.Y / 1080) -- 适配 Android
    window.UIScale.Scale = scale

    window.Frame = Instance.new("Frame")
    window.Frame.Size = UDim2.new(0, 300, 0, 400)
    window.Frame.Position = UDim2.new(0.5, -150, 0.5, -200)
    window.Frame.BackgroundColor3 = Theme.BackgroundColor
    window.Frame.Parent = window.ScreenGui
    window.Frame.ClipsDescendants = true
    FadeIn(window.Frame)

    window.Tabs = {}
    return window
end

-- 创建选项卡
function MyUILibrary:CreateTab(window, config)
    local tab = {}
    tab.Name = config.Name or "Tab"
    tab.Frame = Instance.new("Frame")
    tab.Frame.Size = UDim2.new(1, 0, 1, -30)
    tab.Frame.Position = UDim2.new(0, 0, 0, 30)
    tab.Frame.BackgroundTransparency = 1
    tab.Frame.Parent = window.Frame
    tab.Frame.Visible = false

    -- 选项卡按钮
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0, 100, 0, 30)
    tabButton.Position = UDim2.new(0, #window.Tabs * 100, 0, 0)
    tabButton.BackgroundColor3 = Theme.ButtonColor
    tabButton.TextColor3 = Theme.TextColor
    tabButton.Text = tab.Name
    tabButton.Parent = window.Frame
    SlideIn(tabButton)

    -- 支持触摸输入
    tabButton.MouseButton1Click:Connect(function()
        for _, t in pairs(window.Tabs) do
            t.Frame.Visible = false
        end
        tab.Frame.Visible = true
    end)
    tabButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            for _, t in pairs(window.Tabs) do
                t.Frame.Visible = false
            end
            tab.Frame.Visible = true
        end
    end)

    table.insert(window.Tabs, tab)
    return tab
end

-- 创建按钮
function MyUILibrary:CreateButton(tab, config)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 100, 0, 30)
    button.Position = UDim2.new(0, 10, 0, #tab.Frame:GetChildren() * 40)
    button.BackgroundColor3 = Theme.ButtonColor
    button.TextColor3 = Theme.TextColor
    button.Text = config.Text or "Button"
    button.Parent = tab.Frame
    SlideIn(button)

    button.MouseButton1Click:Connect(config.Callback or function() end)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            if config.Callback then config.Callback() end
        end
    end)

    return button
end

-- 创建开关
function MyUILibrary:CreateToggle(tab, config)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 100, 0, 30)
    toggle.Position = UDim2.new(0, 10, 0, #tab.Frame:GetChildren() * 40)
    toggle.BackgroundColor3 = Theme.ButtonColor
    toggle.TextColor3 = Theme.TextColor
    toggle.Text = config.Text or "Toggle"
    toggle.Parent = tab.Frame
    SlideIn(toggle)

    local state = LoadConfig(config.Flag, config.Default or false)
    toggle.Text = config.Text .. (state and " [ON]" or " [OFF]")

    local function updateToggle()
        state = not state
        toggle.Text = config.Text .. (state and " [ON]" or " [OFF]")
        SaveConfig(config.Flag, state)
        if config.Callback then config.Callback(state) end
    end

    toggle.MouseButton1Click:Connect(updateToggle)
    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            updateToggle()
        end
    end)

    return {Flag = config.Flag, GetState = function() return state end}
end

-- 创建滑块
function MyUILibrary:CreateSlider(tab, config)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0, 150, 0, 30)
    sliderFrame.Position = UDim2.new(0, 10, 0, #tab.Frame:GetChildren() * 40)
    sliderFrame.BackgroundColor3 = Theme.ButtonColor
    sliderFrame.Parent = tab.Frame
    SlideIn(sliderFrame)

    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(0, 100, 0, 10)
    sliderBar.Position = UDim2.new(0, 10, 0.5, -5)
    sliderBar.BackgroundColor3 = Theme.AccentColor
    sliderBar.Parent = sliderFrame

    local value = LoadConfig(config.Flag, config.Default or config.Min or 0)
    local min = config.Min or 0
    local max = config.Max or 100
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 30, 0, 20)
    label.Position = UDim2.new(1, 10, 0.5, -10)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.TextColor
    label.Text = tostring(value)
    label.Parent = sliderFrame

    local dragging = false
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = input.Position.X
            local sliderPos = sliderBar.AbsolutePosition.X
            local sliderWidth = sliderBar.AbsoluteSize.X
            local relativePos = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
            value = min + (max - min) * relativePos
            value = math.floor(value + 0.5)
            label.Text = tostring(value)
            SaveConfig(config.Flag, value)
            if config.Callback then config.Callback(value) end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return {Flag = config.Flag, GetValue = function() return value end}
end

-- 创建文本框
function MyUILibrary:CreateTextBox(tab, config)
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0, 100, 0, 30)
    textBox.Position = UDim2.new(0, 10, 0, #tab.Frame:GetChildren() * 40)
    textBox.BackgroundColor3 = Theme.ButtonColor
    textBox.TextColor3 = Theme.TextColor
    textBox.Text = LoadConfig(config.Flag, config.Default or "")
    textBox.Parent = tab.Frame
    SlideIn(textBox)

    textBox.FocusLost:Connect(function()
        SaveConfig(config.Flag, textBox.Text)
        if config.Callback then config.Callback(textBox.Text) end
    end)

    return {Flag = config.Flag, GetText = function() return textBox.Text end}
end

-- 设置主题
function MyUILibrary:SetTheme(newTheme)
    Theme = newTheme
    -- 遍历所有 UI 元素，更新样式（需要开发者实现）
end

-- 示例用法
local Window = MyUILibrary:CreateWindow({Name = "Test UI"})
local Tab = MyUILibrary:CreateTab(Window, {Name = "Settings"})
local Button = MyUILibrary:CreateButton(Tab, {
    Text = "Click Me",
    Callback = function()
        print("Button clicked!")
    end
})
local Toggle = MyUILibrary:CreateToggle(Tab, {
    Text = "Enable Feature",
    Flag = "Toggle1",
    Default = false,
    Callback = function(state)
        print("Toggle state:", state)
    end
})
local Slider = MyUILibrary:CreateSlider(Tab, {
    Text = "Volume",
    Flag = "Slider1",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value)
        print("Slider value:", value)
    end
})
local TextBox = MyUILibrary:CreateTextBox(Tab, {
    Flag = "TextBox1",
    Default = "Enter text",
    Callback = function(text)
        print("TextBox input:", text)
    end
})

return MyUILibrary
