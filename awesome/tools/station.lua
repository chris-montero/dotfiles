
local function _create_pcall_error_message(signal, result)
    return "Calling callback function on subscribed signal "
        .. "'" .. signal .. "'"
        .. " failed: " .. tostring(result)
end

-- use this subscribe function if you just want a callback to be called when a
-- `signal` is emitted
local function subscribe_signal(station, signal, fun)
    if station.signals[signal] == nil then
        station.signals[signal] = {}
    end
    station.signals[signal][fun] = true
end

-- use this function if you want to subscribe to a signal and have some arguments
-- be automatically added as the first parameters to the callback `fun` when
-- `signal` will be emitted
local function subscribe_signal_with_data(station, signal, fun, subscriber_data)
    if station.signals[signal] == nil then
        station.signals[signal] = {}
    end
    station.signals[signal][fun] = subscriber_data
end

-- returns false if it couldn't find any subscribers to emit the signal on
-- returns true if it does
local function emit_signal(station, signal, emitted_data)
    local callbacks = station.signals[signal]
    if callbacks == nil then
        return false
    end

    for func, subscriber_data in pairs(callbacks) do
        if subscriber_data == true then -- there's no subscriber data
            local success, result = pcall(func, emitted_data)
            if not success then
                print(_create_pcall_error_message(signal, result))
            end
        else
            local success, result = pcall(func, subscriber_data, emitted_data)
            if not success then
                print(_create_pcall_error_message(signal, result))
            end
        end
    end
    return true
end

local function unsubscribe_signal(station, signal, fun)
    local subs = station.signals[signal]
    if subs == nil then
        return false
    end
    if subs[fun] == true then
        table.remove(station.signals[signal][fun])
        return true
    end
    return false
end

local function subscribe_signals(station, signals_and_callbacks)
    for sig_name, callback in pairs(signals_and_callbacks) do
        assert(type(callback) == "function")
        subscribe_signal(station, sig_name, callback)
    end
end

local function subscribe_signals_with_data(station, signals_callbacks_and_data)
    for sig_name, callback_and_data in pairs(signals_callbacks_and_data) do
        local callback = callback_and_data.callback
        local data = callback_and_data.data
        assert(type(callback) == "function")
        assert(data ~= nil)
        subscribe_signal_with_data(station, sig_name, callback, data)
    end
end

local function new(config)
    local station = {
        signals = {}
    }
    if config == nil then return station end

    if config.subscribe_signals ~= nil then
        subscribe_signals(station, config.subscribe_signals)
    end

    if config.subscribe_signals_with_data ~= nil then
        subscribe_signals_with_data(station, config.subscribe_signals_with_data)
    end

    return station
end

return {
    new = new,
    subscribe_signal = subscribe_signal,
    subscribe_signal_with_data = subscribe_signal_with_data,
    subscribe_signals = subscribe_signals,
    subscribe_signals_with_data = subscribe_signals_with_data,
    emit_signal = emit_signal,
    unsubscribe_signal = unsubscribe_signal,
}
