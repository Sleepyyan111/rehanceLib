local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

Library.Version = "2.0.0"

-- ===========================================================================
-- Theme — pulled from Re//Factor's palette (lavender accents, near-black
-- panels, Arial/Ubuntu FontFace, thin white strokes at 0.9 transparency).
-- ===========================================================================
Library.Config = {
	Theme = {
		Background  = Color3.fromRGB(25, 25, 31),   -- main panel fill
		SideBar     = Color3.fromRGB(0, 0, 0),       -- sidebar tint (used with high transparency)
		Accent      = Color3.fromRGB(175, 180, 255), -- titles / icons / notif text
		RowBg       = Color3.fromRGB(204, 209, 255), -- row + tab background tint
		IconColor   = Color3.fromRGB(193, 193, 255),
		Text        = Color3.fromRGB(157, 157, 167), -- muted row label text
		White       = Color3.fromRGB(255, 255, 255),
		Darker      = Color3.fromRGB(30, 30, 37),    -- dropdown option list bg
		OptionHover = Color3.fromRGB(138, 138, 148),
		OptionIdle  = Color3.fromRGB(97, 97, 104),
		Stroke      = Color3.fromRGB(255, 255, 255),
	},
	AnimationSpeed = 0.3,
}

-- ===========================================================================
-- Lucide icon support — resolves a Lucide icon name (e.g. "settings",
-- "user", "chevron-down") to a Roblox rbxassetid using a hosted name->id
-- map (sourced from frappedevs/lucideblox, the same data Fluent uses).
-- Falls back to treating the string as a raw asset id if it's not a
-- known Lucide name, so old "rbxassetid://..." calls still work.
--
-- NOTE: lucideblox's icons.json is a FLAT map — { "icon-name":
-- "rbxassetid://XXXX", ... } — one full dedicated image per icon. It is
-- NOT a "48px" spritesheet keyed by {assetId, rectSize, rectOffset} like
-- Rayfield's bundled icons.lua. ResolveIcon below matches the real shape.
-- ===========================================================================
local LucideIcons = {
    Map = {},
    Loaded = false,
}

-- This is Rayfield's OWN icon pack — a Lua module (not JSON) that returns
-- { ["48px"] = { name = {assetId, {width,height}, {x,y}}, ... }, ["256px"] = {...} }.
-- It's the same file Rayfield itself loads (see icons.lua in its repo), and
-- it's a much larger/more complete set than lucideblox's icons.json — this
-- one actually contains "zap", "settings", "users", etc.
local ICON_MAP_URL =
    "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua"

local function FetchIconMap()
    if LucideIcons.Loaded then
        return
    end

    local success, result = pcall(function()
        local body

        -- Try request()/http_request() first, but fall back to game:HttpGet
        -- on ANY failure (bad status code, empty body, thrown error) rather
        -- than giving up — some executors' request() implementations choke
        -- on raw.githubusercontent.com for reasons HttpGet doesn't hit.
        if request then
            local reqOk, response = pcall(request, {
                Url = ICON_MAP_URL,
                Method = "GET",
            })

            if reqOk and response and response.Body and #response.Body > 0
                and (not response.StatusCode or response.StatusCode == 200) then
                body = response.Body
            elseif reqOk and response then
                warn("[re//hance] request() returned status "
                    .. tostring(response.StatusCode) .. ", falling back to HttpGet")
            else
                warn("[re//hance] request() threw: " .. tostring(response) .. ", falling back to HttpGet")
            end
        end

        if not body then
            local getOk, getResult = pcall(game.HttpGet, game, ICON_MAP_URL)
            assert(getOk, "HttpGet failed: " .. tostring(getResult))
            body = getResult
        end

        assert(body and #body > 0, "Empty response from both request() and HttpGet")

        -- icons.lua is Lua SOURCE that does `return {...}` — compile and run
        -- it, don't JSON-decode it.
        local chunk, loadErr = loadstring(body)
        assert(chunk, "Failed to compile icons.lua: " .. tostring(loadErr))

        local runOk, decoded = pcall(chunk)
        assert(runOk, "icons.lua threw when executed: " .. tostring(decoded))
        assert(type(decoded) == "table", "icons.lua did not return a table")
        assert(type(decoded["48px"]) == "table", "icons.lua is missing its 48px section")

        return decoded
    end)

    if success then
        LucideIcons.Map = result

        local count = 0
        for _ in pairs(result["48px"]) do
            count += 1
        end

        print("[re//hance] Loaded " .. count .. " Lucide icons")
    else
        warn("[re//hance] Failed to load Lucide icons:", result)
    end

    LucideIcons.Loaded = true
end

FetchIconMap()

function Library:ResolveIcon(icon, default)
	if not icon then
		return default, nil, nil
	end

	if type(icon) ~= "string" then
		return default, nil, nil
	end

	-- Already a Roblox asset
	if icon:match("^rbxassetid://") then
		return icon, nil, nil
	end

	icon = string.lower(icon):match("^%s*(.-)%s*$")

	-- icons.lua structure: Map["48px"][icon] = { assetId, {w,h}, {x,y} } —
	-- a real spritesheet, so unlike a flat asset-per-icon map we DO need
	-- to slice out the right rect via ImageRectOffset/ImageRectSize.
	local map = LucideIcons.Map
	if not map then
		warn("[re//hance] Lucide icon map is not loaded")
		return default, nil, nil
	end

	local icons48 = map["48px"]
	if not icons48 then
		warn("[re//hance] Lucide icon map has no 48px section")
		return default, nil, nil
	end

	local data = icons48[icon]

	if not data then
		warn("[re//hance] Unknown Lucide icon:", icon)
		return default, nil, nil
	end

	local assetId = data[1]
	local rectSize = data[2]
	local rectOffset = data[3]

	if type(assetId) ~= "number"
		or type(rectSize) ~= "table"
		or type(rectOffset) ~= "table" then
		warn("[re//hance] Invalid Lucide icon data:", icon)
		return default, nil, nil
	end

	return "rbxassetid://" .. tostring(assetId),
		Vector2.new(rectOffset[1], rectOffset[2]),
		Vector2.new(rectSize[1], rectSize[2])
end

local FontArial  = Font.new("rbxasset://fonts/families/Arial.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
local FontUbuntu = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

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

-- Re//Factor doesn't use 9-slice panels — every panel is a plain Frame with
-- a UICorner and (usually) a thin white UIStroke at 0.9 transparency. This
-- replaces the old Utility.Panel slice-image helper.
function Utility.Card(Properties, Children)
	Properties = Properties or {}
	local cornerRadius = Properties.CornerRadius or 4
	local noStroke = Properties.NoStroke
	Properties.CornerRadius = nil
	Properties.NoStroke = nil
	Properties.BorderSizePixel = Properties.BorderSizePixel or 0
	Properties.BackgroundColor3 = Properties.BackgroundColor3 or Library.Config.Theme.Background

	local frame = Utility.new("Frame", Properties, Children)
	Utility.new("UICorner", { Parent = frame, CornerRadius = UDim.new(0, cornerRadius) })
	if not noStroke then
		Utility.new("UIStroke", { Parent = frame, Color = Library.Config.Theme.Stroke, Transparency = 0.9 })
	end
	return frame
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

	local playerGui = player:WaitForChild("PlayerGui")

	-- If the library was already executed before (e.g. re-running the
	-- script in the same session), an old "rehanceUI" ScreenGui may
	-- still be sitting in PlayerGui. Destroy it so we don't end up with
	-- duplicate UI, stale connections, or a reused instance whose state
	-- doesn't match this fresh run.
	local existing = playerGui:FindFirstChild("rehanceUI")
	if existing then
		existing:Destroy()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "rehanceUI"
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	gui.DisplayOrder = 5
	gui.Parent = playerGui

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

-- ===========================================================================
-- MainUI — 775x452, centered, near-black panel with 5px corners, matching
-- Re//Factor's MainUI frame exactly (just recentered via AnchorPoint so the
-- new round button can grow it symmetrically).
-- ===========================================================================
local Main = Utility.new("Frame", {
	Name = "MainUI",
	Parent = ScreenGui,
	Active = true,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 775, 0, 452),
	BackgroundColor3 = Library.Config.Theme.Background,
	BackgroundTransparency = 0.05,
	ClipsDescendants = true,
	Visible = false,
}, {
	Utility.new("UICorner", { CornerRadius = UDim.new(0, 5) }),
})

-- LeftFrame (sidebar)
local LeftFrame = Utility.new("Frame", {
	Name = "LeftFrame",
	Parent = Main,
	BackgroundColor3 = Library.Config.Theme.SideBar,
	BackgroundTransparency = 0.9,
	Size = UDim2.new(0, 178, 1, 0),
}, {
	Utility.new("UIStroke", { Color = Library.Config.Theme.White, Transparency = 0.95 }),
})

local Title = Utility.new("TextLabel", {
	Name = "Title",
	Parent = LeftFrame,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 32),
	FontFace = FontArial,
	Text = "re//hance",
	TextColor3 = Library.Config.Theme.Accent,
	TextSize = 15,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
}, {
	Utility.new("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10) }),
})

local VersionLabel = Utility.new("TextLabel", {
	Name = "Version",
	Parent = LeftFrame,
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0.06858, 0),
	Size = UDim2.new(1, 0, 0, 19),
	FontFace = FontArial,
	Text = "v" .. Library.Version,
	TextColor3 = Library.Config.Theme.White,
	TextTransparency = 0.7,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
}, {
	Utility.new("UIPadding", { PaddingLeft = UDim.new(0, 10) }),
})

Utility.new("Frame", {
	Name = "Seperator",
	Parent = LeftFrame,
	BorderSizePixel = 0,
	BackgroundColor3 = Library.Config.Theme.White,
	BackgroundTransparency = 0.9,
	Size = UDim2.new(1, 0, 0, 1),
	Position = UDim2.new(0, 0, 0.11062, 0),
})

local TabsFrame = Utility.new("Frame", {
	Name = "TabsFrame",
	Parent = LeftFrame,
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0.11283, 0),
	Size = UDim2.new(1, 0, 0.88717, 0),
}, {
	Utility.new("UIListLayout", {
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
	Utility.new("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5),
	}),
})

-- ContentFrame + page container
local ContentFrame = Utility.new("Frame", {
	Name = "ContentFrame",
	Parent = Main,
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 178, 0, 0),
	Size = UDim2.new(1, -178, 1, 0),
})

local UIPageLayout = Utility.new("UIPageLayout", {
	Parent = ContentFrame,
	EasingStyle = Enum.EasingStyle.Exponential,
	TweenTime = 0.6,
	SortOrder = Enum.SortOrder.LayoutOrder,
	FillDirection = Enum.FillDirection.Vertical,
	GamepadInputEnabled = false,
	ScrollWheelInputEnabled = false,
	TouchInputEnabled = false,
})

-- Shared click-catcher to close any open dropdown when clicking outside it.
local DropdownCatcher = Utility.new("TextButton", {
	Name = "DropdownCatcher",
	Parent = ScreenGui,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Text = "",
	AutoButtonColor = false,
	ZIndex = 10,
	Visible = false,
})

-- Notifications — same card look as Re//Factor's Notifications.Frame,
-- repositioned/sized to match Re//Factor's Notifications container.
-- No UIListLayout here on purpose: layout instances snap children into
-- place instantly, and we want existing notifications to smoothly tween
-- up (or down) whenever one is added or dismissed, so positions are
-- managed manually below.
local NotificationHolder = Utility.new("Frame", {
	Name = "Notifications",
	Parent = ScreenGui,
	BorderSizePixel = 0,
	BackgroundTransparency = 1,
	Size = UDim2.new(0, 311, 0, 383),
	Position = UDim2.new(0.83, 0,0.61, 0),
	ZIndex = 100,
})

local NOTIF_SLOT_HEIGHT = 50
local NOTIF_SPACING = 8
local NOTIF_BOTTOM_PADDING = 6
local NOTIF_RIGHT_PADDING = 6

local activeNotifications = {} -- ordered oldest (top) -> newest (bottom)

-- Recomputes where every active notification slot should sit (stacked
-- upward from the bottom-right corner) and moves them there. Slots that
-- were already positioned tween smoothly to their new spot; a brand new
-- slot is simply placed at its target immediately (its own fade/rise
-- animation, set up in Library:Notify, handles its entrance).
local function RepositionNotifications()
	local count = #activeNotifications
	for i, slotData in ipairs(activeNotifications) do
		local offsetFromBottom = NOTIF_BOTTOM_PADDING + (count - i) * (NOTIF_SLOT_HEIGHT + NOTIF_SPACING)
		local targetPos = UDim2.new(1, -NOTIF_RIGHT_PADDING, 1, -offsetFromBottom)
		if slotData.positioned then
			TweenService:Create(slotData.slot, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = targetPos,
			}):Play()
		else
			slotData.slot.Position = targetPos
			slotData.positioned = true
		end
	end
end

-- Round open/close button (new design) — circular, dark, lavender icon,
-- with a press/release scale-punch.
local GuiButton = Utility.new("Frame", {
	Name = "GuiButton",
	Parent = ScreenGui,
	BorderSizePixel = 0,
	BackgroundColor3 = Library.Config.Theme.Background,
	BackgroundTransparency = 0.2,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.new(0, 50, 0, 50),
	Position = UDim2.new(0.5, 0, 0.07, 25),
}, {
	Utility.new("UICorner", { CornerRadius = UDim.new(1, 0) }),
})

local GuiButtonHit = Utility.new("ImageButton", {
	Name = "ImageButton",
	Parent = GuiButton,
	BorderSizePixel = 0,
	BackgroundTransparency = 1,
	ImageColor3 = Library.Config.Theme.Accent,
	Image = "rbxassetid://12362702029",
	Size = UDim2.new(0, 40, 0, 40),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AutoButtonColor = false,
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

CreateDrag(Title, Main)

local tabs = {}
local currentTab = nil

local function UpdateTabCanvas(tab)
	if not tab or not tab.Frame or not tab.Layout then return end
	local contentSize = tab.Layout.AbsoluteContentSize
	if contentSize.Y > 0 then
		tab.Frame.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y + 15)
	end
end

function Library:NewTab(name, icon)
	local tab = {}
	tab.Name = name
	tab.Elements = {}

	-- Sidebar tab button, styled after Re//Factor's EnabledTab/NotEnabledTab
	local TabButton = Utility.new("ImageButton", {
		Name = "Button",
		Parent = TabsFrame,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		BackgroundColor3 = Library.Config.Theme.RowBg,
		BackgroundTransparency = 0.98,
		Size = UDim2.new(1, 0, 0, 40),
	}, {
		Utility.new("UICorner", { CornerRadius = UDim.new(0, 3) }),
		Utility.new("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
		}),
		Utility.new("UIPadding", { PaddingLeft = UDim.new(0, 10) }),
	})

local iconImage, iconOffset, iconSize =
    Library:ResolveIcon(icon, "rbxassetid://116950805172053")

local TabIcon = Utility.new("ImageLabel", {
    Name = "TabIcon",
    Parent = TabButton,
    BorderSizePixel = 0,
    BackgroundTransparency = 1,

    Image = iconImage,
    ImageColor3 = Library.Config.Theme.IconColor,
    ImageTransparency = 0.5,

    ImageRectOffset = iconOffset or Vector2.zero,
    ImageRectSize = iconSize or Vector2.zero,

    Size = UDim2.new(0, 18, 0, 18),
    LayoutOrder = -1,
})

	local TabTitle = Utility.new("TextLabel", {
		Name = "Title",
		Parent = TabButton,
		BackgroundTransparency = 1,
		FontFace = FontUbuntu,
		Text = name,
		TextColor3 = Library.Config.Theme.White,
		TextTransparency = 0.6,
		TextSize = 14,
		Size = UDim2.new(1, -38, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
	}, {
		Utility.new("UIPadding", { PaddingLeft = UDim.new(0, 10) }),
	})

	-- Page (ScrollingFrame), rows live directly inside it — matches
	-- Re//Factor's Tab ScrollingFrame with a Fill UIListLayout.
	tab.Frame = Utility.new("ScrollingFrame", {
		Name = name,
		Parent = ContentFrame,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageTransparency = 0.8,
		Active = true,
		CanvasSize = UDim2.new(0, 0, 0, 0),
	})

	tab.Layout = Utility.new("UIListLayout", {
		Parent = tab.Frame,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	Utility.new("UIPadding", {
		Parent = tab.Frame,
		PaddingTop = UDim.new(0, 7),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
	})

	tab.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		UpdateTabCanvas(tab)
	end)

	local function Select()
		UIPageLayout:JumpTo(tab.Frame)
	end

	TabButton.MouseButton1Click:Connect(Select)

	local Selected = false
	local function SetHighlight(on)
		Selected = on
		Utility.Tween(TabButton, TweenInfo.new(0.2), {
			BackgroundTransparency = on and 0.95 or 0.98,
		}):Play()
		Utility.Tween(TabTitle, TweenInfo.new(0.2), {
			TextTransparency = on and 0.3 or 0.6,
		}):Play()
		Utility.Tween(TabIcon, TweenInfo.new(0.2), {
			ImageTransparency = on and 0 or 0.5,
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

	-- Rows fill the tab's width automatically (parent UIListLayout is
	-- HorizontalFlex = Fill), so BaseRow only needs to set the height.
	local function BaseRow(height, noStroke)
		return Utility.Card({
			Size = UDim2.new(1, 0, 0, height or 35),
			BackgroundColor3 = Library.Config.Theme.RowBg,
			BackgroundTransparency = 0.97,
			ClipsDescendants = false,
			Parent = tab.Frame,
			NoStroke = noStroke ~= false and true or false,
		})
	end

	function tab:Toggle(text, default)
		local element = {}
		element.Type = "Toggle"
		element.Value = default or false
		element.OnChange = nil

		local frame = BaseRow(35, true)

		Utility.new("TextLabel", {
			Name = "ToggleText",
			Parent = frame,
			Size = UDim2.new(1, -40, 1, 0),
			BackgroundTransparency = 1,
			FontFace = FontArial,
			Text = text,
			TextColor3 = Library.Config.Theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, {
			Utility.new("UIPadding", { PaddingLeft = UDim.new(0, 15) }),
		})

		local EnabledColor = Color3.fromRGB(130,130,155)
		local DisabledColor = Color3.fromRGB(50, 50, 50)

		local toggleBtn = Utility.new("ImageButton", {
			Name = "ToggleButton",
			Parent = frame,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Transparency = 0.8,
			BackgroundColor3 = element.Value and EnabledColor or DisabledColor,
			Size = UDim2.new(0, 18, 0, 18),
			Position = UDim2.new(0.94028, 0, 0.229, 0),
		}, {
			Utility.new("UICorner", { CornerRadius = UDim.new(0, 4) }),
			Utility.new("UIStroke", { Color = Library.Config.Theme.White, Transparency = 0.9 }),
		})

		local debounce = false

		function element:Set(value)
			element.Value = value
			TweenService:Create(toggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = element.Value and EnabledColor or DisabledColor,
			}):Play()
			if element.OnChange then element.OnChange(element.Value) end
		end

		function element:OnChange(callback)
			element.OnChange = callback
			return element
		end

		toggleBtn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if debounce then return end
				debounce = true
				element:Set(not element.Value)
				task.wait(0.3)
				debounce = false
			end
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

		local frame = BaseRow(35, true)

		Utility.new("TextLabel", {
			Name = "SliderText",
			Parent = frame,
			Size = UDim2.new(0, 140, 1, 0),
			BackgroundTransparency = 1,
			FontFace = FontArial,
			Text = text,
			TextColor3 = Library.Config.Theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, {
			Utility.new("UIPadding", { PaddingLeft = UDim.new(0, 15) }),
		})

		local valueLabel = Utility.new("TextLabel", {
			Name = "Value",
			Parent = frame,
			Size = UDim2.new(0, 60, 1, 0),
			Position = UDim2.new(0, 145, 0, 0),
			BackgroundTransparency = 1,
			FontFace = FontArial,
			Text = tostring(element.Value),
			TextColor3 = Library.Config.Theme.Text,
			TextTransparency = 0.5,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Right,
		})

		local bar = Utility.new("Frame", {
			Name = "Bar",
			Parent = frame,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(96, 96, 96),
			BackgroundTransparency = 0.9,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 215, 0.5, 0),
			Size = UDim2.new(1, -230, 0, 5),
		}, {
			Utility.new("UICorner", { CornerRadius = UDim.new(1, 0) }),
		})

		local hitbox = Utility.new("TextButton", {
			Name = "HitBox",
			Parent = frame,
			Active = true,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 215, 0.5, 0),
			Size = UDim2.new(1, -230, 0, 22),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 5,
		})

		local filledBar = Utility.new("Frame", {
			Name = "FilledBar",
			Parent = bar,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(88, 88, 99),
			Size = UDim2.new(0, 0, 1, 0),
			ZIndex = 2,
		}, {
			Utility.new("UICorner", { CornerRadius = UDim.new(1, 0) }),
		})

		local dragger = Utility.new("Frame", {
			Name = "Dragger",
			Parent = filledBar,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(88, 88, 99),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(0, 10, 0, 10),
			Position = UDim2.new(1, 0, 0.5, 0),
			ZIndex = 3,
		}, {
			Utility.new("UICorner", { CornerRadius = UDim.new(1, 0) }),
		})

		local dragging = false

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
			local tweenTime = dragging and 0.1 or 0.2
			TweenService:Create(filledBar, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad), {
				Size = UDim2.new(alpha, 0, 1, 0),
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
		local frame = BaseRow(35, true)
		frame.ClipsDescendants = false

		Utility.new("TextLabel", {
			Name = "DropDownText",
			Parent = frame,
			Size = UDim2.new(0, 200, 1, 0),
			BackgroundTransparency = 1,
			FontFace = FontArial,
			Text = text,
			TextColor3 = Library.Config.Theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, {
			Utility.new("UIPadding", { PaddingLeft = UDim.new(0, 15) }),
		})

		local dropdownButton = Utility.new("TextButton", {
			Name = "DropDownButton",
			Parent = frame,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(50, 50, 50),
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 94, 0, 18),
			Position = UDim2.new(0.811, 0, 0.229, 0),
			Text = initialValue,
			TextColor3 = Color3.fromRGB(157, 157, 157),
			TextTransparency = 0.5,
			TextSize = 11,
			FontFace = FontArial,
		}, {
			Utility.new("UICorner", { CornerRadius = UDim.new(0, 4) }),
			Utility.new("UIStroke", {
				Color = Color3.fromRGB(255, 255, 255),
				Transparency = 0.9,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			}),
		})

		local optionsFrame = Utility.Card({
			Name = "OptionsFrame",
			Parent = frame,
			Size = UDim2.new(0, 94, 0, 0),
			Position = UDim2.new(0.811,0 , 1, 2),
			BackgroundColor3 = Library.Config.Theme.Darker,
			ClipsDescendants = true,
			BackgroundTransparency = 0.4,
			Visible = false,
			ZIndex = 20,
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

		optionsFrame.ZIndex = 20

		return frame, dropdownButton, optionsFrame, optionsScroller
	end

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
				FontFace = FontArial,
				ZIndex = 22,
			})
			scroller.CanvasSize = UDim2.new(0, 0, 0, 0)
			return totalItems
		end

		for i = 1, totalItems do
			local optionText = list[i]
			local item = Utility.new("TextButton", {
				Parent = scroller,
				Size = UDim2.new(1, 0, 0, itemHeight),
				BackgroundColor3 = Library.Config.Theme.OptionIdle,
				BackgroundTransparency = 1,
				Text = optionText,
				TextColor3 = Color3.fromRGB(97, 97, 104),
				TextSize = 12,
				FontFace = FontArial,
				AutoButtonColor = false,
				BorderSizePixel = 0,
				ZIndex = 22,
			}, {
				Utility.new("UICorner", { CornerRadius = UDim.new(0, 3) }),
			})

			item.MouseEnter:Connect(function() item.TextColor3 = Library.Config.Theme.OptionHover end)
			item.MouseLeave:Connect(function() item.TextColor3 = Library.Config.Theme.OptionIdle end)
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

		local frame, dropdownButton, optionsFrame, optionsScroller = DropdownBase(text, element.Value)
		local catcherConn = nil

		local function GetHeight()
			local totalItems = math.min(#options, 5)
			if totalItems == 0 then return 28 end
			return totalItems * 28 + (totalItems - 1) * 2 + 4
		end

		local function CloseDropdown()
			if not element.Open then return end
			element.Open = false
			DropdownCatcher.Visible = false
			if catcherConn then
				catcherConn:Disconnect()
				catcherConn = nil
			end
			local tween = TweenService:Create(optionsFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = UDim2.new(0, 96, 0, 0),
			})
			tween:Play()
			tween.Completed:Connect(function() optionsFrame.Visible = false end)
		end

		local function OpenDropdown()
			if element.Open then return end
			element.Open = true
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
				Size = UDim2.new(0, 96, 0, GetHeight()),
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

		local frame, dropdownButton, optionsFrame, optionsScroller = DropdownBase(text, element.Value ~= "" and element.Value or "Select Player...")
		local catcherConn = nil

		local function GetHeight()
			local totalItems = math.min(#GetPlayerNames(), 5)
			if totalItems == 0 then return 28 end
			return totalItems * 28 + (totalItems - 1) * 2 + 4
		end

		local function CloseDropdown()
			if not element.Open then return end
			element.Open = false
			DropdownCatcher.Visible = false
			if catcherConn then
				catcherConn:Disconnect()
				catcherConn = nil
			end
			local tween = TweenService:Create(optionsFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = UDim2.new(0, 96, 0, 0),
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
			RefreshContent()
			optionsFrame.Visible = true
			DropdownCatcher.Visible = true
			catcherConn = DropdownCatcher.MouseButton1Click:Connect(CloseDropdown)
			TweenService:Create(optionsFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 96, 0, GetHeight()),
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
				optionsFrame.Size = UDim2.new(0, 96, 0, GetHeight())
			end
		end)
		Players.PlayerRemoving:Connect(function()
			if element.Open then
				RefreshContent()
				optionsFrame.Size = UDim2.new(0, 96, 0, GetHeight())
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

		local frame = BaseRow(35, true)

		Utility.new("TextLabel", {
			Name = "Text",
			Parent = frame,
			Size = UDim2.new(0, 200, 1, 0),
			BackgroundTransparency = 1,
			FontFace = FontArial,
			Text = text,
			TextColor3 = Library.Config.Theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, {
			Utility.new("UIPadding", { PaddingLeft = UDim.new(0, 15) }),
		})

		local input = Utility.new("TextBox", {
			Name = "Input",
			Parent = frame,
			Size = UDim2.new(0, 120, 0, 22),
			Position = UDim2.new(0.72, 0, 0.229, 0),
			BackgroundColor3 = Color3.fromRGB(50, 50, 50),
			BackgroundTransparency = 0.9,
			TextColor3 = Color3.fromRGB(159, 162, 195),
			Text = placeholder or "",
			TextSize = 12,
			FontFace = FontArial,
			BorderSizePixel = 0,
			ClearTextOnFocus = false,
		}, {
			Utility.new("UICorner", { CornerRadius = UDim.new(0, 4) }),
			Utility.new("UIStroke", { Color = Library.Config.Theme.White, Transparency = 0.9 }),
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
		local frame = BaseRow(35, true)
		local InitializeColor = frame.BackgroundColor3

		Utility.new("TextLabel", {
			Name = "TextLabel",
			Parent = frame,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			FontFace = FontArial,
			Text = text,
			TextColor3 = Library.Config.Theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, {
			Utility.new("UIPadding", { PaddingLeft = UDim.new(0, 15) }),
		})

		local hit = Utility.new("TextButton", {
			Parent = frame,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
		})

		local debounce = false
		hit.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if debounce then return end
				debounce = true

				local clickTween = TweenService:Create(frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				})
				clickTween:Play()
				clickTween.Completed:Once(function()
					TweenService:Create(frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
						BackgroundColor3 = InitializeColor,
					}):Play()
				end)

				if callback then callback() end
				task.wait(0.2)
				debounce = false
			end
		end)

		task.wait()
		UpdateTabCanvas(tab)
		return { Click = callback }
	end

	function tab:Label(text)
		local frame = BaseRow(35, true)

		local label = Utility.new("TextLabel", {
			Parent = frame,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			FontFace = FontArial,
			Text = text,
			TextColor3 = Library.Config.Theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, {
			Utility.new("UIPadding", { PaddingLeft = UDim.new(0, 15) }),
		})

		task.wait()
		UpdateTabCanvas(tab)
		return label
	end

	return tab
end

local notifOrder = 0

function Library:Notify(text, duration)
	duration = duration or 4
	notifOrder += 1

	local slot = Utility.new("Frame", {
		Name = "NotificationSlot",
		Parent = NotificationHolder,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Size = UDim2.new(0, 206, 0, NOTIF_SLOT_HEIGHT),
		LayoutOrder = notifOrder,
		ClipsDescendants = false,
		ZIndex = 100,
	})

	local slotData = { slot = slot, positioned = false }
	table.insert(activeNotifications, slotData)
	RepositionNotifications()

	-- Card starts slightly below its resting spot and fully transparent so
	-- it tweens upward and fades in, instead of sliding in from the left.
	local card = Utility.new("Frame", {
		Name = "Card",
		Parent = slot,
		BackgroundColor3 = Library.Config.Theme.Background,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 24),
		ZIndex = 100,
	}, {
		Utility.new("UICorner", { CornerRadius = UDim.new(0, 7) }),
		Utility.new("UIStroke", {
			Name = "Stroke",
			Color = Library.Config.Theme.Background,
			Thickness = 2,
			Transparency = 1,
			BorderOffset = UDim.new(0, 2)
		}),
	})

	local label = Utility.new("TextLabel", {
		Name = "Text",
		Parent = card,
		BackgroundTransparency = 1,
		TextTransparency = 1,
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		FontFace = FontUbuntu,
		Text = text or "",
		TextColor3 = Library.Config.Theme.Accent,
		TextSize = 15,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 101,
	})

	local dismissButton = Utility.new("TextButton", {
		Name = "DismissHit",
		Parent = card,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 102,
	})

	local stroke = card:FindFirstChild("Stroke")
	local dismissed = false

	local function AnimateOut()
		if dismissed then return end
		dismissed = true

		local uiScale = card:FindFirstChildOfClass("UIScale")

		if not uiScale then
			uiScale = Instance.new("UIScale")
			uiScale.Scale = 1
			uiScale.Parent = card
		end

		-- Make scaling happen from the center
		card.AnchorPoint = Vector2.new(0.5, 0.5)

		-- Keep the card visually in the same place after changing AnchorPoint
		card.Position = UDim2.new(
			card.Position.X.Scale,
			card.Position.X.Offset + card.AbsoluteSize.X / 2,
			card.Position.Y.Scale,
			card.Position.Y.Offset + card.AbsoluteSize.Y / 2
		)

		local outInfo = TweenInfo.new(
			0.4,
			Enum.EasingStyle.Exponential,
			Enum.EasingDirection.Out
		)

		TweenService:Create(card, outInfo, {
			Position = UDim2.new(
				card.Position.X.Scale,
				card.Position.X.Offset,
				card.Position.Y.Scale,
				card.Position.Y.Offset + 10
			),
			BackgroundTransparency = 1,
		}):Play()

		TweenService:Create(uiScale, outInfo, {
			Scale = 0.85,
		}):Play()

		TweenService:Create(stroke, outInfo, {
			Transparency = 1
		}):Play()

		local labelTween = TweenService:Create(label, outInfo, {
			TextTransparency = 1
		})

		labelTween:Play()

		labelTween.Completed:Connect(function()
			for i, entry in ipairs(activeNotifications) do
				if entry.slot == slot then
					table.remove(activeNotifications, i)
					break
				end
			end

			slot:Destroy()
			RepositionNotifications()
		end)
	end

	dismissButton.MouseButton1Click:Connect(AnimateOut)

	-- Tween up into place and fade in.
	local inInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	TweenService:Create(card, inInfo, {
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 0.2,
	}):Play()
	TweenService:Create(label, inInfo, { TextTransparency = 0 }):Play()

	task.delay(duration, AnimateOut)

	return {
		Dismiss = AnimateOut,
	}
end

-- ===========================================================================
-- Open/close toggle — circular button with a press/release scale-punch
-- (matching the new snippet) plus the grow/shrink open animation for
-- MainUI (matching the old ToggleUI behaviour, now growing from center).
-- ===========================================================================
local uiScale = GuiButton:FindFirstChildOfClass("UIScale")
if not uiScale then
	uiScale = Instance.new("UIScale")
	uiScale.Parent = GuiButton
end
uiScale.Scale = 1

local pressTween = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local releaseTween = TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

GuiButtonHit.MouseButton1Down:Connect(function()
	TweenService:Create(uiScale, pressTween, { Scale = 0.95 }):Play()
end)
GuiButtonHit.MouseButton1Up:Connect(function()
	TweenService:Create(uiScale, releaseTween, { Scale = 1 }):Play()
end)
GuiButtonHit.MouseLeave:Connect(function()
	TweenService:Create(uiScale, releaseTween, { Scale = 1 }):Play()
end)

local uiOpen = false
local toggleDebounce = false

local function ToggleUI()
	if toggleDebounce then return end
	toggleDebounce = true
	uiOpen = not uiOpen

	if uiOpen then
		Main.Visible = true
		Main.Size = UDim2.new(0, 775, 0, 0)

		TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 775, 0, 452),
		}):Play()

		TweenService:Create(GuiButton, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(20, 20, 26),
		}):Play()

		task.wait(0.35)
		if currentTab then UpdateTabCanvas(currentTab) end
	else
		TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 775, 0, 0),
		}):Play()
		task.wait(0.2)
		Main.Visible = false

		TweenService:Create(GuiButton, TweenInfo.new(0.15), {
			BackgroundColor3 = Library.Config.Theme.Background,
		}):Play()
	end

	task.wait(0.3)
	toggleDebounce = false
end

GuiButtonHit.MouseButton1Click:Connect(ToggleUI)

print("re//hance UI Library v" .. Library.Version .. " (Re//Factor style) loaded!")
return Library
