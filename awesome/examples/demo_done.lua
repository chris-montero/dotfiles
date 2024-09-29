

local eapplication = require("elemental.application")
local elayout = require("elemental.layout")
local el = require("elemental.elements.el")
local ebg = require("elemental.elements.bg")
local horizontal = require("elemental.elements.horizontal")
local vertical = require("elemental.elements.vertical")
local etext = require("elemental.elements.text")

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
        width = 600,
        height = 400,
        bg = color1,
        app_data = app_data,
        visible = true,
        screen = screen.primary,

        subscribe_on_layout = {
            Init = function(scope)
                local layout_data = scope.layout_data

                layout_data[1] = el.new({
                    width = etypes.SIZE_FILL,
                    height = etypes.SIZE_FILL,
                    bg = ebg.new({
                        source = tcolor.hsl(215, 0.2, 0.06)
                    }),
                    padding = etypes.padding_axis({
                        x = 60,
                    }),
                    horizontal.new({
                        valign = etypes.ALIGN_CENTER,
                        width = etypes.SIZE_FILL,
                        -- height = 60,
                        bg = ebg.new({
                            border_width = 2,
                            border_source = tcolor.rgb(1, 1, 1)
                        }),
                        el.new({
                            width = 60,
                            height = 60,
                            bg = ebg.new({
                                source = tcolor.hsl(02, 0.5, 0.5),
                            }),
                            subscribe_on_element = {
                                ["MouseButtonPressed"] = function(scope, emitted)
                                    local elem = scope.element
                                    local parent_geom = elem._parent.geometry
                                    local elem_start_x = elem.geometry.x
                                    local final_x = parent_geom.width - elem.geometry.width - parent_geom.x - 6
                                    tweeny.add_ween_at_elapsed(app_data.tracklist, "first",
                                        tweeny.normalized(0.8,
                                            function(elapsed)
                                                return tsf.exponential_ease(elapsed, 0.08)
                                            end,
                                            function(result)
                                                elem.offset_x = elem_start_x + (final_x * result)
                                                eutil.mark_relayout(elem._parent)
                                                eutil.mark_redraw(elem)
                                            end
                                        )
                                    )
                                end
                            }
                        }),
                        el.new({
                            width = 60,
                            height = 60,
                            bg = ebg.new({
                                source = tcolor.hsl(150, 0.5, 0.5),
                            }),
                            subscribe_on_element = {
                                ["MouseButtonPressed"] = function(scope, emitted)
                                    local elem = scope.element
                                    local parent_geom = elem._parent.geometry
                                    local elem_start_x = elem.geometry.x
                                    local final_x = parent_geom.width - elem.geometry.width - parent_geom.x - 6
                                    tweeny.add_ween_at_elapsed(app_data.tracklist, "second",
                                        tweeny.normalized(0.8,
                                            function(elapsed)
                                                return tsf.exponential_ease(elapsed, 0.08)
                                            end,
                                            function(result)
                                                elem.offset_x = elem_start_x + (final_x * result)
                                                eutil.mark_relayout(elem._parent)
                                                eutil.mark_redraw(elem)
                                            end
                                        )
                                    )
                                end
                            }
                        }),
                        el.new({
                            width = 60,
                            height = 60,
                            bg = ebg.new({
                                source = tcolor.hsl(225, 0.5, 0.5),
                            }),
                            subscribe_on_element = {
                                ["MouseButtonPressed"] = function(scope, emitted)
                                    local elem = scope.element
                                    local parent_geom = elem._parent.geometry
                                    local elem_start_x = elem.geometry.x
                                    local final_x = parent_geom.width - elem.geometry.width - parent_geom.x - 6
                                    tweeny.add_ween_at_elapsed(app_data.tracklist, "third",
                                        tweeny.normalized(0.8,
                                            function(elapsed)
                                                return tsf.exponential_ease(elapsed, 0.08)
                                            end,
                                            function(result)
                                                elem.offset_x = elem_start_x + (final_x * result)
                                                eutil.mark_relayout(elem._parent)
                                                eutil.mark_redraw(elem)
                                            end
                                        )
                                    )
                                end
                            }
                        }),
                    })

                })
            end
        }
    })
end



-- local function make_layout(app_data)

--     return elayout.new({
--         x = 200,
--         y = 400,
--         width = 600,
--         height = 400,
--         bg = color1,
--         app_data = app_data,
--         visible = true,
--         screen = screen.primary,

--         subscribe_on_layout = {
--             Init = function(scope)
--                 local layout_data = scope.layout_data

--                 layout_data[1] = el.new({
--                     width = etypes.SIZE_FILL,
--                     height = etypes.SIZE_FILL,
--                     bg = ebg.new({
--                         source = tcolor.hsl(145, 0.45, 0.10)
--                     }),
--                     el.new({

--                         offset_x = 90,
--                         valign = etypes.ALIGN_CENTER,
--                         -- halign = etypes.ALIGN_CENTER,
--                         el.new({
--                             offset_x = -5,
--                             offset_y = 15,
--                             width = 20,
--                             height = 20,
--                             bg = ebg.new({
--                                 source = tcolor.hsl(45, 0.5, 0.4),
--                                 border_radius = 30,
--                             })
--                         }),
--                         etext.new({
--                             -- fg = tcolor.hsl(45, 0.5, 0.4),
--                             fg = tcolor.hsl(0, 0.5, 0.98),
--                             -- family = "Crimson",
--                             -- weight = "Semibold",
--                             family = "Caudex",
--                             weight = "Regular",
--                             -- letter_spacing = 1,
--                             size = 52,
--                             text = "Welcome to our page.",
--                         })
--                     }),
--                 })

--             end
--         }
--     })

-- end

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

