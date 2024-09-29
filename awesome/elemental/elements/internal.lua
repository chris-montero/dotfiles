
local cairo = require("lgi").cairo
local esource = require("elemental.source")
local etypes = require("elemental.types")
local eutil = require("elemental.util")
local tshape = require("tools.shape")
local tcolor = require("tools.color")

local POSITION_START = 1
local POSITION_START_END = 2
local POSITION_START_CENTER_END = 3

-- make sure a surface pattern is freed NOW
local function _dispose_pattern(pattern)
    local status, s = pattern:get_surface()
    if status == "SUCCESS" then
        s:finish()
    end
end

local function align_on_secondary_axis(padding_start, padding_end, align_, context_size, element_size)
    if align_ == etypes.ALIGN_BOTTOM or align_ == etypes.ALIGN_RIGHT then
        return context_size - (element_size + padding_end)
    elseif align_ == etypes.ALIGN_CENTER then
        return (context_size / 2) - (element_size / 2)
    else
        return padding_start
    end
end

local function get_border_width(branch)
    local bg = branch.bg
    if branch.bg == nil then return 0 end
    if bg.border_width == nil then return 0 end
    return bg.border_width
end

local function _get_spacing_between_elements(children_amt, spacing)
    -- if we have 0 or 1 children, there's 0 spacing
    -- if there's 2 or more, we have (num_children - 1) * spacing
    if children_amt >= 2 then
        return spacing * (children_amt - 1)
    end
    return 0
end

local function apply_clip_shape(branch, cr, width, height) -- LEFTOFF

    local clip_shape = branch.clip_shape
    if clip_shape ~= nil then
        clip_shape(branch, cr, width, height)
        return
    end

    local bg = branch.bg
    if bg == nil then
        return
    end

    local border_radius = bg.border_radius or 0
    if border_radius == 0 then
        return
    end

    if branch.clip_to_background == true then

        local border_width = bg.border_width or 0
        cr:translate(border_width, border_width)
        tshape.rounded_rectangle(
            cr,
            width - (border_width * 2),
            height - (border_width * 2),
            border_radius
        )

    end

end

-- this function should return all children in a contiguous array, in the order
-- we want the children to be drawn in
local function get_all_children(branch)
    local all = {}
    if branch.shadow ~= nil then
        table.insert(all, branch.shadow)
    end
    if branch.bg ~= nil then
        table.insert(all, branch.bg)
    end
    for _, child in ipairs(branch) do
        table.insert(all, child)
    end
    return all
end

local function calculate_minimum_dimensions_horizontal(branch, constraint_w, constraint_h)

    local spacing = branch.spacing or 0
    local standardized_padding = eutil.standardize_padding(branch.padding or 0)
    local el_bw = get_border_width(branch)

    local acc_w =
        standardized_padding.left +
        standardized_padding.right +
        _get_spacing_between_elements(#branch, spacing)
        + (el_bw * 2)
    local min_h = standardized_padding.top + standardized_padding.bottom + (el_bw * 2)
    local max_h = 0

    -- NOTE: only go through the children in the array portion of the table because
    -- we don't want the shadow or the bg to take up horizontal space
    for _, child in ipairs(branch) do
        -- NOTE: child_min_w and child_min_h already includes the border width
        local child_border_width = get_border_width(child)
        local child_standardized_padding = eutil.standardize_padding(child.padding or 0)
        local child_w, child_h = child.width, child.height
        if type(child_w) == "number" and type(child_h) == "number" then
            acc_w = acc_w
                + child_w
                + (child_border_width * 2)
                + child_standardized_padding.left
                + child_standardized_padding.right
            max_h = math.max(
                max_h,
                child_h
                    + (child_border_width * 2)
                    + child_standardized_padding.top
                    + child_standardized_padding.bottom
            )
        elseif type(child_w) == "number" and type(child_h) ~= "number" then
            local _, child_min_h = child._calculate_minimum_dimensions(child, constraint_w, constraint_h)
            acc_w = acc_w
                + child_w
                + (child_border_width * 2)
                + child_standardized_padding.left
                + child_standardized_padding.right
            max_h = math.max(max_h, child_min_h)
        elseif type(child_w) ~= "number" and type(child_h) == "number" then
            local child_min_w, _ = child._calculate_minimum_dimensions(child, constraint_w, constraint_h)
            acc_w = acc_w + child_min_w
            max_h = math.max(
                max_h,
                child_h
                    + (child_border_width * 2)
                    + child_standardized_padding.top
                    + child_standardized_padding.bottom
            )
        else -- both are not numbers
            local child_min_w, child_min_h = child._calculate_minimum_dimensions(child, constraint_w, constraint_h)
            acc_w = acc_w + child_min_w
            max_h = math.max(max_h, child_min_h)
        end
    end

    return acc_w, min_h + max_h
end

local function calculate_minimum_dimensions_vertical(branch, constraint_w, constraint_h)

    local spacing = branch.spacing or 0
    local standardized_padding = eutil.standardize_padding(branch.padding or 0)
    local el_bw = get_border_width(branch)

    local acc_h =
        standardized_padding.top +
        standardized_padding.bottom +
        _get_spacing_between_elements(#branch, spacing)
        + (el_bw * 2)
    local min_w = standardized_padding.left + standardized_padding.right + (el_bw * 2)
    local max_w = 0

    -- NOTE: only go through the children in the array portion of the table because
    -- we don't want the shadow or the bg to take up horizontal space
    for _, child in ipairs(branch) do

        local child_border_width = get_border_width(child)
        local child_standardized_padding = eutil.standardize_padding(child.padding or 0)
        local child_w, child_h = child.width, child.height

        if type(child_w) == "number" and type(child_h) == "number" then
            max_w = math.max(
                max_w,
                child_w
                    + (child_border_width * 2)
                    + child_standardized_padding.left
                    + child_standardized_padding.right
            )
            acc_h = acc_h
                + child_h
                + (child_border_width * 2)
                + child_standardized_padding.top
                + child_standardized_padding.bottom
        elseif type(child_w) == "number" and type(child_h) ~= "number" then
            local _, child_min_h = child._calculate_minimum_dimensions(child, constraint_w, constraint_h)
            max_w = math.max(
                max_w,
                child_w
                    + (child_border_width * 2)
                    + child_standardized_padding.left
                    + child_standardized_padding.right
            )
            acc_h = acc_h + child_min_h
        elseif type(child_w) ~= "number" and type(child_h) == "number" then
            local child_min_w, _ = child._calculate_minimum_dimensions(child, constraint_w, constraint_h)
            max_w = math.max(max_w, child_min_w)
            acc_h = acc_h
                + child_h
                + (child_border_width * 2)
                + child_standardized_padding.top
                + child_standardized_padding.bottom
        else -- both are not numbers
            local child_min_w, child_min_h = child._calculate_minimum_dimensions(child, constraint_w, constraint_h)
            max_w = math.max(max_w, child_min_w)
            acc_h = acc_h + child_min_h
        end
    end

    return min_w + max_w, acc_h
end

local function calculate_minimum_dimensions_el(branch, constraint_w, constraint_h)

    local el_bw = get_border_width(branch)
    local standardized_padding = eutil.standardize_padding(branch.padding or 0)

    local min_w = standardized_padding.left + standardized_padding.right + (el_bw * 2)
    local min_h = standardized_padding.top + standardized_padding.bottom + (el_bw * 2)

    local max_w = 0
    local max_h = 0

    -- NOTE: only go through the children in the array portion of the table because
    -- we don't want the shadow or the bg to take up horizontal space
    for _, child in ipairs(branch) do

        local child_bw = get_border_width(child)
        local child_standardized_padding = eutil.standardize_padding(child.padding or 0)
        local child_w, child_h = child.width, child.height

        if type(child_w) == "number" and type(child_h) == "number" then
            max_w = math.max(
                max_w,
                child_w
                    + (child_bw * 2)
                    + child_standardized_padding.left
                    + child_standardized_padding.right
            )
            max_h = math.max(
                max_h,
                child_h
                    + (child_bw * 2)
                    + child_standardized_padding.top
                    + child_standardized_padding.bottom
            )
        elseif type(child_w) == "number" and type(child_h) ~= "number" then
            local _, min_child_h = child._calculate_minimum_dimensions(child, constraint_w, constraint_h)
            max_w = math.max(
                max_w,
                child_w
                    + (child_bw * 2)
                    + child_standardized_padding.left
                    + child_standardized_padding.right
            )
            max_h = math.max(max_h, min_child_h)
        elseif type(child_w) ~= "number" and type(child_h) == "number" then
            local min_child_w, _ = child._calculate_minimum_dimensions(child, constraint_w, constraint_h)
            max_w = math.max(max_w, min_child_w)
            max_h = math.max(
                max_h,
                child_h
                    + (child_bw * 2)
                    + child_standardized_padding.top
                    + child_standardized_padding.bottom
            )
        else -- both are not numbers
            local min_child_w, min_child_h = child._calculate_minimum_dimensions(child, constraint_w, constraint_h)
            max_w = math.max(max_w, min_child_w)
            max_h = math.max(max_h, min_child_h)
        end
    end

    return min_w + max_w, min_h + max_h
end

local function dimensionate_and_position_shadow(shadow, avail_w, avail_h)

    local edge_width = shadow.edge_width or 0
    local shadow_w = avail_w + (edge_width * 2)
    local shadow_h = avail_h + (edge_width * 2)

    -- TODO: make sure the shadow x and y is always on integer coordinates
    local shadow_edge_width = shadow.edge_width or 0
    -- always place shadow in the center of the parent geometry, regardless of 
    -- what halign/valign the shadow has
    local shadow_x = - shadow_edge_width
    local shadow_y = - shadow_edge_width

    if shadow.offset_x ~= nil then shadow_x = shadow_x + shadow.offset_x end
    if shadow.offset_y ~= nil then shadow_y = shadow_y + shadow.offset_y end

    return {
        x = shadow_x,
        y = shadow_y,
        width = shadow_w,
        height = shadow_h,
        element = shadow,
    }
end


local function dimensionate_children_horizontal(branch, avail_w, avail_h)

    local spacing = branch.spacing or 0

    -- account for padding and spacing
    -- NOTE: use #branch instead of #all_children because we don't want chlidren
    -- like the bg and shadow to be part of horizontal layout
    local total_spacing = _get_spacing_between_elements(#branch, spacing)

    local standardized_padding = eutil.standardize_padding(branch.padding or 0)
    local padding_top = standardized_padding.top
    local padding_right = standardized_padding.right
    local padding_bottom = standardized_padding.bottom
    local padding_left = standardized_padding.left
    local parent_bw = get_border_width(branch)

    local dimensionated_children_data = {
        available_width = avail_w,
        available_height = avail_h,
        spacing = spacing,
        standardized_padding = standardized_padding,
        parent_border_width = parent_bw,
    }

    do
        local shadow = branch.shadow
        local bg = branch.bg

        if shadow ~= nil then dimensionated_children_data.shadow = shadow end
        if bg ~= nil then dimensionated_children_data.bg = bg end
    end

    -- NOTE: use ipairs(branch) so we dont layout horizontally bg and shadow
    for k, child in ipairs(branch) do
        dimensionated_children_data[k] = {
            valign = child.valign or etypes.ALIGN_TOP,
            offset_x = child.offset_x or 0,
            offset_y = child.offset_y or 0,
            element = child,
        }
    end

    local number_width_children = {}
    local shrink_width_children = {}
    local fill_width_children_number = 0 -- for dividing width evenly later
    local fill_width_children = {}
    -- for width-fill children, the first priority is their borders.
    -- so we'll have to do subtract the total border width from the remaining
    -- width to find out how much we have left for width-fill elements
    local fill_width_children_total_border_width = 0

    local last_halign_left_child_i = nil
    local halign_left_children = {}
    local halign_center_child_data = nil
    local halign_right_children = {}

    -- divide up the children. we need this because we need to first get
    -- the dimensions of the number-width children and shrink-width children,
    -- to know the remaining width (if any) to distribute to the width="fill"
    -- widgets. we also get the raw height information of children to use later
    -- note: in order to optimise this later, we store the elements in contiguous
    -- arrays, but we also keep track of the initial index of the element, so we
    -- can put them back together at the index they came from
    for k, child in ipairs(branch) do
        -- NOTE: use ipairs(branch) so we dont layout horizontally bg and shadow

        local raw_child_w = child.width
        if type(raw_child_w) == "number" then
            table.insert(number_width_children, {k, child})
        elseif etypes.is_size_fill(raw_child_w) then
            table.insert(fill_width_children, {k, child})
            fill_width_children_number = fill_width_children_number + 1
            fill_width_children_total_border_width =
                fill_width_children_total_border_width + (get_border_width(child) * 2)
        else -- raw_child_w == size.shrink then
            table.insert(shrink_width_children, {k, child})
        end

        if child.halign == etypes.ALIGN_RIGHT then
            table.insert(halign_right_children, {k, child})
        elseif child.halign == etypes.ALIGN_CENTER then
            if halign_center_child_data == nil then
                halign_center_child_data = {k, child}
            else
                -- if we already have a halign="center" element, we treat all other elements as though
                -- they have halign = "right" because what the hell are you doing putting multiple elements
                -- with halign="center" into your layout on the same level. fix your layout
                table.insert(halign_right_children, {k, child})
            end
        -- if it has no "halign", we treat it as halign = "left"
        else -- child.halign == align.left then
            table.insert(halign_left_children, {k, child})
            last_halign_left_child_i = k
        end
    end

    -- now that we have the children divided up in their appropriate
    -- categories, we can start calculating their dimensions

    -- we ll need this to calculate the fill width children
    local occupied_width =
        total_spacing
        + padding_left
        + padding_right
        + (parent_bw * 2)
        + fill_width_children_total_border_width

    -- process width for children that already have it explicitly specified
    for _, child_data in ipairs(number_width_children) do
        local original_child_i = child_data[1]
        local child = child_data[2]
        local child_bw = get_border_width(child)
        local child_width = child.width
        dimensionated_children_data[original_child_i].width = child_width + (child_bw * 2)
        occupied_width = occupied_width + child_width + (child_bw * 2)
    end

    -- now figure width for children that have width = "shrink"
    for _, child_data in ipairs(shrink_width_children) do
        local original_child_i = child_data[1]
        local child = child_data[2]
        local child_bw = get_border_width(child)
        -- border width is already calculated inside _calculate_minimum_dimensions
        local constraint_height = nil
        if type(child.height) == "number" then
            constraint_height = child.height
        elseif etypes.is_size_fill(child.height) then
            constraint_height = math.max(avail_h - (padding_top + padding_bottom), child_bw * 2)
        end
        local min_w, _ = child._calculate_minimum_dimensions(child, nil, constraint_height)
        dimensionated_children_data[original_child_i].width = min_w
        occupied_width = occupied_width + min_w
    end

    -- finally, go through the children with width="fill".
    -- we do this last because only now we know the remaining width (if any) and
    -- can divide it equally between children
    local remaining_width = avail_w - occupied_width
    if remaining_width > 0 then
        local safe_divide_by = math.max(fill_width_children_number, 1) -- dont divide by 0
        local equally_divided_remaining_width = remaining_width / safe_divide_by
        for _, child_data in ipairs(fill_width_children) do
            local original_child_ind = child_data[1]
            local child_bw = get_border_width(child_data[2])
            dimensionated_children_data[original_child_ind].width =
                equally_divided_remaining_width
                    + (child_bw * 2)
        end
    else
        for _, child_data in ipairs(fill_width_children) do
            local original_child_ind = child_data[1]
            local child_bw = get_border_width(child_data[2])
            -- yes, the element doesn't have enough width to render its content,
            -- but we do render its border
            dimensionated_children_data[original_child_ind].width =
                (child_bw * 2)
        end
    end

    -- calculate the height of children after the width because only now do
    -- we know what the constraint_width is in case the child has width-shrink
    -- or width-fill
    -- NOTE: use ipairs(branch) so we dont layout bg and shadow
    for k, child in ipairs(branch) do
        local real_child_h = 0
        local child_bw = get_border_width(child)
        if type(child.height) == "number" then
            real_child_h = child.height + (child_bw * 2)
        elseif etypes.is_size_shrink(child.height) then
            -- minimum dimension result already includes the border_width
            local constraint_width = nil
            if type(child.width) == "number" then
                constraint_width = child.width
            elseif etypes.is_size_fill(child.width) then
                constraint_width = dimensionated_children_data[k].width
            end
            local _, min_h = child._calculate_minimum_dimensions(child, constraint_width, nil)
            real_child_h = min_h
        else -- child.height == "fill"
            real_child_h = math.max(avail_h - (padding_top + padding_bottom), child_bw * 2)
        end
        dimensionated_children_data[k].height = real_child_h
    end


    if #fill_width_children > 0 then
        -- we have a width-fill element which means an easy layout.
        -- we know we can't center-align or right-align any elements, so
        -- we just align all elements as though they all had halign = "left"
        dimensionated_children_data.position_type = POSITION_START
        return dimensionated_children_data
    end

    if remaining_width <= 0 then
        dimensionated_children_data.position_type = POSITION_START
        return dimensionated_children_data
    end

    local first_halign_right_child_i
    local first_halign_right_child_data = halign_right_children[1]
    do
        if first_halign_right_child_data ~= nil then
            first_halign_right_child_i = first_halign_right_child_data[1]
        end
    end

    if first_halign_right_child_i == 1 then
        -- if the first halign-right element has index 1, that means all 
        -- elements get pushed to the right
        dimensionated_children_data.position_type = POSITION_START_END
        dimensionated_children_data.first_halign_right_child_id = first_halign_right_child_i
        return dimensionated_children_data
    end

    if halign_center_child_data == nil then -- no center element
        if first_halign_right_child_data == nil then
            dimensionated_children_data.position_type = POSITION_START
            return dimensionated_children_data
        end

        dimensionated_children_data.position_type = POSITION_START_END
        dimensionated_children_data.first_halign_right_child_id = first_halign_right_child_i
        return dimensionated_children_data
    end


    -- if we're here, we have :
    -- 1. some remaining width
    -- 2. no fill width children
    -- 3. a halign-center element
    -- now we have to see if we can center-align or right-align elements that
    -- want it
    local halign_center_child_i = halign_center_child_data[1]
    if last_halign_left_child_i ~= nil and first_halign_right_child_i ~= nil then

        if last_halign_left_child_i < halign_center_child_i and
            halign_center_child_i < first_halign_right_child_i
        then
            -- if we're on this if branch there's nothing blocking the
            -- path of the center element from being put in the middle,
            -- but now we need to see if any elements are bleeding over it

            local halign_left_children_width = 0
            for i = 1, last_halign_left_child_i do
                halign_left_children_width = halign_left_children_width
                    + dimensionated_children_data[i].width
            end

            local halign_right_children_width = 0
            for i = first_halign_right_child_i, #dimensionated_children_data do
                halign_right_children_width = halign_right_children_width
                    + dimensionated_children_data[i].width
            end

            local spacing_left_side = spacing * (halign_center_child_i - 1)
            local spacing_right_side = spacing * (#dimensionated_children_data - (first_halign_right_child_i - 1))

            local center_child_width = dimensionated_children_data[halign_center_child_i].width
            local ideal_center_x = (avail_w - center_child_width) / 2

            if padding_left
                + parent_bw
                + spacing_left_side
                + halign_left_children_width
                < ideal_center_x
            then
                if padding_right
                    + parent_bw
                    + spacing_right_side
                    + halign_right_children_width
                    < avail_w - (ideal_center_x + center_child_width)
                then
                    -- elements on the left and elements on the right don't push over the center element
                    dimensionated_children_data.position_type = POSITION_START_CENTER_END
                    dimensionated_children_data.halign_center_child_id = halign_center_child_i
                    dimensionated_children_data.center_element_x = ideal_center_x
                else
                    -- elements on the right push over the center element
                    dimensionated_children_data.position_type = POSITION_START_END
                    dimensionated_children_data.first_halign_right_child_id = halign_center_child_i
                end
            else
                -- elements on the left push over the center element
                dimensionated_children_data.position_type = POSITION_START_END
                dimensionated_children_data.first_halign_right_child_id = first_halign_right_child_i
            end
        else
            -- in all other cases we just halign-right all elements past the first
            -- halign-right element because halign-right elements have highest priority
            dimensionated_children_data.position_type = POSITION_START_END
            dimensionated_children_data.first_halign_right_child_id = first_halign_right_child_i
        end

    elseif last_halign_left_child_i ~= nil
        and first_halign_right_child_data == nil
    then -- we have left-align elements, and a center element

        if last_halign_left_child_i < halign_center_child_i then
            -- now we need to see if the left-align elements bleed
            -- over the center element

            local halign_left_children_width = 0
            for i = 1, halign_center_child_i - 1 do
                halign_left_children_width = halign_left_children_width
                    + dimensionated_children_data[i].width
            end

            local spacing_left_side = spacing * (halign_center_child_i - 1)

            local center_child_width = dimensionated_children_data[halign_center_child_i].width
            local ideal_center_x = (avail_w - center_child_width) / 2

            if padding_left
                + parent_bw
                + spacing_left_side
                + halign_left_children_width
                < ideal_center_x
            then
                if padding_right
                    + parent_bw
                    < avail_w - (ideal_center_x + center_child_width)
                then
                    -- nothing pushes or bleeds over the center element
                    dimensionated_children_data.position_type = POSITION_START_CENTER_END
                    dimensionated_children_data.halign_center_child_id = halign_center_child_i
                    dimensionated_children_data.center_element_x = ideal_center_x
                else
                    -- padding on the right pushes over the center element
                    dimensionated_children_data.position_type = POSITION_START_END
                    dimensionated_children_data.first_halign_right_child_id = halign_center_child_i
                end
            else
                -- elements on the left push over the center element
                dimensionated_children_data.position_type = POSITION_START_END
                dimensionated_children_data.first_halign_right_child_id = first_halign_right_child_i
            end
        else -- the center-align element is pushed by a left-align element
            -- everything goes to the left
            dimensionated_children_data.position_type = POSITION_START
        end

    elseif last_halign_left_child_i == nil and
        first_halign_right_child_data ~= nil
    then -- we have right-align elements and a center element

        if halign_center_child_i < first_halign_right_child_i then
            -- now we need to see if the right-align elements bleed
            -- over the center element

            local halign_right_children_width = 0
            for i = first_halign_right_child_i, #dimensionated_children_data do
                halign_right_children_width = halign_right_children_width
                    + dimensionated_children_data[i].width
            end

            local spacing_right_side = spacing * (#dimensionated_children_data - (first_halign_right_child_i - 1))

            local center_child_width = dimensionated_children_data[halign_center_child_i].width
            local ideal_center_x = (avail_w - center_child_width) / 2

            if padding_left
                + parent_bw
                < ideal_center_x
            then
                if padding_right
                    + parent_bw
                    + spacing_right_side
                    + halign_right_children_width
                    < avail_w - (ideal_center_x + center_child_width)
                then
                    -- nothing pushes or bleeds over the center element
                    dimensionated_children_data.position_type = POSITION_START_CENTER_END
                    dimensionated_children_data.halign_center_child_id = halign_center_child_i
                    dimensionated_children_data.center_element_x = ideal_center_x
                else
                    -- elements on the right bleed over the center element
                    dimensionated_children_data.position_type = POSITION_START_END
                    dimensionated_children_data.first_halign_right_child_id = halign_center_child_i
                end
            else
                -- padding on the left bleeds over the center element
                dimensionated_children_data.position_type = POSITION_START_END
                dimensionated_children_data.first_halign_right_child_id = first_halign_right_child_i
            end
        else -- the center element is pushed by a right-align element
            -- so everything goes to the right
            dimensionated_children_data.position_type = POSITION_START_END
            dimensionated_children_data.first_halign_right_child_id = first_halign_right_child_i
        end

    else -- there's only the center element

        local center_child_width = dimensionated_children_data[halign_center_child_i].width
        local ideal_center_x = (avail_w - center_child_width) / 2

        dimensionated_children_data.position_type = POSITION_START_CENTER_END
        dimensionated_children_data.halign_center_child_id = halign_center_child_i
        dimensionated_children_data.center_element_x = ideal_center_x
    end

    return dimensionated_children_data
end

local function position_children_horizontal(dimensionated_children_data)

    local available_width = dimensionated_children_data.available_width
    local available_height = dimensionated_children_data.available_height
    local spacing = dimensionated_children_data.spacing
    local parent_bw = dimensionated_children_data.parent_border_width
    local padding_top, padding_right, padding_bottom, padding_left
    do
        local standardized_padding = dimensionated_children_data.standardized_padding
        padding_top = standardized_padding.top
        padding_right = standardized_padding.right
        padding_bottom = standardized_padding.bottom
        padding_left = standardized_padding.left
    end

    local positioned_children_data = {}

    do
        -- normally, elements should not be dimensionated here. only positioned.
        -- but it's such a trivial task that we just dimensionate and position 
        -- the shadow and bg here

        local shadow = dimensionated_children_data.shadow
        if shadow ~= nil then
            table.insert(positioned_children_data, dimensionate_and_position_shadow(
                shadow,
                available_width,
                available_height
            ))
        end

        local bg = dimensionated_children_data.bg
        if bg ~= nil then
            table.insert(positioned_children_data, {
                x = bg.offset_x or 0,
                y = bg.offset_y or 0,
                width = available_width,
                height = available_height,
                element = bg,
            })
        end
    end

    local position_type = dimensionated_children_data.position_type

    if position_type == POSITION_START_CENTER_END then

        local halign_center_child_id = dimensionated_children_data.halign_center_child_id
        local center_child_x = dimensionated_children_data.center_element_x

        -- left-halign elements
        local left_side_acc_x = padding_left + parent_bw
        for i=1, halign_center_child_id - 1 do

            local child = dimensionated_children_data[i]
            local child_y = align_on_secondary_axis(
                padding_top + parent_bw,
                padding_bottom + parent_bw,
                child.valign,
                available_height,
                child.height
            )
            table.insert(positioned_children_data, {
                x = child.offset_x + left_side_acc_x,
                y = child.offset_y + child_y,
                width = child.width,
                height = child.height,
                element = child.element,
            })

            left_side_acc_x = left_side_acc_x + child.width + spacing
        end

        -- center element
        local center_child = dimensionated_children_data[halign_center_child_id]
        local center_child_y = align_on_secondary_axis(
            padding_top + parent_bw,
            padding_bottom + parent_bw,
            center_child.valign,
            available_height,
            center_child.height
        )
        table.insert(positioned_children_data, {
            x = center_child.offset_x + center_child_x,
            y = center_child.offset_y + center_child_y,
            width = center_child.width,
            height = center_child.height,
            element = center_child.element
        })

        --right elements (if there are any)
        if halign_center_child_id ~= #dimensionated_children_data then
            local right_side_acc_x = available_width - (padding_right + parent_bw)
            for i=#dimensionated_children_data, (halign_center_child_id + 1), -1 do
                local child = dimensionated_children_data[i]
                local child_y = align_on_secondary_axis(
                    padding_top + parent_bw,
                    padding_bottom + parent_bw,
                    child.valign,
                    available_height,
                    child.height
                )

                right_side_acc_x = right_side_acc_x - child.width

                table.insert(positioned_children_data, {
                    x = child.offset_x + right_side_acc_x,
                    y = child.offset_y + child_y,
                    width = child.width,
                    height = child.height,
                    element = child.element,
                })

                right_side_acc_x = right_side_acc_x - spacing
            end
        end

    elseif position_type == POSITION_START_END then
        local first_halign_right_child_id = dimensionated_children_data.first_halign_right_child_id

        -- left-halign elements
        local left_side_acc_x = padding_left + parent_bw
        for i=1, first_halign_right_child_id - 1 do
            local child = dimensionated_children_data[i]
            local child_y = align_on_secondary_axis(
                padding_top + parent_bw,
                padding_bottom + parent_bw,
                child.valign,
                available_height,
                child.height
            )

            table.insert(positioned_children_data, {
                x = child.offset_x + left_side_acc_x,
                y = child.offset_y + child_y,
                width = child.width,
                height = child.height,
                element = child.element,
            })

            left_side_acc_x = left_side_acc_x + child.width + spacing
        end

        -- right-halign elements
        local right_side_acc_x = available_width - (padding_right + parent_bw)
        for i=#dimensionated_children_data, first_halign_right_child_id, -1 do
            local child = dimensionated_children_data[i]
            local child_y = align_on_secondary_axis(
                padding_top + parent_bw,
                padding_bottom + parent_bw,
                child.valign,
                available_height,
                child.height
            )

            right_side_acc_x = right_side_acc_x - child.width

            table.insert(positioned_children_data, {
                x = child.offset_x + right_side_acc_x,
                y = child.offset_y + child_y,
                width = child.width,
                height = child.height,
                element = child.element,
            })

            right_side_acc_x = right_side_acc_x - spacing
        end
    else -- position_type == POSITION_START
        local left_side_acc_x = padding_left + parent_bw

        for i=1, #dimensionated_children_data do
            local child = dimensionated_children_data[i]
            local child_y = align_on_secondary_axis(
                padding_top + parent_bw,
                padding_bottom + parent_bw,
                child.valign,
                available_height,
                child.height
            )

            table.insert(positioned_children_data, {
                x = child.offset_x + left_side_acc_x,
                y = child.offset_y + child_y,
                width = child.width,
                height = child.height,
                element = child.element,
            })

            left_side_acc_x = left_side_acc_x + child.width + spacing
        end

    end

    return positioned_children_data


end

local function dimensionate_children_vertical(branch, avail_w, avail_h)

    local spacing = branch.spacing or 0

    -- account for padding and spacing
    local total_spacing = _get_spacing_between_elements(#branch, spacing)
    local standardized_padding = eutil.standardize_padding(branch.padding or 0)
    local padding_top = standardized_padding.top
    local padding_right = standardized_padding.right
    local padding_bottom = standardized_padding.bottom
    local padding_left = standardized_padding.left
    local parent_bw = get_border_width(branch)

    local dimensionated_children_data = {
        available_width = avail_w,
        available_height = avail_h,
        spacing = spacing,
        standardized_padding = standardized_padding,
        parent_border_width = parent_bw,
    }

    do
        local shadow = branch.shadow
        local bg = branch.bg
        if shadow ~= nil then dimensionated_children_data.shadow = shadow end
        if bg ~= nil then dimensionated_children_data.bg = bg end
    end

    -- NOTE: use ipairs(branch) so we dont layout vertically bg and shadow
    for k, child in ipairs(branch) do
        dimensionated_children_data[k] = {
            halign = child.halign or etypes.ALIGN_LEFT,
            offset_x = child.offset_x or 0,
            offset_y = child.offset_y or 0,
            element = child,
        }
    end

    local number_height_children = {}
    local shrink_height_children = {}
    local fill_height_children_number = 0 -- for dividing height evenly later
    local fill_height_children = {}
    -- for height-fill children, the first priority is their borders.
    -- so we'll have to do subtract the total border width from the remaining
    -- height to find out how much we have left for height-fill elements
    local fill_height_children_total_border_width = 0

    local last_valign_top_child_i = nil
    local valign_top_children = {}
    local valign_center_child_data = nil
    local valign_bottom_children = {}

    -- divide up the children. we need this because we need to first get
    -- the dimensions of the number-height children and shrink-height children,
    -- to know the remaining height (if any) to distribute to the height="fill"
    -- widgets we also get the raw height information of children to use later
    -- note: in order to optimise this later, we store the elements in contiguous
    -- arrays, but we also keep track of the initial index of the element
    -- NOTE: use ipairs(branch) so we dont layout horizontally bg and shadow
    for k, child in ipairs(branch) do
        local raw_child_h = child.height
        if type(raw_child_h) == "number" then
            table.insert(number_height_children, {k, child})
        elseif etypes.is_size_fill(raw_child_h) then
            table.insert(fill_height_children, {k, child})
            fill_height_children_number = fill_height_children_number + 1
            fill_height_children_total_border_width =
                fill_height_children_total_border_width + (get_border_width(child) * 2)
        else -- raw_child_h == size.shrink then
            table.insert(shrink_height_children, {k, child})
        end

        if child.valign == etypes.ALIGN_BOTTOM then
            table.insert(valign_bottom_children, {k, child})
        elseif child.valign == etypes.ALIGN_CENTER then
            if valign_center_child_data == nil then
                valign_center_child_data = {k, child}
            else
                -- if we already have a valign="center" element, we treat all other elements as though
                -- they have valign = "bottom" because what the hell are you doing putting multiple elements
                -- with valign="center" into your layout on the same level. fix your layout
                table.insert(valign_bottom_children, {k, child})
            end
        -- if it has no "valign", we treat it as valign = "top"
        else -- child.valign == align.top then
            table.insert(valign_top_children, {k, child})
            last_valign_top_child_i = k
        end
    end

    -- now that we have the children divided up in their appropriate
    -- categories, we can start calculating their dimensions

    -- we ll need this to calculate the fill height children
    local occupied_height =
        total_spacing
        + padding_top
        + padding_bottom
        + (parent_bw * 2)
        + fill_height_children_total_border_width

    -- process height for children that already have it explicitly specified
    -- NOTE: use ipairs(branch) so we dont layout horizontally bg and shadow
    for _, child_data in ipairs(number_height_children) do
        local original_child_i = child_data[1]
        local child = child_data[2]
        local child_height = child.height
        local child_bw = get_border_width(child)
        dimensionated_children_data[original_child_i].height = child_height + (child_bw * 2)
        occupied_height = occupied_height + child_height + (child_bw * 2)
    end

    -- now figure height for children that have height = "shrink"
    for _, child_data in ipairs(shrink_height_children) do
        local original_child_i = child_data[1]
        local child = child_data[2]
        local child_bw = get_border_width(child)
        -- border width is already calculated inside _calculate_minimum_dimensions
        local constraint_width = nil
        if type(child.width) == "number" then
            constraint_width = child.width
        elseif etypes.is_size_fill(child.width) then
            constraint_width = math.max(avail_w - (padding_left + padding_right), child_bw * 2)
        end
        local _, min_h = child._calculate_minimum_dimensions(child, constraint_width, nil)
        dimensionated_children_data[original_child_i].height = min_h
        occupied_height = occupied_height + min_h
    end

    -- finally, go through the children with height="fill".
    -- we do this last because only now we know the remaining height and
    -- can divide it equally between children
    local remaining_height = avail_h - occupied_height
    if remaining_height > 0 then
        local safe_divide_by = math.max(fill_height_children_number, 1)
        -- this equally divided remaining height actually has the borders of each
        -- child accounted for. This means that this value refers to the available
        -- height of the CONTENT of these height-fill elements
        local equally_divided_remaining_height = remaining_height / safe_divide_by -- dont divide by 0
        for _, child_data in ipairs(fill_height_children) do
            local original_child_ind = child_data[1]
            local child_bw = get_border_width(child_data[2])
            dimensionated_children_data[original_child_ind].height =
                equally_divided_remaining_height
                    + (child_bw * 2)
        end
    else
        for _, child_data in ipairs(fill_height_children) do
            local original_child_ind = child_data[1]
            local child_bw = get_border_width(child_data[2])
            -- yes, the element doesn't have enough height to render its content,
            -- but we do render its borders
            dimensionated_children_data[original_child_ind].height = (child_bw * 2)
        end
    end

    -- calculate the width of elements because this is the same procedure for 
    -- all children. also, we need to do this afterwards because only now we 
    -- know the constraint_height to give to children that have width-shrink

    -- NOTE: use ipairs(branch) so we dont layout bg and shadow
    for k, child in ipairs(branch) do
        local real_child_w = 0
        local child_bw = get_border_width(child)
        if type(child.width) == "number" then
            real_child_w = child.width + (child_bw * 2)
        elseif etypes.is_size_shrink(child.width) then
            -- minimum dimension result already includes the border_width
            local constraint_height = nil
            if type(child.height) == "number" then
                constraint_height = child.height
            elseif etypes.is_size_fill(child.height) then
                constraint_height = dimensionated_children_data[k].height
            end
            local min_w, _ = child._calculate_minimum_dimensions(child, nil, constraint_height)
            real_child_w = min_w
        else -- child.width == "fill"
            real_child_w = math.max(avail_w - (padding_left + padding_right), child_bw * 2)
        end
        dimensionated_children_data[k].width = real_child_w
    end


    if #fill_height_children > 0 then
        -- we have a height-fill element which means an easy layout.
        -- we know we can't center-align or bottom-align any elements, so
        -- we just align all elements as though they all had valign = "top"
        dimensionated_children_data.position_type = POSITION_START
        return dimensionated_children_data
    end

    if remaining_height <= 0 then
        dimensionated_children_data.position_type = POSITION_START
        return dimensionated_children_data
    end

    local first_valign_bottom_child_i
    local first_valign_bottom_child_data = valign_bottom_children[1]
    do
        if first_valign_bottom_child_data ~= nil then
            first_valign_bottom_child_i = first_valign_bottom_child_data[1]
        end
    end

    if first_valign_bottom_child_i == 1 then
        -- valign bottom has highest priority, so everything goes to the bottom
        dimensionated_children_data.position_type = POSITION_START_END
        dimensionated_children_data.first_valign_bottom_child_id = first_valign_bottom_child_i
    end

    if valign_center_child_data == nil then -- no center element
        if first_valign_bottom_child_data == nil then
            dimensionated_children_data.position_type = POSITION_START
            return dimensionated_children_data
        end

        dimensionated_children_data.position_type = POSITION_START_END
        dimensionated_children_data.first_valign_bottom_child_id = first_valign_bottom_child_i
        return dimensionated_children_data
    end


    -- if we're here, we have :
    -- 1. some remaining width
    -- 2. no fill height children
    -- 3. a valign-center element
    -- now we have to see if we can center-align or bottom-align elements that
    -- want it
    local valign_center_child_i = valign_center_child_data[1]
    if last_valign_top_child_i ~= nil and first_valign_bottom_child_i ~= nil then

        if last_valign_top_child_i < valign_center_child_i and
            valign_center_child_i < first_valign_bottom_child_i
        then
            -- if we're on this "if" branch there's nothing blocking the
            -- path of the center element from being put in the middle,
            -- but now we need to see if any elements are bleeding over it

            local valign_top_children_height = 0
            for i = 1, last_valign_top_child_i do
                valign_top_children_height = valign_top_children_height
                    + dimensionated_children_data[i].height
            end

            local valign_bottom_children_height = 0
            for i = first_valign_bottom_child_i, #dimensionated_children_data do
                valign_bottom_children_height = valign_bottom_children_height
                    + dimensionated_children_data[i].height
            end

            local spacing_top_side = spacing * (valign_center_child_i - 1)
            local spacing_bottom_side = spacing * (#dimensionated_children_data - first_valign_bottom_child_i)

            local center_child = dimensionated_children_data[valign_center_child_i]
            local ideal_center_y = (avail_h - center_child.height) / 2

            if padding_top
                + parent_bw
                + spacing_top_side
                + valign_top_children_height
                < ideal_center_y
            then
                if padding_bottom
                    + parent_bw
                    + spacing_bottom_side
                    + valign_bottom_children_height
                    < avail_h - (ideal_center_y + center_child.height)
                then
                    -- nothing pushes or bleeds over the center element
                    dimensionated_children_data.position_type = POSITION_START_CENTER_END
                    dimensionated_children_data.valign_center_child_id = valign_center_child_i
                    dimensionated_children_data.center_element_y = ideal_center_y
                else
                    -- elements on the bottom push over the center element
                    dimensionated_children_data.position_type = POSITION_START_END
                    dimensionated_children_data.first_valign_bottom_child_id = valign_center_child_i
                end
            else
                -- elements on the top push over the center element
                dimensionated_children_data.position_type = POSITION_START_END
                dimensionated_children_data.first_valign_bottom_child_id = first_valign_bottom_child_i
            end
        else
            -- in all other cases we just valign-bottom all elements past the first
            -- valign-bottom element because valign-bottom elements have highest priority
            dimensionated_children_data.position_type = POSITION_START_END
            dimensionated_children_data.first_valign_bottom_child_id = first_valign_bottom_child_i
        end

    elseif last_valign_top_child_i ~= nil and
        first_valign_bottom_child_i == nil
    then -- we only have top-align elements and a center element

        if last_valign_top_child_i < valign_center_child_i then
            -- now we need to see if the top-align elements bleed 
            -- over the center element

            local valign_top_children_height = 0
            for i = 1, last_valign_top_child_i do
                valign_top_children_height = valign_top_children_height
                    + dimensionated_children_data[i].height
            end

            local spacing_top_side = spacing * (valign_center_child_i - 1)

            local center_child = dimensionated_children_data[valign_center_child_i]
            local ideal_center_y = (avail_h - center_child.height) / 2

            if padding_top
                + parent_bw
                + spacing_top_side
                + valign_top_children_height
                < ideal_center_y
            then
                if padding_bottom
                    + parent_bw
                    < avail_h - (ideal_center_y + center_child.height)
                then -- nothing pushes or bleeds over the center element
                    dimensionated_children_data.position_type = POSITION_START_CENTER_END
                    dimensionated_children_data.valign_center_child_id = valign_center_child_i
                    dimensionated_children_data.center_element_y = ideal_center_y
                else -- padding on the bottom bleeds over the center element
                    dimensionated_children_data.position_type = POSITION_START_END
                    dimensionated_children_data.first_valign_bottom_child_id = valign_center_child_i
                end
            else -- elements on the top bleed over the center element
                dimensionated_children_data.position_type = POSITION_START_END
                dimensionated_children_data.first_valign_bottom_child_id = first_valign_bottom_child_i
            end
        else -- the center-align element is pushed by a top-align element
            -- everything goes to the left
            dimensionated_children_data.position_type = POSITION_START
        end

    elseif last_valign_top_child_i == nil and
        first_valign_bottom_child_i ~= nil
    then -- we have bottom-align elements and a center element

        if valign_center_child_i < first_valign_bottom_child_i then
            -- now we need to see if the bottom-align elements bleed
            -- over the center element

            local valign_bottom_children_height = 0
            for i = first_valign_bottom_child_i, #dimensionated_children_data do
                valign_bottom_children_height = valign_bottom_children_height
                    + dimensionated_children_data[i].height
            end

            local spacing_bottom_side = spacing * (#dimensionated_children_data - first_valign_bottom_child_i)

            local center_child = dimensionated_children_data[valign_center_child_i]
            local ideal_center_y = (avail_h - center_child.height) / 2

            if padding_top
                + parent_bw
                < ideal_center_y
            then
                if padding_bottom
                    + parent_bw
                    + spacing_bottom_side
                    + valign_bottom_children_height
                    < avail_h - (ideal_center_y + center_child.height)
                then
                    -- nothing pushes or bleeds over the center element
                    dimensionated_children_data.position_type = POSITION_START_CENTER_END
                    dimensionated_children_data.valign_center_child_id = valign_center_child_i
                    dimensionated_children_data.center_element_y = ideal_center_y
                else
                    -- elements on the bottom bleeds over the center element
                    dimensionated_children_data.position_type = POSITION_START_END
                    dimensionated_children_data.first_valign_bottom_child_id = valign_center_child_i
                end
            else
                -- padding on the top bleeds over the center element
                dimensionated_children_data.position_type = POSITION_START_END
                dimensionated_children_data.first_valign_bottom_child_id = first_valign_bottom_child_i
            end
        else -- the center element is pushed by a bottom-align element
            -- so everything goes to the bottom
            dimensionated_children_data.position_type = POSITION_START_END
            dimensionated_children_data.first_valign_bottom_child_id = first_valign_bottom_child_i
        end

    else -- there's only the center element

        local center_child = dimensionated_children_data[valign_center_child_i]
        local ideal_center_y = (avail_h - center_child.height) / 2

        dimensionated_children_data.position_type = POSITION_START_CENTER_END
        dimensionated_children_data.valign_center_child_id = valign_center_child_i
        dimensionated_children_data.center_element_y = ideal_center_y
    end

    return dimensionated_children_data
end

local function position_children_vertical(dimensionated_children_data)

    local available_width = dimensionated_children_data.available_width
    local available_height = dimensionated_children_data.available_height
    local spacing = dimensionated_children_data.spacing
    local parent_bw = dimensionated_children_data.parent_border_width
    local padding_top, padding_right, padding_bottom, padding_left
    do
        local standardized_padding = dimensionated_children_data.standardized_padding
        padding_top = standardized_padding.top
        padding_right = standardized_padding.right
        padding_bottom = standardized_padding.bottom
        padding_left = standardized_padding.left
    end

    local positioned_children_data = {}

    do
        -- normally, elements should not be dimensionated here. only positioned.
        -- but it's such a trivial task that we just dimensionate and position 
        -- the shadow and bg here

        local shadow = dimensionated_children_data.shadow
        if shadow ~= nil then
            table.insert(positioned_children_data, dimensionate_and_position_shadow(
                shadow,
                available_width,
                available_height
            ))
        end

        local bg = dimensionated_children_data.bg
        if bg ~= nil then
            table.insert(positioned_children_data, {
                x = bg.offset_x or 0,
                y = bg.offset_y or 0,
                width = available_width,
                height = available_height,
                element = bg
            })
        end
    end

    local position_type = dimensionated_children_data.position_type

    if position_type == POSITION_START_CENTER_END then

        local valign_center_child_id = dimensionated_children_data.valign_center_child_id
        local center_child_y = dimensionated_children_data.center_element_y

        -- top-valign elements
        local top_side_acc_y = padding_top + parent_bw
        for i=1, valign_center_child_id - 1 do
            local child = dimensionated_children_data[i]
            local child_x = align_on_secondary_axis(
                padding_left + parent_bw,
                padding_right + parent_bw,
                child.halign,
                available_width,
                child.width
            )

            table.insert(positioned_children_data, {
                x = child.offset_x + child_x,
                y = child.offset_y + top_side_acc_y,
                width = child.width,
                height = child.height,
                element = child.element,
            })

            top_side_acc_y = top_side_acc_y + child.height + spacing
        end

        -- center element
        local center_child = dimensionated_children_data[valign_center_child_id]
        local center_child_x = align_on_secondary_axis(
            padding_left + parent_bw,
            padding_right + parent_bw,
            center_child.halign,
            available_width,
            center_child.width
        )
        table.insert(positioned_children_data, {
            x = center_child.offset_x + center_child_x,
            y = center_child.offset_y + center_child_y,
            width = center_child.width,
            height = center_child.height,
            element = center_child.element
        })

        -- bottom elements (if there are any)
        if valign_center_child_id ~= #dimensionated_children_data then
            local bottom_side_acc_y = available_height - (padding_bottom + parent_bw)
            for i=#dimensionated_children_data, (valign_center_child_id + 1), -1 do
                local child = dimensionated_children_data[i]
                local child_x = align_on_secondary_axis(
                    padding_left + parent_bw,
                    padding_right + parent_bw,
                    child.halign,
                    available_width,
                    child.width
                )

                bottom_side_acc_y = bottom_side_acc_y - child.height

                table.insert(positioned_children_data, {
                    x = child.offset_x + child_x,
                    y = child.offset_y + bottom_side_acc_y,
                    width = child.width,
                    height = child.height,
                    element = child.element,
                })

                bottom_side_acc_y = bottom_side_acc_y - spacing
            end
        end

    elseif position_type == POSITION_START_END then

        local first_valign_bottom_child_id = dimensionated_children_data.first_valign_bottom_child_id

        -- top-valign elements
        local top_side_acc_y = padding_top + parent_bw
        for i=1, first_valign_bottom_child_id - 1 do
            local child = dimensionated_children_data[i]
            local child_x = align_on_secondary_axis(
                padding_left + parent_bw,
                padding_right + parent_bw,
                child.halign,
                available_width,
                child.width
            )

            table.insert(positioned_children_data, {
                x = child.offset_x + child_x,
                y = child.offset_y + top_side_acc_y,
                width = child.width,
                height = child.height,
                element = child.element,
            })

            top_side_acc_y = top_side_acc_y + child.height + spacing
        end

        -- bottom-valign elements
        local bottom_side_acc_y = available_height - (padding_bottom + parent_bw)
        for i=#dimensionated_children_data, first_valign_bottom_child_id, -1 do
            local child = dimensionated_children_data[i]
            local child_x = align_on_secondary_axis(
                padding_left + parent_bw,
                padding_right + parent_bw,
                child.halign,
                available_width,
                child.width
            )

            bottom_side_acc_y = bottom_side_acc_y - child.height

            table.insert(positioned_children_data, {
                x = child.offset_x + child_x,
                y = child.offset_y + bottom_side_acc_y,
                width = child.width,
                height = child.height,
                element = child.element,
            })

            bottom_side_acc_y = bottom_side_acc_y - spacing
        end
    else -- position_type == POSITION_START
        local top_side_acc_y = padding_top + parent_bw
        for i=1, #dimensionated_children_data do
            local child = dimensionated_children_data[i]
            local child_x = align_on_secondary_axis(
                padding_left + parent_bw,
                padding_right + parent_bw,
                child.halign,
                available_width,
                child.width
            )

            table.insert(positioned_children_data, {
                x = child.offset_x + child_x,
                y = child.offset_y + top_side_acc_y,
                width = child.width,
                height = child.height,
                element = child.element,
            })

            top_side_acc_y = top_side_acc_y + child.height + spacing
        end
    end

    return positioned_children_data
end

local function _dimensionate_single_child_el(branch, child, avail_w, avail_h)

    local padd = branch.padding or 0
    local standardized_padding = eutil.standardize_padding(padd)
    local padding_top = standardized_padding.top
    local padding_right = standardized_padding.right
    local padding_bottom = standardized_padding.bottom
    local padding_left = standardized_padding.left
    local child_bw = get_border_width(child)

    local child_w = 0
    local child_h = 0

    local function _calculate_non_shrink_width(c)
        if type(c.width) == "number" then
            return c.width + (child_bw * 2)
        else -- child.width == "fill"
            local remaining_w = avail_w - (padding_left + padding_right)
            if remaining_w - (child_bw * 2) > 0 then
                return remaining_w
            else
                return child_bw * 2
            end
        end
    end

    local function _calculate_non_shrink_height(c)
        if type(c.height) == "number" then
            return c.height + (child_bw * 2)
        else -- child.height == "fill"
            local remaining_h = avail_h - (padding_top + padding_bottom)
            if remaining_h - (child_bw * 2) > 0 then
                return remaining_h
            else
                return child_bw * 2
            end
        end
    end

    if etypes.is_size_shrink(child.width) and etypes.is_size_shrink(child.height) then
        child_w, child_h = child._calculate_minimum_dimensions(child, nil, nil)

    elseif etypes.is_size_shrink(child.width) and not etypes.is_size_shrink(child.height) then
        local min_w, _ = child._calculate_minimum_dimensions(child, nil, child_h)
        child_h = _calculate_non_shrink_height(child)
        child_w = min_w

    elseif not etypes.is_size_shrink(child.width) and etypes.is_size_shrink(child.height) then
        child_w = _calculate_non_shrink_width(child)
        local _, min_h = child._calculate_minimum_dimensions(child, child_w, nil)
        child_h = min_h

    else -- neither are of type "shrink"
        child_w = _calculate_non_shrink_width(child)
        child_h = _calculate_non_shrink_height(child)

    end

    return {
        element = child,
        valign = child.valign or etypes.ALIGN_TOP,
        halign = child.halign or etypes.ALIGN_LEFT,
        width = child_w,
        height = child_h,
        offset_x = child.offset_x or 0,
        offset_y = child.offset_y or 0,
    }
end

local function dimensionate_children_el(branch, avail_w, avail_h)

    local dimensionated_children_data = {
        available_width = avail_w,
        available_height = avail_h,
        standardized_padding = eutil.standardize_padding(branch.padding or 0),
        parent_border_width = get_border_width(branch)
    }

    do
        local shadow = branch.shadow
        local bg = branch.bg
        if shadow ~= nil then dimensionated_children_data.shadow = shadow end
        if bg ~= nil then dimensionated_children_data.bg = bg end
    end

    for _, child in ipairs(branch) do
        table.insert(
            dimensionated_children_data,
            _dimensionate_single_child_el(branch, child, avail_w, avail_h)
        )
    end

    return dimensionated_children_data
end

local function position_children_el(dimensionated_children_data)
    local available_width = dimensionated_children_data.available_width
    local available_height = dimensionated_children_data.available_height

    local padding_top, padding_right, padding_bottom, padding_left
    do
        local standardized_padding = dimensionated_children_data.standardized_padding
        padding_top = standardized_padding.top
        padding_right = standardized_padding.right
        padding_bottom = standardized_padding.bottom
        padding_left = standardized_padding.left
    end

    local parent_bw = dimensionated_children_data.parent_border_width

    local positioned_children_data = {}

    do -- add shadow and bg elements first

        -- Note: normally, elements should not be dimensionated here, only
        -- positioned. but it's such a trivial task that we just dimensionate 
        -- and position the shadow and bg here
        local shadow = dimensionated_children_data.shadow
        if shadow ~= nil then
            table.insert(positioned_children_data, dimensionate_and_position_shadow(
                shadow,
                available_width,
                available_height
            ))
        end

        local bg = dimensionated_children_data.bg
        if bg ~= nil then
            table.insert(positioned_children_data, {
                x = bg.offset_x or 0,
                y = bg.offset_y or 0,
                width = available_width,
                height = available_height,
                element = bg
            })
        end
    end

    for _, dimensionated_child in ipairs(dimensionated_children_data) do

        local child_w = dimensionated_child.width
        local child_h = dimensionated_child.height
        table.insert(positioned_children_data, {
            element = dimensionated_child.element, -- a reference to the child
            x = align_on_secondary_axis(
                padding_left + parent_bw,
                padding_right + parent_bw,
                dimensionated_child.halign,
                available_width,
                child_w
            ) + dimensionated_child.offset_x,
            y = align_on_secondary_axis(
                padding_top + parent_bw,
                padding_bottom + parent_bw,
                dimensionated_child.valign,
                available_height,
                child_h
            ) + dimensionated_child.offset_y,
            width = child_w - (parent_bw * 2),
            height = child_h - (parent_bw * 2),
        })
    end

    return positioned_children_data
end

local function layout_children_horizontal(branch, avail_w, avail_h)

    -- NOTE: this will return nil if this branch has no shadow, no bg,
    -- and no sub-children
    if #branch:get_all_children() == 0 then return nil end

    return position_children_horizontal(
        dimensionate_children_horizontal(branch, avail_w, avail_h)
    )
end

local function layout_children_vertical(branch, avail_w, avail_h)

    -- NOTE: this will return nil if this branch has no shadow, no bg,
    -- and no sub-children
    if #branch:get_all_children() == 0 then return nil end

    return position_children_vertical(
        dimensionate_children_vertical(branch, avail_w, avail_h)
    )
end

local function layout_el(branch, avail_w, avail_h)

    -- NOTE: this will return nil if this branch has no shadow, no bg,
    -- and no sub-children
    if #branch:get_all_children() == 0 then return nil end

    return position_children_el(
        dimensionate_children_el(branch, avail_w, avail_h)
    )
end

------------------
-- drawing code
------------------

local function _create_radial_pattern_at_coords(x, y, corner_radius, edge_width, edge_opacity)

    -- radial gradients are defined by two circles: a starting one, and an ending one.
    -- we don't want to do anything crazy here, so both circles will be at the same
    -- x y coordinates
    local radpat = cairo.Pattern.create_radial(
        math.floor(x),
        math.floor(y),
        math.floor(corner_radius), -- the radius of the first circle.
        math.floor(x),
        math.floor(y),
        math.floor(edge_width + corner_radius) -- the radius of the second circle
    )
    radpat:add_color_stop_rgba(0, 0, 0, 0, 1)
    radpat:add_color_stop_rgba(math.floor(edge_width + corner_radius), 0, 0, 0, edge_opacity)

    return radpat
end

local function draw_shadow(shadow_el, cr, width, height, parent_border_radius)

    parent_border_radius = 5

    local shadow_edge_width = shadow_el.edge_width or 0
    local edge_opacity = shadow_el.edge_opacity or 0
    local clamped_rad = math.min(math.min(width, height ) / 2, parent_border_radius)

    local inner_shadow_body_width = (width - (clamped_rad * 2) - (shadow_edge_width * 2))
    local inner_shadow_body_height = (height - (clamped_rad * 2) - (shadow_edge_width * 2))

    local _, element_x_fractional_part = math.modf(shadow_el.geometry.x)
    local _, element_y_fractional_part = math.modf(shadow_el.geometry.y)

    local horizontally_body_visible = math.floor(inner_shadow_body_width) > 0
    local vertically_body_visible = math.floor(inner_shadow_body_height) > 0

    cr:save()

    -- cr:save()
    -- cr:set_source(esource.to_cairo_source(tcolor.rgb(0, 1, 0)))
    -- cr:set_line_width(1)
    -- cr:rectangle(1.5, 1.5, shadow_el.geometry.width-2, shadow_el.geometry.height-2)
    -- cr:stroke()
    -- cr:restore()



    -- since we're building the shadow out of a bunch of smaller, cut up gradients,
    -- we can have small gaps between these gradients when we put them together if
    -- the values we're using are not pixel aligned. therefore, we get the fractional
    -- part of the x & y position of the element, and we subtract that from the
    -- coordinates we use for shadows. This way, we can draw the element itself
    -- at fractional x & y values (because this looks good when animating at 
    -- high framerates), but we draw the shadow at pixel aligned coordinates,
    -- so we don't get gaps between parts of the shadows. yes, this means that
    -- the shadow is slightly "off" compared to the element, but this is very
    -- unnoticeable, even when animating
    cr:translate(
        clamped_rad + shadow_edge_width - element_x_fractional_part,
        clamped_rad + shadow_edge_width - element_y_fractional_part
    )

    cr:push_group_with_content(cairo.Content.ALPHA)

    -- draw the corners
    if math.floor(clamped_rad) > 0 or math.floor(shadow_edge_width) > 0 then

        cr:save() -- save so the translations don't affect anything else

        -- Note:
        -- (the values are automatically rounded in the radius pattern function)

        -- top-left corner
        local radpat_tl = _create_radial_pattern_at_coords(
            0,
            0,
            clamped_rad,
            shadow_edge_width,
            edge_opacity
        )
        cr:set_source(radpat_tl)
        cr:rectangle(
            0,
            0,
            - (math.floor(shadow_edge_width) + math.floor(clamped_rad)),
            - (math.floor(shadow_edge_width) + math.floor(clamped_rad))
        )
        cr:fill()
        -- print(cairo.Pattern.destroy)

        cr:translate(math.floor(inner_shadow_body_width), 0)

        -- top-right corner
        local radpat_tr = _create_radial_pattern_at_coords(
            0,
            0,
            clamped_rad,
            shadow_edge_width,
            edge_opacity
        )
        cr:set_source(radpat_tr)
        cr:rectangle(
            0,
            0,
            (math.floor(shadow_edge_width) + math.floor(clamped_rad)),
            -(math.floor(shadow_edge_width) + math.floor(clamped_rad))
        )
        cr:fill()

        cr:translate(0, math.floor(inner_shadow_body_height))

        -- bottom-right corner
        local radpat_br = _create_radial_pattern_at_coords(
            0,
            0,
            clamped_rad,
            shadow_edge_width,
            edge_opacity
        )
        cr:set_source(radpat_br)
        cr:rectangle(
            0,
            0,
            (math.floor(shadow_edge_width) + math.floor(clamped_rad)),
            (math.floor(shadow_edge_width) + math.floor(clamped_rad))
        )
        cr:fill()

        cr:translate(-math.floor(inner_shadow_body_width), 0)

        -- bottom-left corner
        local radpat_bl = _create_radial_pattern_at_coords(
            0,
            0,
            clamped_rad,
            shadow_edge_width,
            edge_opacity
        )
        cr:set_source(radpat_bl)
        cr:rectangle(
            0,
            0,
            -(math.floor(shadow_edge_width) + math.floor(clamped_rad)),
            (math.floor(shadow_edge_width) + math.floor(clamped_rad))
        )
        cr:fill()

        cr:restore()

    end

    -- draw the rectangles between the center rectangle and each side gradient
    -- we have to do this because of cases like when we have rounded borders
    if math.floor(clamped_rad) > 0 then

        if horizontally_body_visible then
            -- top side
            cr:rectangle(0, 0, math.floor(inner_shadow_body_width), -math.floor(clamped_rad))
            cr:fill()

            -- bottom side
            cr:save() -- save so translations won't affect anything else
            cr:translate(0, math.floor(inner_shadow_body_height))
            cr:rectangle(0, 0, math.floor(inner_shadow_body_width), math.floor(clamped_rad))
            cr:fill()
            cr:restore() -- save so translations won't affect anything else
        end

        if vertically_body_visible then

            -- left side
            cr:rectangle(0, 0, -math.floor(clamped_rad), math.floor(inner_shadow_body_height))
            cr:fill()

            -- right side
            cr:save()
            cr:translate(math.floor(inner_shadow_body_width), 0)
            cr:rectangle(0, 0, math.floor(clamped_rad), math.floor(inner_shadow_body_height))
            cr:fill()
            cr:restore()

        end

    end

    -- draw the gradients on the sides
    if math.floor(shadow_edge_width) > 0 then

        if horizontally_body_visible then
            -- top side gradient
            cr:save() -- save so translations won't affect anything else
            cr:translate(0, -math.floor(clamped_rad))
            local top = cairo.Pattern.create_linear(
                0,
                0,
                0,
                -math.floor(shadow_edge_width)
            )

            top:add_color_stop_rgba(0, 0, 0, 0, 1)
            top:add_color_stop_rgba(math.ceil(shadow_edge_width), 0, 0, 0, edge_opacity)
            cr:set_source(top)
            cr:rectangle(
                0,
                0,
                math.floor(inner_shadow_body_width),
                -math.floor(shadow_edge_width)
            )
            cr:fill()
            cr:restore()


            -- bottom side gradient
            cr:save()
            cr:translate(0, math.floor(inner_shadow_body_height) + math.floor(clamped_rad))
            local bottom = cairo.Pattern.create_linear(
                0,
                0,
                0,
                math.floor(shadow_edge_width)
            )
            bottom:add_color_stop_rgba(0, 0, 0, 0, 1)
            bottom:add_color_stop_rgba(math.ceil(shadow_edge_width), 0, 0, 0, edge_opacity)
            cr:set_source(bottom)
            cr:rectangle(
                0,
                0,
                math.floor(inner_shadow_body_width),
                math.floor(shadow_edge_width)
            )
            cr:fill()
            cr:restore()
        end

        if vertically_body_visible then
            -- right side gradient
            cr:save()
            cr:translate(math.floor(inner_shadow_body_width) + math.floor(clamped_rad), 0)
            local right = cairo.Pattern.create_linear(
                0,
                0,
                math.floor(shadow_edge_width),
                0
            )
            right:add_color_stop_rgba(0, 0, 0, 0, 1)
            right:add_color_stop_rgba(math.ceil(shadow_edge_width), 0, 0, 0, edge_opacity)
            cr:set_source(right)
            cr:rectangle(
                0,
                0,
                math.floor(shadow_edge_width),
                math.floor(inner_shadow_body_height)
            )
            cr:fill()
            cr:restore()

            -- left side gradient
            cr:save()
            cr:translate(-math.floor(clamped_rad), 0)
            local left = cairo.Pattern.create_linear(
                0,
                0,
                -math.floor(shadow_edge_width),
                0
            )
            left:add_color_stop_rgba(0, 0, 0, 0, 1)
            left:add_color_stop_rgba(math.ceil(shadow_edge_width), 0, 0, 0, edge_opacity)
            cr:set_source(left)
            cr:rectangle(
                0,
                0,
                -math.floor(shadow_edge_width),
                math.floor(inner_shadow_body_height)
            )
            cr:fill()
            cr:restore()
        end
    end

    if vertically_body_visible and horizontally_body_visible then
        -- draw the inner body of the shadow
        cr:rectangle(0, 0, math.floor(inner_shadow_body_width), math.floor(inner_shadow_body_height))
        cr:fill()
    end

    local mask = cr:pop_group()

    -- cr:set_source(esource.to_cairo_source(tcolor.rgb_from_string("#00ff00")))
    local shadow_color = shadow_el.color or tcolor.rgba_from_string("#00000080") -- sensible default shadow color
    cr:set_source(esource.to_cairo_source(shadow_color))
    cr:mask(mask)
    _dispose_pattern(mask)

    cr:restore()

end

local function draw_background(bg_elem, cr, width, height)
    local bg_source = bg_elem.source

    if bg_source == nil then return end

    local br_top_left, br_top_right, br_bottom_right, br_bottom_left
    do
        local border_radius = eutil.standardize_border_radius(bg_elem.border_radius or 0)
        br_top_left = border_radius.top_left or 0
        br_top_right = border_radius.top_right or 0
        br_bottom_right = border_radius.bottom_right or 0
        br_bottom_left = border_radius.bottom_left or 0
    end
    local border_width = bg_elem.border_width or 0

    if br_top_left > 0 or
        br_top_right > 0 or
        br_bottom_right > 0 or
        br_bottom_left > 0
    then
        -- we have rounded borders, so use a rounded rectangle as the path
        cr:save()
        cr:translate(border_width, border_width)
        tshape.rounded_rectangle_each(
            cr,
            width - (border_width * 2),
            height - (border_width * 2),
            br_top_left,
            br_top_right,
            br_bottom_right,
            br_bottom_left
        )
        cr:restore()
    else
        cr:rectangle(
            border_width,
            border_width,
            width - (border_width * 2),
            height - (border_width * 2)
        )
    end

    cr:set_source(esource.to_cairo_source(bg_source))
    cr:fill()
end

local function draw_border(bg_elem, cr, width, height)

    local border_width = bg_elem.border_width

    if border_width == nil then return end

    local br_top_left, br_top_right, br_bottom_right, br_bottom_left
    do
        local border_radius = eutil.standardize_border_radius(bg_elem.border_radius or 0)
        br_top_left = border_radius.top_left or 0
        br_top_right = border_radius.top_right or 0
        br_bottom_right = border_radius.bottom_right or 0
        br_bottom_left = border_radius.bottom_left or 0
    end

    -- local border_radius = bg_elem.border_radius or 0
    local border_source = bg_elem.border_source or tcolor.rgb(0, 0, 0) -- black default color for border
    cr:push_group_with_content(cairo.Content.ALPHA)
    cr.fill_rule = cairo.FillRule.EVEN_ODD

    if br_top_left > 0 or
        br_top_right > 0 or
        br_bottom_right > 0 or
        br_bottom_left > 0
    then

        tshape.rounded_rectangle_each(
            cr,
            width,
            height,
            br_top_left + border_width,
            br_top_right + border_width,
            br_bottom_right + border_width,
            br_bottom_left + border_width
        )

        -- tshape.rounded_rectangle(cr, width, height, border_radius + border_width)
        cr:translate(border_width, border_width)
        -- tshape.rounded_rectangle(cr, width - (border_width * 2), height - (border_width * 2), border_radius)
        tshape.rounded_rectangle_each(
            cr,
            width - (border_width * 2),
            height - (border_width * 2),
            br_top_left,
            br_top_right,
            br_bottom_right,
            br_bottom_left
        )
        cr:fill()
    else
        cr:rectangle(0, 0, width, height)
        cr:rectangle(
            border_width,
            border_width,
            width - (border_width * 2),
            height - (border_width * 2)
        )
        cr:fill()
    end
    local msk = cr:pop_group()
    cr:set_source(esource.to_cairo_source(border_source))
    cr:mask(msk)
    _dispose_pattern(msk)
end

return {

    POSITION_START = POSITION_START,
    POSITION_START_END = POSITION_START_END,
    POSITION_START_CENTER_END = POSITION_START_CENTER_END,

    LAYOUT_EL = 1,
    LAYOUT_HORIZONTAL = 2,
    LAYOUT_VERTICAL = 3,

    get_all_children = get_all_children,
    align_on_secondary_axis = align_on_secondary_axis,
    dimensionate_children_horizontal = dimensionate_children_horizontal,
    position_children_horizontal = position_children_horizontal,
    dimensionate_children_vertical = dimensionate_children_vertical,
    position_children_vertical = position_children_vertical,
    dimensionate_children_el = dimensionate_children_el,
    position_children_el = position_children_el,
    layout_children_horizontal = layout_children_horizontal,
    layout_children_vertical = layout_children_vertical,
    layout_el = layout_el,
    calculate_minimum_dimensions_horizontal = calculate_minimum_dimensions_horizontal,
    calculate_minimum_dimensions_vertical = calculate_minimum_dimensions_vertical,
    calculate_minimum_dimensions_el = calculate_minimum_dimensions_el,
    -- apply_clip_shape = apply_clip_shape,

    draw_background = draw_background,
    draw_border = draw_border,
    draw_shadow = draw_shadow,

}


