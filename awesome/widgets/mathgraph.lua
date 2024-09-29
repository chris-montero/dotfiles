
local lgi = require("lgi")
local extension = require("elemental.extension")
local esource = require("elemental.source")
local ttable = require("tools.table")
local tcolor = require("tools.color")
local beautiful = require("beautiful")

local function _calculate_unit_step(scale)

    local unit_step = 1

    if scale < 0.1 then
        unit_step = 25
    elseif scale < 1 then
        unit_step = 10
    elseif scale < 10 then
        unit_step = 1
    elseif scale < 25 then
        unit_step = 0.5
    elseif scale < 150 then
        unit_step = 0.1
    else
        unit_step = 0.01
    end

    return unit_step

end

local function _calculate_origin_xy(origin_offset_x, origin_offset_y, context_width, context_height)
    local middle_width = math.floor(context_width / 2)
    local middle_height = math.floor(context_height / 2)
    return (middle_width + origin_offset_x), (middle_height + origin_offset_y)
end

local function _calculate_x_units_from_px(px_per_step, scale_x, px)
    return px / (px_per_step * scale_x)
end

local function _draw_text_at_pos(self, context, cr, x, y, text)
    cr:save()
    local ctx = lgi.PangoCairo.font_map_get_default():create_context()
    ctx:set_resolution(self.text_dpi)
    local layout = lgi.Pango.Layout.new(ctx)
    local text_color = self.text_color
    cr:set_source(esource.to_cairo_source(text_color))
    local font_desc = lgi.Pango.FontDescription.from_string(self.font_family .. ' ' .. self.font_weight .. ' ' .. self.font_size)
    layout:set_font_description(font_desc)
    layout.attributes = nil
    layout.text = text
    cr:move_to(x, y)
    cr:update_layout(layout)
    cr:show_layout(layout)
    cr:restore()
end

local function _draw_origin(self, cr, context_width, context_height)
    local orig_x, orig_y = _calculate_origin_xy(self.origin_offset_x or 0, self.origin_offset_y or 0, context_width, context_height)
    local plane_offset_x = self.plane_offset_x or 0
    local offset_orig_x = orig_x + plane_offset_x
    local col = self.origin_color
    local origin_size = 3
    cr:save()
    cr:set_line_width(1)
    cr:set_source(esource.to_cairo_source(col))
    cr:move_to(offset_orig_x - origin_size, orig_y - origin_size)
    cr:line_to(offset_orig_x + origin_size, orig_y + origin_size)
    cr:move_to(offset_orig_x + origin_size, orig_y - origin_size)
    cr:line_to(offset_orig_x - origin_size, orig_y + origin_size)
    cr:stroke()
    cr:restore()
end


local function _calculate_knobs_positions(self, context_width, context_height)

    local points = {
        x_axis = {},
        y_axis = {}
    }

    local orig_x, orig_y = _calculate_origin_xy(self.origin_offset_x, self.origin_offset_y, context_width, context_height)

    local scale_x = self.scale_x or 1
    local scale_y = self.scale_y or 1
    local px_per_step_x = self.px_per_step_x or 10
    local px_per_step_y = self.px_per_step_y or 10
    local unit_step_x = _calculate_unit_step(scale_x)
    local unit_step_y = _calculate_unit_step(scale_y)
    local px_per_unit_y = px_per_step_y * scale_y * unit_step_y
    local px_per_unit_x = px_per_step_x * scale_x * unit_step_x

    local plane_offset_x = self.plane_offset_x or 0
    local modded_plane_offset = plane_offset_x % px_per_unit_x

    local number_offset_x = math.floor(plane_offset_x / px_per_unit_x)
    local starting_number_x_axis = 0 - (number_offset_x * unit_step_x)
    local starting_number_y_axis = 0
    local x_so_far = 0
    local y_so_far = 0
    local fake_origin_x = orig_x + modded_plane_offset

    table.insert(points.x_axis, { -- the point from which we start drawing the x axis
        x = fake_origin_x,
        y = orig_y,
        number = starting_number_x_axis
    })

    local accumulated_units = 0

    while fake_origin_x + x_so_far < context_width do
        x_so_far = x_so_far + px_per_unit_x
        accumulated_units = accumulated_units + 1
        local place_x = fake_origin_x + x_so_far
        local place_y = orig_y
        local number = starting_number_x_axis + (accumulated_units * unit_step_x)
        table.insert(points.x_axis, {
            x = place_x,
            y = place_y,
            number = number
        })
    end
    accumulated_units = 0
    x_so_far = 0
    while fake_origin_x - x_so_far > 0 do
        x_so_far = x_so_far + px_per_unit_x
        accumulated_units = accumulated_units + 1
        local place_x = fake_origin_x - x_so_far
        local place_y = orig_y
        local number = starting_number_x_axis - (accumulated_units * unit_step_x)
        table.insert(points.x_axis, {
            x = place_x,
            y = place_y,
            number = number
        })
    end

    -- table.insert(points.y_axis, { -- the point from which we start drawing the y axis
    --     x = orig_x,
    --     y = orig_y,
    --     number = starting_number_y_axis
    -- })

    accumulated_units = 0
    while orig_y - y_so_far > 0 do
        y_so_far = y_so_far + px_per_unit_y
        accumulated_units = accumulated_units + 1
        local place_x = orig_x
        local place_y = orig_y - y_so_far
        local number = starting_number_y_axis + (accumulated_units * unit_step_y)
        table.insert(points.y_axis, {
            x = place_x,
            y = place_y,
            number = number
        })
    end
    y_so_far = 0
    accumulated_units = 0
    while orig_y + y_so_far < context_height do
        y_so_far = y_so_far + px_per_unit_y
        accumulated_units = accumulated_units + 1
        local place_x = orig_x
        local place_y = orig_y + y_so_far
        local number = starting_number_y_axis - (accumulated_units * unit_step_y)
        table.insert(points.y_axis, {
            x = place_x,
            y = place_y,
            number = number
        })
    end

    return points

end

local function _draw_help_knobs(self, context, cr, context_width, context_height)
    local points = _calculate_knobs_positions(self, context_width, context_height)
    local small_knob_length = 3
    local small_knob_thickness = 1
    -- local big_knob_length = 5
    -- local big_knob_thickness = 2

    local small_knob_color = self.small_knob_color

    cr:save()
    cr:set_source(esource.to_cairo_source(small_knob_color))
    cr:set_line_width(small_knob_thickness)

    for _, point in ipairs(points.x_axis) do
        cr:move_to(point.x, point.y - small_knob_length)
        cr:line_to(point.x, point.y + small_knob_length)
        if point.number ~= nil then
            _draw_text_at_pos(self, context, cr, point.x, point.y, point.number)
        end
    end
    for _, point in ipairs(points.y_axis) do
        cr:move_to(point.x - small_knob_length, point.y)
        cr:line_to(point.x + small_knob_length, point.y)
        if point.number ~= nil then
            _draw_text_at_pos(self, context, cr, point.x, point.y, point.number)
        end
    end
    cr:stroke()
    cr:restore()
end

local function _graph_function(self, cr, context_width, context_height)
    local scale_x = self.scale_x or 1
    local scale_y = self.scale_y or 1
    local px_per_step_x = self.px_per_step_x or 10
    local px_per_step_y = self.px_per_step_y or 10
    local step_function = self.graph_function
    if step_function == nil then
        return
    end
    local detail_level = self.detail_level or 1 -- smaller = more detailed
    local graph_color = self.graph_color
    local orig_x, orig_y = _calculate_origin_xy(self.origin_offset_x, self.origin_offset_y, context_width, context_height)
    local plane_offset_x = self.plane_offset_x or 0
    local plane_offset_x_units = _calculate_x_units_from_px(px_per_step_x, scale_x, plane_offset_x)

    local x_step_amount = detail_level / (px_per_step_x * scale_x)

    cr:save()
    cr:set_source(esource.to_cairo_source(graph_color))
    cr:move_to(orig_x, orig_y)

    local rect = cr.rectangle -- cache rectangle function for better performance
    local stepped = 0
    for _=1, (context_width - orig_x) * (1 / detail_level) do
        local plot_x_right = orig_x + (stepped * px_per_step_x * scale_x)
        local plot_y_right = orig_y - (step_function(stepped - plane_offset_x_units) * px_per_step_y * scale_y)

        if plot_y_right > 0 then
            rect(cr, plot_x_right, plot_y_right, 1, 1)
        end
        stepped = stepped + x_step_amount
    end

    stepped = 0
    for _=1, (context_width - (context_width - orig_x)) * (1 / detail_level) do
        local plot_x_left = orig_x - (stepped * px_per_step_x * scale_x)
        local plot_y_left = orig_y - (step_function(-plane_offset_x_units - stepped) * px_per_step_y * scale_y)

        if plot_y_left > 0 then
            rect(cr, plot_x_left, plot_y_left, 1, 1)
        end
        stepped = stepped + x_step_amount
    end

    cr:fill()
    cr:restore()

end

local function _draw_graph_xy(self, cr, context_width, context_height)

    local x_axis_color = self.x_axis_color
    local y_axis_color = self.y_axis_color

    local orig_x, orig_y = _calculate_origin_xy(self.origin_offset_x, self.origin_offset_y, context_width, context_height)

    cr:save()
    cr:set_line_width(1)
    cr:set_source(esource.to_cairo_source(x_axis_color))
    cr:move_to(0, orig_y)
    cr:line_to(context_width, orig_y)
    cr:stroke()
    cr:set_source(esource.to_cairo_source(y_axis_color))
    cr:move_to(orig_x, 0)
    cr:line_to(orig_x, context_height)
    cr:stroke()
    cr:restore()
end

local function _draw(mathgraph, cr, avail_w, avail_h)

    _draw_graph_xy(mathgraph, cr, avail_w, avail_h)
    _draw_help_knobs(mathgraph, {}, cr, avail_w, avail_h)
    _draw_origin(mathgraph, cr, avail_w, avail_h)
    if mathgraph.graph_function ~= nil then
        _graph_function(mathgraph, cr, avail_w, avail_h)
    end

end

local function _calculate_minimum_dimensions(_, _, _)
    -- if the mathgraph has width or height == shrink then we just don't take up
    -- any space & don't display anything
    return 0, 0
end

local function new(args)

    local text_dpi = 82 --TODO: add a proper implementation

    local defaults = {

        _draw = _draw,
        _layout_children = nil,
        _calculate_minimum_dimensions = _calculate_minimum_dimensions,
        -- plane_offset_y = 0,
        min_scale_x = 0.05,
        min_scale_y = 0.05,
        max_scale_x = 200,
        max_scale_y = 200,
        scale_x = 1,
        scale_y = 1,
        px_per_step_x = 10,
        px_per_step_y = 10,
        origin_offset_x = 0,
        origin_offset_y = 0,
        plane_offset_x = 0,
        graph_function = nil,
        text_dpi = text_dpi,
        text_color = tcolor.rgb_from_string("#f9ffff"),
        -- bg = tcolor.rgb_from_string("#7070ff"),
        x_axis_color = tcolor.rgb_from_string("#181240"),
        y_axis_color = tcolor.rgb_from_string("#181240"),
        small_knob_color = tcolor.rgb_from_string("#181240"),
        graph_color = tcolor.rgb_from_string("#080808"),
        origin_color = tcolor.rgb_from_string("#b03844"),
        font_family = beautiful.font_family_1,
        font_weight = "Regular",
        font_size = beautiful.font_size_1,
        detail_level = 1,
    }

    local ext = extension.new()
    ttable.override_b_to_a(defaults, args)
    ttable.override_b_to_a(ext, defaults)

    -- args._draw = _draw
    -- args._layout_children = nil
    -- args._calculate_minimum_dimensions = _calculate_minimum_dimensions
    -- -- args.plane_offset_y = args.plane_offset_y or 0

    -- args.min_scale_x = args.min_scale_x or 0.05
    -- args.min_scale_y = args.min_scale_y or 0.05
    -- args.max_scale_x = args.max_scale_x or 200
    -- args.max_scale_y = args.max_scale_y or 200
    -- args.scale_x = args.scale_x or 1
    -- args.scale_y = args.scale_y or 1
    -- args.px_per_step_x = args.px_per_step_x or 10
    -- args.px_per_step_y = args.px_per_step_y or 10
    -- args.origin_offset_x = args.origin_offset_x or 0
    -- args.origin_offset_y = args.origin_offset_y or 0
    -- args.plane_offset_x = args.plane_offset_x or 0
    -- args.graph_function = args.graph_function or nil
    -- args.text_dpi = text_dpi
    -- args.text_color = args.text_color or "#f9ffff"
    -- -- args.background_color = args.bg or "#7070ff"
    -- args.x_axis_color = args.x_axis_color or "#181240"
    -- args.y_axis_color = args.y_axis_color or "#181240"
    -- args.small_knob_color = args.small_knob_color or "#181240"
    -- args.graph_color = args.graph_color or "#080808"
    -- args.origin_color = args.origin_color or "#b03844"
    -- args.font = args.font or beautiful.font
    -- args.detail_level = args.detail_level or 2

    return ext
end

local function get_value_by_x(processed_mathgraph, x)

    local mathgraph_w, mathgraph_h
    do
        local mathgraph_geom = processed_mathgraph.geometry
        if mathgraph_geom == nil then
            print(
                [[WARNING: you need to supply an instance of mathgraph that has 
                already been processed by a layout. this is because we need to 
                know the mathgraph's geometry.]]
            )
            return nil
        end

        mathgraph_w = mathgraph_geom.width
        mathgraph_h = mathgraph_geom.height
    end

    local orig_x, _ = _calculate_origin_xy(
        processed_mathgraph.origin_offset_x,
        processed_mathgraph.origin_offset_y,
        mathgraph_w,
        mathgraph_h
    )
    local scale_x = processed_mathgraph.scale_x or 1
    local px_per_step_x = processed_mathgraph.px_per_step_x or 10
    local plane_offset_x = processed_mathgraph.plane_offset_x or 0
    local step_function = processed_mathgraph.graph_function
    if step_function == nil then return 0 end

    return step_function((x - orig_x - plane_offset_x) / (px_per_step_x * scale_x))

end

local function get_y_by_x(processed_mathgraph, x)


    local mathgraph_w, mathgraph_h
    do
        local mathgraph_geom = processed_mathgraph.geometry
        if mathgraph_geom == nil then
            print(
                [[WARNING: you need to supply an instance of mathgraph that has 
                already been processed by a layout. this is because we need to 
                know the mathgraph's geometry.]]
            )
            return nil
        end

        mathgraph_w = mathgraph_geom.width
        mathgraph_h = mathgraph_geom.height
    end

    local scale_x = processed_mathgraph.scale_x or 1
    local scale_y = processed_mathgraph.scale_y or 1
    local px_per_step_x = processed_mathgraph.px_per_step_x or 10
    local px_per_step_y = processed_mathgraph.px_per_step_y or 10
    local plane_offset_x = processed_mathgraph.plane_offset_x or 0
    local step_function = processed_mathgraph.graph_function
    if step_function == nil then return 0 end

    local orig_x, orig_y = _calculate_origin_xy(
        processed_mathgraph.origin_offset_x,
        processed_mathgraph.origin_offset_y,
        mathgraph_w,
        mathgraph_h
    )

    return math.min(
        orig_y -
            (step_function(
                (x - orig_x - plane_offset_x) / (px_per_step_x * scale_x)
            ) * px_per_step_y * scale_y),
        mathgraph_h
    )
end

return {
    new = new,
    get_value_by_x = get_value_by_x,
    get_y_by_x = get_y_by_x,
}
