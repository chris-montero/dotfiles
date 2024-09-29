
local extension = require("elemental.extension")
local internal_es = require("elemental.elements.internal")
local eutil = require("elemental.util")
local ttable = require("tools.table")

local function _get_parent_border_radius(shadow_el)
    if shadow_el._parent == nil then return 0 end

    local bg = shadow_el._parent.bg
    if bg == nil then return 0 end

    if bg.border_radius == nil then return 0 end
    return eutil.standardize_border_radius(bg.border_radius)
end

local function new(args)

    local defaults = {
        _draw = function(self, cr, width, height)
            local parent_border_radius = _get_parent_border_radius(self)
            internal_es.draw_shadow(self, cr, width, height, parent_border_radius)
        end,
    }

    local ext = extension.new()
    ttable.override_b_to_a(defaults, args)
    ttable.override_b_to_a(ext, defaults)
    return ext

end

return {
    new = new,
}
