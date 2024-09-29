
local elayout = require("elemental.layout")
local etypes = require("elemental.types")
local esource = require("elemental.source")
local eutil = require("elemental.util")

local horizontal = require("elemental.elements.horizontal")
local vertical = require("elemental.elements.vertical")
local etext = require("elemental.elements.text")
local esvg = require("elemental.elements.svg")
local ebg = require("elemental.elements.bg")
local el = require("elemental.elements.el")

local tcolor = require("tools.color")
local tshape = require("tools.shape")

local global_palette = require("themes.LateForLunch.palette")

local window_width = 380
local window_height = 620
local window_corner_radius = 14


local function num_to_weekday(num)
    -- the idea of Sunday being first day of the week is retarded
    -- same as the idea "we should change the branch name from 'master' to 'main'"
    return num == 1 and "Sunday" or
        num == 2 and "Monday" or
        num == 3 and "Tuesday" or
        num == 4 and "Wednesday" or
        num == 5 and "Thursday" or
        num == 6 and "Friday" or
        num == 7 and "Saturday"
end

local color1 = tcolor.hsl(200, 0.1, 0.04)

local function make_sick_overlay(win_height, radius)

    return el.new({
        width = etypes.SIZE_FILL,
        height = etypes.SIZE_FILL,

        bg = ebg.new({
            border_width = 1,
            border_source = tcolor.rgb(0, 0, 0),
            border_radius = radius - 1,
        }),
        el.new({
            width = etypes.SIZE_FILL,
            height = etypes.SIZE_FILL,
            bg = ebg.new({
                border_width = 1.3,
                border_source = esource.linear_gradient(
                    { x = 0, y = 0},
                    { x = 0, y = win_height },
                    {
                        esource.stop(0, tcolor.rgba(1, 1, 1, 0.40)),
                        esource.stop(0.01, tcolor.rgba(1, 1, 1, 0.25)),
                        esource.stop(0.98, tcolor.rgba(1, 1, 1, 0.25)),
                        esource.stop(1, tcolor.rgba(1, 1, 1, 0.05)),
                    }
                ),
                border_radius = radius - 2
            }),
        })
    })
end

local function make_calendar(win_width, win_height)


    local month = vertical.new({
        spacing = 1,
        height = 300,
        width = etypes.SIZE_FILL,
        valign = etypes.ALIGN_BOTTOM,
        bg = ebg.new({
            -- source = tcolor.rgb(1, 1, 1)
            source = tcolor.rgba(1, 1, 1, 0.50),

        })
    })

    local day = 1

    for _=1, 5 do

        local week = horizontal.new({
            width = etypes.SIZE_FILL,
            height = etypes.SIZE_FILL,
            spacing = 1,
        })

        for _=1, 7 do
            table.insert(week, el.new({
                width = etypes.SIZE_FILL,
                height = etypes.SIZE_FILL,
                bg = ebg.new({
                    source = color1,
                }),
                etext.new({
                    offset_x = 6,
                    offset_y = 4,
                    text = tostring(day),
                    fg = tcolor.rgba(1, 1, 1, 0.75),
                    family = "TTCommons",
                    weight = "Bold",
                    letter_spacing = 1,
                    size = 10,
                })
            }))
            day = day + 1
        end

        table.insert(month, week)

    end

    local calendar = vertical.new({
        width = etypes.SIZE_FILL,
        padding = etypes.padding_each({ left = 20, right = 20 }),
        -- el.new({
        --     width = etypes.SIZE_FILL,
        --     height = 1,
        --     valign = etypes.ALIGN_BOTTOM,
        --     bg = ebg.new({
        --         -- source = tcolor.rgb(1, 1, 1),
        --         source = tcolor.rgba(1, 1, 1, 0.4),
        --     })
        -- }),
        el.new({
            clip_to_background = true,
            bg = ebg.new({
                border_width = 1,
                border_radius = 7,
                border_source = tcolor.rgba(1, 1, 1, 0.50)
            }),
            width = etypes.SIZE_FILL,
            month,
        }),
    })

    return calendar
end

local function make_content(args, win_width, win_height)

    local app_data = args.app_data

    local time_and_date = vertical.new({
        width = etypes.SIZE_FILL,
        padding = etypes.padding_axis({ x = 20, y = 30 }),
        -- bg = ebg.new({
        --     source = tcolor.rgba(0.8, 0.1, 0.1, 0.4)
        -- }),
        etext.new({
            text = app_data.global_model.time_counter.time:format("%H:%M"),
            fg = tcolor.rgba(1, 1, 1, 0.94),
            family = "TTCommons",
            weight = "Bold",
            size = 24,
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
            text = "",
            fg = tcolor.rgba(1, 1, 1, 0.94),
            family = "TTCommons",
            weight = "Demibold",
            size = 18,
            subscribe_on_global = {
                ["RequestCalendaryShow"] = function(scope)
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
        })
    })

    return vertical.new({
        height = etypes.SIZE_FILL,
        width = etypes.SIZE_FILL,
        -- bg = ebg.new({
        --     source = tcolor.rgba(0.1, 0.8, 0.1, 0.4),
        -- }),
        offset_y = 2,
        time_and_date,
        make_calendar(window_width, window_height)
    })

end

local function new(args)

    local scr = args.screen

    local x = 110
    local y = global_palette.bar_height + 20
    local app_data = args.app_data

    return elayout.new({
        x = x,
        y = y,
        width = window_width,
        height = window_height,
        screen = scr,
        bg = color1,
        shape = function(cr, width, height)
            tshape.rounded_rectangle(cr, width, height, window_corner_radius)
        end,
        visible = false,
        app_data = args.app_data,
        subscribe_on_layout = {
            Init = function(scope)
                local layout_data = scope.layout_data
                layout_data[1] = el.new({
                    width = etypes.SIZE_FILL,
                    height = etypes.SIZE_FILL,
                    make_content({app_data = app_data}, window_width, window_height),
                    make_sick_overlay(window_height, window_corner_radius)
                })
            end
        }
    })

end

return {
    new = new,
}
