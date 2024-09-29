
local km_internal = require("wonderful.keymap.internal")
local km_keytone = require("wonderful.keymap.keytone")

local function get_keytones_by_keytone_id(keytable, keytone_id)
    if keytable[keytone_id.key] == nil then
        return {}
    end

    -- we get a list because we can get multiple keytones for the same keytone_id
    local matched_keytones = {}
    for _, keytones in pairs(keytable[keytone_id.key]) do
        for _, keytone in pairs(keytones) do
            if keytone.event == keytone_id.event and km_internal.mod_tables_equal(keytone.modifiers, keytone_id.modifiers) then
                table.insert(matched_keytones, keytone)
            end
        end
    end
    return matched_keytones
end

local function from_table(tab)
    local keytable = {}
    for _, keytone in ipairs(tab) do
        km_internal.add_keytone(keytable, keytone)
    end
    return keytable
end

local function to_awful_key_table(keytable)
    local awful_key_table = {}
    for _, keytones in pairs(keytable) do
        for _, keytone in pairs(keytones) do
            table.insert(awful_key_table, km_keytone.to_awful_key(keytone))
        end
    end
    return awful_key_table
end

return {

    from_table = from_table,
    add_keytone = km_internal.add_keytone,

    get_keytones_by_keytone_id = get_keytones_by_keytone_id,

    -- awful key conversion function
    to_awful_key_table = to_awful_key_table,
}
