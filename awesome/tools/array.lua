
-- utility functions for working on contiguous "array" tables

-- given a table and a function that returns a boolean value, filters the given
-- table and only keeps values where the function returns true
local function filter(tab, func)
    if #tab == 0 then return tab end

    local newTable = {}

    for i = 1, #tab do
        local passes = func(tab[i])
        assert(type(passes) == "boolean", "the function passed in to 'filter' should return a boolean value")
        if passes then
            table.insert(newTable, tab[i])
        end
    end

    return newTable;
end

local function any(arr, fun)
    for _, v in ipairs(arr) do
        if fun(v) == true then
            return true
        end
    end
    return false
end

-- concatenates all the elements in the "array" side of the table
-- note: all elements must be of type "string", else the function fails
local function concat_elements(tab, sep)

    if sep == nil then
        sep = ""
    end

    if #tab == 0 then
        return ""
    end

    local str = ""
    for k, v in ipairs(tab) do
        assert(type(v) == "string", "all types in the given table must be strings")
        if k ~= #tab then
            str = str .. v .. sep
        else
            str = str .. v
        end
    end
    return str
end

-- concatenates two arrays together
-- note: creates and returns a new table
local function concat(tab1, tab2)
    local newT = {}
    for _, v1 in ipairs(tab1) do
        table.insert(newT, v1)
    end
    for _, v2 in ipairs(tab2) do
        table.insert(newT, v2)
    end
    return newT
end

local function from_table(tab)
    local new_arr = {}
    for k, v in ipairs(tab) do
        new_arr[k] = v
    end
    return new_arr
end

local function shallow_copy(tab)
    local new_tab = {}
    for k, v in ipairs(tab) do
        new_tab [k] = v
    end
    return new_tab
end

local function intersperse(arr, thing)
    if #arr <= 1 then
        return arr
    end

    local new_arr = {arr[1]}
    for i=2, #arr do
        table.insert(new_arr, thing)
        table.insert(new_arr, arr[i])
    end
    return new_arr
end

-- local function map(arr, fun)
--     local new_tab = {}
--     for k, v in ipairs(arr) do
--         new_tab[k] = fun(v)
--     end
--     return new_tab
-- end

return {
    concat = concat,
    concat_elements = concat_elements,
    any = any,
    filter = filter,
    -- map = map,
    shallow_copy = shallow_copy,
    intersperse = intersperse,
    from_table = from_table,
}
