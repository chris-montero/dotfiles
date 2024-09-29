
local eapplication = require("elemental.application")
local elayout = require("elemental.layout")
local eutil = require("elemental.util")
local tcolor = require("tools.color")
local tshape = require("tools.shape")
local weeny = require("tools.weeny")

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
                    x = 320,
                    y = 260,
                    -- shape = function(cr, width, height)
                    --     tshape.rounded_rectangle(cr, width, height, 200)
                    -- end,
                    width = 100,
                    height = 100,
                    visible = true,
                    screen = screen.primary,
                    bg = tcolor.hsl(0, 1, 0.5),
                    subscribe_on_layout = {
                        Init = function(scope)
                            local layout_data = scope.layout_data

                            weeny.add_ween_on_track(app_data.tracklist, "color", weeny.endless(
                                function(elapsed)
                                    local x = elapsed / 5
                                    if x % 2 > 1 then
                                        return - (x % 2) + 2
                                    else
                                        return x % 2
                                    end
                                end,
                                function(result)
                                    layout_data.bg.h = result
                                    eutil.mark_redraw(layout_data)
                                end
                            ))
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
