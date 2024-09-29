
local awful_key = require("awful.key")
local km_types = require("wonderful.keymap.types")

-- keytone: a keytone is a table with the follwing fields:
-- {
--     key : string
--     event : EVENT_PRESS | EVENT_RELEASE
--     modifiers : { string : bool } -- for efficiency, we store modifiers in the form of `{ "mod" = true }`
--     callback : function
--     info: {
--         "description" : string,
--     } | nil -- info about this key.
-- }
-- the values stored in the "keytable" have to be of this type, because we need
-- to have a callback to call when certain keys were pressed. Otherwise there's
-- no point in storing these values in the keytable

local function from_keytone_id(keytone_id, callback, info)
    return {
        modifiers = keytone_id.modifiers or {},
        key = keytone_id.key,
        event = keytone_id.event or km_types.EVENT_PRESS,
        callback = callback,
        info = info or nil,
    }
end

local function to_awful_key(keytone)
    local converted_mods = {}
    for mod_name, _ in pairs(keytone.modifiers) do
        table.insert(converted_mods, mod_name)
    end

    if keytone.event == km_types.EVENT_PRESS then
        return awful_key(
            converted_mods,
            keytone.key,
            keytone.callback,
            nil,
            keytone.info
        )
    else
        return awful_key(
            converted_mods,
            keytone.key,
            nil,
            keytone.callback,
            keytone.info
        )
    end
end

return {
    from_keytone_id = from_keytone_id,
    to_awful_key = to_awful_key,
}

