

local PADDING_AXIS = 1
local PADDING_EACH = 2

local BORDER_EACH = 1

local function is_size_shrink(v)
    return type(v) == "table" and v.type == 1
end

local function is_size_fill(v)
    return type(v) == "table" and v.type == 2
end

local function is_padding_each(p)
    if p.type == PADDING_EACH then return true end
    return false
end
local function is_padding_axis(p)
    if p.type == PADDING_AXIS then return true end
    return false
end


local function padding_axis(args)

    local x = args.x or 0
    local y = args.y or 0
    assert(type(x) == "number", "key 'x' should be number, got: " .. tostring(x))
    assert(type(y) == "number", "key 'y' should be number, got: " .. tostring(y))

    return {
        type = PADDING_AXIS,
        x = x,
        y = y
    }
end

local function padding_each(args)

    local top = args.top or 0
    local right = args.right or 0
    local bottom = args.bottom or 0
    local left = args.left or 0

    assert(type(top) == "number", "key 'top' should be number, got: " .. tostring(top))
    assert(type(right) == "number", "key 'right' should be number, got: " .. tostring(right))
    assert(type(bottom) == "number", "key 'bottom' should be number, got: " .. tostring(bottom))
    assert(type(left) == "number", "key 'left' should be number, got: " .. tostring(left))

    return {
        type = PADDING_EACH,
        top = top,
        right = right,
        bottom = bottom,
        left = left,
    }
end

local function border_radius_each(args)

    local top_left = args.top_left or 0
    local top_right = args.top_right or 0
    local bottom_right = args.bottom_right or 0
    local bottom_left = args.bottom_left or 0

    assert(type(top_left) == "number", "key 'top_left' should be number, got: " .. tostring(top_left))
    assert(type(top_right) == "number", "key 'top_right' should be number, got: " .. tostring(top_right))
    assert(type(bottom_right) == "number", "key 'bottom_right' should be number, got: " .. tostring(bottom_right))
    assert(type(bottom_left) == "number", "key 'bottom_left' should be number, got: " .. tostring(bottom_left))

    return {
        border_type = BORDER_EACH,
        top_left = top_left,
        top_right = top_right,
        bottom_right = bottom_right,
        bottom_left = bottom_left,
    }

end

return {

    is_size_shrink = is_size_shrink,
    is_size_fill = is_size_fill,

    SIZE_SHRINK = { type = 1 },
    SIZE_FILL = { type = 2 },

    ALIGN_CENTER = 1,
    ALIGN_LEFT = 2,
    ALIGN_RIGHT = 3,
    ALIGN_TOP = 4,
    ALIGN_BOTTOM = 5,

    padding_axis = padding_axis,
    padding_each = padding_each,
    is_padding_axis = is_padding_axis,
    is_padding_each = is_padding_each,

    border_radius_each = border_radius_each,

}
