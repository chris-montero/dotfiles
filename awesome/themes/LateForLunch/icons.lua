
local tcolor = require("tools.color")
local esource = require("elemental.source")
local tshape = require("tools.shape")

local function get_width_for_height(icon_data, h)
    return icon_data.width_over_height * h
end

local function get_height_for_width(icon_data, w)
    local ratio = icon_data.width_over_height
    return (1/ratio) * w
end

local function _draw_debug_rel(cr, drawing)

    local old_path = cr:copy_path()

    cr:new_sub_path()
    cr:set_source(esource.to_cairo_source(tcolor.rgba(0, 0, 0, 0)))
    cr:fill()

    local first_point = drawing[1]

    cr:save()
    cr:translate(first_point[1], first_point[2])

    cr:set_line_width(0.003)
    for i=2, #drawing do

        local point = drawing[i]

        cr:set_source(esource.to_cairo_source(tcolor.rgba(0.2, 0.1, 0.9, 0.9)))
        cr:rectangle(-0.010, -0.010, 0.020, 0.020)
        cr:fill()

        cr:set_source(esource.to_cairo_source(tcolor.rgb(1, 0.3, 0.1)))
        cr:move_to(0, 0)
        cr:line_to(point[1], point[2])
        cr:stroke()

        cr:set_source(esource.to_cairo_source(tcolor.rgba(0.7, 0.2, 0.1, 0.7)))
        tshape.circle(cr, point[1], point[2], 0.005)
        cr:fill()

        cr:set_source(esource.to_cairo_source(tcolor.rgb(0.4, 0.9, 0.1)))
        cr:move_to(point[5], point[6])
        cr:line_to(point[3], point[4])
        cr:stroke()

        cr:set_source(esource.to_cairo_source(tcolor.rgba(0.1, 0.8, 0.2, 0.7)))
        tshape.circle(cr, point[3], point[4], 0.005)
        cr:fill()


        cr:translate(point[5], point[6])

    end

    cr:restore()

    cr:append_path(old_path)

end


local function _draw_debug(cr, drawing)

    local point_size = 0.020
    local knob_size = 0.010


    local function _draw_debug_point(
        prev_point_x, prev_point_y,
        first_knob_x, first_knob_y,
        second_knob_x, second_knob_y,
        current_point_x, current_point_y
    )

        cr:set_source(esource.to_cairo_source(tcolor.rgba(0.2, 0.1, 0.9, 0.9)))
        cr:rectangle(current_point_x - (point_size/2), current_point_y - (point_size/2), point_size, point_size)
        cr:fill()

        cr:set_source(esource.to_cairo_source(tcolor.rgb(1, 0.3, 0.1)))
        cr:move_to(prev_point_x, prev_point_y)
        cr:line_to(first_knob_x, first_knob_y)
        cr:stroke()

        cr:set_source(esource.to_cairo_source(tcolor.rgba(0.7, 0.2, 0.1, 0.7)))
        tshape.circle(cr, first_knob_x, first_knob_y, knob_size)
        cr:fill()

        cr:set_source(esource.to_cairo_source(tcolor.rgb(0.4, 0.9, 0.1)))
        cr:move_to(current_point_x, current_point_y)
        cr:line_to(second_knob_x, second_knob_y)
        cr:stroke()

        cr:set_source(esource.to_cairo_source(tcolor.rgba(0.1, 0.8, 0.2, 0.7)))
        tshape.circle(cr, second_knob_x, second_knob_y, knob_size)
        cr:fill()

    end


    local old_path = cr:copy_path()

    cr:new_sub_path()
    cr:set_source(esource.to_cairo_source(tcolor.rgba(0, 0, 0, 0)))
    cr:fill()

    local first_point = drawing[1]

    local prev_point = nil

    cr:save()

    cr:set_line_width(0.003)
    for i=2, #drawing do

        local point = drawing[i]
        local prev_point_x, prev_point_y
        if prev_point == nil then
            prev_point_x = first_point[1]
            prev_point_y = first_point[2]
        else
            prev_point_x = prev_point[5]
            prev_point_y = prev_point[6]
        end

        _draw_debug_point(
            prev_point_x, prev_point_y,
            point[1], point[2],
            point[3], point[4],
            point[5], point[6]
        )

        prev_point = point
    end

    local first_bezier_point = drawing[2]
    local last_point = drawing[#drawing]

        -- cr:set_source(esource.to_cairo_source(tcolor.rgba(0.2, 0.1, 0.9, 0.9)))
        -- cr:rectangle(current_point_x - (point_size/2), current_point_y - (point_size/2), point_size, point_size)
        -- cr:fill()


    if first_bezier_point ~= nil then
        -- cr:set_source(esource.to_cairo_source(tcolor.rgb(1, 0.3, 0.1)))
        -- cr:move_to(last_point[5], last_point[6])
        -- cr:line_to(last_point[3], last_point[4])
        -- cr:stroke()

        -- cr:set_source(esource.to_cairo_source(tcolor.rgba(0.7, 0.2, 0.1, 0.7)))
        -- tshape.circle(cr, last_point[3], last_point[4], knob_size)
        -- cr:fill()

        cr:set_source(esource.to_cairo_source(tcolor.rgb(0.4, 0.9, 0.1)))
        cr:move_to(last_point[5], last_point[6])
        cr:line_to(first_bezier_point[1], first_bezier_point[2])
        cr:stroke()

        cr:set_source(esource.to_cairo_source(tcolor.rgba(0.1, 0.8, 0.2, 0.7)))
        tshape.circle(cr, first_bezier_point[1], first_bezier_point[2], knob_size)
        cr:fill()
    end

    cr:restore()

    cr:append_path(old_path)

end


local function _draw_rel(cr, drawing)

    cr:save()

    local first_point = drawing[1]
    cr:move_to(first_point[1], first_point[2])
    cr:translate(first_point[1], first_point[2])

    for i=2, #drawing do
        local point = drawing[i]
        cr:curve_to(
            point[1], point[2],
            point[3], point[4],
            point[5], point[6]
        )
        cr:translate(point[5], point[6])
    end

    cr:close_path()

    cr:restore()

end


local function _draw_musical_note(cr)

    local drawing = {
        { 0.55, 0.05 },
        { 0.00, 0.00, 0.00, 0.66, 0.00, 0.66 },
        { 0.00, 0.00, 0.00, 0.08, 0.00, 0.08 },

        { 0.00, 0.08, -0.10, 0.20, -0.30, 0.20 },

        { -0.12, 0.00, -0.16, -0.08, -0.16, -0.12 },

        { 0.00, -0.10, 0.12, -0.18, 0.26, -0.18 },

        { 0.08, 0.00, 0.12, 0.04, 0.12, 0.04 },

        { 0.00, 0.00, 0.00, -0.06, 0.00, -0.06 },

        { 0.00, 0.00, 0.00, -0.60, 0.00, -0.60 },
        { 0.00, -0.016, 0.003, -0.016, 0.01, -0.020 },
        { 0.00, 0.00, 0.06, -0.010, 0.06, -0.010 },
        { 0.0058, -0.0003, 0.01, 0.0007, 0.01, 0.015 },

    }

    _draw_rel(cr, drawing)
    -- _draw_debug_rel(cr, drawing)

end

local musical_note = {

    width_over_height = 0.7,
    draw = _draw_musical_note

}


local function _draw(cr, drawing)

    cr:save()

    local first_point = drawing[1]
    cr:move_to(first_point[1], first_point[2])

    for i=2, #drawing do
        local point = drawing[i]
        cr:curve_to(
            point[1], point[2],
            point[3], point[4],
            point[5], point[6]
        )
    end

    cr:close_path()

    cr:restore()

end


local function _draw_rel_custom(cr, drawing)

    cr:save()

    local first_point = drawing[1]
    cr:move_to(first_point[1], first_point[2])

    local prev_point

    for i=2, #drawing do

        local point = drawing[i]
        local prev_point_x, prev_point_y

        if prev_point == nil then
            prev_point_x, prev_point_y = first_point[1], first_point[2]
        else
            prev_point_x, prev_point_y = prev_point[5], prev_point[6]
        end

        cr:curve_to(
            prev_point_x + point[1], prev_point_y + point[2],
            point[5] + point[3], point[6] + point[4],
            point[5], point[6]
        )

        prev_point = point

    end

    cr:close_path()

    cr:restore()
end

local function _debug_draw_rel_custom(cr, drawing)

    local point_size = 0.020
    local knob_size = 0.010

    local function _draw_debug_point(
        prev_point_x, prev_point_y,
        first_knob_x, first_knob_y,
        second_knob_x, second_knob_y,
        current_point_x, current_point_y
    )

        cr:set_source(esource.to_cairo_source(tcolor.rgba(0.2, 0.1, 0.9, 0.9)))
        cr:rectangle(current_point_x - (point_size/2), current_point_y - (point_size/2), point_size, point_size)
        cr:fill()

        cr:set_source(esource.to_cairo_source(tcolor.rgb(1, 0.3, 0.1)))
        cr:move_to(prev_point_x, prev_point_y)
        cr:line_to(first_knob_x, first_knob_y)
        cr:stroke()

        cr:set_source(esource.to_cairo_source(tcolor.rgba(0.7, 0.2, 0.1, 0.7)))
        tshape.circle(cr, first_knob_x, first_knob_y, knob_size)
        cr:fill()

        cr:set_source(esource.to_cairo_source(tcolor.rgb(0.4, 0.9, 0.1)))
        cr:move_to(current_point_x, current_point_y)
        cr:line_to(second_knob_x, second_knob_y)
        cr:stroke()

        cr:set_source(esource.to_cairo_source(tcolor.rgba(0.1, 0.8, 0.2, 0.7)))
        tshape.circle(cr, second_knob_x, second_knob_y, knob_size)
        cr:fill()

    end


    local old_path = cr:copy_path()

    cr:new_sub_path()
    cr:set_source(esource.to_cairo_source(tcolor.rgba(0, 0, 0, 0)))
    cr:fill()

    local first_point = drawing[1]

    local prev_point = nil

    cr:save()

    cr:set_line_width(0.003)
    for i=2, #drawing do

        local point = drawing[i]
        local prev_point_x, prev_point_y
        if prev_point == nil then
            prev_point_x = first_point[1]
            prev_point_y = first_point[2]
        else
            prev_point_x = prev_point[5]
            prev_point_y = prev_point[6]
        end

        _draw_debug_point(
            prev_point_x, prev_point_y,
            prev_point_x + point[1], prev_point_y + point[2],
            point[5] + point[3], point[6] + point[4],
            point[5], point[6]
        )

        prev_point = point
    end

    local first_bezier_point = drawing[2]
    local last_point = drawing[#drawing]

    -- if first_bezier_point ~= nil then
    --     -- cr:set_source(esource.to_cairo_source(tcolor.rgb(1, 0.3, 0.1)))
    --     -- cr:move_to(last_point[5], last_point[6])
    --     -- cr:line_to(last_point[3], last_point[4])
    --     -- cr:stroke()

    --     -- cr:set_source(esource.to_cairo_source(tcolor.rgba(0.7, 0.2, 0.1, 0.7)))
    --     -- tshape.circle(cr, last_point[3], last_point[4], knob_size)
    --     -- cr:fill()

    --     cr:set_source(esource.to_cairo_source(tcolor.rgb(0.4, 0.9, 0.1)))
    --     cr:move_to(last_point[5], last_point[6])
    --     cr:line_to(first_bezier_point[1], first_bezier_point[2])
    --     cr:stroke()

    --     cr:set_source(esource.to_cairo_source(tcolor.rgba(0.1, 0.8, 0.2, 0.7)))
    --     tshape.circle(cr, first_bezier_point[1], first_bezier_point[2], knob_size)
    --     cr:fill()
    -- end

    cr:restore()

    cr:append_path(old_path)

end

local function _draw_next_song(cr)

    -- local scale_w = 1
    local scale_h = 0.7

    local half_height = scale_h / 2

    local first_arrow_middle_x = 0.4

    local second_arrow_middle_x = 0.8

    local wall_w = 0.198
    local wall_h = 0.75 * scale_h
    local wall_x = 0.8
    local wall_y = (scale_h - wall_h) / 2

    local arrow_slope_h = half_height / first_arrow_middle_x

    local start_x, start_y = 0.072 * arrow_slope_h, 0.064

    local arrow_h = scale_h

    local drawing = {
        { start_x, start_y },
        { 0.00, 0.00, 0.00, 0.00, first_arrow_middle_x - 0.06, half_height - 0.035 },
        { 0.023, 0.011, 0.00, 0.027, first_arrow_middle_x, half_height - 0.06 },

        { 0.00, 0.00, 0.00, 0.00, first_arrow_middle_x, start_y + 0.026 },
        { 0.00, -0.044, -0.015, -0.0154, first_arrow_middle_x + start_x, start_y },

        { 0.00, 0.00, 0.00, 0.00, second_arrow_middle_x - 0.06, half_height - 0.035 },
        { 0.023, 0.011, 0.00, 0.027, second_arrow_middle_x, half_height - 0.06 },


        { 0.00, 0.00, 0.00, 0.00, wall_x, wall_y + 0.027 },
        { 0.00, -0.014, -0.014, 0.00, wall_x + 0.027, wall_y },

        { 0.00, 0.00, 0.00, 0.00, wall_x + wall_w - 0.027, wall_y },
        { 0.014, 0.00, 0.00, -0.014, wall_x + wall_w, wall_y + 0.027 },

        { 0.00, 0.00, 0.00, 0.00, wall_x + wall_w, wall_y + wall_h - 0.027 },
        { 0.00, 0.014, 0.014, 0.00, wall_x + wall_w - 0.027, wall_y + wall_h },

        { 0.00, 0.00, 0.00, 0.00, wall_x + 0.027, wall_y + wall_h },
        { -0.014, 0.00, 0.00, 0.014, wall_x, wall_y + wall_h - 0.027 },


        { 0.00, 0.00, 0.00, 0.00, second_arrow_middle_x, half_height + 0.06 },
        { 0, -0.042, 0.023, -0.0214, second_arrow_middle_x - 0.06, half_height + 0.035 },

        { 0.00, 0.00, 0.00, 0.00, first_arrow_middle_x + start_x, arrow_h - start_x },
        { -0.015, 0.0154, 0.00, 0.044, first_arrow_middle_x, arrow_h - (start_y + 0.026) },

        { 0.00, 0.00, 0.00, 0.00, first_arrow_middle_x, half_height + 0.06 },
        { 0.00, -0.042, 0.023, -0.0214, first_arrow_middle_x - 0.06, half_height + 0.035 },

        { 0.00, 0.00, 0.00, 0.00, start_x, arrow_h - start_x },
        { -0.015, 0.0154, 0.00, 0.044, 0.00, arrow_h - (start_y + 0.026) },

        { 0.00, 0.00, 0.00, 0.00, 0.00, start_y + 0.026 },
        { 0.00, -0.044, -0.015, -0.0154, start_x, start_y }
    }


    _draw_rel_custom(cr, drawing)
    -- _debug_draw_rel_custom(cr, drawing)

end

local next_song = {

    width_over_height = 1/0.7,
    draw = _draw_next_song,

}

local function _draw_play(cr, width, height)

    -- local width_over_height = 1.4
    local scale_w = 0.8

    local mid_y = 1 / 2

    local round_amount = 0.12
    local const_bezier_round = 2.30
    local start_x, start_y = round_amount, round_amount * mid_y

    local drawing = {
        { start_x, start_y },
        { 0.00, 0.00, 0.00, 0.00, scale_w - round_amount, mid_y - start_y },
        { round_amount/const_bezier_round, start_y/const_bezier_round, round_amount/const_bezier_round, -start_y/const_bezier_round, scale_w - start_x, mid_y + start_y },
        { 0.000, 0.000, 0.00, 0.000, start_x, 1 - start_y },
        { -round_amount / const_bezier_round, start_y/const_bezier_round, 0.00, round_amount / const_bezier_round, 0, 1 - round_amount },
        { 0.000, 0.000, 0.00, 0.000, 0, round_amount },
        { 0.000, -round_amount/const_bezier_round, -round_amount/const_bezier_round, -start_y/const_bezier_round, start_x, start_y},
    }

    -- scale and translate so the drawing fits in canvas
    cr:scale(1.105, 1.105)
    cr:translate(0, -0.047)
    _draw_rel_custom(cr, drawing)
    -- _debug_draw_rel_custom(cr, drawing)

end

local play = {
    width_over_height = 0.8,
    draw = _draw_play,
}


return {

    get_width_for_height = get_width_for_height,
    get_height_for_width = get_height_for_width,

    musical_note = musical_note,
    next_song = next_song,
    play = play,

}
