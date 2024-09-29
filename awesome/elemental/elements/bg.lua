
local extension = require("elemental.extension")
local ttable = require("tools.table")
local internal_es = require("elemental.elements.internal")

local function new(args)

    local defaults = {
        _draw = function(self, cr, width, height)
            cr:save()
            internal_es.draw_border(self, cr, width, height)
            cr:restore()
            internal_es.draw_background(self, cr, width, height)
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
