
local lgi = require("lgi")
local eapplication = require("elemental.application")
local elayout = require("elemental.layout")
local esource = require("elemental.source")
local etypes = require("elemental.types")
local emouse = require("elemental.mouse_signals")
local eutil = require("elemental.util")
local etext = require("elemental.elements.text")

local horizontal = require("elemental.elements.horizontal")
local vertical = require("elemental.elements.vertical")
local el = require("elemental.elements.el")
local ebg = require("elemental.elements.bg")

local tstation = require("tools.station")
local tshape = require("tools.shape")
local tcolor = require("tools.color")
local ttimer = require("tools.timer")
local weeny = require("tools.weeny")
local tprompt = require("tools.prompt")
local keytone_id = require("wonderful.keymap.keytone_id")

local function _map(things, fun)
    local ret = {}
    for _, thing in ipairs(things) do
        table.insert(ret, fun(thing))
    end
    return ret
end

local font_family_1 = "Cera Pro"
local font_size_1 = 10
local font_size_2 = 13

local gray0 = tcolor.rgb_from_string("#020304")
local gray1 = tcolor.rgb_from_string("#101215")
-- local gray1 = tcolor.rgb_from_string("#15391e")
local gray2 = tcolor.rgb_from_string("#181a1e")
local gray3 = tcolor.rgb_from_string("#26292c")
-- local gray3 = tcolor.rgb_from_string("#122410")
local gray4 = tcolor.rgb_from_string("#40454b")
local gray5 = tcolor.rgb_from_string("#808285")
-- local gray5 = tcolor.rgb_from_string("#0a1809")
local gray6 = tcolor.rgb_from_string("#b0b3b6")
local gray7 = tcolor.rgb_from_string("#f2f4f8")
-- local gray6 = tcolor.rgb_from_string("#ffffff")

local size1 = 2
local size2 = 4
local size3 = 8
local size4 = 16
local size5 = 32

local tools_bar_height = 40

local showcase_weights = {
    "Thin",
    "Light",
    "Regular",
    "Medium",
    "Bold",
    "Black",
}


local function make_size_slider(slider_width, knob_size, init_font_size)
    local half_knob_size = knob_size / 2
    return el.new({
        width = slider_width + knob_size,
        height = knob_size,
        valign = etypes.ALIGN_CENTER,
        id = "dumb_text",
        -- bg = tcolor.rgb(0.2, 0.7, 0.6),
        _draw = function(elem, cr, width, height)
            cr:translate(0, 0.5)
            cr:set_line_width(1)
            cr:set_source(esource.to_cairo_source(gray3))
            cr:move_to(half_knob_size, half_knob_size)
            cr:line_to(slider_width + half_knob_size, half_knob_size)
            cr:stroke()
        end,
        el.new({
            -- border_width = 1,
            -- border_color = tcolor.rgb(1, 0, 0),
            id = "dumb_text",
            offset_x = 0,
            offset_y = 0,
            width = knob_size,
            height = knob_size,
            -- bg = tcolor.rgba(1, 0, 0, 0.2),
            bg = ebg.new({
                source = gray2,
                border_radius = 80,
            }),
            subscribe_on_app = {
                ["ModelChanged:model.global_font_size"] = function(scope)
                    local elem = scope.element
                    local model = elem.app_data.model
                    local min_value = model.global_font_size_min
                    local max_value = model.global_font_size_max
                    local current_value = model.global_font_size

                    local perc = ((current_value - min_value) / (max_value - min_value)) * slider_width
                    elem.offset_x = perc
                    eutil.mark_relayout(elem._parent) -- TODO
                    eutil.mark_redraw(elem._parent)
                end
            },
            etext.new({
                offset_x = knob_size,
                offset_y = knob_size,
                id = "dumb_text",
                size = font_size_1,
                -- bg = tcolor.rgba(0.8, 0.1, 0.1, 0.3),
                family = font_family_1,
                weight = "Regular",
                text = tostring(init_font_size) .. "pt",
                fg = gray2,
                subscribe_on_app = {
                    ["ModelChanged:model.global_font_size"] = function(scope)
                        etext.set_text(scope.element, scope.app_data.model.global_font_size .. "pt")
                        eutil.mark_redraw(scope.element)
                    end
                }
            }),

        }),

        subscribe_on_element = {
            [emouse.MouseButtonPressed] = function(scope, _)
                local self = scope.element
                self.mouse_down = true
            end,
        },

        subscribe_on_layout = {
            [emouse.MouseButtonReleased] = function(scope, _)
                local self = scope.element
                self.mouse_down = false
            end,
            [emouse.MouseMoved] = function(scope, emitted)
                local self = scope.element
                local el_relative_x = emitted.x - self.geometry.x
                local app_data = scope.app_data
                local model = app_data.model
                if self.mouse_down ~= true then
                    return
                end

                local min_value = model.global_font_size_min
                local max_value = model.global_font_size_max
                local shifted_x = math.min(math.max(el_relative_x - half_knob_size, 0), slider_width)
                local what_percent = shifted_x / slider_width

                local new_font_size = math.floor((what_percent * (max_value - min_value)) + min_value)
                model.global_font_size = new_font_size
                tstation.emit_signal(app_data.station, "ModelChanged:model.global_font_size")

            end,
        }

    })
end

-- local function make_size_slider(slider_width, knob_size)

--     local half_knob_size = knob_size / 2
--     return el.new({
--         valign = etypes.ALIGN_CENTER,
--         width = slider_width + knob_size,
--         height = knob_size,
--         dont_clip_children = true,
--         knob_font_description = lgi.Pango.FontDescription.from_string("Cera Pro Regular 9"),

--         -- bg = tcolor.rgba_from_string("#28ff8f77"),
--         -- bg = tcolor.rgb_from_string("#000000"),
--         _draw = function(elem, cr, width, height)

--             local model = elem.app_data.model
--             local min_value = model.global_font_size_min
--             local max_value = model.global_font_size_max
--             local current_value = model.global_font_size

--             local perc = ((current_value - min_value) / (max_value - min_value)) * slider_width

--             cr:translate(0, 0.5) -- translate 0.5 so lines will be exactly 1px thick

--             cr:set_line_width(1)
--             cr:set_source(esource.to_cairo_source(gray3))
--             cr:move_to(half_knob_size, half_knob_size)
--             cr:line_to(slider_width + half_knob_size, half_knob_size)
--             cr:stroke()

--             cr:set_source(esource.to_cairo_source(gray2))
--             tshape.circle(cr, half_knob_size + perc, half_knob_size, half_knob_size-0.5)
--             cr:fill()

--             -- local ctx = lgi.PangoCairo.font_map_get_default():create_context()
--             -- local layout = lgi.Pango.Layout.new(ctx)

--             cr:set_source(esource.to_cairo_source(gray2))
--             local layout = lgi.PangoCairo.create_layout(cr)
--             layout:set_font_description(elem.knob_font_description)
--             layout.text = tostring(current_value) .. "pt"
--             cr:move_to(half_knob_size + perc + 8, half_knob_size + 8)
--             -- cr:update_layout(layout)
--             cr:show_layout(layout)
--         end,

--         subscribe_on_element = {
--             [emouse.MouseButtonPressed] = function(scope, _)
--                 local self = scope.element
--                 self.mouse_down = true
--             end,
--         },
--         subscribe_on_layout = {
--             [emouse.MouseButtonReleased] = function(scope, _)
--                 local self = scope.element
--                 self.mouse_down = false
--             end,
--             [emouse.MouseMoved] = function(scope, emitted)
--                 local self = scope.element
--                 local el_relative_x = emitted.x - self.geometry.x
--                 local app_data = scope.app_data
--                 local model = app_data.model
--                 if self.mouse_down ~= true then
--                     return
--                 end

--                 local min_value = model.global_font_size_min
--                 local max_value = model.global_font_size_max
--                 local shifted_x = math.min(math.max(el_relative_x - half_knob_size, 0), slider_width)
--                 local what_percent = shifted_x / slider_width

--                 local new_font_size = math.floor((what_percent * (max_value - min_value)) + min_value)
--                 model.global_font_size = new_font_size
--                 eutil.mark_relayout(self._parent) -- TODO
--                 tstation.emit_signal(app_data.station, "ModelChanged:model.global_font_size")

--             end,
--         }
--     })
-- end

local function make_toolbar_description_text(txt)
    return etext.new({
        -- bg = tcolor.rgba(0.8, 0.1, 0.1, 0.5),
        halign = etypes.ALIGN_RIGHT,
        family = font_family_1,
        weight = "Regular",
        size = font_size_1,
        fg = gray0,
        text = txt,
    })
end

local function make_size_element(width, height, init_font_size)
    return vertical.new({
        -- bg = tcolor.rgba(0.2, 0.8, 0.8, 0.5),
        -- dont_clip_children = true,
        -- shadow = {
        --     color = tcolor.rgba(0, 0, 0, 0.1),
        --     edge_width = 30,
        --     draw_outside = true,
        --     scale = 0.8,
        -- },
        height = etypes.SIZE_FILL,
        make_toolbar_description_text("Size:"),
        make_size_slider(width, height, init_font_size),
    })
end

local function make_text_input_box(args)

    local app_data = args.app_data

    local function _new_caret_timer(elem)
        return ttimer.new(0.5, function()
            if elem.opacity == 0 then
                elem.opacity = 1
            else
                elem.opacity = 0
            end
            eutil.mark_relayout(elem._parent)
            eutil.mark_redraw(elem._parent)
            return true
        end, { priority = ttimer.PRIORITY_LOW })
    end

    local function _restart_caret_timer(caret_el)
        caret_el.opacity = 1
        if caret_el.caret_timer == nil then
            caret_el.caret_timer = _new_caret_timer(caret_el)
        end
        ttimer.stop(caret_el.caret_timer)
        ttimer.start(caret_el.caret_timer)
    end

    local function _stop_caret_timer(caret_el)
        caret_el.opacity = 0
        if caret_el.caret_timer == nil then return end
        ttimer.stop(caret_el.caret_timer)
        eutil.mark_relayout(caret_el._parent)
        eutil.mark_redraw(caret_el._parent)

    end

    local function new_input_box()

        return el.new({
            halign = etypes.ALIGN_RIGHT,
            valign = etypes.ALIGN_CENTER,
            width = etypes.SIZE_FILL,
            etext.new({
                subscribe_on_element = {
                    [emouse.MouseButtonPressed] = function(scope, _)
                        local elem = scope.element

                        local caret_el = elem._parent[2]
                        local caret_geom = etext.get_caret_geometry(elem, app_data.model.sample_text_data.caret_pos)

                        caret_el.offset_x = caret_geom.x
                        caret_el.width = math.max(caret_geom.width, 2) -- make sure the caret shows up
                        caret_el.height = caret_geom.height

                        _restart_caret_timer(caret_el)
                        eutil.mark_relayout(elem._parent)
                        eutil.mark_redraw(elem._parent)

                        if app_data.model.keygrabber_running == true then
                            return
                        end

                        app_data.model.keygrabber_running = true
                        keygrabber.run(function(mods, key, evt)
                            tprompt.act(
                                app_data.model.sample_text_data,
                                keytone_id.new(mods, key, evt),
                                function()
                                    app_data.model.keygrabber_running = false
                                    _stop_caret_timer(caret_el)
                                end,
                                function()
                                    tstation.emit_signal(app_data.station, "SampleTextChanged")
                                end
                            )
                        end)
                    end,
                },
                subscribe_on_app = {
                    ["SampleTextChanged"] = function(scope,_)
                        local elem = scope.element
                        local caret_el = elem._parent[2]

                        -- TODO: VERY UGLY. Maybe switch this to working with IDs
                        local showcase_parent = elem._parent._parent._parent._parent._parent._parent._parent[2]
                        for _, text_showcase in ipairs(showcase_parent) do
                            print("text_showcase")
                            etext.set_text(text_showcase[1][1], table.concat(app_data.model.sample_text_data.text))
                        end
                        eutil.mark_relayout(showcase_parent)
                        eutil.mark_redraw(showcase_parent)

                        etext.set_text(elem, table.concat(app_data.model.sample_text_data.text))

                        local caret_geom = etext.get_caret_geometry(elem, app_data.model.sample_text_data.caret_pos)
                        caret_el.offset_x = caret_geom.x
                        caret_el.width = math.max(caret_geom.width, 2) -- make sure the caret shows up
                        caret_el.height = caret_geom.height

                        _restart_caret_timer(caret_el)
                        eutil.mark_relayout(elem._parent)
                        eutil.mark_redraw(elem._parent)
                    end,
                },
                -- halign = etypes.ALIGN_RIGHT,
                family = font_family_1,
                -- weight = "Regular Italic",
                weight = "Regular",
                size = font_size_2,
                text = table.concat(app_data.model.sample_text_data.text),
                fg = gray0,
            }),
            el.new({
                width = 0,
                height = 0,
                _draw = function(_, cr, width, height)
                    cr:set_source(esource.to_cairo_source(gray0))
                    cr:set_line_width(2)
                    cr:move_to(0, height)
                    if width <= 2 then -- not italic
                        cr:line_to(0, 0)
                    else -- italic text
                        cr:line_to(width, 0)
                    end
                    cr:stroke()
                end
            })
        })
    end

    return vertical.new({
        height = etypes.SIZE_FILL,
        make_toolbar_description_text("Sample text:"),
        padding = etypes.padding_each({ bottom = 10 }),
        el.new({
            width = 400,
            height = etypes.SIZE_FILL,
            _draw = function(self, cr, width, height)
                cr:set_line_width(2)
                cr:set_source(esource.to_cairo_source(gray0))
                cr:set_dash({2, 6}, 2, 0)
                cr:move_to(0, height - 1)
                cr:line_to(width, height - 1)
                cr:stroke()
            end,
            new_input_box(),
        })
    })
end

local function make_tools_bar(args)

    return horizontal.new({
        height = 60,
        halign = etypes.ALIGN_RIGHT,
        -- bg = tcolor.rgb_from_string("#383a3e"),
        -- width = etypes.SIZE_FILL,
        -- spacing = 10,
        -- padding = etypes.padding_each({bottom = 15}),
        make_size_element(240, 18, args.app_data.model.global_font_size),
        make_text_input_box(args),
    })

end

local function make_text_showcase(family)
    return function(size, sample_text)
        return function(weight)
            return vertical.new({
                id = "vertical_bug",
                width = etypes.SIZE_FILL,
                el.new({
                    -- border_width = 2,
                    id = "el_vertical_bug",
                    padding = etypes.padding_each({top = 20, bottom = 20}),
                    etext.new({
                        id = "showcase",
                        subscribe_on_app = {
                            ["ModelChanged:model.global_font_size"] = function(scope, _)
                                local app_data = scope.app_data
                                local self = scope.element
                                -- local text_el = c[1][1]
                                etext.set_size(self, app_data.model.global_font_size)
                                eutil.mark_relayout(self._parent._parent._parent)
                                eutil.mark_redraw(self._parent._parent._parent)
                            end
                        },
                        family = family .. " Italic ",
                        -- family = family,
                        weight = weight,
                        size = size,
                        text = table.concat(sample_text),
                        fg = gray0,
                    })
                }),
                el.new({
                    width = etypes.SIZE_FILL,
                    height = 1,
                    bg = ebg.new({
                        source = tcolor.rgba(0, 0, 0, 0.10),
                    }),
                }),
                el.new({
                    width = etypes.SIZE_FILL,
                    height = 1,
                    bg = ebg.new({
                        source = gray6,
                    })
                }),
                el.new({
                    width = etypes.SIZE_FILL,
                    height = 1,
                    bg = ebg.new({
                        source = tcolor.rgb(1, 1, 1),
                    }),
                }),
            })
        end
    end
end

local cera_pro_text_showcase = make_text_showcase("Cera Pro")

local function make_head(args)

    local app_data = args.app_data

    return el.new({
        padding = etypes.padding_each({ left = 100, right = 100, top = 82 }),
        width = etypes.SIZE_FILL,
        -- height = etypes.SIZE_FILL,
        -- bg = tcolor.rgb_from_string("#153316"),
        horizontal.new({
            width = etypes.SIZE_FILL,
            -- bg = tcolor.rgb_from_string("#202020"),
            el.new({
                -- width = etypes.SIZE_FILL,
                padding = etypes.padding_each({bottom = 10, right = 16}),
                -- bg = tcolor.rgb_from_string("#223388"),
                etext.new({
                    -- bg = tcolor.rgb_from_string("#1f6f28"),
                    -- bg = tcolor.rgb_from_string("#283888"),
                    -- bg = tcolor.rgb_from_string("#283888"),
                    bg = tcolor.rgb_from_string("#ff38e8"),
                    padding = etypes.padding_each({top = 5}),
                    letter_spacing = 2,
                    family = font_family_1,
                    weight = "Bold",
                    size = size5,
                    fg = gray0,
                    text = "Cera Pro",
                }),
            }),
            make_tools_bar({app_data = app_data}),
        }),
    })
end

local function make_showcase(args)
    local app_data = args.app_data
    return
        vertical.new({
            padding = etypes.padding_each({ left = 100, right = 100 }),
            width = etypes.SIZE_FILL,
            height = etypes.SIZE_FILL,
            unpack(
                _map(
                    showcase_weights,
                    cera_pro_text_showcase(
                        app_data.model.global_font_size,
                        app_data.model.sample_text_data.text
                    )
                )
            ),
        })
end

local function new(args)

    local layout_width = 1600
    local layout_height = 900

    -- local layout_width = 800
    -- local layout_height = 450
    local x = (screen.primary.geometry.width - layout_width) / 2
    local y = (screen.primary.geometry.height - layout_height) / 2

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
                    shape = function(cr, width, height)
                        tshape.rounded_rectangle(cr, width, height, 10)
                    end,
                    x = x,
                    y = y,
                    width = layout_width,
                    height = layout_height,
                    visible = true,
                    screen = screen.primary,
                    bg = gray7,
                    subscribe_on_layout = {
                        Init = function(scope)
                            local layout_data = scope.layout_data
                            layout_data[1] = el.new({
                                width = etypes.SIZE_FILL,
                                height = etypes.SIZE_FILL,
                                -- _draw = function(_, cr, _, _)
                                --     local img = lgi.cairo.ImageSurface.create_from_png("~/Downloads/groovepaper.png")
                                --     local patt = lgi.cairo.Pattern.create_for_surface(img)
                                --     patt.extend = lgi.cairo.Extend.REPEAT
                                --     cr:set_source(patt)
                                --     cr:paint()
                                -- end
                            })
                            layout_data[2] = vertical.new({
                                width = etypes.SIZE_FILL,
                                height = etypes.SIZE_FILL,
                                make_head({app_data = app_data}),
                                make_showcase({app_data = app_data})
                            })
                            layout_data[3] = el.new({
                                width = etypes.SIZE_FILL,
                                height = etypes.SIZE_FILL,
                                _draw = function(elem, cr, width, height)
                                    cr:set_line_width(1)
                                    -- translate so that the stroked line is drawn on 
                                    -- one pixel, otherwise the color gets "smeared"
                                    -- over two pixels
                                    cr:translate(0.5, 0.5)
                                    tshape.rounded_rectangle(cr, width-1, height-1, 9)
                                    cr:set_source(esource.to_cairo_source(tcolor.rgb_from_string("#080a0c")))
                                    cr:stroke()

                                    cr:translate(1, 1)
                                    tshape.rounded_rectangle(cr, width-3, height-3, 9)
                                    cr:set_source(esource.to_cairo_source(tcolor.rgb_from_string("#ffffff")))
                                    cr:stroke()
                                end
                            })
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
