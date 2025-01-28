------------------------------------------------
local _env = getgenv and getgenv() or {}
local _gethui = gethui or function () end
local _httpget = httpget or game.HttpGet or function () end
local _setclipboard = setclipboard or function () end
local _hookmetamethod = hookmetamethod or function () end
local _getnamecallmethod = getnamecallmethod or function () end

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
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService('VirtualInputManager')

----------Variables----------
local player = Players.LocalPlayer
local playerGui = player.PlayerGui

local playerCharacterPosition
local TeleportLocations = {
    ['Zones'] = {
        ['Moosewood'] = CFrame.new(379.875458, 134.500519, 233.5495, -0.033920113, 8.13274355e-08, 0.999424577, 8.98441925e-08, 1, -7.83249803e-08, -0.999424577, 8.7135696e-08, -0.033920113),
        ['Roslit Bay'] = CFrame.new(-1472.9812, 132.525513, 707.644531, -0.00177415239, 1.15743369e-07, -0.99999845, -9.25943056e-09, 1, 1.15759981e-07, 0.99999845, 9.46479251e-09, -0.00177415239),
        ['Forsaken Shores'] = CFrame.new(-2491.104, 133.250015, 1561.2926, 0.355353981, -1.68352852e-08, -0.934731781, 4.69647858e-08, 1, -1.56367586e-10, 0.934731781, -4.38439116e-08, 0.355353981),
        ['Sunstone Island'] = CFrame.new(-913.809143, 138.160782, -1133.25879, -0.746701241, 4.50330218e-09, 0.665159583, 2.84934609e-09, 1, -3.5716119e-09, -0.665159583, -7.71657294e-10, -0.746701241),
        ['Statue of Sovereignty'] = CFrame.new(21.4017925, 159.014709, -1039.14233, -0.865476549, -4.38348664e-08, -0.500949502, -9.38435818e-08, 1, 7.46273798e-08, 0.500949502, 1.11599142e-07, -0.865476549),
        ['Terrapin Island'] = CFrame.new(-193.434143, 135.121979, 1951.46936, 0.512723684, -6.94711346e-08, 0.858553708, 5.44089183e-08, 1, 4.84237539e-08, -0.858553708, 2.18849721e-08, 0.512723684),
        ['Snowcap Island'] = CFrame.new(2607.93018, 135.284332, 2436.13208, 0.909039497, -7.49003748e-10, 0.4167099, 3.38659367e-09, 1, -5.59032465e-09, -0.4167099, 6.49305321e-09, 0.909039497),
        ['Mushgrove Swamp'] = CFrame.new(2434.29785, 131.983276, -691.930542, -0.123090521, -7.92820209e-09, -0.992395461, -9.05862692e-08, 1, 3.2467995e-09, 0.992395461, 9.02970569e-08, -0.123090521),
        ['Ancient Isle'] = CFrame.new(6056.02783, 195.280167, 276.270325, -0.655055285, 1.96010075e-09, 0.755580962, -1.63855578e-08, 1, -1.67997189e-08, -0.755580962, -2.33853594e-08, -0.655055285),
        ['Northern Expedition'] = CFrame.new(-1701.02979, 187.638779, 3944.81494, 0.918493569, -8.5804345e-08, 0.395435959, 8.59132356e-08, 1, 1.74328942e-08, -0.395435959, 1.7961181e-08, 0.918493569),
        ['Northern Summit'] = CFrame.new(19608.791, 131.420105, 5222.15283, 0.462794542, -2.64426987e-08, 0.886465549, -4.47066562e-08, 1, 5.31692343e-08, -0.886465549, -6.42373408e-08, 0.462794542),
        ['Vertigo'] = CFrame.new(-102.40567, -513.299377, 1052.07104, -0.999989033, 5.36423439e-09, 0.00468267547, 5.85247495e-09, 1, 1.04251647e-07, -0.00468267547, 1.04277916e-07, -0.999989033),
        ['Depths Entrance'] = CFrame.new(-15.4965982, -706.123718, 1231.43494, 0.0681341439, 1.15903154e-08, -0.997676194, 7.1017638e-08, 1, 1.64673093e-08, 0.997676194, -7.19745898e-08, 0.0681341439),
        ['Depths'] = CFrame.new(491.758118, -706.123718, 1230.6377, 0.00879980437, 1.29271776e-08, -0.999961257, 1.95575205e-13, 1, 1.29276803e-08, 0.999961257, -1.13956629e-10, 0.00879980437),
        ['Overgrowth Caves'] = CFrame.new(19746.2676, 416.00293, 5403.5752, 0.488031536, -3.30940715e-08, -0.87282598, -3.24267696e-11, 1, -3.79341323e-08, 0.87282598, 1.85413569e-08, 0.488031536),
        ['Frigid Cavern'] = CFrame.new(20253.6094, 756.525818, 5772.68555, -0.781508088, 1.85673343e-08, 0.623895109, 5.92671467e-09, 1, -2.23363816e-08, -0.623895109, -1.3758414e-08, -0.781508088),
        ['Cryogenic Canal'] = CFrame.new(19958.5176, 917.195923, 5332.59375, 0.758922458, -7.29783434e-09, 0.651180983, -4.58880756e-09, 1, 1.65551253e-08, -0.651180983, -1.55522013e-08, 0.758922458),
        ['Glacial Grotto'] = CFrame.new(20003.0273, 1136.42798, 5555.95996, 0.983130038, -3.94455064e-08, 0.182907909, 3.45229765e-08, 1, 3.0096718e-08, -0.182907909, -2.32744615e-08, 0.983130038),
        ["Keeper's Altar"] = CFrame.new(1297.92285, -805.292236, -284.155823, -0.99758029, 5.80044706e-08, -0.0695239156, 6.16549869e-08, 1, -5.03615105e-08, 0.0695239156, -5.45261436e-08, -0.99758029)
    },
    ['Rods'] = {},
}
local ZoneNames = {}
for index, _ in pairs(TeleportLocations["Zones"]) do table.insert(ZoneNames, index) end

----------------------------------------------------------
local window, fileName = UILib:CreateWindow("Fisch", "NTCHub")

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

--[[

     __   __     ______   ______   
    /\ "-.\ \   /\__  _\ /\  ___\  
    \ \ \-.  \  \/_/\ \/ \ \ \____ 
     \ \_\\"\_\    \ \_\  \ \_____\
      \/_/ \/_/     \/_/   \/_____/

]]--

do
    local old; old = _hookmetamethod(game, "__namecall", function(self, ...)
        local method, args = _getnamecallmethod(), {...}
        if method == 'FireServer' and self.Name == 'afk' then
            args[1] = false
            return old(self, unpack(args))
        end
        return old(self, ...)
    end)
end

GuiService.ErrorMessageChanged:Connect(function()
    if GuiService:GetErrorCode() == Enum.ConnectionError.DisconnectLuaKick then
        if _env.Config["Auto Rejoin"] == true then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
            return
        end
    end
end)

local function findRod()
    local playerCharacter = player.Character or player.CharacterAdded:Wait()
    local Rod = playerCharacter:FindFirstChildOfClass("Tool")
    if Rod and Rod:FindFirstChild("values") then
        return Rod
    end
    return nil
end

RunService.Heartbeat:Connect(function()
    if _env.Config["Auto Shake"] then
        if playerGui:FindFirstChild("shakeui") and playerGui["shakeui"]:FindFirstChild("safezone") and playerGui["shakeui"]["safezone"]:FindFirstChild("button") then
            GuiService.SelectedObject = playerGui["shakeui"]["safezone"]["button"]
            if GuiService.SelectedObject == playerGui["shakeui"]["safezone"]["button"] then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            end
        end
    end
    if _env.Config["Auto Reel"] then
        local Rod = findRod()
        if Rod and Rod["values"]["lure"].Value == 100 and task.wait(.5) then
            local reelfinished = ReplicatedStorage:WaitForChild("events"):FindFirstChild("reelfinished ")
            reelfinished:FireServer(100, true)
        end
    end
    if _env.Config["Auto Cast"] then
        local Rod = findRod()
        if Rod and Rod["values"]["lure"].Value <= .001 and task.wait(.5) then
            local cast = Rod:WaitForChild("events"):FindFirstChild("cast")
            cast:FireServer(100, 1)
        end
    end
    if _env.Config["Freeze Character"] then
        local playerCharacter = player.Character or player.CharacterAdded:Wait()
        local playerHumanoidRootPart = playerCharacter:WaitForChild("HumanoidRootPart")

        local Rod = findRod()
        if Rod and playerCharacterPosition == nil then
            playerCharacterPosition = playerHumanoidRootPart.CFrame
        elseif Rod and playerCharacterPosition ~= nil then
            playerHumanoidRootPart.CFrame = playerCharacterPosition
        else
            playerCharacterPosition = nil
        end
    end
end)

---------------------------------------------------------- MAIN
local main_Tab = window:CreateTab("Chính", "rbxassetid://113518381337162")
UILib:SelectTab("Chính")

main_Tab:Toggle(
    "Tự động thả câu",
    "Tự động thả câu khi bật",
    _env.Config["Auto Cast"] or false,
    function(value: boolean)
        updateSettting("Auto Cast", value)
    end
)

main_Tab:Toggle(
    "Tự động cuộn dây",
    "Tự động cuộn dây khi câu cá",
    _env.Config["Auto Reel"] or false,
    function(value: boolean)
        updateSettting("Auto Reel", value)
    end
)

main_Tab:Toggle(
    "Tự động lắc",
    "Tự động lắc khi câu cá",
    _env.Config["Auto Shake"] or false,
    function(value: boolean)
        updateSettting("Auto Shake", value)
    end
)

main_Tab:Toggle(
    "Đóng băng nhân vật",
    "Nhân vật của bạn sẽ bị đóng băng khi cầm cần câu",
    _env.Config["Freeze Character"] or false,
    function(value: boolean)
        updateSettting("Freeze Character", value)
    end
)

main_Tab:Toggle(
    "Đi trên mặt nước",
    "Bạn sẽ có thể đi trên mặt nước",
    false,
    function(value: boolean)
        local zones = game.Workspace:WaitForChild("zones")
        local fishing = zones:FindFirstChild("fishing")

        for _, object in pairs(fishing:GetChildren()) do
            if object:IsA("UnionOperation") or object:IsA("Part") or object:IsA("BasePart") or object:IsA("MeshPart") then
                object.CanCollide = value
            end
        end
    end
)

---------------------------------------------------------- MAIN
local teleport_Tab = window:CreateTab("Dịch chuyển", "rbxassetid://113518381337162")
teleport_Tab:Dropdown(
    "Dịch chuyển đến:",
    ZoneNames,
    function(value: string)
        if value == "" then return end

        local playerCharacter = player.Character or player.CharacterAdded:Wait()
        local playerHumanoidRootPart = playerCharacter:WaitForChild("HumanoidRootPart")
        playerHumanoidRootPart.CFrame = TeleportLocations["Zones"][value]
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
        if _env.Config["Rejoin Timer"].Enable == false then break end
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
more_Tab:Button(
    "Tham gia lại máy chủ",
    function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
)

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
setting_Tab:Button(
    "Sao chép tùy chỉnh vào bộ nhớ đệm",
    function()
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
            _setclipboard("getgenv().Config = "..HttpService:JSONEncode(_env.Config))
        else
            local serializedString = "{" .. "\n" .. serializeTable(result) .. "\n" .. "}"
            _setclipboard("getgenv().Config = "..serializedString)
        end

        UILib:Notify("Config", "Đã sao chép cài đặt vào bộ nhớ đệm của bạn", nil, 5)
    end
)