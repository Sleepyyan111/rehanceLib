--[[
   re//hance UI Library
   A modern, clean UI library for Roblox executors
   Version: 1.0.5
]]

local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Version
Library.Version = "1.0.5"

-- Configuration
Library.Config = {
    Theme = {
        Background = Color3.fromRGB(18, 18, 24),
        Accent = Color3.fromRGB(148, 162, 255),
        AccentGradient = {
            Color3.fromRGB(148, 162, 255),
            Color3.fromRGB(130, 100, 255)
        },
        Text = Color3.fromRGB(220, 220, 230),
        TextMuted = Color3.fromRGB(150, 150, 165),
        Darker = Color3.fromRGB(24, 24, 32),
        DarkerHover = Color3.fromRGB(32, 32, 42),
        ToggleOff = Color3.fromRGB(45, 45, 55),
        ToggleOn = Color3.fromRGB(148, 162, 255),
        Border = Color3.fromRGB(45, 45, 55),
        Shadow = Color3.fromRGB(0, 0, 0),
    },
    AnimationSpeed = 0.3,
}

-- Get or create ScreenGui (persists on death)
local function GetOrCreateScreenGui()
    local player = Players.LocalPlayer
    if not player then return nil end

    local gui = player:FindFirstChild("rehanceUI")
    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Name = "rehanceUI"
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = player:WaitForChild("PlayerGui")
        gui.ResetOnSpawn = false
    end
    return gui
end

-- Create ScreenGui
local ScreenGui = GetOrCreateScreenGui()
if not ScreenGui then
    error("Failed to create ScreenGui")
end

-- If player respawns, re-parent to new PlayerGui
Players.LocalPlayer.CharacterAdded:Connect(function()
    if ScreenGui and ScreenGui.Parent ~= Players.LocalPlayer:FindFirstChild("PlayerGui") then
        ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end)

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 680, 0, 480)
Main.Position = UDim2.new(0.5, -340, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Visible = false
Main.Parent = ScreenGui

-- Corner
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

-- Shadow
local Shadow = Instance.new("Frame")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 20, 1, 20)
Shadow.Position = UDim2.new(0, -10, 0, -10)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.6
Shadow.BorderSizePixel = 0
Shadow.ZIndex = 0
Shadow.Parent = Main

local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 16)
ShadowCorner.Parent = Shadow

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(45, 45, 55)
Stroke.Thickness = 1
Stroke.Parent = Main

-- Drag Bar with Gradient
local DragBar = Instance.new("Frame")
DragBar.Name = "DragBar"
DragBar.Size = UDim2.new(1, 0, 0, 44)
DragBar.BackgroundTransparency = 1
DragBar.Parent = Main

-- Gradient for drag bar
local DragBarGradient = Instance.new("UIGradient")
DragBarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 24))
})
DragBarGradient.Parent = DragBar

-- Title with gradient
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0, 100, 0, 44)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "re//hance"
Title.TextColor3 = Library.Config.Theme.Accent
Title.TextSize = 16
Title.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Bold)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = DragBar

-- Version Label
local VersionLabel = Instance.new("TextLabel")
VersionLabel.Name = "VersionLabel"
VersionLabel.Size = UDim2.new(0, 60, 0, 44)
VersionLabel.Position = UDim2.new(0, 105, 0, 0)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "v" .. Library.Version
VersionLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
VersionLabel.TextSize = 11
VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
VersionLabel.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
VersionLabel.Parent = DragBar

-- Username with icon
local Username = Instance.new("TextLabel")
Username.Name = "Username"
Username.Size = UDim2.new(0, 180, 0, 44)
Username.Position = UDim2.new(1, -190, 0, 0)
Username.BackgroundTransparency = 1
Username.Text = "👤 " .. Players.LocalPlayer.DisplayName
Username.TextColor3 = Color3.fromRGB(180, 180, 195)
Username.TextSize = 13
Username.TextXAlignment = Enum.TextXAlignment.Right
Username.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
Username.Parent = DragBar

-- Tab Container
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, 0, 1, -44)
TabContainer.Position = UDim2.new(0, 0, 0, 44)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Main

-- Tab Chooser with background
local TabChooser = Instance.new("Frame")
TabChooser.Name = "TabChooser"
TabChooser.Size = UDim2.new(0, 220, 0, 40)
TabChooser.Position = UDim2.new(0.5, -110, 1, -45)
TabChooser.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
TabChooser.BorderSizePixel = 0
TabChooser.ClipsDescendants = true
TabChooser.Parent = Main

local TabChooserCorner = Instance.new("UICorner")
TabChooserCorner.CornerRadius = UDim.new(0, 20)
TabChooserCorner.Parent = TabChooser

local TabChooserStroke = Instance.new("UIStroke")
TabChooserStroke.Color = Color3.fromRGB(45, 45, 55)
TabChooserStroke.Thickness = 1
TabChooserStroke.Parent = TabChooser

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 4)
TabListLayout.Parent = TabChooser

-- Toggle Button (Gui Button) - Top center with gradient
local GuiButton = Instance.new("TextButton")
GuiButton.Name = "GuiButton"
GuiButton.Size = UDim2.new(0, 54, 0, 54)
GuiButton.Position = UDim2.new(0.5, -27, 0.06, 0)
GuiButton.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
GuiButton.Text = "◆"
GuiButton.TextColor3 = Library.Config.Theme.Accent
GuiButton.TextSize = 20
GuiButton.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
GuiButton.AutoButtonColor = false
GuiButton.BorderSizePixel = 0
GuiButton.Parent = ScreenGui

local GuiButtonCorner = Instance.new("UICorner")
GuiButtonCorner.CornerRadius = UDim.new(1, 0)
GuiButtonCorner.Parent = GuiButton

local GuiButtonStroke = Instance.new("UIStroke")
GuiButtonStroke.Color = Color3.fromRGB(45, 45, 55)
GuiButtonStroke.Thickness = 1
GuiButtonStroke.Parent = GuiButton

-- GuiButton shadow
local GuiButtonShadow = Instance.new("Frame")
GuiButtonShadow.Name = "Shadow"
GuiButtonShadow.Size = UDim2.new(1, 8, 1, 8)
GuiButtonShadow.Position = UDim2.new(0, -4, 0, -4)
GuiButtonShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
GuiButtonShadow.BackgroundTransparency = 0.5
GuiButtonShadow.BorderSizePixel = 0
GuiButtonShadow.ZIndex = 0
GuiButtonShadow.Parent = GuiButton

local GuiButtonShadowCorner = Instance.new("UICorner")
GuiButtonShadowCorner.CornerRadius = UDim.new(1, 0)
GuiButtonShadowCorner.Parent = GuiButtonShadow

-- Dragging functionality
local dragging = false
local dragStart = nil
local startPos = nil

DragBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Core Functions
local tabs = {}
local currentTab = nil
local tabButtons = {}

-- Helper function to update canvas size
local function UpdateTabCanvas(tab)
    if not tab or not tab.ElementContainer or not tab.Layout then return end

    local contentSize = tab.Layout.AbsoluteContentSize

    if contentSize.Y == 0 then
        local totalHeight = 0
        local children = tab.ElementContainer:GetChildren()
        for _, child in ipairs(children) do
            if child:IsA("Frame") then
                totalHeight = totalHeight + child.Size.Y.Offset + 6
            end
        end
        if totalHeight > 0 then
            contentSize = Vector2.new(0, totalHeight)
        end
    end

    if contentSize.Y > 0 then
        tab.ElementContainer.Size = UDim2.new(1, 0, 0, contentSize.Y + 15)
        tab.Frame.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y + 20)
    end
end

-- Create a new tab
function Library:NewTab(name)
    local tab = {}
    tab.Name = name
    tab.Elements = {}

    -- Create tab frame
    tab.Frame = Instance.new("ScrollingFrame")
    tab.Frame.Name = name
    tab.Frame.Size = UDim2.new(1, 0, 1, -5)
    tab.Frame.BackgroundTransparency = 1
    tab.Frame.BorderSizePixel = 0
    tab.Frame.ScrollBarThickness = 3
    tab.Frame.ScrollBarImageTransparency = 0.7
    tab.Frame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
    tab.Frame.Active = true
    tab.Frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tab.Frame.Parent = TabContainer
    tab.Frame.Visible = false

    -- Create a container frame for elements with UIListLayout
    local elementContainer = Instance.new("Frame")
    elementContainer.Name = "ElementContainer"
    elementContainer.Size = UDim2.new(1, 0, 0, 0)
    elementContainer.BackgroundTransparency = 1
    elementContainer.Parent = tab.Frame

    -- UIListLayout for elements with better spacing
    local layout = Instance.new("UIListLayout")
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = elementContainer

    -- Update canvas size when elements are added
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        UpdateTabCanvas(tab)
    end)

    tab.ElementContainer = elementContainer
    tab.Layout = layout

    -- Create tab button with modern style
    local button = Instance.new("TextButton")
    button.Name = "TabButton"
    button.Size = UDim2.new(0, 70, 0, 32)
    button.BackgroundTransparency = 1
    button.Text = name
    button.TextSize = 13
    button.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
    button.AutoButtonColor = false
    button.BorderSizePixel = 0
    button.TextColor3 = Color3.fromRGB(150, 150, 170)
    button.Parent = TabChooser

    if not currentTab then
        currentTab = tab
        tab.Frame.Visible = true
        button.TextColor3 = Library.Config.Theme.Accent
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 16)
        btnCorner.Parent = button
    end

    -- Tab switching with animation
    button.MouseButton1Click:Connect(function()
        if currentTab == tab then return end

        if currentTab then
            currentTab.Frame.Visible = false
        end

        tab.Frame.Visible = true

        for _, btn in pairs(tabButtons) do
            btn.TextColor3 = Color3.fromRGB(150, 150, 170)
            btn.BackgroundTransparency = 1
            -- Remove corner if exists
            local corner = btn:FindFirstChild("UICorner")
            if corner then corner:Destroy() end
        end
        
        button.TextColor3 = Library.Config.Theme.Accent
        button.BackgroundTransparency = 0
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 16)
        btnCorner.Parent = button

        currentTab = tab

        task.wait()
        UpdateTabCanvas(tab)
    end)

    table.insert(tabs, tab)
    table.insert(tabButtons, button)

    -- Element creation functions
    function tab:Toggle(text, default)
        local element = {}
        element.Type = "Toggle"
        element.Value = default or false
        element.OnChange = nil

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 640, 0, 44)
        frame.BackgroundColor3 = Library.Config.Theme.Darker
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.ZIndex = 1
        frame.Parent = tab.ElementContainer

        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 8)
        frameCorner.Parent = frame

        local frameStroke = Instance.new("UIStroke")
        frameStroke.Color = Color3.fromRGB(45, 45, 55)
        frameStroke.Thickness = 0.5
        frameStroke.Parent = frame

        local label = Instance.new("TextLabel")
        label.Name = "Text"
        label.Size = UDim2.new(0, 82, 0, 44)
        label.Position = UDim2.new(0.02, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Library.Config.Theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
        label.ZIndex = 1
        label.Parent = frame

        local toggle = Instance.new("ImageButton")
        toggle.Name = "Toggle"
        toggle.Size = UDim2.new(0, 24, 0, 24)
        toggle.Position = UDim2.new(0.945, 0, 0.227, 0)
        toggle.BackgroundColor3 = element.Value and Library.Config.Theme.ToggleOn or Library.Config.Theme.ToggleOff
        toggle.Image = "rbxassetid://0"
        toggle.ImageTransparency = 1
        toggle.AutoButtonColor = false
        toggle.BorderSizePixel = 0
        toggle.ZIndex = 1
        toggle.Parent = frame

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 12)
        toggleCorner.Parent = toggle

        -- Toggle indicator dot
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 16, 0, 16)
        dot.Position = UDim2.new(0.02, 0, 0.02, 0)
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dot.BackgroundTransparency = element.Value and 0 or 0.5
        dot.BorderSizePixel = 0
        dot.ZIndex = 2
        dot.Parent = toggle
        
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(0, 8)
        dotCorner.Parent = dot

        local debounce = false

        function element:Set(value)
            element.Value = value
            local targetColor = element.Value and Library.Config.Theme.ToggleOn or Library.Config.Theme.ToggleOff
            TweenService:Create(toggle, TweenInfo.new(0.2), {
                BackgroundColor3 = targetColor
            }):Play()
            TweenService:Create(dot, TweenInfo.new(0.2), {
                BackgroundTransparency = element.Value and 0 or 0.5,
                Position = element.Value and UDim2.new(0.75, 0, 0.02, 0) or UDim2.new(0.02, 0, 0.02, 0)
            }):Play()
            if element.OnChange then
                element.OnChange(element.Value)
            end
        end

        function element:OnChange(callback)
            element.OnChange = callback
            return element
        end

        toggle.MouseButton1Click:Connect(function()
            if debounce then return end
            debounce = true
            element:Set(not element.Value)
            task.wait(0.3)
            debounce = false
        end)

        task.wait()
        UpdateTabCanvas(tab)

        return element
    end

    -- Dropdown for custom options (ANIMATED & HIGHER Z-INDEX)
    function tab:Dropdown(text, options, default)
        local element = {}
        element.Type = "Dropdown"
        element.Value = default or options[1] or ""
        element.Options = options
        element.Open = false
        element.OnChange = nil

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 640, 0, 44)
        frame.BackgroundColor3 = Library.Config.Theme.Darker
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = false
        frame.ZIndex = 10
        frame.Parent = tab.ElementContainer

        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 8)
        frameCorner.Parent = frame

        local frameStroke = Instance.new("UIStroke")
        frameStroke.Color = Color3.fromRGB(45, 45, 55)
        frameStroke.Thickness = 0.5
        frameStroke.Parent = frame

        local label = Instance.new("TextLabel")
        label.Name = "Text"
        label.Size = UDim2.new(0, 82, 0, 44)
        label.Position = UDim2.new(0.02, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Library.Config.Theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
        label.ZIndex = 10
        label.Parent = frame

        -- Dropdown button
        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Name = "DropdownButton"
        dropdownButton.Size = UDim2.new(0, 150, 0, 28)
        dropdownButton.Position = UDim2.new(0.765, 0, 0.182, 0)
        dropdownButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        dropdownButton.Text = element.Value
        dropdownButton.TextColor3 = Color3.fromRGB(200, 200, 215)
        dropdownButton.TextSize = 13
        dropdownButton.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
        dropdownButton.AutoButtonColor = false
        dropdownButton.BorderSizePixel = 0
        dropdownButton.ClipsDescendants = false
        dropdownButton.ZIndex = 11
        dropdownButton.Parent = frame

        local dropdownCorner = Instance.new("UICorner")
        dropdownCorner.CornerRadius = UDim.new(0, 6)
        dropdownCorner.Parent = dropdownButton

        -- Dropdown arrow using ⮃
        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 20, 1, 0)
        arrow.Position = UDim2.new(1, -24, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = "▾"
        arrow.TextColor3 = Color3.fromRGB(150, 150, 170)
        arrow.TextSize = 16
        arrow.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
        arrow.ZIndex = 12
        arrow.Parent = dropdownButton

        -- Dropdown options frame
        local optionsFrame = Instance.new("Frame")
        optionsFrame.Name = "OptionsFrame"
        optionsFrame.Size = UDim2.new(0, 150, 0, 0)
        optionsFrame.Position = UDim2.new(0.765, 0, 1, 2)
        optionsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        optionsFrame.BorderSizePixel = 0
        optionsFrame.ClipsDescendants = true
        optionsFrame.Visible = true
        optionsFrame.ZIndex = 20
        optionsFrame.Parent = frame

        local optionsCorner = Instance.new("UICorner")
        optionsCorner.CornerRadius = UDim.new(0, 6)
        optionsCorner.Parent = optionsFrame

        local optionsStroke = Instance.new("UIStroke")
        optionsStroke.Color = Color3.fromRGB(45, 45, 55)
        optionsStroke.Thickness = 0.5
        optionsStroke.Parent = optionsFrame

        local optionsLayout = Instance.new("UIListLayout")
        optionsLayout.FillDirection = Enum.FillDirection.Vertical
        optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        optionsLayout.Padding = UDim.new(0, 2)
        optionsLayout.Parent = optionsFrame

        -- Pre-calculate the target height for the animation
        local function GetOptionsHeight()
            local maxItems = 5
            local itemHeight = 30
            local totalItems = math.min(#options, maxItems)
            if totalItems == 0 then
                return 30
            end
            return totalItems * itemHeight + (totalItems - 1) * 2 + 4
        end
        local targetHeight = GetOptionsHeight()

        -- Initially set size to 0 (hidden)
        optionsFrame.Size = UDim2.new(0, 150, 0, 0)

        -- Function to update dropdown options (without changing size)
        local function UpdateDropdownContent()
            -- Clear existing options
            for _, child in pairs(optionsFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end

            local maxItems = 5
            local itemHeight = 30
            local totalItems = math.min(#options, maxItems)

            if totalItems == 0 then
                local noOptions = Instance.new("TextLabel")
                noOptions.Size = UDim2.new(1, 0, 1, 0)
                noOptions.BackgroundTransparency = 1
                noOptions.Text = "No options"
                noOptions.TextColor3 = Color3.fromRGB(150, 150, 170)
                noOptions.TextSize = 12
                noOptions.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
                noOptions.ZIndex = 21
                noOptions.Parent = optionsFrame
                return
            end

            for i = 1, totalItems do
                local optionText = options[i]
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1, 0, 0, itemHeight)
                item.BackgroundTransparency = 1
                item.Text = optionText
                item.TextColor3 = Color3.fromRGB(200, 200, 215)
                item.TextSize = 13
                item.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
                item.AutoButtonColor = false
                item.BorderSizePixel = 0
                item.ZIndex = 21
                item.Parent = optionsFrame

                item.MouseEnter:Connect(function()
                    item.BackgroundTransparency = 0.5
                    item.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                end)

                item.MouseLeave:Connect(function()
                    item.BackgroundTransparency = 1
                end)

                item.MouseButton1Click:Connect(function()
                    element.Value = optionText
                    dropdownButton.Text = optionText
                    CloseDropdown()
                    if element.OnChange then
                        element.OnChange(element.Value)
                    end
                end)
            end
        end

        -- Animated Open/Close functions
        local function OpenDropdown()
            if element.Open then return end
            element.Open = true
            arrow.Text = "▴"

            UpdateDropdownContent()

            optionsFrame.Visible = true
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(optionsFrame, tweenInfo, {
                Size = UDim2.new(0, 150, 0, targetHeight)
            })
            tween:Play()
        end

        local function CloseDropdown()
            if not element.Open then return end
            element.Open = false
            arrow.Text = "▾"

            local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            local tween = TweenService:Create(optionsFrame, tweenInfo, {
                Size = UDim2.new(0, 150, 0, 0)
            })
            tween:Play()
            tween.Completed:Connect(function()
                optionsFrame.Visible = false
            end)
        end

        function element:OnChange(callback)
            element.OnChange = callback
            return element
        end

        dropdownButton.MouseButton1Click:Connect(function()
            if element.Open then
                CloseDropdown()
            else
                OpenDropdown()
            end
        end)

        -- Close dropdown when clicking outside
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if element.Open then
                    local mousePos = UserInputService:GetMouseLocation()
                    local absPos = optionsFrame.AbsolutePosition
                    local absSize = optionsFrame.AbsoluteSize

                    local buttonAbsPos = dropdownButton.AbsolutePosition
                    local buttonAbsSize = dropdownButton.AbsoluteSize

                    local isOutsideOptions = not (mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X and
                                                  mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y)

                    local isOutsideButton = not (mousePos.X >= buttonAbsPos.X and mousePos.X <= buttonAbsPos.X + buttonAbsSize.X and
                                                 mousePos.Y >= buttonAbsPos.Y and mousePos.Y <= buttonAbsPos.Y + buttonAbsSize.Y)

                    if isOutsideOptions and isOutsideButton then
                        CloseDropdown()
                    end
                end
            end
        end)

        -- Initial setup
        task.wait()
        UpdateDropdownContent()

        task.wait()
        UpdateTabCanvas(tab)

        return element
    end

    -- Player Dropdown (auto-populates with player names)
    function tab:PlayerDropdown(text, default)
        local element = {}
        element.Type = "PlayerDropdown"
        element.Value = default or ""
        element.Open = false
        element.OnChange = nil

        -- Get all players except local
        local function GetPlayerNames()
            local names = {}
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer then
                    table.insert(names, player.Name)
                end
            end
            table.sort(names)
            return names
        end

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 640, 0, 44)
        frame.BackgroundColor3 = Library.Config.Theme.Darker
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = false
        frame.ZIndex = 10
        frame.Parent = tab.ElementContainer

        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 8)
        frameCorner.Parent = frame

        local frameStroke = Instance.new("UIStroke")
        frameStroke.Color = Color3.fromRGB(45, 45, 55)
        frameStroke.Thickness = 0.5
        frameStroke.Parent = frame

        local label = Instance.new("TextLabel")
        label.Name = "Text"
        label.Size = UDim2.new(0, 82, 0, 44)
        label.Position = UDim2.new(0.02, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Library.Config.Theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
        label.ZIndex = 10
        label.Parent = frame

        -- Dropdown button
        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Name = "DropdownButton"
        dropdownButton.Size = UDim2.new(0, 150, 0, 28)
        dropdownButton.Position = UDim2.new(0.765, 0, 0.182, 0)
        dropdownButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        dropdownButton.Text = element.Value or "Select Player..."
        dropdownButton.TextColor3 = Color3.fromRGB(200, 200, 215)
        dropdownButton.TextSize = 13
        dropdownButton.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
        dropdownButton.AutoButtonColor = false
        dropdownButton.BorderSizePixel = 0
        dropdownButton.ClipsDescendants = false
        dropdownButton.ZIndex = 11
        dropdownButton.Parent = frame

        local dropdownCorner = Instance.new("UICorner")
        dropdownCorner.CornerRadius = UDim.new(0, 6)
        dropdownCorner.Parent = dropdownButton

        -- Dropdown arrow
        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 20, 1, 0)
        arrow.Position = UDim2.new(1, -24, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = "▾"
        arrow.TextColor3 = Color3.fromRGB(150, 150, 170)
        arrow.TextSize = 16
        arrow.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
        arrow.ZIndex = 12
        arrow.Parent = dropdownButton

        -- Dropdown options frame
        local optionsFrame = Instance.new("Frame")
        optionsFrame.Name = "OptionsFrame"
        optionsFrame.Size = UDim2.new(0, 150, 0, 0)
        optionsFrame.Position = UDim2.new(0.765, 0, 1, 2)
        optionsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        optionsFrame.BorderSizePixel = 0
        optionsFrame.ClipsDescendants = true
        optionsFrame.Visible = true
        optionsFrame.ZIndex = 20
        optionsFrame.Parent = frame

        local optionsCorner = Instance.new("UICorner")
        optionsCorner.CornerRadius = UDim.new(0, 6)
        optionsCorner.Parent = optionsFrame

        local optionsStroke = Instance.new("UIStroke")
        optionsStroke.Color = Color3.fromRGB(45, 45, 55)
        optionsStroke.Thickness = 0.5
        optionsStroke.Parent = optionsFrame

        local optionsLayout = Instance.new("UIListLayout")
        optionsLayout.FillDirection = Enum.FillDirection.Vertical
        optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        optionsLayout.Padding = UDim.new(0, 2)
        optionsLayout.Parent = optionsFrame

        -- Pre-calculate the target height for the animation
        local function GetPlayerOptionsHeight()
            local maxItems = 5
            local itemHeight = 30
            local players = GetPlayerNames()
            local totalItems = math.min(#players, maxItems)
            if totalItems == 0 then
                return 30
            end
            return totalItems * itemHeight + (totalItems - 1) * 2 + 4
        end

        -- Initially set size to 0 (hidden)
        optionsFrame.Size = UDim2.new(0, 150, 0, 0)

        -- Function to update dropdown content (without changing size)
        local function UpdatePlayerDropdownContent()
            -- Clear existing options
            for _, child in pairs(optionsFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end

            local players = GetPlayerNames()
            local maxItems = 5
            local itemHeight = 30
            local totalItems = math.min(#players, maxItems)

            if totalItems == 0 then
                local noPlayers = Instance.new("TextLabel")
                noPlayers.Size = UDim2.new(1, 0, 1, 0)
                noPlayers.BackgroundTransparency = 1
                noPlayers.Text = "No players found"
                noPlayers.TextColor3 = Color3.fromRGB(150, 150, 170)
                noPlayers.TextSize = 12
                noPlayers.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
                noPlayers.ZIndex = 21
                noPlayers.Parent = optionsFrame
                return
            end

            for i = 1, totalItems do
                local playerName = players[i]
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1, 0, 0, itemHeight)
                item.BackgroundTransparency = 1
                item.Text = playerName
                item.TextColor3 = Color3.fromRGB(200, 200, 215)
                item.TextSize = 13
                item.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
                item.AutoButtonColor = false
                item.BorderSizePixel = 0
                item.ZIndex = 21
                item.Parent = optionsFrame

                item.MouseEnter:Connect(function()
                    item.BackgroundTransparency = 0.5
                    item.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                end)

                item.MouseLeave:Connect(function()
                    item.BackgroundTransparency = 1
                end)

                item.MouseButton1Click:Connect(function()
                    element.Value = playerName
                    dropdownButton.Text = playerName
                    CloseDropdown()
                    if element.OnChange then
                        element.OnChange(element.Value)
                    end
                end)
            end
        end

        -- Animated Open/Close functions
        local function OpenDropdown()
            if element.Open then return end
            element.Open = true
            arrow.Text = "▴"

            UpdatePlayerDropdownContent()
            local targetHeight = GetPlayerOptionsHeight()

            optionsFrame.Visible = true
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(optionsFrame, tweenInfo, {
                Size = UDim2.new(0, 150, 0, targetHeight)
            })
            tween:Play()
        end

        local function CloseDropdown()
            if not element.Open then return end
            element.Open = false
            arrow.Text = "▾"

            local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            local tween = TweenService:Create(optionsFrame, tweenInfo, {
                Size = UDim2.new(0, 150, 0, 0)
            })
            tween:Play()
            tween.Completed:Connect(function()
                optionsFrame.Visible = false
            end)
        end

        function element:OnChange(callback)
            element.OnChange = callback
            return element
        end

        dropdownButton.MouseButton1Click:Connect(function()
            if element.Open then
                CloseDropdown()
            else
                OpenDropdown()
            end
        end)

        -- Close dropdown when clicking outside
        UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if element.Open then
                    local mousePos = UserInputService:GetMouseLocation()
                    local absPos = optionsFrame.AbsolutePosition
                    local absSize = optionsFrame.AbsoluteSize

                    local buttonAbsPos = dropdownButton.AbsolutePosition
                    local buttonAbsSize = dropdownButton.AbsoluteSize

                    local isOutsideOptions = not (mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X and
                                                  mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y)

                    local isOutsideButton = not (mousePos.X >= buttonAbsPos.X and mousePos.X <= buttonAbsPos.X + buttonAbsSize.X and
                                                 mousePos.Y >= buttonAbsPos.Y and mousePos.Y <= buttonAbsPos.Y + buttonAbsSize.Y)

                    if isOutsideOptions and isOutsideButton then
                        CloseDropdown()
                    end
                end
            end
        end)

        -- Update player list when players join/leave
        Players.PlayerAdded:Connect(function()
            if element.Open then
                UpdatePlayerDropdownContent()
                local newHeight = GetPlayerOptionsHeight()
                optionsFrame.Size = UDim2.new(0, 150, 0, newHeight)
            end
        end)

        Players.PlayerRemoving:Connect(function()
            if element.Open then
                UpdatePlayerDropdownContent()
                local newHeight = GetPlayerOptionsHeight()
                optionsFrame.Size = UDim2.new(0, 150, 0, newHeight)
            end
        end)

        -- Initial setup
        task.wait()
        UpdatePlayerDropdownContent()

        task.wait()
        UpdateTabCanvas(tab)

        return element
    end

    function tab:Input(text, placeholder)
        local element = {}
        element.Type = "Input"
        element.Value = ""
        element.OnChange = nil

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 640, 0, 44)
        frame.BackgroundColor3 = Library.Config.Theme.Darker
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.ZIndex = 1
        frame.Parent = tab.ElementContainer

        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 8)
        frameCorner.Parent = frame

        local frameStroke = Instance.new("UIStroke")
        frameStroke.Color = Color3.fromRGB(45, 45, 55)
        frameStroke.Thickness = 0.5
        frameStroke.Parent = frame

        local label = Instance.new("TextLabel")
        label.Name = "Text"
        label.Size = UDim2.new(0, 82, 0, 44)
        label.Position = UDim2.new(0.02, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Library.Config.Theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
        label.ZIndex = 1
        label.Parent = frame

        local input = Instance.new("TextBox")
        input.Name = "Input"
        input.Size = UDim2.new(0, 150, 0, 28)
        input.Position = UDim2.new(0.765, 0, 0.182, 0)
        input.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        input.TextColor3 = Color3.fromRGB(200, 200, 215)
        input.Text = placeholder or ""
        input.TextSize = 13
        input.TextXAlignment = Enum.TextXAlignment.Center
        input.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
        input.BorderSizePixel = 0
        input.ClearTextOnFocus = false
        input.ZIndex = 1
        input.Parent = frame

        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 6)
        inputCorner.Parent = input

        function element:OnChange(callback)
            element.OnChange = callback
            return element
        end

        input.FocusLost:Connect(function(enterPressed)
            element.Value = input.Text
            if element.OnChange then
                element.OnChange(element.Value)
            end
        end)

        task.wait()
        UpdateTabCanvas(tab)

        return element
    end

    function tab:Button(text, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 640, 0, 44)
        frame.BackgroundColor3 = Library.Config.Theme.Darker
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.ZIndex = 1
        frame.Parent = tab.ElementContainer

        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 8)
        frameCorner.Parent = frame

        local frameStroke = Instance.new("UIStroke")
        frameStroke.Color = Color3.fromRGB(45, 45, 55)
        frameStroke.Thickness = 0.5
        frameStroke.Parent = frame

        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 1, 0)
        button.BackgroundTransparency = 1
        button.Text = text
        button.TextColor3 = Library.Config.Theme.Accent
        button.TextSize = 14
        button.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Medium)
        button.AutoButtonColor = false
        button.BorderSizePixel = 0
        button.ZIndex = 1
        button.Parent = frame

        local debounce = false

        button.MouseEnter:Connect(function()
            if not debounce then
                TweenService:Create(button, TweenInfo.new(0.15), {
                    TextColor3 = Color3.fromRGB(255, 255, 255)
                }):Play()
            end
        end)

        button.MouseLeave:Connect(function()
            if not debounce then
                TweenService:Create(button, TweenInfo.new(0.15), {
                    TextColor3 = Library.Config.Theme.Accent
                }):Play()
            end
        end)

        button.MouseButton1Click:Connect(function()
            if debounce then return end
            debounce = true

            TweenService:Create(button, TweenInfo.new(0.1), {
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 15
            }):Play()
            task.wait(0.1)
            TweenService:Create(button, TweenInfo.new(0.1), {
                TextColor3 = Library.Config.Theme.Accent,
                TextSize = 14
            }):Play()

            if callback then
                callback()
            end

            task.wait(0.2)
            debounce = false
        end)

        task.wait()
        UpdateTabCanvas(tab)

        return { Click = callback }
    end

    function tab:Label(text)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 640, 0, 40)
        frame.BackgroundColor3 = Library.Config.Theme.Darker
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.ZIndex = 1
        frame.Parent = tab.ElementContainer

        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 8)
        frameCorner.Parent = frame

        local frameStroke = Instance.new("UIStroke")
        frameStroke.Color = Color3.fromRGB(45, 45, 55)
        frameStroke.Thickness = 0.5
        frameStroke.Parent = frame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(150, 150, 170)
        label.TextSize = 13
        label.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
        label.ZIndex = 1
        label.Parent = frame

        task.wait()
        UpdateTabCanvas(tab)

        return label
    end

    -- Section for grouping elements
    function tab:Section(title)
        local section = {}
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 640, 0, 30)
        frame.BackgroundTransparency = 1
        frame.Parent = tab.ElementContainer

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = title
        label.TextColor3 = Color3.fromRGB(180, 180, 200)
        label.TextSize = 15
        label.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.SemiBold)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        -- Divider line
        local divider = Instance.new("Frame")
        divider.Size = UDim2.new(1, -100, 0, 1)
        divider.Position = UDim2.new(0.5, 50, 1, -4)
        divider.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        divider.BorderSizePixel = 0
        divider.Parent = frame
        
        function section:Add(element)
            return element
        end
        
        return section
    end

    return tab
end

-- Toggle UI visibility
local uiOpen = false
local debounce = false
local mainPosition = Main.Position

-- Toggle UI function
local function ToggleUI()
    if debounce then return end
    debounce = true

    uiOpen = not uiOpen

    if uiOpen then
        Main.Visible = true
        Main.Size = UDim2.new(0, 680, 0, 0)
        Main.Position = UDim2.new(0.5, -340, 0.5, 0)
        Main.BackgroundTransparency = 0.2

        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 680, 0, 480),
            Position = UDim2.new(0.5, -340, 0.5, -240),
            BackgroundTransparency = 0
        }):Play()

        TweenService:Create(GuiButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(35, 35, 48),
            Size = UDim2.new(0, 56, 0, 56)
        }):Play()

        task.wait(0.35)
        if currentTab then
            UpdateTabCanvas(currentTab)
        end
    else
        TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 680, 0, 0),
            BackgroundTransparency = 0.2
        }):Play()
        task.wait(0.2)
        Main.Visible = false
        mainPosition = Main.Position

        TweenService:Create(GuiButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(24, 24, 32),
            Size = UDim2.new(0, 54, 0, 54)
        }):Play()
    end

    task.wait(0.3)
    debounce = false
end

-- GuiButton click (toggle)
GuiButton.MouseButton1Click:Connect(ToggleUI)

-- Hover effects
GuiButton.MouseEnter:Connect(function()
    TweenService:Create(GuiButton, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(35, 35, 48),
        Size = UDim2.new(0, 56, 0, 56)
    }):Play()
end)

GuiButton.MouseLeave:Connect(function()
    if not uiOpen then
        TweenService:Create(GuiButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(24, 24, 32),
            Size = UDim2.new(0, 54, 0, 54)
        }):Play()
    end
end)

-- Print version when library loads
print("✨ re//hance UI Library v" .. Library.Version .. " loaded!")

-- Return library
return Library
