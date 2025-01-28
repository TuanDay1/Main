------------------------------------------------
local _env = getgenv and getgenv() or {}
local _gethui = gethui or function () end
local _httpget = httpget or game.HttpGet or function () end
local _setclipboard = setclipboard or function () end

------------------------------------------------
local UILib = loadstring(_httpget(game, "https://raw.githubusercontent.com/TuanDay1/Main/refs/heads/main/Library/UILib.lua"))()
local FileManager = loadstring(_httpget(game, "https://raw.githubusercontent.com/TuanDay1/Main/refs/heads/main/Library/FileManager.lua"))()
------------------------------------------------

----- Services -----
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

----------Variables----------
local player = Players.LocalPlayer
local playerGui = player.PlayerGui

----------------------------------------------------------
local window, fileName = UILib:CreateWindow("Debug", "NTCHubDebug")

--[[

     __   __     ______   ______   
    /\ "-.\ \   /\__  _\ /\  ___\  
    \ \ \-.  \  \/_/\ \/ \ \ \____ 
     \ \_\\"\_\    \ \_\  \ \_____\
      \/_/ \/_/     \/_/   \/_____/

]]--

---------------------------------------------------------- MAIN
local debugScripts = {
    ["Infinite Yield"] = "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source",
    ["Dex Explorer"] = "https://raw.githubusercontent.com/AhmadV99/Main/refs/heads/main/Dex-Explorer",
    ["Turtle Spy"] = "https://raw.githubusercontent.com/Turtle-Brand/Turtle-Spy/main/source.lua",
}
local ScriptNames = {}
for index, _ in pairs(debugScripts) do table.insert(ScriptNames, index) end

local antiScripts = {
    ["Anti Adonis"] = "https://raw.githubusercontent.com/C0RP0RATE/Oblivious/refs/heads/main/Adonis_AntiCheat_Bypass_V2.lua",
}
local AntiNames = {}
for index, _ in pairs(antiScripts) do table.insert(AntiNames, index) end

local main_Tab = window:CreateTab("Chính", "rbxassetid://113518381337162")
UILib:SelectTab("Chính")
main_Tab:Dropdown(
    "Chạy đoạn mã:",
    ScriptNames,
    function(value: string)
        if value == "" then return end
        if debugScripts[value] == nil then return end

        loadstring(_httpget(game, debugScripts[value]))()
        UILib:Notify("Script", "Đã khởi chạy đoạn mã thành công!", nil, 5)
    end
)
main_Tab:Dropdown(
    "Chạy anti:",
    AntiNames,
    function(value: string)
        if value == "" then return end
        if antiScripts[value] == nil then return end

        loadstring(_httpget(game, antiScripts[value]))()
        UILib:Notify("Script", "Đã khởi chạy đoạn mã thành công!", nil, 5)
    end
)
main_Tab:Button(
    "Sao chép vị trí nhân vật",
    function()
        local playerCharacter = player.Character or player.CharacterAdded:Wait()
        local playerHumanoidRootPart = playerCharacter:WaitForChild("HumanoidRootPart")

        _setclipboard(string.format("CFrame.new(%s, %s, %s)", playerHumanoidRootPart.CFrame.X, playerHumanoidRootPart.CFrame.Y, playerHumanoidRootPart.CFrame.Z))
        UILib:Notify("Character", "Đã sao chép vị trí nhân vật vào bộ nhớ đệm của bạn", nil, 5)
    end
)