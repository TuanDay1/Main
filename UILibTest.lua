----- Services -----
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

------------------------------------------------
local _env, _gethui, _httpget, _setclipboard, _toclipboard, _protectgui, CoreGui

if RunService:IsStudio() then -- Studio
	_env = {}
	_gethui = function() end
	_httpget = function() end
	_setclipboard = function() end
	_protectgui = function() end
	_toclipboard = function() end

	CoreGui = Players.LocalPlayer:WaitForChild("PlayerGui")
else
	_env = getgenv and getgenv() or {}
	_gethui = gethui or function() end
	_httpget = httpget or game.HttpGet or function() end
	_setclipboard = setclipboard or function() end
	_toclipboard = toclipboard or function() end
	_protectgui = protectgui or (syn and syn.protect_gui) or function() end

	CoreGui = _gethui() or game:GetService("CoreGui"):Clone()
end
------------------------------------------------

----- Variables -----
local Icons = {
	Exit = "rbxassetid://137369722592286",
	Minimize = "rbxassetid://127571985235169",
	Maximize = "rbxassetid://81910909428361",
	Clipboard = "rbxassetid://82888745753053",
}

local Themes = {
	Default = {
		-- MAIN
		TextColor = Color3.fromRGB(255, 205, 135),
		IconColor = Color3.fromRGB(255, 205, 135),
		FrameBackgroundColor = Color3.fromRGB(35, 48, 77),
		TopButtonColor = Color3.fromRGB(72, 99, 158),

		-- KEY SYSTEM
		KeySystem_TopBackground = Color3.fromRGB(23, 31, 50),

		KeySystem_ButtonColor = Color3.fromRGB(255, 205, 135),
		KeySystem_ButtonTextColor = Color3.fromRGB(0, 0, 0),

		KeySystem_KeyTextColor = Color3.fromRGB(116, 158, 255),
		KeySystem_PlaceholderColor = Color3.fromRGB(69, 95, 152),
		KeySystem_KeyBackground = Color3.fromRGB(31, 42, 68),
		KeySystem_BorderColor = Color3.fromRGB(116, 158, 255),
		KeySystem_Background = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#0c101a")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#212e47")),
		}),

		-- NOTIFICATION
		Notification_TopBackground = Color3.fromRGB(23, 31, 50),
		Notification_Background = Color3.fromRGB(25, 35, 54),
	},
}

local UILib = {
	Version = "3.0.0",
	Theme = Themes.Default,

	Windows = {},
	GuiObjects = {},
	Connections = {},
	Keybinds = {},

	Tabs = {},

	MinimizeKey = Enum.KeyCode.RightShift,
}

local LocalPlayer = Players.LocalPlayer
local LocalPlayerMouse = LocalPlayer:GetMouse()
local CurrentCamera = game.Workspace.CurrentCamera

local GameId = game.GameId

----- Hub Screen -----
function UILib:Protect_Gui(object)
	if _protectgui then
		_protectgui(object)
		object.Parent = CoreGui
	else
		object.Parent = CoreGui
	end
end

do
	local oldUI = CoreGui:FindFirstChild("NTC_UI")
	if oldUI then
		oldUI:Destroy()
	end
end

local HubScreen = Instance.new("ScreenGui")
HubScreen.Name = "NTC_UI"
HubScreen.DisplayOrder = math.random(10000, 99999)
HubScreen.IgnoreGuiInset = true
HubScreen.ResetOnSpawn = false
HubScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
UILib:Protect_Gui(HubScreen)
table.insert(UILib.Windows, HubScreen)

------------------------------------------------ Library Functions
function UILib:AddConnection(Signal, Function)
	if HubScreen.Parent ~= CoreGui then
		warn("Work")
		return
	end
	local SignalConnect = Signal:Connect(Function)
	table.insert(UILib.Connections, SignalConnect)
	return SignalConnect
end

function UILib:CreateObject(className: string, properties: table)
	local object = Instance.new(className)
	if properties then
		for index, value in pairs(properties) do
			if index ~= "Parent" then
				if typeof(value) == "Instance" then
					value.Parent = object
				else
					object[index] = value
				end
			end
		end

		object.Parent = properties.Parent
	end
	table.insert(UILib.GuiObjects, object)
	return object
end

function UILib:MakeDraggable(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos

		self:AddConnection(DragPoint.InputBegan, function(Input)
			if
				Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.Touch
			then
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position

				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
		self:AddConnection(DragPoint.InputChanged, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement then
				DragInput = Input
			end
		end)
		self:AddConnection(UserInputService.InputChanged, function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - MousePos
				Main.Position = UDim2.new(
					FramePos.X.Scale,
					FramePos.X.Offset + Delta.X,
					FramePos.Y.Scale,
					FramePos.Y.Offset + Delta.Y
				)
			end
		end)
	end)
end

function UILib:IsRunning()
	return HubScreen.Parent == CoreGui
end
function UILib:Hide()
	HubScreen.Enabled = not HubScreen.Enabled
end
function UILib:Destroy()
	for _, object in pairs(UILib.GuiObjects) do
		object:Destroy()
	end
	for _, connection in pairs(UILib.Connections) do
		connection:Disconnect()
	end
	HubScreen:Destroy()
end

function UILib:RegisterKeybind(key, callback)
	self.Keybinds[key] = callback
end
function UILib:RemoveKeybind(key)
	self.Keybinds[key] = nil
end

function UILib:Notify(title: string, message: string, data: string, value)
	if not self.Notification then
		return
	end
	local newNotification = self:CreateObject("CanvasGroup", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Parent = self.Notification,

		self:CreateObject("UICorner", {
			CornerRadius = UDim.new(0, 15),
		}),

		self:CreateObject("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 1, 6),
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = self.Theme.Notification_Background,
			BackgroundTransparency = 0,
		}),
	})

	local Notification_Top = self:CreateObject("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = self.Theme.Notification_TopBackground,
		BackgroundTransparency = 0,
		Parent = newNotification.Frame,

		self:CreateObject("Frame", {
			Size = UDim2.new(1, 0, 0, 2),
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = self.Theme.FrameBackgroundColor,
			BackgroundTransparency = 0,
		}),

		self:CreateObject("ImageLabel", {
			Size = UDim2.new(0, 18, 0, 18),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 8, 0.5, 0),
			BackgroundTransparency = 1,
			Image = self.Config.Icon,
			ImageColor3 = self.Theme.IconColor,
		}),

		self:CreateObject("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 0, 20),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 35, 0.5, 0),
			BackgroundTransparency = 1,
			RichText = true,
			TextWrapped = true,
			Text = string.format('%s <font color="#ffffff">[%s]</font>', self.Config.Name, title),
			TextColor3 = self.Theme.TextColor,
			FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			TextScaled = false,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
	})

	local Notification_Bottom = self:CreateObject("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, -20, 0, 0),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 35),
		BackgroundTransparency = 1,
		Parent = newNotification.Frame,

		self:CreateObject("Frame", {
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 1, 10),
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,

			self:CreateObject("TextBox", {
				ClearTextOnFocus = false,
				TextEditable = false,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.new(1, 0, 0, 0),
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1,
				RichText = true,
				TextWrapped = true,
				Text = message,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
				TextScaled = false,
				TextSize = 15,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
		}),
	})

	local connection = nil
	local function cleanup()
		if connection then
			connection:Disconnect()
		end

		local timeOutTween = TweenService:Create(
			newNotification,
			TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{
				GroupTransparency = 1,
			}
		)

		timeOutTween:Play()
		timeOutTween.Completed:Connect(function()
			newNotification:Destroy()
		end)
	end

	if data == "callback" then
		value()
		cleanup()
	elseif data == "pin" then
		local Notification_CloseButton = self:CreateObject("ImageButton", {
			Size = UDim2.new(0, 20, 0, 20),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			BackgroundTransparency = 1,
			Parent = Notification_Top,

			self:CreateObject("ImageLabel", {
				Size = UDim2.new(1, -8, 1, -8),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				BackgroundTransparency = 1,
				ImageColor3 = self.Theme.TopButtonColor,
				Image = Icons.Exit,
			}),
		})

		connection = Notification_CloseButton.Activated:Connect(cleanup)
	elseif data == "time" then
		local Notification_Time = self:CreateObject("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 20, 0, 20),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			BackgroundTransparency = 1,
			RichText = false,
			TextWrapped = true,
			Text = tostring(value),
			TextColor3 = Color3.fromRGB(72, 99, 158),
			FontFace = Font.fromName("Montserrat", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			TextScaled = false,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Center,

			Parent = Notification_Top,
		})

		task.spawn(function()
			for index = value, 0, -1 do
				if not newNotification then
					break
				end
				if not Notification_Time then
					break
				end
				Notification_Time.Text = string.format("%ss", index)
				task.wait(1)
			end
			cleanup()
		end)
	end
end

function UILib:CreateWindow(Config: table)
	local window = {}
	Config.Name = Config.Name or "Ngu Thi Chet"
	Config.Icon = Config.Icon or "rbxassetid://98285122013997"
	Config.SaveFolderName = Config.SaveFolderName or "NTC_HUB"
	Config.KeySystem = Config.KeySystem or {Enable = true, Keys = {}}
	Config.Discord = Config.Discord or ""
	self.Theme = (type(Config.Theme) == "string" and Themes[Config.Theme]) or Config.Theme or Themes.Default

	self.Config = Config

	if Config.AntiAFK then
		self:AddConnection(LocalPlayer.Idled, function()
			VirtualUser:Button2Down(Vector2.new(0, 0), CurrentCamera.CFrame)
			task.wait(1)
			VirtualUser:Button2Up(Vector2.new(0, 0), CurrentCamera.CFrame)
		end)
	end

	self.Notification = self:CreateObject("Frame", {
		Size = UDim2.new(0, 250, 1, -10),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -5, 1, -5),
		BackgroundTransparency = 1,
		Parent = HubScreen,

		self:CreateObject("UIListLayout", {
			Padding = UDim.new(0, 5),
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		}),
	})

	local EscMenuOpen = GuiService.MenuIsOpen
	self:AddConnection(GuiService.MenuOpened, function()
		EscMenuOpen = true
	end)
	self:AddConnection(GuiService.MenuClosed, function()
		EscMenuOpen = false
	end)
	self:AddConnection(UserInputService.InputBegan, function(input: InputObject, gameProcessedEvent: boolean)
		if gameProcessedEvent then
			return
		end
		if EscMenuOpen then
			return
		end
		local bind = self.Keybinds[input.KeyCode]
		if not bind then
			return
		end
		bind()
	end)

	if Config.KeySystem.Enable then
		local KeySystem_Config = {}

		local KeySystem_Canvas = self:CreateObject("CanvasGroup", {
			Size = UDim2.new(0, 350, 0, 250),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BackgroundTransparency = 1,
			Parent = HubScreen,

			self:CreateObject("UICorner", {
				CornerRadius = UDim.new(0, 20),
			}),
		})

		local KeySystem_MainFrame = self:CreateObject("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0,
			Parent = KeySystem_Canvas,

			self:CreateObject("UIGradient", {
				Color = self.Theme.KeySystem_Background,
				Rotation = 45,
			}),
		})

		local KeySystem_Top = self:CreateObject("Frame", {
			Size = UDim2.new(1, 0, 0, 45),
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = self.Theme.KeySystem_TopBackground,
			BackgroundTransparency = 0,
			Parent = KeySystem_MainFrame,

			self:CreateObject("Frame", {
				Size = UDim2.new(1, 0, 0, 2),
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 0, 1, 0),
				BackgroundColor3 = self.Theme.FrameBackgroundColor,
				BackgroundTransparency = 0,
			}),

			self:CreateObject("ImageLabel", {
				Size = UDim2.new(0, 20, 0, 20),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 15, 0.5, 0),
				BackgroundTransparency = 1,
				Image = Config.Icon,
				ImageColor3 = self.Theme.IconColor,
			}),

			self:CreateObject("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.new(0, 0, 0, 20),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 45, 0.5, 0),
				BackgroundTransparency = 1,
				RichText = true,
				TextWrapped = true,
				Text = string.format('%s <font color="#ffffff">[Key System]</font>', Config.Name),
				TextColor3 = self.Theme.TextColor,
				FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				TextScaled = false,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
		})

		local KeySystem_ExitButton = self:CreateObject("ImageButton", {
			Size = UDim2.new(0, 20, 0, 20),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -15, 0.5, 0),
			BackgroundTransparency = 1,
			Parent = KeySystem_Top,

			self:CreateObject("ImageLabel", {
				Size = UDim2.new(1, -8, 1, -8),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				BackgroundTransparency = 1,
				ImageColor3 = self.Theme.TopButtonColor,
				Image = Icons.Exit,
			}),
		})

		local KeySystem_MinimizeButton = self:CreateObject("ImageButton", {
			Size = UDim2.new(0, 20, 0, 20),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -45, 0.5, 0),
			BackgroundTransparency = 1,
			Parent = KeySystem_Top,

			self:CreateObject("ImageLabel", {
				Size = UDim2.new(1, -8, 1, -8),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				BackgroundTransparency = 1,
				ImageColor3 = self.Theme.TopButtonColor,
				Image = Icons.Minimize,
			}),
		})

		local KeySystem_Container = self:CreateObject("Frame", {
			Size = UDim2.new(1, 0, 0, 205),
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.new(0, 0, 0, 45),
			BackgroundTransparency = 1,
			Parent = KeySystem_MainFrame,

			self:CreateObject("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.None,
				Size = UDim2.new(1, 0, 0, 18),
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.new(0, 0, 0, 10),
				BackgroundTransparency = 1,
				RichText = false,
				TextWrapped = true,
				Text = "WELCOME TO",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				TextScaled = true,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Center,
			}),

			self:CreateObject("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.None,
				Size = UDim2.new(1, 0, 0, 20),
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.new(0, 0, 0, 30),
				BackgroundTransparency = 1,
				RichText = false,
				TextWrapped = true,
				Text = string.upper(Config.Name),
				TextColor3 = self.Theme.TextColor,
				FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				TextScaled = true,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Center,
			}),
		})

		local KeySystem_Key = self:CreateObject("Frame", {
			Size = UDim2.new(0, 265, 0, 35),
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.new(0, 20, 0, 65),
			BackgroundColor3 = self.Theme.KeySystem_KeyBackground,
			BackgroundTransparency = 0,
			Parent = KeySystem_Container,

			self:CreateObject("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),

			self:CreateObject("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 1,
				Color = self.Theme.KeySystem_BorderColor,
			}),
		})

		local KeySystem_TextBox = self:CreateObject("TextBox", {
			Size = UDim2.new(1, -15, 1, -15),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BackgroundTransparency = 1,
			Parent = KeySystem_Key,

			RichText = false,
			TextWrapped = true,
			PlaceholderColor3 = self.Theme.KeySystem_PlaceholderColor,
			PlaceholderText = "Insert your key here",
			Text = "",
			TextColor3 = self.Theme.KeySystem_KeyTextColor,
			FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextScaled = false,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
		})

		local KeySystem_PasteButton = self:CreateObject("ImageButton", {
			Size = UDim2.new(0, 35, 0, 35),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -20, 0, 65),
			BackgroundColor3 = self.Theme.KeySystem_KeyBackground,
			BackgroundTransparency = 0,
			Parent = KeySystem_Container,

			self:CreateObject("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),

			self:CreateObject("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 1,
				Color = self.Theme.KeySystem_BorderColor,
			}),

			self:CreateObject("ImageLabel", {
				Size = UDim2.new(0, 20, 0, 20),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				BackgroundTransparency = 1,
				ImageColor3 = self.Theme.KeySystem_BorderColor,
				Image = Icons.Clipboard,
			}),
		})

		local KeySystem_SubmitButton = self:CreateObject("TextButton", {
			Size = UDim2.new(0, 310, 0, 35),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 115),
			BackgroundColor3 = self.Theme.KeySystem_ButtonColor,
			BackgroundTransparency = 0,
			Parent = KeySystem_Container,

			RichText = false,
			TextWrapped = true,
			Text = "Submit",
			TextColor3 = self.Theme.KeySystem_ButtonTextColor,
			FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextScaled = false,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Center,

			self:CreateObject("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),
		})

		local KeySystem_SupportButton = self:CreateObject("TextButton", {
			Size = UDim2.new(1, 0, 0, 18),
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 165),
			BackgroundTransparency = 1,
			Parent = KeySystem_Container,

			RichText = true,
			TextWrapped = true,
			Text = 'Need support? <font color="#5165f6">Join the Discord</font>',
			TextColor3 = Color3.fromRGB(255, 255, 255),
			FontFace = Font.fromName("Montserrat", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			TextScaled = false,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Center,
		})

		self:MakeDraggable(KeySystem_Top, KeySystem_Canvas)

		KeySystem_Config.Minimize = false
		self:AddConnection(KeySystem_MinimizeButton.Activated, function()
			if not KeySystem_Config.Minimize then
				KeySystem_Config.Minimize = true
				KeySystem_MinimizeButton.ImageLabel.Image = Icons.Maximize
				TweenService:Create(KeySystem_Canvas, TweenInfo.new(0.2), {
					Size = UDim2.new(0, 350, 0, 45),
				}):Play()
			else
				KeySystem_Config.Minimize = false
				KeySystem_MinimizeButton.ImageLabel.Image = Icons.Minimize
				TweenService:Create(KeySystem_Canvas, TweenInfo.new(0.2), {
					Size = UDim2.new(0, 350, 0, 250),
				}):Play()
			end
		end)

		self:AddConnection(KeySystem_ExitButton.Activated, function()
			self:Destroy()
		end)

		self:AddConnection(KeySystem_SupportButton.Activated, function()
			_setclipboard(Config.Discord)
			self:Notify("Discord", "The Discord server link has been copied to your clipboard", "time", 5)
		end)

		self:AddConnection(KeySystem_PasteButton.Activated, function()
			local text = _toclipboard()
			if text then
				KeySystem_TextBox.Text = text
			end
		end)

		self:AddConnection(KeySystem_SubmitButton.Activated, function()
			warn("Work")
			local text = KeySystem_TextBox.Text
			if Config.KeySystem.Keys[text] then
				self:Notify("Key System", "Key valid!", "time", 5)
			else
				self:Notify("Key System", "Invalid key!", "time", 10)
			end
		end)
	end

	return window
end

return UILib
