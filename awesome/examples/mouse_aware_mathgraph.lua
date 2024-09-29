
local application = require("elemental.application")
local elayout = require("elemental.layout")
local esource = require("elemental.source")
local etypes = require("elemental.types")
local eutil = require("elemental.util")
local ebg = require("elemental.elements.bg")
local el = require("elemental.elements.el")
local etext = require("elemental.elements.text")
-- local vertical = require("elemental.elements.vertical")
local horizontal = require("elemental.elements.horizontal")
local m_signals = require("elemental.mouse_signals")
local mathgraph = require("widgets.mathgraph")

local tstation = require("tools.station")
local tcolor = require("tools.color")
local tshape = require("tools.shape")
local tsf = require("tools.shaping_functions")
local tweeny = require("tools.weeny")
local global_palette = require("themes.LateForLunch.palette")

local function round_to_thousanths(num)
    local factor = 1000
    local floored_factored_num, _ = math.modf(num * factor)
    return floored_factored_num / factor
end

local function make_content(app_data)


    local base_scale_x = 1.2
    local base_scale_y = 2.0

    local min_scale_x = base_scale_x / 8
    local min_scale_y = base_scale_y / 8

    local max_scale_x = base_scale_x * 100
    local max_scale_y = base_scale_y * 100

    return el.new({
        width = etypes.SIZE_FILL,
        height = etypes.SIZE_FILL,
        mathgraph.new({
            id = "MATHGRAPH",
            plane_offset_x = app_data.model.plane_offset,
            -- graph_function = function(x) return tsf.exponential_ease(x, 0.1) end,
            graph_function = function(x) return math.sin(x) end,
            -- graph_function = function(x) return math.log(x) end,
            origin_offset_x = -200,
            origin_offset_y = 100,
            -- graph_function = function(x) return math.log(x) end,
            -- graph_function = function(x) return math.exp(x) end,
            -- graph_function = function(x) return math.tan(x) end,
            -- graph_function = function(x) return math.cos(x) end,
            -- graph_function = function(x)
            --     x = x / 2
            --     if x % 2 > 1 then
            --         return - (x % 2) + 2
            --     else
            --         return x % 2
            --     end
            -- end,
            width = etypes.SIZE_FILL,
            height = etypes.SIZE_FILL,
            -- x_axis_color = tcolor.rgb_from_string("#ff99a0"),
            -- y_axis_color = tcolor.rgb_from_string("#ff99a0"),
            -- small_knob_color = tcolor.rgb_from_string("#ff99a0"),
            x_axis_color = tcolor.hsl(120, 0.4, 0.16),
            y_axis_color = tcolor.hsl(120, 0.4, 0.16),
            small_knob_color = tcolor.hsl(120, 0.4, 0.16),
            -- text_color = tcolor.rgb_from_string("#080600")
            text_color = tcolor.rgb_from_string("#ffffff"),
            font_family = "Cera Pro",
            scale_x = base_scale_x,
            scale_y = base_scale_y,
            font_size = 9,
            px_per_step_x = 25,
            px_per_step_y = 25,
            detail_level = 0.5,
            subscribe_on_element = {
                [m_signals.MouseButtonPressed] = function(scope, emitted_data)
                    local app_data = scope.app_data
                    local tracklist = app_data.tracklist
                    local element = scope.element
                    local mouse_x = emitted_data.x

                    local zoom_amt_x = 0.5 * element.scale_x
                    local zoom_amt_y = 0.5 * element.scale_y

                    if emitted_data.button_number == 1 then
                        app_data.model.graph_mouse_down = true
                        app_data.model.previous_plane_offset = app_data.model.plane_offset
                        app_data.model.graph_mouse_down_x = mouse_x
                    elseif emitted_data.button_number == 4 then

                        local current_scale_x = element.scale_x
                        local current_scale_y = element.scale_y
                        tweeny.add_ween_at_elapsed(tracklist, "zoom_x",
                            tweeny.normalized(0.12,
                                function(elapsed)
                                    return tsf.exponential_ease(elapsed, 0.12)
                                end,
                                function(result)
                                    element.scale_x = math.min(max_scale_x, current_scale_x + (result * zoom_amt_x))
                                    element.scale_y = math.min(max_scale_y, current_scale_y + (result * zoom_amt_y))
                                    eutil.mark_redraw(element)
                                end
                            )
                        )
                    elseif emitted_data.button_number == 5 then

                        -- print(element.scale_x, element.scale_y)
                        -- print(element.scale_x, min_scale_x)
                        -- print(math.max(min_scale_x, element.scale_x - zoom_amt_x),
                        --     math.max(min_scale_y, element.scale_y - zoom_amt_y)
                        -- )
                        local current_scale_x = element.scale_x
                        local current_scale_y = element.scale_y
                        tweeny.add_ween_at_elapsed(tracklist, "zoom_x",
                            tweeny.normalized(0.12,
                                function(elapsed)
                                    return tsf.exponential_ease(elapsed, 0.12)
                                end,
                                function(result)
                                    -- print(element.scale_x - (result * zoom_amt_x))
                                    element.scale_x = math.max(min_scale_x, current_scale_x - (result * zoom_amt_x))
                                    element.scale_y = math.max(min_scale_y, current_scale_y - (result * zoom_amt_y))
                                    eutil.mark_redraw(element)
                                end
                            )
                        )
                        eutil.mark_redraw(element)
                    end
                end,
                [m_signals.MouseMoved] = function(scope, emitted_data)
                    local app_data = scope.app_data
                    local mouse_x = emitted_data.x
                    local element = scope.element
                    if app_data.model.graph_mouse_down == true then
                        app_data.model.plane_offset = app_data.model.previous_plane_offset + (mouse_x - app_data.model.graph_mouse_down_x)
                        tstation.emit_signal(app_data.station, "ModelChanged:model.plane_offset")
                    else
                        app_data.model.mouse_result = round_to_thousanths(mathgraph.get_value_by_x(element, mouse_x))
                        -- app_data.model.result_y_value = mathgraph.get_y_by_x(element, mouse_x)
                        tstation.emit_signal(app_data.station, "MouseResultChanged")
                        -- tstation.emit_signal(app_data.station, "ResultYValueChanged", {x = mouse_x})
                    end
                end,
            },
            subscribe_on_layout = {
                [m_signals.MouseButtonReleased] = function(scope, emitted_data)
                    local app_data = scope.app_data
                    local mouse_x = emitted_data.x
                    if app_data.model.graph_mouse_down == true then
                        app_data.model.graph_mouse_down = false
                        -- we don't set the plane offset when we release the mouse
                        -- because this seems to be applied with a very small offset
                        -- when you release the mouse button
                        tstation.emit_signal(app_data.station, "ModelChanged:model.plane_offset")
                    end
                end,
            },
            subscribe_on_app = {
                ["ModelChanged:model.plane_offset"] = function(scope)
                    local app_data = scope.app_data
                    local m_graph = scope.element
                    m_graph.plane_offset_x = app_data.model.plane_offset
                    eutil.mark_redraw(m_graph)
                end
            }
        }),
        el.new({
            halign = etypes.ALIGN_LEFT,
            valign = etypes.ALIGN_TOP,
            padding = etypes.padding_each({top = 25, left = 25}),
            etext.new({
                -- family = "Helvetica LT Std UltCompressed",
                family = "Bebas Neue",
                -- family = "Gilroy-Bold",
                -- family = "Venti CF",
                weight = "Bold",
                size = 26,
                fg = tcolor.hsl(120, 0.4, 0.16),
                text = "0",
                subscribe_on_app = {
                    ["MouseResultChanged"] = function(scope, emitted)
                        local elem = scope.element
                        local app_data = scope.app_data
                        etext.set_text(elem, app_data.model.mouse_result)
                        eutil.mark_relayout(elem._parent)
                        eutil.mark_redraw(elem)
                    end
                }
            }),
        }),
        el.new({
            offset_x = -1,
            width = 1,
            height = etypes.SIZE_FILL,
            _draw = function(_, cr, width, height)
                local progress = 2
                local step = 4
                local should_color = true
                while progress < height do
                    if should_color then
                        cr:rectangle(0, progress, width, step)
                    end
                    should_color = not should_color
                    progress = progress + step
                end
                cr:set_source(esource.to_cairo_source(tcolor.hsl(120, 0.4, 0.10)))
                cr:fill()
            end,
            subscribe_on_layout = {
                [m_signals.MouseMoved] = function(scope, emitted)
                    local elem = scope.element
                    elem.offset_x = emitted.x - 1
                    eutil.mark_relayout(elem._parent)
                    eutil.mark_redraw(elem)
                end
            }
        }),
        -- el.new({
        --     offset_y = -1,
        --     width = etypes.SIZE_FILL,
        --     height = 1,
        --     _draw = function(_, cr, width, height)
        --         cr:rectangle(0, 0, width, height)
        --         cr:set_source(esource.to_cairo_source(tcolor.hsl(120, 0.4, 0.16)))
        --         cr:fill()
        --     end,
        --     subscribe_on_app = {
        --         ["ResultYValueChanged"] = function(scope, emitted)
        --             local elem = scope.element
        --             local app_data = scope.app_data
        --             elem.offset_y = app_data.model.result_y_value
        --             eutil.mark_relayout(elem._parent)
        --             eutil.mark_redraw(elem)
        --         end
        --     }
        -- }),

        el.new({
            offset_x = -10, -- dont show the dot before the mouse moves
            width = 6,
            height = 6,
            bg = ebg.new({
                border_radius = 99,
                source = tcolor.hsl(120, 0.1, 0.02)
            }),
            subscribe_on_layout = {
                -- ["ResultYValueChanged"] = function(scope, emitted)
                [m_signals.MouseMoved] = function(scope, emitted)
                    local elem = scope.element
                    local mathgraph_instance = elem._parent[1]
                    local mouse_x = emitted.x
                    local result_y_value = mathgraph.get_y_by_x(mathgraph_instance, mouse_x)
                    -- local result_y_value = app_data.model.result_y_value or 0
                    elem.offset_x = mouse_x - 3.0
                    elem.offset_y = result_y_value - 2.0
                    eutil.mark_relayout(elem._parent)
                    eutil.mark_redraw(elem)
                end
            }
        }),
    })


end

local function new(args)
    local app = application.new({
        model = args.model,
        global_station = args.global_station,
        global_model = args.global_model,
        tracklist = args.tracklist,
        subscribe_on_app = {
            Init = function(scope)
                local app_data = scope.app_data
                app_data.model.layout = elayout.new({
                    -- type = "dock",
                    -- border_radius = global_palette.border_radius,
                    app_data = app_data,
                    x = 394,
                    y = 287,
                    width = 700,
                    height = 420,
                    screen = screen.primary,
                    bg = tcolor.rgba_from_string("#00000000"),
                    shape = function(cr, width, height)
                        tshape.rounded_rectangle(cr, width, height, global_palette.border_radius)
                    end,
                    visible = true,
                    subscribe_on_layout = {
                        Init = function(scope)
                            local app_data = scope.app_data
                            local layout_data = scope.layout_data
                            layout_data[1] = el.new({
                                width = etypes.SIZE_FILL,
                                height = etypes.SIZE_FILL,
                                bg = ebg.new({
                                    source = tcolor.rgb_from_string("#22884e"),
                                    border_width = 1,
                                    border_source = tcolor.rgb_from_string("#121212"),
                                    border_radius = 11,
                                }),
                                make_content(app_data),
                                el.new({
                                    width = etypes.SIZE_FILL,
                                    height = etypes.SIZE_FILL,
                                    _draw = function(elem, cr, width, height)
                                        cr:set_line_width(1)
                                        cr:translate(0.5, 0.5)
                                        tshape.rounded_rectangle(cr, width-1, height-1, 11)
                                        cr:set_source(esource.to_cairo_source(tcolor.rgba_from_string("#ffffff55")))
                                        cr:stroke()
                                    end
                                }),
                                el.new({
                                    mouse_input_stop = {
                                        [m_signals.MouseButtonPressed] = true
                                    },
                                    subscribe_on_element = {
                                        [m_signals.MouseButtonPressed] = function(scope, emitted)
                                            local app_data = scope.app_data
                                            if app_data.model.titlebar_mouse_down ~= true then
                                                app_data.model.titlebar_mouse_down = true
                                                app_data.model.titlebar_mouse_down_x = emitted.x
                                                app_data.model.titlebar_mouse_down_y = emitted.y
                                            end
                                        end,
                                    },
                                    subscribe_on_layout = {
                                        -- [m_signals.MouseButtonPressed] = function(scope, emitted)
                                        --     local layout_data = scope.layout_data
                                        --     awful.mouse.client.move(layout_data.window)
                                        -- end,

                                        -- [m_signals.MouseMoved] = function(scope, emitted)
                                            -- -- print("MOUSE MOVED")
                                            -- if app_data.model.titlebar_mouse_down == true then

                                            --     local x = layout_data.x + (emitted.x - app_data.model.titlebar_mouse_down_x)
                                            --     local y = layout_data.y + (emitted.y - app_data.model.titlebar_mouse_down_y)
                                            --     layout_data.x = x
                                            --     layout_data.y = y
                                            -- end
                                        -- end,
                                        [m_signals.MouseButtonReleased] = function(scope, emitted)
                                            if app_data.model.titlebar_mouse_down == true then
                                                app_data.model.titlebar_mouse_down = false
                                            end
                                        end
                                    },
                                    width = etypes.SIZE_FILL,
                                    height = 50,
                                    -- bg = tcolor.rgba_from_string("#88ff8877"),
                                    horizontal.new({
                                        height = etypes.SIZE_FILL,
                                        -- bg = tcolor.rgba_from_string("#ffff0044"),
                                        halign = etypes.ALIGN_RIGHT,
                                        spacing = 12,
                                        el.new({
                                            valign = etypes.ALIGN_CENTER,
                                            width = 12,
                                            height = 12,
                                            bg = ebg.new({
                                                source = tcolor.rgb_from_string("#28a850"),
                                                border_width = 1,
                                                border_radius = 15,
                                                border_source = tcolor.rgba_from_string("#00000044"),
                                            }),
                                        }),
                                        el.new({
                                            valign = etypes.ALIGN_CENTER,
                                            width = 12,
                                            height = 12,
                                            bg = ebg.new({
                                                source = tcolor.rgb_from_string("#50cc66"),
                                                border_width = 1,
                                                border_radius = 15,
                                                border_source = tcolor.rgba_from_string("#00000044"),
                                            })
                                        }),
                                        el.new({
                                            padding = etypes.padding_each({right = 16}),
                                            valign = etypes.ALIGN_CENTER,
                                            el.new({
                                                width = 12,
                                                height = 12,
                                                bg = ebg.new({
                                                    source = tcolor.rgb_from_string("#62d077"),
                                                    border_width = 1,
                                                    border_source = tcolor.rgba_from_string("#00000044"),
                                                    border_radius = 15,
                                                }),
                                            })
                                        }),
                                    })
                                })
                            })
                        end
                    }
                })
            end
        }
    })
    return app
end


return {
    new = new
}
