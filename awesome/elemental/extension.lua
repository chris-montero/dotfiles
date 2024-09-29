
local etypes = require("elemental.types")
local tstation = require("tools.station")
local m_signals = require("elemental.mouse_signals")

local function _subscribe_debug_signals(elem)
    tstation.subscribe_signal(elem.station, m_signals.MouseMoved, function(rel_x, rel_y)
        print("new_el:")
        unveil.dump(elem.address)
        print(rel_x, rel_y)
    end)
    tstation.subscribe_signal(elem.station, m_signals.MouseButtonPressed, function(rel_x, rel_y, btn_nr, modifiers)
        print("ELEMENT_PRESSED:")
        print(rel_x, rel_y, btn_nr)
        unveil.dump(modifiers)
        unveil.dump(elem.address)
    end)
    tstation.subscribe_signal(elem.station, m_signals.MouseButtonReleased, function(rel_x, rel_y, btn_nr, modifiers)
        print("ELEMENT_RELEASED:")
        print(rel_x, rel_y, btn_nr)
        unveil.dump(modifiers)
        unveil.dump(elem.address)
    end)
end

local function _set_geometry(self, x, y, width, height)
    self.geometry.x = x
    self.geometry.y = y
    self.geometry.width = width
    self.geometry.height = height
end

local function new()
    -- assert(args._calculate_minimum_dimensions ~= nil)

    local essentials = {
        width = etypes.SIZE_SHRINK,
        height = etypes.SIZE_SHRINK,
        station = tstation.new(),
        opacity = 1,
        _calculate_minimum_dimensions = function(_, _, _) return 0, 0 end,
        geometry = {},
        _set_geometry = _set_geometry,
    }

    -- for k, v in pairs(essentials) do
    --     if args[k] == nil then
    --         args[k] = v
    --     end
    -- end
    -- _subscribe_debug_signals(args)
    return essentials
end


return {
    new = new,
}
