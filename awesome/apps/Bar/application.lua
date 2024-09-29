
local eapplication = require("elemental.application")
local theme_name = require("theme_names")

local function new(args)

    local model = { screen = args.screen, tags = args.screen.tags }
    local tracklist = args.tracklist
    local global_station = args.global_station
    local global_model = args.global_model
    local scr = args.screen

    local app = eapplication.new({
        model = model,
        tracklist = tracklist,
        global_station = global_station,
        global_model = global_model,
    })

    if global_model.theme_name == theme_name[1] then -- LateForLunch 
        local layout_func = require("apps.Bar." .. global_model.theme_name .. ".layout")
        app.model.layout = layout_func.new({
            app_data = app,
            screen = scr,
            height = args.height,
        })
    end

    return app

end

return {
    new = new,
}
