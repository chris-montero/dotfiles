
local application = require("elemental.application")
local elayout = require("elemental.layout")
local eutil = require("elemental.util")
local eshadow = require("elemental.elements.shadow")
local ebg = require("elemental.elements.bg")
local el = require("elemental.elements.el")
local horizontal = require("elemental.elements.horizontal")
-- local vertical = require("elemental.elements.vertical")
local tstation = require("tools.station")
local tcolor = require("tools.color")
local weeny = require("tools.weeny")


local function new(args)
    local app_data = application.new({
        model = args.model,
        global_model = args.global_model,
        global_station = args.global_station,
        tracklist = args.tracklist,
        subscribe_on_app = {
            Init = function(scope)
                local app_data = scope.app_data
                app_data.model.layout = elayout.new({
                    app_data = app_data,
                    x = 200,
                    y = 200,
                    width = 200,
                    height = 200,
                    visible = true,
                    bg = tcolor.rgb_from_string("#222222"),
                    screen = screen.primary,
                    subscribe_on_layout = {
                        Init = function(scope)
                            local app_data = scope.app_data
                            local layout_data = scope.layout_data

                            local root_el
                            root_el = horizontal.new({
                                width = "fill",
                                height = "fill",
                                bg = ebg.new({
                                    source = tcolor.rgb_from_string("#222730"),
                                }),
                                el.new({ -- first_el
                                    offset_x = app_data.model.x,
                                    offset_y = app_data.model.y,
                                    width = 40,
                                    height = 20,
                                    shadow = eshadow.new({
                                        color = tcolor.rgba_from_string("#00000050"),
                                        offset_x = 0,
                                        offset_y = 0,
                                        -- scale = 0.8,
                                        edge_width = 20,
                                        edge_opacity = 0,
                                        -- draw_outside = true,
                                    }),
                                    bg = ebg.new({
                                        source = tcolor.rgba_from_string("#ff88ffaa"),
                                        border_radius = 6,
                                        border_width = 1,
                                    }),
                                    -- bg = ebg.new({
                                    --     source = tcolor.rgb_from_string("#ff88ff"),
                                    --     border_color = tcolor.rgb_from_string("#0088ff"),
                                    --     border_width = 1,
                                    --     border_radius = 12,
                                    -- }),
                                    subscribe_on_app = {
                                        ["ModelChanged:model.x"] = function(scope)
                                            local app_data = scope.app_data
                                            local first_el = scope.element
                                            first_el.offset_x = app_data.model.x + 40
                                            eutil.mark_relayout(root_el)
                                            eutil.mark_redraw(first_el)
                                            eutil.mark_redraw(first_el.shadow)
                                        end,
                                        ["ModelChanged:model.y"] = function(scope)
                                            local app_data = scope.app_data
                                            local first_el = scope.element
                                            first_el.offset_y = app_data.model.y + 40
                                            eutil.mark_relayout(root_el)
                                            eutil.mark_redraw(first_el)
                                            eutil.mark_redraw(first_el.shadow)
                                        end
                                    }
                                }),
                                el.new({ -- second_el
                                    offset_x = app_data.model.x,
                                    offset_y = app_data.model.y,
                                    width = 15,
                                    height = 15,
                                    bg = ebg.new({
                                        source = tcolor.rgb_from_string("#8888ff"),
                                        border_radius = 6,
                                        border_width = 1,
                                    }),
                                    subscribe_on_app = {
                                        ["ModelChanged:model.x"] = function(scope)
                                            local app_data = scope.app_data
                                            local second_el = scope.element
                                            second_el.offset_x = app_data.model.x + 80
                                            eutil.mark_relayout(root_el)
                                            eutil.mark_redraw(second_el)
                                        end,
                                        ["ModelChanged:model.y"] = function(scope)
                                            local app_data = scope.app_data
                                            local second_el = scope.element
                                            second_el.offset_y = app_data.model.y + 80
                                            eutil.mark_relayout(root_el)
                                            eutil.mark_redraw(second_el)
                                        end
                                    }
                                })
                            })

                            weeny.add_ween_on_track(app_data.tracklist, 1, weeny.endless(
                                function(elapsed)
                                    return math.sin(elapsed) + 1
                                end,
                                function(result)
                                    app_data.model.x = result * 20
                                    tstation.emit_signal(app_data.station, "ModelChanged:model.x")
                                end
                            ))
                            weeny.add_ween_on_track(app_data.tracklist, 2, weeny.endless(
                                function(elapsed)
                                    return math.cos(elapsed) + 1
                                end,
                                function(result)
                                    app_data.model.y = result * 20
                                    tstation.emit_signal(app_data.station, "ModelChanged:model.y")
                                end
                            ))

                            layout_data[1] = root_el

                        end
                    }
                })
            end
        }
    })
    return app_data
end

return {
    new = new
}

