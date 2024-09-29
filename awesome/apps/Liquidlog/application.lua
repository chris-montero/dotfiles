
local eapplication = require("elemental.application")
local tstation = require("tools.station")

local function new(args)

    local app = eapplication.new({
        global_model = args.global_model,
        global_station = args.global_station,
        tracklist = args.tracklist,
        model = args.model,
    })

    local subscriptions = {
        -- LayoutShown = function()
        -- end

        -- TextChanged = function(text)
        --     app.model.text = text
        -- end
    }

    tstation.subscribe_signals(app.station, subscriptions)

    return app
end

return {
    new = new,
}

