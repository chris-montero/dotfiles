
local eapplication = require("elemental.application")
local esource = require("elemental.source")
local etitlebar = require("wonderful.titlebar")
local etypes = require("elemental.types")
local eutil = require("elemental.util")
local ebg = require("elemental.elements.bg")
local el = require("elemental.elements.el")
local horizontal = require("elemental.elements.horizontal")
local etext = require("elemental.elements.text")

local m_signals = require("elemental.mouse_signals")
local awful = require("awful")

local tstation = require("tools.station")
local tcolor = require("tools.color")

local global_palette = require("themes.LateForLunch.palette")

local color_button_unfocused = tcolor.hsl(28, 0.80, 0.03)
-- local color_button_focused1 = tcolor.hsl(18, 0.50, 0.60)
-- local color_button_focused2 = tcolor.hsl(16, 0.50, 0.55)
-- local color_button_focused3 = tcolor.hsl(14, 0.50, 0.50)
-- local color_button_focused1 = tcolor.hsl(30, 0.90, 0.60)
-- local color_button_focused2 = tcolor.hsl(30, 0.90, 0.55)
-- local color_button_focused3 = tcolor.hsl(30, 0.90, 0.50)
-- local color_button_focused1 = tcolor.hsl(020, 0.75, 0.35)
-- local color_button_focused2 = tcolor.hsl(020, 0.75, 0.44)
-- local color_button_focused3 = tcolor.hsl(020, 0.75, 0.50)
-- local color_button_focused1 = tcolor.hsl(30, 0.48, 0.62)
-- local color_button_focused2 = tcolor.hsl(29, 0.50, 0.57)
-- local color_button_focused3 = tcolor.hsl(28, 0.52, 0.52)
-- local color_button_focused1 = tcolor.hsl(30, 0.58, 0.67)
-- local color_button_focused2 = tcolor.hsl(29, 0.60, 0.62)
-- local color_button_focused3 = tcolor.hsl(28, 0.62, 0.57)
local color_button_focused1 = tcolor.hsl(30, 0.51, 0.70)
local color_button_focused2 = tcolor.hsl(29, 0.63, 0.65)
local color_button_focused3 = tcolor.hsl(28, 0.65, 0.60)
-- local color_button_focused1 = tcolor.hsl(20, 0.30, 0.30)
-- local color_button_focused2 = tcolor.hsl(19, 0.35, 0.25)
-- local color_button_focused3 = tcolor.hsl(18, 0.40, 0.20)
-- local color_button_focused1 = tcolor.hsl(210, 0.70, 0.30)
-- local color_button_focused2 = tcolor.hsl(210, 0.80, 0.35)
-- local color_button_focused3 = tcolor.hsl(210, 0.90, 0.40)


local function bg_changer(color_focused, color_unfocused)
    return function (scope)
        local layout_data = scope.layout_data
        local elem = scope.element
        local bg = elem.bg
        if layout_data.client == client.focus then
            if bg.source == color_focused then return end
            bg.source = color_focused
            eutil.mark_redraw(bg)
        else
            if bg.source == color_unfocused then return end
            bg.source = color_unfocused
            eutil.mark_redraw(bg)
        end
    end
end

local function _make_titlebar_side(c, app_data, side)

    return etitlebar.new({
        app_data = app_data,
        bg = global_palette.bg,
        side = side,
        size = 1,
        client = c,
        visible = true,
        subscribe_on_layout = {
            Init = function(scope)
                local layout_data = scope.layout_data
                layout_data[1] = el.new({
                    width = etypes.SIZE_FILL,
                    height = etypes.SIZE_FILL,
                    bg = ebg.new({
                        source = tcolor.hsla(0, 0, 1, 0.08)
                    }),
                })
            end
        }
    })
end

local function make_titlebar_left(c, app_data)
    _make_titlebar_side(c, app_data, etitlebar.SIDE_LEFT)
end
local function make_titlebar_right(c, app_data)
    _make_titlebar_side(c, app_data, etitlebar.SIDE_RIGHT)
end

local function make_titlebar_bottom(c, app_data, border_radius)

    return etitlebar.new({
        app_data = app_data,
        bg = global_palette.bg,
        side = etitlebar.SIDE_BOTTOM,
        size = border_radius,
        client = c,
        visible = true,
        subscribe_on_layout = {
            Init = function(scope)
                local layout_data = scope.layout_data
                layout_data[1] = el.new({
                    width = etypes.SIZE_FILL,
                    height = etypes.SIZE_FILL,
                    _draw = function(_, cr, width, height)

                        cr:push_group()
                        local linpat = tcolor.linear_gradient(
                            { x = 0, y = height },
                            { x = 0, y = 0 },
                            {
                                -- esource.stop(
                                --     0.5,
                                --     tcolor.rgba_from_string("#ffffff14")
                                -- ),
                                esource.stop(
                                    0,
                                    -- tcolor.rgba_from_string("#ffffff0c")
                                    tcolor.rgba_from_string("#ffffff0c")
                                ),
                                esource.stop(
                                    0.05,
                                    tcolor.rgba_from_string("#ffffff0c")
                                ),
                                esource.stop(
                                    1,
                                    tcolor.rgba_from_string("#ffffff14")
                                ),
                            }
                        )
                        cr:set_source(esource.to_cairo_source(linpat))
                        cr:paint()
                        local src = cr:pop_group()

                        cr:arc(
                            width - border_radius,
                            0,
                            border_radius,
                            0, (math.pi/2)
                        )
                        cr:line_to(border_radius, height)
                        cr:arc(
                            border_radius,
                            0,
                            border_radius,
                            (math.pi/2),
                            math.pi
                        )
                        cr:set_source(src)
                        cr:stroke()
                    end
                })
            end
        }
    })
end

local function make_titlebar_top(c, app_data, border_radius, mousebindings)

    local bar_height = 46

    return etitlebar.new({
        app_data = app_data,
        -- bg = global_palette.bg,
        side = etitlebar.SIDE_TOP,
        size = bar_height,
        client = c,
        visible = true,
        mousebindings = mousebindings,
        subscribe_on_layout = {
            -- FIXME: this should have function(scope, emitted), but the
            -- scope for some reason is not emitted
            [m_signals.MouseButtonPressed] = function(emitted) 
                local btn = emitted.button_number
                if btn == 1 then -- left click
                    client.focus = c
                    awful.mouse.client.move(c)
                    c:raise()
                elseif btn == 3 then -- right click
                    print("what")
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end
            end,

            Init = function(scope)
                local layout_data = scope.layout_data

                layout_data[1] = horizontal.new({
                    width = etypes.SIZE_FILL,
                    height = etypes.SIZE_FILL,
                    padding = etypes.padding_each({
                        left = 16,
                    }),
                    bg = ebg.new({
                        source = global_palette.bg,
                    }),
                    -- subscribe_on_global = {
                    --     ["ClientFocused"] = function(scope)
                    --         local layout_data = scope.layout_data
                    --         local elem = scope.element
                    --         local bg = elem.bg
                    --         if layout_data.client == client.focus then
                    --             if bg.source == global_palette.bg then return end
                    --             bg.source = global_palette.bg
                    --             eutil.mark_redraw(bg)
                    --         else
                    --             if bg.source == global_palette.bg2 then return end
                    --             bg.source = global_palette.bg2
                    --             eutil.mark_redraw(bg)
                    --         end
                    --     end
                    -- },
                    etext.new({
                        valign = etypes.ALIGN_CENTER,
                        family = "TTCommonsPro",
                        weight = "Medium",
                        size = 10,
                        text = c.name,
                        fg = tcolor.rgb_from_string("#fff8f0"),
                        subscribe_on_layout = {
                            [etitlebar.TitleChanged] = function(scope, emitted)
                                local text_el = scope.element
                                local title = emitted.title
                                etext.set_text(text_el, title)
                                eutil.mark_relayout(text_el._parent)
                                eutil.mark_redraw(text_el._parent)
                            end,
                        }
                    }),

                    horizontal.new({
                        spacing = 13,
                        height = etypes.SIZE_FILL,
                        -- bg = tcolor.rgba_from_string("#ffff0044"),
                        halign = etypes.ALIGN_RIGHT,
                        el.new({
                            valign = etypes.ALIGN_CENTER,
                            -- border_width = 1,
                            -- border_color = tcolor.rgba_from_string("#00000044"),
                            width = 14,
                            height = 14,
                            -- bg = tcolor.rgb_from_string("#c6a178"),
                            bg = ebg.new({
                                -- source = tcolor.hsl(14, 0.75, 0.76),
                                -- source = tcolor.hsl(06, 0.65, 0.70),
                                source = color_button_unfocused,
                                border_radius = 30,
                            }),
                            subscribe_on_global = {
                                ["ClientFocused"] = bg_changer(
                                    color_button_focused1,
                                    color_button_unfocused
                                )
                            }
                        }),
                        el.new({
                            valign = etypes.ALIGN_CENTER,
                            -- border_width = 1,
                            -- border_color = tcolor.rgba_from_string("#00000044"),
                            width = 14,
                            height = 14,
                            -- bg = tcolor.rgb_from_string("#a5815a"),
                            bg = ebg.new({
                                -- source = tcolor.hsl(14, 0.60, 0.65),
                                -- source = tcolor.hsl(06, 0.65, 0.65),
                                -- source = tcolor.hsl(06, 0.65, 0.70),
                                source = color_button_unfocused,
                                border_radius = 30,
                            }),
                            subscribe_on_global = {
                                ["ClientFocused"] = bg_changer(
                                    color_button_focused2,
                                    color_button_unfocused
                                )
                            }
                        }),
                        el.new({
                            padding = etypes.padding_each({right = 16}),
                            valign = etypes.ALIGN_CENTER,
                            el.new({
                                -- border_width = 1,
                                -- border_color = tcolor.rgba_from_string("#00000044"),
                                width = 14,
                                height = 14,
                                -- bg = tcolor.rgb_from_string("#825a4b"),
                                bg = ebg.new({
                                    -- source = tcolor.rgb_from_string("#ae5442"),
                                    -- source = tcolor.hsl(12, 0.75, 0.66),
                                    -- source = tcolor.hsl(06, 0.70, 0.60),
                                    -- source = tcolor.hsl(28, 0.29, 0.46),
                                    source = color_button_unfocused,
                                    border_radius = 30,
                                }),
                                subscribe_on_global = {
                                    ["ClientFocused"] = bg_changer(
                                        color_button_focused3,
                                        color_button_unfocused
                                    )
                                }
                            })
                        }),
                    })
                    -- el.new({
                    --     h
                    -- })
                })

                layout_data[2] = el.new({
                    width = etypes.SIZE_FILL,
                    height = etypes.SIZE_FILL,
                    _draw = function(_, cr, width, height)

                        cr:push_group()

                        local linpat = esource.linear_gradient(
                            { x = 0, y = 0 },
                            { x = 0, y = height },
                            {
                                esource.stop(
                                    0,
                                    tcolor.hsla(0, 0, 1, 0.35)
                                ),
                                esource.stop(
                                    0.05,
                                    tcolor.hsla(0, 0, 1, 0.14)
                                ),
                                esource.stop(
                                    0.5,
                                    tcolor.hsla(0, 0, 1, 0.08)
                                ),
                                esource.stop(
                                    1,
                                    tcolor.hsla(0, 0, 1, 0.08)
                                )
                            }


                            -- {
                            --     esource.stop(
                            --         0,
                            --         tcolor.rgba_from_string("#ff222250")
                            --     ),
                            --     esource.stop(
                            --         0.05,
                            --         tcolor.rgba_from_string("#22ff2230")
                            --     ),
                            --     esource.stop(
                            --         0.5,
                            --         tcolor.rgba_from_string("#2222ff14")
                            --     ),
                            --     esource.stop(
                            --         1,
                            --         tcolor.rgba_from_string("#ffffff14")
                            --     )
                            -- }
                            --

                            -- epic rainbow colors
                            -- {
                            --     esource.stop(
                            --         0.05,
                            --         tcolor.rgba_from_string("#ff2222ff")
                            --     ),
                            --     esource.stop(
                            --         0.5,
                            --         tcolor.rgba_from_string("#22ff22ff")
                            --     ),
                            --     esource.stop(
                            --         1,
                            --         tcolor.rgba_from_string("#2222ffff")
                            --     )
                            -- }
                        )

                        -- cr:set_source(linpat)
                        cr:set_source(esource.to_cairo_source(linpat))
                        -- cr:set_source(esource.to_cairo_source(tcolor.rgb_from_string("#ff88ff")))
                        cr:paint()

                        local src = cr:pop_group()

                        cr:move_to(0, height)
                        cr:line_to(0, border_radius)
                        cr:arc(border_radius, border_radius, border_radius, -math.pi, -(math.pi/2))
                        cr:line_to(width - border_radius, 0)
                        cr:arc(width - border_radius, border_radius, border_radius, -(math.pi/2), 0)
                        cr:line_to(width, height)
                        -- cr:set_source(esource.to_cairo_source(tcolor.rgba_from_string("#000000ff")))
                        -- cr:close_path()
                        cr:set_source(src)
                        cr:stroke()

                        -- cr:set_source(esource.to_cairo_source(tcolor.rgba_from_string("#ffffff30")))
                    end
                })
            end
        }
    })

end

local function new(args)

    local global_station = args.global_station
    local global_model = args.global_model
    local tracklist = args.tracklist
    -- local c = args.client

    -- local titlebar_top = args.titlebar_top
    -- local titlebar_right = args.titlebar_right
    -- local titlebar_bottom = args.titlebar_bottom
    -- local titlebar_left = args.titlebar_left

    return eapplication.new({
        global_station = global_station,
        global_model = global_model,
        tracklist = tracklist,
        model = {},
        subscribe_on_app = {
            -- Init = function(scope)
            --     local app_data = scope.app_data
            --     if titlebar_top ~= nil then
            --         app_data.model.titlebar_top = _make_titlebar_top(c, app_data)
            --     end
            --     -- app_data.model.top_titlebar = _make_titlebar_top(c)
            --     -- app_data.model.left_titlebar = _make_titlebar_side(c)
            --     -- app_data.model.right_titlebar = _make_titlebar_side(c)
            -- end
        }
    })

end


return {
    new = new,
    make_titlebar_top = make_titlebar_top,
    make_titlebar_right = make_titlebar_right,
    make_titlebar_bottom = make_titlebar_bottom,
    make_titlebar_left = make_titlebar_left,
}
