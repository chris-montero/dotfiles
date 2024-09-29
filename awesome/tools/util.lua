
local function current_dir_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    local cut = str:match("(.*/)") or ""
    return cut:sub(1, -2)
end

return {
    current_dir_path = current_dir_path
}
