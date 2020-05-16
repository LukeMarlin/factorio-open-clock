function update_clock(player)
   local clock_button = global[player.index]

    -- daytime is between 0 and 1. 0 == 1 and therefore both are the middle of the clock
    -- shift by 0.5 to avoid dealing with negatives, giving 0.5 -> 1 -> 1.5
    -- modulo 1 to have 0.5 -> 0 -> 0.5 (now 0.5 do look like the middle of the clock)
    -- *24, giving 12 -> 0 -> 12
    local time = math.fmod((player.surface.daytime + 0.5), 1 ) * 24
    local hours = math.floor(time)
    local minutes = math.floor((time - hours) * 60)
    clock_button.caption = string.format("%02d:%02d", hours, minutes)
end

function config_update(e)
    local player = game.connected_players[e.player_index]
    if e.setting == "open-clock-ui-visible" then
        if settings.get_player_settings(player)["open-clock-ui-visible"].value == "yes" then
            global[e.player_index].visible = true
        else
            global[e.player_index].visible = false
        end
    end
end

function init_player(e)
    local player = game.connected_players[e.player_index]
    if global[player.index] == nil then
    -- We have no reference to the UI but it might be there, trying to get it
        global[player.index] = player.gui.top.open_clock
        if global[player.index] ~= nil then
            return
        end
    end

    global[player.index] = player.gui.top.add{type="button", name="open_clock", enabled=false}
    -- global[player.index].visible = true -- TODO: from config!
end

script.on_event({defines.events.on_player_created}, init_player)

script.on_event({defines.events.on_tick},
    function (e)
        if e.tick % 60 == 0 then -- Run once every 1 seconds
            for _, player in pairs(game.connected_players) do
                if settings.get_player_settings(player)["open-clock-ui-visible"].value == "yes" then
                    update_clock(player)
                end
            end
        end
    end
)

script.on_event({defines.events.on_runtime_mod_setting_changed}, config_update)
