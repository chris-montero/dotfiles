
local eapplication = require("elemental.application")
local tstation = require("tools.station")

local function new(args)
    local layout = args.layout -- will be selected by the caller based on the theme
    local scr = args.screen

    local app = eapplication.new({
        global_station = args.global_station,
        global_model = args.global_model,
        tracklist = args.tracklist,
        model = args.model,
        subscribe_on_app = {
            Init = function(scope)
                local app_data = scope.app_data
                if layout == nil then
                    return
                end
                if scr == nil then
                    error([[if you provide a layout function for this app, you 
                    must supply a reference to a screen.]])
                end
                app_data.model.layout = layout.new({
                    app_data = app_data,
                    screen = scr,
                })
            end

        }
    })

    local subscriptions = {
        EventWeatherShown = function()
        end,
    }

    tstation.subscribe_signals(app.station, subscriptions)

    return app

end


return {
    new = new,
}


