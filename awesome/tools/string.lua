
local function startsWith(str, otherStr)

    if string.len(otherStr) > string.len(str) then
        return false;
    end

    for i=1, string.len(otherStr) do
        if string.sub(str, i, i) ~= string.sub(otherStr, i, i) then
            return false;
        end
    end

    return true;
end

local function endsWith(str, otherStr)
    assert(type(str) == "string");
    assert(type(otherStr) == "string");

    if string.len(otherStr) > string.len(str) then
        return false;
    end

    local revStr = string.reverse(str);
    local revOtherStr = string.reverse(otherStr);

    for i=1, string.len(otherStr) do
        if string.sub(revStr, i, i) ~= string.sub(revOtherStr, i, i) then
            return false;
        end
    end

    return true;
end

local function trimLeft(str, chr)

    if string.len(chr) ~= 1 then
        error("`trimLeft`'s second parameter must be an individual character");
    end

    for i=1, string.len(str) do
        if string.sub(str, i, i) ~= chr then
            return string.sub(str, i, string.len(str))
        end
    end
end

local function trimRight(str, chr)

    if string.len(chr) ~= 1 then
        error("`trimRight`'s second parameter must be an individual character");
    end

    for i=string.len(str), 1, -1 do
        if string.sub(str, i, i) ~= chr then
            return string.sub(str, 1, i)
        end
    end
end

local function removeLeft(str, subStr)
    if string.len(subStr) > string.len(str) then
        error("the sub-string to remove should be shorter than the string to remove from");
    end

    local matches = true;
    for i=1, string.len(subStr) do
        if string.sub(str, i, i) ~= string.sub(subStr, i, i) then
            matches = false;
        end
    end
    if matches then
        return string.sub(str, string.len(subStr) + 1, string.len(str));
    else
        return str -- TODO: maybe find something better to return in case of failure
    end
end

local function removeRight(str, subStr)

    if string.len(subStr) > string.len(str) then
        error("the sub-string to remove should be shorter than the string to remove from");
    end

    local revStr, revSubStr = string.reverse(str), string.reverse(subStr);

    local matches = true;
    for i=1, string.len(revSubStr) do
        if string.sub(revStr, i, i) ~= string.sub(revSubStr, i, i) then
            matches = false;
        end
    end

    if matches then
        return string.sub(str, 1, (string.len(str) - string.len(subStr)))
    else
        return str -- TODO: maybe find something better to return in case of failure
    end

end

local function split(str)
    local t = {}
    for i=1, string.len(str) do
        table.insert(t, string.sub(str,i, i))
    end
    return t
end

local function splice(str, pattern) --TODO: implement
end

return {
    startsWith = startsWith,
    endsWith = endsWith,
    trimLeft = trimLeft,
    trimRight = trimRight,
    removeLeft = removeLeft,
    removeRight = removeRight,
    split = split,
};

