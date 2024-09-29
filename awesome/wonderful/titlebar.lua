
local internal_e = require("elemental.internal")
local esource = require("elemental.source")
local tstation = require("tools.station")
local tarray = require("tools.array")
local cairo = require("lgi").cairo

local SIDE_TOP = 1
local SIDE_RIGHT = 2
local SIDE_BOTTOM = 3
local SIDE_LEFT = 4

local TitleChanged = "TitleChanged"
local ClientFocused = "ClientFocused"

local function _change_and_relay_awesome_signals(c, station)
    c:connect_signal("property::name", function()
        tstation.emit_signal(station, TitleChanged, {
            client = c,
            title = c.name
        })
    end)
    c:connect_signal("focus", function()
        tstation.emit_signal(station, ClientFocused)
    end)
    -- c:connect_signal("focus", function()
    --     print("FOCUSED")
    -- end)
    -- c:connect_signal("unfocus", function()
    --     print("lost focus")
    -- end)
end

local function _get_side_func(c, side)
    if side == SIDE_TOP then
        return c.titlebar_top
    elseif side == SIDE_RIGHT then
        return c.titlebar_right
    elseif side == SIDE_BOTTOM then
        return c.titlebar_bottom
    elseif side == SIDE_LEFT then
        return c.titlebar_left
    end
end

local function _draw_window(bg, cr)
    cr:save()
    cr.operator = cairo.Operator.SOURCE
    cr:set_source(esource.to_cairo_source(bg))
    cr:paint()
    cr:restore()
end

local function _mark_relayout_at_layout(layout_data)
    layout_data.window_changes.someone_needs_relayout = true
    layout_data.window_changes.relayout_needed = true
end

local function _mark_redraw_at_layout(layout_data)
    layout_data.window_changes.someone_needs_redraw = true
    layout_data.window_changes.redraw_needed = true
end

local function _drawable_listen_callback(layout_data)
    layout_data.drawable_changed = true
end

local function _start_listening_to_drawable_changes(layout_data)
    layout_data.client:connect_signal("property::geometry", function() _drawable_listen_callback(layout_data) end)
    layout_data.client:connect_signal("property::screen", function() layout_data.screen = client.screen end)
end

local function _stop_listening_to_drawable_changes(layout_data)
    layout_data.drawable:disconnect_signal("property::geometry", _drawable_listen_callback)
end

local function new(args)

    local bg = args.bg
    local visible = args.visible
    local side = args.side
    local size = args.size
    local c = args.client
    local app_data = args.app_data

    assert(type(visible) == "boolean", "the property 'visible' should be 'true' or 'false'")
    assert(type(app_data) == "table", "you must have a reference to a valid 'app_data' table")
    assert(side > 0 and side < 5, "the 'side' must be one of the 'SIDE_' enums included in this module" )
    assert(type(size) == "number", "the size must be a number")
    assert(c ~= nil, "you must provide the client on which you want the titlebar")

    local layout_data

    local side_func = _get_side_func(c, side)

    local drawable = side_func(c, size)

    layout_data = {
        client = c,
        screen = c.screen,
        _very_secret_layout_identifier_property = true,
        app_data = app_data,

        -- station used for mouse input events that happen on this titlebar
        station = tstation.new(),

        visible = visible,
        bg = bg,

        drawable_changed = false,
        drawable = drawable,
        cr = internal_e.create_new_cairo_context(drawable),

        id_table = {},
        processed_tree = nil,

        -- to be used by functions that manipulate elements and the window so
        -- we can efficiently redraw the least amount of things
        window_changes = internal_e.create_empty_window_changes()
    }

    _start_listening_to_drawable_changes(layout_data)
    _change_and_relay_awesome_signals(c, layout_data.station)

    tstation.subscribe_signal(layout_data.app_data.global_station, "TracklistBeforeTick", function(_)


        -- if layout_data.visible ~= layout_data.window.visible then
        --     if layout_data.visible == true then
        --         need_new_cairo_context = true
        --     end
        --     layout_data.window.visible = layout_data.visible
        -- end

        -- local window_geom = layout_data.drawable:geometry()

        -- if layout_data.x ~= window_geom.x then
        --     layout_data.window.x = layout_data.x
        --     need_new_cairo_context = true
        -- end
        -- if layout_data.y ~= window_geom.y then
        --     layout_data.window.y = layout_data.y
        --     need_new_cairo_context = true
        -- end
        -- if layout_data.width ~= window_geom.width then
        --     need_new_cairo_context = true
        --     layout_data.window.width = layout_data.width
        -- end
        -- if layout_data.height ~= window_geom.height then
        --     layout_data.window.height = layout_data.height
        --     need_new_cairo_context = true
        -- end

        if layout_data.drawable_changed == true then
            layout_data.cr = internal_e.create_new_cairo_context(layout_data.drawable)
            -- if the cairo context changes, mark the whole window as dirty area
            _mark_relayout_at_layout(layout_data)
            _mark_redraw_at_layout(layout_data)
            layout_data.drawable_changed = false
        end

    end)

    tstation.subscribe_signal(layout_data.app_data.global_station, "TracklistAfterTick", function(_)

        -- if the window is not visible then we don't even go through the changes.
        -- this way, any changes made like elements being marked as needing a
        -- relayout will not be recomputed, but will only be computed once
        -- the window becomes visible
        if layout_data.visible == false then return end
        if internal_e.do_we_need_to_redraw(layout_data) == false then return end

        -- clip to dirty areas so we only redraw what was changed
        internal_e.compute_changes_and_clip_dirty_areas(layout_data)

        -- if we have a background, draw it on the window
        if layout_data.bg ~= nil then
            _draw_window(layout_data.bg, layout_data.cr)
        end

        -- if we have elements, draw them
        if layout_data.processed_tree ~= nil then
            for _, branch in ipairs(layout_data.processed_tree) do
                internal_e.draw_processed_branch(branch, layout_data.cr)
            end
        end

        -- refresh the drawable so the drawing actually shows up
        layout_data.drawable:refresh()

        -- reset changes table so we don't see the same changes we just
        -- redrew in the next frame
        layout_data.window_changes = internal_e.create_empty_window_changes()

    end)

    internal_e.subscribe_everyone_to_mouse_signals(drawable, layout_data)

    -- drawable:connect_signal("property::surface", function(_) --TODO: find out what this does
    --     tstation.emit_signal(app_data.station, "SurfaceChanged")
    -- end)
    if args.subscribe_on_layout ~= nil then
        for sig_name, callback in pairs(args.subscribe_on_layout) do
            tstation.subscribe_signal(layout_data.station, sig_name, callback)
        end
    end
    -- emit "Init" before we check for the children. Children can also be appended
    -- by whoever is listening to the "Init" signal
    -- Note: elements can also subscribe to signals on the layout_data station,
    -- but since the subscription happens AFTER "Init" is emitted, they won't
    -- receive the "Init" signal
    tstation.emit_signal(layout_data.station, "Init", {
        app_data = layout_data.app_data,
        layout_data = layout_data
    })
    local first_child = layout_data[1] -- TODO: add a standard way of getting children

    if layout_data.bg ~= nil then
        _draw_window(layout_data.bg, layout_data.cr) -- TODO: maybe redraw the window only sometimes?
    end
    if first_child ~= nil then

        local first_elements = tarray.from_table(layout_data)

        for _, child in ipairs(first_elements) do
            -- subscribe the signals of elements to the app_data station AFTER 'Init'
            -- was emitted, because some elements only get attached after init was emitted
            internal_e.subscribe_element_signals_recursively(layout_data.app_data, layout_data, child)

            -- local _id_table = {}
            -- _populate_id_table(_id_table, child)
            -- layout_data.id_table = _id_table
        end

        local geom = layout_data.drawable:geometry()
        layout_data.processed_tree = internal_e.process_first_elements(
            first_elements, geom.width, geom.height
        )

        -- draw everything once when the layout is created
        for _, child in ipairs(first_elements) do
            internal_e.draw_processed_branch(child, layout_data.cr)
        end
    end

    drawable:refresh()

    return layout_data
end



return {
    SIDE_TOP = SIDE_TOP,
    SIDE_RIGHT = SIDE_RIGHT,
    SIDE_BOTTOM = SIDE_BOTTOM,
    SIDE_LEFT = SIDE_LEFT,

    TitleChanged = TitleChanged,

    new = new,
}
