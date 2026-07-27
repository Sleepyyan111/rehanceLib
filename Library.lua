local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

Library.Version = "2.0.0"

Library.Config = {
    Theme = {
        Background = Color3.fromRGB(24, 24, 30),
        SideBar = Color3.fromRGB(20, 20, 25),
        Accent = Color3.fromRGB(148, 162, 255),
        Text = Color3.fromRGB(199, 199, 199),
        Darker = Color3.fromRGB(30, 30, 37),
        ToggleOff = Color3.fromRGB(41, 41, 51),
        ToggleOn = Color3.fromRGB(148, 162, 255),
        Border = Color3.fromRGB(37, 37, 46),
    },
    AnimationSpeed = 0.3,
}

local SLICE_IMAGE = "rbxassetid://3570695787"
local SLICE_RECT = Rect.new(100, 100, 100, 100)
local SLICE_SCALE = 0.1

local Utility = {}

function Utility.new(Class, Properties, Children)
    local NewInstance = Instance.new(Class)
    for i, v in pairs(Properties or {}) do
        if i ~= "Parent" then
            NewInstance[i] = v
        end
    end
    for _, v in ipairs(Children or {}) do
        if typeof(v) == "Instance" then
            v.Parent = NewInstance
        end
    end
    if Properties and Properties.Parent then
        NewInstance.Parent = Properties.Parent
    end
    return NewInstance
end

function Utility.Panel(Properties, Children)
    Properties = Properties or {}
    Properties.Image = SLICE_IMAGE
    Properties.ImageColor3 = Properties.ImageColor3 or Library.Config.Theme.Darker
    Properties.ScaleType = Enum.ScaleType.Slice
    Properties.SliceCenter = SLICE_RECT
    Properties.SliceScale = SLICE_SCALE
    Properties.BackgroundTransparency = 1
    return Utility.new("ImageLabel", Properties, Children)
end

function Utility.Tween(Object, Info, Goal)
    local Tween = TweenService:Create(Object, Info, Goal)
    return setmetatable({}, {
        __index = function(_, Index)
            if Index == "Yield" then
                return function()
                    Tween:Play()
                    Tween.Completed:Wait()
                end
            end
            local Value = Tween[Index]
            if typeof(Value) == "function" then
                return function(_, ...)
                    return Value(Tween, ...)
                end
            end
            return Value
        end,
    })
end

local function GetOrCreateScreenGui()
    local player = Players.LocalPlayer
    if not player then return nil end

    local gui = player:FindFirstChild("rehanceUI")
    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Name = "rehanceUI"
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 5
        gui.Parent = player:WaitForChild("PlayerGui")
    end
    return gui
end

local ScreenGui = GetOrCreateScreenGui()
if not ScreenGui then
    error("Failed to create ScreenGui")
end

Players.LocalPlayer.CharacterAdded:Connect(function()
    if ScreenGui and ScreenGui.Parent ~= Players.LocalPlayer:FindFirstChild("PlayerGui") then
        ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end)

local Main = Utility.Panel({
    Name = "Main",
    Parent = ScreenGui,
    Active = true,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 650, 0, 400),
    ImageColor3 = Library.Config.Theme.Background,
    ClipsDescendants = true,
    Visible = false,
}, {
})

local SideBar = Utility.Panel({
    Name = "SideBar",
    Parent = Main,
    Size = UDim2.new(0, 160, 1, 0),
    ImageColor3 = Library.Config.Theme.SideBar,
}, {})

local Info = Utility.new("Frame", {
    Name = "Info",
    Parent = SideBar,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 60),
}, {
    Utility.new("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 12),
        Size = UDim2.new(1, -28, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "re//hance",
        TextColor3 = Library.Config.Theme.Accent,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
    }),
    Utility.new("TextLabel", {
        Name = "Header",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 32),
        Size = UDim2.new(1, -28, 0, 15),
        Font = Enum.Font.Gotham,
        Text = "v" .. Library.Version,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextTransparency = 0.4,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }),
    Utility.new("Frame", {
        Name = "Divider",
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = Color3.fromRGB(200, 200, 200),
        BackgroundTransparency = 0.75,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 1),
    }),
})

local Username = Utility.new("TextLabel", {
    Name = "Username",
    Parent = SideBar,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 14, 0, 64),
    Size = UDim2.new(1, -28, 0, 18),
    Text = Players.LocalPlayer.DisplayName,
    TextColor3 = Color3.fromRGB(140, 140, 140),
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Center,
})

local TabList = Utility.new("Frame", {
    Name = "TabList",
    Parent = SideBar,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 90),
    Size = UDim2.new(1, 0, 1, -90),
}, {
    Utility.new("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    }),
    Utility.new("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    }),
})

local Contents = Utility.new("Frame", {
    Name = "Contents",
    Parent = Main,
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    Position = UDim2.new(0, 160, 0, 0),
    Size = UDim2.new(1, -160, 1, 0),
})

local UIPageLayout = Utility.new("UIPageLayout", {
    Parent = Contents,
    EasingStyle = Enum.EasingStyle.Quad,
    TweenTime = 0.25,
    SortOrder = Enum.SortOrder.LayoutOrder,
    GamepadInputEnabled = false,
    ScrollWheelInputEnabled = false,
    TouchInputEnabled = false,
})

-- Shared invisible click-catcher used to close any open dropdown when the
-- user clicks outside of it. This avoids doing manual pixel-math against
-- AbsolutePosition/AbsoluteSize (which raced against the open/close tweens
-- and caused dropdown selections to randomly fail).
local DropdownCatcher = Utility.new("TextButton", {
    Name = "DropdownCatcher",
    Parent = ScreenGui,
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 10,
    Visible = false,
})

local GuiButton = Utility.Panel({
    Name = "GuiButton",
    Parent = ScreenGui,
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(0.5, -25, 0.07, 0),
    ImageColor3 = Library.Config.Theme.Background,
}, {
    Utility.new("TextButton", {
        Name = "Hit",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "r//h",
        TextColor3 = Library.Config.Theme.Accent,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
    }),
})

local function CreateDrag(handle, target)
    local dragging = false
    local dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Utility.Tween(target, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            }):Play()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

CreateDrag(Info, Main)

local tabs = {}
local currentTab = nil

local function UpdateTabCanvas(tab)
    if not tab or not tab.ElementContainer or not tab.Layout then return end
    local contentSize = tab.Layout.AbsoluteContentSize
    if contentSize.Y > 0 then
        tab.ElementContainer.Size = UDim2.new(1, 0, 0, contentSize.Y + 10)
        tab.Frame.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y + 15)
    end
end

function Library:NewTab(name, icon)
    local tab = {}
    tab.Name = name
    tab.Elements = {}

    local TabButton = Utility.new("Frame", {
        Name = "Button",
        Parent = TabList,
        BackgroundColor3 = Library.Config.Theme.Accent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
    }, {
        Utility.new("UICorner", { CornerRadius = UDim.new(0, 4) }),
        Utility.new("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -24, 1, 0),
            Font = Enum.Font.Gotham,
            Text = icon and ("  " .. name) or name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextTransparency = 0.3,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        }),
    })

    local Hit = Utility.new("TextButton", {
        Parent = TabButton,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
    })

    tab.Frame = Utility.new("ScrollingFrame", {
        Name = name,
        Parent = Contents,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageTransparency = 0.61,
        Active = true,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    })

    local elementContainer = Utility.new("Frame", {
        Name = "ElementContainer",
        Parent = tab.Frame,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
    })

    local layout = Utility.new("UIListLayout", {
        Parent = elementContainer,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    Utility.new("UIPadding", {
        Parent = elementContainer,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
    })

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        UpdateTabCanvas(tab)
    end)

    tab.ElementContainer = elementContainer
    tab.Layout = layout

    local function Select()
        UIPageLayout:JumpTo(tab.Frame)
    end

    Hit.MouseButton1Click:Connect(Select)

    local Selected = false
    local function SetHighlight(on)
        Selected = on
        Utility.Tween(TabButton, TweenInfo.new(0.2), {
            BackgroundTransparency = on and 0.85 or 1,
        }):Play()
        Utility.Tween(TabButton.Title, TweenInfo.new(0.2), {
            TextTransparency = on and 0 or 0.3,
            TextColor3 = on and Library.Config.Theme.Accent or Color3.fromRGB(255, 255, 255),
        }):Play()
    end

    UIPageLayout:GetPropertyChangedSignal("CurrentPage"):Connect(function()
        local focused = UIPageLayout.CurrentPage == tab.Frame
        if focused ~= Selected then
            SetHighlight(focused)
        end
        if focused then
            currentTab = tab
            task.wait()
            UpdateTabCanvas(tab)
        end
    end)

    if not currentTab then
        currentTab = tab
        SetHighlight(true)
    end

    table.insert(tabs, tab)

    local function BaseRow(height)
        local frame = Utility.Panel({
            Size = UDim2.new(0, 480, 0, height or 42),
            ImageColor3 = Library.Config.Theme.Darker,
            ClipsDescendants = true,
            Parent = tab.ElementContainer,
        })
        return frame
    end

    function tab:Toggle(text, default)
        local element = {}
        element.Type = "Toggle"
        element.Value = default or false
        element.OnChange = nil

        local frame = BaseRow(42)

        local label = Utility.new("TextLabel", {
            Name = "Text",
            Parent = frame,
            Size = UDim2.new(0, 200, 0, 42),
            Position = UDim2.new(0.02, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Library.Config.Theme.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local toggle = Utility.new("ImageButton", {
            Name = "Toggle",
            Parent = frame,
            Size = UDim2.new(0, 22, 0, 22),
            Position = UDim2.new(0.945, -22, 0.238, 0),
            BackgroundColor3 = element.Value and Library.Config.Theme.ToggleOn or Library.Config.Theme.ToggleOff,
            Image = "rbxassetid://0",
            AutoButtonColor = false,
            BorderSizePixel = 0,
        }, {
            Utility.new("UICorner", { CornerRadius = UDim.new(0, 4) }),
        })

        local debounce = false

        function element:Set(value)
            element.Value = value
            TweenService:Create(toggle, TweenInfo.new(0.15), {
                BackgroundColor3 = element.Value and Library.Config.Theme.ToggleOn or Library.Config.Theme.ToggleOff,
            }):Play()
            if element.OnChange then element.OnChange(element.Value) end
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

    function tab:Slider(text, min, max, increment, default)
        local element = {}
        element.Type = "Slider"
        min = min or 0
        max = max or 100
        increment = increment or 1
        element.Min = min
        element.Max = max
        element.Increment = increment
        element.Value = math.clamp(default or min, min, max)
        element.OnChange = nil

        local frame = BaseRow(42)

        Utility.new("TextLabel", {
            Name = "Text",
            Parent = frame,
            Size = UDim2.new(0, 140, 0, 42),
            Position = UDim2.new(0.02, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Library.Config.Theme.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local valueLabel = Utility.new("TextLabel", {
            Name = "Value",
            Parent = frame,
            Size = UDim2.new(0, 28, 1, 0),
            Position = UDim2.new(0, 170, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(element.Value),
            TextColor3 = Color3.fromRGB(140, 140, 155),
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local track = Utility.new("Frame", {
            Name = "Track",
            Parent = frame,
            BackgroundColor3 = Color3.fromRGB(45, 45, 55),
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 204, 0.5, 0),
            Size = UDim2.new(1, -224, 0, 3),
        }, {
            Utility.new("UICorner", { CornerRadius = UDim.new(1, 0) }),
        })

        -- Invisible, taller hitbox that sits on top of the (visually thin)
        -- track. All input is read from this instead of the 3px track so
        -- the slider is actually easy to click/drag, while the track itself
        -- stays skinny for looks.
        local hitbox = Utility.new("TextButton", {
            Name = "HitBox",
            Parent = frame,
            Active = true,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 204, 0.5, 0),
            Size = UDim2.new(1, -224, 0, 22),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 5,
        })

        local fill = Utility.new("Frame", {
            Name = "Fill",
            Parent = track,
            BackgroundColor3 = Color3.fromRGB(135, 135, 158),
            BorderSizePixel = 0,
            Size = UDim2.new(0, 0, 1, 0),
            ZIndex = 2,
        }, {
            Utility.new("UICorner", { CornerRadius = UDim.new(1, 0) }),
        })

        local thumb = Utility.new("Frame", {
            Name = "Thumb",
            Parent = track,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(158, 158, 178),
            BorderSizePixel = 0,
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(0, 0, 0.5, 0),
            ZIndex = 3,
        }, {
            Utility.new("UICorner", { CornerRadius = UDim.new(1, 0) }),
        })

        local dragging = false

        -- Snaps a raw value to the nearest increment and clamps it to
        -- [min, max]. Uses integer rounding when the increment is >= 1 so
        -- whole-number sliders don't show floating point drift (e.g. 49.999999).
        local function SnapValue(rawValue)
            local stepped = min + math.floor((rawValue - min) / increment + 0.5) * increment
            stepped = math.clamp(stepped, min, max)
            if increment >= 1 then
                stepped = math.floor(stepped + 0.5)
            end
            return stepped
        end

        local function UpdateVisual()
            local alpha = (max - min) > 0 and (element.Value - min) / (max - min) or 0
            alpha = math.clamp(alpha, 0, 1)
            -- Always tween, even while dragging, but keep the drag tween very
            -- short so it still feels responsive instead of laggy - this is
            -- what smooths out the snap-to-increment jumps while you drag.
            local tweenTime = dragging and 0.06 or 0.12
            TweenService:Create(fill, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad), {
                Size = UDim2.new(alpha, 0, 1, 0),
            }):Play()
            TweenService:Create(thumb, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad), {
                Position = UDim2.new(alpha, 0, 0.5, 0),
            }):Play()
            valueLabel.Text = tostring(element.Value)
        end

        function element:Set(rawValue)
            element.Value = SnapValue(rawValue)
            UpdateVisual()
            if element.OnChange then element.OnChange(element.Value) end
        end

        function element:OnChange(callback)
            element.OnChange = callback
            return element
        end

        local function UpdateFromInput(input)
            local absPos = hitbox.AbsolutePosition.X
            local absSize = hitbox.AbsoluteSize.X
            if absSize <= 0 then return end
            local relative = (input.Position.X - absPos) / absSize
            relative = math.clamp(relative, 0, 1)
            element:Set(min + (max - min) * relative)
        end

        hitbox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                UpdateFromInput(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateFromInput(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                dragging = false
                UpdateVisual()
            end
        end)

        UpdateVisual()

        task.wait()
        UpdateTabCanvas(tab)
        return element
    end

    local function DropdownBase(text, initialValue)
        local frame = BaseRow(42)
        frame.ClipsDescendants = false

        Utility.new("TextLabel", {
            Name = "Text",
            Parent = frame,
            Size = UDim2.new(0, 200, 0, 42),
            Position = UDim2.new(0.02, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Library.Config.Theme.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local dropdownButton = Utility.new("TextButton", {
            Name = "DropdownButton",
            Parent = frame,
            Size = UDim2.new(0, 120, 0, 22),
            Position = UDim2.new(0.72, 0, 0.238, 0),
            BackgroundColor3 = Library.Config.Theme.Background,
            Text = initialValue,
            TextColor3 = Color3.fromRGB(159, 162, 195),
            TextSize = 12,
            Font = Enum.Font.Gotham,
            AutoButtonColor = false,
            BorderSizePixel = 0,
        }, {
            Utility.new("UICorner", { CornerRadius = UDim.new(0, 4) }),
        })

        local arrow = Utility.new("TextLabel", {
            Parent = dropdownButton,
            Size = UDim2.new(0, 20, 1, 0),
            Position = UDim2.new(1, -22, 0, 0),
            BackgroundTransparency = 1,
            Text = " ",
            TextColor3 = Color3.fromRGB(107, 107, 107),
            TextSize = 14,
            Font = Enum.Font.Gotham,
        })

        local optionsFrame = Utility.Panel({
            Name = "OptionsFrame",
            Parent = frame,
            Size = UDim2.new(0, 120, 0, 0),
            Position = UDim2.new(0.72, 0, 1, 2),
            ImageColor3 = Color3.fromRGB(30, 30, 37),
            ClipsDescendants = true,
            Visible = false,
            ZIndex = 20,
        }, {
            Utility.new("UICorner", { CornerRadius = UDim.new(0, 3) }),
            Utility.new("UIStroke", { Color = Library.Config.Theme.Border }),
        })

        local optionsScroller = Utility.new("ScrollingFrame", {
            Name = "OptionsScroller",
            Parent = optionsFrame,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageTransparency = 0.4,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ZIndex = 21,
        }, {
            Utility.new("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2),
            }),
            Utility.new("UIPadding", {
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2),
            }),
        })

        dropdownButton.ZIndex = 11
        arrow.ZIndex = 12
        optionsFrame.ZIndex = 20

        return frame, dropdownButton, arrow, optionsFrame, optionsScroller
    end

    -- Populates a dropdown's scrolling list with ALL items (no artificial
    -- cap) and sizes the canvas so the ScrollingFrame can scroll through
    -- the full list, showing a fixed number of rows at a time.
    local function PopulateOptions(scroller, list, onPick, emptyText)
        for _, child in pairs(scroller:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        local itemHeight = 28
        local totalItems = #list

        if totalItems == 0 then
            Utility.new("TextLabel", {
                Parent = scroller,
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                Text = emptyText or "No options",
                TextColor3 = Color3.fromRGB(107, 107, 107),
                TextSize = 12,
                Font = Enum.Font.Gotham,
                ZIndex = 22,
            })
            scroller.CanvasSize = UDim2.new(0, 0, 0, 0)
            return totalItems
        end

        for i = 1, totalItems do
            local optionText = list[i]
            local item = Utility.new("TextButton", {
                Parent = scroller,
                Size = UDim2.new(1, -4, 0, itemHeight),
                BackgroundColor3 = Color3.fromRGB(24, 24, 30),
                Text = optionText,
                TextColor3 = Color3.fromRGB(199, 199, 199),
                TextSize = 12,
                Font = Enum.Font.Gotham,
                AutoButtonColor = false,
                BorderSizePixel = 0,
                ZIndex = 22,
            }, {
                Utility.new("UICorner", { CornerRadius = UDim.new(0, 3) }),
            })

            item.MouseEnter:Connect(function() item.BackgroundColor3 = Color3.fromRGB(40, 40, 50) end)
            item.MouseLeave:Connect(function() item.BackgroundColor3 = Color3.fromRGB(24, 24, 30) end)
            item.MouseButton1Click:Connect(function() onPick(optionText) end)
        end

        scroller.CanvasSize = UDim2.new(0, 0, 0, totalItems * itemHeight + (totalItems - 1) * 2 + 4)
        return totalItems
    end

    function tab:Dropdown(text, options, default)
        local element = {}
        element.Type = "Dropdown"
        element.Value = default or options[1] or ""
        element.Options = options
        element.Open = false
        element.OnChange = nil

        local frame, dropdownButton, arrow, optionsFrame, optionsScroller = DropdownBase(text, element.Value)
        local catcherConn = nil

        local function GetHeight()
            local totalItems = math.min(#options, 5)
            if totalItems == 0 then return 28 end
            return totalItems * 28 + (totalItems - 1) * 2 + 4
        end

        local function CloseDropdown()
            if not element.Open then return end
            element.Open = false
            arrow.Text = " "
            DropdownCatcher.Visible = false
            if catcherConn then
                catcherConn:Disconnect()
                catcherConn = nil
            end
            local tween = TweenService:Create(optionsFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 120, 0, 0),
            })
            tween:Play()
            tween.Completed:Connect(function() optionsFrame.Visible = false end)
        end

        local function OpenDropdown()
            if element.Open then return end
            element.Open = true
            arrow.Text = " "
            PopulateOptions(optionsScroller, options, function(optionText)
                element.Value = optionText
                dropdownButton.Text = optionText
                CloseDropdown()
                if element.OnChange then element.OnChange(element.Value) end
            end)
            optionsFrame.Visible = true
            DropdownCatcher.Visible = true
            catcherConn = DropdownCatcher.MouseButton1Click:Connect(CloseDropdown)
            TweenService:Create(optionsFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 120, 0, GetHeight()),
            }):Play()
        end

        function element:OnChange(callback)
            element.OnChange = callback
            return element
        end

        dropdownButton.MouseButton1Click:Connect(function()
            if element.Open then CloseDropdown() else OpenDropdown() end
        end)

        task.wait()
        PopulateOptions(optionsScroller, options, function() end)
        task.wait()
        UpdateTabCanvas(tab)
        return element
    end

    function tab:PlayerDropdown(text, default)
        local element = {}
        element.Type = "PlayerDropdown"
        element.Value = default or ""
        element.Open = false
        element.OnChange = nil

        local function GetPlayerNames()
            local names = {}
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer then table.insert(names, player.Name) end
            end
            table.sort(names)
            return names
        end

        local frame, dropdownButton, arrow, optionsFrame, optionsScroller = DropdownBase(text, element.Value ~= "" and element.Value or "Select Player...")
        local catcherConn = nil

        local function GetHeight()
            local totalItems = math.min(#GetPlayerNames(), 5)
            if totalItems == 0 then return 28 end
            return totalItems * 28 + (totalItems - 1) * 2 + 4
        end

        local function CloseDropdown()
            if not element.Open then return end
            element.Open = false
            arrow.Text = " "
            DropdownCatcher.Visible = false
            if catcherConn then
                catcherConn:Disconnect()
                catcherConn = nil
            end
            local tween = TweenService:Create(optionsFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 120, 0, 0),
            })
            tween:Play()
            tween.Completed:Connect(function() optionsFrame.Visible = false end)
        end

        local function RefreshContent()
            PopulateOptions(optionsScroller, GetPlayerNames(), function(playerName)
                element.Value = playerName
                dropdownButton.Text = playerName
                CloseDropdown()
                if element.OnChange then element.OnChange(element.Value) end
            end, "No players found")
        end

        local function OpenDropdown()
            if element.Open then return end
            element.Open = true
            arrow.Text = " "
            RefreshContent()
            optionsFrame.Visible = true
            DropdownCatcher.Visible = true
            catcherConn = DropdownCatcher.MouseButton1Click:Connect(CloseDropdown)
            TweenService:Create(optionsFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 120, 0, GetHeight()),
            }):Play()
        end

        function element:OnChange(callback)
            element.OnChange = callback
            return element
        end

        dropdownButton.MouseButton1Click:Connect(function()
            if element.Open then CloseDropdown() else OpenDropdown() end
        end)

        Players.PlayerAdded:Connect(function()
            if element.Open then
                RefreshContent()
                optionsFrame.Size = UDim2.new(0, 120, 0, GetHeight())
            end
        end)
        Players.PlayerRemoving:Connect(function()
            if element.Open then
                RefreshContent()
                optionsFrame.Size = UDim2.new(0, 120, 0, GetHeight())
            end
        end)

        task.wait()
        RefreshContent()
        task.wait()
        UpdateTabCanvas(tab)
        return element
    end

    function tab:Input(text, placeholder)
        local element = {}
        element.Type = "Input"
        element.Value = ""
        element.OnChange = nil

        local frame = BaseRow(42)

        Utility.new("TextLabel", {
            Name = "Text",
            Parent = frame,
            Size = UDim2.new(0, 200, 0, 42),
            Position = UDim2.new(0.02, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Library.Config.Theme.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        local input = Utility.new("TextBox", {
            Name = "Input",
            Parent = frame,
            Size = UDim2.new(0, 120, 0, 22),
            Position = UDim2.new(0.72, 0, 0.238, 0),
            BackgroundColor3 = Library.Config.Theme.Background,
            TextColor3 = Color3.fromRGB(159, 162, 195),
            Text = placeholder or "",
            TextSize = 12,
            Font = Enum.Font.Gotham,
            BorderSizePixel = 0,
            ClearTextOnFocus = false,
        }, {
            Utility.new("UICorner", { CornerRadius = UDim.new(0, 4) }),
        })

        function element:OnChange(callback)
            element.OnChange = callback
            return element
        end

        input.FocusLost:Connect(function()
            element.Value = input.Text
            if element.OnChange then element.OnChange(element.Value) end
        end)

        task.wait()
        UpdateTabCanvas(tab)
        return element
    end

    function tab:Button(text, callback)
        local frame = BaseRow(42)

        local button = Utility.new("TextButton", {
            Parent = frame,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Library.Config.Theme.Accent,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            AutoButtonColor = false,
            BorderSizePixel = 0,
        })

        local debounce = false
        button.MouseButton1Click:Connect(function()
            if debounce then return end
            debounce = true
            TweenService:Create(button, TweenInfo.new(0.1), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
            task.wait(0.1)
            TweenService:Create(button, TweenInfo.new(0.1), { TextColor3 = Library.Config.Theme.Accent }):Play()
            if callback then callback() end
            task.wait(0.2)
            debounce = false
        end)

        task.wait()
        UpdateTabCanvas(tab)
        return { Click = callback }
    end

    function tab:Label(text)
        local frame = BaseRow(42)

        local label = Utility.new("TextLabel", {
            Parent = frame,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Library.Config.Theme.Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
        })

        task.wait()
        UpdateTabCanvas(tab)
        return label
    end

    return tab
end

local uiOpen = false
local debounce = false

local function ToggleUI()
    if debounce then return end
    debounce = true
    uiOpen = not uiOpen

    if uiOpen then
        Main.Visible = true
        Main.Size = UDim2.new(0, 650, 0, 0)

        TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 650, 0, 400),
        }):Play()

        TweenService:Create(GuiButton, TweenInfo.new(0.15), {
            ImageColor3 = Color3.fromRGB(20, 20, 26),
        }):Play()

        task.wait(0.35)
        if currentTab then UpdateTabCanvas(currentTab) end
    else
        TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 650, 0, 0),
        }):Play()
        task.wait(0.2)
        Main.Visible = false

        TweenService:Create(GuiButton, TweenInfo.new(0.15), {
            ImageColor3 = Library.Config.Theme.Background,
        }):Play()
    end

    task.wait(0.3)
    debounce = false
end

GuiButton.Hit.MouseButton1Click:Connect(ToggleUI)

GuiButton.Hit.MouseEnter:Connect(function()
    TweenService:Create(GuiButton, TweenInfo.new(0.15), { ImageColor3 = Color3.fromRGB(30, 30, 38) }):Play()
end)
GuiButton.Hit.MouseLeave:Connect(function()
    if not uiOpen then
        TweenService:Create(GuiButton, TweenInfo.new(0.15), { ImageColor3 = Library.Config.Theme.Background }):Play()
    end
end)

print("re//hance UI Library v" .. Library.Version .. " loaded!")

return Library
