
local eapplication = require("elemental.application")
local tstation = require("tools.station")
local theme_names = require("theme_names")
local keytone_id = require("wonderful.keymap.keytone_id")
local keymap_types = require("wonderful.keymap.types")
local crank_mode = require("apps.Crank.mode")

local function new(args)

    local global_station = args.global_station
    local model = args.model

    local app = eapplication.new({
        global_model = args.global_model,
        global_station = global_station,
        tracklist = args.tracklist,
        model = model,
    })

    if args.global_model.theme_name == theme_names[1] then -- LateForLunch
        local layout = require("apps.Crank." .. args.global_model.theme_name .. ".panel_layout")
        local scr = args.screen
        app.model.panel_layout = layout.new({
            screen = scr,
            app_data = app,
        })
        -- app.model.notification_layout = require("apps.Crank." .. args.global_model.theme_name .. ".notification_layout")
    end

    tstation.subscribe_signals(global_station, {
        ["EventCrankShown"] = function()
            keygrabber.run(function(mods, key, evt)
                local k = keytone_id.new(mods, key, evt)
                if k.event == keymap_types.EVENT_RELEASE then return end -- ignore release

                if model.mode == crank_mode.MODE_NORMAL then

                    if k.modifiers.Mod1 then -- alt + <key> cases
                        if k.key == 'n' then -- alt + n
                            keygrabber.stop()
                            tstation.emit_signal(global_station, "RequestCrankHide")
                        -- elseif k.key == 'y' then -- alt + y
                        --     tstation.emit_signal(global_station, "RequestTakeScreenshot")
                        end
                        return
                    end
                    if k.key == '/' then
                        model.mode = crank_mode.MODE_SEARCH
                        tstation.emit_signal(app.station, "ModeChanged")
                    end

                elseif model.mode == crank_mode.MODE_SEARCH then

                    if k.key == 'Escape' then
                        model.mode = crank_mode.MODE_NORMAL
                        tstation.emit_signal(app.station, "ModeChanged")
                    end

                end
            end)
        end,
        ["ClearNotifications"] = function() -- TODO: implement
        end
    })

    return app
end

local function show_panel()
end

local function show_notification()
end

return {
    new = new,
}

