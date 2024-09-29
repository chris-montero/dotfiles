
local extension = require("elemental.extension")
local einternal = require("elemental.internal")
local etypes = require("elemental.types")
local eutil = require("elemental.util")
local size = etypes.size
local align = etypes.align
local layout = etypes.layout
local ttable = require("tools.table")

local function _assert_layout_exists(element)
    local layout_missing_msg = "the element must have a reference to the original "
    .. "layout data. Maybe you called a function to modify an element on an element"
    .. "that hadn't yet been attached to a layout?"
    assert(element.layout_data ~= nil, layout_missing_msg)
end


-- a "clean" parent is an element whose layout data doesn't change
-- if any of its children experiences a change that necessitates its relayout.
-- this means we can use that parent's absolute x, y, width, and height to
-- relayout its children.
-- this is best explained through an example:

-- consider the following layout of elements:

-- _ e1
-- |
-- |__ e2
-- | |
-- | |__ e3
-- | | |

-- let e1 have width = 200
-- let e2 have width = "shrink"
-- let e3 have width = 80

-- imagine the width of e3 changes from 80 to 90

-- then, the "first_clean_parent" would be e1. this is because if the width of e3
-- changes, then the width of its parent (e2) would also change because it's
-- of type "shrink". so the first parent whose current layout data we can use
-- to relayout the least amount of elements correctly is e1
local function _find_first_clean_width_parent(changed_el)

    local parent = changed_el.parent
    if parent == nil then
        return nil
    end

    local user_set_width = parent.width

    if type(user_set_width) == "number" or etypes.is_size_fill(user_set_width) then
        return parent
    else
        return _find_first_clean_width_parent(parent)
    end

end

local function _find_first_clean_height_parent(changed_el)

    local parent = changed_el.parent
    if parent == nil then
        return nil
    end

    local user_set_height = parent.height

    if type(user_set_height) == "number" or etypes.is_size_fill(user_set_height) then
        return parent
    else
        return _find_first_clean_height_parent(parent)
    end
end

local function vertical(args)

    local defaults = {
        _layout_type = layout.vertical,
        _before_draw_children = _draw_element_before,
        _after_draw_children = _draw_element_after,
        _layout_children = einternal.layout_children_vertical,
        _calculate_minimum_dimensions = einternal.calculate_minimum_dimensions_vertical,
    }
    local ext = extension.new()
    ttable.override_b_to_a(defaults, args)
    ttable.override_b_to_a(ext, defaults)
    return ext
end

local function set_opacity(element, val)
    _assert_layout_exists(element)
    if element.opacity == val then return end
    element.opacity = val or 1 --TODO: sanitize this
    local element_changes = element._layout.window_changes.element_changes
    eutil.mark_redraw(element_changes, element)
end

local function set_width(element, val)
    _assert_layout_exists(element)
    if element.width == val then return end -- TODO: might have to check better for equality between table values
    element.width = val or size.shrink --TODO: sanitize this

    local window_changes = element._layout.window_changes
    local first_clean_parent = _find_first_clean_width_parent(element)
    if first_clean_parent == nil then -- means we need to redraw the whole window
        window_changes.layout_needed = true -- a bit of a hack, but it should work
    else
        eutil.mark_relayout(window_changes.element_changes, first_clean_parent)
    end
end

local function set_height(element, val)
    _assert_layout_exists(element)
    if element.height == val then return end -- TODO: might have to check better for equality between table values
    element.height = val or size.shrink --TODO: sanitize this

    local window_changes = element._layout.window_changes
    local first_clean_parent = _find_first_clean_height_parent(element)
    if first_clean_parent == nil then
        window_changes.layout_needed = true
    else
        eutil.mark_relayout(window_changes.element_changes, first_clean_parent)
    end
end

local function set_valign(element, val)
    _assert_layout_exists(element)
    if element.valign == val then return end
    element.valign = val or align.top --TODO: sanitize this

    local window_changes = element._layout.window_changes
    local element_processed_height = element.geometry.height
    local parent_processed_height
    local parent = element.parent
    if parent == nil then
        parent_processed_height = element._layout.height
    else
        parent_processed_height = parent.geometry.height
    end

    -- use ceil because when drawn, floating point values will get `ceil`'ed anyway
    if math.ceil(parent_processed_height) == math.ceil(element_processed_height) then
        -- if there's no space to valign the element, no need to redraw.
        -- just set the new valign and return
        return -- valign was already set above
    end

    if parent == nil then
        window_changes.layout_needed = true
    else
        eutil.mark_relayout(window_changes.element_changes, parent)
    end
end

local function set_halign(element, val)
    _assert_layout_exists(element)
    if element.halign == val then return end
    element.halign = val or align.left --TODO: sanitize this

    local window_changes = element._layout.window_changes
    local element_processed_width = element.geometry.width
    local parent_processed_width
    local parent = element.parent
    if parent == nil then
        parent_processed_width = element._layout.width
    else
        parent_processed_width = parent.geometry.width
    end

    if math.ceil(parent_processed_width) == math.ceil(element_processed_width) then
        return -- halign was already set above
    end

    if parent == nil then
        window_changes.layout_needed = true
    else
        eutil.mark_relayout(window_changes.element_changes, parent)
    end
end

local function set_padding(element, val)
    _assert_layout_exists(element)
    if element.padding == val then return end -- TODO: might have to check better for equality between table values

    local old_sp = eutil.standardize_padding(element.padding)
    local new_sp = eutil.standardize_padding(val)
    element.padding = val or 0 --TODO: sanitize this

    local window_changes = element._layout.window_changes
    local element_changes = window_changes.element_changes

    if etypes.is_size_shrink(element.width) == false and etypes.is_size_shrink(element.height) == false then
        element.padding = val or 0 --TODO: sanitize this
        eutil.mark_relayout(element_changes, element)
        return
    end

    local old_top = old_sp.top
    local old_right = old_sp.right
    local old_bottom = old_sp.bottom
    local old_left = old_sp.left

    local new_top = new_sp.top
    local new_right = new_sp.right
    local new_bottom = new_sp.bottom
    local new_left = new_sp.left

    -- by default use the current element. this will change if it has
    -- width/height == size.shrink
    local first_safe_width_el = element
    local first_safe_height_el = element
    if old_top == new_top and old_bottom == new_bottom then
        if old_left == new_left and old_right == new_right then
            return -- nothing changed
        else
            if etypes.is_size_shrink(element.width) then
                first_safe_width_el = _find_first_clean_width_parent(element)
            end
        end
    else
        if old_left == new_left and old_right == new_right then
            if type.is_size_shrink(element.height) then
                first_safe_height_el = _find_first_clean_height_parent(element)
            end
        else
            if etypes.is_size_shrink(element.width) then
                first_safe_width_el = _find_first_clean_width_parent(element)
            end
            if etypes.is_size_shrink(element.height) then
                first_safe_height_el = _find_first_clean_height_parent(element)
            end
        end
    end

    -- if any of the "clean parents" are nil, that means the only "element" with
    -- a correct width/height we can use is the window, so relayout everything
    if first_safe_width_el == nil or first_safe_height_el == nil then
        window_changes.layout_needed = true
        return
    end

    -- we mark the element with the "shorter" address. by doing this, the
    -- element with the longer address will automatically end up being re-layouted
    if #first_safe_width_el.address < #first_safe_height_el.address then
        eutil.mark_relayout(element_changes, first_safe_width_el)
    else
        eutil.mark_relayout(element_changes, first_safe_height_el)
    end
end


local function set_spacing(element, val)
    _assert_layout_exists(element)
    if element.spacing == val then return end
    element.spacing = val --TODO: sanitize this

    local window_changes = element._layout.window_changes
    local element_changes = window_changes.element_changes

    local safe_layout_el = element
    if element._layout_type == layout.horizontal then
        if etypes.is_size_shrink(element.width) then
            safe_layout_el = _find_first_clean_width_parent(element) --TODO: can you find first parent if there's a custom extension in the way?
        end
    elseif element._layout_type == layout.vertical then
        if etypes.is_size_shrink(element.height) then
            safe_layout_el = _find_first_clean_width_parent(element)
        end
    else -- LAYOUT_EL
        return
    end

    if safe_layout_el == nil then
        window_changes.layout_needed = true
    else
        eutil.mark_relayout(element_changes, safe_layout_el)
    end
end


return {

    -- padding_axis = padding_axis,
    -- padding_each = padding_each,

    -- set_opacity = set_opacity,
    -- set_width = set_width,
    -- set_height = set_height,
    -- set_valign = set_valign,
    -- set_halign = set_halign,
    -- set_padding = set_padding,
    -- set_spacing = set_spacing,

}





