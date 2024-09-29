

local elayout = require("elemental.layout")
local esource = require("elemental.source")
local eutil = require("elemental.util")
local etypes = require("elemental.types")
local el = require("elemental.elements.el")
local ebg = require("elemental.elements.bg")
local vertical = require("elemental.elements.vertical")
-- local horizontal = require("elemental.elements.horizontal")
local etext = require("elemental.elements.text")
local tcolor = require("tools.color")
local tstation = require("tools.station")
local keytone_id = require("wonderful.keymap.keytone_id")
local vim_prompt = require("apps.Liquidlog.vim_prompt")
-- local weeny = require("tools.weeny")

local font_family_1 = "RobotoMono Nerd Font"

local font_size_1 = 11


local function _make_text_skeleton(args)

    local init_text = args.text

    local avail_width = args.width
    local avail_height = args.height

    return el.new({
        width = avail_width,
        height = avail_height,
        halign = etypes.ALIGN_CENTER,
        valign = etypes.ALIGN_CENTER,
        padding = etypes.padding_axis({ x = 15, y = 30 }),
        -- spacing = 10,
        bg = ebg.new({
            source = tcolor.rgb_from_string("#181210")
        }),
        etext.new({
            fg = tcolor.rgb_from_string("#ffffff"),
            width = etypes.SIZE_FILL,
            -- width = 500,
            family = font_family_1,
            weight = "Regular",
            size = font_size_1,
            text = table.concat(init_text),
            subscribe_on_global = {
                ["EventLiquidlogShown"] = function(scope)
                    local elem = scope.element
                    local app_data = scope.app_data

                    keygrabber.run(function(mods, key, evt)
                        local kid = keytone_id.new(mods, key, evt)

                        vim_prompt.act(
                            elem,
                            app_data.model.prompt_data,
                            kid,
                            function()
                                tstation.emit_signal(
                                    app_data.global_station,
                                    "RequestLiquidlogHide"
                                )
                                app_data.model.prompt_data.mode = vim_prompt.MODE_NORMAL
                                keygrabber.stop()
                            end,
                            function()
                                tstation.emit_signal(
                                    app_data.station,
                                    "CaretChanged"
                                )
                            end,
                            function()
                                tstation.emit_signal(
                                    app_data.station,
                                    "TextChanged"
                                )
                            end
                        )
                    end)
                end,
            },
            subscribe_on_app = {

                TextChanged = function(scope)
                    local elem = scope.element
                    local app_data = scope.app_data
                    etext.set_text(elem, table.concat(app_data.model.prompt_data.text))
                    eutil.mark_relayout(elem._parent)
                    eutil.mark_redraw(elem)
                end,
                CaretChanged = function(scope)
                    local elem = scope.element
                    local app_data = scope.app_data
                    local caret_el = elem._parent[2]
                    local caret_geom = vim_prompt.get_caret_geometry(
                        elem,
                        app_data.model.prompt_data.caret_pos
                    )
                    caret_el.offset_x = caret_geom.x
                    caret_el.offset_y = caret_geom.y
                    caret_el.width = math.max(1, caret_geom.width)
                    caret_el.height = caret_geom.height
                    eutil.mark_relayout(elem._parent)
                    eutil.mark_redraw(elem)
                end
            }
        }),
        el.new({
            width = 0,
            height = 0,
            _draw = function(elem, cr, width, height)
                cr:set_line_width(1)
                cr:set_source(esource.to_cairo_source(tcolor.rgb(1, 1, 1)))
                cr:move_to(0, height)
                cr:line_to(width, 0)
                cr:stroke()
            end
        })
    })

end

local function new(args)

    local scr = args.screen or screen.primary
    local app_data = args.app_data
    -- local blob_bounding_width = 600
    -- local blob_bounding_height = 740
    local blob_bounding_width = 600
    local blob_bounding_height = 800
    local x = (scr.geometry.width - blob_bounding_width) / 2
    local y = (scr.geometry.height - blob_bounding_height) / 2

    return elayout.new({
        x = x,
        y = y,
        width = blob_bounding_width,
        height = blob_bounding_height,
        visible = false,
        app_data = app_data,
        screen = scr,
        -- type = "dock",
        bg = tcolor.rgba(1, 0.2, 0.3, 0.8),
        subscribe_on_layout = {
            Init = function(scope)
                local layout_data = scope.layout_data
                layout_data[1] = _make_text_skeleton({
                    text = app_data.model.prompt_data.text,
                    width = blob_bounding_width,
                    height = blob_bounding_height,
                })
            end
        }
    })

end

return {
    new = new
}
