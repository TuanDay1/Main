----- Services -----
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local RenderStepped = RunService.RenderStepped

------------------------------------------------
local _env = getgenv and getgenv() or {}
local _gethui = gethui or function () end
local _httpget = httpget or game.HttpGet or function () end
local _setclipboard = setclipboard or function () end

local CoreGui = _gethui() or game:GetService("CoreGui"):Clone()

------------------------------------------------
local FileManager = loadstring(_httpget(game, "https://raw.githubusercontent.com/TuanDay1/Main/refs/heads/main/Library/FileManager.lua"))()
------------------------------------------------

----- Variables -----
local DefaultTheme = {
    Name = "Ngu Thi Chet",
    Logo = "rbxassetid://98285122013997",

    TextColor = Color3.fromRGB(255, 205, 135),
    LogoColor = Color3.fromRGB(255, 205, 135),
    ButtonColor = Color3.fromRGB(255, 205, 135),
    ButtonTextColor = Color3.fromRGB(9, 13, 21),
    KeyPlaceholderTextColor = Color3.fromRGB(44, 64, 103),
    StrokeColor = Color3.fromRGB(36, 53, 83),
    KeyBackground = Color3.fromRGB(19, 27, 43),
    Background = Color3.fromRGB(9, 13, 21),
    SideImageColor = Color3.fromRGB(38, 55, 88),
    SideImageColor2 = Color3.fromRGB(255, 205, 135),
    SliderColor = Color3.fromRGB(25, 38, 58),
}

local UILib = {
	Version = "2.0.0",
    Theme = DefaultTheme,

	GuiObjects = {},
    Connections = {},
    Keybinds = {},

    Window = nil,
    WindowKey = nil,
    WindowNotification = nil,
    WindowDebug = nil,
    MinimizeButton = nil,

    Tabs = {},

	MinimizeKey = Enum.KeyCode.RightShift,
}

local player = Players.LocalPlayer
local playerMouse = player:GetMouse()
local gameId = game.GameId

local fileName = nil
local tabTweening = false

----- Hub Screen -----
local function protect_gui(object)
    local _protectgui = protectgui or (syn and syn.protect_gui)
    if _protectgui then
        _protectgui(object)
        object.Parent = CoreGui
    else
        object.Parent = CoreGui
    end
end

do
    local oldButtonGui = CoreGui:FindFirstChild(UILib.Theme.Name.." Button")
    if oldButtonGui then
        oldButtonGui:Destroy()
    end
    local oldNotificationGui = CoreGui:FindFirstChild(UILib.Theme.Name.." Notification")
    if oldNotificationGui then
        oldNotificationGui:Destroy()
    end
    local oldDebugGui = CoreGui:FindFirstChild(UILib.Theme.Name.." Debug")
    if oldDebugGui then
        oldDebugGui:Destroy()
    end
    local oldGui = CoreGui:FindFirstChild(UILib.Theme.Name)
    if oldGui then
        oldGui:Destroy()
    end
end

local HubScreen = Instance.new("ScreenGui")
HubScreen.Name = UILib.Theme.Name
HubScreen.DisplayOrder = math.random(10000,99999)
HubScreen.IgnoreGuiInset = true
HubScreen.ResetOnSpawn = false
protect_gui(HubScreen)

------------------------------------------------ Local Functions
local function AddConnection(Signal, Function)
	if not HubScreen.Parent == CoreGui then return end
	local SignalConnect = Signal:Connect(Function)
	table.insert(UILib.Connections, SignalConnect)
	return SignalConnect
end
local function MakeDraggable(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos
		AddConnection(DragPoint.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
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
		AddConnection(DragPoint.InputChanged, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement then
				DragInput = Input
			end
		end)
		AddConnection(UserInputService.InputChanged, function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - MousePos
				Main.Position  = UDim2.new(FramePos.X.Scale,FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
			end
		end)
	end)
end
local function Create(className, Properties)
	local object = Instance.new(className)
	if Properties then
		for index, value in pairs(Properties) do
			if index ~= "Parent" then
				if typeof(value) == "Instance" then
					value.Parent = object
				else
					object[index] = value
				end
			end
		end

		object.Parent = Properties.Parent
	end
    table.insert(UILib.GuiObjects, object)
	return object
end
local function itemContainerResize(itemContainer)
    if itemContainer:FindFirstChild("UIListLayout") then
        local UIListLayout = itemContainer.UIListLayout
        itemContainer.CanvasSize = UDim2.new(0,0,0,UIListLayout.AbsoluteContentSize.Y)
    end
end
local function autoContainerResize(itemContainer)
    AddConnection(itemContainer.ChildAdded, function()
        itemContainerResize(itemContainer)
    end)
    AddConnection(itemContainer.ChildRemoved, function()
        itemContainerResize(itemContainer)
    end)

    itemContainerResize(itemContainer)
end
local function setupConfig(saveFolder: string)
	fileName = string.format("%s//%s_%s.json", saveFolder, player.Name, gameId)

	if _env.Config == nil then
		local readFile = FileManager:ReadFile(fileName, "table")
		if readFile then
			_env.Config = readFile
		else
			_env.Config = {}
		end
	end

	FileManager:GetFolder(saveFolder)
    FileManager:GetFile(fileName, _env.Config)
end

------------------------------------------------ Init
local EscMenuOpen = GuiService.MenuIsOpen
AddConnection(GuiService.MenuOpened, function()
    EscMenuOpen = true
end)
AddConnection(GuiService.MenuClosed, function()
    EscMenuOpen = false
end)
AddConnection(UserInputService.InputBegan, function(input: InputObject, gameProcessedEvent: boolean)
    if not gameProcessedEvent or EscMenuOpen then
        local bind = UILib.Keybinds[input.KeyCode]
        if bind then
            bind()
        end
    end
end)
AddConnection(player.Idled, function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

------------------------------------------------ Functions
function UILib:IsRunning()
    return HubScreen.Parent == CoreGui
end
function UILib:Destroy()
    for _, object in pairs(UILib.GuiObjects) do
        object:Destroy()
    end
	HubScreen:Destroy()
end
function UILib:Hide()
    HubScreen.Enabled = not HubScreen.Enabled
end
function UILib:RegisterKeybind(key, callback)
	self.Keybinds[key] = callback
end
function UILib:RemoveKeybind(key)
	self.Keybinds[key] = nil
end

function UILib:CreateWindow(gameName: string, saveFolder: string)
    local window = {}

    local NotificationScreen = Instance.new("ScreenGui")
    NotificationScreen.Name = UILib.Theme.Name.." Notification"
    NotificationScreen.DisplayOrder = math.random(10000,99999)
    NotificationScreen.IgnoreGuiInset = true
    NotificationScreen.ResetOnSpawn = false
    protect_gui(NotificationScreen)

	self.WindowNotification = Create("Frame", {
        Size = UDim2.new(0,250,1,-10),
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1,-5,1,-5),
        BackgroundTransparency = 1,
        Parent = NotificationScreen,

        Create("UIListLayout", {
            Padding = UDim.new(0, 5),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
        })
    })

    self.WindowKey = Create("CanvasGroup", {
        Size = UDim2.fromOffset(278, 118),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundColor3 = self.Theme.Background,
        Parent = HubScreen,

        Create("UICorner", {
            CornerRadius = UDim.new(0, 15),
        }),

        -- TOP
        Create("Frame", {
            Name = "Top",
            Size = UDim2.new(1, 0, 0, 35),
            Position = UDim2.fromScale(0, 0),
            BackgroundTransparency = 1,
            ZIndex = 2,

            Create("ImageLabel", {
                Size = UDim2.new(0, 20, 0, 20),
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, 15, 1, 0),
                Image = self.Theme.Logo,
                ImageColor3 = self.Theme.LogoColor,
                ImageTransparency = 0,
                BackgroundTransparency = 1,
                ZIndex = 3,
            }),

            Create("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.new(0, 0, 0, 20),
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, 45, 1, 0),
                RichText = true,
                Text = string.format('%s <font color="#ffffff">[Key]</font>', self.Theme.Name),
                TextColor3 = self.Theme.TextColor,
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                ZIndex = 3,
            }),
        }),

        -- CONTAINER
        Create("Frame", {
            Name = "Container",
            Size = UDim2.new(1, 0, 1, -35),
            Position = UDim2.fromOffset(0, 35),
            BackgroundTransparency = 1,
            ZIndex = 2,

            Create("CanvasGroup", {
                Size = UDim2.new(1, -20, 0, 25),
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, 10),
                BackgroundColor3 = self.Theme.KeyBackground,
                ZIndex = 3,

                Create("TextBox", {
                    Size = UDim2.new(1, -5, 1, -5),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    PlaceholderText = "Nhập mã tại đây",
                    PlaceholderColor3 = self.Theme.KeyPlaceholderTextColor,
                    RichText = false,
                    Text = "",
                    TextColor3 = self.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    BackgroundTransparency = 1,
                    ZIndex = 4,
                }),
            }),

            Create("TextButton", {
                Size = UDim2.new(1, -20, 0, 20),
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.new(0.5, 0, 1, -15),
                BackgroundColor3 = self.Theme.ButtonColor,
                Text = "",
                ZIndex = 3,

                Create("UICorner", {
                    CornerRadius = UDim.new(0, 5),
                }),

                Create("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2.fromScale(1, 1),
                    AnchorPoint = Vector2.new(0, 0),
                    Position = UDim2.fromScale(0, 0),
                    RichText = false,
                    Text = "Sao chép để lấy mã",
                    TextColor3 = self.Theme.ButtonTextColor,
                    FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    BackgroundTransparency = 1,
                    ZIndex = 4,
                }),
            }),
        }),
    })

    MakeDraggable(self.WindowKey.Top, self.WindowKey)

    local bypass = false

    local KeyTextBox = self.WindowKey.Container.CanvasGroup.TextBox
    AddConnection(KeyTextBox.FocusLost, function()
        local emptyCheck = KeyTextBox.Text:gsub("%s","")
        if #emptyCheck == 0 then return end

        if string.lower(KeyTextBox.Text) == string.lower("uilibv2debug") then
            bypass = true
        else
            self:Notify("Key", "Mã không hợp lệ, vui lòng nhập lại", nil, 5)
        end
    end)

    local CopyButton = self.WindowKey.Container.TextButton
    AddConnection(CopyButton.MouseButton1Click, function()
        _setclipboard("uilibv2debug")
        self:Notify("Key", "Đã sao chép đường dẫn vào bộ nhớ tạm của bạn", nil, 5)
    end)

    repeat
        RenderStepped:Wait()
    until bypass == true
    self.WindowKey.Visible = false

    setupConfig(saveFolder)

    -------------------------------------------------------------------------
    local DebugScreen = Instance.new("ScreenGui")
    DebugScreen.Name = UILib.Theme.Name.." Debug"
    DebugScreen.DisplayOrder = math.random(10000,99999)
    DebugScreen.IgnoreGuiInset = true
    DebugScreen.ResetOnSpawn = false
    protect_gui(DebugScreen)

    self.WindowDebug = Create("CanvasGroup", {
        Size = UDim2.fromOffset(245, 85),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.12),
        BackgroundColor3 = self.Theme.Background,
        BackgroundTransparency = 0.3,
        Parent = DebugScreen,

        Create("UICorner", {
            CornerRadius = UDim.new(0, 10),
        }),

        Create("Frame", {
            Name = "Top",
            Size = UDim2.new(1, 0, 0, 35),
            Position = UDim2.fromScale(0, 0),
            BackgroundTransparency = 1,
            ZIndex = 2,

            Create("ImageLabel", {
                Size = UDim2.new(0, 15, 0, 15),
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 10, 0.5, 0),
                Image = self.Theme.Logo,
                ImageColor3 = self.Theme.LogoColor,
                ImageTransparency = 0,
                BackgroundTransparency = 1,
                ZIndex = 3,
            }),

            Create("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.new(0, 0, 0, 15),
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 35, 0.5, 0),
                RichText = true,
                Text = string.format('%s <font color="#ffffff">[Debug]</font>', self.Theme.Name),
                TextColor3 = self.Theme.TextColor,
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                ZIndex = 3,
            }),
        }),

        -- CONTAINER
        Create("Frame", {
            Name = "Container",
            Size = UDim2.new(1, 0, 1, -35),
            Position = UDim2.fromOffset(0, 35),
            BackgroundTransparency = 1,
            ZIndex = 2,

            Create("TextLabel", {
                Name = "Info1",
                Size = UDim2.new(1, 0, 0, 12),
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 0, 0, 13),
                RichText = false,
                Text = "FPS: N/A | Ping: N/A",
                TextColor3 = self.Theme.TextColor,
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Center,
                BackgroundTransparency = 1,
                ZIndex = 3,
            }),

            Create("TextLabel", {
                Name = "Info2",
                Size = UDim2.new(1, 0, 0, 12),
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 0, 0, 32),
                RichText = false,
                Text = "TIME PLAYED: N/A",
                TextColor3 = self.Theme.TextColor,
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Center,
                BackgroundTransparency = 1,
                ZIndex = 3,
            }),
        }),
    })

    task.spawn(function()
        local startTime = tick()
        while task.wait(0.1) do
            if not self:IsRunning() then break end
            pcall(function()
                local elapsedTime = tick() - startTime
                local hours = math.floor(elapsedTime / 3600)
                local minutes = math.floor((elapsedTime % 3600) / 60)
                local seconds = math.floor(elapsedTime % 60)

                local timeFormatted = string.format("%02d:%02d:%02d", hours, minutes, seconds)
                local fps = math.floor(workspace:GetRealPhysicsFPS())
                local ping = tonumber(Stats.Network.ServerStatsItem["Data Ping"]:GetValueString():match("%d+"))
    
                self.WindowDebug.Container.Info1.Text = string.format("FPS: %s | PING: %sms", fps, ping)
                self.WindowDebug.Container.Info2.Text = string.format("TIME PLAYED: %s", timeFormatted)
            end)
        end
    end)

    self.Window = Create("CanvasGroup", {
        Size = UDim2.fromOffset(530, 308),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundColor3 = self.Theme.Background,
        Parent = HubScreen,

        Create("UICorner", {
            CornerRadius = UDim.new(0, 15),
        }),

        -- TOP
        Create("Frame", {
            Name = "Top",
            Size = UDim2.new(1, 0, 0, 35),
            Position = UDim2.fromScale(0, 0),
            BackgroundTransparency = 1,
            ZIndex = 2,

            Create("ImageLabel", {
                Size = UDim2.new(0, 20, 0, 20),
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, 15, 1, 0),
                Image = self.Theme.Logo,
                ImageColor3 = self.Theme.LogoColor,
                ImageTransparency = 0,
                BackgroundTransparency = 1,
                ZIndex = 3,
            }),

            Create("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.new(0, 0, 0, 20),
                AnchorPoint = Vector2.new(0, 1),
                Position = UDim2.new(0, 45, 1, 0),
                RichText = true,
                Text = string.format('%s <font color="#ffffff">[%s]</font>', self.Theme.Name, gameName),
                TextColor3 = self.Theme.TextColor,
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                ZIndex = 3,
            }),
        }),

        -- CONTAINER
        Create("Frame", {
            Name = "Container",
            Size = UDim2.new(1, 0, 1, -35),
            Position = UDim2.fromOffset(0, 35),
            BackgroundTransparency = 1,
            ZIndex = 2,

            -- SIDE
            Create("Frame", {
                Name = "Side",
                Size = UDim2.new(0, 140, 1, 0),
                Position = UDim2.fromScale(0, 0),
                BackgroundTransparency = 1,
                ZIndex = 3,
                
                Create("ScrollingFrame", {
                    Size = UDim2.new(1, -20, 1, -20),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    CanvasSize = UDim2.fromScale(0, 0),
                    ScrollBarImageTransparency = 0,
                    ScrollingDirection = Enum.ScrollingDirection.Y,
                    BackgroundTransparency = 1,
                    ZIndex = 4,
                    
                    Create("UIListLayout", {
                        Padding = UDim.new(0, 5),
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    }),
                }),
            }),

            --MAIN
            Create("Frame", {
                Name = "Main",
                Size = UDim2.new(0, 390, 1, 0),
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.fromScale(1, 0),
                BackgroundTransparency = 1,
                ZIndex = 3,

                Create("Frame", {
                    Size = UDim2.new(1, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 1),
                    Position = UDim2.fromScale(0.5, 1),
                    BackgroundColor3 = self.Theme.Background,
                    Visible = false,
                    ZIndex = 6,

                    Create("UIGradient", {
                        Color = ColorSequence.new(Color3.fromRGB(255,255,255)),
                        Rotation = -90,
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0,0),
                            NumberSequenceKeypoint.new(1,1),
                        })
                    }),
                }),
            }),
        })
    })

    local MinimizeButtonScreen = Instance.new("ScreenGui")
    MinimizeButtonScreen.Name = UILib.Theme.Name.." Button"
    MinimizeButtonScreen.DisplayOrder = math.random(10000,99999)
    MinimizeButtonScreen.IgnoreGuiInset = true
    MinimizeButtonScreen.ResetOnSpawn = false
    protect_gui(MinimizeButtonScreen)

    self.MinimizeButton = Create("ImageButton", {
        Size = UDim2.new(0,50,0,50),
        Position = UDim2.new(0.041,0,0.77,0),
        BackgroundColor3 = self.Theme.Background,
        BackgroundTransparency = 0.15,
        Image = "",
        Parent = MinimizeButtonScreen,

        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),

        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = self.Theme.StrokeColor,
            Thickness = 2,
        }),

        Create("ImageLabel", {
            Size = UDim2.new(0,22,0,22),
            AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.new(0.5,0,0.5,0),
            BackgroundTransparency = 1,
            Image = self.Theme.Logo,
            ImageColor3 = self.Theme.LogoColor,
            ZIndex = 2,
        }),
    })

    -------------------------------------------------------------------------
    MakeDraggable(self.WindowDebug.Top, self.WindowDebug)
    MakeDraggable(self.Window.Top, self.Window)
    MakeDraggable(self.MinimizeButton, self.MinimizeButton)

    self:Hide()

    self:RegisterKeybind(self.MinimizeKey, function()
        self:Hide()
    end)

    AddConnection(self.MinimizeButton.MouseButton1Click, function()
        self:Hide()
    end)

    task.spawn(function()
        self:Notify(string.format("v%s", self.Version), "Giao diện sẽ tự động ẩn, bạn có thể bật nó bằng cách nhấn vào biểu tượng trên màn hình.", function()
            repeat
                RenderStepped:Wait()
            until HubScreen.Enabled == true
        end)
    end)
    -------------------------------------------------------------------------

    function window:CreateTab(tabName: string, imageId: string)
        local tab = {}

        local SideUI = UILib.Window.Container.Side.ScrollingFrame
        local tabUI = Create("CanvasGroup", {
            Name = tabName,
            Size = UDim2.new(1, 0, 0, 30),
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.fromScale(0, 0),
            BackgroundColor3 = UILib.Theme.KeyBackground,
            BackgroundTransparency = 1,
            Parent = SideUI,
            ZIndex = 5,

            Create("UICorner", {
                CornerRadius = UDim.new(0, 5),
            }),

            Create("CanvasGroup", {
                Size = UDim2.new(0, 3, 0, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.fromScale(0, 0.5),
                BackgroundColor3 = UILib.Theme.SideImageColor2,
                BackgroundTransparency = 1,
                ZIndex = 6,

                Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                }),
            }),

            Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                AnchorPoint = Vector2.new(0, 0),
                Position = UDim2.fromScale(0, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 8,
            }),

            Create("ImageLabel", {
                Size = UDim2.new(0, 10, 0, 10),
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 12, 0.5, 0),
                BackgroundTransparency = 1,
                Image = imageId,
                ImageColor3 = UILib.Theme.SideImageColor,
                ZIndex = 6,
            }),

            Create("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.new(0, 0, 0, 15),
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 30, 0.5, 0),
                BackgroundTransparency = 1,
                RichText = false,
                Text = tabName,
                TextColor3 = UILib.Theme.SideImageColor,
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 6,
            }),

            Create("Frame", {
                Size = UDim2.new(0.65, 0, 1, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                BackgroundColor3 = UILib.Theme.Background,
                ZIndex = 7,

                Create("UIGradient", {
                    Color = ColorSequence.new(Color3.fromRGB(255,255,255)),
                    Rotation = 0,
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0,0.75),
                        NumberSequenceKeypoint.new(1,0),
                    }),
                }),
            }),
        })
        table.insert(UILib.Tabs, tabUI)

        AddConnection(tabUI.TextButton.MouseButton1Click, function()
            UILib:SelectTab(tabName)
        end)

        local MainUI = UILib.Window.Container.Main
        local tabList = Create("ScrollingFrame", {
            Name = tabName,
            Size = UDim2.new(1, -20, 1, -20),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            CanvasSize = UDim2.fromScale(0, 0),
            ScrollBarImageTransparency = 0,
            ScrollBarThickness = 0,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            BackgroundTransparency = 1,
            ZIndex = 4,
            Visible = false,
            Parent = MainUI,
            
            Create("UIListLayout", {
                Padding = UDim.new(0, 5),
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
            }),
        })
        autoContainerResize(tabList)

        function tab:Toggle(toggleTitle: string, toggleDesc: string, defaultValue: boolean, callback)
            local toggleUI = Create("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1, 0, 0, 0),
                AnchorPoint = Vector2.new(0, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = UILib.Theme.KeyBackground,
                Parent = tabList,
                ZIndex = 5,

                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                }),

                Create("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Size = UDim2.new(1, 0, 1, 12),
                    AnchorPoint = Vector2.new(0, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    ZIndex = 6,
                }),

                Create("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Size = UDim2.new(1, -20, 0, 0),
                    AnchorPoint = Vector2.new(0, 0),
                    Position = UDim2.new(0, 10, 0, 8),
                    BackgroundTransparency = 1,
                    RichText = true,
                    Text = toggleTitle,
                    TextColor3 = UILib.Theme.TextColor,
                    FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 7,
                }),

                Create("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Size = UDim2.new(1, -90, 0, 0),
                    AnchorPoint = Vector2.new(0, 0),
                    Position = UDim2.new(0, 10, 0, 25),
                    BackgroundTransparency = 1,
                    RichText = true,
                    Text = toggleDesc,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 7,
                }),

                Create("CanvasGroup", {
                    Size = UDim2.new(1, -320, 0, 20),
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -10, 1, -20),
                    BackgroundColor3 = UILib.Theme.Background,
                    BackgroundTransparency = 0,
                    ZIndex = 7,

                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 5),
                    }),

                    Create("TextButton", {
                        Size = UDim2.new(1, 0, 1, 0),
                        AnchorPoint = Vector2.new(0, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundTransparency = 1,
                        Text = "",
                        ZIndex = 10,
                    }),

                    Create("Frame", {
                        Size = UDim2.new(0, 20, 0, 20),
                        AnchorPoint = Vector2.new(0, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundTransparency = 1,
                        ZIndex = 8,

                        Create("Frame", {
                            Size = UDim2.new(1, -5, 1, -5),
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.new(0.5, 0, 0.5, 0),
                            BackgroundColor3 = UILib.Theme.KeyBackground,
                            ZIndex = 9,

                            Create("UICorner", {
                                CornerRadius = UDim.new(0, 2),
                            }),
                        }),
                    }),
                }),
            })

            local toggleButton = toggleUI.CanvasGroup.TextButton

            local active = defaultValue
            local function oMouseButton1Click()
                if self.toggling then
                    return
                end
                self.toggling = true
                active = not active

                if active == true then
                    TweenService:Create(toggleUI.CanvasGroup.Frame, TweenInfo.new(0.3), {
                        Position = UDim2.new(0, 30, 0, 0)
                    }):Play()
                    TweenService:Create(toggleUI.CanvasGroup.Frame.Frame, TweenInfo.new(0.3), {
                        BackgroundColor3 = UILib.Theme.ButtonColor
                    }):Play()
                else
                    TweenService:Create(toggleUI.CanvasGroup.Frame, TweenInfo.new(0.3), {
                        Position = UDim2.new(0, 0, 0, 0)
                    }):Play()
                    TweenService:Create(toggleUI.CanvasGroup.Frame.Frame, TweenInfo.new(0.3), {
                        BackgroundColor3 = UILib.Theme.KeyBackground
                    }):Play()
                end

                if callback then
                    callback(active)
                end

                self.toggling = false
            end
            AddConnection(toggleButton.MouseButton1Click, oMouseButton1Click)
            active = not active
            oMouseButton1Click()

            task.spawn(function()
                if callback then
                    callback(active)
                end
            end)
        end

        function tab:Slider(sliderTitle: string, defaultValue: number, minValue: number, maxValue: number, callback)
            local sliderUI = Create("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1, 0, 0, 0),
                AnchorPoint = Vector2.new(0, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = UILib.Theme.KeyBackground,
                Parent = tabList,
                ZIndex = 5,

                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                }),

                Create("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Size = UDim2.new(1, -20, 0, 0),
                    AnchorPoint = Vector2.new(0, 0),
                    Position = UDim2.new(0, 10, 0, 8),
                    BackgroundTransparency = 1,
                    RichText = true,
                    Text = sliderTitle,
                    TextColor3 = UILib.Theme.TextColor,
                    FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6,
                }),

                Create("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Size = UDim2.new(1, 0, 1, 12),
                    AnchorPoint = Vector2.new(0, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    ZIndex = 6,
                }),

                Create("Frame", {
                    Name = "Box",
                    Size = UDim2.new(1, -290, 0, 25),
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -10, 0, 5),
                    BackgroundColor3 = UILib.Theme.Background,
                    ZIndex = 6,

                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                    }),
    
                    Create("TextBox", {
                        Size = UDim2.new(1, -20, 1, 0),
                        AnchorPoint = Vector2.new(0.5, 0),
                        Position = UDim2.fromScale(0.5, 0),
                        FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                        PlaceholderText = "0",
                        PlaceholderColor3 = UILib.Theme.TextColor,
                        RichText = false,
                        Text = "",
                        TextColor3 = UILib.Theme.TextColor,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        BackgroundTransparency = 1,
                        ZIndex = 7,
                    }),
                }),

                Create("CanvasGroup", {
                    Size = UDim2.new(1, -20, 0, 9),
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.new(0.5, 0, 0, 35),
                    BackgroundColor3 = UILib.Theme.Background,
                    BackgroundTransparency = 0,
                    ZIndex = 6,

                    Create("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                    }),

                    Create("Frame", {
                        Size = UDim2.new(0, 0, 1, 0),
                        AnchorPoint = Vector2.new(0, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundColor3 = UILib.Theme.SliderColor,
                        ZIndex = 7,

                        Create("UICorner", {
                            CornerRadius = UDim.new(1, 0),
                        }),
                    }),

                    Create("TextButton", {
                        Size = UDim2.new(1, 0, 1, 0),
                        AnchorPoint = Vector2.new(0, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundTransparency = 1,
                        Text = "",
                        ZIndex = 8,
                    }),
                }),
            })

            local sliderButton = sliderUI.CanvasGroup.TextButton
            local sliderTextBox = sliderUI.Box.TextBox

            local outputValue = 0
            local lastValue
            local function updateSlider(value)
                local output 
                if value ~= nil then
                    output = (value - minValue) / (maxValue - minValue)
                else
                    output = math.clamp(((Vector2.new(playerMouse.X, playerMouse.Y) - sliderUI.CanvasGroup.AbsolutePosition) / sliderUI.CanvasGroup.AbsoluteSize).X,0,1)
                end

                local outputClamped = minValue + (output*(maxValue-minValue))

                if outputValue ~= outputClamped then
                    TweenService:Create(sliderUI.CanvasGroup.Frame, TweenInfo.new(0.25, Enum.EasingStyle.Exponential), {
                        Size = UDim2.fromScale(output, 1)
                    }):Play()
                end

                outputValue = outputClamped
                sliderTextBox.Text = tostring(math.round(outputValue))

                if lastValue ~= math.round(outputValue) then
                    lastValue = math.round(outputValue)

                    if callback ~= nil then
                        callback(math.round(outputValue))
                    end
                end
            end

            updateSlider(defaultValue)
            local sliderActive = false
            local function activateSlider()
                sliderActive = true
                TweenService:Create(sliderUI.CanvasGroup.Frame, TweenInfo.new(0.2), {
                    BackgroundColor3 = UILib.Theme.TextColor
                }):Play()
                while sliderActive do
                    updateSlider()
                    task.wait()
                end
            end

            AddConnection(sliderButton.MouseButton1Down, activateSlider)
            AddConnection(UserInputService.InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if not UILib:IsRunning() then return end
                    sliderActive = false
                    TweenService:Create(sliderUI.CanvasGroup.Frame, TweenInfo.new(0.2), {
                        BackgroundColor3 = UILib.Theme.SliderColor
                    }):Play()
                end
            end)
            AddConnection(sliderTextBox:GetPropertyChangedSignal("Text"), function()
                if not tonumber(sliderTextBox.Text) then
                    sliderTextBox.Text = ""
                end
            end)
            AddConnection(sliderTextBox.FocusLost, function()
                if tonumber(sliderTextBox.Text) > maxValue then
                    sliderTextBox.Text = tostring(maxValue)
                    updateSlider(maxValue)
                else
                    updateSlider(tonumber(sliderTextBox.Text))
                end
            end)
        end

        function tab:TextBox(textBoxTitle: string, textBoxButtonText: string, textBoxPlaceholder: string, callback)
            local textBoxUI = Create("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1, 0, 0, 0),
                AnchorPoint = Vector2.new(0, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = UILib.Theme.KeyBackground,
                Parent = tabList,
                ZIndex = 5,

                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                }),

                Create("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Size = UDim2.new(1, -20, 0, 0),
                    AnchorPoint = Vector2.new(0, 0),
                    Position = UDim2.new(0, 10, 0, 8),
                    BackgroundTransparency = 1,
                    RichText = true,
                    Text = textBoxTitle,
                    TextColor3 = UILib.Theme.TextColor,
                    FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6,
                }),

                Create("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Size = UDim2.new(1, 0, 1, 12),
                    AnchorPoint = Vector2.new(0, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    ZIndex = 6,
                }),

                Create("CanvasGroup", {
                    Size = UDim2.new(1, -120, 0, 25),
                    AnchorPoint = Vector2.new(0, 0),
                    Position = UDim2.new(0, 8, 0, 27),
                    BackgroundColor3 = UILib.Theme.Background,
                    ZIndex = 6,

                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                    }),

                    Create("TextBox", {
                        Size = UDim2.new(1, -20, 1, 0),
                        AnchorPoint = Vector2.new(0.5, 0),
                        Position = UDim2.fromScale(0.5, 0),
                        FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        PlaceholderText = textBoxPlaceholder,
                        PlaceholderColor3 = UILib.Theme.KeyBackground,
                        RichText = false,
                        Text = "",
                        TextColor3 = UILib.Theme.TextColor,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        ZIndex = 7,
                    }),
                }),

                Create("TextButton", {
                    Size = UDim2.new(0.23, 0, 0, 25),
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -8, 0, 27),
                    BackgroundColor3 = UILib.Theme.ButtonColor,
                    Text = "",
                    ZIndex = 6,
    
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                    }),
    
                    Create("TextLabel", {
                        AutomaticSize = Enum.AutomaticSize.X,
                        Size = UDim2.fromScale(1, 0.5),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.fromScale(0, 0.5),
                        RichText = false,
                        Text = textBoxButtonText,
                        TextColor3 = UILib.Theme.ButtonTextColor,
                        FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        TextScaled = true,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        BackgroundTransparency = 1,
                        ZIndex = 7,
                    }),
                }),
            })

            local textBox = textBoxUI.CanvasGroup.TextBox
            local textBoxButton = textBoxUI.TextButton

            AddConnection(textBoxButton.MouseButton1Click, function()
                if callback ~= nil then
                    callback(textBox.Text)
                end
            end)
        end

        function tab:Button(buttonText: string, callback)
            local buttonUI = Create("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1, 0, 0, 0),
                AnchorPoint = Vector2.new(0, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = UILib.Theme.KeyBackground,
                Parent = tabList,
                ZIndex = 5,

                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                }),

                Create("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Size = UDim2.new(1, 0, 1, 12),
                    AnchorPoint = Vector2.new(0, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    ZIndex = 6,
                }),

                Create("TextButton", {
                    Size = UDim2.new(1, -20, 0, 21),
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.new(0.5, 0, 0, 10),
                    BackgroundColor3 = UILib.Theme.ButtonColor,
                    Text = "",
                    ZIndex = 6,
    
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                    }),
    
                    Create("TextLabel", {
                        Size = UDim2.fromScale(1, 0.6),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.fromScale(0, 0.5),
                        RichText = false,
                        Text = buttonText,
                        TextColor3 = UILib.Theme.ButtonTextColor,
                        FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        TextScaled = true,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        BackgroundTransparency = 1,
                        ZIndex = 7,
                    }),
                }),
            })

            local TextButton = buttonUI.TextButton
            AddConnection(TextButton.MouseButton1Click, function()
                if callback ~= nil then
                    callback()
                end
            end)
        end

        function tab:Dropdown(dropdownText: string, dropdownItems: table, callback)
            local dropdownUI = Create("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                Size = UDim2.new(1, 0, 0, 0),
                AnchorPoint = Vector2.new(0, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = UILib.Theme.KeyBackground,
                Parent = tabList,
                ZIndex = 5,

                Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                }),

                Create("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Size = UDim2.new(1, 0, 1, 12),
                    AnchorPoint = Vector2.new(0, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    ZIndex = 6,
                }),

                Create("TextButton", {
                    Size = UDim2.new(1, -20, 0, 23),
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.new(0.5, 0, 0, 10),
                    BackgroundColor3 = UILib.Theme.ButtonColor,
                    Text = "",
                    ZIndex = 6,
    
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                    }),

                    Create("TextLabel", {
                        Size = UDim2.new(1, -60, 0.6, 0),
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 10, 0.5, 0),
                        RichText = false,
                        Text = dropdownText,
                        TextColor3 = UILib.Theme.ButtonTextColor,
                        FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        TextScaled = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        ZIndex = 7,
                    }),

                    Create("ImageLabel", {
                        Size = UDim2.new(0, 15, 0, 15),
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, -10, 0.5, 0),
                        BackgroundTransparency = 1,
                        Image = "rbxassetid://18630017208",
                        ImageColor3 = UILib.Theme.ButtonTextColor,
                        Rotation = -90,
                        ZIndex = 7,
                    }),
                }),

                Create("Frame", {
                    Name = "Container",
                    Size = UDim2.new(1,-20,0,0),
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.new(0.5,0,0,35),
                    BackgroundColor3 = UILib.Theme.Background,
                    Visible = false,
                    ZIndex = 6,

                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                    }),

                    Create("ScrollingFrame", {
                        Size = UDim2.new(1,-20,1,-20),
                        AnchorPoint = Vector2.new(0.5, 0),
                        Position = UDim2.new(0.5,0,0,10),
                        BackgroundTransparency = 1,
                        ScrollingDirection = Enum.ScrollingDirection.Y,
                        ScrollBarThickness = 6,
                        ScrollBarImageColor3 = UILib.Theme.SideImageColor,
                        BottomImage = "",
                        TopImage = "",
                        CanvasSize = UDim2.new(0,0,0,0),
                        ZIndex = 7,
    
                        Create("UIListLayout", {
                            Padding = UDim.new(0, 1),
                            FillDirection = Enum.FillDirection.Vertical
                        })
                    }),
                }),
            })

            local TextButton = dropdownUI.TextButton
            local Container = dropdownUI.Container
            local ScrollingFrame = Container.ScrollingFrame

            local function resize()
                if ScrollingFrame:FindFirstChild("UIListLayout") then
                    local UIListLayout = ScrollingFrame.UIListLayout
                    ScrollingFrame.CanvasSize = UDim2.new(0,0,0,UIListLayout.AbsoluteContentSize.Y) 
                end
            end
            AddConnection(ScrollingFrame.ChildAdded, function(child: Instance)
                if child:IsA("TextButton") then
                    resize()
                end
            end)
            AddConnection(ScrollingFrame.ChildRemoved, function(child: Instance)
                if child:IsA("TextButton") then
                    resize()
                end
            end)

            local dropdownTweening = false
            AddConnection(TextButton.MouseButton1Click, function()
                local ImageLabel = TextButton.ImageLabel
                if dropdownTweening then return end
                dropdownTweening = true

                if ImageLabel.Rotation == -90 then
                    local imageTween = TweenService:Create(ImageLabel, TweenInfo.new(0.25), {
                        Rotation = 0,
                    })
                    imageTween:Play()
                    Container.Visible = true
                    local frameTween = TweenService:Create(Container, TweenInfo.new(0.25), {
                        Size = UDim2.new(1,-20,0,100)
                    })
                    frameTween:Play()
                    frameTween.Completed:Wait()
                else
                    local imageTween = TweenService:Create(ImageLabel, TweenInfo.new(0.25), {
                        Rotation = -90,
                    })
                    imageTween:Play()
                    local frameTween = TweenService:Create(Container, TweenInfo.new(0.25), {
                        Size = UDim2.new(1,-20,0,0)
                    })
                    frameTween:Play()
                    frameTween.Completed:Wait()
                    Container.Visible = false
                end
                itemContainerResize(tabList)
                dropdownTweening = false
            end)

            local buttonSelect = ""
            for _, buttonName in pairs(dropdownItems) do
                local button = Create("TextButton", {
                    Size = UDim2.new(1,0,0,20),
                    Position = UDim2.new(0,0,0,0),
                    BackgroundTransparency = 1,
                    RichText = true,
                    FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    Text = buttonName,
                    TextSize = 14,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    ZIndex = 8,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ScrollingFrame
                })

                AddConnection(button.MouseButton1Click, function()
                    if callback ~= nil then
                        if buttonSelect == buttonName then
                            TextButton.TextLabel.Text = dropdownText
                            callback("")
                        else
                            buttonSelect = buttonName
                            TextButton.TextLabel.Text = string.format("%s %s", dropdownText, buttonName)
                            callback(buttonName)
                        end
                    end
                end)
            end
            itemContainerResize(tabList)
        end

        return tab
    end

    return window, fileName
end

function UILib:SelectTab(tabName: string)
    task.spawn(function()
        if tabTweening == true then return end
        tabTweening = true
        
        local SideUI = UILib.Window.Container.Side.ScrollingFrame
        local MainUI = UILib.Window.Container.Main
        
        local tabFrame = SideUI:FindFirstChild(tabName)
        if not tabFrame then return end
    
        if table.find(self.Tabs, tabFrame) then
    
            for _, object in pairs(SideUI:GetChildren()) do
                if object:IsA("CanvasGroup") then
                    if object.CanvasGroup.BackgroundTransparency == 0 then
                        TweenService:Create(object.CanvasGroup, TweenInfo.new(0.3), {
                            Size = UDim2.new(0, 3, 0, 0),
                            BackgroundTransparency = 1,
                        }):Play()
    
                        TweenService:Create(object.ImageLabel, TweenInfo.new(0.3), {
                            ImageColor3 = self.Theme.SideImageColor,
                        }):Play()
    
                        TweenService:Create(object.TextLabel, TweenInfo.new(0.3), {
                            TextColor3 = self.Theme.SideImageColor,
                        }):Play()
    
                        TweenService:Create(object, TweenInfo.new(0.3), {
                            BackgroundTransparency = 1,
                        }):Play()
    
                        object.Frame.Visible = true

                        local tabList = MainUI:FindFirstChild(object.Name)
                        if tabList then
                            tabList.Visible = false
                        end
                        break
                    end
                end
            end
    
            TweenService:Create(tabFrame.CanvasGroup, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 3, 0.6, 0),
                BackgroundTransparency = 0,
            }):Play()
    
            TweenService:Create(tabFrame.ImageLabel, TweenInfo.new(0.3), {
                ImageColor3 = self.Theme.SideImageColor2,
            }):Play()
    
            TweenService:Create(tabFrame.TextLabel, TweenInfo.new(0.3), {
                TextColor3 = self.Theme.SideImageColor2,
            }):Play()
    
            local lastTween = TweenService:Create(tabFrame, TweenInfo.new(0.3), {
                BackgroundTransparency = 0,
            })
            lastTween:Play()
    
            tabFrame.Frame.Visible = false

            local tabList = MainUI:FindFirstChild(tabName)
            if tabList then
                tabList.Visible = true
            end
    
            lastTween.Completed:Wait()
        end
        tabTweening = false
    end)
end

function UILib:Notify(title: string, message: string, callback, timeOut: number)
    local newNotification = Create("Frame", {
        Size = UDim2.new(1,0,0,0),
        Position = UDim2.new(0,0,0,0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = self.WindowNotification,

        Create("Frame", {
            Name = "Container",
            Size = UDim2.new(1,0,1,6),
            Position = UDim2.new(0,0,0,0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(26, 26, 26),

            Create("UICorner", {
                CornerRadius = UDim.new(0, 4)
            }),

            Create("Frame", {
                Name = "Top",
                Size = UDim2.new(1,0,0,25),
                Position = UDim2.new(0,0,0,5),
                BackgroundTransparency = 1,

                Create("ImageLabel", {
                    Size = UDim2.new(0,20,0,20),
                    Position = UDim2.new(0,10,0.5,0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    Image = self.Theme.Logo,
                    ImageColor3 = self.Theme.LogoColor,
                }),

                Create("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2.new(0,0,0,20),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0,40,0.5,0),
                    BackgroundTransparency = 1,
                    FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    RichText = true,
                    Text = title and string.format('%s <font color="#ffffff">[%s]</font>', self.Theme.Name, title) or self.Theme.Name,
                    TextColor3 = self.Theme.TextColor,
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
            }),

            Create("Frame", {
                Name = "Bottom",
                Size = UDim2.new(1,-25,0,0),
                Position = UDim2.new(0,10,0,30),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,

                Create("TextLabel", {
                    Name = "Message",
                    Size = UDim2.new(1,-30,1,0),
                    Position = UDim2.new(0,0,0,0),
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    RichText = true,
                    FontFace = Font.fromName("Montserrat", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                    Text = message,
                    TextSize = 15,
                    TextWrapped = true,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextXAlignment = Enum.TextXAlignment.Left,
                }),

                Create("Frame", {
                    Name = "Time",
                    Size = UDim2.new(0,20,0,20),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1,0,0.5,0),
                    BackgroundTransparency = 1,

                    Create("TextLabel", {
                        Size = UDim2.new(1,0,1,0),
                        Position = UDim2.new(0,0,0,0),
                        BackgroundTransparency = 1,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        FontFace = Font.fromName("Montserrat", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        Text = "0",
                        TextSize = 14,
                        TextColor3 = self.Theme.TextColor,
                        TextXAlignment = Enum.TextXAlignment.Center,

                        Create("Frame", {
                            Size = UDim2.new(1,4,1,4),
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.new(0.5,0,0.5,0),
                            BackgroundTransparency = 1,

                            -- Left
                            Create("Frame", {
                                Name = "L",
                                Size = UDim2.new(0.5,0,1,0),
                                Position = UDim2.new(0,0,0,0),
                                BackgroundTransparency = 1,
                                ClipsDescendants = true,

                                Create("ImageLabel", {
                                    Name = "Circle",
                                    Size = UDim2.new(2,0,1,0),
                                    Position = UDim2.new(0,0,0,0),
                                    BackgroundTransparency = 1,
                                    Image = "http://www.roblox.com/asset/?id=483229625",
                                    ImageColor3 = self.Theme.TextColor,
    
                                    Create("UIGradient", {
                                        Color = ColorSequence.new(Color3.fromRGB(255,255,255)),
                                        Rotation = 180,
                                        Transparency = NumberSequence.new({
                                            NumberSequenceKeypoint.new(0,0),
                                            NumberSequenceKeypoint.new(0.499,0),
                                            NumberSequenceKeypoint.new(0.5,1),
                                            NumberSequenceKeypoint.new(1,1),
                                        })
                                    })
                                }),
                            }),

                            -- Right
                            Create("Frame", {
                                Name = "R",
                                Size = UDim2.new(0.5,0,1,0),
                                AnchorPoint = Vector2.new(1, 0),
                                Position = UDim2.new(1,0,0,0),
                                BackgroundTransparency = 1,
                                ClipsDescendants = true,

                                Create("ImageLabel", {
                                    Name = "Circle",
                                    Size = UDim2.new(2,0,1,0),
                                    AnchorPoint = Vector2.new(1, 0),
                                    Position = UDim2.new(1,0,0,0),
                                    BackgroundTransparency = 1,
                                    Image = "http://www.roblox.com/asset/?id=483229625",
                                    ImageColor3 = self.Theme.TextColor,
    
                                    Create("UIGradient", {
                                        Color = ColorSequence.new(Color3.fromRGB(255,255,255)),
                                        Rotation = 0,
                                        Transparency = NumberSequence.new({
                                            NumberSequenceKeypoint.new(0,0),
                                            NumberSequenceKeypoint.new(0.499,0),
                                            NumberSequenceKeypoint.new(0.5,1),
                                            NumberSequenceKeypoint.new(1,1),
                                        })
                                    })
                                })
                            })
                        })
                    })
                })
            })
        })
    })

	local BottomFrame = newNotification.Container.Bottom

	local NumberValue = Instance.new("NumberValue", newNotification)
	NumberValue.Name = math.random(666, 999)
	NumberValue.Value = 100

	local notifyConnection = AddConnection(NumberValue:GetPropertyChangedSignal("Value"), function()
		local rotation = math.floor(math.clamp(NumberValue.Value * 3.6, 0, 360))

		BottomFrame.Time.TextLabel.Frame.R.Circle.UIGradient.Rotation =
			math.clamp(rotation, 0, 180)
        BottomFrame.Time.TextLabel.Frame.L.Circle.UIGradient.Rotation =
			math.clamp(rotation, 180, 360)
	end)

	if callback ~= nil then
		BottomFrame.Time.Visible = false
		callback()
	else
        local timeOutTween = TweenService:Create(
            NumberValue,
            TweenInfo.new(timeOut, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            {
                Value = 0
            }
        )
        timeOutTween:Play()
        task.spawn(function()
            for i = timeOut, 0, -1 do
                if newNotification == nil then break end
                if not BottomFrame:FindFirstChild("Time") then break end
                BottomFrame.Time.TextLabel.Text = tostring(i)
                task.wait(1)
            end
        end)
        timeOutTween.Completed:Wait()
	end

    notifyConnection:Disconnect()
	newNotification:Destroy()
end

return UILib