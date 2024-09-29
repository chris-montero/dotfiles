
local cairo = require("lgi").cairo
local internal_es = require("elemental.elements.internal")
local el = require("elemental.elements.el")
local esource = require("elemental.source")
local m_signals = require("elemental.mouse_signals")
local tstation = require("tools.station")
local tarray = require("tools.array")
local tcolor = require("tools.color")
local gsurf = require("gears.surface")
-- local unveil = require("tools.unveil")

-- draws a processed branch onto a cairo context
local function draw_processed_branch(processed_branch, cr)

    local geometry = processed_branch.geometry
    -- unveil.dump(processed_branch, {
    --     ignore_fields = {
    --         app_data = true,
    --         layout_data = true,
    --         _parent = true,
    --     }
    -- })

    local draw_func = processed_branch._draw
    local before_draw_children = processed_branch._before_draw_children
    local after_draw_children = processed_branch._after_draw_children

    local branch_x = geometry.x
    local branch_y = geometry.y
    local branch_x_floor, branch_x_fractional_part = math.modf(branch_x)
    local branch_y_floor, branch_y_fractional_part = math.modf(branch_y)
    local branch_width = geometry.width
    local branch_height = geometry.height

    -- if an element asks for transparency, push all drawing to a temporary 
    -- surface
    if processed_branch.opacity < 1 then
        cr:push_group()
    end

    if draw_func ~= nil then
        cr:save()

        -- go to where the element's geometry says we should draw
        cr:translate(branch_x_floor, branch_y_floor)
        cr:rectangle(
            0,
            0,
            math.ceil(branch_width + branch_x_fractional_part + 1),
            math.ceil(branch_height + branch_y_fractional_part + 1)
        )
        cr:clip()

        -- check if we have an empty clip first. no reason to draw if it won't be seen
        local clip_x, clip_y, clip_w, clip_h = cr:clip_extents()
        if clip_x ~= clip_w and clip_y ~= clip_h then
            cr:translate(branch_x_fractional_part, branch_y_fractional_part)
            draw_func(processed_branch, cr, branch_width, branch_height)
        end




        -- -- go to where the element's geometry says we should draw
        -- cr:translate(branch_x_floor, branch_y_floor)
        -- cr:rectangle(
        --     -1,
        --     -1,
        --     math.ceil(branch_width + branch_x_fractional_part + 2),
        --     math.ceil(branch_height + branch_y_fractional_part + 2)
        -- )
        -- cr:clip()

        -- -- check if we have an empty clip first. no reason to draw if it won't be seen
        -- local clip_x, clip_y, clip_w, clip_h = cr:clip_extents()
        -- if clip_x ~= clip_w and clip_y ~= clip_h then
        --     cr:translate(branch_x_fractional_part, branch_y_fractional_part)
        --     draw_func(processed_branch, cr, branch_width, branch_height)
        -- end




        cr:restore()
    end

    cr:translate(branch_x, branch_y)

    if before_draw_children ~= nil then
        before_draw_children(processed_branch, cr, branch_width, branch_height)
    end

    cr:translate(-branch_x, -branch_y)

    if processed_branch.get_all_children ~= nil then
        for _, child in ipairs(processed_branch:get_all_children()) do
            draw_processed_branch(child, cr)
        end
    end

    cr:translate(branch_x, branch_y)
    if after_draw_children ~= nil then
        after_draw_children(processed_branch, cr, branch_width, branch_height)
    end

    -- pop the surface pushed above and paint it, but with the requested amount 
    -- of transparency
    if processed_branch.opacity < 1 then
        local drawn_branch = cr:pop_group()
        cr:set_operator(cairo.Operator.OVER)
        cr:set_source(drawn_branch)
        cr:paint_with_alpha(processed_branch.opacity)

        -- free the surface now
        local status, surf = drawn_branch:get_surface()
        if status == "SUCCESS" then
            surf:finish()
        end
    end

    cr:translate(-branch_x, -branch_y)

    assert(cr.status == "SUCCESS", "Cairo context entered error state: " .. cr.status)
end

-- geometries can have floating point values. clip areas shouldn't. Given the
-- geometry of an element, this function returns a table with x, y, width, height
-- as integers
local function geometry_to_clip_area(geom)

    -- note: when clipping, these values should always be integers, in 
    -- order to have the rectangle be on pixel aligned coordinates. We do
    -- this because the cairo docs suggest this would be fastest.
    -- https://www.cairographics.org/FAQ/#clipping_performance
    local branch_x_floor, branch_x_fractional_part = math.modf(
        geom.x
    )
    local branch_y_floor, branch_y_fractional_part = math.modf(
        geom.y
    )

    return {
        x = branch_x_floor,
        y = branch_y_floor,
        width = math.ceil(geom.width
            + branch_x_fractional_part
        ),
        height = math.ceil(geom.height
            + branch_y_fractional_part
        )
    }
end

local function create_empty_window_changes()
    return {
        relayout_needed = false,
        redraw_needed = false,
        someone_needs_relayout = false,
        someone_needs_redraw = false,
        element_changes = {}
    }
end

local function do_we_need_to_redraw(layout_data)
    if layout_data.window_changes.someone_needs_relayout == true then
        return true
    end
    if layout_data.window_changes.someone_needs_redraw == true then
        return true
    end
    return false
end


-- we have to put this in a separate function. If we just create a table,
-- all elements will get a reference to the same table.
local function _pack_first_args(app_data, layout_data, element)
    return {
        app_data = app_data,
        layout_data = layout_data,
        element = element
    }
end
local function subscribe_element_signals_recursively(app_data, layout_data, element)
    -- TODO: add reference to `_app_data` somewhere else, or change the function name
    -- When the user manipulates this element and marks it with "mark_redraw",
    -- we track the changes (which we store in the layout_data), and then, when
    -- we decide what to redraw, we can figure out the least amount of work we
    -- need to do
    element.app_data = app_data
    element.layout_data = layout_data

    if element.subscribe_on_global ~= nil then
        for sig_name, callback in pairs(element.subscribe_on_global) do
            tstation.subscribe_signal_with_data(
                app_data.global_station,
                sig_name,
                callback,
                _pack_first_args(app_data, layout_data, element)
            )
        end
    end

    -- the field is called "subscribe_on_app" because we subscribe the callbacks
    -- given to when the `signal` is emitted on the station of the application
    if element.subscribe_on_app ~= nil then
        for sig_name, callback in pairs(element.subscribe_on_app) do
            tstation.subscribe_signal_with_data(
                app_data.station,
                sig_name,
                callback,
                -- we want the subscriber to have access to itself, and the layout_data
                -- when `sig_name` is emitted
                _pack_first_args(app_data, layout_data, element)
            )
        end
    end

    -- some elements might want to be subscribed to the layout_data station.
    -- The only signals that we currently emit on that station are mouse signals
    -- that happen on the drawable we use to draw on. (not to be confused with 
    -- wibox.drawable)
    if element.subscribe_on_layout ~= nil then
        for sig_name, callback in pairs(element.subscribe_on_layout) do
            tstation.subscribe_signal_with_data(
                layout_data.station,
                sig_name,
                callback,
                _pack_first_args(app_data, layout_data, element)
            )
        end
    end

    -- for every signal in subscribe_on_element, subscribe to that signal on the
    -- station of the element, and call whatever callback the element wants.
    -- we do this here because we want to also add references to the app_data,
    -- the layout_data and the element itself
    if element.subscribe_on_element ~= nil then
        for sig_name, callback in pairs(element.subscribe_on_element) do
            tstation.subscribe_signal_with_data(
                element.station,
                sig_name,
                callback,
                _pack_first_args(app_data, layout_data, element)
            )
        end
    end

    if element.get_all_children == nil then
        return
    end

    local all_children = element:get_all_children()
    for _, child in ipairs(all_children) do
        subscribe_element_signals_recursively(app_data, layout_data, child)
    end
end

local function point_is_in_element(element_geom, point_x, point_y)
    if point_x < element_geom.x then return false end
    if point_x > element_geom.x + element_geom.width then return false end
    if point_y < element_geom.y then return false end
    if point_y > element_geom.y + element_geom.height then return false end
    return true
end

local function get_elements_under_point(elements, point_x, point_y)

    local function _dig(acc, children, x, y)
        --TODO: add a standard way of getting children
        for _, child in ipairs(children) do
            local element_geom = child.geometry
            if point_is_in_element(element_geom, x, y) then
                table.insert(acc, child)
            end
            if child.get_all_children ~= nil then
                _dig(acc, child:get_all_children(), x, y)
            end
        end
        return acc
    end

    -- TODO: figure out a way to make the processed_tree not be a list of elements
    if elements[1] == nil then
        return {}
    end

    return _dig({}, elements, point_x, point_y)
end

local function process_tree(current_branch, data)

    -- local rel_x = data.rel_x
    -- local rel_y = data.rel_y
    local abs_x = data.abs_x
    local abs_y = data.abs_y
    local width = data.width
    local height = data.height
    local parent = data.parent
    local address = data.address

    current_branch._parent = parent
    current_branch._address = address

    current_branch:_set_geometry(abs_x, abs_y, width, height)



    if current_branch._layout_children == nil then return end
    local positioned_children_data = current_branch:_layout_children(width, height)
    if positioned_children_data == nil then return end

    for k, child_geometry_data in ipairs(positioned_children_data) do
        local child = child_geometry_data.element

        -- use shallow_copy because it's just numbers
        local new_address = tarray.shallow_copy(address)
        table.insert(new_address, k)

        process_tree(child, {
            address = new_address,
            parent = current_branch,
            -- rel_x = child_geometry_data.x,
            -- rel_y = child_geometry_data.y,
            abs_x = abs_x + child_geometry_data.x,
            abs_y = abs_y + child_geometry_data.y,
            width = child_geometry_data.width,
            height = child_geometry_data.height
        })
    end
end

local function process_first_elements(first_elements, available_width, available_height)

    -- since our layout algorithms work based on allowing children to set properties
    -- that parents use for their layout, we create an element to put the first
    -- user-supplied elements
    local fake_root = el.new({
        width = available_width,
        height = available_height,
        unpack(first_elements)
    })

    local processed_first_elements = internal_es.position_children_el(
        internal_es.dimensionate_children_el(fake_root, available_width, available_height)
    )

    for k, child_data in ipairs(processed_first_elements) do
        process_tree(child_data.element, -- the child itself
            {
            address = { k },
            parent = nil,
            -- rel_x = child_data.x,
            -- rel_y = child_data.y,
            abs_x = child_data.x,
            abs_y = child_data.y,
            width = child_data.width,
            height = child_data.height,
        })
    end

    return first_elements
end

-- returns a list of the fewest elements that need a relayout
-- for example: if 'b' is the child of 'a', and they're both marked as requiring
-- a relayout, only { a } will be returned because 'b' will automatically be
-- relayouted when 'a' will be
local function changes_to_layout_elements(element_changes)
    local function dig(els_to_relayout, current_el_changes)
        if current_el_changes.relayout_needed ~= nil then
            table.insert(els_to_relayout, current_el_changes.relayout_needed)
            return
        end

        for k, elem in pairs(current_el_changes) do
            if k ~= "redraw_needed" and k ~= "relayout_needed" then
                dig(els_to_relayout, elem)
            end
        end
    end

    local elements_needing_relayout = {}
    dig(elements_needing_relayout, element_changes)
    return elements_needing_relayout
end

local function changes_to_redraw_elements(element_changes)
    local function dig(els_to_redraw, current_el_changes)
        if current_el_changes.redraw_needed ~= nil then
            table.insert(els_to_redraw, current_el_changes.redraw_needed)
            -- since we don't early return here, this function will keep descending 
            -- and get all the elements that want to be redrawn, not just the first
            -- one we find
        end

        for k, elem in pairs(current_el_changes) do
            if k ~= "redraw_needed" and k ~= "relayout_needed" then
                dig(els_to_redraw, elem)
            end
        end
    end

    local elements_to_redraw = {}
    dig(elements_to_redraw, element_changes)
    return elements_to_redraw
end

local function debug_relayout_invalid_elements(layout_data)

    local window_changes = layout_data.window_changes
    local window_geom = layout_data.drawable:geometry()

    local was_anything_relayouted = false

    layout_data.relayout_rects = {}

    if layout_data.window_changes.relayout_needed == true then

        local first_elements = layout_data.processed_tree
        if first_elements ~= nil then
            process_first_elements(first_elements, window_geom.width, window_geom.height)
            was_anything_relayouted = true
        end
    else
        local elements_to_relayout = changes_to_layout_elements(window_changes.element_changes)
        if #elements_to_relayout > 0 then
            was_anything_relayouted = true
        end
        for _, elem in ipairs(elements_to_relayout) do
            -- if elem.id == "dumb_text" then
            --     unveil.dump(elem, {
            --         ignore_fields = {
            --             _parent = true,
            --             app_data = true,
            --             layout_data = true,
            --         }
            --     })
            -- end
            process_tree(elem, {
                address = elem._address,
                -- rel_x = elem.processed_data.relative_coordinates.x,
                -- rel_y = elem.processed_data.relative_coordinates.y,
                abs_x = elem.geometry.x,
                abs_y = elem.geometry.y,
                width = elem.geometry.width,
                height = elem.geometry.height,
                parent = elem._parent
            })

            table.insert(layout_data.relayout_rects, geometry_to_clip_area(elem.geometry))
        end
    end

    return was_anything_relayouted

end

local function debug_compute_changes_and_clip_dirty_areas(layout_data)

    local cr = layout_data.cr
    local window_changes = layout_data.window_changes

    -- reset clip so we can draw anywhere on the window
    cr:reset_clip()

    -- if we need to redraw the whole window, skip the whole step of getting
    -- all elements that need to be redrawn. just relayout what needs to be
    -- relayouted, and return. we reset the clip above, so when the call
    -- to "draw_processed_branch" will be made, the whole window will be redrawn
    if window_changes.redraw_needed == true then
        debug_relayout_invalid_elements(layout_data)
        return
    end

    local dirty_region = cairo.Region.create()
    local elements_to_redraw = changes_to_redraw_elements(layout_data.window_changes.element_changes)

    -- mark the areas of the elements that need to be redrawn BEFORE anything is
    -- relayouted

    layout_data.before_redraw_rects = {}

    for _, elem in ipairs(elements_to_redraw) do
        dirty_region:union_rectangle(
            cairo.RectangleInt(geometry_to_clip_area(elem.geometry))
        )
        table.insert(layout_data.before_redraw_rects, geometry_to_clip_area(elem.geometry))
    end

    local was_anything_relayouted = debug_relayout_invalid_elements(layout_data)

    layout_data.after_redraw_rects = {}
    -- and now, mark those same elements AFTER things were relayouted (if they were)
    if was_anything_relayouted then
        for _, elem in ipairs(elements_to_redraw) do
            dirty_region:union_rectangle(
                cairo.RectangleInt(geometry_to_clip_area(elem.geometry))
            )
            table.insert(layout_data.after_redraw_rects, geometry_to_clip_area(elem.geometry))
        end
    end

    for i=0, dirty_region:num_rectangles() - 1 do
        local rect = dirty_region:get_rectangle(i)
        cr:rectangle(rect.x, rect.y, rect.width, rect.height)
    end

    cr:clip()

    -- layout_data.elements_to_relayout = elements_to_relayout
    -- layout_data.elements_to_redraw = elements_to_redraw

end


local function relayout_invalid_elements(layout_data)

    local window_changes = layout_data.window_changes
    local window_geom = layout_data.drawable:geometry()

    local was_anything_relayouted = false

    if layout_data.window_changes.relayout_needed == true then

        local first_elements = layout_data.processed_tree
        if first_elements ~= nil then
            process_first_elements(first_elements, window_geom.width, window_geom.height)
            was_anything_relayouted = true
        end
    else
        local elements_to_relayout = changes_to_layout_elements(window_changes.element_changes)
        if #elements_to_relayout > 0 then
            was_anything_relayouted = true
        end
        for _, elem in ipairs(elements_to_relayout) do
            process_tree(elem, {
                address = elem._address,
                -- rel_x = elem.processed_data.relative_coordinates.x,
                -- rel_y = elem.processed_data.relative_coordinates.y,
                abs_x = elem.geometry.x,
                abs_y = elem.geometry.y,
                width = elem.geometry.width,
                height = elem.geometry.height,
                parent = elem._parent
            })
        end
    end

    return was_anything_relayouted

end


local function compute_changes_and_clip_dirty_areas(layout_data)

    local cr = layout_data.cr
    local window_changes = layout_data.window_changes

    -- reset clip so we can draw anywhere on the window
    cr:reset_clip()

    -- if we need to redraw the whole window, skip the whole step of getting
    -- all elements that need to be redrawn. just relayout what needs to be
    -- relayouted, and return. we reset the clip above, so when the call
    -- to "draw_processed_branch" will be made, the whole window will be redrawn
    if window_changes.redraw_needed == true then
        relayout_invalid_elements(layout_data)
        return
    end

    local dirty_region = cairo.Region.create()
    local elements_to_redraw = changes_to_redraw_elements(layout_data.window_changes.element_changes)

    -- mark the areas of the elements that need to be redrawn BEFORE anything is
    -- relayouted

    -- cache functions for better performance; TODO: benchmark
    local union_rect = cairo.Region.union_rectangle
    local rect_int = cairo.RectangleInt
    local cr_rect = cr.rectangle

    for _, elem in ipairs(elements_to_redraw) do
        union_rect(dirty_region,
            rect_int(geometry_to_clip_area(elem.geometry))
        )
    end

    local was_anything_relayouted = relayout_invalid_elements(layout_data)

    -- and now, mark those same elements AFTER things were relayouted (if they were)
    if was_anything_relayouted then
        for _, elem in ipairs(elements_to_redraw) do
            union_rect(dirty_region,
                rect_int(geometry_to_clip_area(elem.geometry))
            )
        end
    end

    for i=0, dirty_region:num_rectangles() - 1 do
        local rect = dirty_region:get_rectangle(i)
        cr_rect(cr, rect.x, rect.y, rect.width, rect.height)
    end

    cr:clip()

    -- layout_data.elements_to_relayout = elements_to_relayout
    -- layout_data.elements_to_redraw = elements_to_redraw

end

local function create_new_cairo_context(drawable)
    local cr = cairo.Context(gsurf.load_silently(drawable.surface, false))
    cr:set_antialias(cairo.Antialias.FAST)
    local font_options = cairo.FontOptions.create()
    cairo.FontOptions.set_antialias(font_options, cairo.Antialias.SUBPIXEL)
    cr:set_font_options(font_options)
    return cr
end

-- an element can have a property like "mouse_input_stop = { MouseMove = true }".
-- if it does, we go through all elements under the mouse, from
-- last ("highest" element), to first ("lowest" element), and when an element
-- has a property like this, all the children under this element don't get
-- the mouse signal by that name
local function get_approved_mouse_hit_elements(elements_under_mouse, signal)
    local approved_elements = {}
    for i=#elements_under_mouse, 1, -1 do
        local elem = elements_under_mouse[i]
        table.insert(approved_elements, elem)
        if elem.mouse_input_stop ~= nil
            and elem.mouse_input_stop[signal] == true
        then
            return approved_elements
        end
    end
    return approved_elements
end

local function subscribe_everyone_to_mouse_signals(drawable, layout_data)

    drawable:connect_signal("button::press", function(_, mouse_x, mouse_y, btn_nr, modifiers)
        tstation.emit_signal(layout_data.station, m_signals.MouseButtonPressed, {
            x = mouse_x,
            y = mouse_y,
            button_number = btn_nr,
            modifiers = modifiers
        })
        --     x = mouse_x,
        --     y = mouse_y,
        --     button_number = btn_nr,
        --     modifiers = modifiers
        -- })

        local processed_tree = layout_data.processed_tree
        if processed_tree == nil then return end

        -- TODO: figure out a way to make the processed_tree not be a list of elements
        local processed_els_under_mouse = get_elements_under_point(processed_tree, mouse_x, mouse_y)
        local approved_elements_under_mouse = get_approved_mouse_hit_elements(processed_els_under_mouse, m_signals.MouseButtonPressed)
        for _, processed_hit_el in ipairs(approved_elements_under_mouse) do
            local element_geom = processed_hit_el.geometry
            tstation.emit_signal(
                processed_hit_el.station,
                m_signals.MouseButtonPressed,
                {
                    x = mouse_x - element_geom.x,
                    y = mouse_y - element_geom.y,
                    button_number = btn_nr,
                    modifiers = modifiers
                }
            )
        end
    end)

    drawable:connect_signal("button::release", function(_, mouse_x, mouse_y, btn_nr, modifiers)
        tstation.emit_signal(layout_data.station, m_signals.MouseButtonReleased, {
            x = mouse_x,
            y = mouse_y,
            button_number = btn_nr,
            modifiers = modifiers
        })

        local processed_tree = layout_data.processed_tree
        if processed_tree == nil then return end

        -- TODO: figure out a way to make the processed_tree not be a list of elements
        local processed_els_under_mouse = get_elements_under_point(processed_tree, mouse_x, mouse_y)
        local approved_elements_under_mouse = get_approved_mouse_hit_elements(processed_els_under_mouse, m_signals.MouseButtonReleased)
        for _, processed_hit_el in ipairs(approved_elements_under_mouse) do
            local element_geom = processed_hit_el.geometry
            tstation.emit_signal(
                processed_hit_el.station,
                m_signals.MouseButtonReleased,
                {
                    x = mouse_x - element_geom.x,
                    y = mouse_y - element_geom.y,
                    button_number = btn_nr,
                    modifiers = modifiers
                }
            )
        end
    end)
    -- TODO: also implement mouse_entered on elements
    drawable:connect_signal("mouse::enter", function(_)
        tstation.emit_signal(layout_data.station, m_signals.MouseEntered)
    end)
    -- TODO: also implement mouse_left on elements
    drawable:connect_signal("mouse::leave", function(_)
        tstation.emit_signal(layout_data.station, m_signals.MouseLeft)
    end)

    drawable:connect_signal("mouse::move", function(_, mouse_x, mouse_y)
        tstation.emit_signal(layout_data.station, m_signals.MouseMoved, { x = mouse_x, y = mouse_y })

        local processed_tree = layout_data.processed_tree
        if processed_tree == nil then return end

        -- TODO: figure out a way to make the processed_tree not be a list of elements
        local processed_els_under_mouse = get_elements_under_point(processed_tree, mouse_x, mouse_y)
        local approved_elements_under_mouse = get_approved_mouse_hit_elements(processed_els_under_mouse, m_signals.MouseMoved)
        for _, processed_hit_el in ipairs(approved_elements_under_mouse) do
            local element_geom = processed_hit_el.geometry
            tstation.emit_signal(
                processed_hit_el.station,
                m_signals.MouseMoved,
                {
                    -- by doing this trick, we get the relative coords we should emit on the element
                    x = mouse_x - element_geom.x,
                    y = mouse_y - element_geom.y
                }
            )
        end
    end)
end

return {
    point_is_in_element = point_is_in_element,
    create_empty_window_changes = create_empty_window_changes,
    changes_to_layout_elements = changes_to_layout_elements,
    changes_to_redraw_elements = changes_to_redraw_elements,
    debug_compute_changes_and_clip_dirty_areas = debug_compute_changes_and_clip_dirty_areas,
    debug_relayout_invalid_elements = debug_relayout_invalid_elements,
    relayout_invalid_elements = relayout_invalid_elements,
    compute_changes_and_clip_dirty_areas = compute_changes_and_clip_dirty_areas,
    process_tree = process_tree,
    process_first_elements = process_first_elements,
    create_new_cairo_context = create_new_cairo_context,
    subscribe_element_signals_recursively = subscribe_element_signals_recursively,
    subscribe_everyone_to_mouse_signals = subscribe_everyone_to_mouse_signals,
    do_we_need_to_redraw = do_we_need_to_redraw,
    draw_processed_branch = draw_processed_branch,
    get_elements_under_point = get_elements_under_point,
    get_approved_mouse_hit_elements = get_approved_mouse_hit_elements,
}


