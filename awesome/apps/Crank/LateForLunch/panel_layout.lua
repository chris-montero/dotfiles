
local lgi = require("lgi")

local elayout = require("elemental.layout")
local etypes = require("elemental.types")
local esource = require("elemental.source")
local eutil = require("elemental.util")

local eshadow = require("elemental.elements.shadow")
local horizontal = require("elemental.elements.horizontal")
local vertical = require("elemental.elements.vertical")
local etext = require("elemental.elements.text")
local esvg = require("elemental.elements.svg")
local ebg = require("elemental.elements.bg")
local el = require("elemental.elements.el")

local tcolor = require("tools.color")
local tshape = require("tools.shape")
local tstation = require("tools.station")
local tutil = require("tools.util")

local crank_mode = require("apps.Crank.mode")

local global_palette = require("themes.LateForLunch.palette")

local function _map(arr, func)

    local new_arr = {}
    for k, v in ipairs(arr) do
        new_arr[k] = func(v)
    end
    return new_arr
end

local this_dir = tutil.current_dir_path()

local notifs = {
    {
        icon = this_dir .. "/assets/trash.svg",
        title = "Take out trash",
        time = "Today, 09:54 PM",
        -- description = "",
    },
    {
        icon = this_dir .. "/assets/phone.svg",
        title = "Call mom",
        description = "Dont forget to call mom. Shes very worried.",
        time = "Today, 7:22 PM",
    },
    {
        icon = this_dir .. "/assets/alert.svg",
        title = "Urgent",
        description = "Kitty in sock = Glumbis.",
        time = "Yesterday, 04:20 AM",
    },

}

local d_color_a3 = tcolor.hsl(215, 0.40, 0.10) -- original dark mode background

local d_color_a1 = tcolor.hsl(215, 0.40, 0.18) -- dark mode background
local d_color_a2 = tcolor.hsl(215, 0.40, 0.14) -- dark mode background
local d_color_a3 = tcolor.hsl(215, 0.40, 0.10) -- dark mode background

local d_color_b1 = tcolor.hsl(215, 0.36, 0.06)
local d_color_b2 = tcolor.hsl(210, 0.28, 0.30)
local d_color_b3 = tcolor.hsl(215, 0.36, 0.036)
local d_color_b4 = tcolor.hsl(210, 0.28, 0.22)

local l_color_a = tcolor.hsl(212, 0.30, 0.10) -- light mode background
-- local l_color_a = tcolor.hsl(207, 0.55, 0.20)
-- local l_color_a = tcolor.hsl(210, 0.58, 0.175)
-- local l_color_a = tcolor.hsl(204, 0.80, 0.21)

local l_color_b1 = tcolor.hsl(205, 0.8, 0.14)
local l_color_b2 = tcolor.hsl(200, 0.5, 0.28)
local l_color_b3 = tcolor.hsl(205, 0.6, 0.09)
local l_color_b4 = tcolor.hsl(200, 0.4, 0.60)


local border_out = esource.linear_gradient(
    { x = 0, y = 0 },
    { x = 36, y = 36 },
    {
        esource.stop(0, d_color_b4),
        esource.stop(0.46, d_color_b4),
        esource.stop(0.54, d_color_b3),
        esource.stop(1, d_color_b3),
    }
)

local border_pushed = esource.linear_gradient(
    { x = 0, y = 0 },
    { x = 36, y = 36 },
    {
        esource.stop(0, d_color_b3),
        esource.stop(0.48, d_color_b3),
        esource.stop(0.52, d_color_b4),
        esource.stop(1, d_color_b4),
    }
)

local function _draw_bg(self, cr, width, height)


    cr:rectangle(0, 0, width, height)
    cr:set_source(esource.to_cairo_source(d_color_a3))
    cr:fill()

    local height_a1 = (height / 10) * 4
    local height_a2 = (height / 10) * 12

    local width_b1 = (width / 10) * 7
    local height_b2 = (height / 10) * 7.5

    cr:move_to(0, 0)
    cr:line_to(width, 0)
    cr:line_to(width, height_a1)
    cr:line_to(0, height_a2)
    cr:line_to(0, 0)
    cr:set_source(esource.to_cairo_source(d_color_a2))
    cr:fill()


    cr:move_to(0, 0)
    cr:line_to(width_b1, 0)
    cr:line_to(0, height_b2)
    cr:line_to(0, 0)
    cr:set_source(esource.to_cairo_source(d_color_a1))
    cr:fill()

end

local function _draw_notification_list_bg_dark_mode(_, cr, width, height)

    -- cr:rectangle(0, 0, width, height)
    -- cr:set_source(esource.to_cairo_source(tcolor.hsl(198, 0.7, 0.67)))
    -- cr:fill()

    -- local surf = lgi.cairo.ImageSurface.create(lgi.cairo.Format.RGB24, 12, 12)
    -- local ctx = lgi.cairo.Context(surf)

    -- ctx:set_source(esource.to_cairo_source(tcolor.hsl(200, 0.7, 0.32)))
    -- ctx:paint()
    -- tshape.circle(ctx, 6, 6, 2)
    -- ctx:set_source(esource.to_cairo_source(tcolor.hsl(204, 0.74, 0.195)))
    -- ctx:fill()

    -- local patt = lgi.cairo.Pattern.create_for_surface(surf)
    -- patt:set_extend(lgi.cairo.Extend.REPEAT)

    -- cr:set_source(patt)
    -- cr:paint()

    -- local surf_size = 4
    -- local circle_rad = 1.0
    local surf_size = 12
    local circle_rad = 2
    local color_a = tcolor.hsl(208, 0.64, 0.030)
    local color_b = tcolor.hsl(210, 0.50, 0.070)


    cr:rectangle(0, 0, width, height)
    cr:set_source(esource.to_cairo_source(color_b))
    cr:fill()

    -- -- local color_b = tcolor.hsl(206, 0.50, 0.50)
    -- -- local color_b = tcolor.hsl(206, 0.50, 0.37)
    -- -- local color_b = tcolor.hsl(199, 0.55, 0.34)
    -- -- local color_b = tcolor.hsl(199, 0.7, 0.30)
    -- -- local color_b = tcolor.hsl(200, 0.7, 0.32)

    -- local surf_a = lgi.cairo.ImageSurface.create(lgi.cairo.Format.RGB24, surf_size, surf_size)
    -- local ctx = lgi.cairo.Context(surf_a)

    -- -- ctx:set_source(esource.to_cairo_source(tcolor.hsl(200, 0.7, 0.32)))
    -- ctx:set_source(esource.to_cairo_source(color_b))
    -- ctx:paint()
    -- tshape.circle(ctx, surf_size/2, surf_size/2, circle_rad)
    -- -- ctx:set_source(esource.to_cairo_source(tcolor.hsl(204, 0.74, 0.195)))
    -- ctx:set_source(esource.to_cairo_source(color_a))
    -- ctx:fill()

    -- local patt = lgi.cairo.Pattern.create_for_surface(surf_a)
    -- patt:set_extend(lgi.cairo.Extend.REPEAT)

    -- local surf_b = lgi.cairo.ImageSurface.create(lgi.cairo.Format.RGB24, surf_size, surf_size)
    -- local ctx_b = lgi.cairo.Context(surf_b)

    -- -- ctx_b:set_source(esource.to_cairo_source(tcolor.hsl(200, 0.7, 0.32)))
    -- ctx_b:set_source(esource.to_cairo_source(color_b))
    -- ctx_b:paint()
    -- tshape.circle(ctx_b, 0, surf_size/2, circle_rad)
    -- tshape.circle(ctx_b, surf_size, surf_size/2, circle_rad)
    -- ctx_b:set_source(esource.to_cairo_source(color_a))
    -- -- ctx_b:set_source(esource.to_cairo_source(tcolor.hsl(204, 0.74, 0.195)))
    -- ctx_b:fill()

    -- local patt_b = lgi.cairo.Pattern.create_for_surface(surf_b)
    -- patt_b:set_extend(lgi.cairo.Extend.REPEAT)


    -- local surf2 = lgi.cairo.ImageSurface.create(lgi.cairo.Format.RGB24, width, surf_size * 2)
    -- local ctx2 = lgi.cairo.Context(surf2)

    -- ctx2:set_source(patt)
    -- ctx2:rectangle(0, 0, width, surf_size)
    -- ctx2:fill()
    -- ctx2:translate(0, surf_size)
    -- ctx2:set_source(patt_b)
    -- ctx2:rectangle(0, 0, width, surf_size)
    -- ctx2:fill()

    -- surf_a:finish()
    -- surf_b:finish()

    -- local patt2 = lgi.cairo.Pattern.create_for_surface(surf2)
    -- patt2:set_extend(lgi.cairo.Extend.REPEAT)

    -- cr:set_source(patt2)
    -- tshape.rounded_rectangle(cr, width, height, 8)
    -- cr:fill()

    -- surf2:finish()


end

local function _draw_notification_list_bg(_, cr, width, height)

    -- cr:rectangle(0, 0, width, height)
    -- cr:set_source(esource.to_cairo_source(tcolor.hsl(198, 0.7, 0.67)))
    -- cr:fill()

    -- local surf = lgi.cairo.ImageSurface.create(lgi.cairo.Format.RGB24, 12, 12)
    -- local ctx = lgi.cairo.Context(surf)

    -- ctx:set_source(esource.to_cairo_source(tcolor.hsl(200, 0.7, 0.32)))
    -- ctx:paint()
    -- tshape.circle(ctx, 6, 6, 2)
    -- ctx:set_source(esource.to_cairo_source(tcolor.hsl(204, 0.74, 0.195)))
    -- ctx:fill()

    -- local patt = lgi.cairo.Pattern.create_for_surface(surf)
    -- patt:set_extend(lgi.cairo.Extend.REPEAT)

    -- cr:set_source(patt)
    -- cr:paint()


    -- local surf_size = 4
    -- local circle_rad = 1.0
    local surf_size = 12
    local circle_rad = 2
    local color_a = tcolor.hsl(208, 0.74, 0.145)
    local color_b = tcolor.hsl(204, 0.45, 0.60)
    -- local color_b = tcolor.hsl(206, 0.50, 0.50)
    -- local color_b = tcolor.hsl(206, 0.50, 0.37)
    -- local color_b = tcolor.hsl(199, 0.55, 0.34)
    -- local color_b = tcolor.hsl(199, 0.7, 0.30)
    -- local color_b = tcolor.hsl(200, 0.7, 0.32)

    local surf_a = lgi.cairo.ImageSurface.create(lgi.cairo.Format.RGB24, surf_size, surf_size)
    local ctx = lgi.cairo.Context(surf_a)

    -- ctx:set_source(esource.to_cairo_source(tcolor.hsl(200, 0.7, 0.32)))
    ctx:set_source(esource.to_cairo_source(color_b))
    ctx:paint()
    tshape.circle(ctx, surf_size/2, surf_size/2, circle_rad)
    -- ctx:set_source(esource.to_cairo_source(tcolor.hsl(204, 0.74, 0.195)))
    ctx:set_source(esource.to_cairo_source(color_a))
    ctx:fill()

    local patt = lgi.cairo.Pattern.create_for_surface(surf_a)
    patt:set_extend(lgi.cairo.Extend.REPEAT)

    local surf_b = lgi.cairo.ImageSurface.create(lgi.cairo.Format.RGB24, surf_size, surf_size)
    local ctx_b = lgi.cairo.Context(surf_b)

    -- ctx_b:set_source(esource.to_cairo_source(tcolor.hsl(200, 0.7, 0.32)))
    ctx_b:set_source(esource.to_cairo_source(color_b))
    ctx_b:paint()
    tshape.circle(ctx_b, 0, surf_size/2, circle_rad)
    tshape.circle(ctx_b, surf_size, surf_size/2, circle_rad)
    ctx_b:set_source(esource.to_cairo_source(color_a))
    -- ctx_b:set_source(esource.to_cairo_source(tcolor.hsl(204, 0.74, 0.195)))
    ctx_b:fill()

    local patt_b = lgi.cairo.Pattern.create_for_surface(surf_b)
    patt_b:set_extend(lgi.cairo.Extend.REPEAT)


    local surf2 = lgi.cairo.ImageSurface.create(lgi.cairo.Format.RGB24, width, surf_size * 2)
    local ctx2 = lgi.cairo.Context(surf2)

    ctx2:set_source(patt)
    ctx2:rectangle(0, 0, width, surf_size)
    ctx2:fill()
    ctx2:translate(0, surf_size)
    ctx2:set_source(patt_b)
    ctx2:rectangle(0, 0, width, surf_size)
    ctx2:fill()

    surf_a:finish()
    surf_b:finish()

    local patt2 = lgi.cairo.Pattern.create_for_surface(surf2)
    patt2:set_extend(lgi.cairo.Extend.REPEAT)

    cr:set_source(patt2)
    tshape.rounded_rectangle(cr, width, height, 8)
    cr:fill()

    surf2:finish()

end

local function make_mode_hud()

    local bg_normal1 = tcolor.hsl(215, 0.34, 0.19)
    local bg_normal2 = tcolor.hsl(215, 0.34, 0.40)
    local text_color_normal = tcolor.hsl(215, 0.45, 0.06)
    local text_normal = "Normal"

    local bg_search1 = tcolor.hsl(186, 0.35, 0.16)
    local bg_search2 = tcolor.hsl(177, 0.84, 0.50)
    local text_color_search = tcolor.hsl(170, 0.40, 0.08)
    local text_search = "Search"

    return horizontal.new({
        valign = etypes.ALIGN_BOTTOM,
        width = etypes.SIZE_FILL,
        height = 21,
        -- offset_y = -2,
        bg = ebg.new({
            source = bg_normal1,
        }),
        subscribe_on_app = {
            ["ModeChanged"] = function(scope, _)
                local app_data = scope.app_data
                local bg = scope.element.bg
                if app_data.model.mode == crank_mode.MODE_NORMAL then
                    bg.source = bg_normal1
                elseif app_data.model.mode == crank_mode.MODE_SEARCH then
                    bg.source = bg_search1
                end
                eutil.mark_redraw(bg)
            end
        },
        el.new({
            padding = etypes.padding_each({right = 10}),
            halign = etypes.ALIGN_RIGHT,
            width = 85,
            height = etypes.SIZE_FILL,
            _draw = function(self, cr, width, height)
                local _mode = self.app_data.model.mode
                cr:move_to(10, 0)
                cr:line_to(width, 0)
                cr:line_to(width, height)
                cr:line_to(0, height)
                cr:close_path()
                if _mode == crank_mode.MODE_NORMAL then
                    cr:set_source(esource.to_cairo_source(bg_normal2))
                elseif _mode == crank_mode.MODE_SEARCH then
                    cr:set_source(esource.to_cairo_source(bg_search2))
                end
                cr:fill()
            end,

            etext.new({
                halign = etypes.ALIGN_RIGHT,
                valign = etypes.ALIGN_CENTER,
                family = "TTCommons",
                weight = "Medium",
                size = 12,
                text = text_normal,
                fg = text_color_normal,
                subscribe_on_app = {
                    ["ModeChanged"] = function(scope, _)
                        local app_data = scope.app_data
                        local elem = scope.element
                        if app_data.model.mode == crank_mode.MODE_NORMAL then
                            elem.fg = text_color_normal
                            etext.set_text(elem, text_normal)
                        elseif app_data.model.mode == crank_mode.MODE_SEARCH then
                            elem.fg = text_color_search
                            etext.set_text(elem, text_search)
                        end
                        eutil.mark_relayout(elem._parent)
                        eutil.mark_redraw(elem)
                    end
                },
            })
        }),
    })


end

-- local function _draw_background(_, cr, width, height)

--     local first_anchor_y = height / 2
--     local second_anchor_y = (height / 3) * 2

--     local y_offset_unit1 = height / 18

--     local first_point_x = width / 3
--     local second_point_x = (width / 3) * 2

--     local l1_x1 = 0
--     local l1_y1 = first_anchor_y

--     local l1_x2 = first_point_x
--     local l1_y2 = first_anchor_y - y_offset_unit1 + 10

--     local l1_x3 = second_point_x
--     local l1_y3 = first_anchor_y - (y_offset_unit1 * 2) - 10

--     local l1_x4 = width
--     local l1_y4 = first_anchor_y - (y_offset_unit1 * 3) - 20

--     -- local l1_x5 = width
--     -- local l1_y5 = first_anchor_y - (y_offset_unit1 * 4)


--     cr:set_source(esource.to_cairo_source(tcolor.hsl(194, 0.60, 0.50)))
--     cr:rectangle(0, 0, width, height)
--     cr:fill()

--     cr:move_to(0, 0)
--     cr:line_to(l1_x1, l1_y1)
--     cr:curve_to(
--         l1_x1 + 60, l1_y1,
--         l1_x2 - 60, l1_y2,
--         l1_x2, l1_y2
--     )
--     cr:curve_to(
--         l1_x2 + 60, l1_y2,
--         l1_x3 - 60, l1_y3,
--         l1_x3, l1_y3
--     )
--     cr:curve_to(
--         l1_x3 + 60, l1_y3,
--         l1_x4 - 60, l1_y4,
--         l1_x4, l1_y4
--     )
--     -- cr:curve_to(
--     --     l1_x4 + 50, l1_y4,
--     --     l1_x5 - 50, l1_y5,
--     --     l1_x5, l1_y5
--     -- )
--     cr:line_to(width, 0)
--     cr:line_to(0, 0)
--     cr:set_source(esource.to_cairo_source(tcolor.hsl(205, 0.74, 0.235)))
--     cr:fill()

-- end









local function make_notification_with_description(args)

    local icon = args.icon
    local title = args.title
    local description = args.description
    local time = args.time

    local content = el.new({
        width = etypes.SIZE_FILL,
        padding = etypes.padding_each({ bottom = 6 }),
        shadow = eshadow.new({
            edge_width = 30,
            color = tcolor.rgba(0, 0, 0, 0.15),
        }),
        bg = ebg.new({
            -- source = tcolor.hsl(48, 0.90, 0.53),
            source = tcolor.hsl(40, 0.90, 0.33),
            border_radius = 5,
        }),
        vertical.new({
            bg = ebg.new({
                source = tcolor.hsl(48, 0.98, 0.65),
                -- source = tcolor.hsl(48, 0.90, 0.49),
                border_radius = 5,
            }),
            width = etypes.SIZE_FILL,
            horizontal.new({
                width = etypes.SIZE_FILL,
                padding = etypes.padding_each({ left = 10 }),
                spacing = 7,
                bg = ebg.new({
                    source = tcolor.hsl(48, 0.90, 0.50),
                    -- source = tcolor.hsl(48, 0.98, 0.64),
                    border_radius = etypes.border_radius_each({
                        top_left = 5,
                        top_right = 5
                    })
                }),
                esvg.new({
                    height = 20,
                    valign = etypes.ALIGN_CENTER,
                    file = icon,
                }),
                el.new({
                    padding = etypes.padding_each ({top = 10, bottom = 10}),
                    etext.new({
                        offset_y = 1,
                        family = "TTCommons",
                        weight = "Medium",
                        size = 12,
                        text = title,
                        fg = tcolor.rgb(0, 0, 0)
                    }),
                }),

                horizontal.new({
                    halign = etypes.ALIGN_RIGHT,
                    height = etypes.SIZE_FILL,
                    el.new({
                        height = etypes.SIZE_FILL,
                        padding = etypes.padding_axis({ x = 10 }),
                        -- bg = ebg.new({
                        --     source = tcolor.rgba(0, 0, 0, 0.2),
                        -- }),
                        esvg.new({
                            halign = etypes.ALIGN_CENTER,
                            valign = etypes.ALIGN_CENTER,
                            height = 14,
                            file = this_dir .. "/assets/thumbtack_1.svg",
                        })
                    }),
                    el.new({
                        height = etypes.SIZE_FILL,
                        padding = etypes.padding_each({ left = 10, right = 15 }),
                        -- bg = ebg.new({
                        --     source = tcolor.rgba(0, 0, 0, 0.2),
                        -- }),
                        el.new({
                            halign = etypes.ALIGN_CENTER,
                            valign = etypes.ALIGN_CENTER,
                            offset_x = -3,
                            width = 9,
                            height = 9,
                            _draw = function(self, cr, width, height)

                                cr:set_line_width(2)
                                cr:set_source(esource.to_cairo_source(tcolor.rgb(0, 0, 0)))

                                local epsilon = 0.5

                                cr:move_to(epsilon, epsilon)
                                cr:line_to(width - epsilon, height - epsilon)

                                cr:move_to(width - epsilon, epsilon)
                                cr:line_to(epsilon, height - epsilon)
                                cr:stroke()

                            end
                        })
                    }),
                }),
            }),
            el.new({
                width = etypes.SIZE_FILL,
                el.new({
                    padding = etypes.padding_each({
                        top = 10,
                        left = 10,
                        right = 10
                    }),
                    etext.new({
                        family = "TTCommons",
                        weight = "Regular",
                        size = 11,
                        text = description,
                        fg = tcolor.rgb(0, 0, 0)
                    })
                })
            }),
            el.new({
                padding = etypes.padding_each({
                    top = 5,
                    bottom = 5,
                    right = 10
                }),
                halign = etypes.ALIGN_RIGHT,
                etext.new({
                    family = "TTCommons",
                    weight = "Medium",
                    size = 9,
                    text = time,
                    letter_spacing = 1,
                    fg = tcolor.rgb(0, 0, 0)
                })
            }),
        }),
    })

    return content
end

local function make_notification_without_description(args)

    local icon = args.icon
    local title = args.title
    -- local description = args.description
    local time = args.time

    local content = el.new({
        width = etypes.SIZE_FILL,
        padding = etypes.padding_each({bottom = 6}),
        shadow = eshadow.new({
            edge_width = 30,
            color = tcolor.rgba(0, 0, 0, 0.15),
        }),
        bg = ebg.new({
            -- source = tcolor.hsl(48, 0.90, 0.53),
            source = tcolor.hsl(40, 0.90, 0.33),
            border_radius = 5,
        }),
        vertical.new({
            bg = ebg.new({
                source = tcolor.hsl(48, 0.98, 0.65),
                -- source = tcolor.hsl(48, 0.90, 0.49),
                border_radius = 5,
            }),
            width = etypes.SIZE_FILL,
            horizontal.new({
                width = etypes.SIZE_FILL,
                padding = etypes.padding_each({left = 10}),
                spacing = 7,
                bg = ebg.new({
                    source = tcolor.hsl(48, 0.90, 0.50),
                    -- source = tcolor.hsl(48, 0.98, 0.64),
                    border_radius = etypes.border_radius_each({
                        top_left = 5,
                        top_right = 5
                    })
                }),
                esvg.new({
                    -- width = 15,
                    -- offset_y = -1,
                    height = 20,
                    valign = etypes.ALIGN_CENTER,
                    file = icon,
                }),
                el.new({
                    padding = etypes.padding_each ({top = 10, bottom = 10}),
                    etext.new({
                        offset_y = 1,
                        family = "TTCommons",
                        weight = "Medium",
                        size = 12,
                        text = title,
                        fg = tcolor.rgb(0, 0, 0)
                    }),
                }),

                horizontal.new({
                    halign = etypes.ALIGN_RIGHT,
                    height = etypes.SIZE_FILL,
                    el.new({
                        height = etypes.SIZE_FILL,
                        padding = etypes.padding_axis({x = 10}),
                        esvg.new({
                            halign = etypes.ALIGN_CENTER,
                            valign = etypes.ALIGN_CENTER,
                            height = 14,
                            file = this_dir .. "/assets/thumbtack_1.svg",
                        })
                    }),
                    el.new({
                        height = etypes.SIZE_FILL,
                        padding = etypes.padding_each({left = 10, right = 15}),
                        -- bg = ebg.new({
                        --     source = tcolor.rgba(0, 0, 0, 0.2),
                        -- }),
                        el.new({
                            halign = etypes.ALIGN_CENTER,
                            valign = etypes.ALIGN_CENTER,
                            offset_x = -3,
                            width = 9,
                            height = 9,
                            _draw = function(self, cr, width, height)

                                cr:set_line_width(2)
                                cr:set_source(esource.to_cairo_source(tcolor.rgb(0, 0, 0)))

                                local epsilon = 0.5

                                cr:move_to(epsilon, epsilon)
                                cr:line_to(width - epsilon, height - epsilon)

                                cr:move_to(width - epsilon, epsilon)
                                cr:line_to(epsilon, height - epsilon)
                                cr:stroke()

                            end
                        })
                    }),
                }),

            }),
            el.new({
                halign = etypes.ALIGN_RIGHT,
                padding = etypes.padding_each({
                    top = 5,
                    bottom = 5,
                    right = 10,
                }),
                etext.new({
                    family = "TTCommons",
                    weight = "Medium",
                    size = 9,
                    text = time,
                    letter_spacing = 1,
                    fg = tcolor.rgb(0, 0, 0)
                })
            }),
        }),
    })

    return content
end

local button_pressed_source = tcolor.hsl(215, 0.3, 0.04)
local button_enabled_source = tcolor.hsl(215, 0.3, 0.18)
local button_source = tcolor.rgba(0, 0, 0, 0)

local bell_icon = esvg.new({
    halign = etypes.ALIGN_CENTER,
    valign = etypes.ALIGN_CENTER,
    source = tcolor.rgba(1, 1, 1, 0.80),
    height = 18,
    file = this_dir .. "/assets/bell.svg",
})
local bell_icon_slashed = esvg.new({
    halign = etypes.ALIGN_CENTER,
    valign = etypes.ALIGN_CENTER,
    source = tcolor.rgba(1, 1, 1, 0.80),
    height = 18,
    file = this_dir .. "/assets/bell-slash.svg",
})

local function make_tools_bar(args)

    local tools_bar = horizontal.new({
        padding = etypes.padding_axis({ y = 10 }),
        width = etypes.SIZE_FILL,
        spacing = 10,
        el.new({ -- mute / unmute notifications
            width = 36,
            height = 36,
            bg = ebg.new({
                source = button_source,
                border_radius = 3,
            }),
            mouse_input_stop = { -- dont forward this signal to anything below
                ["MouseButtonReleased"] = true
            },
            subscribe_on_element = {
                ["MouseButtonPressed"] = function(scope, _)
                    local elem = scope.element
                    local bg = elem.bg
                    elem.mouse_down = true
                    bg.source = button_pressed_source
                    elem[1].offset_x = 1
                    elem[1].offset_y = 1
                    eutil.mark_relayout(elem)
                    eutil.mark_redraw(bg)
                end,
                ["MouseButtonReleased"] = function(scope, _)
                    local elem = scope.element
                    local app_data = scope.app_data
                    if elem.mouse_down ~= true then return end

                    if app_data.model.muted == false then
                        app_data.model.muted = true
                        tstation.emit_signal(app_data.station, "Muted")
                    else
                        app_data.model.muted = false
                        tstation.emit_signal(app_data.station, "Unmuted")
                    end
                end,
            },
            subscribe_on_layout = {
                ["MouseButtonReleased"] = function(scope, _)
                    local elem = scope.element
                    local app_data = scope.app_data
                    local bg = elem.bg
                    if elem.mouse_down then
                        elem[1].offset_x = 0
                        elem[1].offset_y = 0
                        if app_data.model.muted == false then
                            bg.source = button_source
                        end
                        eutil.mark_relayout(elem)
                        eutil.mark_redraw(bg)
                    end
                end,
            },
            subscribe_on_app = {
                ["Muted"] = function(scope, _)
                    local elem = scope.element
                    local bg = elem.bg
                    -- elem.bg.border_source = border_pushed
                    elem[1] = bell_icon_slashed
                    elem[1].offset_x = 0
                    elem[1].offset_y = 0

                    bg.source = button_pressed_source
                    eutil.mark_relayout(elem._parent)
                    eutil.mark_redraw(elem)
                end,
                ["Unmuted"] = function(scope, _)
                    local elem = scope.element
                    local bg = elem.bg
                    -- elem.bg.border_source = border_out
                    elem[1] = bell_icon
                    elem[1].offset_x = 0
                    elem[1].offset_y = 0
                    bg.source = button_source
                    eutil.mark_relayout(elem._parent)
                    eutil.mark_redraw(elem)
                end,
            },
            bell_icon
        }),

        horizontal.new({ -- search bar
            -- halign = etypes.ALIGN_RIGHT,
            width = etypes.SIZE_FILL,
            height = 36,
            bg = ebg.new({
                -- source = tcolor.hsl(215, 0.2, 0.06),
                source = tcolor.hsl(215, 0.35, 0.22),
                border_radius = 5,
                border_width = 1,
                border_source = tcolor.hsl(215, 0.30, 0.35)
            }),
            mouse_input_stop = { -- dont forward this signal to anything below
                ["MouseButtonReleased"] = true
            },
            -- subscribe_on_element = {
            --     ["MouseButtonPressed"] = function(scope, _)
            --         local elem = scope.element
            --         elem.bg.source = button_pressed_source
            --         elem.mouse_down = true
            --         elem[1].offset_x = 1
            --         elem[1].offset_y = 1
            --         eutil.mark_relayout(elem._parent)
            --         eutil.mark_redraw(elem)
            --     end,
            --     ["MouseButtonReleased"] = function(scope, _)
            --         local elem = scope.element
            --         local app_data = scope.app_data
            --         if elem.mouse_down ~= true then return end
            --         elem.bg.source = button_source
            --         elem[1].offset_x = 0
            --         elem[1].offset_y = 0
            --         eutil.mark_relayout(elem._parent)
            --         eutil.mark_redraw(elem)
            --         tstation.emit_signal(app_data.station, "ClearNotifications")
            --     end,
            -- },
            -- subscribe_on_layout = {
            --     ["MouseButtonReleased"] = function(scope, _)
            --         local elem = scope.element
            --         local bg = elem.bg
            --         if bg.source == button_source and
            --             elem[1].offset_x == 0 and
            --             elem[1].offset_y == 0
            --         then
            --             return
            --         end
            --         bg.source = button_source
            --         elem[1].offset_x = 0
            --         elem[1].offset_y = 0
            --         eutil.mark_relayout(elem)
            --         eutil.mark_redraw(bg)
            --     end,
            -- },
            el.new({
                padding = etypes.padding_each({ left = 10 }),
                valign = etypes.ALIGN_CENTER,
                etext.new({
                    offset_y = 2,
                    valign = etypes.ALIGN_CENTER,
                    family = "TTCommons",
                    weight = "Medium",
                    size = 11,
                    text = "Search...",
                    -- fg = tcolor.rgba(1, 1, 1, 0.4),
                    fg = tcolor.hsl(215, 0.16, 0.50),
                }),
            }),

            el.new({
                halign = etypes.ALIGN_RIGHT,
                width = 36,
                height = etypes.SIZE_FILL,
                esvg.new({
                    offset_y = -2,
                    halign = etypes.ALIGN_CENTER,
                    valign = etypes.ALIGN_CENTER,
                    source = tcolor.rgba(1, 1, 1, 0.80),
                    height = 18,
                    file = this_dir .. "/assets/magnifying-glass.svg",
                }),
            }),
        }),


        el.new({ -- clear notifications button
            halign = etypes.ALIGN_RIGHT,
            width = 36,
            height = 36,
            bg = ebg.new({
                border_radius = 3,
            }),
            mouse_input_stop = { -- dont forward this signal to anything below
                ["MouseButtonReleased"] = true
            },
            subscribe_on_element = {
                ["MouseButtonPressed"] = function(scope, _)
                    local elem = scope.element
                    elem.bg.source = button_pressed_source
                    elem.mouse_down = true
                    elem[1].offset_x = 1
                    elem[1].offset_y = 1
                    eutil.mark_relayout(elem._parent)
                    eutil.mark_redraw(elem)
                end,
                ["MouseButtonReleased"] = function(scope, _)
                    local elem = scope.element
                    local app_data = scope.app_data
                    if elem.mouse_down ~= true then return end
                    elem.bg.source = button_source
                    elem[1].offset_x = 0
                    elem[1].offset_y = 0
                    eutil.mark_relayout(elem._parent)
                    eutil.mark_redraw(elem)
                    tstation.emit_signal(app_data.station, "ClearNotifications")
                end,
            },
            subscribe_on_layout = {
                ["MouseButtonReleased"] = function(scope, _)
                    local elem = scope.element
                    local bg = elem.bg
                    if bg.source == button_source and
                        elem[1].offset_x == 0 and
                        elem[1].offset_y == 0
                    then
                        return
                    end
                    bg.source = button_source
                    elem[1].offset_x = 0
                    elem[1].offset_y = 0
                    eutil.mark_relayout(elem)
                    eutil.mark_redraw(bg)
                end,
            },
            esvg.new({
                halign = etypes.ALIGN_CENTER,
                valign = etypes.ALIGN_CENTER,
                source = tcolor.rgba(1, 1, 1, 0.80),
                height = 18,
                file = this_dir .. "/assets/arrow-down-short-wide.svg",
            }),
        })
    })

    return tools_bar

end


local function make_content(args)

    local function make_separator()
        return vertical.new({
            width = etypes.SIZE_FILL,
            el.new({
                width = etypes.SIZE_FILL,
                height = 1,
                bg = ebg.new({
                    source = tcolor.rgba(0, 0, 0, 0.80)
                }),
            }),
            el.new({
                width = etypes.SIZE_FILL,
                height = 1,
                bg = ebg.new({
                    -- source = tcolor.hsl(200, 0.5, 0.38)
                    source = tcolor.hsl(210, 0.30, 0.34)
                }),
            }),
        })
    end

    local header = vertical.new({
        width = etypes.SIZE_FILL,
        padding = etypes.padding_each({bottom = 5}),
        horizontal.new({
            width = etypes.SIZE_FILL,
            etext.new({
                family = "TTCommons",
                weight = "Bold",
                size = 35,
                text = "Notifications",
                -- fg = tcolor.rgba(0, 0, 0, 0.60)
                -- fg = tcolor.rgba(1, 1, 1, 0.90)
                fg = tcolor.hsl(200, 0.55, 0.97)
            }),
            el.new({
                halign = etypes.ALIGN_RIGHT,
                height = etypes.SIZE_FILL,
                padding = etypes.padding_axis({x = 15}),
                el.new({
                    halign = etypes.ALIGN_CENTER,
                    valign = etypes.ALIGN_CENTER,
                    width = 14,
                    height = 14,
                    _draw = function(self, cr, width, height)

                        cr:set_line_width(2)
                        -- cr:set_source(esource.to_cairo_source(tcolor.rgb(0, 0, 0)))
                        cr:set_source(esource.to_cairo_source(tcolor.rgba(1, 1, 1, 0.8)))

                        local epsilon = 0.5

                        cr:move_to(epsilon, epsilon)
                        cr:line_to(width - epsilon, height - epsilon)

                        cr:move_to(width - epsilon, epsilon)
                        cr:line_to(epsilon, height - epsilon)
                        cr:stroke()

                    end
                })
            }),
        }),
    })

    -- local footer = el.new({
    --     width = etypes.SIZE_FILL,
    --     
    -- })

    local notification_list = el.new({
        -- padding = etypes.padding_axis({y = 20}),
        width = etypes.SIZE_FILL,
        height = etypes.SIZE_FILL,
        -- _draw = _draw_notification_list_bg,
        -- _draw = _draw_notification_list_bg_dark_mode,
        bg = ebg.new({
            source = tcolor.hsl(214, 0.50, 0.060),
            border_radius = 7,
            border_source = esource.linear_gradient(
                { x = 0, y = 0},
                -- { x = 780, y = 285 },
                { x = 782, y = 285 },
                {
                    esource.stop(0, d_color_b1),
                    esource.stop(0.49, d_color_b1),
                    esource.stop(0.51, d_color_b2),
                    esource.stop(1, d_color_b2),
                }
            ),
            border_width = 1.0,
        }),

        el.new({
            height = etypes.SIZE_FILL,
            width = etypes.SIZE_FILL,
            bg = ebg.new({
                border_radius = 6,
                border_source = esource.linear_gradient(
                    { x = 0, y = 0},
                    { x = 782, y = 285 },
                    {
                        esource.stop(0, d_color_b3),
                        esource.stop(0.49, d_color_b3),
                        esource.stop(0.51, d_color_b4),
                        esource.stop(1, d_color_b4)
                    }
                ),
                border_width = 1.0,
            }),
            vertical.new({
                padding = etypes.padding_axis({ x = 20, y = 20 }),
                spacing = 20,
                width = etypes.SIZE_FILL,
                unpack(_map(notifs, function(thing)
                    if thing.description == nil then
                        -- return make_notification_with_description(thing)
                        return make_notification_without_description(thing)
                    else
                        return make_notification_with_description(thing)
                    end
                end))
            }),
        })
    })

    return vertical.new({
        -- spacing = 10,
        width = etypes.SIZE_FILL,
        height = etypes.SIZE_FILL,
        padding = etypes.padding_each({ top = 40, bottom = 42 }),
        spacing = 40,

        vertical.new({
            padding = etypes.padding_each({ left = 20, right = 20 }),
            width = etypes.SIZE_FILL,
            height = etypes.SIZE_FILL,

            header,
            make_separator(),
            make_tools_bar(),
            -- make_separator(),
            notification_list,
        }),
        make_mode_hud(),
        -- make_mode_hud(MODE_SEARCH),
    })

end

local function new(args)

    local scr = args.screen

    local window_shadow_edge_width = 60

    local panel_width = 480
    local window_width = panel_width + window_shadow_edge_width
    local height = scr.geometry.height
    local x = scr.geometry.width - window_width
    local y = 0
    local app_data = args.app_data

    return elayout.new({
        x = x,
        y = y,
        width = window_width,
        height = height,
        screen = scr,
        bg = tcolor.rgba(0, 0, 0, 0),
        visible = false,
        app_data = args.app_data,
        type = "dock",
        subscribe_on_layout = {
            Init = function(scope)
                local layout_data = scope.layout_data
                layout_data[1] = el.new({
                    width = panel_width,
                    halign = etypes.ALIGN_RIGHT,
                    height = etypes.SIZE_FILL,
                    shadow = eshadow.new({
                        edge_width = window_shadow_edge_width,
                        color = tcolor.rgba(0, 0, 0, 0.20)
                    }),
                    -- bg = ebg.new({
                    --     -- source = tcolor.hsl(215, 0.31, 0.06)
                    --     -- source = tcolor.hsl(207, 0.55, 0.20)
                    --     -- source = tcolor.hsl(210, 0.58, 0.175)
                    --     -- source = tcolor.hsl(204, 0.80, 0.21)
                    --     source = d_color_a1,
                    -- }),
                    _draw = _draw_bg,
                    make_content({app_data = app_data}),
                    horizontal.new({

                        height = etypes.SIZE_FILL,
                        halign = etypes.ALIGN_LEFT,
                        el.new({
                            width = 1,
                            height = etypes.SIZE_FILL,
                            bg = ebg.new({
                                source = tcolor.rgb(0, 0, 0),
                            }),
                        }),
                        el.new({
                            width = 1.4,
                            height = etypes.SIZE_FILL,
                            bg = ebg.new({
                                -- source = tcolor.hsl(1, 1, 1, 0.15)
                                source = tcolor.hsla(215, 0.20, 0.38, 0.5)
                            })
                        })
                    }),
                })
            end
        }
    })

end

return {
    new = new,
}

