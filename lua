local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local Theme = {
	Background   = Color3.fromRGB(22, 22, 28),
	Surface      = Color3.fromRGB(30, 30, 40),
	SurfaceHover = Color3.fromRGB(45, 45, 58),
	Accent       = Color3.fromRGB(120, 100, 255),
	AccentLight  = Color3.fromRGB(160, 140, 255),
	Success      = Color3.fromRGB(80, 220, 140),
	Error        = Color3.fromRGB(235, 75, 75),
	TextPrimary  = Color3.fromRGB(240, 240, 255),
	TextSecond   = Color3.fromRGB(160, 160, 185),
	Border       = Color3.fromRGB(50, 50, 70),
	TopBar       = Color3.fromRGB(18, 18, 24),
}

local function tw(obj, props, t, style, dir)
	TweenService:Create(obj, TweenInfo.new(t or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props):Play()
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

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "KoonsReplicatorV2"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999

local success, _ = pcall(function()
	gui.Parent = game:GetService("CoreGui")
end)
if not success then gui.Parent = player:WaitForChild("PlayerGui") end

local WIN_W, WIN_H = 380, 460

local window = Instance.new("Frame", gui)
window.Name = "Window"
window.Size = UDim2.new(0, WIN_W, 0, WIN_H)
window.Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
window.BackgroundColor3 = Theme.Background
window.BorderSizePixel = 0
addCorner(window, 14)
addStroke(window, Theme.Border, 1.4)

-- Shadow
local shadow = Instance.new("ImageLabel", window)
shadow.Size = UDim2.new(1, 80, 1, 80)
shadow.Position = UDim2.new(0.5, 0, 0.5, 10)
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://6014261993"
shadow.ImageColor3 = Color3.fromRGB(0,0,0)
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(49,49,450,450)
shadow.ZIndex = 0

-- Top Bar
local topBar = Instance.new("Frame", window)
topBar.Size = UDim2.new(1, 0, 0, 48)
topBar.BackgroundColor3 = Theme.TopBar
addCorner(topBar, 14)
local topFix = Instance.new("Frame", topBar)
topFix.Size = UDim2.new(1,0,0.5,0)
topFix.Position = UDim2.new(0,0,0.5,0)
topFix.BackgroundColor3 = Theme.TopBar

local title = Instance.new("TextLabel", topBar)
title.Text = "ITEM REPLICATOR"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Theme.TextPrimary
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.TextXAlignment = Enum.TextXAlignment.Left

local by = Instance.new("TextLabel", topBar)
by.Text = "by Koons"
by.Font = Enum.Font.Gotham
by.TextSize = 11
by.TextColor3 = Theme.TextSecond
by.BackgroundTransparency = 1
by.Size = UDim2.new(0, 80, 1, 0)
by.Position = UDim2.new(1, -100, 0, 0)
by.TextXAlignment = Enum.TextXAlignment.Right

-- Close Button
local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -40, 0.5, -16)
closeBtn.BackgroundColor3 = Theme.Error
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
addCorner(closeBtn, 8)
closeBtn.MouseButton1Click:Connect(function()
	tw(window, {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}, 0.35)
	task.delay(0.4, function() gui:Destroy() end)
end)

-- Content
local content = Instance.new("Frame", window)
content.Size = UDim2.new(1, -24, 1, -70)
content.Position = UDim2.new(0, 12, 0, 58)
content.BackgroundTransparency = 1

-- Tool Selection
local searchBox = Instance.new("TextBox", content)
searchBox.Size = UDim2.new(1, 0, 0, 36)
searchBox.BackgroundColor3 = Theme.Surface
searchBox.PlaceholderText = "Search tool..."
searchBox.Text = ""
searchBox.TextColor3 = Theme.TextPrimary
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14
searchBox.ClearTextOnFocus = false
addCorner(searchBox, 10)
addStroke(searchBox, Theme.Border, 1)

local toolList = Instance.new("ScrollingFrame", content)
toolList.Size = UDim2.new(1, 0, 0, 160)
toolList.Position = UDim2.new(0, 0, 0, 46)
toolList.BackgroundColor3 = Theme.Surface
toolList.ScrollBarThickness = 6
toolList.ScrollBarImageColor3 = Theme.Accent
addCorner(toolList, 10)
addStroke(toolList, Theme.Border, 1)

local listLayout = Instance.new("UIListLayout", toolList)
listLayout.Padding = UDim.new(0, 4)
listLayout.SortOrder = Enum.SortOrder.Name

local selectedTool = nil
local toolButtons = {}

local function refreshTools(filter)
	for _, v in pairs(toolButtons) do v:Destroy() end
	toolButtons = {}

	local tools = {}
	for _, v in pairs(player.Backpack:GetChildren()) do
		if v:IsA("Tool") and (not filter or v.Name:lower():find(filter:lower())) then
			table.insert(tools, v)
		end
	end
	local equipped = player.Character and player.Character:FindFirstChildOfClass("Tool")
	if equipped and (not filter or equipped.Name:lower():find(filter:lower())) then
		table.insert(tools, equipped)
	end

	for _, tool in ipairs(tools) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -8, 0, 42)
		btn.BackgroundColor3 = Theme.SurfaceHover
		btn.Text = "  " .. tool.Name
		btn.TextColor3 = Theme.TextPrimary
		btn.Font = Enum.Font.GothamMedium
		btn.TextSize = 14
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.BackgroundTransparency = (selectedTool == tool) and 0.3 or 1
		addCorner(btn, 8)
		btn.Parent = toolList

		btn.MouseButton1Click:Connect(function()
			selectedTool = tool
			refreshTools(searchBox.Text)
		end)

		table.insert(toolButtons, btn)
	end
	toolList.CanvasSize = UDim2.new(0,0,0, listLayout.AbsoluteContentSize.Y + 10)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	refreshTools(searchBox.Text)
end)

-- Multipliers
local multipliers = {1, 5, 10, 25, 50, 100}

local multFrame = Instance.new("Frame", content)
multFrame.Size = UDim2.new(1, 0, 0, 110)
multFrame.Position = UDim2.new(0, 0, 0, 220)
multFrame.BackgroundTransparency = 1

local grid = Instance.new("UIGridLayout", multFrame)
grid.CellSize = UDim2.new(0, 68, 0, 48)
grid.CellPadding = UDim2.new(0, 8, 0, 8)
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center

for _, count in ipairs(multipliers) do
	local btn = Instance.new("TextButton", multFrame)
	btn.BackgroundColor3 = Theme.Surface
	btn.Text = "×" .. count
	btn.TextColor3 = Theme.AccentLight
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 18
	addCorner(btn, 10)
	addStroke(btn, Theme.Accent, 1.2)

	btn.MouseEnter:Connect(function() tw(btn, {BackgroundColor3 = Theme.SurfaceHover}, 0.15) end)
	btn.MouseLeave:Connect(function() tw(btn, {BackgroundColor3 = Theme.Surface}, 0.15) end)

	btn.MouseButton1Click:Connect(function()
		if not selectedTool then return end
		for i = 1, count do
			local clone = selectedTool:Clone()
			clone.Parent = player.Backpack
		end
		notify("Replicated " .. selectedTool.Name .. " ×" .. count, false)
	end)
end

-- Custom Amount
local customFrame = Instance.new("Frame", content)
customFrame.Size = UDim2.new(1, 0, 0, 50)
customFrame.Position = UDim2.new(0, 0, 0, 340)
customFrame.BackgroundTransparency = 1

local customBox = Instance.new("TextBox", customFrame)
customBox.Size = UDim2.new(0.6, -5, 1, 0)
customBox.Position = UDim2.new(0, 0, 0, 0)
customBox.PlaceholderText = "Custom amount"
customBox.BackgroundColor3 = Theme.Surface
customBox.TextColor3 = Theme.TextPrimary
addCorner(customBox, 10)

local replicateBtn = Instance.new("TextButton", customFrame)
replicateBtn.Size = UDim2.new(0.4, -5, 1, 0)
replicateBtn.Position = UDim2.new(0.6, 5, 0, 0)
replicateBtn.BackgroundColor3 = Theme.Accent
replicateBtn.Text = "REPLICATE"
replicateBtn.TextColor3 = Color3.new(1,1,1)
replicateBtn.Font = Enum.Font.GothamBold
addCorner(replicateBtn, 10)

replicateBtn.MouseButton1Click:Connect(function()
	if not selectedTool then 
		notify("No tool selected!", true)
		return 
	end
	local amount = tonumber(customBox.Text)
	if not amount or amount < 1 then 
		notify("Invalid amount!", true)
		return 
	end
	
	for i = 1, amount do
		local clone = selectedTool:Clone()
		clone.Parent = player.Backpack
	end
	notify("Replicated " .. selectedTool.Name .. " ×" .. amount, false)
end)

-- Notification Function
function notify(text, isError)
	local toast = Instance.new("Frame", gui)
	toast.Size = UDim2.new(0, 320, 0, 60)
	toast.Position = UDim2.new(0.5, -160, 0.8, 0)
	toast.BackgroundColor3 = isError and Theme.Error or Theme.Success
	toast.BackgroundTransparency = 0.1
	addCorner(toast, 12)
	-- (full toast code shortened for space - same quality as before)

	-- Simple version for now
	local label = Instance.new("TextLabel", toast)
	label.Size = UDim2.new(1,0,1,0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.new(1,1,1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	tw(toast, {Position = UDim2.new(0.5, -160, 0.75, 0)}, 0.4)
	task.delay(2.8, function()
		tw(toast, {Position = UDim2.new(0.5, -160, 1, 50)}, 0.4)
		task.delay(0.5, function() toast:Destroy() end)
	end)
end

-- Initial Setup
window.BackgroundTransparency = 1
tw(window, {BackgroundTransparency = 0}, 0.4)

refreshTools("")
player.Backpack.ChildAdded:Connect(function() task.delay(0.3, refreshTools) end)
player.Backpack.ChildRemoved:Connect(function() task.delay(0.3, refreshTools) end)

if player.Character then
	player.Character.ChildAdded:Connect(function() task.delay(0.3, refreshTools) end)
end

print(" Koons Replicator V2 Loaded!")
