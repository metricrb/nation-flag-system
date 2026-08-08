--!strict

--[=[
	@class FlagPicker
	Client LocalScript. Opens a searchable ScreenGui when `OpenPicker` fires,
	and submits `RequestSetNation` on selection. Escape / dimmer closes the UI.
]=]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Nations = require(ReplicatedStorage:WaitForChild("NationFlagSystem"):WaitForChild("Nations"))
local remotes = ReplicatedStorage:WaitForChild("NationFlagSystem"):WaitForChild("Remotes")
local OpenPicker = remotes:WaitForChild("OpenPicker") :: RemoteEvent
local RequestSetNation = remotes:WaitForChild("RequestSetNation") :: RemoteEvent
local Notify = remotes:WaitForChild("Notify") :: RemoteEvent

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local activePoleId: string? = nil
local gui: ScreenGui? = nil
local listFrame: ScrollingFrame? = nil
local searchBox: TextBox? = nil
local statusLabel: TextLabel? = nil

local ROW_HEIGHT = 44

local function destroyGui()
	if gui then
		gui:Destroy()
		gui = nil
	end
	listFrame = nil
	searchBox = nil
	statusLabel = nil
end

local function closePicker()
	destroyGui()
	activePoleId = nil
end

local function setStatus(text: string)
	if statusLabel then
		statusLabel.Text = text
	end
end

local function clearRows()
	if not listFrame then
		return
	end
	for _, child in listFrame:GetChildren() do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
end

local function populate(query: string)
	if not listFrame then
		return
	end
	clearRows()

	local results = Nations.search(query)
	listFrame.CanvasSize = UDim2.fromOffset(0, #results * (ROW_HEIGHT + 4))

	for index, nation in results do
		local row = Instance.new("TextButton")
		row.Name = nation.id
		row.Size = UDim2.new(1, -12, 0, ROW_HEIGHT)
		row.Position = UDim2.fromOffset(6, (index - 1) * (ROW_HEIGHT + 4))
		row.BackgroundColor3 = if nation.inPassportAssets then Color3.fromRGB(36, 48, 64) else Color3.fromRGB(28, 28, 32)
		row.BorderSizePixel = 0
		row.AutoButtonColor = true
		row.Text = ""
		row.Parent = listFrame

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = row

		local flag = Instance.new("ImageLabel")
		flag.Name = "Flag"
		flag.BackgroundTransparency = 1
		flag.Size = UDim2.fromOffset(56, 32)
		flag.Position = UDim2.fromOffset(8, 6)
		flag.ScaleType = Enum.ScaleType.Fit
		flag.Image = nation.textureId
		flag.Active = false
		flag.Parent = row

		local nameLabel = Instance.new("TextLabel")
		nameLabel.BackgroundTransparency = 1
		nameLabel.Size = UDim2.new(1, -80, 1, 0)
		nameLabel.Position = UDim2.fromOffset(72, 0)
		nameLabel.Font = Enum.Font.GothamMedium
		nameLabel.TextSize = 16
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.TextColor3 = Color3.fromRGB(235, 235, 240)
		nameLabel.Text = nation.displayName .. "  (" .. nation.id .. ")"
		nameLabel.Active = false
		nameLabel.Parent = row

		local function selectNation()
			local poleId = activePoleId
			if not poleId then
				return
			end
			RequestSetNation:FireServer(poleId, nation.id)
			closePicker()
		end

		row.Activated:Connect(selectNation)
		row.MouseButton1Click:Connect(selectNation)
	end

	setStatus(string.format("%d nations", #results))
end

local function createGui()
	destroyGui()

	local screen = Instance.new("ScreenGui")
	screen.Name = "NationFlagPicker"
	screen.ResetOnSpawn = false
	screen.IgnoreGuiInset = true
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screen.Parent = playerGui
	gui = screen

	local dim = Instance.new("TextButton")
	dim.Name = "Dim"
	dim.Size = UDim2.fromScale(1, 1)
	dim.BackgroundColor3 = Color3.new(0, 0, 0)
	dim.BackgroundTransparency = 0.45
	dim.Text = ""
	dim.AutoButtonColor = false
	dim.ZIndex = 1
	dim.Parent = screen
	dim.Activated:Connect(closePicker)

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromOffset(420, 520)
	panel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	panel.BorderSizePixel = 0
	panel.Active = true
	panel.ZIndex = 2
	panel.Parent = screen

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 10)
	panelCorner.Parent = panel

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, -56, 0, 40)
	title.Position = UDim2.fromOffset(16, 8)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Color3.fromRGB(245, 245, 248)
	title.Text = "Select nation"
	title.ZIndex = 3
	title.Parent = panel

	local close = Instance.new("TextButton")
	close.Size = UDim2.fromOffset(32, 32)
	close.Position = UDim2.new(1, -40, 0, 10)
	close.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	close.TextColor3 = Color3.fromRGB(230, 230, 230)
	close.Font = Enum.Font.GothamBold
	close.TextSize = 18
	close.Text = "X"
	close.ZIndex = 3
	close.Parent = panel
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = close
	close.Activated:Connect(closePicker)

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -32, 0, 36)
	box.Position = UDim2.fromOffset(16, 52)
	box.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
	box.TextColor3 = Color3.fromRGB(240, 240, 245)
	box.PlaceholderText = "Search nations..."
	box.PlaceholderColor3 = Color3.fromRGB(140, 140, 150)
	box.Font = Enum.Font.Gotham
	box.TextSize = 16
	box.ClearTextOnFocus = false
	box.Text = ""
	box.ZIndex = 3
	box.Parent = panel
	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, 6)
	boxCorner.Parent = box
	searchBox = box

	local status = Instance.new("TextLabel")
	status.BackgroundTransparency = 1
	status.Size = UDim2.new(1, -32, 0, 20)
	status.Position = UDim2.fromOffset(16, 94)
	status.Font = Enum.Font.Gotham
	status.TextSize = 13
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.TextColor3 = Color3.fromRGB(160, 160, 170)
	status.Text = ""
	status.ZIndex = 3
	status.Parent = panel
	statusLabel = status

	local list = Instance.new("ScrollingFrame")
	list.Size = UDim2.new(1, -24, 1, -130)
	list.Position = UDim2.fromOffset(12, 118)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 6
	list.CanvasSize = UDim2.fromOffset(0, 0)
	list.ZIndex = 3
	list.Parent = panel
	listFrame = list

	box:GetPropertyChangedSignal("Text"):Connect(function()
		populate(box.Text)
	end)

	populate("")
	box:CaptureFocus()
end

OpenPicker.OnClientEvent:Connect(function(poleId: string, _currentNationId: string)
	activePoleId = poleId
	createGui()
end)

Notify.OnClientEvent:Connect(function(message: string)
	setStatus(message)
	local billboard = Instance.new("ScreenGui")
	billboard.Name = "NationFlagToast"
	billboard.ResetOnSpawn = false
	billboard.Parent = playerGui

	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 0)
	label.Position = UDim2.new(0.5, 0, 0, 72)
	label.Size = UDim2.fromOffset(360, 36)
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	label.BackgroundTransparency = 0.15
	label.TextColor3 = Color3.fromRGB(240, 240, 245)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 15
	label.Text = message
	label.Parent = billboard
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label

	task.delay(2.5, function()
		billboard:Destroy()
	end)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.Escape and gui then
		closePicker()
	end
end)
