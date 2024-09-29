
local etypes = require("elemental.types")

local function create_nodes_to_address(tab, address)
    local function _fake_recurse(current_i, t, addr)

        local current_node_nr = addr[current_i]

        if current_node_nr == nil then
            return
        end

        if t[current_node_nr] == nil then
            t[current_node_nr] = {}
        end

        _fake_recurse(current_i + 1, t[current_node_nr], addr)

    end
    _fake_recurse(1, tab, address)
end

local function get_by_address(tab, address)

    local current_node = tab

    for _, node_num in ipairs(address) do
        if current_node == nil then
            return
        end
        current_node = current_node[node_num]
    end

    return current_node
end

local function mark_relayout(element_or_layout)
    if element_or_layout._very_secret_layout_identifier_property == true then
        -- we have a layout
        element_or_layout.window_changes.someone_needs_relayout = true
        element_or_layout.window_changes.relayout_needed = true
        return
    end

    -- we have an element
    assert(element_or_layout.layout_data ~= nil, "the element must have a 'layout_data' reference.")
    if element_or_layout.layout_data.window_changes.someone_needs_relayout ~= true then
        element_or_layout.layout_data.window_changes.someone_needs_relayout = true -- to easily check if we need to relayout later
    end
    local changes_table = element_or_layout.layout_data.window_changes.element_changes
    create_nodes_to_address(changes_table, element_or_layout._address)
    local change_node = get_by_address(changes_table, element_or_layout._address)
    if change_node.relayout_needed == element_or_layout then
        return
    end
    change_node.relayout_needed = element_or_layout
end

local function mark_redraw(element_or_layout)
    if element_or_layout._very_secret_layout_identifier_property == true then
        -- we have a layout
        element_or_layout.window_changes.someone_needs_redraw = true
        element_or_layout.window_changes.redraw_needed = true
        return
    end

    -- we have an element
    assert(element_or_layout.layout_data ~= nil, "the element must have a 'layout_data' reference.")
    if element_or_layout.layout_data.window_changes.someone_needs_redraw ~= true then
        element_or_layout.layout_data.window_changes.someone_needs_redraw = true -- to easily check if we need to redraw later
    end
    local changes_table = element_or_layout.layout_data.window_changes.element_changes
    create_nodes_to_address(changes_table, element_or_layout._address)
    local change_node = get_by_address(changes_table, element_or_layout._address)
    if change_node.redraw_needed == element_or_layout then
        return
    end
    change_node.redraw_needed = element_or_layout
end

local function standardize_padding(pad)

    if type(pad) == "number" then
        return {
            top = pad,
            right = pad,
            bottom = pad,
            left = pad,
        }
    elseif etypes.is_padding_axis(pad) then
        return {
            top = pad.y,
            right = pad.x,
            bottom = pad.y,
            left = pad.x,
        }
    else -- pad.type == PADDING_EACH
        return {
            top = pad.top,
            right = pad.right,
            bottom = pad.bottom,
            left = pad.left,
        }
    end
end


local function standardize_border_radius(border_radius)

    if type(border_radius) == "number" then
        return {
            top_left = border_radius,
            top_right = border_radius,
            bottom_right = border_radius,
            bottom_left = border_radius,
        }
    else -- border_each
        border_radius.border_type = nil
        return border_radius
    end
end


-- local function _serialize_address(a)
--     local serialized = "R" -- 'R' means the root element.
--     for _, num in ipairs(a) do
--         serialized = serialized .. ',' .. tostring(num)
--     end
--     return serialized
-- end

-- local function _deserialize_address(serialized_a)

--     local address = {}

--     local numbers = string.gmatch(serialized_a, "%d+")
--     for num in numbers do
--         table.insert(address, num)
--     end

--     return address

-- end

-- local function _get_serialized_parent_address(address)
--     if #address == 0 then
--         return "T" -- return 'T' to represent the "parent" of the root node
--     end

--     local parent_address = {}
--     for k, num in ipairs(address) do
--         if k ~= #address then
--             parent_address[k] = num
--         end
--     end

--     return _serialize_address(parent_address)
-- end


return {
    mark_redraw = mark_redraw,
    mark_relayout = mark_relayout,
    create_nodes_to_address = create_nodes_to_address,
    get_by_address = get_by_address,
    standardize_padding = standardize_padding,
    standardize_border_radius = standardize_border_radius,
}
