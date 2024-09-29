
local elayout = require("elemental.layout")
local esource = require("elemental.source")
local etypes = require("elemental.types")
local etext = require("elemental.elements.text")
local eutil = require("elemental.util")

local horizontal = require("elemental.elements.horizontal")
local el = require("elemental.elements.el")
local ebg = require("elemental.elements.bg")
-- local eshadow = require("elemental.elements.shadow")
local esvg = require("elemental.elements.svg")

local tcolor = require("tools.color")
local tutil = require("tools.util")

local icons = require("themes.LateForLunch.icons")
local global_palette = require("themes.LateForLunch.palette")
-- local vertical = require("elemental.elements.vertical")
-- local tstation = require("tools.station")
-- local m_signals = require("elemental.mouse_signals")

local unselected_dot_rad = 2
local selected_dot_rad = 6

local padding_bottom = 8

local this_dir = tutil.current_dir_path()
print("this_dir: ", this_dir)

-- local right_side_color = tcolor.hsl(210, 0.12, 0.12)
local right_side_color = tcolor.hsl(18, 0.17, 0.11)
-- local right_side_color = tcolor.hsl(194, 0.67, 0.16)

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

local function _make_left_buttons(args)

    local musical_note_icon = icons.musical_note
    local musical_note_height = 28
    -- local musical_note_width = 32
    local musical_note_width = math.ceil(icons.get_width_for_height(musical_note_icon, musical_note_height))

    return horizontal.new({
        -- width = 
        height = etypes.SIZE_FILL,
        padding = etypes.padding_each({left = 30}),
        offset_y = -1,
        el.new({
            padding = etypes.padding_each({bottom = padding_bottom, right = 12}),
            -- halign = etypes.ALIGN_RIGHT,
            valign = etypes.ALIGN_BOTTOM,
            el.new({
                width = musical_note_width,
                height = musical_note_height,
                _draw = function(self, cr, width, height)

                    cr:scale(musical_note_height, musical_note_height)
                    musical_note_icon.draw(cr)
                    -- cr:set_source(esource.to_cairo_source(tcolor.rgb(0.12, 0.11, 0.15)))
                    cr:set_source(esource.to_cairo_source(tcolor.rgb(1, 1, 1)))
                    -- cr:set_source(esource.to_cairo_source(tcolor.hsl(195, 0.88, 0.34)))
                    cr:fill()
                end,
            }),
        }),
        el.new({
            offset_y = -4,
            bg = ebg.new({
                -- source = tcolor.rgba(0, 0, 0, 0.4),
                border_radius = 4,
            }),
            width = 44,
            height = 36,
            valign = etypes.ALIGN_BOTTOM,
            esvg.new({
                halign = etypes.ALIGN_CENTER,
                valign = etypes.ALIGN_CENTER,
                height = 18,
                source = tcolor.rgb(1, 1, 1),
                file = this_dir .. "/assets/cloud.svg",
            }),
            subscribe_on_global = {
                ["EventWeatherShown"] = function(scope)
                    local elem = scope.element
                    local icon = elem[1]
                    icon.source = esource.linear_gradient(
                        { x = 0, y = 0 },
                        { x = 0, y = icon.geometry.height },
                        {
                            esource.stop(0.1, tcolor.hsl(210, 0.80, 0.6)),
                        }
                    )
                    elem.bg.source = tcolor.rgba(0, 0, 0, 0.4)
                    eutil.mark_redraw(elem)
                end,
                ["EventWeatherHidden"] = function(scope)
                    local elem = scope.element
                    local icon = elem[1]
                    icon.source = tcolor.rgb(1, 1, 1)
                    elem.bg.source = nil
                    eutil.mark_redraw(elem)
                end,
            },
        }),
        el.new({
            offset_y = -4,
            bg = ebg.new({
                -- source = tcolor.rgba(0, 0, 0, 0.4),
                border_radius = 4,
            }),
            width = 44,
            height = 36,
            valign = etypes.ALIGN_BOTTOM,
            esvg.new({
                halign = etypes.ALIGN_CENTER,
                valign = etypes.ALIGN_CENTER,
                height = 18,
                source = tcolor.rgb(1, 1, 1),
                file = this_dir .. "/assets/calendar-days.svg"
            })
        }),
        el.new({
            offset_y = -4,
            offset_x = 1,
            bg = ebg.new({
                -- source = tcolor.rgba(0, 0, 0, 0.4),
                border_radius = 4,
            }),
            width = 44,
            height = 36,
            valign = etypes.ALIGN_BOTTOM,
            esvg.new({
                halign = etypes.ALIGN_CENTER,
                valign = etypes.ALIGN_CENTER,
                height = 17,
                source = tcolor.rgb(1, 1, 1),
                file = this_dir .. "/assets/eye-dropper.svg",
            })
        }),
        el.new({
            offset_y = -4,
            bg = ebg.new({
                -- source = tcolor.rgba(0, 0, 0, 0.4),
                border_radius = 4,
            }),
            width = 44,
            height = 36,
            valign = etypes.ALIGN_BOTTOM,
            esvg.new({
                halign = etypes.ALIGN_CENTER,
                valign = etypes.ALIGN_CENTER,
                height = 18,
                source = tcolor.rgb(1, 1, 1),
                file = this_dir .. "/assets/crop-simple.svg"
            })
        })
    })

end

local function make_dots(tags)

    local dots = {}

    for k, tg in ipairs(tags) do
        table.insert(dots, el.new({
            width = selected_dot_rad * 2,
            height = etypes.SIZE_FILL,
            el.new({
                width = unselected_dot_rad * 2,
                height = unselected_dot_rad * 2,
                bg = ebg.new({
                    source = tcolor.rgb(1, 1, 1),
                    border_radius = 40,
                }),
                -- bg = tcolor.rgb_from_string("#ffffff"),
                halign = etypes.ALIGN_CENTER,
                valign = etypes.ALIGN_CENTER,
            })
        }))
    end

    return dots
end

local function _select_tag(elem, unselected_tag, selected_tag)

    if unselected_tag ~= nil then
        local unsel_ind = unselected_tag.index
        if unsel_ind >= 4 then
            unsel_ind = unsel_ind + 1
        end
        elem[unsel_ind][1].width = unselected_dot_rad * 2
        elem[unsel_ind][1].height = unselected_dot_rad * 2
        eutil.mark_relayout(elem)
        eutil.mark_redraw(elem)
    end

    local sel_ind = selected_tag.index
    if sel_ind >= 4 then
        sel_ind = sel_ind + 1
    end
    elem[sel_ind][1].width = selected_dot_rad * 2
    elem[sel_ind][1].height = selected_dot_rad * 2
    eutil.mark_relayout(elem)
    eutil.mark_redraw(elem)

end

local function _make_tagdots(app_data, layout_data, height)

    local separator = el.new({
        padding = etypes.padding_axis({x = 6}),
        el.new({
            width = 4,
            height = 20,
            valign = etypes.ALIGN_CENTER,
            bg = ebg.new({
                source = tcolor.rgb(1, 1, 1),
                border_radius = 10,
            })
        })
    })
    local dots = make_dots(app_data.model.tags)
    table.insert(dots, 4, separator)

    return el.new({
        padding = etypes.padding_each({top = 11, bottom = padding_bottom + 4}),
        halign = etypes.ALIGN_CENTER,
        height = etypes.SIZE_FILL,
        horizontal.new({
            spacing = 6,
            valign = etypes.ALIGN_BOTTOM,
            subscribe_on_global = {
                TagSelected = function(scope, emitted)
                    if layout_data.screen ~= emitted.screen then
                        return
                    end
                    local elem = scope.element
                    local unselected_tag = emitted.unselected_tag
                    local selected_tag = emitted.selected_tag
                    _select_tag(elem, unselected_tag, selected_tag)
                end
            },
            unpack(dots)
        })
    })
end

local function _make_clock(app_data)
    return el.new({
        width = 52, -- TODO: replace with relayout properly
        offset_x = 5,
        height = etypes.SIZE_FILL,
        valign = etypes.ALIGN_BOTTOM,
        halign = etypes.ALIGN_RIGHT,
        padding = etypes.padding_each({bottom = padding_bottom}),
        -- bg = ebg.new({
        --     source = tcolor.rgba(1, 0.1, 0.1, 0.4)
        -- }),
        el.new({
            valign = etypes.ALIGN_BOTTOM,
            halign = etypes.ALIGN_CENTER,
            padding = etypes.padding_axis({
                -- x = 12,
                y = 4,
            }),
            el.new({
                etext.new({
                    offset_y = 1,
                    text = app_data.global_model.time_counter.time:format("%H:%M"),
                    fg = right_side_color,
                    halign = etypes.ALIGN_CENTER,
                    valign = etypes.ALIGN_CENTER,
                    size = 14,
                    -- family = "Gilroy-Bold",
                    family = "TTCommons",
                    weight = "Demibold",
                    -- family = "CeraPro Bold",
                    -- family = "CircularStd Medium",
                    subscribe_on_global = {
                        TimeChanged = function(scope, emitted)
                            local element = scope.element
                            local time = emitted.time
                            etext.set_text(element, time:format("%H:%M"))
                            -- TODO: dont use "_parent._parent"
                            eutil.mark_relayout(element._parent._parent or element.layout_data)
                            eutil.mark_redraw(element)
                        end
                    },
                }),
            }),
        })
    })

end

local function _make_right_side(app_data)

    local function _form_date(os_date)
        return
            tostring(os_date.day) .. ', ' ..
            tostring(num_to_weekday(os_date.wday)) .. ', ' ..
            tostring(os_date.month) .. ', ' ..
            tostring(os_date.year)
    end

    local os_date = os.date("*t")

    local date = el.new({
        offset_y = 1,
        valign = etypes.ALIGN_CENTER,
        padding = etypes.padding_each({bottom = padding_bottom}),

        etext.new({
            text = _form_date(os_date),
            fg = right_side_color,
            family = "TTCommons",
            weight = "Demibold",
            size = 14,
        })
    })

    local notifications_button = el.new({
        height = etypes.SIZE_FILL,
        padding = etypes.padding_each({ padding_bottom = padding_bottom }),
        el.new({
            offset_y = -4,
            -- bg = ebg.new({
            --     source = tcolor.rgba(0, 0, 0, 0.4)
            -- }),
            width = 36,
            height = 36,
            valign = etypes.ALIGN_BOTTOM,
            esvg.new({
                halign = etypes.ALIGN_CENTER,
                valign = etypes.ALIGN_CENTER,
                height = 19,
                source = right_side_color,
                file = this_dir .. "/assets/bell.svg",
            })
        })
    })

    return horizontal.new({
        halign = etypes.ALIGN_RIGHT,
        valign = etypes.ALIGN_BOTTOM,
        padding = etypes.padding_each({ right = 20 }),
        spacing = 12,
        date,
        _make_clock(app_data),
        notifications_button,
    })



end

local function _make_horizontal_layout(args)
    -- local w = args.width
    -- local h = args.height
    return horizontal.new({
        valign = etypes.ALIGN_BOTTOM,
        halign = etypes.ALIGN_CENTER,
        -- padding = etypes.padding_each({bottom = 6}),
        -- width = w - 80,
        -- height = h - 10,
        width = etypes.SIZE_FILL,
        height = etypes.SIZE_FILL,
        -- bg = tcolor.rgb_from_string("#881a28"),
        -- border_radius = 25,
        _make_left_buttons(),
        _make_tagdots(args.app_data, args.layout_data, args.height),
        _make_right_side(args.app_data),
    })
end

local function new(args)

    local scr = args.screen

    local x = 0
    local y = 0
    local width = scr.geometry.width
    local height = global_palette.bar_height

    local struts = {
        top = height
    }

    local app_data = args.app_data

    app_data.layout = elayout.new({
        app_data = app_data,
        struts = struts,
        x = x,
        y = y,
        width = width,
        height = height,
        visible = true,
        screen = scr,
        type = "dock",
        bg = tcolor.rgba_from_string("#00000000"),
        subscribe_on_layout = {
            Init = function(scope)
                local app_data = scope.app_data
                local layout_data = scope.layout_data
                layout_data[1] = _make_horizontal_layout({
                    app_data = app_data,
                    layout_data = layout_data,
                    height = height,
                })
            end
        }
    })

end

return {
    new = new,

}

