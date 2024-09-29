local awful = require("awful")
local dpi = require("beautiful.xresources").apply_dpi
local km_types = require("wonderful.keymap.types")
local tstation = require("tools.station")

local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys") -- TODO: might take this out. have to see if it does anything

local terminal = "alacritty"
local floating_terminal = "alacritty --class fst,fst"

-- put global variables in a file
-- for k, _ in pairs(_G) do
    -- file = io.open(os.getenv("HOME").."/awesome_globals.txt", "a")
    -- file:write(tostring(k)..'\n')
    -- file:close()
-- end

-- keys.globalkeys = gears.table.join(

--     ---------------
--     -- Screens
--     ---------------
--     -- focus the prev screen
--     awful.key({ superkey }, "e", function () awful.screen.focus_relative(-1) end,
--               { description = "focus the previous screen", group = "screen"}),

--     -- focus the next screen
--     awful.key({ superkey }, "r", function () awful.screen.focus_relative( 1) end,
--               { description = "focus the next screen", group = "screen"})
-- )

-- keys.globalkeys = gears.table.join( keys.globalkeys,

--     ---------------
--     -- Tags
--     ---------------
--     -- view previous tag
--     awful.key({ superkey }, "q", awful.tag.viewprev,
--             {description = "view previous", group = "tag"}),

--     -- view next tag
--     awful.key({ superkey }, "w",  awful.tag.viewnext,
--               {description = "view next", group = "tag"})
-- )

-- keys.globalkeys = gears.table.join( keys.globalkeys,
--     ---------------
--     -- Program-related
--     ---------------
--     
--     -- restart awesomeWM
--     -- PRO TIP: 'Shift_L' doesn't work ;)
--     awful.key({ superkey, shift }, "t", awesome.restart,
--               { description = "reload awesome", group = "awesome"}),

--     -- quit awesome
--     awful.key({ superkey, shift }, "Escape", awesome.quit,
--               { description = "quit awesome", group = "awesome"}),

--     -- show main menu
--     -- awful.key({ superkey }, "c", function () mymainmenu:show() end, -- this keybind is used to center clients
--     --           { description = "show main menu", group = "awesome"}),

--     -- alt + 'grave' to start a FLOATING terminal
--     awful.key({ alt }, "grave", function () awful.spawn(floating_terminal) end,
--               { description = "open a floating terminal", group = "awesome"}),

--     -- superkey + 'grave' to start a terminal
--     awful.key({ superkey }, "grave", function () awful.spawn(terminal) end,
--               { description = "open a terminal", group = "awesome"}),


--     --awful.key({ superkey, shift }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
--     --          {description = "increase the number of master clients", group = "layout"}),

--     --awful.key({ superkey, shift }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
--     --          {description = "decrease the number of master clients", group = "layout"}),

--     awful.key({ superkey, control }, "h",
--         function () awful.tag.incncol( 1, nil, false ) end,
--         {
--             description = "increase the number of columns",
--             group = "layout"
--         }
--     ),

--     awful.key({ superkey, control }, "l",
--         function () awful.tag.incncol(-1, nil, true) end,
--         {
--             description = "decrease the number of columns",
--             group = "layout"
--         }
--     ),

--     awful.key({ alt }, "r", piglets.piggyprompt.launch,
--         { description = "Run programs", group = "awesome"})

--     -- superkey + r
--     -- program-running prompt
--     -- awful.key({ alt }, "r",
--         -- function () 
--             -- awful.screen.focused().mypromptbox:run() 
--             -- piglets.sidebar.sidebar.promptbox:run()
--             -- for k, v in pairs(piglets.sidebar.sidebar:get_children_by_id("launcher")[1]) do
--                 -- naughty.notify({text = tostring(k)})
--             -- end
--             -- piglets.sidebar.sidebar:get_children_by_id("launcher")[1]:run()
--             -- if not piglets.sidebar.sidebar.visible then
--                 -- piglets.sidebar.sidebar.visible = true
--                 -- piglets.sidebar.sidebar.ontop = true
--             -- end
--             -- piglets.sidebar.promptbox:run()
--         -- end,
--     -- {description = "run prompt", group = "awesome"}),

--     -- superkey + x
--     -- run-lua-code prompt
--     -- awful.key({ alt }, "l",
--     --     function ()
--     --         awful.prompt.run ({
--     --             prompt       = "Run Lua code: ",
--     --             textbox      = awful.screen.focused().mypromptbox.widget,
--     --             exe_callback = awful.util.eval,
--     --             history_path = awful.util.get_cache_dir() .. "/history_eval"
--     --         })
--     --     end,
--     --     {description = "lua execute prompt", group = "awesome"})

--     -- Menubar
--     -- this is broken currently (30, march, 2019)
--     -- awful.key({ superkey }, "x", 
--         -- function() 
--             -- menubar.show() 
--             -- naughty.notify({text = tostring(capi.selection())})
--         -- end,
--     -- {description = "show the clipboard contents", group = "awesome"}),
-- )

-- ---------------
-- -- Clients
-- ---------------
-- keys.globalkeys = gears.table.join( keys.globalkeys,
--     ------ TABBING THROUGH CLIENTS 
--     awful.key({ superkey, shift }, "q",
--         function() 
--             awful.client.focus.byidx(1)
--         end,
--         { description = "focus next client", group = "client"}),
--     awful.key({ superkey, shift }, "w",
--         function()
--             awful.client.focus.byidx(-1)
--         end,
--         { description = "focus previous client", group = "client"}),
--     awful.key({ superkey }, "Tab",
--         function()
--             awful.client.focus.byidx(1)
--         end,
--         { description = "focus next client", group = "client"}),
--     awful.key({ superkey, shift }, "Tab",
--         function()
--             awful.client.focus.byidx(-1)
--         end,
--         { description = "focus previous client", group = "client"})
-- )

-- -- Swapping/moving clients with arrow keys
-- keys.globalkeys = gears.table.join( keys.globalkeys,
--     -- swap with client above
--     awful.key({ superkey, shift }, "Up",
--         function () 
--             local c = client.focus
--             local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
--             if current_layout == "floating" or c.floating then
--                 c:relative_move(0, dpi(-30), 0, 0)
--             else
--                 awful.client.swap.bydirection("up")
--             end
--         end,
--         { description = "swap with the client above", group = "client"}),
--     -- swap with client on the right
--     awful.key({ superkey, shift }, 'Right',
--         function ()
--             local c = client.focus
--             local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
--             if current_layout == "floating" or c.floating then
--                 c:relative_move(dpi(30), 0, 0, 0)
--             else
--                 awful.client.swap.bydirection("right")
--             end
--         end,
--         { description = "swap with the client on the right", group = "client"}),
--     -- swap places with the client below
--     awful.key({ superkey, shift }, "Down",
--         function () 
--             local c = client.focus
--             local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
--             if current_layout == "floating" or c.floating then
--                 c:relative_move(0, dpi(30), 0, 0)
--             else
--                 awful.client.swap.bydirection("down")
--             end
--         end,
--         { description = "swap with the client below", group = "client"}),
--     -- swap with the client on the left
--     awful.key({ superkey, shift }, "Left",
--         function ()
--             local c = client.focus
--             local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
--             if current_layout == "floating" or c.floating then
--                 c:relative_move(dpi(-30), 0, 0, 0)
--             else
--                 awful.client.swap.bydirection("left")
--             end
--         end,
--         { description = "swap with the client on the left", group = "client" })
-- )

-- -- Focusing clients with arrow keys
-- keys.globalkeys = gears.table.join( keys.globalkeys,
--     -- focus client by direction: up
--     awful.key({ superkey }, "Up",
--         function()
--             awful.client.focus.bydirection("up")
--             if client.focus then client.focus:raise() end
--         end,
--         { description = "focus up", group = "client"}),
--     -- focus client by direction: right
--     awful.key({ superkey }, "Right",
--         function()
--             awful.client.focus.bydirection("right")
--             if client.focus then client.focus:raise() end
--         end,
--         { description = "focus right", group = "client"}),
--     -- focus client by direction: down
--     awful.key({ superkey }, "Down",
--         function()
--             awful.client.focus.bydirection("down")
--             if client.focus then client.focus:raise() end
--         end,
--         { description = "focus down", group = "client" }),
--     -- focus client by direction: left
--     awful.key({ superkey }, "Left",
--         function()
--             awful.client.focus.bydirection("left")
--             if client.focus then client.focus:raise() end
--         end,
--         { description = "focus left", group = "client"})
-- )

-- -- resizing clients with arrow keys
-- keys.globalkeys = gears.table.join(keys.globalkeys,
--     awful.key({ superkey, control }, "Up", 
--         function ()
--             local c = client.focus
--             local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
--             if current_layout == "floating" or c.floating == true then
--                 c:relative_move( 0, 0, 0, dpi(-60) )
--             else
--                 awful.tag.incmwfact(0.02)
--             end
--         end),
--     awful.key({ superkey, control }, "Right",
--         function () 
--             local c = client.focus
--             local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
--             if current_layout == "floating" or c.floating == true then
--                 c:relative_move( 0, 0, dpi(60), 0 )
--             else
--                 awful.tag.incmwfact(0.02)
--             end
--         end),
--     awful.key({ superkey, control }, "Down", 
--         function ()
--             local c = client.focus
--             local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
--             if current_layout == "floating" or c.floating == true then
--                 c:relative_move(  0,  0,  0, dpi(60) )
--             else
--                 awful.tag.incmwfact(-0.02)
--             end
--         end),
--     awful.key({ superkey, control }, "Left",
--         function ()
--             local c = client.focus
--             local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
--             if current_layout == "floating" or c.floating == true then
--                 c:relative_move( 0, 0, dpi(-60), 0 )
--             else
--                 awful.tag.incmwfact(-0.02)
--             end
--         end)
-- )

-- ------ Swapping/moving between clients with superkey + [yuio]
-- keys.globalkeys = gears.table.join( keys.globalkeys,
--     -- swap with client above
--     awful.key({ superkey }, "i",
--         function ()
--             local c = client.focus
--             local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
--             if current_layout == "floating" or c.floating then
--                 c:relative_move(0, dpi(-40), 0, 0)
--             else
--                 awful.client.swap.bydirection("up")
--             end
--         end,
--         { description = "swap with the client above", group = "client"}),
--     -- swap with client on the right
--     awful.key({ superkey }, 'o',
--         function ()
--             local c = client.focus
--             local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
--             if current_layout == "floating" or c.floating then
--                 c:relative_move(dpi(40), 0, 0, 0)
--             else
--                 awful.client.swap.bydirection("right")
--             end
--         end,
--         { description = "swap with the client on the right", group = "client"}),
--     -- swap places with the client below
--     awful.key({ superkey }, "u",
--         function ()
--             local c = client.focus
--             local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
--             if current_layout == "floating" or c.floating then
--                 c:relative_move(0, dpi(40), 0, 0)
--             else
--                 awful.client.swap.bydirection("down")
--             end
--         end,
--         { description = "swap with the client below", group = "client"}),
--     -- swap with the client on the left
--     awful.key({ superkey }, "y",
--         function ()
--             local c = client.focus
--             local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
--             if current_layout == "floating" or c.floating then
--                 c:relative_move(dpi(-40), 0, 0, 0)
--             else
--                 awful.client.swap.bydirection("left")
--             end
--         end,
--         { description = "swap with the client on the left", group = "client" })
-- )

-- -- focus clients with vim keys
-- keys.globalkeys = gears.table.join( keys.globalkeys,
--     -- focus client by direction: up
--     awful.key({ superkey }, "k",
--         function()
--             awful.client.focus.bydirection("up")
--             if client.focus then client.focus:raise() end
--         end,
--         { description = "focus up", group = "client"}),
--     -- focus client by direction: right
--     awful.key({ superkey }, "l",
--         function()
--             awful.client.focus.bydirection("right")
--             if client.focus then client.focus:raise() end
--         end,
--         { description = "focus right", group = "client"}),
--     -- focus client by direction: down
--     awful.key({ superkey }, "j",
--         function()
--             awful.client.focus.bydirection("down")
--             if client.focus then client.focus:raise() end
--         end,
--         { description = "focus down", group = "client" }),
--     -- focus client by direction: left
--     awful.key({ superkey }, "h",
--         function()
--             awful.client.focus.bydirection("left")
--             if client.focus then client.focus:raise() end
--         end,
--         { description = "focus left", group = "client"})
-- )

-- ------ resizing clients with superkey + [n.]keys
-- keys.globalkeys = gears.table.join( keys.globalkeys,

--     awful.key({ superkey }, "comma", 
--         function ()
--             local c = client.focus
--             local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
--             if current_layout == "floating" or c.floating == true then
--                 c:relative_move( 0, 0, 0, dpi(-30) )
--             else
--                 awful.tag.incmwfact(0.04)
--             end
--         end),
--     awful.key({ superkey }, "period",
--         function () 
--             local c = client.focus
--             local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
--             if current_layout == "floating" or c.floating == true then
--                 c:relative_move( 0, 0, dpi(30), 0 )
--             else
--                 awful.tag.incmwfact(0.04)
--             end
--         end),
--     awful.key({ superkey }, "m", 
--         function ()
--             local c = client.focus
--             local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
--             if current_layout == "floating" or c.floating == true then
--                 c:relative_move(  0,  0,  0, dpi(30) )
--             else
--                 awful.tag.incmwfact(-0.04)
--             end
--         end),

--     -- superkey + n to decrease window width
--     awful.key({ superkey }, "n",
--         function ()
--             local c = client.focus
--             local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
--             if current_layout == "floating" or c.floating == true then
--                 c:relative_move( 0, 0, dpi(-30), 0 )
--             else
--                 awful.tag.incmwfact(-0.04)
--             end
--         end)
-- )


-- -- Switching through layouts
-- keys.globalkeys = gears.table.join( keys.globalkeys,
--     ------ super + shift + [er] to browse back and forth through layouts for clients
--     awful.key({ superkey, shift }, "e", function () awful.layout.inc(-1) end,
--               { description = "select previous", group = "client"}),

--     -- superkey + shift + r select next layout for clients
--     awful.key({ superkey, shift }, "r", function () awful.layout.inc(1) end,
--               { description = "select next", group = "client"})
-- )

-- keys.globalkeys = gears.table.join( keys.globalkeys,
--     -- Center client
--     awful.key({ superkey }, "c",  function ()
--         local c = client.focus
--         awful.placement.centered(c,{honor_workarea=true})
--     end),

--     -- Toggle titlebar (for focused client only)
--     -- awful.key({ alt }, "t",
--     --     function (c)
--     --         -- Don't toggle if titlebars are used as borders
--     --         if not beautiful.titlebars_imitate_borders then
--     --             awful.titlebar.toggle(c)
--     --         end
--     --     end,
--     --     {description = "toggle titlebar", group = "client"}),
--     -- Toggle titlebar (for all visible clients in selected tag)
--     awful.key({ alt, shift }, "t",
--         function (c)
--             --local s = awful.screen.focused()
--             local clients = awful.screen.focused().clients
--             for _, c in pairs(clients) do
--                 -- Don't toggle if titlebars are used as borders
--                 if not beautiful.titlebars_imitate_borders then
--                     awful.titlebar.toggle(c)
--                 end
--             end
--         end,
--         {description = "toggle titlebar", group = "client"}),

--     -- toggle fullscreen
--     awful.key({ superkey }, "f",
--         function (c)
--             local c = client.focus
--             if c then
--                 c.fullscreen = not c.fullscreen
--                 c:raise()
--             end
--         end,
--         { description = "toggle fullscreen", group = "client"}),

--     -- toggle maximized
--     awful.key({ superkey }, "d",
--         function (c)
--             local c = client.focus
--             if c then
--                 c.maximized = not c.maximized
--                 c:raise()
--             end
--         end ,
--         { description = "toggle maximized", group = "client"}),

--     -- minimize client
--     awful.key({ superkey }, "s",
--         function (c)
--             local c = client.focus
--             -- The client currently has the input focus, so it cannot be
--             -- minimized, since minimized clients can't have the focus.
--             if c then
--                 c.minimized = true
--             end
--         end,
--         { description = "minimize", group = "client"}),

--     -- restore minimized client
--     awful.key({ superkey }, "a",
--         function ()
--             local c = awful.client.restore()
--             -- Focus restored client
--             if c then
--                 client.focus = c
--                 c:raise()
--             end
--         end,
--         { description = "restore minimized", group = "client"}),

--     -- kill current client
--     awful.key({ superkey }, "Escape",
--         function ()
--                 local c = client.focus
--                 if c then
--                     c:kill()
--                 end
--         end,
--         { description = "kill client", group = "client" }),

--     -- toggle floating layout mode
--     awful.key({ superkey }, "space",
--         awful.client.floating.toggle,
--         { description = "toggle floating", group = "client"}),

--     -- move to master
--     --awful.key({ superkey, control }, "Return", function (c) c:swap(awful.client.getmaster())   end,
--     --          {description = "move to master", group = "client"}),

--     -- move to screen
--     awful.key({ superkey, shift }, "e",      function (c) c:move_to_screen()               end,
--              {description = "move to screen", group = "client"}),

--     -- toggle "keep on top"
--     -- awful.key({ superkey, shift }, "r",      function (c) c.ontop = not c.ontop            end,
--     --         {description = "toggle keep on top", group = "client"}),

--     ------ other client-related keybindings

--     -- superkey + u
--     -- jump to urgent client
--     awful.key({ superkey }, "z",
--         awful.client.urgent.jumpto,
--         { description = "jump to urgent client", group = "client"})
-- )
--     -- superkey + Tab
--     -- go to the previously visited client
--     -- awful.key({ superkey }, "Tab",
--     --    function ()
--     --        awful.client.focus.history.previous()
--     --        if client.focus then
--     --            client.focus:raise()
--     --        end
--     --    end,
--     --    {description = "go back", group = "client"}),

--     ---------------
--     -- Misc
--     ---------------
-- keys.globalkeys = gears.table.join(keys.globalkeys,

--     -- superkey + shift + h
--     -- show help
--     awful.key({ superkey, shift }, "h", hotkeys_popup.show_help,
--               { description="show help", group="awesome"}),

--     -- awful.key({ superkey, shift }, "a", function()
--     --         print("KEYGRABBER STARTS")
--     --         grabber = liquidlog.keygrab(liquidlog.new({}))
--     --     end,
--     --     { description = "open liquidlog", group = "liquidlog" }
--     -- ),
--     awful.key({ superkey, shift }, "a", function() print("KEY_PRESSED")end, nil,
--         { description = "open liquidlog", group = "liquidlog" }
--     ),
--     awful.key({ superkey, shift }, "a", nil, function()print("KEY_RELEASED")end,
--         { description = "open liquidlog", group = "liquidlog" }
--     ),

--     -- this is temporary
--     awful.key({ alt }, "y", function()
--         awful.spawn(os.getenv("HOME") .. "/.config/awesome/bin/screenshot.sh")
--     end),
--     awful.key({ alt }, "u", function()
--         awful.spawn(os.getenv("HOME") .. "/.config/awesome/bin/screenshot.sh -s")
--     end)
-- )

-- keys.globalkeys = gears.table.join(keys.globalkeys,

--     ---------------
--     -- Sidebar
--     ---------------
--     awful.key({ alt }, "s",
--         function()
--             piglets.sidebar.sidebar.visible = not piglets.sidebar.sidebar.visible
--             piglets.sidebar.sidebar.ontop = not piglets.sidebar.sidebar.ontop
--             audio_widget_module.notification_audio_bar_bg.visible = false
--         end,
--         { description = "toggle sidebar", group = "sidebar"}),

--     awful.key({ superkey }, "F1", 
--         function()
--             awful.spawn(os.getenv("HOME") .. "/.config/awesome/bin/volumectl down")
--         end,
--         { description = "decrease volume by 5%", group = "sidebar"}),

--     awful.key({ superkey }, "F2", 
--         function()
--             awful.spawn(os.getenv("HOME") .. "/.config/awesome/bin/volumectl up")
--         end,
--         { description = "increase volume by 5%", group = "sidebar"}),

--     awful.key({ superkey }, "F3", 
--         function()
--             awful.spawn(os.getenv("HOME") .. "/.config/awesome/bin/volumectl toggle")
--         end,
--         { description = "toggle volume", group = "sidebar"}),

--     awful.key({ superkey }, "F4", 
--         function()
--             awful.spawn(os.getenv("HOME") .. "/.config/awesome/bin/volumectl reset")
--         end,
--         { description = "reset volume to 50%", group = "sidebar"})
-- )

-- keys.globalkeys = gears.table.join(keys.globalkeys,
--     ----------------
--     -- Hogbar
--     ----------------
--     awful.key({ superkey }, 'F9', porkerpanel.show_panel,
--         { description = "show exit panel", group = "sidebar"})
-- )

-- -- Bind all key numbers to tags.
-- -- Be careful: we use keycodes to make it work on any keyboard layout.
-- -- This should map on the top row of your keyboard, usually 1 to 9.
-- for i = 1, 9 do
--     keys.globalkeys = gears.table.join(keys.globalkeys,
--         -- View tag only.
--         awful.key({ superkey }, "#" .. i + 9,
--                   function ()
--                         local screen = awful.screen.focused()
--                         local tag = screen.tags[i]
--                         if tag then
--                            tag:view_only()
--                         end
--                   end,
--                   {description = "view tag #"..i, group = "tag"}),
--         -- Toggle tag display.
--         awful.key({ superkey, control }, "#" .. i + 9,
--                   function ()
--                       local screen = awful.screen.focused()
--                       local tag = screen.tags[i]
--                       if tag then
--                          awful.tag.viewtoggle(tag)
--                       end
--                   end,
--                   {description = "toggle tag #" .. i, group = "tag"}),
--         -- Move client to tag.
--         awful.key({ superkey, shift }, "#" .. i + 9,
--                   function ()
--                       if client.focus then
--                           local tag = client.focus.screen.tags[i]
--                           if tag then
--                               client.focus:move_to_tag(tag)
--                           end
--                      end
--                   end,
--                   {description = "move focused client to tag #"..i, group = "tag"}),
--         -- Toggle tag on focused client.
--         awful.key({ superkey, control, shift }, "#" .. i + 9,
--                   function ()
--                       if client.focus then
--                           local tag = client.focus.screen.tags[i]
--                           if tag then
--                               client.focus:toggle_tag(tag)
--                           end
--                       end
--                   end,
--                   {description = "toggle focused client on tag #" .. i, group = "tag"})
--     )
-- end

-- -- Mouse buttons on the desktop ( the actual background image )
-- keys.desktopbuttons = gears.table.join(
--     awful.button({ }, 1, function (c)
--         if c then
--             client.focus = c
--             c:raise()
--         end
--         utils.check_double_tap( function() end )
--     end)
-- )

-- -- Mouse buttons on the client (whole window, not the titlebar)
-- keys.clientbuttons = gears.table.join(
--     awful.button({ superkey }, 1, awful.mouse.client.move),
--     awful.button({ superkey }, 3, awful.mouse.client.resize)
-- )
local function make_root_keys(global_station)
    local root_keys = {
        {
            key = 'e',
            modifiers = {
                Mod4 = true -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function() awful.screen.focus_relative(-1) end,
            info = { description = "Focus the previous screen." },
        },
        {
            key = 'r',
            modifiers = {
                Mod4 = true -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function() awful.screen.focus_relative(1) end,
            info = { description = "Focus the next screen." },
        },
        {
            key = 'q',
            modifiers = {
                Mod4 = true -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function()
                tstation.emit_signal(global_station, "RequestTagSelectPrev", {screen = awful.screen.focused()})
            end,
            info = { description = "View previous tag." },
        },
        {
            key = 'w',
            modifiers = {
                Mod4 = true -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function()
                print("SELECTING NEXT TAG")
                tstation.emit_signal(global_station, "RequestTagSelectNext", {screen = awful.screen.focused()})
            end,
            info = { description = "View next tag." },
        },
        {
            key = 't',
            modifiers = {
                Mod4 = true, -- windows key
                Shift = true
            },
            event = km_types.EVENT_PRESS,
            callback = awesome.restart,
            info = { description = "Restart AwesomeWM." },
        },
        {
            key = 'Escape',
            modifiers = {
                Mod4 = true, -- windows key
                Shift = true
            },
            event = km_types.EVENT_PRESS,
            callback = awesome.quit,
            info = { description = "Quit AwesomeWM." },
        },
        {
            key = 'grave',
            modifiers = {
                Mod1 = true, -- alt key
            },
            event = km_types.EVENT_PRESS,
            callback = function() awful.spawn(floating_terminal) end,
            info = { description = "Open a floating terminal." },
        },
        {
            key = 'grave',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function() awful.spawn(terminal) end,
            info = { description = "Open a terminal." },
        },
        -- {
        --     key = 'h',
        --     modifiers = {
        --         Mod4 = true, -- windows key
        --         Control = true,
        --     },
        --     event = km_types.EVENT_PRESS,
        --     callback = function() awful.tag.incncol(1, nil, false) end,
        --     info = { description = "Increase the number of columns." },
        -- },
        -- {
        --     key = 'l',
        --     modifiers = {
        --         Mod4 = true, -- windows key
        --         Control = true,
        --     },
        --     event = km_types.EVENT_PRESS,
        --     callback = function() awful.tag.incncol(-1, nil, true) end,
        --     info = { description = "Decrease the number of columns." },
        -- },
        -- {
        --     key = 'r',
        --     modifiers = {
        --         Mod1 = true, -- alt key
        --     },
        --     event = km_types.EVENT_PRESS,
        --     callback = piglets.piggyprompt.launch,
        --     info = { description = "Open program runner." },
        -- },

        -- focusing clients with win_key + Tab / win_key + Shift + Tab
        {
            key = 'Tab',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function() awful.client.focus.byidx(1) end,
            info = { description = "Focus next client." },
        },
        {
            key = 'Tab',
            modifiers = {
                Mod4 = true, -- windows key
                Shift = true,
            },
            event = km_types.EVENT_PRESS,
            callback = function() awful.client.focus.byidx(-1) end,
            info = { description = "Focus previous client." },
        },

        -- swap / move clients with win_key + [yuio]
        {
            key = 'i',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function()
                local c = client.focus
                local current_layout_name = awful.layout.getname(awful.layout.get(awful.screen.focused()))
                if current_layout_name == "floating" or c.floating then
                    c:relative_move(0, dpi(-40), 0, 0)
                else
                    awful.client.swap.bydirection("left")
                end
            end,
            info = { description = "(Depending on the layout): Swap places with client above / Move client up." },
        },
        {
            key = 'o',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function ()
                local c = client.focus
                local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
                if current_layout == "floating" or c.floating then
                    c:relative_move(dpi(40), 0, 0, 0)
                else
                    awful.client.swap.bydirection("right")
                end
            end,
            info = { description = "(Depending on the layout): Swap places with client on the right / Move client to the right." },
        },
        {
            key = 'u',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function ()
                local c = client.focus
                local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
                if current_layout == "floating" or c.floating then
                    c:relative_move(0, dpi(40), 0, 0)
                else
                    awful.client.swap.bydirection("down")
                end
            end,
            info = { description = "(Depending on the layout): Swap places with client below / Move client down." },
        },
        {
            key = 'y',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function ()
                local c = client.focus
                local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
                if current_layout == "floating" or c.floating then
                    c:relative_move(dpi(-40), 0, 0, 0)
                else
                    awful.client.swap.bydirection("left")
                end
            end,
            info = { description = "(Depending on the layout): Swap places with client on the left / Move client to the left." },
        },

        -- focus clients with win_key + [hjkl]
        {
            key = 'k',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function ()
                awful.client.focus.bydirection("up")
                if client.focus then client.focus:raise() end
            end,
            info = { description = "Focus client above." },
        },
        {
            key = 'l',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function ()
                awful.client.focus.bydirection("right")
                if client.focus then client.focus:raise() end
            end,
            info = { description = "Focus client to the right." },
        },
        {
            key = 'j',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function ()
                awful.client.focus.bydirection("down")
                if client.focus then client.focus:raise() end
            end,
            info = { description = "Focus client below." },
        },
        {
            key = 'h',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function ()
                awful.client.focus.bydirection("left")
                if client.focus then client.focus:raise() end
            end,
            info = { description = "Focus client to the left." },
        },

        -- increase or decrease width or height with win_key + [nm,.]
        {
            key = 'comma',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function ()
                local c = client.focus
                local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
                if current_layout == "floating" or c.floating == true then
                    c:relative_move( 0, 0, 0, dpi(-30) )
                else
                    awful.tag.incmwfact(0.04)
                end
            end,
            info = { description = "Make client height smaller." },
        },
        {
            key = 'period',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function ()
                local c = client.focus
                local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
                if current_layout == "floating" or c.floating == true then
                    c:relative_move( 0, 0, dpi(30), 0 )
                else
                    awful.tag.incmwfact(0.04)
                end
            end,
            info = { description = "Make client width bigger." },
        },
        {
            key = 'm',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function ()
                local c = client.focus
                local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
                if current_layout == "floating" or c.floating == true then
                    c:relative_move(  0,  0,  0, dpi(30) )
                else
                    awful.tag.incmwfact(-0.04)
                end
            end,
            info = { description = "Make client height bigger." },
        },
        {
            key = 'n',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function ()
                local c = client.focus
                local current_layout = awful.layout.getname(awful.layout.get(awful.screen.focused()))
                if current_layout == "floating" or c.floating == true then
                    c:relative_move( 0, 0, dpi(-30), 0 )
                else
                    awful.tag.incmwfact(-0.04)
                end
            end,
            info = { description = "Make client width smaller." },
        },

        -- switch back and forth through layouts with win_key + shift + [er]
        {
            key = 'e',
            modifiers = {
                Mod4 = true, -- windows key
                Shift = true,
            },
            event = km_types.EVENT_PRESS,
            callback = function ()
                awful.layout.inc(-1)
            end,
            info = { description = "Change the current layout type to the previous one." },
        },
        {
            key = 'r',
            modifiers = {
                Mod4 = true, -- windows key
                Shift = true,
            },
            event = km_types.EVENT_PRESS,
            callback = function ()
                awful.layout.inc(1)
            end,
            info = { description = "Change the current layout type to the next one." },
        },

        -- center client with win_key + c
        {
            key = 'c',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function ()
                local c = client.focus
                awful.placement.centered(c, { honor_workarea = true })
            end,
            info = { description = "Center focused client." },
        },

        -- toggle client fullscreen with win_key + f
        {
            key = 'f',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function ()
                local c = client.focus
                if c then
                    c.fullscreen = not c.fullscreen
                    c:raise()
                end
            end,
            info = { description = "Toggle fullscreen on currently focused client." },
        },

        -- toggle client maximized with win_key + d
        {
            key = 'd',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function ()
                local c = client.focus
                if c then
                    c.maximized = not c.maximized
                    c:raise()
                end
            end,
            info = { description = "Toggle maximize on currently focused client." },
        },

        -- minimize client with win_key + s
        {
            key = 's',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function ()
                local c = client.focus
                -- The client currently has the input focus, so it cannot be
                -- minimized, since minimized clients can't have the focus.
                if c then
                    c.minimized = true
                end
            end,
            info = { description = "Minimize currently focused client." },
        },

        -- restore minimized client with win_key + a
        {
            key = 'a',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function ()
                local c = awful.client.restore()
                -- Focus restored client
                if c then
                    client.focus = c
                    c:raise()
                end
            end,
            info = { description = "Restore a minimized client." },
        },

        -- kill current client with win_key + Escape
        {
            key = 'Escape',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function ()
                local c = client.focus
                if c then
                    c:kill()
                end
            end,
            info = { description = "Kill the currently focused client." },
        },

        -- toggle floating layout mode on currently focused client with win_key + space
        {
            key = 'space',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = awful.client.floating.toggle,
            info = { description = "Toggle floating layout on currently focused client." },
        },

        -- TODO: implement a better way to send a client to a different screen
        -- {
        --     key = 'e',
        --     modifiers = {
        --         Mod4 = true, -- windows key
        --         Shift = true,
        --     },
        --     event = km_types.EVENT_PRESS,
        --     callback = function(c) c:move_to_screen() end,
        --     info = { description = "Move currently focused client to screen." },
        -- },

        -- TODO: add a better keybindings screen
        -- {
        --     key = 'h',
        --     modifiers = {
        --         Mod4 = true, -- windows key
        --         Shift = true,
        --     },
        --     event = km_types.EVENT_PRESS,
        --     callback = awful.client.floating.toggle,
        --     info = { description = "Show help." },
        -- },

        -- take screenshots of a portion, or the entire screen with alt + [yu]
        {
            key = 'y',
            modifiers = {
                Mod1 = true, -- alt key
            },
            event = km_types.EVENT_PRESS,
            callback = function()
                awful.spawn(os.getenv("HOME") .. "/.config/awesome/scripts/screenshot.sh")
            end,
            info = { description = "Take a screenshot of the screen." },
        },
        {
            key = 'u',
            modifiers = {
                Mod1 = true, -- alt key
            },
            event = km_types.EVENT_PRESS,
            callback = function()
                awful.spawn(os.getenv("HOME") .. "/.config/awesome/scripts/screenshot.sh -s")
            end,
            info = { description = "Take a screenshot of a portion of the screen." },
        },

        -- open/close Songman widget
        {
            key = 's',
            modifiers = {
                Mod1 = true, -- alt key
            },
            event = km_types.EVENT_PRESS,
            callback = function()
                tstation.emit_signal(global_station, "RequestSongmanShow")
            end,
            info = { description = "Open/Close Song manipulation widget." },
        },

        -- open/close Calendar widget
        {
            key = 'c',
            modifiers = {
                Mod1 = true, -- alt key
            },
            event = km_types.EVENT_PRESS,
            callback = function()
                tstation.emit_signal(global_station, "RequestCalendaryShow")
            end,
            info = { description = "Open/Close quick calendar widget." },
        },

        -- open/close Crank notification panel
        {
            key = 'n',
            modifiers = {
                Mod1 = true, -- alt key
            },
            event = km_types.EVENT_PRESS,
            callback = function()
                tstation.emit_signal(global_station, "RequestCrankShow")
            end,
            info = { description = "Open/Close notification panel." },
        },

        -- open/close weather
        {
            key = 'w',
            modifiers = {
                Mod1 = true, -- alt key
            },
            event = km_types.EVENT_PRESS,
            callback = function()
                tstation.emit_signal(global_station, "RequestWeatherToggle")
            end,
            info = { description = "Open/Close Weather." },
        },

        -- open/close the liquidlog
        {
            key = 'l',
            modifiers = {
                Mod1 = true, -- alt key
            },
            event = km_types.EVENT_PRESS,
            callback = function()
                tstation.emit_signal(global_station, "RequestLiquidlogShow")
            end,
            info = { description = "Open the liquidlog." },
        },

        -- change volume / mute with win_key + [F1F2F3F4]
        {
            key = 'F1',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function()
                awful.spawn(os.getenv("HOME") .. "/.config/awesome/scripts/volumectl down")
            end,
            info = { description = "Decrease the volume by 5%." },
        },
        {
            key = 'F2',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function()
                awful.spawn(os.getenv("HOME") .. "/.config/awesome/scripts/volumectl up")
            end,
            info = { description = "Increase the volume by 5%." },
        },
        {
            key = 'F3',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function()
                awful.spawn(os.getenv("HOME") .. "/.config/awesome/scripts/volumectl toggle")
            end,
            info = { description = "Mute/Unmute." },
        },
        {
            key = 'F4',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function()
                awful.spawn(os.getenv("HOME") .. "/.config/awesome/scripts/volumectl reset")
            end,
            info = { description = "Reset the volume to 50%." },
        },


        {
            key = 'F4',
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function()
                awful.spawn(os.getenv("HOME") .. "/.config/awesome/scripts/volumectl reset")
            end,
            info = { description = "Reset the volume to 50%." },
        },

    }

    for i=1,6 do
        table.insert(root_keys, {
            key = '#' .. i + 9,
            modifiers = {
                Mod4 = true, -- windows key
            },
            event = km_types.EVENT_PRESS,
            callback = function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                   tag:view_only()
                end
            end,
            info = { description = "Jump to tag #" .. i .. '.'},
        })

        table.insert(root_keys, {
            key = '#' .. i + 9,
            modifiers = {
                Mod4 = true, -- windows key
                Shift = true,
            },
            event = km_types.EVENT_PRESS,
            callback = function()
                  if client.focus then
                      local tag = client.focus.screen.tags[i]
                      if tag then
                          client.focus:move_to_tag(tag)
                      end
                 end
            end,
            info = { description = "Jump to tag #" .. i .. '.'},
        })

    end

    return root_keys

end

return {
    make_root_keys = make_root_keys,
    -- root_buttons = root_buttons
}
