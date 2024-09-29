
local tstation = require("tools.station")

local function new(args)

    assert(args.model ~= nil, "you must provide a 'model' for your application.")
    assert(args.global_station ~= nil, "you must provide a reference to the global station")
    assert(args.global_model ~= nil, "you must provide a reference to the global model")
    assert(args.tracklist ~= nil, "you must provide a reference to a tracklist")

    local app = {
        model = args.model,
        station = tstation.new(),
        global_station = args.global_station,
        global_model = args.global_model,
        tracklist = args.tracklist
    }

    if args.subscribe_on_app ~= nil then
        for sig_name, cb in pairs(args.subscribe_on_app) do
            tstation.subscribe_signal_with_data(
                app.station,
                sig_name,
                cb,
                { app_data = app }
            )
        end
    end
    if args.subscribe_on_global ~= nil then
        for sig_name, cb in pairs(args.subscribe_on_global) do
            tstation.subscribe_signal_with_data(
                app.global_station,
                sig_name,
                cb,
                { app_data = app }
            )
        end
    end

    tstation.emit_signal(app.station, "Init", { app_data = app })
    -- unveil.dump(app, {
    --     ignore_fields = {
    --         _parent = true,
    --         app_data = true,
    --         layout_data = true,
    --     }
    -- })
    return app
end


return {
    new = new
}
