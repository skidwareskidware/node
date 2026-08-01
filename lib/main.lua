local Oblivion = {}
Oblivion.Flags = {}
Oblivion.Version = "1.0.0"

local function getService(name)
	local ok, svc = pcall(function()
		return game:GetService(name)
	end)
	if ok and svc then
		if type(cloneref) == "function" then
			local ok2, c = pcall(cloneref, svc)
			if ok2 and c then
				return c
			end
		end
		return svc
	end
	return nil
end

local TweenService = getService("TweenService")
local UserInputService = getService("UserInputService")
local RunService = getService("RunService")
local Players = getService("Players")
local CoreGui = getService("CoreGui")
local Stats = getService("Stats")
local HttpService = getService("HttpService")

local function localPlayer()
	return Players and Players.LocalPlayer
end

local function getGuiParent()
	if type(gethui) == "function" then
		local ok, h = pcall(gethui)
		if ok and h then return h end
	end
	if type(get_hidden_gui) == "function" then
		local ok, h = pcall(get_hidden_gui)
		if ok and h then return h end
	end
	if CoreGui then
		return CoreGui
	end
	local lp = localPlayer()
	if lp then
		return lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui")
	end
	return nil
end

local function protectGui(gui)
	pcall(function()
		if syn and syn.protect_gui then
			syn.protect_gui(gui)
		elseif type(protectgui) == "function" then
			protectgui(gui)
		end
	end)
end

local ICON_URL = "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua"
local iconMap = nil

local function loadIconMap()
	if iconMap ~= nil then
		return iconMap
	end
	iconMap = false
	if type(loadstring) == "function" then
		pcall(function()
			local src = game:HttpGet(ICON_URL)
			local fn = loadstring(src)
			if type(fn) == "function" then
				local ok, map = pcall(fn)
				if ok and type(map) == "table" then
					iconMap = map
				end
			end
		end)
	end
	return iconMap
end

local function resolveIcon(icon)
	if not icon or icon == 0 or icon == "" then
		return nil
	end
	if type(icon) == "number" then
		return { Image = "rbxassetid://" .. icon }
	end
	if type(icon) == "string" then
		if string.match(icon, "^%d+$") then
			return { Image = "rbxassetid://" .. icon }
		end
		if string.find(icon, "rbxassetid://") == 1 or string.sub(icon, 1, 4) == "http" then
			return { Image = icon }
		end
		local map = loadIconMap()
		if type(map) == "table" then
			local sized = map["48px"] or map
			local entry = sized and sized[string.lower(icon)]
			if entry then
				return {
					Image = "rbxassetid://" .. entry[1],
					ImageRectSize = Vector2.new(entry[2][1], entry[2][2]),
					ImageRectOffset = Vector2.new(entry[3][1], entry[3][2]),
				}
			end
		end
	end
	return nil
end

local function applyIcon(image, spec)
	if not spec or not spec.Image then
		image.Image = ""
		return false
	end
	image.Image = spec.Image
	if spec.ImageRectSize then
		image.ImageRectSize = spec.ImageRectSize
	end
	if spec.ImageRectOffset then
		image.ImageRectOffset = spec.ImageRectOffset
	end
	image.Visible = true
	return true
end

local function customAssetFn()
	if type(getcustomasset) == "function" then return getcustomasset end
	if type(getsynasset) == "function" then return getsynasset end
	if syn and type(syn.getcustomasset) == "function" then
		return function(p) return syn.getcustomasset(p) end
	end
	return nil
end

local remoteImageCache = {}
local function remoteImage(url, filename)
	if remoteImageCache[filename] ~= nil then
		return remoteImageCache[filename] or nil
	end
	remoteImageCache[filename] = false
	local getAsset = customAssetFn()
	if not getAsset or type(writefile) ~= "function" then return nil end
	pcall(function()
		local have = type(isfile) == "function" and isfile(filename)
		if not have then
			writefile(filename, game:HttpGet(url))
		end
		remoteImageCache[filename] = getAsset(filename)
	end)
	return remoteImageCache[filename] or nil
end

local STAR_URL = "https://raw.githubusercontent.com/SyncUnofficial/Oblivion/main/assets/oblivion_star_v1.png"
local STAR_FILE = "oblivion_star_v1c.png"
local function applyStar(img)
	local s = remoteImage(STAR_URL, STAR_FILE)
	if s then
		img.Image = s
		img.Visible = true
	else
		applyIcon(img, resolveIcon("star"))
	end
end

local Theme = {
	Accent = Color3.fromRGB(0, 190, 196),
	AccentDim = Color3.fromRGB(0, 95, 98),
	WindowBg = Color3.fromRGB(8, 8, 8),
	ListBg = Color3.fromRGB(15, 15, 17),
	Outline = Color3.fromRGB(25, 25, 25),
	TextBright = Color3.fromRGB(212, 212, 215),
	TextMid = Color3.fromRGB(150, 150, 155),
	TextDim = Color3.fromRGB(86, 86, 90),
	TrackBg = Color3.fromRGB(36, 36, 40),
	ToggleOff = Color3.fromRGB(26, 26, 28),
	Knob = Color3.fromRGB(0, 0, 0),
	Star = Color3.fromRGB(250, 200, 0),
	WatermarkBg = Color3.fromRGB(10, 10, 12),
}

local WIN_W = 260
local HEADER_H = 44
local ROW_H = 36
local SET_H = 28
local PAD = 12
local TEXT = 13
local SUBTEXT = 13

local FONT = Enum.Font.Gotham
local FONT_MED = Enum.Font.GothamMedium

local function tween(obj, props, dur, style, dir)
	if not obj then return end
	local t = TweenService:Create(obj, TweenInfo.new(dur or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function make(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then
			inst[k] = v
		end
	end
	for _, c in ipairs(children or {}) do
		c.Parent = inst
	end
	if props and props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end

local function corner(parent, r)
	return make("UICorner", { CornerRadius = UDim.new(0, r or 6), Parent = parent })
end

local function stroke(parent, color, transparency)
	return make("UIStroke", {
		Color = color or Theme.Outline,
		Thickness = 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

local accentLinks = {}
local function linkAccent(inst, prop, mod)
	table.insert(accentLinks, { inst = inst, prop = prop, mod = mod })
	local c = Theme.Accent
	if mod then c = mod(c) end
	inst[prop] = c
end

local function retintAccent(color)
	Theme.Accent = color
	Theme.AccentDim = Color3.new(color.R * 0.5, color.G * 0.5, color.B * 0.5)
	for _, link in ipairs(accentLinks) do
		if link.inst and link.inst.Parent then
			local c = color
			if link.mod then c = link.mod(color) end
			link.inst[link.prop] = c
		end
	end
end

local function dimAccent(c)
	return Color3.new(c.R * 0.5, c.G * 0.5, c.B * 0.5)
end

local fadeProps = {
	Frame = { "BackgroundTransparency" },
	TextLabel = { "BackgroundTransparency", "TextTransparency", "TextStrokeTransparency" },
	TextBox = { "BackgroundTransparency", "TextTransparency" },
	TextButton = { "BackgroundTransparency", "TextTransparency" },
	ImageLabel = { "BackgroundTransparency", "ImageTransparency" },
	ImageButton = { "BackgroundTransparency", "ImageTransparency" },
	ScrollingFrame = { "BackgroundTransparency", "ScrollBarImageTransparency" },
	UIStroke = { "Transparency" },
}

local function collectFade(root)
	local list = {}
	local function grab(inst)
		local props = fadeProps[inst.ClassName]
		if props then
			for _, p in ipairs(props) do
				list[#list + 1] = { inst = inst, prop = p, value = inst[p] }
			end
		end
	end
	grab(root)
	for _, d in ipairs(root:GetDescendants()) do
		grab(d)
	end
	return list
end

local function fadeTree(cache, out, dur)
	for _, e in ipairs(cache) do
		if e.inst and e.inst.Parent then
			tween(e.inst, { [e.prop] = out and 1 or e.value }, dur or 0.18, Enum.EasingStyle.Quad)
		end
	end
end

local WIN_CORNER = 7
local UNDERLINE_H = 4

local function makeDraggable(handle, target, onGrab, canDrag, track)
	local dragging = false
	local startPos, startMouse
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if canDrag and not canDrag() then return end
			dragging = true
			startMouse = input.Position
			startPos = target.Position
			if onGrab then onGrab() end
		end
	end)
	handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	local moveConn = UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - startMouse
			target.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	if track then track(moveConn) end
end

local CONFIG_FOLDER = "Oblivion"
local function canFile()
	return type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
end

local function ensureFolder()
	if type(isfolder) == "function" and type(makefolder) == "function" then
		pcall(function()
			if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
			if not isfolder(CONFIG_FOLDER .. "/configs") then makefolder(CONFIG_FOLDER .. "/configs") end
		end)
	end
end

local flagBinds = {}

local function bindFlag(flag, setter, getter)
	if flag and flag ~= "" then
		flagBinds[flag] = { set = setter, get = getter }
	end
end

local function keyName(keyCode)
	if not keyCode then return "None" end
	local n = keyCode.Name
	local pretty = {
		LeftShift = "LShift", RightShift = "RShift",
		LeftControl = "LCtrl", RightControl = "RCtrl",
		LeftAlt = "LAlt", RightAlt = "RAlt",
	}
	return pretty[n] or n
end

function Oblivion.Window(opts)
	opts = opts or {}
	local self = {}
	local title = opts.title or "Oblivion"
	if opts.accent then
		Theme.Accent = opts.accent
		Theme.AccentDim = dimAccent(opts.accent)
	end

	local screen = make("ScreenGui", {
		Name = "Oblivion",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
	})
	protectGui(screen)
	screen.Parent = getGuiParent()
	self.Gui = screen

	local function viewport()
		local cam = workspace.CurrentCamera
		if cam and cam.ViewportSize.X > 100 then
			return cam.ViewportSize
		end
		return Vector2.new(1280, 720)
	end

	local conns = {}
	local function trackConn(c)
		conns[#conns + 1] = c
		return c
	end
	local keybindListenCancel = nil

	function self.Destroy()
		for _, c in ipairs(conns) do
			pcall(function() c:Disconnect() end)
		end
		conns = {}
		screen:Destroy()
	end

	local zTop = 10
	local function bringToFront(frame)
		zTop = zTop + 1
		frame.ZIndex = zTop
	end

	local categories = {}

	local COL_GAP = 14
	local ROW_GAP = 14
	local TOP_Y = 96
	local openStack = {}

	local function startX()
		return 40 + WIN_W + 30
	end

	local function columnCount()
		local vp = viewport()
		local avail = vp.X - startX() - 20
		return math.max(1, math.floor((avail + COL_GAP) / (WIN_W + COL_GAP)))
	end

	local function computeTargets()
		local cols = columnCount()
		local bottoms = {}
		for i = 1, cols do bottoms[i] = TOP_Y end
		for _, w in ipairs(openStack) do
			local best = 1
			for i = 2, cols do
				if bottoms[i] < bottoms[best] - 0.5 then best = i end
			end
			local x = startX() + (best - 1) * (WIN_W + COL_GAP)
			local y = bottoms[best]
			w.LayoutTarget = UDim2.new(0, x, 0, y)
			local h = w.Frame.AbsoluteSize.Y
			local th = w.TargetHeight and w.TargetHeight() or h
			h = math.max(h, th, HEADER_H)
			bottoms[best] = y + h + ROW_GAP
		end
	end

	local function relayout(exclude)
		computeTargets()
		for _, w in ipairs(openStack) do
			if w ~= exclude and not w.Flying and w.Frame.Visible and w.LayoutTarget then
				tween(w.Frame, { Position = w.LayoutTarget }, 0.34, Enum.EasingStyle.Quint)
			end
		end
	end

	local relayoutQueued = false
	local function requestRelayout()
		if relayoutQueued then return end
		relayoutQueued = true
		task.delay(0.04, function()
			relayoutQueued = false
			relayout(nil)
		end)
	end

	local function registerOpen(w)
		local present = false
		for _, rec in ipairs(openStack) do
			if rec == w then
				present = true
				break
			end
		end
		if not present then
			openStack[#openStack + 1] = w
		end
		w.OnLayoutChanged = requestRelayout
		computeTargets()
		relayout(w)
		return w.LayoutTarget
	end

	local function registerClose(w)
		w.OnLayoutChanged = nil
		for i, rec in ipairs(openStack) do
			if rec == w then
				table.remove(openStack, i)
				break
			end
		end
		relayout(nil)
	end

	local function baseWindow(name, iconSpec, width)

		local win = make("Frame", {
			Name = name,
			Size = UDim2.new(0, width or WIN_W, 0, HEADER_H),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = false,
			Parent = screen,
		})
		corner(win, WIN_CORNER)

		local accent = make("Frame", {
			Name = "Accent",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			ZIndex = 1,
			Parent = win,
		})
		linkAccent(accent, "BackgroundColor3")
		corner(accent, WIN_CORNER)

		local fill = make("Frame", {
			Name = "Fill",
			Size = UDim2.new(1, 0, 1, -UNDERLINE_H),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = Theme.WindowBg,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			ZIndex = 1,
			Parent = win,
		})
		corner(fill, WIN_CORNER)

		local header = make("Frame", {
			Name = "Header",
			Size = UDim2.new(1, 0, 0, HEADER_H),
			BackgroundTransparency = 1,
			ZIndex = 3,
			Parent = win,
		})

		local icon = make("ImageLabel", {
			Name = "Icon",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, PAD, 0.5, 0),
			Size = UDim2.new(0, 17, 0, 17),
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Fit,
			Visible = false,
			ZIndex = 3,
			Parent = header,
		})
		if iconSpec then
			applyIcon(icon, iconSpec)
			linkAccent(icon, "ImageColor3")
		end

		local titleLbl = make("TextLabel", {
			Name = "Title",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, iconSpec and (PAD + 28) or PAD, 0.5, 0),
			Size = UDim2.new(1, -70, 1, 0),
			BackgroundTransparency = 1,
			Font = FONT_MED,
			Text = name,
			TextSize = 14,
			TextColor3 = Theme.TextBright,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 3,
			Parent = header,
		})

		local chevSpec = resolveIcon("chevron-up")
		local chev = make("ImageLabel", {
			Name = "Collapse",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -PAD + 2, 0.5, 0),
			Size = UDim2.new(0, 14, 0, 14),
			BackgroundTransparency = 1,
			ImageColor3 = Theme.TextDim,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 3,
			Parent = header,
		})
		applyIcon(chev, chevSpec)

		local body = make("ScrollingFrame", {
			Name = "Body",
			Position = UDim2.new(0, 0, 0, HEADER_H),
			Size = UDim2.new(1, 0, 1, -HEADER_H - 3),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 0,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ClipsDescendants = true,
			ZIndex = 2,
			Parent = win,
		})
		local layout = make("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = body,
		})
		make("UIPadding", {
			PaddingBottom = UDim.new(0, 6),
			Parent = body,
		})

		local w = {
			Frame = win,
			Header = header,
			Body = body,
			Layout = layout,
			Title = titleLbl,
			Chevron = chev,
			Collapsed = false,
			Flying = false,
			MaxHeight = nil,
			OnLayoutChanged = nil,
			LayoutTarget = nil,
			Fill = fill,
			Accent = accent,
		}

		function w.FadeBody(to, dur)
			if dur and dur > 0 then
				tween(fill, { BackgroundTransparency = to }, dur, Enum.EasingStyle.Quint)
				tween(accent, { BackgroundTransparency = to }, dur, Enum.EasingStyle.Quint)
			else
				fill.BackgroundTransparency = to
				accent.BackgroundTransparency = to
			end
		end

		local function contentHeight()
			return layout.AbsoluteContentSize.Y + 6
		end

		local function targetHeight()
			if w.Collapsed then return HEADER_H end
			local maxH = w.MaxHeight or (viewport().Y - 120)
			return math.min(HEADER_H + 3 + contentHeight(), maxH)
		end
		w.TargetHeight = targetHeight

		local sizing = false
		function w.Resize(animate)
			if sizing then return end
			local h = targetHeight()
			if animate == false then
				win.Size = UDim2.new(0, win.Size.X.Offset, 0, h)
			else
				sizing = true
				local t = tween(win, { Size = UDim2.new(0, win.Size.X.Offset, 0, h) }, 0.25, Enum.EasingStyle.Quart)
				t.Completed:Connect(function()
					sizing = false
					local h2 = targetHeight()
					if math.abs(win.Size.Y.Offset - h2) > 1 then
						w.Resize()
					end
				end)
			end
		end

		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			w.Resize()
			if w.OnLayoutChanged then w.OnLayoutChanged() end
		end)

		local function setCollapsed(c, animate)
			w.Collapsed = c
			tween(chev, { Rotation = c and 180 or 0 }, 0.22)
			if animate == false then
				win.Size = UDim2.new(0, win.Size.X.Offset, 0, targetHeight())
			else
				w.Resize()
			end
		end
		w.SetCollapsed = setCollapsed

		chev.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and not w.Flying then
				setCollapsed(not w.Collapsed)
			end
		end)
		chev.MouseEnter:Connect(function()
			tween(chev, { ImageColor3 = Theme.TextMid }, 0.12)
		end)
		chev.MouseLeave:Connect(function()
			tween(chev, { ImageColor3 = Theme.TextDim }, 0.12)
		end)

		makeDraggable(header, win, function()
			bringToFront(win)
		end, function()
			return not w.Flying
		end, trackConn)
		win.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				bringToFront(win)
			end
		end)

		return w
	end

	local backdrop = make("Frame", {
		Name = "Backdrop",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.72,
		BorderSizePixel = 0,
		Active = false,
		ZIndex = 1,
		Parent = screen,
	})

	local watermark = make("Frame", {
		Name = "Watermark",
		Position = UDim2.new(0, 16, 0, 16),
		Size = UDim2.new(0, 10, 0, 34),
		BackgroundColor3 = Theme.WatermarkBg,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.X,
		ZIndex = 5,
		Visible = opts.watermark ~= false,
		Parent = screen,
	})
	corner(watermark, 6)
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = watermark,
	})
	make("UIPadding", {
		PaddingLeft = UDim.new(0, 16),
		PaddingRight = UDim.new(0, 16),
		Parent = watermark,
	})

	local wmSegments = {}
	local function setWatermark(segments)
		for _, s in ipairs(wmSegments) do
			s.label:Destroy()
			if s.divider then s.divider:Destroy() end
		end
		wmSegments = {}
		for i, text in ipairs(segments) do
			local divider
			if i > 1 then
				divider = make("Frame", {
					Size = UDim2.new(0, 1, 0, 14),
					BackgroundColor3 = Color3.fromRGB(52, 52, 58),
					BorderSizePixel = 0,
					LayoutOrder = i * 2 - 1,
					Parent = watermark,
				})
			end
			local lbl = make("TextLabel", {
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Font = FONT_MED,
				Text = text,
				TextSize = 13,
				TextColor3 = Theme.TextBright,
				LayoutOrder = i * 2,
				Parent = watermark,
			})
			make("UIPadding", {
				PaddingLeft = UDim.new(0, i > 1 and 14 or 0),
				PaddingRight = UDim.new(0, i < #segments and 14 or 0),
				Parent = lbl,
			})
			wmSegments[#wmSegments + 1] = { label = lbl, divider = divider }
		end
	end

	local wmAuto = opts.watermarkStats ~= false
	local wmBase = opts.watermarkText or title
	local wmServer = opts.watermarkServer or ""
	setWatermark({ wmBase })

	if wmAuto then
		local frames, acc, fps = 0, 0, 0
		trackConn(RunService.RenderStepped:Connect(function(dt)
			if not screen.Parent then return end
			frames = frames + 1
			acc = acc + dt
			if acc >= 0.5 then
				fps = math.floor(frames / acc + 0.5)
				frames, acc = 0, 0
				if wmAuto and watermark.Visible then
					local ping = ""
					pcall(function()
						ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5) .. "PING"
					end)
					local segs = { wmBase, fps .. "FPS" }
					if ping ~= "" then segs[#segs + 1] = ping end
					if wmServer ~= "" then segs[#segs + 1] = wmServer end
					setWatermark(segs)
				end
			end
		end))
	end

	self.SetWatermark = function(segments)
		if type(segments) == "table" then
			wmAuto = false
			setWatermark(segments)
		end
	end
	self.SetWatermarkVisible = function(v)
		watermark.Visible = v and true or false
	end

	local searchOpen = false
	local searchFrame = make("Frame", {
		Name = "Search",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 16),
		Size = UDim2.new(0, 34, 0, 34),
		BackgroundColor3 = Theme.WindowBg,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 5,
		Parent = screen,
	})
	corner(searchFrame, 18)

	local searchIcon = make("ImageLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 14),
		BackgroundTransparency = 1,
		ImageColor3 = Theme.TextBright,
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 5,
		Parent = searchFrame,
	})
	applyIcon(searchIcon, resolveIcon("search"))

	local searchBox = make("TextBox", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 34, 0.5, 0),
		Size = UDim2.new(1, -44, 1, 0),
		BackgroundTransparency = 1,
		Font = FONT,
		Text = "",
		PlaceholderText = "",
		PlaceholderColor3 = Theme.TextDim,
		TextSize = SUBTEXT,
		TextColor3 = Theme.TextBright,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Visible = false,
		ZIndex = 5,
		Parent = searchFrame,
	})

	local applySearch

	local function openSearch()
		if searchOpen then return end
		searchOpen = true
		tween(searchFrame, { Size = UDim2.new(0, 260, 0, 36) }, 0.28, Enum.EasingStyle.Quint)
		searchBox.Visible = true
		task.delay(0.1, function()
			searchBox:CaptureFocus()
		end)
	end

	local function closeSearch()
		if not searchOpen then return end
		searchOpen = false
		searchBox.Text = ""
		searchBox:ReleaseFocus()
		searchBox.Visible = false
		if applySearch then applySearch("") end
		tween(searchFrame, { Size = UDim2.new(0, 34, 0, 34) }, 0.25, Enum.EasingStyle.Quint)
	end

	searchFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and not searchOpen then
			openSearch()
		end
	end)
	searchBox.FocusLost:Connect(function(enterPressed)
		if searchBox.Text == "" then
			closeSearch()
		end
	end)
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		if applySearch then applySearch(searchBox.Text) end
	end)
	trackConn(UserInputService.InputBegan:Connect(function(input)
		if searchOpen and input.KeyCode == Enum.KeyCode.Escape then
			closeSearch()
		end
	end))

	local side = baseWindow(title, resolveIcon(opts.icon or "waves"), WIN_W)
	side.Frame.Position = UDim2.new(0, 40, 0, 120)
	side.Frame.Name = "Main"
	bringToFront(side.Frame)

	local sideOrder = 0
	local function nextSideOrder()
		sideOrder = sideOrder + 1
		return sideOrder
	end

	local function settingRow(parent, height)
		local row = make("Frame", {
			Size = UDim2.new(1, 0, 0, height or SET_H),
			BackgroundTransparency = 1,
			Parent = parent,
		})
		return row
	end

	local function rowLabel(row, text, offsetY)
		return make("TextLabel", {
			Position = UDim2.new(0, PAD, 0, offsetY or 0),
			Size = UDim2.new(1, -PAD * 2, 0, offsetY and 14 or row.Size.Y.Offset),
			BackgroundTransparency = 1,
			Font = FONT,
			Text = text,
			TextSize = SUBTEXT,
			TextColor3 = Theme.TextDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
	end

	local function hoverText(target, lbl, activeCheck)
		target.MouseEnter:Connect(function()
			if not activeCheck() then
				tween(lbl, { TextColor3 = Theme.TextMid }, 0.12)
			end
		end)
		target.MouseLeave:Connect(function()
			if not activeCheck() then
				tween(lbl, { TextColor3 = Theme.TextDim }, 0.12)
			end
		end)
	end

	local function buildToggle(parent, opts2)
		opts2 = opts2 or {}
		local state = opts2.default and true or false
		local row = settingRow(parent)
		row.LayoutOrder = opts2.order or 0
		local lbl = rowLabel(row, opts2.text or "Toggle")

		local pill = make("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -PAD, 0.5, 0),
			Size = UDim2.new(0, 24, 0, 12),
			BackgroundColor3 = Theme.ToggleOff,
			BorderSizePixel = 0,
			Parent = row,
		})
		corner(pill, 6)
		local knob = make("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 2, 0.5, 0),
			Size = UDim2.new(0, 9, 0, 9),
			BackgroundColor3 = Theme.Knob,
			BorderSizePixel = 0,
			Parent = pill,
		})
		corner(knob, 5)

		local function paint(animate)
			local dur = animate == false and 0 or 0.16
			if state then
				tween(pill, { BackgroundColor3 = Theme.Accent }, dur, Enum.EasingStyle.Quad)
				tween(knob, { Position = UDim2.new(0, 13, 0.5, 0) }, dur, Enum.EasingStyle.Quad)
				tween(lbl, { TextColor3 = Theme.TextBright }, dur)
			else
				tween(pill, { BackgroundColor3 = Theme.ToggleOff }, dur, Enum.EasingStyle.Quad)
				tween(knob, { Position = UDim2.new(0, 2, 0.5, 0) }, dur, Enum.EasingStyle.Quad)
				tween(lbl, { TextColor3 = Theme.TextDim }, dur)
			end
		end
		paint(false)

		local function set(v, silent)
			v = v and true or false
			if v == state then return end
			state = v
			paint()
			if opts2.flag then Oblivion.Flags[opts2.flag] = state end
			if not silent and opts2.callback then
				task.spawn(opts2.callback, state)
			end
		end

		row.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				set(not state)
			end
		end)
		hoverText(row, lbl, function() return state end)

		if opts2.flag then Oblivion.Flags[opts2.flag] = state end
		bindFlag(opts2.flag, function(v) set(v, false) end, function() return state end)

		return {
			Row = row,
			Set = set,
			Get = function() return state end,
		}
	end

	local function buildSlider(parent, opts2)
		opts2 = opts2 or {}
		local min = opts2.min or 0
		local max = opts2.max or 100
		local step = opts2.step or 1
		local value = math.clamp(opts2.default or min, min, max)

		local row = settingRow(parent, 32)
		row.LayoutOrder = opts2.order or 0
		local lbl = rowLabel(row, opts2.text or "Slider", 3)
		lbl.TextColor3 = Theme.TextBright

		local valueLbl = make("TextLabel", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -PAD, 0, 3),
			Size = UDim2.new(0, 90, 0, 14),
			BackgroundTransparency = 1,
			Font = FONT,
			Text = "",
			TextSize = SUBTEXT,
			TextColor3 = Theme.TextBright,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = row,
		})

		local track = make("Frame", {
			Position = UDim2.new(0, PAD, 0, 25),
			Size = UDim2.new(1, -PAD * 2, 0, 3),
			BackgroundColor3 = Theme.TrackBg,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			Parent = row,
		})
		corner(track, 2)
		local fill = make("Frame", {
			Size = UDim2.new(0, 0, 1, 0),
			BorderSizePixel = 0,
			Parent = track,
		})
		linkAccent(fill, "BackgroundColor3")
		corner(fill, 2)
		local knob = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 9, 0, 9),
			BorderSizePixel = 0,
			ZIndex = 3,
			Parent = track,
		})
		linkAccent(knob, "BackgroundColor3")
		corner(knob, 5)

		local function fmt(v)
			if step >= 1 then
				return tostring(math.floor(v + 0.5))
			end
			return string.format("%.1f", v)
		end

		local function paint(animate)
			local alpha = (max > min) and (value - min) / (max - min) or 0
			valueLbl.Text = fmt(value) .. (opts2.suffix or "")
			local dur = animate == false and 0 or 0.06
			tween(fill, { Size = UDim2.new(alpha, 0, 1, 0) }, dur, Enum.EasingStyle.Quad)
			tween(knob, { Position = UDim2.new(alpha, 0, 0.5, 0) }, dur, Enum.EasingStyle.Quad)
		end

		local function set(v, silent)
			v = math.clamp(v, min, max)
			v = min + math.floor((v - min) / step + 0.5) * step
			v = math.clamp(v, min, max)
			if v == value then
				paint()
				return
			end
			value = v
			paint()
			if opts2.flag then Oblivion.Flags[opts2.flag] = value end
			if not silent and opts2.callback then
				task.spawn(opts2.callback, value)
			end
		end

		local dragging = false
		local function fromX(x)
			local a = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
			set(min + a * (max - min))
		end
		row.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				fromX(input.Position.X)
			end
		end)
		trackConn(UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end))
		trackConn(UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				fromX(input.Position.X)
			end
		end))

		paint(false)
		if opts2.flag then Oblivion.Flags[opts2.flag] = value end
		bindFlag(opts2.flag, function(v) set(v, false) end, function() return value end)

		return {
			Row = row,
			Set = set,
			Get = function() return value end,
		}
	end

	local function buildRangeSlider(parent, opts2)
		opts2 = opts2 or {}
		local min = opts2.min or 0
		local max = opts2.max or 100
		local step = opts2.step or 1
		local lo = math.clamp(opts2.defaultMin or min, min, max)
		local hi = math.clamp(opts2.defaultMax or max, lo, max)

		local row = settingRow(parent, 32)
		row.LayoutOrder = opts2.order or 0
		local lbl = rowLabel(row, opts2.text or "Range", 3)
		lbl.TextColor3 = Theme.TextBright

		local valueBox = make("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -PAD, 0, 3),
			Size = UDim2.new(0, 130, 0, 14),
			BackgroundTransparency = 1,
			Parent = row,
		})
		make("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
			Parent = valueBox,
		})
		local loLbl = make("TextLabel", {
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			Font = FONT,
			Text = "",
			TextSize = SUBTEXT,
			TextColor3 = Theme.TextBright,
			LayoutOrder = 1,
			Parent = valueBox,
		})
		local sep = make("ImageLabel", {
			Size = UDim2.new(0, 10, 0, 10),
			BackgroundTransparency = 1,
			ImageColor3 = Theme.TextDim,
			ScaleType = Enum.ScaleType.Fit,
			LayoutOrder = 2,
			Parent = valueBox,
		})
		applyIcon(sep, resolveIcon("move-horizontal"))
		local hiLbl = loLbl:Clone()
		hiLbl.LayoutOrder = 3
		hiLbl.Parent = valueBox

		local track = make("Frame", {
			Position = UDim2.new(0, PAD, 0, 25),
			Size = UDim2.new(1, -PAD * 2, 0, 3),
			BackgroundColor3 = Theme.TrackBg,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			Parent = row,
		})
		corner(track, 2)
		local fill = make("Frame", {
			BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 1, 0),
			Parent = track,
		})
		linkAccent(fill, "BackgroundColor3")
		corner(fill, 2)
		local knobA = make("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 11, 0, 11),
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 3,
			Parent = track,
		})
		applyIcon(knobA, resolveIcon("play"))
		linkAccent(knobA, "ImageColor3")
		local knobB = make("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 11, 0, 11),
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Fit,
			Rotation = 180,
			ZIndex = 3,
			Parent = track,
		})
		applyIcon(knobB, resolveIcon("play"))
		linkAccent(knobB, "ImageColor3")

		local function fmt(v)
			if step >= 1 then
				return tostring(math.floor(v + 0.5))
			end
			return string.format("%.1f", v)
		end

		local function paint(animate)
			local ra = (max > min) and (lo - min) / (max - min) or 0
			local rb = (max > min) and (hi - min) / (max - min) or 0
			loLbl.Text = fmt(lo)
			hiLbl.Text = fmt(hi)
			local dur = animate == false and 0 or 0.06
			tween(knobA, { Position = UDim2.new(ra, -2, 0.5, 0) }, dur, Enum.EasingStyle.Quad)
			tween(knobB, { Position = UDim2.new(rb, 2, 0.5, 0) }, dur, Enum.EasingStyle.Quad)
			tween(fill, { Position = UDim2.new(ra, 0, 0, 0), Size = UDim2.new(rb - ra, 0, 1, 0) }, dur, Enum.EasingStyle.Quad)
		end

		local function snap(v)
			v = math.clamp(v, min, max)
			return math.clamp(min + math.floor((v - min) / step + 0.5) * step, min, max)
		end

		local function push(silent)
			if opts2.flag then Oblivion.Flags[opts2.flag] = { Min = lo, Max = hi } end
			if not silent and opts2.callback then
				task.spawn(opts2.callback, lo, hi)
			end
		end

		local function set(a, b, silent)
			lo = snap(math.min(a, b))
			hi = snap(math.max(a, b))
			paint()
			push(silent)
		end

		local dragging = nil
		local function fromX(x)
			local a = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
			local v = snap(min + a * (max - min))
			if dragging == "a" then
				lo = math.min(v, hi)
			else
				hi = math.max(v, lo)
			end
			paint()
			push(false)
		end
		row.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local x = input.Position.X
				local da = math.abs(x - knobA.AbsolutePosition.X)
				local db = math.abs(x - knobB.AbsolutePosition.X)
				dragging = da <= db and "a" or "b"
				fromX(x)
			end
		end)
		trackConn(UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = nil
			end
		end))
		trackConn(UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				fromX(input.Position.X)
			end
		end))

		paint(false)
		if opts2.flag then Oblivion.Flags[opts2.flag] = { Min = lo, Max = hi } end
		bindFlag(opts2.flag, function(v)
			if type(v) == "table" then set(v.Min or lo, v.Max or hi, false) end
		end, function() return { Min = lo, Max = hi } end)

		return {
			Row = row,
			Set = function(a, b) set(a, b) end,
			Get = function() return lo, hi end,
		}
	end

	local function buildDropdown(parent, opts2)
		opts2 = opts2 or {}
		local options = opts2.options or {}
		local multi = opts2.multi and true or false
		local label = opts2.text or "Dropdown"
		local selected
		local selectedSet = {}
		if multi then
			for _, v in ipairs(opts2.default or {}) do
				selectedSet[v] = true
			end
		else
			selected = opts2.default or options[1]
		end

		local BOX_H = 26
		local ITEM_H = 24
		local holder = make("Frame", {
			Size = UDim2.new(1, 0, 0, BOX_H + 10),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Parent = parent,
		})
		holder.LayoutOrder = opts2.order or 0

		local box = make("Frame", {
			Position = UDim2.new(0, PAD, 0, 4),
			Size = UDim2.new(1, -PAD * 2, 0, BOX_H),
			BackgroundColor3 = Theme.WindowBg,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Parent = holder,
		})
		corner(box, 6)
		stroke(box, Theme.Outline, 0)

		local boxLbl = make("TextLabel", {
			Position = UDim2.new(0, 10, 0, 0),
			Size = UDim2.new(1, -34, 1, 0),
			BackgroundTransparency = 1,
			Font = FONT,
			Text = "",
			TextSize = SUBTEXT,
			TextColor3 = Theme.TextDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = box,
		})
		local chevSpec = resolveIcon("chevron-down")
		local chev = make("ImageLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -8, 0.5, 0),
			Size = UDim2.new(0, 12, 0, 12),
			BackgroundTransparency = 1,
			ImageColor3 = Theme.TextDim,
			ScaleType = Enum.ScaleType.Fit,
			Parent = box,
		})
		applyIcon(chev, chevSpec)

		local list = make("Frame", {
			Position = UDim2.new(0, PAD, 0, BOX_H + 8),
			Size = UDim2.new(1, -PAD * 2, 0, #options * ITEM_H + 8),
			BackgroundColor3 = Theme.ListBg,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Parent = holder,
		})
		corner(list, 6)
		make("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = list,
		})
		make("UIPadding", {
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
			Parent = list,
		})

		local function labelText()
			if multi then
				local parts = {}
				for _, opt in ipairs(options) do
					if selectedSet[opt] then parts[#parts + 1] = opt end
				end
				local joined = table.concat(parts, ", ")
				if joined == "" then joined = "None" end
				return label .. " - " .. joined
			end
			return label .. " - " .. tostring(selected or "None")
		end

		local open = false
		local itemLbls = {}

		local function paintItems()
			for opt, l in pairs(itemLbls) do
				local on = multi and selectedSet[opt] or (opt == selected)
				tween(l, { TextColor3 = on and Theme.TextBright or Theme.TextDim }, 0.12)
			end
			boxLbl.Text = labelText()
		end

		local function current()
			if multi then
				local parts = {}
				for _, opt in ipairs(options) do
					if selectedSet[opt] then parts[#parts + 1] = opt end
				end
				return parts
			end
			return selected
		end

		local function push(silent)
			if opts2.flag then Oblivion.Flags[opts2.flag] = current() end
			if not silent and opts2.callback then
				task.spawn(opts2.callback, current())
			end
		end

		local function setOpen(o)
			open = o
			tween(chev, { Rotation = o and 180 or 0 }, 0.2)
			tween(holder, { Size = UDim2.new(1, 0, 0, o and (BOX_H + 14 + #options * ITEM_H + 8) or (BOX_H + 10)) }, 0.22, Enum.EasingStyle.Quart)
			tween(boxLbl, { TextColor3 = o and Theme.TextMid or Theme.TextDim }, 0.12)
		end

		local function addItem(opt, i)
			local item = make("TextButton", {
				Size = UDim2.new(1, 0, 0, ITEM_H),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = i,
				Parent = list,
			})
			local il = make("TextLabel", {
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(1, -20, 1, 0),
				BackgroundTransparency = 1,
				Font = FONT,
				Text = opt,
				TextSize = SUBTEXT,
				TextColor3 = Theme.TextDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = item,
			})
			itemLbls[opt] = il
			item.MouseEnter:Connect(function()
				local on = multi and selectedSet[opt] or (opt == selected)
				if not on then
					tween(il, { TextColor3 = Theme.TextMid }, 0.1)
				end
			end)
			item.MouseLeave:Connect(function()
				local on = multi and selectedSet[opt] or (opt == selected)
				if not on then
					tween(il, { TextColor3 = Theme.TextDim }, 0.1)
				end
			end)
			item.MouseButton1Click:Connect(function()
				if multi then
					selectedSet[opt] = not selectedSet[opt] or nil
				else
					selected = opt
					setOpen(false)
				end
				paintItems()
				push(false)
			end)
		end

		local function rebuild(newOptions)
			options = newOptions or options
			for _, c in ipairs(list:GetChildren()) do
				if c:IsA("TextButton") then c:Destroy() end
			end
			itemLbls = {}
			for i, opt in ipairs(options) do
				addItem(opt, i)
			end
			list.Size = UDim2.new(1, -PAD * 2, 0, #options * ITEM_H + 8)
			if open then
				tween(holder, { Size = UDim2.new(1, 0, 0, BOX_H + 14 + #options * ITEM_H + 8) }, 0.2, Enum.EasingStyle.Quart)
			end
			paintItems()
		end

		for i, opt in ipairs(options) do
			addItem(opt, i)
		end

		box.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				setOpen(not open)
			end
		end)

		paintItems()
		push(true)
		bindFlag(opts2.flag, function(v)
			if multi and type(v) == "table" then
				selectedSet = {}
				for _, x in ipairs(v) do selectedSet[x] = true end
			elseif not multi then
				selected = v
			end
			paintItems()
			push(false)
		end, current)

		return {
			Row = holder,
			Set = function(v)
				if multi and type(v) == "table" then
					selectedSet = {}
					for _, x in ipairs(v) do selectedSet[x] = true end
				elseif not multi then
					selected = v
				end
				paintItems()
				push(false)
			end,
			Get = current,
			Refresh = rebuild,
		}
	end

	local function buildColorSlider(parent, opts2)
		opts2 = opts2 or {}
		local hue = 0
		if opts2.default then
			local h = select(1, opts2.default:ToHSV())
			hue = h
		end

		local row = settingRow(parent, 32)
		row.LayoutOrder = opts2.order or 0
		local lbl = rowLabel(row, opts2.text or "Color", 3)
		lbl.TextColor3 = Theme.TextBright

		local hexLbl = make("TextLabel", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -PAD, 0, 3),
			Size = UDim2.new(0, 90, 0, 14),
			BackgroundTransparency = 1,
			Font = FONT,
			Text = "",
			TextSize = SUBTEXT,
			TextColor3 = Theme.TextBright,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = row,
		})

		local track = make("Frame", {
			Position = UDim2.new(0, PAD, 0, 25),
			Size = UDim2.new(1, -PAD * 2, 0, 3),
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = row,
		})
		corner(track, 2)
		make("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
			}),
			Parent = track,
		})
		local knob = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 8, 0, 8),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 3,
			Parent = track,
		})
		corner(knob, 4)
		stroke(knob, Color3.fromRGB(20, 20, 22), 0)

		local function color()
			return Color3.fromHSV(hue, 1, 1)
		end

		local function paint(animate)
			local c = color()
			hexLbl.Text = "#" .. string.upper(string.format("%02x%02x%02x",
				math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5)))
			local dur = animate == false and 0 or 0.06
			tween(knob, { Position = UDim2.new(hue, 0, 0.5, 0) }, dur, Enum.EasingStyle.Quad)
		end

		local function push(silent)
			if opts2.flag then Oblivion.Flags[opts2.flag] = color() end
			if not silent and opts2.callback then
				task.spawn(opts2.callback, color())
			end
		end

		local dragging = false
		local function fromX(x)
			hue = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
			paint()
			push(false)
		end
		row.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				fromX(input.Position.X)
			end
		end)
		trackConn(UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end))
		trackConn(UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				fromX(input.Position.X)
			end
		end))

		paint(false)
		push(true)
		bindFlag(opts2.flag, function(v)
			if typeof(v) == "Color3" then
				hue = select(1, v:ToHSV())
			elseif type(v) == "table" and v.R then
				hue = select(1, Color3.new(v.R, v.G, v.B):ToHSV())
			end
			paint()
			push(false)
		end, color)

		return {
			Row = row,
			Set = function(c)
				hue = select(1, c:ToHSV())
				paint()
				push(false)
			end,
			Get = color,
		}
	end

	local function buildKeybind(parent, opts2)
		opts2 = opts2 or {}
		local key = opts2.default
		local mode = opts2.mode or "Toggle"
		local listening = false
		local held = false

		local row = settingRow(parent)
		row.LayoutOrder = opts2.order or 0
		local lbl = rowLabel(row, opts2.text or "Bind")

		local box = make("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -PAD, 0.5, 0),
			Size = UDim2.new(0, 64, 0, 20),
			BackgroundColor3 = Theme.WindowBg,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			Parent = row,
		})
		corner(box, 4)
		local boxStroke = stroke(box, Theme.Outline, 0.25)
		local keyLbl = make("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Font = FONT,
			Text = keyName(key),
			TextSize = 11,
			TextColor3 = Theme.TextDim,
			Parent = box,
		})

		local function push(state)
			if opts2.callback then
				task.spawn(opts2.callback, state, key)
			end
		end

		local function stopListening()
			listening = false
			keyLbl.Text = keyName(key)
			tween(keyLbl, { TextColor3 = Theme.TextDim }, 0.1)
			boxStroke.Color = Theme.Outline
			tween(boxStroke, { Transparency = 0.25 }, 0.1)
		end

		box.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if keybindListenCancel then keybindListenCancel() end
				keybindListenCancel = stopListening
				listening = true
				keyLbl.Text = "..."
				tween(keyLbl, { TextColor3 = Theme.TextBright }, 0.1)
				boxStroke.Color = Theme.Accent
				tween(boxStroke, { Transparency = 0 }, 0.1)
			end
		end)

		trackConn(UserInputService.InputBegan:Connect(function(input, processed)
			if listening and input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode == Enum.KeyCode.Escape then
					key = nil
				else
					key = input.KeyCode
				end
				keybindListenCancel = nil
				stopListening()
				if opts2.flag then Oblivion.Flags[opts2.flag] = key and key.Name or "None" end
				return
			end
			if processed or listening then return end
			if key and input.KeyCode == key then
				if mode == "Hold" then
					held = true
					push(true)
				else
					push(true)
				end
			end
		end))
		trackConn(UserInputService.InputEnded:Connect(function(input)
			if mode == "Hold" and key and input.KeyCode == key and held then
				held = false
				push(false)
			end
		end))

		local function applyKey(kc)
			key = kc
			keyLbl.Text = keyName(key)
			if opts2.flag then Oblivion.Flags[opts2.flag] = key and key.Name or "None" end
		end

		if opts2.flag then Oblivion.Flags[opts2.flag] = key and key.Name or "None" end
		bindFlag(opts2.flag, function(v)
			if type(v) == "string" and v ~= "None" then
				local ok, kc = pcall(function() return Enum.KeyCode[v] end)
				applyKey(ok and kc or nil)
			else
				applyKey(nil)
			end
		end, function() return key and key.Name or "None" end)

		return {
			Row = row,
			Set = applyKey,
			Get = function() return key end,
		}
	end

	local function buildButton(parent, opts2)
		opts2 = opts2 or {}
		local row = settingRow(parent)
		row.LayoutOrder = opts2.order or 0
		local lbl = rowLabel(row, opts2.text or "Button")
		lbl.TextColor3 = Theme.TextMid

		row.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				tween(lbl, { TextColor3 = Theme.TextBright }, 0.06)
				task.delay(0.12, function()
					tween(lbl, { TextColor3 = Theme.TextMid }, 0.2)
				end)
				if opts2.callback then
					task.spawn(opts2.callback)
				end
			end
		end)
		row.MouseEnter:Connect(function()
			tween(lbl, { TextColor3 = Theme.TextBright }, 0.12)
		end)
		row.MouseLeave:Connect(function()
			tween(lbl, { TextColor3 = Theme.TextMid }, 0.12)
		end)

		return { Row = row }
	end

	local function buildTextbox(parent, opts2)
		opts2 = opts2 or {}
		local row = settingRow(parent, 36)
		row.LayoutOrder = opts2.order or 0

		local box = make("Frame", {
			Position = UDim2.new(0, PAD + 4, 0, 5),
			Size = UDim2.new(1, -(PAD + 4) * 2, 0, 26),
			BackgroundColor3 = Theme.WindowBg,
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			Parent = row,
		})
		corner(box, 5)
		local boxStroke = stroke(box, Theme.Outline, 0.25)

		local input = make("TextBox", {
			Position = UDim2.new(0, 10, 0, 0),
			Size = UDim2.new(1, -20, 1, 0),
			BackgroundTransparency = 1,
			Font = FONT,
			Text = opts2.default or "",
			PlaceholderText = opts2.placeholder or (opts2.text or ""),
			PlaceholderColor3 = Theme.TextDim,
			TextSize = SUBTEXT,
			TextColor3 = Theme.TextBright,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Parent = box,
		})

		input.Focused:Connect(function()
			tween(boxStroke, { Transparency = 0 }, 0.1)
		end)
		input.FocusLost:Connect(function(enter)
			tween(boxStroke, { Transparency = 0.25 }, 0.1)
			if opts2.flag then Oblivion.Flags[opts2.flag] = input.Text end
			if opts2.callback then
				task.spawn(opts2.callback, input.Text, enter)
			end
		end)

		local function setText(t, silent)
			input.Text = tostring(t == nil and "" or t)
			if opts2.flag then Oblivion.Flags[opts2.flag] = input.Text end
			if not silent and opts2.callback then
				task.spawn(opts2.callback, input.Text, false)
			end
		end

		if opts2.flag then Oblivion.Flags[opts2.flag] = input.Text end
		bindFlag(opts2.flag, function(v)
			setText(v, false)
		end, function() return input.Text end)

		return {
			Row = row,
			Set = function(t) setText(t) end,
			Get = function() return input.Text end,
		}
	end

	local catCount = 0

	function self.Category(name, copts)
		copts = copts or {}
		catCount = catCount + 1
		local cat = {}
		local iconSpec = resolveIcon(copts.icon)
		local isOpen = false
		local modules = {}
		local row = make("Frame", {
			Size = UDim2.new(1, 0, 0, ROW_H),
			BackgroundTransparency = 1,
			LayoutOrder = copts.order or nextSideOrder(),
			Parent = side.Body,
		})
		local rowIcon = make("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, PAD + 2, 0.5, 0),
			Size = UDim2.new(0, 16, 0, 16),
			BackgroundTransparency = 1,
			ImageColor3 = Theme.TextDim,
			ScaleType = Enum.ScaleType.Fit,
			Visible = false,
			Parent = row,
		})
		if iconSpec then
			applyIcon(rowIcon, iconSpec)
		end
		local rowLbl = make("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, iconSpec and 40 or PAD, 0.5, 0),
			Size = UDim2.new(1, -60, 1, 0),
			BackgroundTransparency = 1,
			Font = FONT_MED,
			Text = name,
			TextSize = SUBTEXT,
			TextColor3 = Theme.TextDim,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = row,
		})
		local rowChev = make("ImageLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -PAD, 0.5, 0),
			Size = UDim2.new(0, 12, 0, 12),
			BackgroundTransparency = 1,
			ImageColor3 = Theme.TextDim,
			ScaleType = Enum.ScaleType.Fit,
			Parent = row,
		})
		applyIcon(rowChev, resolveIcon("chevron-right"))

		local function paintRow()
			local dur = 0.15
			if isOpen then
				tween(rowIcon, { ImageColor3 = Theme.Accent }, dur)
				tween(rowLbl, { TextColor3 = Theme.Accent }, dur)
				tween(rowChev, { ImageColor3 = Theme.Accent }, dur)
			else
				tween(rowIcon, { ImageColor3 = Theme.TextDim }, dur)
				tween(rowLbl, { TextColor3 = Theme.TextDim }, dur)
				tween(rowChev, { ImageColor3 = Theme.TextDim }, dur)
			end
		end

		row.MouseEnter:Connect(function()
			if not isOpen then
				tween(rowIcon, { ImageColor3 = Theme.Accent }, 0.12)
				tween(rowLbl, { TextColor3 = Theme.Accent }, 0.12)
				tween(rowChev, { ImageColor3 = Theme.Accent }, 0.12)
			end
		end)
		row.MouseLeave:Connect(function()
			paintRow()
		end)

		local w = baseWindow(name, iconSpec, WIN_W)
		local win = w.Frame
		win.Visible = false

		local function openWindow()
			if isOpen or w.Flying then return end
			isOpen = true
			w.Flying = true
			win:SetAttribute("OblOpen", true)
			paintRow()
			local target = registerOpen(w)
			local rowPos = row.AbsolutePosition
			win.Position = UDim2.new(0, rowPos.X, 0, rowPos.Y)
			win.Size = UDim2.new(0, WIN_W, 0, HEADER_H)
			w.Collapsed = true
			w.Chevron.Rotation = 180
			w.FadeBody(0.35)
			win.Visible = true
			bringToFront(win)
			tween(win, { Position = target }, 0.42, Enum.EasingStyle.Quint)
			w.FadeBody(0, 0.42)
			task.delay(0.24, function()
				if not isOpen then return end
				w.SetCollapsed(false)
				for i, m in ipairs(modules) do
					m.FadeIn(0.04 + i * 0.028)
				end
				task.delay(0.34, function() w.Flying = false end)
			end)
		end

		local function closeWindow()
			if not isOpen or w.Flying then return end
			isOpen = false
			w.Flying = true
			win:SetAttribute("OblOpen", false)
			paintRow()
			registerClose(w)
			w.SetCollapsed(true)
			task.delay(0.16, function()
				local rowPos = row.AbsolutePosition
				w.FadeBody(1, 0.3)
				local t = tween(win, {
					Position = UDim2.new(0, rowPos.X, 0, rowPos.Y),
				}, 0.32, Enum.EasingStyle.Quint)
				t.Completed:Connect(function()
					win.Visible = false
					w.FadeBody(0)
					w.Flying = false
				end)
			end)
		end

		row.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if isOpen then closeWindow() else openWindow() end
			end
		end)

		local modOrder = 0

		function cat.Module(mname, mopts)
			mopts = mopts or {}
			modOrder = modOrder + 1
			local myOrder = modOrder
			local mod = {}
			local enabled = false
			local expanded = false
			local favorite = false
			local hidden = false

			local holder = make("Frame", {
				Size = UDim2.new(1, 0, 0, ROW_H),
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				LayoutOrder = myOrder,
				Parent = w.Body,
			})

			local mrow = make("Frame", {
				Size = UDim2.new(1, 0, 0, ROW_H),
				BackgroundTransparency = 1,
				Parent = holder,
			})
			local hoverFill = make("Frame", {
				Size = UDim2.new(1, -8, 1, -4),
				Position = UDim2.new(0, 4, 0, 2),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 1,
				Parent = mrow,
			})
			corner(hoverFill, 5)
			local nameLbl = make("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, PAD, 0.5, 0),
				Size = UDim2.new(1, -76, 1, 0),
				BackgroundTransparency = 1,
				Font = FONT_MED,
				Text = mname,
				TextSize = SUBTEXT,
				TextColor3 = Theme.TextDim,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = mrow,
			})
			local star = make("ImageLabel", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -PAD - 20, 0.5, 0),
				Size = UDim2.new(0, 13, 0, 13),
				BackgroundTransparency = 1,
				ImageColor3 = Theme.Star,
				ImageTransparency = 1,
				ScaleType = Enum.ScaleType.Fit,
				ZIndex = 3,
				Parent = mrow,
			})
			applyStar(star)
			star.Visible = true
			local dots = make("ImageLabel", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -PAD + 4, 0.5, 0),
				Size = UDim2.new(0, 14, 0, 14),
				BackgroundTransparency = 1,
				ImageColor3 = Theme.TextDim,
				ScaleType = Enum.ScaleType.Fit,
				ZIndex = 3,
				Parent = mrow,
			})
			applyIcon(dots, resolveIcon("more-vertical"))

			local settings = make("Frame", {
				Position = UDim2.new(0, 0, 0, ROW_H),
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Parent = holder,
			})
			local setLayout = make("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = settings,
			})

			local function paintName()
				local target = (enabled or expanded) and Theme.Accent or Theme.TextDim
				tween(nameLbl, { TextColor3 = target }, 0.15)
			end

			local function settingsHeight()
				return setLayout.AbsoluteContentSize.Y
			end

			local function holderTarget()
				if hidden then return 0 end
				return expanded and (ROW_H + settingsHeight() + 8) or ROW_H
			end

			local function refreshHeight(animate)
				local h = holderTarget()
				if animate == false then
					holder.Size = UDim2.new(1, 0, 0, h)
				else
					tween(holder, { Size = UDim2.new(1, 0, 0, h) }, 0.25, Enum.EasingStyle.Quart)
				end
			end

			setLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				if expanded then refreshHeight() end
			end)

			local function staggerSettings()
				local i = 0
				for _, child in ipairs(settings:GetChildren()) do
					if child:IsA("Frame") and child.Visible then
						i = i + 1
						local cache = collectFade(child)
						for _, e in ipairs(cache) do
							e.inst[e.prop] = 1
						end
						task.delay(i * 0.02, function()
							fadeTree(cache, false, 0.2)
						end)
					end
				end
			end

			local function setExpanded(x)
				if expanded == x then return end
				expanded = x
				paintName()
				refreshHeight()
				if x then staggerSettings() end
			end
			mod.SetExpanded = setExpanded
			mod.IsExpanded = function() return expanded end

			mrow.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local pos = input.Position.X
					local starX = star.AbsolutePosition.X
					if pos >= starX - 6 then
						return
					end
					setExpanded(not expanded)
				end
			end)

			mrow.MouseEnter:Connect(function()
				if not enabled and not expanded then
					tween(nameLbl, { TextColor3 = Theme.TextMid }, 0.12)
				elseif enabled or expanded then
					tween(nameLbl, { TextColor3 = Theme.Accent }, 0.12)
				end
				if not favorite then
					tween(star, { ImageTransparency = 0.55 }, 0.12)
				end
				tween(hoverFill, { BackgroundTransparency = 0.96 }, 0.12)
			end)
			mrow.MouseLeave:Connect(function()
				paintName()
				if not favorite then
					tween(star, { ImageTransparency = 1 }, 0.12)
				end
				tween(hoverFill, { BackgroundTransparency = 1 }, 0.16)
			end)

			star.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					favorite = not favorite
					tween(star, {
						ImageTransparency = favorite and 0 or 0.55,
						ImageColor3 = favorite and Theme.Star or Theme.TextDim,
					}, 0.15)
					if favFilter then applyFavFilter() end
				end
			end)
			star.MouseEnter:Connect(function()
				tween(star, { ImageTransparency = favorite and 0 or 0.3 }, 0.1)
			end)

			local enableToggle = buildToggle(settings, {
				text = "Enable",
				default = mopts.default,
				flag = mopts.flag,
				order = 1,
				callback = function(v)
					enabled = v
					paintName()
					if mopts.callback then
						task.spawn(mopts.callback, v)
					end
				end,
			})
			if mopts.default then
				enabled = true
				paintName()
			end

			local bindRow
			dots.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if not bindRow then
						bindRow = buildKeybind(settings, {
							text = "Bind",
							order = 1000,
							mode = mopts.bindMode or "Toggle",
							flag = mopts.flag and (mopts.flag .. "_bind") or nil,
							callback = function(state)
								if (mopts.bindMode or "Toggle") == "Hold" then
									enableToggle.Set(state)
								else
									enableToggle.Set(not enableToggle.Get())
								end
							end,
						})
					else
						bindRow.Row.Visible = not bindRow.Row.Visible
					end
					if not expanded then
						setExpanded(true)
					else
						refreshHeight()
					end
				end
			end)
			dots.MouseEnter:Connect(function()
				tween(dots, { ImageColor3 = Theme.TextMid }, 0.1)
			end)
			dots.MouseLeave:Connect(function()
				tween(dots, { ImageColor3 = Theme.TextDim }, 0.1)
			end)

			local elemOrder = 1
			local function nextOrder()
				elemOrder = elemOrder + 1
				return elemOrder
			end

			function mod.Toggle(o)
				o = o or {}
				o.order = o.order or nextOrder()
				return buildToggle(settings, o)
			end
			function mod.Slider(o)
				o = o or {}
				o.order = o.order or nextOrder()
				return buildSlider(settings, o)
			end
			function mod.RangeSlider(o)
				o = o or {}
				o.order = o.order or nextOrder()
				return buildRangeSlider(settings, o)
			end
			function mod.Dropdown(o)
				o = o or {}
				o.order = o.order or nextOrder()
				return buildDropdown(settings, o)
			end
			function mod.MultiDropdown(o)
				o = o or {}
				o.multi = true
				o.order = o.order or nextOrder()
				return buildDropdown(settings, o)
			end
			function mod.ColorSlider(o)
				o = o or {}
				o.order = o.order or nextOrder()
				return buildColorSlider(settings, o)
			end
			function mod.Keybind(o)
				o = o or {}
				o.order = o.order or nextOrder()
				return buildKeybind(settings, o)
			end
			function mod.Button(o)
				o = o or {}
				o.order = o.order or nextOrder()
				return buildButton(settings, o)
			end
			function mod.Textbox(o)
				o = o or {}
				o.order = o.order or nextOrder()
				return buildTextbox(settings, o)
			end

			function mod.SetEnabled(v)
				enableToggle.Set(v)
			end
			function mod.GetEnabled()
				return enableToggle.Get()
			end
			mod.IsFavorite = function() return favorite end
			mod.SetHidden = function(h)
				hidden = h
				holder.Visible = not h
				refreshHeight(false)
			end
			mod.FadeIn = function(delay)
				local cache = collectFade(mrow)
				for _, e in ipairs(cache) do
					if not (e.inst == star and not favorite) then
						e.inst[e.prop] = 1
					end
				end
				task.delay(delay or 0, function()
					fadeTree(cache, false, 0.22)
				end)
			end

			mod.Name = mname
			mod.Holder = holder
			modules[#modules + 1] = mod

			return mod
		end

		cat.RefreshHidden = applyFavFilter
		cat.Open = openWindow
		cat.Close = closeWindow
		cat.IsOpen = function() return isOpen end
		cat.Window = w
		cat.Modules = modules
		categories[#categories + 1] = cat
		return cat
	end

	local searchActive = false
	local preState = nil

	local function snapshotCat(cat)
		local st = { collapsed = cat.Window.Collapsed, expanded = {} }
		for i, m in ipairs(cat.Modules) do
			st.expanded[i] = m.IsExpanded()
		end
		preState[cat] = st
	end

	applySearch = function(q)
		q = string.lower(q or "")
		if q == "" then
			if searchActive and preState then
				for _, cat in ipairs(categories) do
					local st = preState[cat]
					if st then
						cat.RefreshHidden()
						for i, m in ipairs(cat.Modules) do
							m.SetExpanded(st.expanded[i])
						end
						if cat.IsOpen() then
							cat.Window.SetCollapsed(st.collapsed)
						end
					end
				end
			end
			searchActive = false
			preState = nil
			return
		end
		if not searchActive then
			searchActive = true
			preState = {}
		end
		for _, cat in ipairs(categories) do
			if cat.IsOpen() then
				if not preState[cat] then
					snapshotCat(cat)
				end
				local any = false
				for _, m in ipairs(cat.Modules) do
					local hit = string.find(string.lower(m.Name), q, 1, true) ~= nil
					m.SetHidden(not hit)
					if hit then
						any = true
						m.SetExpanded(true)
					end
				end
				cat.Window.SetCollapsed(not any)
			end
		end
	end

	local function encodeValue(v)
		if typeof(v) == "Color3" then
			return { __color = { v.R, v.G, v.B } }
		end
		return v
	end

	local function decodeValue(v)
		if type(v) == "table" and v.__color then
			return Color3.new(v.__color[1], v.__color[2], v.__color[3])
		end
		return v
	end

	function self.SaveConfig(cfgName)
		if not canFile() or not HttpService then return false end
		cfgName = (cfgName == nil or cfgName == "") and "default" or tostring(cfgName)
		ensureFolder()
		local out = {}
		for flag, v in pairs(Oblivion.Flags) do
			out[flag] = encodeValue(v)
		end
		local ok = pcall(function()
			writefile(CONFIG_FOLDER .. "/configs/" .. cfgName .. ".json", HttpService:JSONEncode(out))
		end)
		return ok
	end

	function self.LoadConfig(cfgName)
		if not canFile() or not HttpService then return false end
		cfgName = (cfgName == nil or cfgName == "") and "default" or tostring(cfgName)
		local path = CONFIG_FOLDER .. "/configs/" .. cfgName .. ".json"
		local ok, data = pcall(function()
			return HttpService:JSONDecode(readfile(path))
		end)
		if not ok or type(data) ~= "table" then return false end
		for flag, v in pairs(data) do
			local bindEntry = flagBinds[flag]
			if bindEntry then
				pcall(bindEntry.set, decodeValue(v))
			else
				Oblivion.Flags[flag] = decodeValue(v)
			end
		end
		return true
	end

	function self.ListConfigs()
		local names = {}
		if type(listfiles) ~= "function" then return names end
		ensureFolder()
		pcall(function()
			for _, f in ipairs(listfiles(CONFIG_FOLDER .. "/configs")) do
				local n = string.match(f, "([^/\\]+)%.json$")
				if n then names[#names + 1] = n end
			end
		end)
		return names
	end

	local menuVisible = true
	local hiddenFrames = {}
	local fadeLock = 0

	local function setMenuVisible(v)
		if v == menuVisible then return end
		if os.clock() < fadeLock then return end
		fadeLock = os.clock() + 0.2
		menuVisible = v
		if not v then
			hiddenFrames = {}
			for _, f in ipairs(screen:GetChildren()) do
				if f:IsA("GuiObject") and f.Name ~= "Watermark" and f.Visible and f:GetAttribute("OblOpen") ~= false then
					local cache = collectFade(f)
					hiddenFrames[#hiddenFrames + 1] = { frame = f, cache = cache }
					fadeTree(cache, true, 0.16)
				end
			end
			task.delay(0.17, function()
				if not menuVisible then
					for _, e in ipairs(hiddenFrames) do
						e.frame.Visible = false
					end
				end
			end)
		else
			for _, e in ipairs(hiddenFrames) do
				if e.frame:GetAttribute("OblOpen") ~= false then
					e.frame.Visible = true
					fadeTree(e.cache, false, 0.18)
				end
			end
			hiddenFrames = {}
		end
	end

	function self.ToggleMenu()
		setMenuVisible(not menuVisible)
	end
	function self.SetMenuVisible(v)
		setMenuVisible(v and true or false)
	end

	local settingsWin = baseWindow("Settings", resolveIcon("settings"), WIN_W)
	settingsWin.Frame.Visible = false
	local settingsOpen = false

	local footer = make("Frame", {
		Size = UDim2.new(1, 0, 0, ROW_H),
		BackgroundTransparency = 1,
		LayoutOrder = 100000,
		Parent = side.Body,
	})
	local gear = make("ImageLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, PAD, 0.5, 0),
		Size = UDim2.new(0, 15, 0, 15),
		BackgroundTransparency = 1,
		ImageColor3 = Theme.TextDim,
		ScaleType = Enum.ScaleType.Fit,
		Parent = footer,
	})
	applyIcon(gear, resolveIcon("settings"))
	local unloadBtn = make("ImageLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -PAD, 0.5, 0),
		Size = UDim2.new(0, 15, 0, 15),
		BackgroundTransparency = 1,
		ImageColor3 = Theme.TextDim,
		ScaleType = Enum.ScaleType.Fit,
		Parent = footer,
	})
	applyIcon(unloadBtn, resolveIcon("sparkles"))

	local function toggleSettings()
		if settingsWin.Flying then return end
		if not settingsOpen then
			settingsOpen = true
			settingsWin.Flying = true
			settingsWin.Frame:SetAttribute("OblOpen", true)
			tween(gear, { ImageColor3 = Theme.Accent }, 0.15)
			local target = registerOpen(settingsWin)
			local fp = footer.AbsolutePosition
			local win = settingsWin.Frame
			win.Position = UDim2.new(0, fp.X, 0, fp.Y)
			win.Size = UDim2.new(0, WIN_W, 0, HEADER_H)
			settingsWin.Collapsed = true
			settingsWin.Chevron.Rotation = 180
			settingsWin.FadeBody(0.35)
			win.Visible = true
			bringToFront(win)
			tween(win, { Position = target }, 0.42, Enum.EasingStyle.Quint)
			settingsWin.FadeBody(0, 0.42)
			task.delay(0.24, function()
				if not settingsOpen then return end
				settingsWin.SetCollapsed(false)
				task.delay(0.34, function() settingsWin.Flying = false end)
			end)
		else
			settingsOpen = false
			settingsWin.Flying = true
			settingsWin.Frame:SetAttribute("OblOpen", false)
			tween(gear, { ImageColor3 = Theme.TextDim }, 0.15)
			registerClose(settingsWin)
			settingsWin.SetCollapsed(true)
			task.delay(0.16, function()
				local fp = footer.AbsolutePosition
				settingsWin.FadeBody(1, 0.3)
				local t = tween(settingsWin.Frame, {
					Position = UDim2.new(0, fp.X, 0, fp.Y),
				}, 0.32, Enum.EasingStyle.Quint)
				t.Completed:Connect(function()
					settingsWin.Frame.Visible = false
					settingsWin.FadeBody(0)
					settingsWin.Flying = false
				end)
			end)
		end
	end

	gear.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			toggleSettings()
		end
	end)
	gear.MouseEnter:Connect(function()
		if not settingsOpen then
			tween(gear, { ImageColor3 = Theme.TextMid }, 0.12)
		end
	end)
	gear.MouseLeave:Connect(function()
		if not settingsOpen then
			tween(gear, { ImageColor3 = Theme.TextDim }, 0.12)
		end
	end)

	unloadBtn.MouseEnter:Connect(function()
		tween(unloadBtn, { ImageColor3 = Color3.fromRGB(235, 90, 90) }, 0.12)
	end)
	unloadBtn.MouseLeave:Connect(function()
		tween(unloadBtn, { ImageColor3 = Theme.TextDim }, 0.12)
	end)
	unloadBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.Destroy()
		end
	end)

	buildKeybind(settingsWin.Body, {
		text = "Menu keybind",
		default = opts.keybind or Enum.KeyCode.RightShift,
		order = 1,
		callback = function()
			self.ToggleMenu()
		end,
	})
	buildColorSlider(settingsWin.Body, {
		text = "Accent color",
		default = Theme.Accent,
		order = 2,
		callback = function(c)
			retintAccent(c)
		end,
	})
	buildToggle(settingsWin.Body, {
		text = "Watermark",
		default = opts.watermark ~= false,
		order = 3,
		callback = function(v)
			watermark.Visible = v
		end,
	})

	local cfgDrop
	local cfgNameBox = buildTextbox(settingsWin.Body, {
		placeholder = "Config name",
		order = 4,
	})
	buildButton(settingsWin.Body, {
		text = "Save config",
		order = 5,
		callback = function()
			self.SaveConfig(cfgNameBox.Get())
			if cfgDrop then cfgDrop.Refresh(self.ListConfigs()) end
		end,
	})
	cfgDrop = buildDropdown(settingsWin.Body, {
		text = "Config",
		options = self.ListConfigs(),
		order = 6,
	})
	buildButton(settingsWin.Body, {
		text = "Load config",
		order = 7,
		callback = function()
			local sel = cfgDrop.Get()
			if sel then
				self.LoadConfig(sel)
			end
		end,
	})

	self.Categories = categories
	self.Flags = Oblivion.Flags
	self.SetAccent = retintAccent
	return self
end

return Oblivion
