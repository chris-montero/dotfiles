

local eapplication = require("elemental.application")
local elayout = require("elemental.layout")
local ebg = require("elemental.elements.bg")
local el = require("elemental.elements.el")
local horizontal = require("elemental.elements.horizontal")
local vertical = require("elemental.elements.vertical")

local etypes = require("elemental.types")
local eutil = require("elemental.util")

local tstation = require("tools.station")
local tweeny = require("tools.weeny")
local tsf = require("tools.shaping_functions")
local tcolor = require("tools.color")

local color1 = tcolor.hsl(214, 0.2, 0.06)


local function make_layout(app_data)

    return elayout.new({
        x = 200,
        y = 400,
        width = 400,
        height = 300,
        -- bg = color1,
        app_data = app_data,
        visible = true,
        screen = screen.primary,
        subscribe_on_layout = {
            Init = function(scope)
                local layout_data = scope.layout_data
                layout_data[1] = vertical.new({
                    width = etypes.SIZE_FILL,
                    height = etypes.SIZE_FILL,
                    bg = ebg.new({
                        source = tcolor.hsl(215, 0.2, 0.10)
                    }),
                    horizontal.new({
                        valign = etypes.ALIGN_CENTER,
                        width = etypes.SIZE_FILL,
                        height = 60,
                        bg = ebg.new({
                            source = tcolor.hsl(100, 0.5, 0.5),
                            border_width = 2,
                            border_source = tcolor.rgb(1, 1, 1),
                        }),
                        el.new({
                            offset_x = 0,
                            offset_y = 0,
                            width = 60,
                            height = 60,
                            bg = ebg.new({
                                source = tcolor.hsl(02, 0.5, 0.5),
                            }),
                            subscribe_on_element = {
                                ["MouseButtonPressed"] = function(scope, emitted)
                                    local elem = scope.element
                                    local tracklist = app_data.tracklist
                                    tweeny.add_ween_at_elapsed(tracklist, "change_x",
                                        tweeny.endless(
                                            function(elapsed)
                                                return elapsed
                                            end,
                                            function(result)
                                                elem.offset_x = math.sin(result) * 20
                                                eutil.mark_relayout(elem._parent)
                                                eutil.mark_redraw(elem)
                                            end
                                        )
                                    )
                                    tweeny.add_ween_at_elapsed(tracklist, "change_y",
                                        tweeny.endless(
                                            function(elapsed)
                                                return elapsed
                                            end,
                                            function(result)
                                                elem.offset_y = - (math.cos(result) * 20)
                                                eutil.mark_relayout(elem._parent)
                                                eutil.mark_redraw(elem)
                                            end
                                        )
                                    )
                                end,
                            }
                        }),
                        el.new({
                            width = 60,
                            height = 60,
                            bg = ebg.new({
                                source = tcolor.hsl(202, 0.5, 0.5),
                            }),
                        }),
                        el.new({
                            width = 60,
                            height = 60,
                            bg = ebg.new({
                                source = tcolor.hsl(302, 0.5, 0.5),
                            }),
                        })
                    }),
                })
            end,
        }
    })

end

local function new(args)

    local tracklist = args.tracklist
    local global_model = args.global_model
    local global_station = args.global_station

    local app = eapplication.new({
        tracklist = tracklist,
        global_model = global_model,
        global_station = global_station,
        model = { },
    })
    app.model.layout = make_layout(app)

    return app

end



return {
    new = new,
}

