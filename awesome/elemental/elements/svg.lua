
local extension = require("elemental.extension")
local lgi = require("lgi")
local ttable = require("tools.table")
local tcolor = require("tools.color")
local esource = require("elemental.source")

local rsvg_handle_cache = setmetatable({}, { __mode = 'k' })

---Load rsvg handle form image file
-- @tparam string file Path to svg file or svg content directly as a lua string.
-- @return Rsvg handle
-- @treturn table A table where cached data can be stored.
local function load_rsvg_handle(file)

    local cache = (rsvg_handle_cache[file] or {})["handle"]

    if cache then
        return cache, rsvg_handle_cache[file]
    end

    local handle, err

    if file:match("<[?]?xml") or file:match("<svg") then
        handle, err = lgi.Rsvg.Handle.new_from_data(file)
    else
        handle, err = lgi.Rsvg.Handle.new_from_file(file)
    end

    if not err then
        rsvg_handle_cache[file] = rsvg_handle_cache[file] or {}
        rsvg_handle_cache[file]["handle"] = handle
        return handle, rsvg_handle_cache[file]
    else
        print("error loading svg file:", err)
    end
end

local function draw(self, cr, width, height)
    if width == 0 or height == 0 then return end
    local handle = self._handle
    if handle == nil then return end

    local dim = self._handle:get_dimensions()
    local scale_w, scale_h = width / dim.width, height / dim.height
    local src = self.source or tcolor.rgb(0, 0, 0)

    cr:scale(scale_w, scale_h)
    cr:push_group_with_content(lgi.cairo.Content.ALPHA)
    handle:render_cairo(cr)
    local mask = cr:pop_group()
    cr:set_source(esource.to_cairo_source(src))
    cr:mask(mask)

    -- deallocate the surface when done
    local stat, surf = mask:get_surface()
    if stat == "SUCCESS" then surf:finish() end

end

local function calculate_minimum_dimensions(self, constraint_w, constraint_h)

    local handle = self._handle

    local elem_w, elem_h = self.width, self.height

    -- note: we don't account for the case where both width and height are 
    -- numbers because this function wouldn't be called at all in that case

    local dim = handle:get_dimensions()
    if type(elem_w) == "number" then

        local scale_h = elem_w / dim.width
        self.scale_w = nil
        self.scale_h = scale_h
        return elem_w, dim.height * scale_h
    end

    if type(elem_h) == "number" then
        local scale_w = elem_h / dim.height
        self.scale_w = scale_w
        self.scale_h = nil
        return dim.width * scale_w, elem_h

    end

    return dim.width, dim.height
end


local function new(args)

    local defaults = {
        _draw = draw,
        _calculate_minimum_dimensions = calculate_minimum_dimensions,
        file = nil, -- the path to the svg file
        _handle = nil,
        _cache = nil,
    }

    local ext = extension.new()
    ttable.override_b_to_a(defaults, args)
    ttable.override_b_to_a(ext, defaults)

    if ext.file ~= nil then

        local handle, cache = load_rsvg_handle(ext.file)

        if handle ~= nil then
            ext._handle = handle
            ext._cache = cache
        end
    end

    return ext

end


return {
    new = new,
}


