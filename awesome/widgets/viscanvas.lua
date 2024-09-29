
local gcolor = require("gears.color")
local tshape = require("tools.shape")
local extension = require("elemental.extension")
local eutil = require("elemental.util")
local etypes = require("elemental.types")
local ttable = require("tools.table")

local SIDE_TOP = 1
local SIDE_RIGHT = 2
local SIDE_BOTTOM = 3
local SIDE_LEFT = 4

local CORNER_START = 1
local CORNER_END = 2

local WAVE_PEAK = 1
local WAVE_VALLEY = 2


local function offset_to_90_angle(offset, arc_length)
    local amt = offset / arc_length
    return amt * (math.pi / 2)
end


-- TODO: make all these debug functions only take the colors they need, not the entire viscanvas table
local function _debug_draw_rounded_elapsed_point(self, cr, rounded_elapsed_point)
    cr:save()
    cr:set_source(gcolor(self._private.debug.color7))
    tshape.circle(cr, rounded_elapsed_point.elapsed_x, rounded_elapsed_point.elapsed_y, 4)
    cr:fill()
    cr:restore()
end

local function _debug_draw_rect_elapsed_point(self, cr, rect_elapsed_point)
    cr:save()
    cr:set_source(gcolor(self._private.debug.color4))
    tshape.circle(cr, rect_elapsed_point.elapsed_x, rect_elapsed_point.elapsed_y, 3)
    cr:fill()
    cr:restore()
end

local function _debug_draw_rect_elapsed_amount(self, cr, debug_data)
    local rect_data = debug_data.rect_data
    cr:save()
    cr:set_source(gcolor(self._private.debug.color6))
    tshape.circle(cr, rect_data.elapsed_x, rect_data.elapsed_y, 4)
    cr:fill()
    cr:restore()
end

local function _debug_draw_blob(self, cr, peaks, valleys)
    local first_peak = peaks[1]
    if first_peak == nil then
        return
    end
    cr:save()
    cr:set_source(gcolor(self._private.debug.color5))
    cr:move_to(first_peak.elapsed_x, first_peak.elapsed_y)
    for i=1, #peaks do
        local peak = peaks[i]
        local next_i = i + 1
        if next_i > #peaks then
            next_i = 1
        end
        local next_peak = peaks[next_i]
        local valley = valleys[i]
        cr:curve_to(peak.knob1_x, peak.knob1_y, valley.knob1_x, valley.knob1_y, valley.elapsed_x, valley.elapsed_y)
        cr:curve_to(valley.knob2_x, valley.knob2_y, peak.knob2_x, peak.knob2_y, next_peak.elapsed_x, next_peak.elapsed_y)
    end
    cr:close_path()
    cr:fill()
    cr:restore()
end

local function _debug_draw_bezier_knobs(self, cr, elapsed_x, elapsed_y, knob1_x, knob1_y, knob2_x, knob2_y, source_color)
    cr:save()
    cr:set_source(gcolor(source_color))
    cr:move_to(elapsed_x, elapsed_y)
    cr:line_to(knob1_x, knob1_y)
    cr:stroke()
    tshape.circle(cr, knob1_x, knob1_y, 2)
    cr:fill()
    cr:set_source(gcolor(self._private.debug.color1))
    cr:move_to(elapsed_x, elapsed_y)
    cr:line_to(knob2_x, knob2_y)
    cr:stroke()
    tshape.circle(cr, knob2_x, knob2_y, 2)
    cr:fill()
    cr:restore()
end

local function _debug_draw_inner_rectangle(self, cr, debug_data)
    local rect_data = debug_data.rect_data
    cr:save()
    cr:set_source(gcolor(self._private.debug.color2))
    cr:set_line_width(2)
    cr:rectangle(rect_data.x, rect_data.y, rect_data.width, rect_data.height)
    cr:stroke()
    cr:restore()
end

local function _debug_draw_inner_rounded_rectangle(self, cr, debug_data)
    local rect_corners = debug_data.rect_corners
    local tl = rect_corners[1]
    local tr = rect_corners[2]
    local br = rect_corners[3]
    local bl = rect_corners[4]
    local corner_size = debug_data.corner_size

    cr:save()
    cr:set_source(gcolor(self._private.debug.color6))
    cr:set_line_width(1)
    cr:move_to(tl.x + corner_size, tl.y)
    cr:line_to(tr.x - corner_size, tr.y)
    cr:arc(tr.x - corner_size, tr.y + corner_size, corner_size, -(math.pi / 2), 0)
    -- cr:move_to(tr.x, tr.y + corner_size)
    cr:line_to(br.x, br.y - corner_size)
    cr:arc(br.x - corner_size, br.y - corner_size, corner_size, 0, (math.pi/2))
    -- cr:move_to(br.x - corner_size, br.y)
    cr:line_to(bl.x + corner_size, bl.y)
    cr:arc(bl.x + corner_size, bl.y - corner_size, corner_size, (math.pi/2), math.pi)
    -- cr:move_to(bl.x, bl.y - corner_size)
    cr:line_to(bl.x, tl.y + corner_size)
    cr:arc(tl.x + corner_size, tl.y + corner_size, corner_size, math.pi, ((math.pi / 2) * 3))
    cr:stroke()
    cr:restore()

end

local function _debug_draw_selected_corner_line(self, cr, rect_elapsed_point_index, debug_data)
    local elapsed_point = debug_data.rect_elapsed_points[rect_elapsed_point_index]
    local side = elapsed_point.side
    local corner_size = debug_data.corner_size
    local next_side = side + 1
    if next_side > 4 then
        next_side = 1
    end
    local first_corner_coords = debug_data.rect_corners[side]
    local second_corner_coords = debug_data.rect_corners[next_side]

    local move_to_coords = {}
    local line_to_coords = {}

    if elapsed_point.corner == nil then
        return
    end

    if side == SIDE_TOP then
        move_to_coords.y = first_corner_coords.y
        line_to_coords.y = first_corner_coords.y
        if elapsed_point.corner.which == CORNER_START then
            move_to_coords.x = first_corner_coords.x
            line_to_coords.x = first_corner_coords.x + corner_size
        elseif elapsed_point.corner.which == CORNER_END then
            move_to_coords.x = second_corner_coords.x - corner_size
            line_to_coords.x = second_corner_coords.x
        end
    elseif side == SIDE_RIGHT then
        move_to_coords.x = first_corner_coords.x
        line_to_coords.x = first_corner_coords.x
        if elapsed_point.corner.which == CORNER_START then
            move_to_coords.y = first_corner_coords.y
            line_to_coords.y = first_corner_coords.y + corner_size
        elseif elapsed_point.corner.which == CORNER_END then
            move_to_coords.y = second_corner_coords.y - corner_size
            line_to_coords.y = second_corner_coords.y
        end
    elseif side == SIDE_BOTTOM then
        move_to_coords.y = first_corner_coords.y
        line_to_coords.y = first_corner_coords.y
        if elapsed_point.corner.which == CORNER_START then
            move_to_coords.x = first_corner_coords.x
            line_to_coords.x = first_corner_coords.x - corner_size
        elseif elapsed_point.corner.which == CORNER_END then
            move_to_coords.x = second_corner_coords.x + corner_size
            line_to_coords.x = second_corner_coords.x
        end
    elseif side == SIDE_LEFT then
        move_to_coords.x = first_corner_coords.x
        line_to_coords.x = first_corner_coords.x
        if elapsed_point.corner.which == CORNER_START then
            move_to_coords.y = first_corner_coords.y
            line_to_coords.y = first_corner_coords.y - corner_size
        elseif elapsed_point.corner.which == CORNER_END then
            move_to_coords.y = second_corner_coords.y + corner_size
            line_to_coords.y = second_corner_coords.y
        end
    end

    cr:save()
    cr:set_source(gcolor(self._private.debug.color5))
    cr:set_line_width(2)
    cr:move_to(move_to_coords.x, move_to_coords.y)
    cr:line_to(line_to_coords.x, line_to_coords.y)
    cr:stroke()
    cr:restore()

end


local function _elapsed_to_rect_space_point(rect_elapsed_amount, x, y, width, height, corner_size)
    local side = nil
    local corner = nil -- a corner can be nil in the return value
    local elapsed_x, elapsed_y

    if rect_elapsed_amount < width then
        side = SIDE_TOP
        if rect_elapsed_amount < corner_size then
            corner = {
                which = CORNER_START,
                elapsed_amount = rect_elapsed_amount
            }
        elseif rect_elapsed_amount > width - corner_size then
            corner = {
                which = CORNER_END,
                elapsed_amount = rect_elapsed_amount - (width - corner_size)
            }
        end
        elapsed_x = x + rect_elapsed_amount
        elapsed_y = y
    elseif rect_elapsed_amount < width + height then
        local right_side_elapsed = rect_elapsed_amount - width -- for convenience
        side = SIDE_RIGHT
        if right_side_elapsed < corner_size then
            corner = {
                which = CORNER_START,
                elapsed_amount = right_side_elapsed
            }
        elseif right_side_elapsed > height - corner_size then
            corner = {
                which = CORNER_END,
                elapsed_amount = right_side_elapsed - (height - corner_size)
            }
        end
        elapsed_x = x + width
        elapsed_y = y + right_side_elapsed
    elseif rect_elapsed_amount < width + height + width then
        local bottom_side_elapsed = rect_elapsed_amount - width - height -- for convenience
        side = SIDE_BOTTOM
        if bottom_side_elapsed < corner_size then
            corner = {
                which = CORNER_START,
                elapsed_amount = bottom_side_elapsed
            }
        elseif bottom_side_elapsed > width - corner_size then
            corner = {
                which = CORNER_END,
                elapsed_amount = bottom_side_elapsed - (width - corner_size)
            }
        end
        elapsed_x = x + width - bottom_side_elapsed
        elapsed_y = y + height
    elseif rect_elapsed_amount < width * 2 + height * 2 then
        local left_side_elapsed = rect_elapsed_amount - (width * 2) - height -- for convenience
        side = SIDE_LEFT
        if left_side_elapsed < corner_size then
            corner = {
                which = CORNER_START,
                elapsed_amount = left_side_elapsed
            }
        elseif left_side_elapsed > height - corner_size then
            corner = {
                which = CORNER_END,
                elapsed_amount = left_side_elapsed - (height - corner_size)
            }
        end
        elapsed_x = x
        elapsed_y = y + height - left_side_elapsed
    end

    return {
        side = side,
        corner = corner,
        elapsed_x = elapsed_x,
        elapsed_y = elapsed_y,
    }

end

local function _rect_space_point_to_rounded_space_point(rect_elapsed_point, point_height, rect_x, rect_y, rect_width, rect_height, corner_size)
    local side = rect_elapsed_point.side
    local corner = rect_elapsed_point.corner
    local rect_elapsed_x = rect_elapsed_point.elapsed_x
    local rect_elapsed_y = rect_elapsed_point.elapsed_y

    local rounded_elapsed_x = rect_elapsed_x
    local rounded_elapsed_y = rect_elapsed_y

    if corner == nil then
        if side == SIDE_TOP then
            rounded_elapsed_y = rounded_elapsed_y - point_height
        elseif side == SIDE_RIGHT then
            rounded_elapsed_x = rounded_elapsed_x + point_height
        elseif side == SIDE_BOTTOM then
            rounded_elapsed_y = rounded_elapsed_y + point_height
        elseif side == SIDE_LEFT then
            rounded_elapsed_x = rounded_elapsed_x - point_height
        end
        return {
            elapsed_x = rounded_elapsed_x,
            elapsed_y = rounded_elapsed_y,
        }
    end

    local corner_elapsed_amount = corner.elapsed_amount
    if corner.which == CORNER_START then
        local angle_rotate = math.atan((corner_size - corner_elapsed_amount) / corner_size)
        if side == SIDE_TOP then
            rounded_elapsed_x = rect_x + (corner_size - (corner_size * math.sin(angle_rotate)))
            rounded_elapsed_y = rect_y + (corner_size - (corner_size * math.cos(angle_rotate)))
        elseif side == SIDE_RIGHT then
            rounded_elapsed_x = rect_x + rect_width - (corner_size - (corner_size * math.cos(angle_rotate)))
            rounded_elapsed_y = rect_y + (corner_size - (corner_size * math.sin(angle_rotate)))
        elseif side == SIDE_BOTTOM then
            rounded_elapsed_x = rect_x + rect_width - (corner_size - (corner_size * math.sin(angle_rotate)))
            rounded_elapsed_y = rect_y + rect_height - corner_size + (corner_size * math.cos(angle_rotate))
        elseif side == SIDE_LEFT then
            rounded_elapsed_x = rect_x + (corner_size - (corner_size * math.cos(angle_rotate)))
            rounded_elapsed_y = rect_y + rect_height - (corner_size - (corner_size * math.sin(angle_rotate)))
        end
    elseif corner.which == CORNER_END then
        local angle_rotate = math.atan(corner_elapsed_amount / corner_size)
        if side == SIDE_TOP then
            rounded_elapsed_x = rect_x + rect_width - corner_size + (corner_size * math.sin(angle_rotate))
            rounded_elapsed_y = rect_y + (corner_size - (corner_size * math.cos(angle_rotate)))
        elseif side == SIDE_RIGHT then
            rounded_elapsed_x = rect_x + rect_width - (corner_size - (corner_size * math.cos(angle_rotate)))
            rounded_elapsed_y = rect_y + rect_height - (corner_size - (corner_size * math.sin(angle_rotate)))
        elseif side == SIDE_BOTTOM then
            rounded_elapsed_x = rect_x + (corner_size - (corner_size * math.sin(angle_rotate)))
            rounded_elapsed_y = rect_y + rect_height - (corner_size - (corner_size * math.cos(angle_rotate)))
        elseif side == SIDE_LEFT then
            rounded_elapsed_x = rect_x + (corner_size - (corner_size * math.cos(angle_rotate)))
            rounded_elapsed_y = rect_y + (corner_size - (corner_size * math.sin(angle_rotate)))
        end
    end

    return { elapsed_x = rounded_elapsed_x, elapsed_y = rounded_elapsed_y }

end

local function get_rounded_perimeter(width, height, rounded_amount)
    -- local blob = self._private.blob_data

    -- if blob == nil then
    --     return 0
    -- end

    -- local width = blob.width
    -- local height = blob.height
    local half_width = width / 2
    local half_height = height / 2
    local corner_size = rounded_amount
    if width > height then
        if corner_size > half_height then
            corner_size = half_height
        end
    else
        if corner_size > half_width then
            corner_size = half_width
        end
    end

    local cornerless_perimeter = ((width * 2) + (height * 2)) - (corner_size * 8)

    return ((math.pi * 2) * corner_size) + cornerless_perimeter
end

local function _calculate_rect_and_rounded_data(data)

    local points = {}

    local wave_amount = data.wave_amount
    local max_wave_height = data.max_wave_height
    local offset = data.offset
    local x = data.x
    local y = data.y
    local width = data.width
    local height = data.height
    local corner_size = data.corner_size
    local viscosity = data.viscosity
    local base_wave_width = data.base_wave_width
    local wave_heights = data.wave_heights
    local wave_spaces = data.wave_spaces

    local rounded_perimeter = get_rounded_perimeter(width, height, corner_size)
    local cornerless_height = height - corner_size * 2
    local cornerless_width = width - corner_size * 2
    local half_cornerless_height = cornerless_height / 2
    local arc_length = (math.pi / 2) * corner_size
    local ideal_peak_space = rounded_perimeter / wave_amount
    local number_of_custom_waves = 0
    local total_custom_wave_space = 0
    for _, v in pairs(wave_spaces) do
        total_custom_wave_space = total_custom_wave_space + (v * ideal_peak_space)
        number_of_custom_waves = number_of_custom_waves + 1
    end
    local remaining_perimeter = rounded_perimeter - total_custom_wave_space

    -- local function clamp(shrink_amount)
    --     if shrink_amount > 1 then
    --         shrink_amount = 1
    --     elseif shrink_amount < 0 then
    --         shrink_amount = 0
    --     end
    --     return ((-math.atan(x * 2) / (math.pi / 2)) * shrink_amount) + 1
    -- end

    local peak_to_valley_distance = remaining_perimeter / ((wave_amount - number_of_custom_waves) * 2)
    -- local peak_to_valley_distance = rounded_perimeter / (wave_amount  * 2)
    local half_peak_to_valley_distance = peak_to_valley_distance / 2

    local peaks = {}
    local peaks_misarranged_knobs = {}
    local valleys = {}
    local valleys_misarranged_knobs = {}

    -- local previous_custom_half_waves = 0
    -- local previous_custom_wave_space = 0

    local previous_wave_space = 0

    for i=1, wave_amount * 2 do


        if i % 2 == 0 then -- valley point

            -- local real_elapsed = (flat_elapsed + ((i-1) * peak_to_valley_distance)) % rounded_perimeter

            -- local prev_peak_i = (i/2)
            -- if wave_spaces[prev_peak_i] ~= nil then
            -- end
            local backward_peak_i = i/2
            local safe_forward_peak_i = i/2 + 1
            if safe_forward_peak_i > wave_amount then
                safe_forward_peak_i = 1
            end

            local backward_peak_space_factor = wave_spaces[backward_peak_i] or 1
            local forward_peak_space_factor = wave_spaces[safe_forward_peak_i] or 1
            local backward_peak_to_valley_distance = backward_peak_space_factor * peak_to_valley_distance
            local forward_peak_to_valley_distance = forward_peak_space_factor * peak_to_valley_distance

            local current_point_offset = previous_wave_space + backward_peak_to_valley_distance
            previous_wave_space = current_point_offset
            local real_offset = (current_point_offset + offset) % rounded_perimeter

            local backward_peak_height_factor = wave_heights[i/2] or 0
            local forward_peak_height_factor = wave_heights[safe_forward_peak_i] or 0
            local backward_peak_height = backward_peak_height_factor * max_wave_height
            local forward_peak_height = forward_peak_height_factor * max_wave_height
            local viscosity_height = math.min(backward_peak_height, forward_peak_height) * viscosity
            local viscosity_knob1_push_width = (backward_peak_to_valley_distance / 2)
            local viscosity_knob2_push_width = (forward_peak_to_valley_distance / 2)

            local valley_x, valley_y
            local knob1_x, knob1_y, knob2_x, knob2_y

            if real_offset < half_cornerless_height then
                valley_x = x + width + viscosity_height
                valley_y = y + corner_size + half_cornerless_height + real_offset
                knob1_x = valley_x
                knob1_y = valley_y - viscosity_knob1_push_width
                knob2_x = valley_x
                knob2_y = valley_y + viscosity_knob2_push_width
            elseif real_offset < half_cornerless_height + arc_length then
                local relative_offset = real_offset - half_cornerless_height
                local angle = offset_to_90_angle(relative_offset, arc_length)
                local knob1_relative_x = math.cos(angle - (math.pi / 2))
                local knob1_relative_y = math.sin(angle - (math.pi / 2))
                local knob2_relative_x = math.cos(angle + (math.pi / 2))
                local knob2_relative_y = math.sin(angle + (math.pi / 2))
                valley_x = x + width - corner_size + ((corner_size + viscosity_height) * math.cos(angle))
                valley_y = y + height - corner_size + ((corner_size + viscosity_height) * math.sin(angle))
                knob1_x = valley_x + (viscosity_knob1_push_width * knob1_relative_x)
                knob1_y = valley_y + (viscosity_knob1_push_width * knob1_relative_y)
                knob2_x = valley_x + (viscosity_knob2_push_width * knob2_relative_x)
                knob2_y = valley_y + (viscosity_knob2_push_width* knob2_relative_y)
            elseif real_offset < half_cornerless_height + arc_length + cornerless_width then
                local relative_offset = real_offset - half_cornerless_height - arc_length
                valley_x = x + width - corner_size - relative_offset
                valley_y = y + height + viscosity_height
                knob1_x = valley_x + viscosity_knob1_push_width
                knob1_y = valley_y
                knob2_x = valley_x - viscosity_knob2_push_width
                knob2_y = valley_y
            elseif real_offset < half_cornerless_height + arc_length + cornerless_width + arc_length then
                local relative_offset = real_offset - half_cornerless_height - arc_length - cornerless_width
                local angle = offset_to_90_angle(relative_offset, arc_length)
                local knob1_relative_x = math.sin(angle - (math.pi / 2))
                local knob1_relative_y = math.cos(angle - (math.pi / 2))
                local knob2_relative_x = math.sin(angle + (math.pi / 2))
                local knob2_relative_y = math.cos(angle + (math.pi / 2))
                valley_x = x + corner_size - ((corner_size + viscosity_height) * math.sin(angle))
                valley_y = y + height - corner_size + ((corner_size + viscosity_height) * math.cos(angle))
                knob1_x = valley_x - (viscosity_knob1_push_width * knob1_relative_x)
                knob1_y = valley_y + (viscosity_knob1_push_width * knob1_relative_y)
                knob2_x = valley_x - (viscosity_knob2_push_width * knob2_relative_x)
                knob2_y = valley_y + (viscosity_knob2_push_width * knob2_relative_y)
            elseif real_offset < half_cornerless_height + arc_length + cornerless_width + arc_length + cornerless_height then
                local relative_offset = real_offset - half_cornerless_height - arc_length - cornerless_width - arc_length
                valley_x = x - viscosity_height
                valley_y = y + height - corner_size - relative_offset
                knob1_x = valley_x
                knob1_y = valley_y + viscosity_knob1_push_width
                knob2_x = valley_x
                knob2_y = valley_y - viscosity_knob2_push_width
            elseif real_offset < half_cornerless_height + arc_length + cornerless_width + arc_length + cornerless_height + arc_length then
                local relative_offset = real_offset - half_cornerless_height - arc_length - cornerless_width - arc_length - cornerless_height
                local angle = offset_to_90_angle(relative_offset, arc_length)
                local knob1_relative_x = math.cos(angle - (math.pi / 2))
                local knob1_relative_y = math.sin(angle - (math.pi / 2))
                local knob2_relative_x = math.cos(angle + (math.pi / 2))
                local knob2_relative_y = math.sin(angle + (math.pi / 2))
                valley_x = x + corner_size - ((corner_size + viscosity_height) * math.cos(angle))
                valley_y = y + corner_size - ((corner_size + viscosity_height) * math.sin(angle))
                knob1_x = valley_x - (viscosity_knob1_push_width * knob1_relative_x)
                knob1_y = valley_y - (viscosity_knob1_push_width * knob1_relative_y)
                knob2_x = valley_x - (viscosity_knob2_push_width * knob2_relative_x)
                knob2_y = valley_y - (viscosity_knob2_push_width * knob2_relative_y)
            elseif real_offset < half_cornerless_height + arc_length + cornerless_width + arc_length + cornerless_height + arc_length + cornerless_width then
                local relative_offset = real_offset - half_cornerless_height - arc_length - cornerless_width - arc_length - cornerless_height - arc_length
                valley_x = x + corner_size + relative_offset
                valley_y = y - viscosity_height
                knob1_x = valley_x - viscosity_knob1_push_width
                knob1_y = valley_y
                knob2_x = valley_x + viscosity_knob2_push_width
                knob2_y = valley_y
            elseif real_offset < half_cornerless_height + cornerless_height + (cornerless_width * 2) + (arc_length * 4) then
                local relative_offset = real_offset - half_cornerless_height - arc_length - cornerless_width - arc_length - cornerless_height - arc_length - cornerless_width
                local angle = offset_to_90_angle(relative_offset, arc_length)
                local knob1_relative_x = math.sin(angle - (math.pi / 2))
                local knob1_relative_y = math.cos(angle - (math.pi / 2))
                local knob2_relative_x = math.sin(angle + (math.pi / 2))
                local knob2_relative_y = math.cos(angle + (math.pi / 2))
                valley_x = x + width - corner_size + ((corner_size + viscosity_height) * math.sin(angle))
                valley_y = y + (corner_size - ((corner_size + viscosity_height) * math.cos(angle)))
                knob1_x = valley_x + (viscosity_knob1_push_width * knob1_relative_x)
                knob1_y = valley_y - (viscosity_knob1_push_width * knob1_relative_y)
                knob2_x = valley_x + (viscosity_knob2_push_width * knob2_relative_x)
                knob2_y = valley_y - (viscosity_knob2_push_width * knob2_relative_y)
            else
                local relative_offset = real_offset - half_cornerless_height - (arc_length * 4) - (cornerless_width * 2) - cornerless_height
                valley_x = x + width + viscosity_height
                valley_y = y + corner_size + relative_offset
                knob1_x = valley_x
                knob1_y = valley_y - viscosity_knob1_push_width
                knob2_x = valley_x
                knob2_y = valley_y + viscosity_knob2_push_width
            end


            table.insert(valleys, {
                type = WAVE_VALLEY,
                elapsed_x = valley_x,
                elapsed_y = valley_y,
            })

            table.insert(valleys_misarranged_knobs, {
                knob1_x = knob1_x,
                knob1_y = knob1_y,
                knob2_x = knob2_x,
                knob2_y = knob2_y,
            })

        else -- peak point
            local real_wave_ind = ((i + 1) / 2)
            local this_peak_push = peak_to_valley_distance
            if wave_spaces[real_wave_ind] ~= nil then
                local modifier = wave_spaces[real_wave_ind]
                this_peak_push = peak_to_valley_distance * modifier
            end

            local current_point_offset = previous_wave_space + this_peak_push
            previous_wave_space = current_point_offset
            local push_knob1_amount = base_wave_width * (this_peak_push / 2)
            local push_knob2_amount = push_knob1_amount -- TODO: make these different for a more fluid & natural effect
            local real_offset = (current_point_offset + offset) % rounded_perimeter

            local set_wave_height = wave_heights[real_wave_ind] or 0
            local peak_height = set_wave_height * max_wave_height

            local peak_x, peak_y
            local knob1_x, knob1_y, knob2_x, knob2_y

            if real_offset < half_cornerless_height then
                peak_x = x + width + peak_height
                peak_y = y + corner_size + half_cornerless_height + real_offset
                knob1_x = peak_x
                knob1_y = peak_y - push_knob1_amount
                knob2_x = peak_x
                knob2_y = peak_y + push_knob2_amount
            elseif real_offset < half_cornerless_height + arc_length then
                local relative_offset = real_offset - half_cornerless_height
                local angle = offset_to_90_angle(relative_offset, arc_length)
                peak_x = x + width - corner_size + ((corner_size + peak_height) * math.cos(angle))
                peak_y = y + height - corner_size + ((corner_size + peak_height) * math.sin(angle))
                local knob1_relative_x = math.cos(angle - (math.pi / 2))
                local knob1_relative_y = math.sin(angle - (math.pi / 2))
                local knob2_relative_x = math.cos(angle + (math.pi / 2))
                local knob2_relative_y = math.sin(angle + (math.pi / 2))
                knob1_x = peak_x + (push_knob1_amount * knob1_relative_x)
                knob1_y = peak_y + (push_knob1_amount * knob1_relative_y)
                knob2_x = peak_x + (push_knob2_amount * knob2_relative_x)
                knob2_y = peak_y + (push_knob2_amount * knob2_relative_y)
            elseif real_offset < half_cornerless_height + arc_length + cornerless_width then
                local relative_offset = real_offset - half_cornerless_height - arc_length
                peak_x = x + width - corner_size - relative_offset
                peak_y = y + height + peak_height
                knob1_x = peak_x + push_knob1_amount
                knob1_y = peak_y
                knob2_x = peak_x - push_knob2_amount
                knob2_y = peak_y
            elseif real_offset < half_cornerless_height + arc_length + cornerless_width + arc_length then
                local relative_offset = real_offset - half_cornerless_height - arc_length - cornerless_width
                local angle = offset_to_90_angle(relative_offset, arc_length)
                peak_x = x + corner_size - ((corner_size + peak_height) * math.sin(angle))
                peak_y = y + height - corner_size + ((corner_size + peak_height) * math.cos(angle))
                local knob1_relative_x = math.sin(angle - (math.pi / 2))
                local knob1_relative_y = math.cos(angle - (math.pi / 2))
                local knob2_relative_x = math.sin(angle + (math.pi / 2))
                local knob2_relative_y = math.cos(angle + (math.pi / 2))
                knob1_x = peak_x - (push_knob1_amount * knob1_relative_x)
                knob1_y = peak_y + (push_knob1_amount * knob1_relative_y)
                knob2_x = peak_x - (push_knob2_amount * knob2_relative_x)
                knob2_y = peak_y + (push_knob2_amount * knob2_relative_y)
            elseif real_offset< half_cornerless_height + arc_length + cornerless_width + arc_length + cornerless_height then
                local relative_offset = real_offset - half_cornerless_height - arc_length - cornerless_width - arc_length
                peak_x = x - peak_height
                peak_y = y + height - corner_size - relative_offset
                knob1_x = peak_x
                knob1_y = peak_y + push_knob1_amount
                knob2_x = peak_x
                knob2_y = peak_y - push_knob2_amount
            elseif real_offset < half_cornerless_height + arc_length + cornerless_width + arc_length + cornerless_height + arc_length then
                local relative_offset = real_offset - half_cornerless_height - arc_length - cornerless_width - arc_length - cornerless_height
                local angle = offset_to_90_angle(relative_offset, arc_length)
                peak_x = x + corner_size - ((corner_size + peak_height) * math.cos(angle))
                peak_y = y + corner_size - ((corner_size + peak_height) * math.sin(angle))
                local knob1_relative_x = math.cos(angle - (math.pi / 2))
                local knob1_relative_y = math.sin(angle - (math.pi / 2))
                local knob2_relative_x = math.cos(angle + (math.pi / 2))
                local knob2_relative_y = math.sin(angle + (math.pi / 2))
                knob1_x = peak_x - (push_knob1_amount * knob1_relative_x)
                knob1_y = peak_y - (push_knob2_amount * knob1_relative_y)
                knob2_x = peak_x - (push_knob1_amount * knob2_relative_x)
                knob2_y = peak_y - (push_knob2_amount * knob2_relative_y)
            elseif real_offset < half_cornerless_height + arc_length + cornerless_width + arc_length + cornerless_height + arc_length + cornerless_width then
                local relative_offset = real_offset - half_cornerless_height - arc_length - cornerless_width - arc_length - cornerless_height - arc_length
                peak_x = x + corner_size + relative_offset
                peak_y = y - peak_height
                knob1_x = peak_x - push_knob1_amount
                knob1_y = peak_y
                knob2_x = peak_x + push_knob2_amount
                knob2_y = peak_y
            elseif real_offset < half_cornerless_height + cornerless_height + (cornerless_width * 2) + (arc_length * 4) then
                local relative_offset = real_offset - half_cornerless_height - arc_length - cornerless_width - arc_length - cornerless_height - arc_length - cornerless_width
                local angle = offset_to_90_angle(relative_offset, arc_length)
                peak_x = x + width - corner_size + ((corner_size + peak_height) * math.sin(angle))
                peak_y = y + (corner_size - ((corner_size + peak_height) * math.cos(angle)))
                local knob1_relative_x = math.sin(angle - (math.pi / 2))
                local knob1_relative_y = math.cos(angle - (math.pi / 2))
                local knob2_relative_x = math.sin(angle + (math.pi / 2))
                local knob2_relative_y = math.cos(angle + (math.pi / 2))
                knob1_x = peak_x + (push_knob1_amount * knob1_relative_x)
                knob1_y = peak_y - (push_knob1_amount * knob1_relative_y)
                knob2_x = peak_x + (push_knob2_amount * knob2_relative_x)
                knob2_y = peak_y - (push_knob2_amount * knob2_relative_y)
            else
                local relative_offset = real_offset - half_cornerless_height - (arc_length * 4) - (cornerless_width * 2) - cornerless_height
                peak_x = x + width + peak_height
                peak_y = y + corner_size + relative_offset
                knob1_x = peak_x
                knob1_y = peak_y - push_knob1_amount
                knob2_x = peak_x
                knob2_y = peak_y + push_knob2_amount
            end

            table.insert(peaks, {
                type = WAVE_PEAK,
                elapsed_x = peak_x,
                elapsed_y = peak_y,
            })

            table.insert(peaks_misarranged_knobs, {
                knob1_x = knob1_x,
                knob1_y = knob1_y,
                knob2_x = knob2_x,
                knob2_y = knob2_y
            })

        end
    end

    points.debug_peaks_knobs = peaks_misarranged_knobs
    points.debug_valleys_knobs = valleys_misarranged_knobs


    for i=1, #peaks_misarranged_knobs do
        local current_peak = peaks_misarranged_knobs[i]
        local peak_real_knob1_x = current_peak.knob2_x
        local peak_real_knob1_y = current_peak.knob2_y

        local next_i = i + 1
        if next_i > #peaks_misarranged_knobs then
            next_i = 1
        end

        local next_peak = peaks_misarranged_knobs[next_i]
        local peak_real_knob2_x = next_peak.knob1_x
        local peak_real_knob2_y = next_peak.knob1_y

        peaks[i].knob1_x = peak_real_knob1_x
        peaks[i].knob1_y = peak_real_knob1_y
        peaks[i].knob2_x = peak_real_knob2_x
        peaks[i].knob2_y = peak_real_knob2_y


        local v = valleys_misarranged_knobs[i]
        valleys[i].knob1_x = v.knob1_x
        valleys[i].knob1_y = v.knob1_y
        valleys[i].knob2_x = v.knob2_x
        valleys[i].knob2_y = v.knob2_y

        -- local current_valley = valleys_misarranged_knobs[i]
        -- local valley_real_knob1_x = current_valley.knob2_x
        -- local valley_real_knob1_y = current_valley.knob2_y

        -- local next_valley = valleys_misarranged_knobs[next_i]
        -- local valley_real_knob2_x = next_valley.knob1_x
        -- local valley_real_knob2_y = next_valley.knob1_y

        -- points.valleys[i].knob1_x = valley_real_knob1_x
        -- points.valleys[i].knob1_y = valley_real_knob1_y
        -- points.valleys[i].knob2_x = valley_real_knob2_x
        -- points.valleys[i].knob2_y = valley_real_knob2_y

    end

    points.peaks = peaks
    points.valleys = valleys

    return points
end

local function _calculate_wave_points(self)
    local points = {}
    local debug = {}

    local max_wave_height = self.max_wave_height
    local blob_x = max_wave_height
    local blob_y = max_wave_height
    -- TODO: maybe find a better way to use this data
    local blob_width = self.geometry.width - (max_wave_height * 2)
    local blob_height = self.geometry.height - (max_wave_height * 2)
    local offset = self.offset
    local wave_amount = self.wave_amount
    local rounded_amount = self.rounded_amount
    local viscosity = self.viscosity
    local base_wave_width = self.base_wave_width
    local wave_heights = self._private.blob_data.wave_heights
    local wave_spaces = self._private.blob_data.wave_spaces

    local blob_half_width = blob_width / 2
    local blob_half_height = blob_height / 2
    if blob_width > blob_height then
        if rounded_amount > blob_half_height then
            rounded_amount = blob_half_height
        end
    else
        if rounded_amount > blob_half_width then
            rounded_amount = blob_half_width
        end
    end

    debug.points = _calculate_rect_and_rounded_data({
        wave_amount = wave_amount,
        max_wave_height = max_wave_height,
        offset = offset,
        wave_heights = wave_heights,
        wave_spaces = wave_spaces,
        x = blob_x,
        y = blob_y,
        width = blob_width,
        height = blob_height,
        corner_size = rounded_amount,
        viscosity = viscosity,
        base_wave_width = base_wave_width,
    })

    debug.rect_data = {
        x = blob_x,
        y = blob_y,
        width = blob_width,
        height = blob_height,
        elapsed_x = debug.points.peaks[1].elapsed_x,
        elapsed_y = debug.points.peaks[1].elapsed_y,
    }

    debug.rect_corners = {
        {x = blob_x, y = blob_y},
        {x = blob_x + blob_width, y = blob_y},
        {x = blob_x + blob_width, y = blob_y + blob_height},
        {x = blob_x, y = blob_y + blob_height}
    }
    debug.corner_size = rounded_amount

    return points, debug

end

local function _draw(self, cr, context_width, context_height) -- TODO: add context parameter
    cr:save()

    local points, debug_data = _calculate_wave_points(self)
    _debug_draw_blob(self, cr, debug_data.points.peaks, debug_data.points.valleys)

    if self.debug_mode == true then
        for i=1, #debug_data.points.peaks do
            local p = debug_data.points.peaks[i]
            local misarranged_knobs = debug_data.points.debug_peaks_knobs[i]
            local elapsed_x = p.elapsed_x
            local elapsed_y = p.elapsed_y
            local knob1_x = misarranged_knobs.knob1_x
            local knob1_y = misarranged_knobs.knob1_y
            local knob2_x = misarranged_knobs.knob2_x
            local knob2_y = misarranged_knobs.knob2_y
            _debug_draw_rect_elapsed_point(self, cr, p)
            _debug_draw_bezier_knobs(self, cr, elapsed_x, elapsed_y, knob1_x, knob1_y, knob2_x, knob2_y, self._private.debug.color3)
        end
        for i=1, #debug_data.points.valleys do
            local v = debug_data.points.valleys[i]
            local misarranged_knobs = debug_data.points.debug_valleys_knobs[i]
            local elapsed_x = v.elapsed_x
            local elapsed_y = v.elapsed_y
            local knob1_x = misarranged_knobs.knob1_x
            local knob1_y = misarranged_knobs.knob1_y
            local knob2_x = misarranged_knobs.knob2_x
            local knob2_y = misarranged_knobs.knob2_y
            _debug_draw_rounded_elapsed_point(self, cr, v)
            _debug_draw_bezier_knobs(self, cr, elapsed_x, elapsed_y, knob1_x, knob1_y, knob2_x, knob2_y, self._private.debug.color3)
        end

        _debug_draw_rect_elapsed_amount(self, cr, debug_data)
        _debug_draw_inner_rounded_rectangle(self, cr, debug_data)
    end

    -- local x = 40
    -- local y = 40
    -- local r = 20

    -- local c_x = 120
    -- local c_y = 20
    -- local c_r = 40

    -- cr:translate(x , y)
    -- cr:scale(3, 3)
    -- cr:save()
    -- cr:set_source(color("#ff7755"))
    -- -- cr:translate(x/2, y)
    -- gshape.circle(cr, c_r, c_r)
    -- cr:fill()
    -- cr:restore()

    -- cr:set_source(color("#ff0f66"))

    -- -- cr:scale(2, 2)
    -- cr:move_to(x, y)

    -- -- cr:curve_to(x+r, y-r, x+r, y, x+r, y)
    -- -- cr:curve_to(x+r, y+r, x, y+r, x, y+r)
    -- -- cr:curve_to(x-r, y+r, x-r, y, x-r, y)
    -- -- cr:curve_to(x-r, y-r, x, y-r, x, y-r)
    -- local c_push = 20
    -- local b = c_push / 1.80

    -- cr:rel_curve_to(b, 0, c_push, c_push - b, c_push, c_push)
    -- cr:rel_curve_to(0, b, -c_push + b, c_push, -c_push, c_push)
    -- cr:rel_curve_to(-b, 0, -c_push, -c_push+b, -c_push, -c_push)
    -- cr:rel_curve_to(0, -b, c_push-b, -c_push, c_push, -c_push)
    -- cr:fill()

    cr:restore()
end

-- function viscanvas:set_initial_blob_data(data)

--     local x = data.x
--     local y = data.y
--     local width = data.width
--     local height = data.height
--     local rounded_amount = data.rounded_amount
--     local wave_amount = data.wave_amount
--     local max_wave_height = data.max_wave_height
--     local viscosity = data.viscosity
--     local base_wave_width = data.base_wave_width

--     self._private.blob_data = {
--         x = x,
--         y = y,
--         width = width,
--         height = height,
--         rounded_amount = rounded_amount,
--         wave_amount = wave_amount,
--         max_wave_height = max_wave_height,
--         viscosity = viscosity,
--         base_wave_width = base_wave_width,
--         offset = data.offset,
--         wave_heights = {}, -- will be set later
--         wave_spaces = {} -- will be set later
--     }

-- end

-- local function create_blob_setters(canvas)
--     local props = { "x", "y", "width", "height", "rounded_amount", "wave_amount", "max_wave_height", "viscosity", "base_wave_width" }
--     for _, prop in ipairs(props) do
--         local setter = "set_" .. prop
--         if canvas[setter] == nil then
--             canvas[setter] = function(self, v)
--                 self._private.blob_data[prop] = v
--             end
--         end
--     end
-- end

-- function viscanvas:set_offset(offset)
--     self._private.blob_data.offset = offset
-- end

-- function viscanvas:get_offset()
--     return self._private.blob_data.offset
-- end

-- -- ind : which wave do you want to set the height on? (numbers outside of 1<->wave_amount will be discarded)
-- -- height : number between 0 and 1 meaning percentage between 0 and "max_wave_height"
-- function viscanvas:set_wave_height(ind, height)
--     if ind < 0 then return end
--     if ind > self._private.blob_data.wave_amount then return end
--     if height > 1 then height = 1 end
--     if height < 0 then height = 0 end
--     self._private.blob_data.wave_heights[ind] = height
-- end

-- function viscanvas:set_wave_space(ind, space)
--     if ind < 0 then return end
--     if ind > self._private.blob_data.wave_amount then return end
--     if space > 1 then space = 1 end
--     if space < 0 then space = 0 end
--     self._private.blob_data.wave_spaces[ind] = space
-- end

-- function viscanvas:get_wave_amount()
--     return self._private.blob_data.wave_amount
-- end


local function _calculate_minimum_dimensions(self, context_width, context_height) --TODO: add context paremeter
    -- return 0, 0 because the parent of this widget should be
    -- setting explicit dimensions for this element
    return 0, 0
end

local function _layout_children(self, available_width, available_height)

    local child = self[1]
    if child == nil then return nil end

    local max_wave_height = self.max_wave_height
    local max_inner_w = available_width - (max_wave_height * 2)
    local max_inner_h = available_height - (max_wave_height * 2)
    local raw_child_w = child.width
    local raw_child_h = child.height

    local real_child_w, real_child_h
    if type(raw_child_w) == "number" then
        real_child_w = math.min(max_inner_w, raw_child_w)
    elseif etypes.is_size_fill(raw_child_w) then
        real_child_w = max_inner_w
    else
        local child_min_w, _ = child._calculate_minimum_dimensions(child, max_inner_w, max_inner_h)
        real_child_w = math.min(max_inner_w, child_min_w)
    end
    if type(raw_child_h) == "number" then
        real_child_h = math.min(max_inner_h, raw_child_h)
    elseif etypes.is_size_fill(raw_child_h) then
        real_child_h = max_inner_h
    else
        local _, child_min_h = child._calculate_minimum_dimensions(child, max_inner_w, max_inner_h)
        real_child_h = math.min(max_inner_h, child_min_h)
    end

    local raw_child_halign = child.halign
    local raw_child_valign = child.valign
    local standardized_padding = eutil.standardize_padding(child.padding or 0)

    local aligned_x = max_wave_height + standardized_padding.left
    local aligned_y = max_wave_height + standardized_padding.top

    if raw_child_halign == etypes.align.center then
        aligned_x = (available_width / 2) - (real_child_w / 2)
    elseif raw_child_halign == etypes.align.right then
        aligned_x = (available_width - max_wave_height) - (real_child_w + standardized_padding.right)
    end

    if raw_child_valign == etypes.align.center then
        aligned_y = (available_height / 2) - (real_child_h / 2)
    elseif raw_child_valign == etypes.align.bottom then
        aligned_y = (available_height - max_wave_height) - (real_child_h + standardized_padding.bottom)
    end

    return {
        { -- viscanvas can only hold one child
            x = aligned_x,
            y = aligned_y,
            width = real_child_w,
            height = real_child_h,
        }
    }

end

local function new(args)

    local defaults = {
        _draw = _draw,
        _calculate_minimum_dimensions = _calculate_minimum_dimensions,
        _layout_children = _layout_children,

        width = 0,
        height = 0,
        max_wave_height = 0,
        wave_amount = 1,
        rounded_amount = 0,
        viscosity = 0,
        base_wave_width = 0,
        offset = 0,
        debug_mode = false,

        _private = {
            blob_data = {
                -- x = x, --TODO: remove this. the blob can be offset by setting "offset_x" on it
                -- y = y,
                wave_heights = {}, -- will be set later
                wave_spaces = {} -- will be set later
            },
            debug = {
                color1 = "#ff4455",
                color2 = "#994455",
                color3 = "#99ff55",
                color4 = "#28ffff",
                -- color5 = "#5940c0",
                -- color5 = "#fec822",
                -- color5 = "#ffffff",
                -- color5 = "#3e2a8a",
                -- color5 = "#06030b",
                color5 = "#0f0b16",
                color6 = "#ff2faa",
                color7 = "#ffffff",
                offset_on_scroll = true,
                offset = 0
            }
        }
    }

    local ext = extension.new()
    ttable.override_b_to_a(defaults, args)
    ttable.override_b_to_a(ext, defaults)
    return ext
end

-- ind : which wave do you want to set the height on? (numbers outside of 1<->wave_amount will be discarded)
-- height : number between 0 and 1 meaning percentage between 0 and "max_wave_height"
local function set_wave_height(att_viscanvas, ind, height)
    if ind < 0 then return end
    if ind > att_viscanvas.wave_amount then return end
    if height > 1 then height = 1 end
    if height < 0 then height = 0 end
    att_viscanvas._private.blob_data.wave_heights[ind] = height
    eutil.mark_redraw(att_viscanvas)
end

local function set_offset(att_viscanvas, offset)
    if att_viscanvas.offset == offset then return end
    att_viscanvas.offset = offset
    eutil.mark_redraw(att_viscanvas)
end

return {
    new = new,

    set_wave_height = set_wave_height,
    set_offset = set_offset,
}

