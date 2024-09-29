
local tstation = require("tools.station")
local lgi = require("lgi")

local function _make_time(timezone) -- I wish it was this easy
    return lgi.GLib.DateTime.new_now(timezone or lgi.GLib.TimeZone.new_local())
end

local function new(args)
    local timezone = args.timezone
    local global_station = args.global_station
    assert(global_station ~= nil, "you must provide a reference to the global station")

    local auto_updating_time_obj
    local time = _make_time(timezone)
    tstation.emit_signal(global_station, "TimeChanged", { time = time })
    auto_updating_time_obj = {
        time = time,
        _timer = lgi.GLib.timeout_add_seconds(lgi.GLib.PRIORITY_LOW, 1, function()
            local new_time = _make_time(timezone)
            auto_updating_time_obj.time = new_time
            tstation.emit_signal(global_station, "TimeChanged", { time = new_time })
            return true
        end)
    }
    return auto_updating_time_obj
end

return {
    new = new,
}

