
local lgi = require("lgi")

local elayout = require("elemental.layout")
local esource = require("elemental.source")
local etypes = require("elemental.types")
local etext = require("elemental.elements.text")
local eutil = require("elemental.util")

local horizontal = require("elemental.elements.horizontal")
local vertical = require("elemental.elements.vertical")
local el = require("elemental.elements.el")
local ebg = require("elemental.elements.bg")
local esvg = require("elemental.elements.svg")

local tcolor = require("tools.color")
local tshape = require("tools.shape")
local tweeny = require("tools.weeny")
local tutil = require("tools.util")
local tsf = require("tools.shaping_functions")

local global_palette = require("themes.LateForLunch.palette")

local this_dir = tutil.current_dir_path()

local color1 = tcolor.hsl(203, 0.68, 0.4)

local panel_root = "panel_root"
local top_side = "top_side"

local cloud_width1 = 160
local cloud_height1 = 100

local cloud_width2 = 200
local cloud_height2 = 120

local function _map_id(arr, func)
    local new_arr = {}
    for k, v in ipairs(arr) do
        new_arr[k] = func(k, v)
    end
    return new_arr
end

local function num_to_weekday(num)
    -- the idea of Sunday being first day of the week is retarded
    -- same as the idea "we should change the branch name from 'master' to 'main'"
    if num == 1 then
        return "Sunday"
    elseif num == 2 then
        return "Monday"
    elseif num == 3 then
        return "Tuesday"
    elseif num == 4 then
        return "Wednesday"
    elseif num == 5 then
        return "Thursday"
    elseif num == 6 then
        return "Friday"
    elseif num == 7 then
        return "Saturday"
    end
end

local bg_cloud = lgi.cairo.ImageSurface.create_from_png(this_dir .. "/assets/bg_cloud.png")
local fg_cloud = lgi.cairo.ImageSurface.create_from_png(this_dir .. "/assets/fg_cloud.png")
local height_scale_factor = fg_cloud:get_height() / fg_cloud:get_width()
local down_scale_factor1 = cloud_width1 / fg_cloud:get_width()
local down_scale_factor2 = cloud_width2 / bg_cloud:get_width()
-- print(fg_cloud:get_width(), fg_cloud:get_height())


local forecast_list = {
    {
        average_degrees = 4,
        icon = this_dir .. "/assets/cloud-rain.svg",
        selected = true,
    },
    {
        average_degrees = 11,
        icon = this_dir .. "/assets/cloud-sun.svg"
    },
    {
        average_degrees = 1,
        icon = this_dir .. "/assets/cloud.svg"
    },
    {
        average_degrees = -2,
        icon = this_dir .. "/assets/snowflake.svg"
    },
    {
        average_degrees = -5,
        icon = this_dir .. "/assets/snowflake.svg"
    },
    {
        average_degrees = -3,
        icon = this_dir .. "/assets/cloud.svg"
    },
    {
        average_degrees = -7,
        icon = this_dir .. "/assets/cloud.svg"
    },

}

local function make_forecast_item(id, args)

    local modded = (id + 3) % 7 + 1
    local day_name = string.sub(num_to_weekday(modded), 1, 2)
    local degrees = args.average_degrees
    local icon = args.icon


    local item = vertical.new({
        spacing = 8,
        etext.new({
            halign = etypes.ALIGN_CENTER,
            family = "TTCommons",
            weight = "Medium",
            size = 11,
            fg = tcolor.rgb(1, 1, 1),
            text = day_name,
        }),
        esvg.new({
            height = 18,
            source = tcolor.rgb(1, 1, 1),
            file = icon
        }),
        etext.new({
            halign = etypes.ALIGN_CENTER,
            family = "TTCommons",
            weight = "Demibold",
            letter_spacing = 1,
            size = 11,
            fg = tcolor.rgb(1, 1, 1),
            text = degrees .. '°'
        })
    })

    if id == 1 then
        table.insert(item, el.new({
            -- width = 10,
            -- height = 10,
            halign = etypes.ALIGN_CENTER,
            width = 6,
            height = 6,
            -- _draw = function(self, cr, width, height)
            --     -- local point_y1 = height / 3

            --     -- cr:move_to(width / 2, 0)
            --     -- cr:line_to(width, point_y1)
            --     -- cr:line_to(width, height)
            --     -- cr:line_to(0, height)
            --     -- cr:line_to(0, point_y1)
            --     -- cr:close_path()
            --     -- cr:set_source(esource.to_cairo_source(tcolor.hsl(1, 0.6, 0.5)))
            --     -- cr:fill()

            --     local point_y1 = height / 3

            --     cr:move_to(width / 2, 0)
            --     cr:line_to(width, height)
            --     cr:line_to(0, height)
            --     cr:close_path()
            --     cr:set_source(esource.to_cairo_source(tcolor.hsl(1, 0.6, 0.5)))
            --     cr:fill()

            -- end,
            bg = ebg.new({
                source = tcolor.hsl(1, 0.6, 0.5),
                border_radius = 10,
            }),
        }))
    else
        table.insert(item, el.new({
            halign = etypes.ALIGN_CENTER,
            width = 6,
            height = 6,
            bg = ebg.new({
                source = tcolor.rgb(1, 1, 1),
                border_radius = 10,
            }),
        }))
    end

    return item
end


local function make_hud(args)

    local full_height = args.height
    local hud_height = 130

    local hud_separator = vertical.new({
        width = etypes.SIZE_FILL,
        el.new({
            width = etypes.SIZE_FILL,
            height = 1,
            bg = ebg.new({
                source = tcolor.rgba(0, 0, 0, 0.3)
            }),
        }),
        el.new({
            width = etypes.SIZE_FILL,
            height = 1,
            bg = ebg.new({
                -- source = tcolor.rgba(1, 1, 1, 0.3)
                source = tcolor.hsl(212, 0.6, 0.55)
            }),
        }),
    })

    return vertical.new({
        width = etypes.SIZE_FILL,
        height = hud_height,
        valign = etypes.ALIGN_BOTTOM,
        bg = ebg.new({
            source = tcolor.rgba(0, 0, 0, 0.30)
        }),
        -- thermometer,
        hud_separator,
        vertical.new({
            halign = etypes.ALIGN_CENTER,
            valign = etypes.ALIGN_CENTER,
            offset_y = -4,
            spacing = 10,

            el.new({

                offset_y = 87.5,
                width = etypes.SIZE_FILL,
                halign = etypes.ALIGN_CENTER,
                padding = etypes.padding_each({left = 8, right = 10}),
                el.new({
                    width = etypes.SIZE_FILL,
                    height = 1,
                    bg = ebg.new({
                        source = tcolor.rgba(1, 1, 1, 0.65)
                    })
                }),
            }),
            horizontal.new({
                spacing = 16,
                unpack(_map_id(forecast_list, make_forecast_item))
            }),
        }),
    })
end

local function make_top_side(args)
    -- local width = args.width
    local avail_h = args.height
    local app_data = args.app_data
    return el.new({
        width = etypes.SIZE_FILL,
        -- height = avail_h,
        height = avail_h,
        bg = ebg.new({
            source = esource.linear_gradient(
                { x = 0, y = 0},
                { x = 0, y = avail_h},
                {
                    -- esource.stop(0, tcolor.hsl(200, 0.13, 0.35)),
                    -- esource.stop(1, tcolor.hsl(200, 0.12, 0.50))
                    esource.stop(0, tcolor.hsl(198, 0.70, 0.30)),
                    esource.stop(1, color1),
                }
            )
        }),
        -- _draw = function(elem, cr, width, height)
        --     cr:move_to(0, 0)
        --     cr:line_to(width, 0)
        --     cr:line_to(width, height)
        --     cr:line_to(0, height)
        --     -- cr:line_to(width, height - app_data.model.top_sheet_push)
        --     -- cr:line_to(0, height - app_data.model.top_sheet_push / 2)
        --     cr:line_to(0, 0)
        --     cr:close_path()
        --     local linpat = esource.linear_gradient(
        --         { x = 0, y = 0,},
        --         { x = 0, y = args.height},
        --         {
        --             esource.stop(0, tcolor.hsl(200, 0.13, 0.35)),
        --             esource.stop(1, tcolor.hsl(200, 0.12, 0.50))
        --             -- esource.stop(0, tcolor.hsl(198, 0.70, 0.30)),
        --             -- esource.stop(1, color1),
        --         }
        --     )
        --     -- cr:set_source(esource.to_cairo_source(color1))
        --     cr:set_source(esource.to_cairo_source(linpat))
        --     cr:fill()
        -- end,

        subscribe_on_global = {
            ["EventWeatherShown"] = function(scope)
                local model = app_data.model
                local elem = scope.element
                tweeny.add_ween_at_elapsed(app_data.tracklist, top_side, tweeny.normalized(0.4,
                    function(x)
                        return tsf.exponential_ease(x, 0.06)
                    end,
                    function(result)
                        model.top_sheet_push = result * 60
                        eutil.mark_redraw(elem)
                    end
                ))
            end
        },

        el.new({
            offset_y = 40,
            offset_x = 220,
            width = cloud_width2,
            height = cloud_width2 * height_scale_factor,
            _draw = function(_, cr, width, height)
                -- local bg_cloud_surf = lgi.cairo.Surface.create_similar_image(
                -- local bg_cloud_surf = lgi.cairo.ImageSurface.create_similar(
                --     bg_cloud,
                --     lgi.cairo.Content.COLOR,
                --     bg_cloud:get_width(),
                --     bg_cloud:get_height()
                -- )
                -- local cloud = lgi.cairo.ImageSurface.create_from_png(this_dir .. "/assets/bg_cloud.png")

                cr:scale(down_scale_factor2, down_scale_factor2)
                -- cr:set_source_surface(bg_cloud_surf)
                cr:set_source_surface(bg_cloud)
                -- cr:paint_with_alpha(0.9)
                cr:paint()
                -- bg_cloud_surf:finish()
            end,

            subscribe_on_global = {
                ["EventWeatherShown"] = function(scope)
                    local model = app_data.model
                    local elem = scope.element
                    tweeny.add_ween_at_elapsed(app_data.tracklist, "bg_cloud", tweeny.normalized(7,
                        function(x)
                            return tsf.exponential_ease(x, 0.05)
                        end,
                        function(result)
                            elem.offset_x = 220 - (result * 100)
                            eutil.mark_relayout(elem._parent)
                            eutil.mark_redraw(elem)
                        end
                    ))
                end
            }
        }),
        el.new({
            offset_y = 25,
            offset_x = 20,
            width = cloud_width1 + 2,
            height = (cloud_width1 * height_scale_factor) + 2,
            _draw = function(_, cr, width, height)

                cr:scale(down_scale_factor1, down_scale_factor1)
                cr:set_source_surface(fg_cloud)
                -- cr:paint_with_alpha(0.9)
                cr:paint()
                -- cloud:finish()

            end,
            subscribe_on_global = {
                ["EventWeatherShown"] = function(scope)
                    local model = app_data.model
                    local elem = scope.element
                    tweeny.add_ween_at_elapsed(app_data.tracklist, "fg_cloud", tweeny.normalized(7,
                        function(x)
                            return tsf.exponential_ease(x, 0.05)
                        end,
                        function(result)
                            elem.offset_x = result * (20)
                            eutil.mark_relayout(elem._parent)
                            eutil.mark_redraw(elem)
                        end
                    ))
                end
            }
        }),

        vertical.new({
            padding = etypes.padding_each({
                top = 120,
            }),
            halign = etypes.ALIGN_CENTER,

            etext.new({
                halign = etypes.ALIGN_CENTER,
                text = app_data.global_model.time_counter.time:format("%H:%M"),
                fg = tcolor.rgb_from_string("#ffffff"),
                size = 80,
                family = "Bebas Neue",
                weight = "Bold",
                subscribe_on_global = {
                    TimeChanged = function(scope, emitted)
                        local element = scope.element
                        local time = emitted.time
                        etext.set_text(element, time:format("%H:%M"))
                        eutil.mark_relayout(element._parent._parent)
                        eutil.mark_redraw(element)
                    end
                }
            }),
            etext.new({
                offset_y = -10,
                halign = etypes.ALIGN_CENTER,
                text = "",
                -- fg = tcolor.rgba_from_string("#00000040"),
                fg = tcolor.rgb_from_string("#ffffff"),
                size = 14,
                -- letter_spacing = 0,
                family = "TTCommons",
                -- weight = "Medium",
                weight = "Medium",
                subscribe_on_global = {
                    ["RequestWeatherToggle"] = function(scope)
                        local element = scope.element
                        local date = os.date("*t")
                        etext.set_text(element,
                            tostring(date.day) .. ', ' ..
                            tostring(num_to_weekday(date.wday)) .. ', ' ..
                            tostring(date.month) .. ', ' ..
                            tostring(date.year)
                        )
                        eutil.mark_relayout(element._parent._parent)
                        eutil.mark_redraw(element)
                    end,
                }
            }),
            etext.new({
                -- offset_y = 5,
                offset_x = 6,
                halign = etypes.ALIGN_CENTER,
                -- text = "17°-22°",
                text = "02°-06°",
                -- fg = tcolor.rgba_from_string("#00000040"),
                fg = tcolor.rgb_from_string("#ffffff"),
                letter_spacing = 2,
                size = 13,
                family = "TTCommons",
                weight = "Demibold",
            }),
        }),

    })
end

local function make_sick_overlay(args)

    local height = args.height

    return el.new({
        width = etypes.SIZE_FILL,
        height = etypes.SIZE_FILL,

        bg = ebg.new({
            border_width = 1,
            border_source = tcolor.rgb(0, 0, 0),
            border_radius = 19,
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
                        esource.stop(0, tcolor.rgba(1, 1, 1, 0.45)),
                        esource.stop(0.01, tcolor.rgba(1, 1, 1, 0.20)),
                        esource.stop(0.98, tcolor.rgba(1, 1, 1, 0.20)),
                        esource.stop(1, tcolor.rgba(1, 1, 1, 0.08)),
                    }
                ),
                border_radius = 18,
            }),
        })
    })
end


local function new(args)
    local app_data = args.app_data
    local scr = args.screen

    local width = 320
    local height = 480
    -- local x = scr.geometry.width - width - 100
    local x = 60
    local y = global_palette.bar_height + 20 -- TODO: make this work based on the actual size of the bar

    return elayout.new({
        x = x,
        y = y,
        width = width,
        height = height,
        app_data = app_data,
        screen = scr,
        bg = tcolor.rgba_from_string("#00000000"),
        shape = function(cr, w, h)
            tshape.rounded_rectangle(cr, w, h, 20)
        end,
        visible = false,
        type = "popup_menu",
        subscribe_on_layout = {
            Init = function(scope)
                local layout_data = scope.layout_data
                layout_data[1] = el.new({
                    width = etypes.SIZE_FILL,
                    height = etypes.SIZE_FILL,
                    -- bg = ebg.new({
                    --     border_radius = 21,
                    --     -- source = tcolor.hsl(210, 0.72, 0.17),
                    --     source = tcolor.hsl(210, 0.66, 0.25),
                    -- }),
                    make_top_side({
                        app_data = app_data,
                        height = height,
                    }),
                    make_hud({height = height}),
                    make_sick_overlay({height = height}),
                })

            end
        }
    })

end


return {
    new = new,
}
