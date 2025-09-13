------------------------------------------------
local _env = getgenv and getgenv() or {}
local _gethui = gethui or function() end
local _httpget = httpget or game.HttpGet or function() end
local _httprequest = http_request or request or HttpPost or syn.request or function() end
local _setclipboard = setclipboard or function() end
local _hookmetamethod = hookmetamethod or function() end
local _getnamecallmethod = getnamecallmethod or function() end

------------------------------------------------
local UILib =
	loadstring(_httpget(game, "https://raw.githubusercontent.com/TuanDay1/Main/refs/heads/main/Library/UILib.lua"))()
local FileManager = loadstring(
	_httpget(game, "https://raw.githubusercontent.com/TuanDay1/Main/refs/heads/main/Library/FileManager.lua")
)()
task.spawn(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Anti-Kick/refs/heads/main/Anti-Kick.lua"))()
end)
------------------------------------------------

----- Services -----
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

----------Variables----------
local player = Players.LocalPlayer
local playerGui = player.PlayerGui

local ChestSkinsFolder = ReplicatedStorage:WaitForChild("ChestSkins")

local Chest1Skins = {}
local Chest1SkinDecals = require(ChestSkinsFolder.Chest1.SkinData).Decals
for _, value in pairs(Chest1SkinDecals) do
    local formattedName = string.format("%s - %s", value.Image, value.Rarity)
    table.insert(Chest1Skins, formattedName)
end

local Chest2Skins = {}
local Chest2SkinDecals = require(ChestSkinsFolder.Chest2.SkinData).Tags
for _, value in pairs(Chest2SkinDecals) do
    table.insert(Chest2Skins, value.Id)
end

-- Game Remotes
local AddOwnedSkinRemote = ReplicatedStorage:WaitForChild("AddOwnedSkin")
local SellSkinEventRemote = ReplicatedStorage:WaitForChild("SellSkinEvent")
local AwardAchievementRemote = ReplicatedStorage:WaitForChild("AwardAchievement")
local AnswerResultRemote = ReplicatedStorage:WaitForChild("AnswerResult")

local QuestionGui = playerGui:WaitForChild("QuestionGui")
local QuestionFrame = QuestionGui:WaitForChild("QuestionFrame")

----------------------------------------------------------
local window, fileName = UILib:CreateWindow("Guess Vietnamese Songs", "NTCHub")

local function updateSettting(index, value)
	local keys = string.split(index, "/")
	local current = _env.Config

	if #keys == 1 then
		current[index] = value
	else
		for i = 1, #keys - 1 do
			if current[keys[i]] == nil then
				current[keys[i]] = {}
			end
			current = current[keys[i]]
		end
		local finalKey = keys[#keys]
		current[finalKey] = value
	end

	if index == "Auto Save" or _env.Config["Auto Save"] then
		FileManager:WriteFile(fileName, _env.Config)
	end
end

function ColorConverter(color)
	local r = math.floor(color.R * 255 + 0.5)
	local g = math.floor(color.G * 255 + 0.5)
	local b = math.floor(color.B * 255 + 0.5)
	return (r * 65536) + (g * 256) + b
end

function FormatNumber(number: number)
	local formatted = tostring(number):reverse():gsub("(%d%d%d)", "%1,"):reverse()

	if formatted:sub(1, 1) == "," then
		formatted = formatted:sub(2)
	end
	return formatted
end

--[[

     __   __     ______   ______   
    /\ "-.\ \   /\__  _\ /\  ___\  
    \ \ \-.  \  \/_/\ \/ \ \ \____ 
     \ \_\\"\_\    \ \_\  \ \_____\
      \/_/ \/_/     \/_/   \/_____/

]]
--

GuiService.ErrorMessageChanged:Connect(function()
	if GuiService:GetErrorCode() == Enum.ConnectionError.DisconnectLuaKick then
		if _env.Config["Auto Rejoin"] then
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
			return
		end
	end
end)

RunService.Heartbeat:Connect(function()
	if _env.Config["Auto Score"] and _env.Config["Auto Score"]["Enable"] then
        local SkinId = _env.Config["Auto Score"]["Skin"] or "rbxassetid://113186515754759"
		AddOwnedSkinRemote:FireServer(SkinId)
        task.wait()
        SellSkinEventRemote:FireServer(SkinId, 1)
	end
end)

QuestionFrame:GetPropertyChangedSignal("Visible"):Connect(function()
    if not QuestionFrame.Visible then return end
    if _env.Config["Auto Win"] then
        QuestionFrame.Visible = false
        task.wait(math.random(0.8, 1.2))
        AnswerResultRemote:FireServer("Correct")
    end
end)

---------------------------------------------------------- MAIN
local main_Tab = window:CreateTab("Chính", "rbxassetid://113518381337162")
UILib:SelectTab("Chính")

main_Tab:Dropdown(
    "Chọn vật phẩm để tự cộng Score:",
    Chest1Skins,
    function(value: string)
        if value == "" then return end
        local splitString = string.split(value, " - ")
        local skinName = splitString[1]
        updateSettting("Auto Score/Skin", skinName)
    end
)

main_Tab:Toggle(
	"Tự động cộng Score",
	"Tự động cộng Score",
	_env.Config["Auto Score"] and _env.Config["Auto Score"]["Enable"] or false,
	function(value: boolean)
		updateSettting("Auto Score/Enable", value)
	end
)

main_Tab:Toggle(
	"Tự động thắng",
	"Tự động thắng",
	_env.Config["Auto Win"] or false,
	function(value: boolean)
		updateSettting("Auto Win", value)
	end
)

---------------------------------------------------------- ITEMS
local item_Tab = window:CreateTab("Vật phẩm", "rbxassetid://113518381337162")

item_Tab:Dropdown(
    "Lấy vật phẩm 1",
    Chest1Skins,
    function(value: string)
        if value == "" then return end
        local splitString = string.split(value, " - ")
        local skinName = splitString[1]
        AddOwnedSkinRemote:FireServer(skinName)
         UILib:Notify("Items", string.format("Bạn đã lấy thành công vật phẩm: %s", skinName), nil, 3)
    end
)

item_Tab:Dropdown(
    "Lấy vật phẩm 2",
    Chest2Skins,
    function(value: string)
        if value == "" then return end
        AwardAchievementRemote:FireServer(value)
        UILib:Notify("Items", string.format("Bạn đã lấy thành công vật phẩm: %s", value), nil, 3)
    end
)

---------------------------------------------------------- MORE
local more_Tab = window:CreateTab("Thêm", "rbxassetid://113518381337162")
more_Tab:Toggle(
	"Tự động tham gia lại (Bị đuổi)",
	"Tự động tham gia lại nếu như bị trò chơi đuổi",
	_env.Config["Auto Rejoin"] or false,
	function(value: boolean)
		updateSettting("Auto Rejoin", value)
	end
)
local function rejoinTimer()
	while _env.Config["Rejoin Timer"].Enable do
		task.wait(_env.Config["Rejoin Timer"].Minute * 60)
		if _env.Config["Rejoin Timer"].Enable == false then
			break
		end
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
	end
end

more_Tab:Toggle(
	"Tự động tham gia lại (Thời gian)",
	"Tự động tham gia lại sau khi đã hết thời gian đã đặt trước đó",
	(_env.Config["Rejoin Timer"] and _env.Config["Rejoin Timer"]["Enable"]) or false,
	function(value: boolean)
		updateSettting("Rejoin Timer/Enable", value)
		if value == true then
			rejoinTimer()
		end
	end
)
more_Tab:Slider(
	"Đặt thời gian tự động tham gia lại",
	(_env.Config["Rejoin Timer"] and _env.Config["Rejoin Timer"]["Minute"]) or 60,
	5,
	300,
	function(value)
		updateSettting("Rejoin Timer/Minute", value)
	end
)
more_Tab:Button("Tham gia lại máy chủ", function()
	TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
end)

---------------------------------------------------------- SETTINGS
local setting_Tab = window:CreateTab("Cài đặt", "rbxassetid://113518381337162")
setting_Tab:Toggle(
	"Tự động lưu",
	"Tự động lưu các cài đặt bạn đã chỉnh",
	_env.Config["Auto Save"] or false,
	function(value: boolean)
		updateSettting("Auto Save", value)
	end
)
local filterCopy = true
setting_Tab:Toggle(
	"Lọc sao chép (Gợi ý)",
	"Lọc các cài đặt chưa sử dụng đến hoặc đang tắt",
	true,
	function(value: boolean)
		filterCopy = value
	end
)
local minifyCopy = false
setting_Tab:Toggle(
	"Tối giản sao chép",
	"Tối giản sao chép cài đặt thành một chuỗi duy nhất",
	false,
	function(value: boolean)
		minifyCopy = value
	end
)
setting_Tab:Button("Sao chép tùy chỉnh vào bộ nhớ đệm", function()
	local function filterConfig(config)
		local filtered = {}
		for key, value in pairs(config) do
			if type(value) == "table" then
				filtered[key] = filterConfig(value)
			elseif value ~= false then
				filtered[key] = value
			end
		end
		return filtered
	end
	local function serializeTable(tbl, indent)
		indent = indent or 2
		local result = {}
		local spacing = string.rep("  ", indent)

		for key, value in pairs(tbl) do
			if type(key) == "string" then
				key = '"' .. key .. '"'
			end

			if type(value) == "table" then
				table.insert(result, spacing .. "[" .. key .. "] = {")
				table.insert(result, serializeTable(value, indent + 1))
				table.insert(result, spacing .. "},")
			else
				if value == "" or value == nil then
					table.insert(result, spacing .. "[" .. key .. "] = '',")
				else
					table.insert(result, spacing .. "[" .. key .. "] = " .. tostring(value) .. ",")
				end
			end
		end

		return table.concat(result, "\n")
	end

	local result = ""
	if filterCopy then
		local filtered = filterConfig(_env.Config)
		result = filtered
	else
		result = _env.Config
	end

	if minifyCopy then
		_setclipboard("getgenv().Config = " .. HttpService:JSONEncode(_env.Config))
	else
		local serializedString = "{" .. "\n" .. serializeTable(result) .. "\n" .. "}"
		_setclipboard("getgenv().Config = " .. serializedString)
	end

	UILib:Notify("Config", "Đã sao chép cài đặt vào bộ nhớ đệm của bạn", nil, 5)
end)
