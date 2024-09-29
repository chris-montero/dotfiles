
local km_types = require("wonderful.keymap.types")

-- keytone_id: a table containing information used to identify a set of keytones
-- we say "set" because one keytone_id can match multiple keytones (eg. duplicate keybindings)
-- {
--     key : string
--     event : km_types.EVENT_PRESS | km_types.EVENT_RELEASE
--     modifiers : { string : bool } -- for efficiency, we store modifiers in the form of `{ "mod" = true }`
-- }
-- this is usually used for identification of what key and modifiers was pressed
-- you can use something like this to index into a keytable, and get the callbacks
-- associated with this key

-- note: awesomewm_modifiers are different from the way we store modifiers
-- same for "awm_event"
local function new(awesomewm_modifiers, key, awesomewm_event)
    local new_mods = {}
    local new_evt = km_types.EVENT_PRESS
    for _, mod_name in ipairs(awesomewm_modifiers) do
        new_mods[mod_name] = true
    end
    if awesomewm_event == "release" then
        new_evt = km_types.EVENT_RELEASE
    end
    return {
        modifiers = new_mods,
        key = key,
        event = new_evt
    }
end


return {
    new = new,
}
