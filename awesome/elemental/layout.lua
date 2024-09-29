
local cairo = require("lgi").cairo
local internal_e = require("elemental.internal")
local esource = require("elemental.source")
local tarray = require("tools.array")
local tstation = require("tools.station")
local tshape = require("tools.shape")
local tcolor = require("tools.color")


local function _debug_draw_affected_element_bounding_box(rects, cr, color)
    cr:save()
    cr:set_source(esource.to_cairo_source(color))
    cr:set_line_width(2)
    for _, rect in ipairs(rects) do
        cr:rectangle(
            math.floor(rect.x),
            math.floor(rect.y),
            math.ceil(rect.width),
            math.ceil(rect.height)
        )
    end
    cr:stroke()
    cr:restore()
end

local function mark_relayout_at_layout(layout_data)
    layout_data.window_changes.someone_needs_relayout = true
    layout_data.window_changes.relayout_needed = true
end

local function mark_redraw_at_layout(layout_data)
    layout_data.window_changes.someone_needs_redraw = true
    layout_data.window_changes.redraw_needed = true
end
-- local function mark_redraw_at_layout(layout_data)
--     layout_data.window_changes.someone_needs_redraw = true
--     layout_data.window_changes.redraw_needed = true
-- end

local function get_children(layout_data)
    return tarray.from_table(layout_data)
end

-- local function _element_is_visible(parent_ac, parent_vp, processed_element)
--     -- "_ac" suffix means "absolute_coordinates" and "_vp" suffix means "viewport_dimensions"
--     local element_ac = processed_element.processed_data.absolute_coordinates
--     local element_vp = processed_element.processed_data.viewport_dimensions
--     local element_is_visible = false

--     if element_vp.width == 0 or element_vp.height == 0 then
--         return nil
--     end

--     if element_ac.x < parent_ac.x and element_ac.y < parent_ac.y then
--         if
--             element_ac.x + element_vp.width > parent_ac.x and
--             element_ac.y + element_vp.height > parent_ac.y
--         then
--             element_is_visible = true
--         end
--     elseif
--         element_ac.x < parent_ac.x and
--         (element_ac.y > parent_ac.y and element_ac.y < parent_ac.y + parent_vp.height)
--     then
--         if element_ac.x + element_vp.width > parent_ac.x then
--             element_is_visible = true
--         end
--     elseif
--         (element_ac.x > parent_ac.x and element_ac.x < parent_ac.x + parent_vp.x) and
--         element_ac.y < parent_ac.y
--     then
--         if element_ac.y + element_vp.height > parent_ac.y then
--             element_is_visible = true
--         end
--     elseif
--         (element_ac.x > parent_ac.x and element_ac.x < parent_ac.x + parent_vp.width) and
--         (element_ac.y > parent_ac.y and element_ac.y < parent_ac.y + parent_vp.height)
--     then
--         -- if both x and y are inside the parent, the element is surely visible
--         element_is_visible = true
--     end
--     if element_is_visible then
--         return processed_element
--     end
-- end

-- -- takes as argument a table of non-contiguous elements, and returns the first
-- -- index that is `nil`. bonus points for using a generator to traverse the array
-- local function _find_free_index(elements_at_name)

--     local function one_to_inf_generator()
--         local i = 0
--         return function()
--             i = i + 1
--             return i
--         end
--     end

--     local next_num = one_to_inf_generator()

--     local function _find(els)
--         local num = next_num()
--         if els[num] == nil then
--             return num
--         end
--         return _find(els)
--     end

--     return _find(elements_at_name)

-- end

-- local function _populate_id_table(id_table, branch)

--     if branch.id ~= nil then
--         if id_table[branch.id] == nil then
--             id_table[branch.id] = {}
--         end
--         -- local next_ind = (#id_table[branch.id]) + 1
--         local free_ind = _find_free_index(id_table[branch.id])
--         id_table[branch.id][free_ind] = branch
--         branch.id_table_ind = free_ind
--     end

--     for _, child in ipairs(branch) do
--         _populate_id_table(id_table, child)
--     end
-- end

local function _reset_changes_table(layout_data)
    layout_data.window_changes = internal_e.create_empty_window_changes()
end

local function _draw_window(bg, cr)
    cr:save()
    cr.operator = cairo.Operator.SOURCE
    cr:set_source(esource.to_cairo_source(bg))
    cr:paint()
    cr:restore()
end

local function border_radius()
end

local function _shape_window(w, width, height, shape)
    local img = cairo.ImageSurface(
        cairo.Format.A1,
        width,
        height
    )
    local cr = cairo.Context(img)

    shape(cr, width, height)
    cr:set_operator(cairo.Operator.SOURCE)
    cr:fill()
    w.shape_bounding = img._native
    img:finish()
end

local function new(args)

    local x = args.x
    local y = args.y
    local width = args.width
    local height = args.height
    local bg = args.bg
    local screen = args.screen
    local visible = args.visible
    local shape = args.shape

    assert(type(x) == "number", "you must set the x coordinate of the window as a 'number', not a: " .. tostring(x))
    assert(type(y) == "number", "you must set the y coordinate of the window as a 'number', not a: " .. tostring(y))
    assert(type(width) == "number", "you must set the width of the window as a 'number', not a: " .. tostring(width))
    assert(type(height) == "number", "you must set the height of the window as a 'number', not a: " .. tostring(height))
    assert(type(visible) == "boolean", "the property 'visible' should be 'true' or 'false'")
    assert(screen ~= nil, "you must specify a screen for your layout")
    assert(type(args.app_data) == "table", "you must have a reference to a valid 'app_data' table")

    local layout_data

    local window = drawin({ -- `drawin` is part of the c api
        x = x,
        y = y,
        width = width,
        height = height,
        screen = screen,
        visible = visible,
        type = args.type or nil,
    })
    if args.struts ~= nil then window:struts(args.struts) end
    local drawable = window.drawable
    local window_geom = drawable:geometry()

    if shape then
        _shape_window(window, window_geom.width, window_geom.height, shape)
    end

    layout_data = {
        -- use this property to know this is a layout because lua doesnt have 
        -- a type system
        _very_secret_layout_identifier_property = true,
        app_data = args.app_data,

        -- station used for mouse input events that happen on this window
        station = tstation.new(),

        x = x,
        y = y,
        width = width,
        height = height,
        -- TODO: maybe the initial screen here should be called "anchor_screen"
        -- because the x & y values would be relative to this screen
        screen = screen,
        visible = visible, -- TODO: change this to "mapped"
        bg = bg,

        -- TODO: only store the scanvas and "cr" here once I get there
        window = window,
        drawable = drawable,
        cr = internal_e.create_new_cairo_context(drawable),

        id_table = {},
        processed_tree = nil, -- TODO: just process the tree here directly

        -- to be used by functions that manipulate elements and the window so
        -- we can efficiently redraw the least amount of things
        window_changes = internal_e.create_empty_window_changes()
    }

    tstation.subscribe_signal(layout_data.app_data.global_station, "TracklistBeforeTick", function(_)

        local need_new_cairo_context = false

        if layout_data.visible ~= layout_data.window.visible then
            if layout_data.visible == true then
                need_new_cairo_context = true
            end
            layout_data.window.visible = layout_data.visible
        end

        if layout_data.x ~= window_geom.x then
            layout_data.window.x = layout_data.x
            need_new_cairo_context = true
        end
        if layout_data.y ~= window_geom.y then
            layout_data.window.y = layout_data.y
            need_new_cairo_context = true
        end
        if layout_data.width ~= window_geom.width then
            layout_data.window.width = layout_data.width
            need_new_cairo_context = true
        end
        if layout_data.height ~= window_geom.height then
            layout_data.window.height = layout_data.height
            need_new_cairo_context = true
        end

        if need_new_cairo_context then
            layout_data.cr = internal_e.create_new_cairo_context(layout_data.drawable)
            -- if the cairo context changes, mark the whole window as dirty area
            mark_relayout_at_layout(layout_data)
            mark_redraw_at_layout(layout_data)
        end
    end)

    tstation.subscribe_signal(layout_data.app_data.global_station, "TracklistAfterTick", function(_)

        -- if the window is not visible then we don't even go through the 
        -- changes. this way, any changes made like elements being marked as
        -- needing a relayout will accumulate, and only be computed once when 
        -- the window becomes visible.
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

        -- uncomment to see the regions that are being relayouted
        -- if layout_data.before_redraw_rects ~= nil then
        --     _debug_draw_affected_element_bounding_box(
        --         layout_data.before_redraw_rects,
        --         layout_data.cr,
        --         tcolor.rgb_from_string("#ff0000")
        --     )
        -- end
        -- if layout_data.after_redraw_rects ~= nil then
        --     _debug_draw_affected_element_bounding_box(
        --         layout_data.after_redraw_rects,
        --         layout_data.cr,
        --         tcolor.rgb_from_string("#0000ff")
        --     )
        -- end

        -- if layout_data.relayout_rects ~= nil then
        --     _debug_draw_affected_element_bounding_box(
        --         layout_data.relayout_rects,
        --         layout_data.cr,
        --         tcolor.rgb_from_string("#00ff44")
        --     )
        -- end


        -- refresh the drawable so the drawing actually shows up
        layout_data.drawable:refresh()

        -- reset changes table so that the same changes we've just redrawn 
        -- dont show up in the next frame
        _reset_changes_table(layout_data)
    end)

    internal_e.subscribe_everyone_to_mouse_signals(drawable, layout_data)

    if args.subscribe_on_layout ~= nil then
        for sig_name, callback in pairs(args.subscribe_on_layout) do
            tstation.subscribe_signal(layout_data.station, sig_name, callback)
        end
    end

    -- emit "Init" before we check for the children. Children can also be appended
    -- by whoever is listening to the "Init" signal
    -- Note: elements can also subscribe to signals on the layout_data station,
    -- but they won't receive the "Init" signal because the subscription happens 
    -- AFTER "Init" is emitted
    tstation.emit_signal(layout_data.station, "Init", {
        app_data = layout_data.app_data,
        layout_data = layout_data
    })
    local first_child = layout_data[1] -- TODO: add a standard way of getting children

    if layout_data.bg ~= nil then
        _draw_window(layout_data.bg, layout_data.cr) -- TODO: maybe redraw the window only sometimes?
    end

    if first_child ~= nil then

        local first_elements = get_children(layout_data)

        for _, child in ipairs(first_elements) do
            -- subscribe the signals of elements to the app_data station AFTER 'Init'
            -- was emitted, because some elements only get attached after init was emitted
            internal_e.subscribe_element_signals_recursively(layout_data.app_data, layout_data, child)

            -- local _id_table = {}
            -- _populate_id_table(_id_table, child)
            -- layout_data.id_table = _id_table
        end

        layout_data.processed_tree = internal_e.process_first_elements(
            first_elements, window_geom.width, window_geom.height
        )

        -- draw all elements when the layout is created
        for _, child in ipairs(first_elements) do
            internal_e.draw_processed_branch(child, layout_data.cr)
        end

    end
    drawable:refresh()

    return layout_data
end

-- the reason we set these values on the layout_data, and do not actually redraw
-- anything yet is because we would get a crash if we change window properties
-- at the wrong time.
-- for example: the cairo context (cr) becomes invalidated the moment a property
-- like window.width changes, and you cannot draw to that context anymore. However,
-- what if you are already in the process of drawing and an input signal changes
-- window.width? We get a crash. This is why, when you change let's say the width
-- of a window, we put it in this buffer, and when the tracklist finishes the
-- loop and begins another one, we apply the window changes, create a new
-- cairo context and then we redraw
local function set_x(_layout_data, x)
    _layout_data.x = x
end
local function set_y(_layout_data, y)
    _layout_data.y = y
end
local function set_width(_layout_data, width)
    _layout_data.width = width
end
local function set_height(_layout_data, height)
    _layout_data.height = height
end
local function set_visible(_layout_data, bool)
    _layout_data.visible = bool
end

local function refresh(_layout_data)

    local need_new_cairo_context = false
    local window_geom = _layout_data.drawable:geometry()

    if _layout_data.x ~= window_geom.x then
        _layout_data.window.x = _layout_data.x
        need_new_cairo_context = true
    end
    if _layout_data.y ~= window_geom.y then
        _layout_data.window.y = _layout_data.y
        need_new_cairo_context = true
    end
    if _layout_data.width ~= window_geom.width then
        _layout_data.window.width = _layout_data.width
        need_new_cairo_context = true
    end
    if _layout_data.height ~= window_geom.height then
        _layout_data.window.height = _layout_data.height
        need_new_cairo_context = true
    end

    -- if the window geometry changed, we need a new cairo context
    if need_new_cairo_context then
        _layout_data.cr = internal_e.create_new_cairo_context(_layout_data.drawable)
        -- if the cairo context changes, mark the whole window as dirty area
        mark_relayout_at_layout(_layout_data)
    end

    internal_e.compute_changes_and_clip_dirty_areas(_layout_data)

    -- if we have a background, draw it on the window
    if _layout_data.bg ~= nil then
        _draw_window(_layout_data.bg, _layout_data.cr)
    end

    -- if we have elements, draw them
    if _layout_data.processed_tree ~= nil then
        for _, branch in ipairs(_layout_data.processed_tree) do
            internal_e.draw_processed_branch(branch, _layout_data.cr)
        end
    end

    -- refresh the drawable so the drawing actually shows up
    _layout_data.drawable:refresh()
    _reset_changes_table(_layout_data)
end

-- TODO: maybe with the signal-attach system I implemented we won't even need this at all
-- local function get_elements_by_id(_app, name)
--     local elems = _app.id_table[name]
--     if elems == nil then return {} end
--     return elems
-- end

return {
    new = new,
    border_radius = border_radius,

    set_x = set_x,
    set_y = set_y,
    set_width = set_width,
    set_height = set_height,
    set_visible = set_visible,
    refresh = refresh,

    -- get_elements_by_id = get_elements_by_id,
}

