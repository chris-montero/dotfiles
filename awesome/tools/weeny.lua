

local lgi = require("lgi")
local glib = lgi.GLib
local ttimer = require("tools.timer")

local TRACKLIST_PLAYING = 1
local TRACKLIST_PAUSED = 2
local TRACKLIST_STOPPED = 3

local WEEN_WAIT = 1
local WEEN_REGULAR = 2
local WEEN_NORMALIZED = 3
local WEEN_ENDLESS = 4

local function _get_running_ween_ind(track, elapsed)
    for ind, optimised_ween in ipairs(track) do
        if optimised_ween.leading_duration <= elapsed then
            return ind
        end
    end
end

local function _get_running_ween_indices(tracks, elapsed)

    local selected_weens = {}

    for track_id, track in pairs(tracks) do
        local ween_id = _get_running_ween_ind(track, elapsed)
        if ween_id ~= nil then
            table.insert(selected_weens, {
                track_id = track_id,
                ween_id = ween_id,
            })
        end
    end

    return selected_weens

end

local function _optimise_ween(wen, track_id, ween_id, leading_duration)
    wen.track_id = track_id
    wen.ween_id = ween_id
    wen.leading_duration = leading_duration
end

local function _optimise_weens(track_id, track)

    -- no reason to keep subsequent weens past "endless" weens
    local sanitised_weens = {}
    for k, wen in ipairs(track) do
        sanitised_weens[k] = wen
        if wen.type == WEEN_ENDLESS then
            break
        end
    end

    local new_weens = {}

    local leading_duration = 0
    for ween_id, wen in ipairs(sanitised_weens) do
        _optimise_ween(wen, track_id, ween_id, leading_duration)
        new_weens[ween_id] = wen
        if wen.type ~= WEEN_ENDLESS then
            leading_duration = leading_duration + wen.duration
        end
    end

    return new_weens

end

local function _optimise_tracks(tracks)

    local new_tracks = {}

    for track_id, track in pairs(tracks) do
        new_tracks[track_id] = _optimise_weens(track_id, track)
    end

    return new_tracks

end

-- TODO: maybe I could optimise this by storing some table in some way
-- and get O(1) performance instead of O(n).
local function _get_ween_from_elapsed(track, elapsed)
    for _, optimised_ween in ipairs(track) do
        local min_time = optimised_ween.leading_duration
        if optimised_ween.type == WEEN_ENDLESS then
            if elapsed > min_time then
                return optimised_ween
            end
        end
        local max_time = optimised_ween.leading_duration + optimised_ween.duration
        if elapsed > min_time and elapsed < max_time then
            return optimised_ween
        end
    end
    return nil
end


local function wait(duration)
    assert(type(duration) == "number")
    return {
        type = WEEN_WAIT,
        duration = duration,
    }
end

local function normalized(duration, animation_func, result_func)
    return {
        type = WEEN_NORMALIZED,
        duration = duration,
        animation_func = animation_func,
        result_func = result_func,
    }
end

local function ween(duration, point_a, point_b, animation_func, result_func)
    assert(type(duration) == "number")
    assert(type(point_a) == "number")
    assert(type(point_b) == "number")
    assert(type(animation_func) == "function")
    assert(type(result_func) == "function")
    return {
        type = WEEN_REGULAR,
        duration = duration,
        point_a = point_a,
        point_b = point_b,
        animation_func = animation_func,
        result_func = result_func,
    }
end

local function endless(animation_func, result_func)
    assert(type(animation_func) == "function")
    assert(type(result_func) == "function")
    return {
        type = WEEN_ENDLESS,
        animation_func = animation_func,
        result_func = result_func,
    }
end

local function _is_this_ween_expired(elapsed, wen)
    if wen.type == WEEN_ENDLESS then
        return false -- endless weens can't expire
    end

    if elapsed <
        wen.leading_duration + wen.duration
    then -- this ween hasn't expired
        return false
    end

    return true

end

local function _get_new_selected_weens(tracks, elapsed, old_selected_weens_ids)
    local new_selected_weens_ids = {}

    for _, optimised_ween_ids in ipairs(old_selected_weens_ids) do
        local optimised_ween = tracks[optimised_ween_ids.track_id][optimised_ween_ids.ween_id]

        local is_expired = _is_this_ween_expired(elapsed, optimised_ween)
        if is_expired then
            -- when the ween expires, always call the ween with the result
            -- it said it wants to get in the end. for example, if a ween 
            -- said it wants its result to be 2, call it here with 2 instead
            -- of 1.998837
            if optimised_ween.type == WEEN_REGULAR then
                optimised_ween.result_func(optimised_ween.point_b)
            elseif optimised_ween.type == WEEN_NORMALIZED then
                -- normalized weens should always end with "1"
                optimised_ween.result_func(1)
            end

            -- this ween is expired, so get the next one
            local next_ween = _get_ween_from_elapsed(
                tracks[optimised_ween.track_id],
                elapsed
            )

            if next_ween ~= nil then
                table.insert(new_selected_weens_ids, next_ween)
            end
        else
            table.insert(new_selected_weens_ids, optimised_ween)
        end

    end

    return new_selected_weens_ids
end

local function _animation_callback(tracklist)

    local cronometer = tracklist.cronometer
    local tracks = tracklist.tracks
    local before_tick = tracklist.before_tick
    local after_tick = tracklist.after_tick

    if before_tick ~= nil then
        before_tick(cronometer:elapsed())
    end

    local old_selected_weens_ids = tracklist.currently_selected_weens
    local new_selected_weens_ids = _get_new_selected_weens(
        tracks,
        cronometer:elapsed(),
        old_selected_weens_ids
    )
    tracklist.currently_selected_weens = new_selected_weens_ids


    -- for k, optimised_ween_ids in pairs(selected_weens_ids) do
    --     local optimised_ween = tracklist.tracks[optimised_ween_ids.track_id][optimised_ween_ids.ween_id]
    --     _retire_ween_if_expired(selected_weens_ids, k, optimised_ween)
    -- end

    -- now that everything is in order, we animate each track we need to
    for _, optimised_ween_ids in pairs(new_selected_weens_ids) do
        local optimised_ween = tracks[optimised_ween_ids.track_id][optimised_ween_ids.ween_id]
        if optimised_ween.type == WEEN_REGULAR then
            local point_a = optimised_ween.point_a
            local point_b = optimised_ween.point_b
            local leading_duration = optimised_ween.leading_duration
            local animation_func = optimised_ween.animation_func

            local points_diff = point_b - point_a
            local difference_factor = animation_func(cronometer:elapsed() - leading_duration)
            local result = point_a + (difference_factor * points_diff)
            optimised_ween.result_func(result)

        elseif optimised_ween.type == WEEN_NORMALIZED then
            local leading_duration = optimised_ween.leading_duration
            local animation_func = optimised_ween.animation_func

            local anim_arg = (cronometer:elapsed() - leading_duration) / optimised_ween.duration
            optimised_ween.result_func(animation_func(anim_arg))

        elseif optimised_ween.type == WEEN_ENDLESS then
            local animation_func = optimised_ween.animation_func
            local result_func = optimised_ween.result_func
            local leading_duration = optimised_ween.leading_duration

            -- we subtract the leading duration in order to give each track
            -- RELATIVE elapsed time, instead of absolute elapsed time
            local result = animation_func(cronometer:elapsed() - leading_duration)
            result_func(result)
        end
    end

    if after_tick ~= nil then
        after_tick(cronometer:elapsed())
    end

    return true -- return true to restart the timer

end

local function _create_animation_timer(tracklist_data)
    return ttimer.new(
        1 / tracklist_data.fps,
        function()
            if tracklist_data.play_state == TRACKLIST_PAUSED
                or tracklist_data.play_state == TRACKLIST_STOPPED
            then
                return false
            end
            return _animation_callback(tracklist_data)
        end,
        { priority = ttimer.PRIORITY_HIGH }
    )
end

local function create_tracklist(config, tracks)
    assert(config.fps ~= nil, "you must supply a 'fps' parameter")

    local fps = math.min(config.fps, 300) -- cap fps at 300
    local before_tick = config.before_tick
    local after_tick = config.after_tick

    assert(type(fps) == "number")

    local play_state = TRACKLIST_STOPPED
    local cronometer = glib.Timer()
    cronometer:stop()

    local optimised_tracks = _optimise_tracks(tracks or {})
    local tracklist_data = {
        cronometer = cronometer,
        fps = fps,
        play_state = play_state,
        before_tick = before_tick,
        after_tick = after_tick,
        tracks = optimised_tracks,
        currently_selected_weens = {}
    }

    -- NOTE: this doesn't start the timer. It only creates the data necessary
    -- for when the timer will actually be started
    tracklist_data.tick_timer = _create_animation_timer(tracklist_data)
    return tracklist_data
end

local function set_fps(tracklist, fps)
    if fps > 300 then fps = 300 end
    if tracklist.fps == fps then
        return
    end
    tracklist.fps = fps
    -- if tracklist.play_state == TRACKLIST_PAUSED or tracklist.play_state == TRACKLIST_STOPPED then
    --     return
    -- end

    -- tracklist.tick_timer = _make_new_animation_timer(tracklist, fps)

    -- stop the timer so the GLib timer is removed and can be garbage collected
    ttimer.stop(tracklist.tick_timer)
    tracklist.tick_timer = _create_animation_timer(tracklist)

end
local function get_fps(tracklist)
    return tracklist.fps
end

local function get_elapsed(tracklist)
    tracklist.cronometer:elapsed()
end
local function stop(tracklist)
    tracklist.play_state = TRACKLIST_STOPPED
    ttimer.stop(tracklist.tick_timer)
    tracklist.cronometer:stop()
end
local function start(tracklist)
    if tracklist.play_state == TRACKLIST_PLAYING then
        return
    end
    tracklist.play_state = TRACKLIST_PLAYING
    tracklist.currently_selected_weens = _get_running_ween_indices(tracklist.tracks, 0)
    ttimer.start(tracklist.tick_timer)
    tracklist.cronometer:start()
end

local function add_ween_on_track(tracklist, track_id, wen)

    local relevant_track = tracklist.tracks[track_id]

    if relevant_track == nil then
        relevant_track = {}
        tracklist.tracks[track_id] = relevant_track
    end

    local last_wen = relevant_track[#relevant_track]
    if last_wen == nil  then
        _optimise_ween(wen, track_id, 1, 0)
    else
        if last_wen.type == WEEN_ENDLESS then
            return -- no point adding ween if the last ween is endless
        end

        local ween_id = #relevant_track + 1
        local leading_duration = last_wen.leading_duration
        _optimise_ween(wen, track_id, ween_id, leading_duration)
    end
    table.insert(relevant_track, wen)
    tracklist.currently_selected_weens = _get_running_ween_indices(tracklist.tracks, tracklist.cronometer:elapsed())
end

local function add_ween_at_elapsed(tracklist, track_id, wen)

    local track = tracklist.tracks[track_id]
    local elapsed = tracklist.cronometer:elapsed()

    if track == nil then
        track = {}
        tracklist.tracks[track_id] = track
    end

    local running_ween_ind = _get_running_ween_ind(track, elapsed)
    if running_ween_ind ~= nil then
        table.remove(track, running_ween_ind)
    end

    local last_wen = track[#track]
    if last_wen == nil then
        _optimise_ween(wen, track_id, 1, elapsed)
    else
        local ween_id = #track + 1
        local leading_duration = elapsed
        _optimise_ween(wen, track_id, ween_id, leading_duration)
    end
    table.insert(track, wen)
    tracklist.currently_selected_weens = _get_running_ween_indices(tracklist.tracks, elapsed)

end

return {
    WEEN_WAIT = WEEN_WAIT,
    WEEN_REGULAR = WEEN_REGULAR,
    WEEN_ENDLESS = WEEN_ENDLESS,

    TRACKLIST_PLAYING = TRACKLIST_PLAYING,
    TRACKLIST_PAUSED = TRACKLIST_PAUSED,
    TRACKLIST_STOPPED = TRACKLIST_STOPPED,

    create_tracklist = create_tracklist,
    get_elapsed = get_elapsed,
    stop = stop,
    start = start,
    set_fps = set_fps,
    get_fps = get_fps,

    add_ween_on_track = add_ween_on_track,
    add_ween_at_elapsed = add_ween_at_elapsed,

    wait = wait,
    ween = ween,
    normalized = normalized,
    endless = endless,
}
