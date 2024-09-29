
local glib = require("lgi").GLib
local protected_call = require("gears.protected_call")

local STATE_RUNNING = 1
local STATE_STOPPED = 2

local function round(num)
    return math.floor(num + 0.5)
end

local function is_running(timer)
    if timer.state == STATE_RUNNING then
        return true
    end
    return false
end

local function new(timeout, callback, config)
    config = config or {}

    local priority = config.priority or glib.PRIORITY_DEFAULT

    return {
        timeout = timeout,
        callback = callback,
        priority = priority,
        state = STATE_STOPPED,
        gtimer_id = nil -- no timer started yet
    }
end

local function stop(timer)
    if timer.gtimer_id == nil then
        return
    end
    glib.source_remove(timer.gtimer_id)
    timer.gtimer_id = nil
    timer.state = STATE_STOPPED
end

local function start(timer)

    if is_running(timer) then
        print(debug.traceback("timer is already running."))
        return
    end
    timer.state = STATE_RUNNING
    local timeout_ms = round(timer.timeout * 1000)
    timer.gtimer_id = glib.timeout_add(timer.priority, timeout_ms, function()
        local ret = protected_call(timer.callback)
        if type(ret) ~= "boolean" then
            ret = false
        end
        if ret == false then
            -- the source will be removed automatically if we return false
            timer.timer_id = nil
            timer.state = STATE_STOPPED
        end
        return ret
    end)

end

return {
    new = new,
    start = start,
    stop = stop,
    is_running = is_running,

    PRIORITY_LOW = glib.PRIORITY_LOW,
    PRIORITY_DEFAULT = glib.PRIORITY_DEFAULT,
    PRIORITY_DEFAULT_IDLE = glib.PRIORITY_DEFAULT_IDLE,
    PRIORITY_HIGH = glib.PRIORITY_HIGH,
    PRIORITY_HIGH_IDLE = glib.PRIORITY_HIGH_IDLE,
}

