
local tcolor = require("tools.color")
local lgi = require("lgi")

local ERROR_TYPE_INVALID_TITLE = 1
local ERROR_TYPE_COLOR_MISSING = 2
local ERROR_TYPE_INVALID_DATE = 3
local ERROR_TYPE_INVALID_SCREENSHOT = 4

local NOTIFICATION_TYPE_REGULAR = 1
local NOTIFICATION_TYPE_COLOR_PICKED = 2
local NOTIFICATION_TYPE_APPOINTMENT = 3
local NOTIFICATION_TYPE_SCREENSHOT_TAKEN = 4

local function make_date_time()
    return lgi.GLib.DateTime.new_now(lgi.GLib.TimeZone.new_local())
end

local function extension(args) end

local function regular(args)

    local title = args.title
    local description = args.description

    if title == nil then return ERROR_TYPE_INVALID_TITLE end

    return {
        _notification_type = NOTIFICATION_TYPE_REGULAR,
        date_time = make_date_time(),
        title = title,
        description = description
    }
end

local function appointment(args)

    local title = args.title
    local description = args.description
    local date_time = args.date_time

    if title == nil then return ERROR_TYPE_INVALID_TITLE end
    -- TODO: implement and replace the date validation code
    if date_time == nil then return ERROR_TYPE_INVALID_DATE end
    -- if tdate.is_valid_date(date) == false then return ERROR_TYPE_INVALID_DATE end

    return {
        _notification_type = NOTIFICATION_TYPE_APPOINTMENT,
        date_time = make_date_time(),
        title = title,
        description = description,
        appointment_date_time = date_time,
    }
end

local function color_picked(args)

    local color = args.color

    if tcolor.is_color(color) == false then return ERROR_TYPE_COLOR_MISSING end

    return {
        _notification_type = NOTIFICATION_TYPE_COLOR_PICKED,
        date_time = make_date_time(),
        color = color,
    }
end

local function screenshot_taken(args)

    local path_to_screenshot = args.path

    -- TODO: check if path exists
    if path_to_screenshot == nil then return ERROR_TYPE_INVALID_SCREENSHOT end

    return {
        _notification_type = NOTIFICATION_TYPE_SCREENSHOT_TAKEN,
        date_time = make_date_time(),
        path = path_to_screenshot,
    }

end


local function is_notification_regular(n)
    if type(n) ~= "table" then return false end
    return n._notification_type == NOTIFICATION_TYPE_REGULAR
end
local function is_notification_color_picked(n)
    if type(n) ~= "table" then return false end
    return n._notification_type == NOTIFICATION_TYPE_COLOR_PICKED
end
local function is_notification_appointment(n)
    if type(n) ~= "table" then return false end
    return n._notification_type == NOTIFICATION_TYPE_APPOINTMENT
end
local function is_notification_screenshot_taken(n)
    if type(n) ~= "table" then return false end
    return n._notification_type == NOTIFICATION_TYPE_SCREENSHOT_TAKEN
end


return {

    ERROR_TYPE_INVALID_TITLE = ERROR_TYPE_INVALID_TITLE,
    ERROR_TYPE_COLOR_MISSING = ERROR_TYPE_COLOR_MISSING,
    ERROR_TYPE_INVALID_DATE = ERROR_TYPE_INVALID_DATE,
    ERROR_TYPE_INVALID_SCREENSHOT = ERROR_TYPE_INVALID_SCREENSHOT,

    is_notification_regular = is_notification_regular,
    is_notification_color_picked = is_notification_color_picked,
    is_notification_appointment = is_notification_appointment,
    is_notification_screenshot_taken = is_notification_screenshot_taken,

    regular = regular,
    appointment = appointment,
    color_picked = color_picked,
    screenshot_taken = screenshot_taken
}
