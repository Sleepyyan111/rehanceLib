--[[
   re//hance UI Library
   A modern, clean UI library for Roblox executors
   Version: 1.0.0
]]

local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Version
Library.Version = "1.0.0"

-- Configuration
Library.Config = {
    Theme = {
        Background = Color3.fromRGB(24, 24, 30),
        Accent = Color3.fromRGB(148, 162, 255),
        Text = Color3.fromRGB(199, 199, 199),
        Darker = Color3.fromRGB(30, 30, 37),
        ToggleOff = Color3.fromRGB(41, 41, 51),
        ToggleOn = Color3.fromRGB(148, 162, 255),
        Border = Color3.fromRGB(45, 45, 45),
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
Main.Size = UDim2.new(0, 650, 0, 400)
Main.Position = UDim2.new(0.5, -325, 0.5, -200) -- Centered
Main.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Visible = false
Main.Parent = ScreenGui

-- Corner & Shadow
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 4)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Library.Config.Theme.Border
Stroke.Parent = Main

-- Drag Bar
local DragBar = Instance.new("Frame")
DragBar.Name = "DragBar"
DragBar.Size = UDim2.new(1, 0, 0, 31)
DragBar.BackgroundTransparency = 1
DragBar.Parent = Main

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0, 88, 0, 31)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "re//hance"
Title.TextColor3 = Library.Config.Theme.Accent
Title.TextSize = 14
Title.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
Title.Parent = Main

-- Version Label
local VersionLabel = Instance.new("TextLabel")
VersionLabel.Name = "VersionLabel"
VersionLabel.Size = UDim2.new(0, 60, 0, 31)
VersionLabel.Position = UDim2.new(0, 95, 0, 0)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "v" .. Library.Version
VersionLabel.TextColor3 = Color3.fromRGB(107, 107, 107)
VersionLabel.TextSize = 11
VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
VersionLabel.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
VersionLabel.Parent = Main

-- Username
local Username = Instance.new("TextLabel")
Username.Name = "Username"
Username.Size = UDim2.new(0, 150, 0, 31)
Username.Position = UDim2.new(1, -160, 0, 0)
Username.BackgroundTransparency = 1
Username.Text = Players.LocalPlayer.DisplayName
Username.TextColor3 = Color3.fromRGB(185, 185, 185)
Username.TextSize = 14
Username.TextXAlignment = Enum.TextXAlignment.Right
Username.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
Username.Parent = Main

-- Tab Container
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, 0, 1, -31)
TabContainer.Position = UDim2.new(0, 0, 0, 31)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Main

-- Tab Chooser
local TabChooser = Instance.new("Frame")
TabChooser.Name = "TabChooser"
TabChooser.Size = UDim2.new(0, 215, 0, 30)
TabChooser.Position = UDim2.new(0.5, -107.5, 1, -35)
TabChooser.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
TabChooser.BorderSizePixel = 0
TabChooser.ClipsDescendants = true
TabChooser.Parent = Main

local TabChooserCorner = Instance.new("UICorner")
TabChooserCorner.CornerRadius = UDim.new(0, 5)
TabChooserCorner.Parent = TabChooser

local TabChooserStroke = Instance.new("UIStroke")
TabChooserStroke.Color = Color3.fromRGB(47, 47, 58)
TabChooserStroke.Thickness = 0.5
TabChooserStroke.Parent = TabChooser

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 2)
TabListLayout.Parent = TabChooser

-- Toggle Button (Gui Button) - Top center
local GuiButton = Instance.new("TextButton")
GuiButton.Name = "GuiButton"
GuiButton.Size = UDim2.new(0, 50, 0, 50)
GuiButton.Position = UDim2.new(0.5, -25, 0.07, 0)
GuiButton.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
GuiButton.Text = "r//h"
GuiButton.TextColor3 = Library.Config.Theme.Accent
GuiButton.TextSize = 14
GuiButton.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
GuiButton.AutoButtonColor = false
GuiButton.BorderSizePixel = 0
GuiButton.Parent = ScreenGui

local GuiButtonCorner = Instance.new("UICorner")
GuiButtonCorner.CornerRadius = UDim.new(0, 4)
GuiButtonCorner.Parent = GuiButton

local GuiButtonStroke = Instance.new("UIStroke")
GuiButtonStroke.Color = Library.Config.Theme.Border
GuiButtonStroke.Parent = GuiButton

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
    
    -- Force layout to update
    local contentSize = tab.Layout.AbsoluteContentSize
    
    -- If content size is 0, try to calculate it manually
    if contentSize.Y == 0 then
        local totalHeight = 0
        local children = tab.ElementContainer:GetChildren()
        for _, child in ipairs(children) do
            if child:IsA("Frame") then
                totalHeight = totalHeight + child.Size.Y.Offset + 5 -- 5 is the padding
            end
        end
        if totalHeight > 0 then
            contentSize = Vector2.new(0, totalHeight)
        end
    end
    
    if contentSize.Y > 0 then
        tab.ElementContainer.Size = UDim2.new(1, 0, 0, contentSize.Y + 10)
        tab.Frame.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y + 15)
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
    tab.Frame.ScrollBarThickness = 2
    tab.Frame.ScrollBarImageTransparency = 0.61
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
    
    -- UIListLayout for elements
    local layout = Instance.new("UIListLayout")
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = elementContainer
    
    -- Update canvas size when elements are added
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        UpdateTabCanvas(tab)
    end)
    
    tab.ElementContainer = elementContainer
    tab.Layout = layout

    -- Create tab button
    local button = Instance.new("TextButton")
    button.Name = "TabButton"
    button.Size = UDim2.new(0, 67, 0, 30)
    button.BackgroundTransparency = 1
    button.Text = name
    button.TextSize = 14
    button.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
    button.AutoButtonColor = false
    button.BorderSizePixel = 0
    button.Parent = TabChooser

    if not currentTab then
        currentTab = tab
        tab.Frame.Visible = true
        button.TextColor3 = Library.Config.Theme.Accent
    else
        button.TextColor3 = Color3.fromRGB(107, 107, 107)
    end

    -- Tab switching
    button.MouseButton1Click:Connect(function()
        if currentTab == tab then return end
        
        -- Hide current tab
        if currentTab then
            currentTab.Frame.Visible = false
        end
        
        -- Show new tab
        tab.Frame.Visible = true
        
        -- Update button colors
        for _, btn in pairs(tabButtons) do
            btn.TextColor3 = Color3.fromRGB(107, 107, 107)
        end
        button.TextColor3 = Library.Config.Theme.Accent
        
        currentTab = tab
        
        -- Update canvas when switching to tab
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

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 630, 0, 42)
        frame.BackgroundColor3 = Library.Config.Theme.Darker
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.Parent = tab.ElementContainer

        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 4)
        frameCorner.Parent = frame

        local label = Instance.new("TextLabel")
        label.Name = "Text"
        label.Size = UDim2.new(0, 82, 0, 42)
        label.Position = UDim2.new(0.02, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Library.Config.Theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
        label.Parent = frame

        local toggle = Instance.new("ImageButton")
        toggle.Name = "Toggle"
        toggle.Size = UDim2.new(0, 22, 0, 22)
        toggle.Position = UDim2.new(0.945, 0, 0.238, 0)
        toggle.BackgroundColor3 = element.Value and Library.Config.Theme.ToggleOn or Library.Config.Theme.ToggleOff
        toggle.Image = "rbxassetid://0"
        toggle.ImageTransparency = 1
        toggle.AutoButtonColor = false
        toggle.BorderSizePixel = 0
        toggle.Parent = frame

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 4)
        toggleCorner.Parent = toggle

        local debounce = false

        function element:Set(value)
            element.Value = value
            TweenService:Create(toggle, TweenInfo.new(0.15), {
                BackgroundColor3 = element.Value and Library.Config.Theme.ToggleOn or Library.Config.Theme.ToggleOff
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

        -- Force update after adding element
        task.wait()
        UpdateTabCanvas(tab)

        return element
    end

    -- Player Input (Auto-completes player usernames)
    function tab:PlayerInput(text, placeholder)
        local element = {}
        element.Type = "PlayerInput"
        element.Value = ""
        element.Players = {}

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 630, 0, 42)
        frame.BackgroundColor3 = Library.Config.Theme.Darker
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.Parent = tab.ElementContainer

        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 4)
        frameCorner.Parent = frame

        local label = Instance.new("TextLabel")
        label.Name = "Text"
        label.Size = UDim2.new(0, 82, 0, 42)
        label.Position = UDim2.new(0.02, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Library.Config.Theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
        label.Parent = frame

        local input = Instance.new("TextBox")
        input.Name = "Input"
        input.Size = UDim2.new(0, 137, 0, 22)
        input.Position = UDim2.new(0.775, 0, 0.238, 0)
        input.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
        input.TextColor3 = Color3.fromRGB(159, 162, 195)
        input.Text = placeholder or ""
        input.TextSize = 12
        input.TextXAlignment = Enum.TextXAlignment.Center
        input.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Light)
        input.BorderSizePixel = 0
        input.ClearTextOnFocus = false
        input.Parent = frame

        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 4)
        inputCorner.Parent = input

        -- Dropdown frame for player suggestions
        local dropdown = Instance.new("Frame")
        dropdown.Name = "Dropdown"
        dropdown.Size = UDim2.new(0, 137, 0, 0)
        dropdown.Position = UDim2.new(0.775, 0, 1, 0)
        dropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 37)
        dropdown.BorderSizePixel = 0
        dropdown.ClipsDescendants = true
        dropdown.Visible = false
        dropdown.ZIndex = 2
        dropdown.Parent = frame

        local dropdownCorner = Instance.new("UICorner")
        dropdownCorner.CornerRadius = UDim.new(0, 4)
        dropdownCorner.Parent = dropdown

        local dropdownStroke = Instance.new("UIStroke")
        dropdownStroke.Color = Library.Config.Theme.Border
        dropdownStroke.Parent = dropdown

        local dropdownLayout = Instance.new("UIListLayout")
        dropdownLayout.FillDirection = Enum.FillDirection.Vertical
        dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
        dropdownLayout.Padding = UDim.new(0, 2)
        dropdownLayout.Parent = dropdown

        local function UpdateDropdown(searchText)
            -- Clear existing dropdown items
            for _, child in pairs(dropdown:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            -- Get all players
            local players = {}
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer then
                    table.insert(players, player.Name)
                end
            end
            table.sort(players)
            
            -- Filter players based on search text
            local searchLower = string.lower(searchText)
            local matchedPlayers = {}
            for _, playerName in ipairs(players) do
                if string.find(string.lower(playerName), searchLower, 1, true) then
                    table.insert(matchedPlayers, playerName)
                end
            end
            
            -- Update dropdown height
            local maxItems = 5
            local itemHeight = 30
            local totalItems = math.min(#matchedPlayers, maxItems)
            dropdown.Size = UDim2.new(0, 137, 0, totalItems * itemHeight + (totalItems - 1) * 2)
            
            -- Create dropdown items
            for i = 1, totalItems do
                local playerName = matchedPlayers[i]
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1, 0, 0, itemHeight)
                item.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
                item.Text = playerName
                item.TextColor3 = Color3.fromRGB(199, 199, 199)
                item.TextSize = 12
                item.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
                item.AutoButtonColor = false
                item.BorderSizePixel = 0
                item.ZIndex = 3
                item.Parent = dropdown
                
                local itemCorner = Instance.new("UICorner")
                itemCorner.CornerRadius = UDim.new(0, 3)
                itemCorner.Parent = item
                
                item.MouseEnter:Connect(function()
                    item.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                end)
                
                item.MouseLeave:Connect(function()
                    item.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
                end)
                
                item.MouseButton1Click:Connect(function()
                    input.Text = playerName
                    dropdown.Visible = false
                    element.Value = playerName
                    if element.OnChange then
                        element.OnChange(element.Value)
                    end
                end)
            end
            
            dropdown.Visible = #matchedPlayers > 0
        end

        function element:OnChange(callback)
            element.OnChange = callback
            return element
        end

        input.FocusLost:Connect(function(enterPressed)
            dropdown.Visible = false
            if enterPressed then
                element.Value = input.Text
                if element.OnChange then
                    element.OnChange(element.Value)
                end
            end
        end)

        input:GetPropertyChangedSignal("Text"):Connect(function()
            if input:IsFocused() then
                UpdateDropdown(input.Text)
            end
        end)

        input.Focused:Connect(function()
            UpdateDropdown(input.Text)
        end)

        -- Force update after adding element
        task.wait()
        UpdateTabCanvas(tab)

        return element
    end

    -- Regular Input (kept for compatibility)
    function tab:Input(text, placeholder)
        local element = {}
        element.Type = "Input"
        element.Value = ""

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 630, 0, 42)
        frame.BackgroundColor3 = Library.Config.Theme.Darker
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.Parent = tab.ElementContainer

        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 4)
        frameCorner.Parent = frame

        local label = Instance.new("TextLabel")
        label.Name = "Text"
        label.Size = UDim2.new(0, 82, 0, 42)
        label.Position = UDim2.new(0.02, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Library.Config.Theme.Text
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
        label.Parent = frame

        local input = Instance.new("TextBox")
        input.Name = "Input"
        input.Size = UDim2.new(0, 137, 0, 22)
        input.Position = UDim2.new(0.775, 0, 0.238, 0)
        input.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
        input.TextColor3 = Color3.fromRGB(159, 162, 195)
        input.Text = placeholder or ""
        input.TextSize = 12
        input.TextXAlignment = Enum.TextXAlignment.Center
        input.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Light)
        input.BorderSizePixel = 0
        input.ClearTextOnFocus = false
        input.Parent = frame

        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 4)
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

        -- Force update after adding element
        task.wait()
        UpdateTabCanvas(tab)

        return element
    end

    function tab:Button(text, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 630, 0, 42)
        frame.BackgroundColor3 = Library.Config.Theme.Darker
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.Parent = tab.ElementContainer

        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 4)
        frameCorner.Parent = frame

        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 1, 0)
        button.BackgroundTransparency = 1
        button.Text = text
        button.TextColor3 = Library.Config.Theme.Accent
        button.TextSize = 14
        button.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
        button.AutoButtonColor = false
        button.BorderSizePixel = 0
        button.Parent = frame

        local debounce = false

        button.MouseButton1Click:Connect(function()
            if debounce then return end
            debounce = true

            -- Button press animation
            TweenService:Create(button, TweenInfo.new(0.1), {
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            task.wait(0.1)
            TweenService:Create(button, TweenInfo.new(0.1), {
                TextColor3 = Library.Config.Theme.Accent
            }):Play()

            if callback then
                callback()
            end

            task.wait(0.2)
            debounce = false
        end)

        -- Force update after adding element
        task.wait()
        UpdateTabCanvas(tab)

        return { Click = callback }
    end

    function tab:Label(text)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 630, 0, 42)
        frame.BackgroundColor3 = Library.Config.Theme.Darker
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.Parent = tab.ElementContainer

        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 4)
        frameCorner.Parent = frame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Library.Config.Theme.Text
        label.TextSize = 14
        label.FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json")
        label.Parent = frame

        -- Force update after adding element
        task.wait()
        UpdateTabCanvas(tab)

        return label
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
        -- Opening animation (slide in from center)
        Main.Visible = true
        Main.Size = UDim2.new(0, 650, 0, 0)
        Main.Position = UDim2.new(0.5, -325, 0.5, 0)
        
        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 650, 0, 400),
            Position = UDim2.new(0.5, -325, 0.5, -200)
        }):Play()

        TweenService:Create(GuiButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(20, 20, 26)
        }):Play()
        
        -- Update canvas when opening
        task.wait(0.35)
        if currentTab then
            UpdateTabCanvas(currentTab)
        end
    else
        -- Closing animation (slide up)
        TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 650, 0, 0)
        }):Play()
        task.wait(0.2)
        Main.Visible = false
        mainPosition = Main.Position

        TweenService:Create(GuiButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(24, 24, 30)
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
        BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    }):Play()
end)

GuiButton.MouseLeave:Connect(function()
    if not uiOpen then
        TweenService:Create(GuiButton, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(24, 24, 30)
        }):Play()
    end
end)

-- Print version when library loads
print("re//hance UI Library v" .. Library.Version .. " loaded!")

-- Return library
return Library
