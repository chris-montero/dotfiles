

local km_internal = require("wonderful.keymap.internal")

local function from_table(args)
    assert(args.close_keytone ~= nil, "A strict keytable MUST have a close key specified")


    local keytable = {}
    for _, keytone in ipairs(args) do
        km_internal.add_keytone(keytable, keytone)
    end

    keytable.close_keytone = km_internal.sanity_check_keytone(args.close_keytone)
    return keytable
end

return {
    from_table = from_table,
    add_keytone = km_internal.add_keytone,
}
