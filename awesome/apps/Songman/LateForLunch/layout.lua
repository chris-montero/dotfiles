
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
local tutil = require("tools.util")

local icons = require("themes.LateForLunch.icons")
local global_palette = require("themes.LateForLunch.palette")


local window_width = 580
local window_height = 165

local window_corner_radius = 12


local color1 = tcolor.hsl(07, 0.87, 0.66)
local color2 = tcolor.hsl(18, 0.87, 0.66)

local this_dir = tutil.current_dir_path()

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
                        esource.stop(0, tcolor.rgba(1, 1, 1, 1.00)),
                        esource.stop(0.01, tcolor.rgba(1, 1, 1, 0.70)),
                        esource.stop(0.98, tcolor.rgba(1, 1, 1, 0.70)),
                        esource.stop(1, tcolor.rgba(1, 1, 1, 0.35)),
                    }
                ),
                border_radius = radius - 2
            }),
        })
    })
end

local function make_inner_content(win_width, win_height)

    local song_status = etext.new({
        text = "Now Playing:",
        halign = etypes.ALIGN_CENTER,
        fg = tcolor.rgb(0.25, 0.25, 0.25),
        family = "TTCommons",
        weight = "Medium",
        size = 11,
    })

    local song_playing = el.new({
        width = etypes.SIZE_FILL,
        etext.new({
            text = "Firewatch Original Soundtrack",
            halign = etypes.ALIGN_CENTER,
            fg = tcolor.rgb(0.1, 0.1, 0.1),
            family = "TTCommons",
            weight = "Regular",
            size = 13,
        })
    })

    local knob_radius = 5

    local seek_bar = horizontal.new({
        width = etypes.SIZE_FILL,
        padding = etypes.padding_axis({ x = 40 }),
        etext.new({
            offset_y = -1,
            offset_x = -3,
            text = "0:37",
            fg = tcolor.rgb(0.1, 0.1, 0.1),
            family = "TTCommons",
            weight = "Medium",
            size = 10,
            letter_spacing = 1,
        }),
        el.new({
            width = etypes.SIZE_FILL,
            el.new({
                offset_y = 1,
                width = etypes.SIZE_FILL,
                vertical.new({
                    valign = etypes.ALIGN_CENTER,
                    width = etypes.SIZE_FILL,
                    padding = etypes.padding_axis({ x = knob_radius }),
                    el.new({
                        width = etypes.SIZE_FILL,
                        height = 1,
                        bg = ebg.new({
                            source = tcolor.rgb(0, 0, 0)
                        })
                    }),
                    el.new({
                        width = etypes.SIZE_FILL,
                        height = 1,
                        bg = ebg.new({
                            source = tcolor.rgb(1, 1, 1)
                        })
                    })
                }),
                el.new({
                    width = knob_radius * 2,
                    height = knob_radius * 2,
                    bg = ebg.new({
                        source = tcolor.rgb(0, 0, 0),
                        -- source = esource.linear_gradient(
                        --     { x = 0, y = 0 },
                        --     { x = knob_radius * 2, y = knob_radius * 2},
                        --     {
                        --         esource.stop(0, tcolor.hsl(04, 0.88, 0.62)),
                        --         esource.stop(1, tcolor.hsl(16, 0.88, 0.62))
                        --     }
                        -- ),
                        border_radius = knob_radius,
                    }),
                }),
                subscribe_on_element = {
                    ["MouseButtonPressed"] = function(scope, emitted)
                        local elem = scope.element
                        local elem_width = elem.geometry.width
                        elem.mouse_down = true
                    end
                },
                subscribe_on_layout = {
                    ["MouseMoved"] = function(scope, emitted)
                        local elem = scope.element
                        local elem_width = elem.geometry.width
                        local adjusted_width = elem_width - (knob_radius * 2)
                        local mouse_x = math.min(adjusted_width, math.max(0, emitted.x - elem.geometry.x - knob_radius))
                        if elem.mouse_down then
                            elem[2].offset_x = mouse_x
                            eutil.mark_relayout(elem)
                            eutil.mark_redraw(elem[2])
                            -- print(emitted.x - elem.geometry.x, emitted.y - elem.geometry.y)
                        end
                    end,
                    ["MouseButtonReleased"] = function(scope, emitted)
                        local elem = scope.element
                        elem.mouse_down = false
                    end
                }
            }),
        }),
        etext.new({
            offset_y = -1,
            offset_x = 5,
            text = "2:51",
            fg = tcolor.rgb(0.1, 0.1, 0.1),
            family = "TTCommons",
            weight = "Medium",
            size = 10,
            letter_spacing = 1,
        }),
    })

    local mouse_button_pressed_handler = function()
        return function(scope, emitted)
            local elem_bg = scope.element.bg
            elem_bg.border_width = 1
            eutil.mark_redraw(elem_bg)
        end
    end

    local mouse_button_released_handler = function()
        return function(scope, emitted)
            local elem_bg = scope.element.bg
            elem_bg.border_width = 0
            eutil.mark_redraw(elem_bg)
        end
    end


    local play_icon = icons.play
    local play_height = 24
    local play_width = icons.get_width_for_height(play_icon, play_height)

    local next_song_icon = icons.next_song
    local icon_height = 14
    local icon_width = icons.get_width_for_height(next_song_icon, icon_height)

    local button_width = 34
    local button_height = 34

    local play_button_size = 40

    local buttons = horizontal.new({
        width = etypes.SIZE_FILL,
        padding = etypes.padding_axis({x = 32}),
            -- bg = ebg.new({
            --     source = tcolor.rgba(0.7, 0, 0, 0.4)
            -- }),
        el.new({
            width = button_width,
            height = button_height,
            halign = etypes.ALIGN_LEFT,
            valign = etypes.ALIGN_CENTER,
            bg = ebg.new({
                border_source = tcolor.rgb(0, 0, 0),
                -- border_width = 1.5,
                border_width = 0,
                border_radius = 5,
            }),
            esvg.new({
                halign = etypes.ALIGN_CENTER,
                valign = etypes.ALIGN_CENTER,
                file = this_dir .. "/assets/repeat.svg",
            }),
            subscribe_on_element = {
                ["MouseButtonPressed"] = mouse_button_pressed_handler()
            },
            subscribe_on_layout = {
                ["MouseButtonReleased"] = mouse_button_released_handler()
            },
        }),
        horizontal.new({
            halign = etypes.ALIGN_CENTER,
            valign = etypes.ALIGN_CENTER,
            spacing = 10,
            el.new({
                width = button_width,
                height = button_height,
                valign = etypes.ALIGN_CENTER,
                bg = ebg.new({
                    border_source = tcolor.rgb(0, 0, 0),
                    border_width = 0,
                    border_radius = 5,
                }),
                el.new({
                    width = math.ceil(icon_width),
                    height = icon_height,
                    halign = etypes.ALIGN_CENTER,
                    valign = etypes.ALIGN_CENTER,
                    _draw = function(self, cr, width, height)
                        cr:translate(width, 0)
                        cr:scale(-width, width)
                        cr:set_source(esource.to_cairo_source(tcolor.rgb(0.1, 0.1, 0.1)))
                        next_song_icon.draw(cr)
                        cr:fill()
                    end
                }),
                subscribe_on_element = {
                    ["MouseButtonPressed"] = mouse_button_pressed_handler()
                },
                subscribe_on_layout = {
                    ["MouseButtonReleased"] = mouse_button_released_handler()
                },
            }),

            el.new({
                width = play_button_size,
                height = play_button_size,
                bg = ebg.new({
                    border_source = tcolor.rgb(0, 0, 0),
                    border_width = 0,
                    border_radius = 5,
                }),
                el.new({
                    offset_x = 2,
                    width = math.ceil(play_width),
                    height = play_height,
                    halign = etypes.ALIGN_CENTER,
                    valign = etypes.ALIGN_CENTER,
                    -- bg = ebg.new({
                    --     source = tcolor.rgba(1, 0, 0, 0.4)
                    -- }),
                    _draw = function(self, cr, width, height)
                        cr:scale(height, height)
                        cr:set_source(esource.to_cairo_source(tcolor.rgb(0.1, 0.1, 0.1)))
                        play_icon.draw(cr)
                        cr:fill()
                    end
                }),
                subscribe_on_element = {
                    ["MouseButtonPressed"] = mouse_button_pressed_handler()
                },
                subscribe_on_layout = {
                    ["MouseButtonReleased"] = mouse_button_released_handler()
                },
            }),
            el.new({
                width = button_width,
                height = button_height,
                valign = etypes.ALIGN_CENTER,
                bg = ebg.new({
                    border_source = tcolor.rgb(0, 0, 0),
                    border_width = 0,
                    border_radius = 5,
                }),
                el.new({
                    width = math.ceil(icon_width),
                    height = icon_height,
                    halign = etypes.ALIGN_CENTER,
                    valign = etypes.ALIGN_CENTER,
                    _draw = function(self, cr, width, height)
                        cr:scale(width, width)
                        cr:set_source(esource.to_cairo_source(tcolor.rgb(0.1, 0.1, 0.1)))
                        next_song_icon.draw(cr)
                        cr:fill()
                    end
                }),
                subscribe_on_element = {
                    ["MouseButtonPressed"] = mouse_button_pressed_handler()
                },
                subscribe_on_layout = {
                    ["MouseButtonReleased"] = mouse_button_released_handler()
                },
            }),
        }),


        el.new({
            width = button_width,
            height = button_height,
            halign = etypes.ALIGN_RIGHT,
            valign = etypes.ALIGN_CENTER,
            bg = ebg.new({
                border_source = tcolor.rgb(0, 0, 0),
                -- border_width = 1.5,
                border_width = 0,
                border_radius = 5,
            }),
            esvg.new({
                halign = etypes.ALIGN_CENTER,
                valign = etypes.ALIGN_CENTER,
                file = this_dir .. "/assets/box.svg",
            }),
            subscribe_on_element = {
                ["MouseButtonPressed"] = mouse_button_pressed_handler()
            },
            subscribe_on_layout = {
                ["MouseButtonReleased"] = mouse_button_released_handler()
            },
        }),
    })

    local controls_bar = vertical.new({
        width = etypes.SIZE_FILL,
        padding = etypes.padding_each({ bottom = 20 }),
        spacing = 5,
        seek_bar,
        buttons,
    })

    local content = el.new({
        height = etypes.SIZE_FILL,
        width = etypes.SIZE_FILL,
        vertical.new({
            offset_y = 7,
            halign = etypes.ALIGN_CENTER,
            valign = etypes.ALIGN_CENTER,
            spacing = 5,
            song_status,
            song_playing,
        }),
    })

    return vertical.new({ -- bg
        width = etypes.SIZE_FILL,
        height = etypes.SIZE_FILL,
        bg = ebg.new({
            source = tcolor.rgb(0.94, 0.93, 0.92)
        }),
        content,
        controls_bar,
    })

end

local function new(args)

    local scr = args.screen

    local x = 20
    local y = global_palette.bar_height + 20

    return elayout.new({
        x = x,
        y = y,
        width = window_width,
        height = window_height,
        screen = scr,
        bg = tcolor.rgba(0, 0, 0, 0),
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
                    make_inner_content(window_width, window_height),
                    make_sick_overlay(window_height, window_corner_radius)
                })
            end
        }
    })

end

return {
    new = new
}
