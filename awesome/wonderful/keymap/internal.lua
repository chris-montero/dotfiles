
local km_types = require("wonderful.keymap.types")

local function mod_tables_equal(mods1, mods2)
    for mod_name, _ in pairs(mods1) do
        if mods2[mod_name] ~= true then
            return false
        end
    end
    return true
end

local function sanity_check_keytone(maybe_key_tone)
    assert(type(maybe_key_tone) == "table")
    assert(type(maybe_key_tone.callback) == "function")
    assert(maybe_key_tone.event == km_types.EVENT_PRESS or maybe_key_tone.event == km_types.EVENT_RELEASE)
    assert(type(maybe_key_tone.key) == "string")
    return maybe_key_tone
end

-- this can take a keytable OR a strict_keytable
local function add_keytone(keytable, keytone)
    local kt = sanity_check_keytone(keytone)

    if keytable[kt.key] == nil then
        keytable[kt.key] = {}
    end

    table.insert(keytable[kt.key], kt)
end

return {
    mod_tables_equal = mod_tables_equal,
    sanity_check_keytone = sanity_check_keytone,
    add_keytone = add_keytone,
}
