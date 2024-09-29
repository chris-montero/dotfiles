
local lgi = require("lgi")
local ktypes = require("wonderful.keymap.types")
local etext = require("elemental.elements.text")

local MODE_NORMAL = 1
local MODE_INSERT = 2
local MODE_REPLACE = 3
local MODE_VISUAL_CHAR = 4
local MODE_VISUAL_LINE = 5
local MODE_VISUAL_BLOCK = 6

local function get_caret_geometry(text_el, pos)

    local pango_caret_pos = lgi.Pango.Layout.get_caret_pos(text_el._text_layout, pos)
    return {
        x = pango_caret_pos.x / lgi.Pango.SCALE,
        y = pango_caret_pos.y / lgi.Pango.SCALE,
        width = pango_caret_pos.width / lgi.Pango.SCALE,
        height = pango_caret_pos.height / lgi.Pango.SCALE,
    }

end

local function _handle_mode_normal(text_el, prompt_data, kid, on_close, on_caret_change, on_text_change)

    if kid.modifiers.Mod1 then
        if kid.key == "l" then
            return on_close()
        end
    end

    if kid.key == 'h' then
        prompt_data.caret_pos = math.max(0, prompt_data.caret_pos - 1)
    elseif kid.key == 'j' then
        local lines = text_el._text_layout:get_lines_readonly()
    elseif kid.key == 'k' then
    elseif kid.key == "l" then
        prompt_data.caret_pos = math.min(#prompt_data.text, prompt_data.caret_pos + 1)
    elseif kid.key == 'i' then
        prompt_data.mode = MODE_INSERT
    end

    on_caret_change()

end

local function _handle_mode_insert(text_el, prompt_data, kid, on_close, on_caret_change, on_text_change)

    local caret_pos = prompt_data.caret_pos

    if #kid.key == 1 then
        local new_caret_pos = caret_pos + 1
        table.insert(prompt_data.text, new_caret_pos, kid.key)
        prompt_data.caret_pos = new_caret_pos
        on_text_change()
        on_caret_change()
    end

    if kid.key == "BackSpace" then
        if caret_pos == 0 then return end
        table.remove(prompt_data.text, caret_pos)
        local new_caret_pos = caret_pos - 1
        prompt_data.caret_pos = new_caret_pos
        on_text_change()
        on_caret_change()
    elseif kid.key == "Return" then
        local new_caret_pos = caret_pos + 1
        table.insert(prompt_data.text, new_caret_pos, '\n')
        prompt_data.caret_pos = new_caret_pos
        on_text_change()
        on_caret_change()
    end

    local lines = text_el._text_layout:get_lines_readonly()

    if kid.key == "Escape" then
        prompt_data.mode = MODE_NORMAL
        return
    end

end

local function act(text_el, prompt_data, kid, on_close, on_caret_change, on_text_change)
    if kid.event == ktypes.EVENT_RELEASE then return end

    if prompt_data.mode == MODE_NORMAL then
        return _handle_mode_normal(text_el, prompt_data, kid, on_close, on_caret_change, on_text_change)
    elseif prompt_data.mode == MODE_INSERT then
        return _handle_mode_insert(text_el, prompt_data, kid, on_close, on_caret_change, on_text_change)
    end

end

return {

    MODE_NORMAL = MODE_NORMAL,
    MODE_INSERT = MODE_INSERT,
    MODE_REPLACE = MODE_REPLACE,
    MODE_VISUAL_CHAR = MODE_VISUAL_CHAR,
    MODE_VISUAL_LINE = MODE_VISUAL_LINE,
    MODE_VISUAL_BLOCK = MODE_VISUAL_BLOCK,

    act = act,
    get_caret_geometry = get_caret_geometry,
}
