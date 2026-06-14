local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local Theme = {
	Background   = Color3.fromRGB(25, 25, 32),
	Surface      = Color3.fromRGB(35, 35, 45),
	SurfaceHover = Color3.fromRGB(48, 48, 62),
	Accent       = Color3.fromRGB(110, 90, 230),
	AccentLight  = Color3.fromRGB(140, 120, 255),
	Success      = Color3.fromRGB(80, 210, 130),
	Error        = Color3.fromRGB(220, 70, 70),
	TextPrimary  = Color3.fromRGB(235, 235, 250),
	TextSecond   = Color3.fromRGB(140, 138, 165),
	Border       = Color3.fromRGB(55, 53, 75),
	TopBar       = Color3.fromRGB(18, 18, 24),
}

local function tw(obj, props, t, style, dir)
	TweenService:Create(obj,
		TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
		props
	):Play()
end

local function addCorner(p, r)
	local c = Instance.new("UICorner", p)
	c.CornerRadius = UDim.new(0, r or 10)
	return c
end

local function addStroke(p, col, thick, trans)
	local s = Instance.new("UIStroke", p)
	s.Color = col or Theme.Border
	s.Thickness = thick or 1
	s.Transparency = trans or 0
	return s
end

-- GUI ROOT — use CoreGui for maximum compatibility
local gui
local ok = pcall(function()
	gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
end)
if not ok then
	gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
end
gui.Name = "KuunsItemReplicator"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999

local WIN_W, WIN_H = 340, 235

-- MAIN WINDOW
local window = Instance.new("Frame", gui)
window.Name = "Window"
window.Size = UDim2.new(0, WIN_W, 0, WIN_H)
window.Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
window.BackgroundColor3 = Theme.Background
window.BorderSizePixel = 0
window.Active = true
window.ZIndex = 5
addCorner(window, 12)
addStroke(window, Theme.Border, 1.2, 0)

-- Drop shadow
local shadow = Instance.new("ImageLabel", window)
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.BackgroundTransparency = 1
shadow.Position = UDim2.new(0.5, 0, 0.5, 8)
shadow.Size = UDim2.new(1, 60, 1, 60)
shadow.ZIndex = 4
shadow.Image = "rbxassetid://6014261993"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.55
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(49, 49, 450, 450)

-- TOP BAR
local topBar = Instance.new("Frame", window)
topBar.Size = UDim2.new(1, 0, 0, 42)
topBar.BackgroundColor3 = Theme.TopBar
topBar.BorderSizePixel = 0
topBar.ZIndex = 6
addCorner(topBar, 12)

local topFix = Instance.new("Frame", topBar)
topFix.Size = UDim2.new(1, 0, 0.5, 1)
topFix.Position = UDim2.new(0, 0, 0.5, 0)
topFix.BackgroundColor3 = Theme.TopBar
topFix.BorderSizePixel = 0
topFix.ZIndex = 6

-- Accent pill left
local pill = Instance.new("Frame", topBar)
pill.Size = UDim2.new(0, 3, 0, 20)
pill.Position = UDim2.new(0, 13, 0.5, -10)
pill.BackgroundColor3 = Theme.Accent
pill.BorderSizePixel = 0
pill.ZIndex = 7
addCorner(pill, 3)

local titleLabel = Instance.new("TextLabel", topBar)
titleLabel.Text = "Item Replicator"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 15
titleLabel.TextColor3 = Theme.TextPrimary
titleLabel.BackgroundTransparency = 1
titleLabel.Size = UDim2.new(1, -110, 1, 0)
titleLabel.Position = UDim2.new(0, 24, 0, 0)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 7

local byLabel = Instance.new("TextLabel", topBar)
byLabel.Text = "by Koons"
byLabel.Font = Enum.Font.Gotham
byLabel.TextSize = 11
byLabel.TextColor3 = Theme.TextSecond
byLabel.BackgroundTransparency = 1
byLabel.Size = UDim2.new(0, 65, 1, 0)
byLabel.Position = UDim2.new(1, -130, 0, 0)
byLabel.TextXAlignment = Enum.TextXAlignment.Right
byLabel.ZIndex = 7

-- Minimize btn
local minBtn = Instance.new("TextButton", topBar)
minBtn.Text = "—"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 13
minBtn.TextColor3 = Theme.TextSecond
minBtn.BackgroundColor3 = Theme.Surface
minBtn.Size = UDim2.new(0, 26, 0, 26)
minBtn.Position = UDim2.new(1, -62, 0.5, -13)
minBtn.ZIndex = 8
minBtn.AutoButtonColor = false
addCorner(minBtn, 6)

-- Close btn
local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.BackgroundColor3 = Theme.Error
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -32, 0.5, -13)
closeBtn.ZIndex = 8
closeBtn.AutoButtonColor = false
addCorner(closeBtn, 6)

for _, b in pairs({minBtn, closeBtn}) do
	b.MouseEnter:Connect(function() tw(b, {BackgroundTransparency = 0.3}, 0.12) end)
	b.MouseLeave:Connect(function() tw(b, {BackgroundTransparency = 0}, 0.12) end)
end

-- CONTENT
local content = Instance.new("Frame", window)
content.Name = "Content"
content.Size = UDim2.new(1, -24, 0, WIN_H - 54)
content.Position = UDim2.new(0, 12, 0, 50)
content.BackgroundTransparency = 1
content.ZIndex = 6

-- ITEM INFO BOX
local infoBox = Instance.new("Frame", content)
infoBox.Size = UDim2.new(1, 0, 0, 44)
infoBox.Position = UDim2.new(0, 0, 0, 0)
infoBox.BackgroundColor3 = Theme.Surface
infoBox.ZIndex = 6
addCorner(infoBox, 8)
addStroke(infoBox, Theme.Border, 1, 0.4)

local statusDot = Instance.new("Frame", infoBox)
statusDot.Size = UDim2.new(0, 7, 0, 7)
statusDot.Position = UDim2.new(0, 13, 0.5, -3.5)
statusDot.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
statusDot.ZIndex = 7
addCorner(statusDot, 4)

local itemNameLbl = Instance.new("TextLabel", infoBox)
itemNameLbl.Text = "No item equipped"
itemNameLbl.Font = Enum.Font.GothamMedium
itemNameLbl.TextSize = 13
itemNameLbl.TextColor3 = Theme.TextPrimary
itemNameLbl.BackgroundTransparency = 1
itemNameLbl.Size = UDim2.new(1, -80, 1, 0)
itemNameLbl.Position = UDim2.new(0, 28, 0, 0)
itemNameLbl.TextXAlignment = Enum.TextXAlignment.Left
itemNameLbl.ZIndex = 7

local equippedTag = Instance.new("TextLabel", infoBox)
equippedTag.Text = "EQUIPPED"
equippedTag.Font = Enum.Font.GothamBold
equippedTag.TextSize = 9
equippedTag.TextColor3 = Theme.TextSecond
equippedTag.BackgroundTransparency = 1
equippedTag.Size = UDim2.new(0, 68, 1, 0)
equippedTag.Position = UDim2.new(1, -72, 0, 0)
equippedTag.TextXAlignment = Enum.TextXAlignment.Right
equippedTag.ZIndex = 7

-- BUTTONS
local btnRow = Instance.new("Frame", content)
btnRow.Size = UDim2.new(1, 0, 0, 50)
btnRow.Position = UDim2.new(0, 0, 0, 54)
btnRow.BackgroundTransparency = 1
btnRow.ZIndex = 6

local layout = Instance.new("UIListLayout", btnRow)
layout.FillDirection = Enum.FillDirection.Horizontal
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center

local function makeBtn(label, accentCol)
	local btn = Instance.new("TextButton", btnRow)
	btn.Size = UDim2.new(0, 88, 0, 50)
	btn.BackgroundColor3 = Theme.Surface
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.ZIndex = 7
	addCorner(btn, 9)
	addStroke(btn, accentCol, 1, 0.55)

	local top = Instance.new("TextLabel", btn)
	top.Text = label
	top.Font = Enum.Font.GothamBold
	top.TextSize = 16
	top.TextColor3 = Theme.TextPrimary
	top.BackgroundTransparency = 1
	top.Size = UDim2.new(1, 0, 0.55, 0)
	top.Position = UDim2.new(0, 0, 0.05, 0)
	top.TextXAlignment = Enum.TextXAlignment.Center
	top.ZIndex = 8

	local sub = Instance.new("TextLabel", btn)
	sub.Text = "REPLICATE"
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 9
	sub.TextColor3 = accentCol
	sub.BackgroundTransparency = 1
	sub.Size = UDim2.new(1, 0, 0.35, 0)
	sub.Position = UDim2.new(0, 0, 0.62, 0)
	sub.TextXAlignment = Enum.TextXAlignment.Center
	sub.ZIndex = 8

	btn.MouseEnter:Connect(function()
		tw(btn, {BackgroundColor3 = Theme.SurfaceHover}, 0.15)
	end)
	btn.MouseLeave:Connect(function()
		tw(btn, {BackgroundColor3 = Theme.Surface}, 0.15)
	end)
	btn.MouseButton1Down:Connect(function()
		tw(btn, {Size = UDim2.new(0, 83, 0, 46)}, 0.07, Enum.EasingStyle.Quad)
	end)
	btn.MouseButton1Up:Connect(function()
		tw(btn, {Size = UDim2.new(0, 88, 0, 50)}, 0.2, Enum.EasingStyle.Back)
	end)

	return btn
end

local btn1  = makeBtn("×1",  Color3.fromRGB(120, 100, 255))
local btn5  = makeBtn("×5",  Color3.fromRGB(160, 80,  255))
local btn10 = makeBtn("×10", Color3.fromRGB(200, 60,  255))

-- TOAST NOTIFICATION (floats below main window, slides in from bottom)
local toastActive = false

local function notify(text, isErr)
	if toastActive then return end
	toastActive = true

	local color = isErr and Theme.Error or Theme.Success
	local icon  = isErr and "⚠" or "✔"

	-- Toast container
	local toast = Instance.new("Frame", gui)
	toast.Name = "Toast"
	toast.AnchorPoint = Vector2.new(0.5, 0)
	toast.Size = UDim2.new(0, 300, 0, 52)
	-- start above screen, slides down to center
	toast.Position = UDim2.new(0.5, 0, 0, -60)
	toast.BackgroundColor3 = Color3.fromRGB(20, 20, 27)
	toast.BorderSizePixel = 0
	toast.ZIndex = 50
	addCorner(toast, 12)
	addStroke(toast, color, 1.2, 0.3)

	-- Drop shadow
	local tShadow = Instance.new("ImageLabel", toast)
	tShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	tShadow.BackgroundTransparency = 1
	tShadow.Position = UDim2.new(0.5, 0, 0.5, 6)
	tShadow.Size = UDim2.new(1, 40, 1, 40)
	tShadow.ZIndex = 49
	tShadow.Image = "rbxassetid://6014261993"
	tShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	tShadow.ImageTransparency = 0.6
	tShadow.ScaleType = Enum.ScaleType.Slice
	tShadow.SliceCenter = Rect.new(49, 49, 450, 450)

	-- Left accent bar
	local acBar = Instance.new("Frame", toast)
	acBar.Size = UDim2.new(0, 3, 0, 30)
	acBar.Position = UDim2.new(0, 12, 0.5, -15)
	acBar.BackgroundColor3 = color
	acBar.BorderSizePixel = 0
	acBar.ZIndex = 51
	addCorner(acBar, 3)

	-- Icon
	local iconLbl = Instance.new("TextLabel", toast)
	iconLbl.Text = icon
	iconLbl.Font = Enum.Font.GothamBold
	iconLbl.TextSize = 16
	iconLbl.TextColor3 = color
	iconLbl.BackgroundTransparency = 1
	iconLbl.Size = UDim2.new(0, 28, 1, 0)
	iconLbl.Position = UDim2.new(0, 22, 0, 0)
	iconLbl.TextXAlignment = Enum.TextXAlignment.Center
	iconLbl.ZIndex = 51

	-- Title
	local titleLbl2 = Instance.new("TextLabel", toast)
	titleLbl2.Text = isErr and "Error" or "Success"
	titleLbl2.Font = Enum.Font.GothamBold
	titleLbl2.TextSize = 13
	titleLbl2.TextColor3 = Theme.TextPrimary
	titleLbl2.BackgroundTransparency = 1
	titleLbl2.Size = UDim2.new(1, -60, 0, 22)
	titleLbl2.Position = UDim2.new(0, 52, 0, 6)
	titleLbl2.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl2.ZIndex = 51

	-- Message
	local msgLbl = Instance.new("TextLabel", toast)
	msgLbl.Text = text
	msgLbl.Font = Enum.Font.Gotham
	msgLbl.TextSize = 11
	msgLbl.TextColor3 = Theme.TextSecond
	msgLbl.BackgroundTransparency = 1
	msgLbl.Size = UDim2.new(1, -60, 0, 18)
	msgLbl.Position = UDim2.new(0, 52, 0, 26)
	msgLbl.TextXAlignment = Enum.TextXAlignment.Left
	msgLbl.ZIndex = 51

	-- Progress bar bg
	local progBg = Instance.new("Frame", toast)
	progBg.Size = UDim2.new(1, 0, 0, 2)
	progBg.Position = UDim2.new(0, 0, 1, -2)
	progBg.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
	progBg.BorderSizePixel = 0
	progBg.ZIndex = 52
	addCorner(progBg, 2)

	-- Progress bar fill
	local progFill = Instance.new("Frame", progBg)
	progFill.Size = UDim2.new(1, 0, 1, 0)
	progFill.BackgroundColor3 = color
	progFill.BorderSizePixel = 0
	progFill.ZIndex = 53
	addCorner(progFill, 2)

	-- SLIDE IN from bottom
	local targetY = UDim2.new(0.5, 0, 0.5, -26)
	tw(toast, {Position = targetY}, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	-- Progress bar drain
	tw(progFill, {Size = UDim2.new(0, 0, 1, 0)}, 3.0, Enum.EasingStyle.Linear)

	-- SLIDE OUT after delay
	task.delay(3.0, function()
		tw(toast, {Position = UDim2.new(0.5, 0, 0, -60)}, 0.35, Enum.EasingStyle.Quint)
		task.delay(0.4, function()
			toast:Destroy()
			toastActive = false
		end)
	end)
end

-- DRAG
window.Draggable = true

-- MINIMIZE / CLOSE
local minimized = false
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		content.Visible = false
		tw(window, {Size = UDim2.new(0, WIN_W, 0, 42)}, 0.28, Enum.EasingStyle.Quint)
		minBtn.Text = "▢"
	else
		content.Visible = true
		tw(window, {Size = UDim2.new(0, WIN_W, 0, WIN_H)}, 0.32, Enum.EasingStyle.Back)
		minBtn.Text = "—"
	end
end)
closeBtn.MouseButton1Click:Connect(function()
	tw(window, {BackgroundTransparency = 1, Size = UDim2.new(0, WIN_W, 0, 0)}, 0.28, Enum.EasingStyle.Quint)
	task.delay(0.3, function() gui:Destroy() end)
end)



-- ITEM LOOP
local function getEquipped()
	local char = player.Character
	if not char then return nil end
	for _, v in pairs(char:GetChildren()) do
		if v:IsA("Tool") then return v end
	end
end

task.spawn(function()
	local last = ""
	while gui and gui.Parent do
		local tool = getEquipped()
		local name = tool and tool.Name or ""
		if name ~= last then
			last = name
			if name ~= "" then
				itemNameLbl.Text = name
				equippedTag.TextColor3 = Theme.AccentLight
				tw(statusDot, {BackgroundColor3 = Theme.Success}, 0.3)
				task.delay(1.2, function()
					tw(statusDot, {BackgroundColor3 = Theme.Accent}, 0.6)
				end)
			else
				itemNameLbl.Text = "No item equipped"
				equippedTag.TextColor3 = Theme.TextSecond
				tw(statusDot, {BackgroundColor3 = Color3.fromRGB(80, 80, 100)}, 0.3)
			end
		end
		task.wait(0.5)
	end
end)

-- REPLICATE
local function replicate(count)
	local tool = getEquipped()
	if not tool then
		notify("⚠  No item equipped!", true)
		return
	end
	for i = 1, count do
		local clone = tool:Clone()
		clone.Parent = player.Backpack
	end
	notify("✔  " .. tool.Name .. "  ×" .. count .. " replicated")
end

btn1.MouseButton1Click:Connect(function() replicate(1) end)
btn5.MouseButton1Click:Connect(function() replicate(5) end)
btn10.MouseButton1Click:Connect(function() replicate(10) end)

-- Subtle entrance (just fade in, no size anim)
window.BackgroundTransparency = 1
tw(window, {BackgroundTransparency = 0}, 0.35, Enum.EasingStyle.Quint)
