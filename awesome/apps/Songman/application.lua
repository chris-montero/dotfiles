
local eapplication = require("elemental.application")
local tstation = require("tools.station")
local theme_names = require("theme_names")
local keytone_id = require("wonderful.keymap.keytone_id")
local keymap_types = require("wonderful.keymap.types")

local function new(args)

    local scr = args.screen
    local global_model = args.global_model
    local global_station = args.global_station

    local app = eapplication.new({
        global_station = global_station,
        global_model = global_model,
        tracklist = args.tracklist,
        model = {}
    })

    if global_model.theme_name == theme_names[1] then -- LateForLunch

        local layout = require("apps.Songman." .. global_model.theme_name .. ".layout")
        app.model.layout = layout.new({
            screen = scr,
            app_data = app,
        })

    end

    -- local subscriptions = {}

    tstation.subscribe_signals(global_station, {
        EventSongmanShown = function()
            -- keygrabber.run(function(mods, key, evt)
            --     local k = keytone_id.new(mods, key, evt)
            --     if k.event == keymap_types.EVENT_RELEASE then return end -- ignore release
            --
            --     if k.modifiers.Mod1 and k.key == 's' then -- alt + s
            --         keygrabber.stop()
            --         tstation.emit_signal(global_station, "RequestSongmanHide")
            --     end
            --
            -- end)
        end
    })

    return app
end

return {
    new = new,
}
