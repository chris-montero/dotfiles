
_G.unveil = require("tools.unveil")

-- Themes
-- local theme_collection = {
--     "LateForLunch",
-- }

local theme_names = require("theme_names")
local theme_name = theme_names[1]

local palette = require("themes." .. theme_name .. ".palette")
local beautiful = require("beautiful")
beautiful.init(palette)

local awful = require("awful")
require("awful.autofocus") --TODO: remove this but still make autofocus work somehow
local tstation = require("tools.station")
local tstring = require("tools.string")
local tshape = require("tools.shape")
local a_compat = require("awesome_compat")
local weeny = require("tools.weeny")
local wtime_counter= require("wonderful.time_counter")
local wibox = require("wibox") --TODO: just use elemental to set the wallpaper and remove this
local client_decoration = require("themes.LateForLunch.client_decoration")
local gears = require("gears")

-- kill the previously running 'subscribed' scripts
-- otherwise they'll accumulate across awesome-wm restarts
local pactl_cleanup = [[bash -c "ps aux | grep '[0-9] pactl subscribe' | awk '{ print $2 }' | xargs kill"]]
local mpc_cleanup = [[bash -c "ps aux | grep '[0-9] mpc idleloop player' | awk '{ print $2 }' | xargs kill"]]
awful.spawn(pactl_cleanup)
awful.spawn(mpc_cleanup)

-------------------
-- Error handling
-------------------
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    print("WE HAD STARTUP ERRORS!")
    print(awesome.startup_errors)
end

local function _set_client_shape_if_necessary(c)
    if beautiful.border_radius == 0 then
        return
    end
    if c.fullscreen or c.maximized or c.type == "dock" then
        c.shape = function(cr, width, height)
            cr:rectangle(0, 0, width, height)
        end
    else
        c.shape = function(cr, width, height)
            tshape.rounded_rectangle(cr, width, height, palette.border_radius)
        end
    end
end

local tracklist
_G.global_station = tstation.new()
local global_model = {
    theme_name = theme_name,
    time_counter = wtime_counter.new({
        global_station = global_station,
    }),
    notifications = {}
}

-- catch and modify all relevant AwesomeWM signals, and subscribe to the new ones
-- TODO: change all of them and remove this eventually
a_compat.relay_awesome_signals(global_station)
tstation.subscribe_signals(global_station, {

    -- ["TracklistBeforeTick"] = function(data)
    --     global_model.before_tick = data.elapsed
    -- end,
    -- ["TracklistAfterTick"] = function(data)
    --     global_model.after_tick = data.elapsed
    -- end,

    [a_compat.ClientManaged] = function(emitted_data)

        -- FIXME: awesome apparently only sends this signal when it feels like it,
        -- so use "ClientRequestsTitlebars" instead
        local c = emitted_data.client

        -- Prevent clients from being unreachable after screen count changes.
        if awesome.startup
            and not c.size_hints.user_position
            and not c.size_hints.program_position
        then
            awful.placement.no_offscreen(c)
        end

        -- If the layout is not floating, every floating client that appears is centered
        -- If the layout is floating, and there is no other client visible, center it
        if not awesome.startup then
            if awful.layout.get(c.screen) ~= awful.layout.suit.floating then
                awful.placement.centered(c, { honor_workarea = true })
            elseif #c.screen.clients == 1 then
                awful.placement.centered(c, { honor_workarea = true })
            end
        end

        _set_client_shape_if_necessary(c)

        if palette.border_width > 0 then
            c.border_width = palette.border_width
            c.border_color = "#080604"
        end

    end,

    [a_compat.ClientUnmanaged] = function(emitted)
        -- local c = emitted.client
        -- if c.inner_border_decoration_data ~= nil then
        --     _undecorate_client(c)
        -- end
        if emitted.client.decoration ~= nil then
            emitted.client.decoration = nil
        end
    end,

    [a_compat.ClientRequestsDefaultMousebindings] = function()
        awful.mouse.append_client_mousebindings({
            awful.button({}, 1, function(c)
                c:activate({ context = "mouse_click" })
            end)
        })
    end,
    [a_compat.ClientPropertyChanged] = function(emitted_data)
        local c = emitted_data.client

        if emitted_data.property_name == "fullscreen" then
            _set_client_shape_if_necessary(c)
        elseif emitted_data.property_name == "maximized" then
            _set_client_shape_if_necessary(c)
        end
    end,

    -- Add a titlebar if titlebars_enabled is set to true in the rules.
    [a_compat.ClientRequestsTitlebars] = function(emitted_data)
        local c = emitted_data.client

        if beautiful.titlebars_enabled == false then
            return
            -- awful.titlebar.hide(c)
        end

        -- buttons for the titlebar
        local function make_buttons(cl)
            return {
                awful.button({ }, 1, function()
                    client.focus = cl
                    awful.mouse.client.move(cl)
                    cl:raise()
                end),
                awful.button({ }, 3, function()
                    client.focus = cl
                    cl:raise()
                    awful.mouse.client.resize(cl)
                end)
            }
        end

        local decoration = client_decoration.new({
            global_station = global_station,
            global_model = global_model,
            tracklist = tracklist,
            client = c
        })

        decoration.model.titlebar_top = client_decoration.make_titlebar_top(c, decoration, palette.border_radius, make_buttons(c))
        decoration.model.titlebar_right = client_decoration.make_titlebar_right(c, decoration)
        -- decoration.model.titlebar_bottom = client_decoration.make_titlebar_bottom(c, decoration, palette.border_radius)
        decoration.model.titlebar_left = client_decoration.make_titlebar_left(c, decoration)

        c.decoration = decoration

    end,

    ["RequestTagSelectPrev"] = function(emitted)
        local old_selected_tag = emitted.screen.selected_tag
        awful.tag.viewprev()
        local new_selected_tag = emitted.screen.selected_tag
        tstation.emit_signal(global_station, "TagSelected", {
            screen = emitted.screen,
            unselected_tag = old_selected_tag,
            selected_tag = new_selected_tag
        })
    end,
    ["RequestTagSelectNext"] = function(emitted)
        local old_selected_tag = emitted.screen.selected_tag
        awful.tag.viewnext()
        local new_selected_tag = emitted.screen.selected_tag
        tstation.emit_signal(global_station, "TagSelected", {
            screen = emitted.screen,
            unselected_tag = old_selected_tag,
            selected_tag = new_selected_tag
        })
    end,

    ["RequestTagSelect"] = function(emitted)
        if type(emitted.id) ~= "number" then
            print("The id of the tag you requested to select should be a number. Got: " .. type(emitted.id))
            return
        end
        if emitted.id < 1 or emitted.id > #emitted.screen.tags then
            print("the id of the tag you requested to select is out of bounds")
            return
        end

        local old_selected_tag = emitted.screen.selected_tag
        if old_selected_tag ~= nil then
            emitted.screen.selected_tag.selected = false
        end
        emitted.screen.tags[emitted.id].selected = true
        local new_selected_tag = emitted.screen.selected_tag

        tstation.emit_signal(global_station, "TagSelected", {
            screen = emitted.screen,
            unselected_tag = old_selected_tag,
            selected_tag = new_selected_tag,
        })
    end,


    ["RequestLayoutOnTop"] = function(emitted)
        local l = emitted.layout
        assert(l ~= nil)

        -- normally we should have a table of other layouts, and check through 
        -- them if any of them also want to be even higher rendered, etc but this
        -- will do for now
        l.window.ontop = true
    end,

    ["RequestWeatherToggle"] = function()
        if global_model.weather.model.layout.visible == true then
            global_model.weather.model.layout.visible = false
            tstation.emit_signal(
                global_station,
                "EventWeatherHidden",
                { layout = global_model.weather.model.layout }
            )
        else
            global_model.weather.model.layout.visible = true
            tstation.emit_signal(global_station, "RequestLayoutOnTop", {
                layout = global_model.weather.model.layout
            })
            tstation.emit_signal(
                global_station,
                "EventWeatherShown",
                { layout = global_model.weather.model.layout }
            )
        end
    end,

    ["RequestSongmanHide"] = function()
        if global_model.songman.model.layout.visible == false then return end
        global_model.songman.model.layout.visible = false
        tstation.emit_signal(
            global_station,
            "EventSongmanHidden",
            { layout = global_model.songman.model.layout }
        )
    end,

    ["RequestSongmanShow"] = function()
        if global_model.songman.model.layout.visible == true then return end
        global_model.songman.model.layout.visible = true
        tstation.emit_signal(global_station, "RequestLayoutOnTop", {
            layout = global_model.songman.model.layout
        })
        tstation.emit_signal(
            global_station,
            "EventSongmanShown",
            { layout = global_model.songman.model.layout }
        )
    end,

    ["RequestCalendaryShow"] = function()
        if global_model.calendary.model.layout.visible == true then return end
        global_model.calendary.model.layout.visible = true
        tstation.emit_signal(global_station, "RequestLayoutOnTop", {
            layout = global_model.calendary.model.layout
        })
        tstation.emit_signal(
            global_station,
            "EventCalendaryShown",
            { layout = global_model.calendary.model.layout }
        )
    end,

    ["RequestCalendaryHide"] = function()
        if global_model.calendary.model.layout.visible == false then return end
        global_model.calendary.model.layout.visible = false
        tstation.emit_signal(
            global_station,
            "EventCalendaryHidden",
            { layout = global_model.calendary.model.layout }
        )
    end,

    ["RequestCrankShow"] = function()
        if global_model.crank.model.panel_layout.visible == true then return end
        global_model.crank.model.panel_layout.visible = true
        tstation.emit_signal(global_station, "RequestLayoutOnTop", {
            layout = global_model.crank.model.panel_layout
        })
        tstation.emit_signal(
            global_station,
            "EventCrankShown",
            { layout = global_model.crank.model.panel_layout }
        )
    end,

    ["RequestCrankHide"] = function()
        if global_model.crank.model.panel_layout.visible == false then return end
        global_model.crank.model.panel_layout.visible = false
        tstation.emit_signal(
            global_station,
            "EventCrankHidden",
            { layout = global_model.crank.model.panel_layout }
        )
    end,

    ["RequestLiquidlogShow"] = function()
        if global_model.liquidlog.model.layout.visible == true then return end
        global_model.liquidlog.model.layout.visible = true
        tstation.emit_signal(global_station, "RequestLayoutOnTop", {
            layout = global_model.liquidlog.model.layout
        })
        tstation.emit_signal(
            global_station,
            "EventLiquidlogShown",
            { layout = global_model.liquidlog.model.layout }
        )
    end,

    ["RequestLiquidlogHide"] = function()
        if global_model.liquidlog.model.layout.visible == false then return end
        global_model.liquidlog.model.layout.visible = false
        tstation.emit_signal(
            global_station,
            "EventLiquidlogHidden",
            { layout = global_model.liquidlog.model.layout }
        )
    end,

    ["RequestTakeScreenshot"] = function()
        awful.spawn(os.getenv("HOME") .. "/.config/awesome/scripts/screenshot.sh")
    end,

    ["RequestNotify"] = function(_, notification)
        table.insert(global_model.notifications, notification)
        tstation.emit_signal(global_station, "EventNotification")
    end,
    ["EventNotification"] = function(_, emitted)
    end,

    [a_compat.AwesomeError] = function(emitted_data)
        -- Handle runtime errors after startup
        print("We got a runtime error:")
        print(tostring(emitted_data.error))
    end,

})

tracklist = weeny.create_tracklist({
    fps = 144,
    before_tick = function(e)
        tstation.emit_signal(global_station, "TracklistBeforeTick", {
            elapsed = e,
        })
    end,
    after_tick = function(e)
        tstation.emit_signal(global_station, "TracklistAfterTick", {
            elapsed = e
        })
    end
})



-- local function set_wallpaper(s)
--     if beautiful.wallpaper then
--         local wallpaper = beautiful.wallpaper
--         -- If wallpaper is a function, call it with the screen
--         if type(wallpaper) == "function" then
--             wallpaper = wallpaper(s)
--         end
--         -- gears.wallpaper.maximized(wallpaper, s, false)
--         awful.wallpaper({
--             screen = s,
--             widget = {
--                 horizontal_fit_policy = "fit",
--                 image = wallpaper,
--                 resize = true,
--                 widget = wibox.widget.imagebox,
--             }
--         })
--     end
-- end
--
-- local bar = require("apps.Bar.application")
-- awful.screen.connect_for_each_screen(function(s)
--
--     -- hardcode dpi because everything on X11 returns a different dpi result. 
--     -- `nvidia-xconfig` can't get it right, `xdpyinfo | grep "resolution"`
--     -- doesn't get it right, setting it explicitly in xinitrc doesn't set it in
--     -- awesomewm; TODO: investigate and fix
--     s.dpi = 96
--
--     set_wallpaper(s)
--
--     local layouts = {
--         awful.layout.suit.floating,
--         awful.layout.suit.floating,
--         awful.layout.suit.floating,
--         awful.layout.suit.tile,
--         awful.layout.suit.tile,
--         awful.layout.suit.tile,
--     }
--     for i=1, 6 do
--         awful.tag.add(tostring(i), {
--             gap = 5,
--             screen = s,
--             layout = layouts[i],
--             column_count = 3,
--         })
--     end
--
--     bar.new({
--         screen = s,
--         tracklist = tracklist,
--         global_station = global_station,
--         global_model = global_model,
--         time = global_model.time,
--     })
--
-- end)
-- tstation.emit_signal(global_station, "RequestTagSelect", {screen = screen.primary, id = 1})


local bar = require("apps.Bar.application")
awful.screen.connect_for_each_screen(function(s)

    -- hardcode dpi because everything on X11 returns a different dpi result. 
    -- `nvidia-xconfig` can't get it right, `xdpyinfo | grep "resolution"`
    -- doesn't get it right, setting it explicitly in xinitrc doesn't set it in
    -- awesomewm; TODO: investigate and fix
    s.dpi = 96

    gears.wallpaper.maximized(palette.wallpaper, s, false)
    -- awful.wallpaper({
    --     screen = s,
    --     widget = {
    --         horizontal_fit_policy = "fit",
    --         image = palette.wallpaper,
    --         resize = true,
    --         widget = wibox.widget.imagebox,
    --     }
    -- })

    local layouts = {
        awful.layout.suit.floating,
        awful.layout.suit.floating,
        awful.layout.suit.floating,
        awful.layout.suit.tile,
        awful.layout.suit.tile,
        awful.layout.suit.tile,
    }
    for i=1, 6 do
        awful.tag.add(tostring(i), {
            gap = 5,
            screen = s,
            layout = layouts[i],
            column_count = 3,
        })
    end

    bar.new({
        screen = s,
        tracklist = tracklist,
        global_station = global_station,
        global_model = global_model,
        time = global_model.time,
    })

end)
tstation.emit_signal(global_station, "RequestTagSelect", {screen = screen.primary, id = 1})

-- global keybindings
local keys = require("keys")
local keytable = require("wonderful.keymap.keytable")
local kt = keytable.to_awful_key_table(
    keytable.from_table(
        keys.make_root_keys(global_station)
    )
)
local ks = {}
for _, v in ipairs(kt) do
    for _, k in ipairs(v) do
        table.insert(ks, k)
    end
end
root.keys(ks)
-- awful.keyboard.append_global_keybindings(
--     keytable.to_awful_key_table(
--         keytable.from_table(
--             keys.make_root_keys(global_station)
--         )
--     )
-- )
-- root.buttons = keys.root_buttons

-------------------
-- RULES
-------------------
-- Rules to apply to new clients (through the "manage" signal).
--TODO: write my own client management system
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
        properties = {
            -- border_color = "#161a13",
            border_width = 1,
            border_color = '#12001c',
            focus = awful.client.focus.filter,
            raise = true,
            -- keys = keys.globalkeys,
            -- buttons = keys.clientbuttons,
            maximized_vertical = false,
            maximized_horisontal = false,
            -- screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
            size_hints_honor = false
        }
    },
    { -- Add titlebars to normal clients and dialogs
        rule_any = {
            type = { "normal", "dialog" }
        },
        properties = { titlebars_enabled = true }
    },
    { -- Floating clients.
        rule_any = {
            instance = {
              "DTA",  -- Firefox addon DownThemAll.
              "copyq",  -- Includes session name in class.
            },
            class = {
                -- "Arandr",
                "Lxappearance",
                "Nm-connection-editor",
                "Gpick",
                "Kruler",
                "MessageWin",  -- kalarm.
                "Sxiv",
                "Wpa_gui",
                "pinentry",
                "veromix",
                "xtightvncviewer",
                "fst" -- (floating st)
            },
            name = {
              "Event Tester",  -- xev.
            },
            role = {
              "AlarmWindow",  -- Thunderbird's calendar.
              "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
            },
        },
        properties = { floating = true, ontop = false }
    },
    {
        rule_any = {
            type = { "dialog" },
            class = {
                "Steam",
                "discord",
            },
            role = {
                "GtkFileChooserDialog",
            }
        },
        properties = {},
        callback = function(c)
            awful.placement.centered(c, {honor_workarea = true})
        end,
    },
    {
        rule_any = {
            class = {
                "Nautilus",
                "Thunar",
            },
        },
        except_any = {
            type = { "dialog" }
        },
        properties = {
            floating = true,
            -- width = awful.screen.focused().geometry.width * 0.4,
            -- height = awful.screen.focused().geometry.height * 0.7,
        }
    },
    {
        rule_any = {
            class = {
                "feh",
                "Sxiv",
            },
        },
        properties = {
            floating = true,
            -- width = awful.screen.focused().geometry.width * 0.7,
            -- height = awful.screen.focused().geometry.height * 0.7,
        },
        callback = function(c)
            awful.placement.centered(c, { honor_workarea = true })
        end,
    },
    { -- Set Firefox to always map on the tag named "2" on screen 1.
        rule = { class = "Firefox" },
        properties = {
            -- screen = 1,
            tag = "6"
        }
    },
}


local mouse_aware_mathgraph = require("examples.mouse_aware_mathgraph")
local ma_mathgraph = mouse_aware_mathgraph.new({
    global_station = global_station,
    global_model = global_model,
    tracklist = tracklist,
    model = {
        graph_mouse_down = false,
        graph_mouse_down_x = 0,
        plane_offset = 0,
        previous_plane_offset = 0,
        titlebar_mouse_down = false,
        titlebar_mouse_down_x = 0,
        titlebar_mouse_down_y = 0
    }
})

local liquidlog_app = require("apps.Liquidlog.application")
local liquidlog_layout = require("apps.Liquidlog." .. theme_name .. ".layout")
local liquidlog_prompt = require("apps.Liquidlog.vim_prompt")
global_model.liquidlog = liquidlog_app.new({
    global_station = global_station,
    global_model = global_model,
    tracklist = tracklist,
    model = {
        prompt_data = {
            caret_pos = 0,
            text = {},
            mode = liquidlog_prompt.MODE_NORMAL
        }
    },
})
global_model.liquidlog.model.layout = liquidlog_layout.new({
    app_data = global_model.liquidlog,
    screen = screen.primary
})

local weather_app = require("apps.Weather.application")
local weather_layout = require("apps.Weather." .. theme_name .. ".layout")
global_model.weather = weather_app.new({
    global_station = global_station,
    global_model = global_model,
    tracklist = tracklist,
    screen = screen.primary,
    layout = weather_layout,
    model = { top_sheet_push = 0 },
})

-- notification widget
local crank_app = require("apps.Crank.application")
local crank_mode = require("apps.Crank.mode")
global_model.crank = crank_app.new({
    global_station = global_station,
    global_model = global_model,
    tracklist = tracklist,
    screen = screen.primary,
    model = {
        muted = false,
        mode = crank_mode.MODE_NORMAL
    },
})

-- local iconographer_app = require("apps.Iconographer.application")
-- global_model.iconographer = iconographer_app.new({
--     global_station = global_station,
--     global_model = global_model,
--     tracklist = tracklist,
--     screen = screen.primary,
--     icon_height = 400,
--     -- icon_height = ic_height,
--     -- icon_width = ic_width,
--     -- icon = require("themes.LateForLunch.icons").next_song
--     -- icon_func = require("themes.LateForLunch.icons").prev_song
--     icon = require("themes.LateForLunch.icons").musical_note
-- })

local songman_app = require("apps.Songman.application")
global_model.songman = songman_app.new({
    global_station = global_station,
    global_model = global_model,
    tracklist = tracklist,
    screen = screen.primary,
})

local calendary_app = require("apps.Calendary.application")
global_model.calendary = calendary_app.new({
    global_station = global_station,
    global_model = global_model,
    tracklist = tracklist,
    screen = screen.primary,
})

-- local text_1 = require("examples.text.1")
-- local text_1_app = text_1.new({
--     global_station = global_station,
--     global_model = global_model,
--     tracklist = tracklist,
--     model = {
--         global_font_size_min = 4,
--         global_font_size_max = 96,
--         global_font_size = 20,
--         sample_text_data = {
--             caret_pos = 5,
--             -- text = tstring.split("The quick brown fox jumps over the lazy dog.")
--             text = tstring.split("Pack my box with five dozen liquor jugs.")
--         }
--     },
-- })



-- local tcolor = require("tools.color")
-- local h = tcolor.rgb_to_hsl(tcolor.rgb(0.09, 0.38, 0.46))
-- local back = tcolor.hsl_to_rgb(h)
-- print(h.h, h.s, h.l)

-- local app_test = require("examples.app_test")
-- local app = app_test.new({
--     global_model = global_model,
--     global_station = global_station,
--     tracklist = tracklist,
--     model = {
--         x = 70,
--         y = 70,
--     }
-- })

-- local color_animation = require("examples.color_animation")
-- local anim = color_animation.new({
--     global_station = global_station,
--     global_model = global_model,
--     tracklist = tracklist,
--     model = {}
-- })

-- local demo = require("examples.demo")
-- global_model.demo = demo.new({
--     global_model = global_model,
--     global_station = global_station,
--     tracklist = tracklist,
-- })

-- local demo_done = require("examples.demo_done")
-- global_model.demo_done = demo_done.new({
--     global_model = global_model,
--     global_station = global_station,
--     tracklist = tracklist,
-- })



local candy_clock = require("examples.candy_clock")
local clock = candy_clock.new({
    global_station = global_station,
    global_model = global_model,
    tracklist = tracklist,
    model = {}
})

weeny.start(tracklist)

