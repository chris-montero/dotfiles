
local eapplication = require("elemental.application")
local esource = require("elemental.source")
local elayout = require("elemental.layout")
local etypes = require("elemental.types")
local el = require("elemental.elements.el")
local ebg = require("elemental.elements.bg")
local tcolor = require("tools.color")
local tshape = require("tools.shape")
local icons = require("themes.LateForLunch.icons")


local fancy_radius = 12


local function make_sick_overlay(args)

    local height = args.height

    return el.new({
        width = etypes.SIZE_FILL,
        height = etypes.SIZE_FILL,

        bg = ebg.new({
            border_width = 1,
            border_source = tcolor.rgb(0, 0, 0),
            border_radius = fancy_radius - 1,
        }),
        el.new({
            width = etypes.SIZE_FILL,
            height = etypes.SIZE_FILL,
            bg = ebg.new({
                border_width = 1.3,
                border_source = esource.linear_gradient(
                    { x = 0, y = 0},
                    { x = 0, y = height },
                    {
                        esource.stop(0, tcolor.rgba(1, 1, 1, 0.70)),
                        esource.stop(0.01, tcolor.rgba(1, 1, 1, 0.40)),
                        esource.stop(0.98, tcolor.rgba(1, 1, 1, 0.40)),
                        esource.stop(1, tcolor.rgba(1, 1, 1, 0.12)),
                    }
                ),
                border_radius = fancy_radius - 2
            }),
        })
    })
end

local function make_fancy_drawing(args)

    local avail_w = args.width
    local avail_h = args.height
    local icon_w = args.icon_width / 3.4
    local icon_h = args.icon_height / 3.4
    local icon = args.icon

    return el.new({
        width = etypes.SIZE_FILL,
        height = etypes.SIZE_FILL,
        bg = ebg.new({
            source = esource.linear_gradient(
                { x = avail_w - (0.95 * avail_w), y = 0 },
                { x = avail_w - (0.05 * avail_w), y = avail_h },
                {
                    -- esource.stop(0, tcolor.hsl(02, 0.82, 0.69)),
                    -- esource.stop(1, tcolor.hsl(18, 0.82, 0.69))
                    esource.stop(0, tcolor.hsl(02, 0.85, 0.67)),
                    esource.stop(1, tcolor.hsl(18, 0.85, 0.67))
                }
            )
        }),
        el.new({
            width = math.ceil(icon_w),
            height = math.ceil(icon_h),
            offset_x = 2,
            offset_y = 2.5,
            halign = etypes.ALIGN_CENTER,
            valign = etypes.ALIGN_CENTER,
            _draw = function(self, cr, width, height)

                cr:scale(icon_h, icon_h)
                icon.draw(cr)
                cr:set_source(esource.to_cairo_source(tcolor.rgba(0, 0, 0, 0.1)))
                cr:fill()

            end,
        }),
        el.new({
            width = math.ceil(icon_w),
            height = math.ceil(icon_h),
            offset_x = 0,
            halign = etypes.ALIGN_CENTER,
            valign = etypes.ALIGN_CENTER,
            -- bg = ebg.new({
            --     source = tcolor.rgba(1, 0.2, 0.2, 0.4)
            -- }),
            _draw = function(self, cr, width, height)
                -- cr:scale(icon_h * icon.width_over_height, icon_h * icon.width_over_height)
                cr:scale(icon_h, icon_h)

                cr:push_group()
                cr:set_source(esource.to_cairo_source(tcolor.hsl(26, 1, 0.93)))
                -- cr:set_source(esource.to_cairo_source(tcolor.hsl(316, 0.55, 0.14))) -- ugly fucking slack color
                -- cr:set_source(esource.to_cairo_source(tcolor.hsl(138, 0.38, 0.10)))
                -- cr:set_source(esource.to_cairo_source(tcolor.hsl(205, 0.60, 0.14)))
                -- cr:set_source(esource.to_cairo_source(tcolor.hsl(250, 0.22, 0.10)))
                icon.draw(cr)
                cr:fill()

                cr:translate(0.3 / icon_h, 1 / icon_h)
                cr:set_line_width(1.3 / icon_h)
                cr:set_source(esource.to_cairo_source(tcolor.hsl(0, 1, 1)))
                icon.draw(cr)
                cr:stroke()

                local drawn = cr:pop_group()
                cr:set_source(drawn)
                icon.draw(cr)
                cr:fill()
                local _, drawn_surf = drawn:get_surface()
                drawn_surf:finish()

            end

        })
    })

end

local function fancy_layout(args)

    local scr = args.screen
    local app_data = args.app_data

    local icon = args.icon
    local icon_height = args.height
    local icon_width = icons.get_width_for_height(icon, icon_height)

    local layout_width = 480
    local layout_height = 320

    -- local x = (scr.geometry.width - layout_width) / 2
    -- local y = (scr.geometry.height - layout_height) / 2
    local x = 1110
    local y = 387

    return elayout.new({
        x = x,
        y = y,
        width = layout_width,
        height = layout_height,
        screen = scr,
        bg = tcolor.rgba(0, 0, 0, 0),
        shape = function(cr, width, height)
            tshape.rounded_rectangle(cr, width, height, fancy_radius)
        end,
        visible = true,
        app_data = app_data,
        subscribe_on_layout = {
            Init = function(scope)

                local layout_data = scope.layout_data
                layout_data[1] = el.new({
                    width = etypes.SIZE_FILL,
                    height = etypes.SIZE_FILL,
                    make_fancy_drawing({
                        width = layout_width,
                        height = layout_height,
                        icon_width = icon_width,
                        icon_height = icon_height,
                        icon = icon,
                    }),
                    make_sick_overlay({
                        height = layout_height,
                    })
                })
            end
        }
    })

end


local function layout(args)

    local icon = args.icon
    local app_data = args.app_data
    local scr = args.screen

    local height = args.height
    local icon_width = icons.get_width_for_height(icon, height)

    local x = scr.geometry.width - math.ceil(icon_width) - 40

    return elayout.new({
        x = x,
        y = 80,
        width = math.ceil(icon_width),
        height = height,
        screen = scr,
        bg = tcolor.rgb(1, 1, 1),
        visible = true,
        type = "dock",
        app_data = app_data,
        subscribe_on_layout = {
            Init = function(scope)
                local layout_data = scope.layout_data
                layout_data[1] = el.new({
                    width = etypes.SIZE_FILL,
                    height = etypes.SIZE_FILL,
                    _draw = function(self, cr, _, _)
                        -- cr:scale(height * icon.width_over_height, height * icon.width_over_height)
                        -- cr:scale(icon_width, icon_width)
                        cr:scale(height, height)
                        icon.draw(cr)
                        cr:set_source(esource.to_cairo_source(tcolor.rgb(0, 0, 0)))
                        cr:fill()
                    end
                })
            end
        }
    })


end


local function new(args)

    local icon = args.icon

    local icon_height = 460
    -- local icon_height = 550
    -- local icon_width = args.icon_width
    -- local icon_height = args.icon_height
    local scr = args.screen

    local app = eapplication.new({
        global_station = args.global_station,
        global_model = args.global_model,
        tracklist = args.tracklist,
        model = {
            icon = icon,
        }
    })

    -- app.model.layout = layout({
    --     -- width = icon_width,
    --     height = icon_height,
    --     icon = icon,
    --     app_data = app,
    --     screen = scr,
    -- })

    app.model.fancy_layout = fancy_layout({
        height = icon_height,
        icon = icon,
        app_data = app,
        screen = scr,
    })


end



return {
    new = new,
}
