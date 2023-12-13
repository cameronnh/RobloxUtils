-- Debouncer
-- Cameron Jewett (poolcreep)
-- November 11, 2023

local Players = game:GetService("Players")

local debounces: {[string]: number} = {}
local playerDebounces: {[Player]: {[string]: number}} = {}

Players.PlayerRemoving:Connect(function(player: Player)
    if not playerDebounces[player] then
        return
    end

    table.clear(playerDebounces[player])
    playerDebounces[player] = nil
end)

--[[
    Returns: boolean
    Description: Checks debounces time based.
    Paremeters
        - key: time,
        - time: number (Calls when the client has touched item passed.)
        - player: Player? (For use with different players.)
]]

return function (key: string, debounce: number, player: Player?)
    assert(debounce > 0, "Debounce must be greater than 0.")
    assert(typeof(key) == "string", "Key must be a string")

    local tableToCheck: {[string]: number} | {[Player]: {[string]: number}} = debounces

    if player then
        if not playerDebounces[player] then
            playerDebounces[player] = {}
        end

        tableToCheck = playerDebounces[player]
    end

    if not tableToCheck[key] then
        tableToCheck[key] = os.clock()
        return true
    end

    if tableToCheck[key] > os.clock() then
        return false
    end

    tableToCheck[key] = os.clock() + debounce
    return true
end
