
local eapplication = require("elemental.application")
local elayout = require("elemental.layout")
local eutil = require("elemental.util")
local tcolor = require("tools.color")
local tshape = require("tools.shape")
local weeny = require("tools.weeny")
local esource = require("elemental.source")

local etypes = require("elemental.types")
local etext = require("elemental.elements.text")
local el = require("elemental.elements.el")
local ebg = require("elemental.elements.bg")


local window_border_radius = 14
local window_height = 260

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

                        -- esource.stop(0, tcolor.rgba(1, 1, 1, 0.40)),
                        -- esource.stop(0.01, tcolor.rgba(1, 1, 1, 0.25)),
                        -- esource.stop(0.98, tcolor.rgba(1, 1, 1, 0.25)),
                        -- esource.stop(1, tcolor.rgba(1, 1, 1, 0.05)),

                        esource.stop(0, tcolor.hsl(215, 0.22, 0.40)),
                        esource.stop(0.01, tcolor.hsl(215, 0.22, 0.25)),
                        esource.stop(0.98, tcolor.hsl(215, 0.22, 0.25)),
                        esource.stop(1, tcolor.hsl(215, 0.22, 0.05)),
                    }
                ),
                border_radius = radius - 2
            }),
        })
    })
end


local function new(args)

    return eapplication.new({
        global_station = args.global_station,
        global_model = args.global_model,
        tracklist = args.tracklist,
        model = args.model,
        subscribe_on_app = {
            Init = function(scope)
                local app_data = scope.app_data
                app_data.model.layout = elayout.new({
                    app_data = app_data,
                    x = 1110,
                    y = 446,
                    shape = function(cr, width, height)
                        tshape.rounded_rectangle(cr, width, height, window_border_radius)
                    end,
                    width = 380,
                    height = window_height,
                    visible = true,
                    screen = screen.primary,
                    bg = tcolor.hsl(0, 1, 0.5),
                    subscribe_on_layout = {
                        Init = function(scope)
                            local layout_data = scope.layout_data

                            layout_data[1] = el.new({
                                width = etypes.SIZE_FILL,
                                height = etypes.SIZE_FILL,
                                bg = ebg.new({
                                    source = tcolor.hsl(215, 0.48, 0.06)
                                }),
                                etext.new({
                                    offset_y = 1,
                                    text = app_data.global_model.time_counter.time:format("%H:%M"),
                                    fg = tcolor.rgb(1, 1, 1),
                                    halign = etypes.ALIGN_CENTER,
                                    valign = etypes.ALIGN_CENTER,
                                    size = 56,
                                    family = "TTCommons",
                                    weight = "Bold",
                                    subscribe_on_global = {
                                        TimeChanged = function(scope, emitted)
                                            local element = scope.element
                                            local time = emitted.time
                                            etext.set_text(element, time:format("%H:%M"))
                                            -- TODO: dont use "_parent._parent"
                                            eutil.mark_relayout(element.layout_data)
                                            eutil.mark_redraw(element)
                                        end
                                    },
                                })
                            })
                            layout_data[2] = make_sick_overlay(window_height, window_border_radius)
                        end
                    }
                })
            end
        }
    })

end


return {
    new = new,
}




