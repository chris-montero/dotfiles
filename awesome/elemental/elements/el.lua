
local extension = require("elemental.extension")
local ttable = require("tools.table")
local internal_es = require("elemental.elements.internal")

local function new(args)

    local defaults = {
        _layout_type = internal_es.LAYOUT_EL,
        _layout_children = internal_es.layout_el,
        _calculate_minimum_dimensions = internal_es.calculate_minimum_dimensions_el,
        get_all_children = internal_es.get_all_children,
    }
    local ext = extension.new()
    ttable.override_b_to_a(defaults, args)
    ttable.override_b_to_a(ext, defaults)
    return ext
end

return {
    new = new
}
