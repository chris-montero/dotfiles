

local tstation = require("tools.station")
local m_signals = require("elemental.mouse_signals")

local ret = {

    -- `client` global object
    ClientManaged = "ClientManaged",
    ClientUnmanaged = "ClientUnmanaged",
    BeforeScanningClients = "BeforeScanningClients",
    AfterScanningClients = "AfterScanningClients",
    ClientFocused = "ClientFocused",
    ClientUnfocused = "ClientUnfocused",
    ClientActivated = "ClientActivated",
    ClientGeometryChanged = "ClientGeometryChanged",
    ClientTagChanged = "ClientTagChanged",
    ClientUrgentStateChanged = "ClientUrgentStateChanged",
    ClientRequestsDefaultMousebindings = "ClientRequestsDefaultMousebindings",
    ClientRequestsDefaultKeybindings = "ClientRequestsDefaultKeybindings",
    ClientTagged = "ClientTagged",
    ClientUntagged = "ClientUntagged",
    ClientRenderOrderRaised = "ClientRenderOrderRaised",
    ClientRenderOrderLowered = "ClientRenderOrderLowered",
    ClientRequestsTitlebars = "ClientRequestsTitlebars",
    ClientRequestsBorder = "ClientRequestsBorder",
    ClientPropertyChanged = "ClientPropertyChanged",

    -- `awesome` global object
    AwesomeError = "AwesomeError", -- how ironic

    -- `screen` global object
    -- ScreensChanged = "ScreensChanged",
    -- ViewportsChanged = "ViewportsChanged",
    -- ScreenRequestsCreation = "ScreenRequestsCreation",
    -- ScreenRequestsRemoval = "ScreenRequestsRemoval",
}
-- --TODO: update this list as I find the properties which I need
local client_props = {
    "fullscreen",
    "maximized"
}
for _, prop in ipairs(client_props) do
    local signal_name = "ClientPropertyChanged_" .. prop
    ret[signal_name] = signal_name
end

local function _relay_client_property_changed_signal(station, name)
    client.connect_signal("property::" .. name, function(c)
        tstation.emit_signal(station, ret.ClientPropertyChanged, {
            c = c,
            property_name = name,
        })
    end)
end

function ret.relay_awesome_signals(station)
    client.connect_signal("request::manage", function(c, context, hints)
        tstation.emit_signal(station, ret.ClientManaged, {
            client = c,
            context = context, -- what created the client. Currently can be "new" or "startup"
            -- hints are currently empty for manage signals, so don't send it
        })
    end)
    client.connect_signal("request::unmanage", function(c, context, hints)
        tstation.emit_signal(station, ret.ClientUnmanaged, {
            client = c,
            context = context,
            -- hints are currently empty for unmanage signals, so don't send it
        })
    end)
    client.connect_signal("scanning", function()
        tstation.emit_signal(station, ret.BeforeScanningClients)
    end)
    client.connect_signal("scanned", function()
        tstation.emit_signal(station, ret.AfterScanningClients)
    end)
    client.connect_signal("focus", function()
        tstation.emit_signal(station, ret.ClientFocused)
    end)
    --TODO: check if 'c' really exists here
    client.connect_signal("unfocus", function()
        tstation.emit_signal(station, ret.ClientUnfocused)
    end)

    -- client.connect_signal("list", function()
    --     tstation.emit_signal(station, )
    -- end)
    -- client.connect_signal("swapped")

    --TODO: check if 'c' really exists here
    client.connect_signal("button:press", function(c)
        tstation.emit_signal(station, m_signals.MouseButtonPressed, { client = c })
    end)
    --TODO: check if 'c' really exists here
    client.connect_signal("button::release", function(c)
        tstation.emit_signal(station, m_signals.MouseButtonReleased, { client = c })
    end)
    --TODO: check if 'c' really exists here
    client.connect_signal("mouse::enter", function(c)
        tstation.emit_signal(station, m_signals.MouseEntered, { client = c })
    end)
    --TODO: check if 'c' really exists here
    client.connect_signal("mouse::leave", function(c)
        tstation.emit_signal(station, m_signals.MouseLeft, { client = c })
    end)
    --TODO: check if 'c' really exists here
    client.connect_signal("mouse::leave", function(c)
        tstation.emit_signal(station, m_signals.MouseLeft, { client = c })
    end)
    --TODO: check if 'c' really exists here
    client.connect_signal("request::activate", function(c, context, hints)
        -- Emitted when a client is focused and/or raised
        --  Context can be:
        --     ewmh: When a client asks for focus (from X11 events).
        --     *autofocus.check_focus*: When autofocus is enabled (from awful.autofocus).
        --     *autofocus.checkfocustag*: When autofocus is enabled (from awful.autofocus).
        --     client.jumpto: When a custom lua extension asks a client to be focused (from client.jump_to).
        --     *client.swap.global_bydirection*: When client swapping requires a focus change (from awful.client.swap.bydirection).
        --     client.movetotag: When a client is moved to a new tag (from client.move_to_tag).
        --     client.movetoscreen: When the client is moved to a new screen (from client.move_to_screen).
        --     client.focus.byidx: When selecting a client using its index (from awful.client.focus.byidx).
        --     client.focus.history.previous: When cycling through history (from awful.client.focus.history.previous).
        --     menu.clients: When using the builtin client menu (from awful.menu.clients).
        --     rules: When a new client is focused from a rule (from ruled.client).
        --     screen.focus: When a screen is focused (from awful.screen.focus).
        -- Default implementation: awful.ewmh.activate.

        -- To implement focus stealing filters see awful.ewmh.add_activate_filter.
        tstation.emit_signal(station, ret.ClientActivated, {
            client = c, context = context, hints = hints
        })
    end)
    -- client.connect_signal("request::autoactivate")

    client.connect_signal("request::geometry", function(c, context, additional)
        tstation.emit_signal(station, ret.ClientGeometryChanged, {
            client = c, context = context, additional = additional
        })
    end)
    client.connect_signal("request::tag", function(c)
        tstation.emit_signal(station, ret.ClientTagChanged, {
            client = c
        })
    end)
    client.connect_signal("request::urgent", function(c)
        tstation.emit_signal(station, ret.ClientUrgentStateChanged, {
            client = c
        })
    end)

    client.connect_signal("request::default_mousebindings", function(context)
        tstation.emit_signal(station, ret.ClientRequestsDefaultMousebindings, {
            context = context,
        })
    end)
    client.connect_signal("request::default_keybindings", function(c, context)
        tstation.emit_signal(station, ret.ClientRequestsDefaultKeybindings, {
            client = c,
            context = context,
        })
    end)

    --TODO: check if 'c' is actually the first argument here
    client.connect_signal("tagged", function(t)
        tstation.emit_signal(station, ret.ClientTagged, {
            tag = t
        })
    end)
    --TODO: check if 'c' is actually the first argument here
    client.connect_signal("untagged", function(t)
        tstation.emit_signal(station, ret.ClientUntagged, {
            tag = t
        })
    end)
    client.connect_signal("raised", function(c)
        tstation.emit_signal(station, ret.ClientRenderOrderRaised, {
            client = c
        })
    end)
    client.connect_signal("lowered", function(c)
        tstation.emit_signal(station, ret.ClientRenderOrderLowered, {
            client = c
        })
    end)
    client.connect_signal("request::titlebars", function(c, content, hints)
        -- content: (string) The context (like "rules") (default nil)
        -- hints: (table) Some hints. (default nil)
        tstation.emit_signal(station, ret.ClientRequestsTitlebars, {
            client = c,
            content = content,
            hints = hints,
        })
    end)
    client.connect_signal("request::border", function(c, context, hints)
         -- The context are:
         --    added: When a new client is created.
         --    active: When client gains the focus (or stop being urgent/floating but is active).
         --    inactive: When client loses the focus (or stop being urgent/floating and is not active.
         --    urgent: When a client becomes urgent.
         --    floating: When the floating or maximization state changes.
        tstation.emit_signal(station, ret.ClientRequestsBorder, {
            client = c,
            content = context,
            hints = hints,
        })
    end)
    client.connect_signal("property::fullscreen", function(c) 
        tstation.emit_signal(station, ret.ClientPropertyChanged, {
            client = c,
            property_name = "fullscreen"
        })
    end)
    client.connect_signal("property::maximized", function(c) 
        tstation.emit_signal(station, ret.ClientPropertyChanged, {
            client = c,
            property_name = "maximized"
        })
    end)
    for _, prop in ipairs(client_props) do
        _relay_client_property_changed_signal(station, prop)
    end

    awesome.connect_signal("debug::error", function(err)
        tstation.emit_signal(station, ret.AwesomeError, {
            error = err,
        })
    end)

    -- screen.connect_signal("property::viewports", function(viewports)
    --     tstation.emit_signal(station, ret.ScreensChanged, viewports)
    -- end)
    -- screen.connect_signal("list", function()
    --     tstation.emit_signal(station, ret.ViewportsChanged)
    -- end)
--     screen.connect_signal("request::create", function(viewport)
--         tstation.emit_signal(station, ret.ScreenRequestsCreation, viewport)
--     end)
--     screen.connect_signal("request::remove", function(viewport)
--         tstation.emit_signal(station, ret.ScreenRequestsRemoval, viewport)
--     end)
end

return ret


