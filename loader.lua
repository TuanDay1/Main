repeat task.wait() until game:IsLoaded()

----------------------------------------------------------
local _env = getgenv and getgenv() or {}
local _httpget = httpget or game.HttpGet or function () end
----------------------------------------------------------

local gameId = game.GameId
_env.Games = {
    [5750914919] = "https://raw.githubusercontent.com/TuanDay1/Main/refs/heads/main/Games/Fisch.lua",
}

if _env.Games[gameId] then
    loadstring(_httpget(game, _env.Games[gameId]))()
else
    loadstring(_httpget(game, "https://raw.githubusercontent.com/TuanDay1/Main/refs/heads/main/Games/Debug.lua"))()
end