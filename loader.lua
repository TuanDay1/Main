repeat task.wait() until game:IsLoaded()

----------------------------------------------------------
local _env = getgenv and getgenv() or {}
local _httpget = httpget or game.HttpGet or function () end
----------------------------------------------------------

local gameId = game.GameId
_env.Games = {
    [5750914919] = "",
}

if _env.Games[gameId] then
    loadstring(_httpget(game, _env.Games[gameId]))()
end