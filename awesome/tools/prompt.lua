
local ktypes = require("wonderful.keymap.types")

-- local special = {

--     -- function keys
--     F1 = true,
--     F2 = true,
--     F3 = true,
--     F4 = true,
--     F5 = true,
--     F6 = true,
--     F7 = true,
--     F8 = true,
--     F9 = true,
--     F10 = true,
--     F11 = true,
--     F12 = true,

--     -- modifiers
--     Alt_L = true,
--     Alt_R = true,
--     Super_L = true,
--     Super_R = true,
--     Control_L = true,
--     Control_R = true,
--     Shift_L = true,
--     Shift_R = true,
--     Tab = true,

--     Escape = true,
--     Menu = true,
--     Caps_Lock = true,
--     Return = true,
--     BackSpace = true,

--     -- arrows
--     Up = true,
--     Right = true,
--     Down = true,
--     Left = true,

--     -- buttons above arrows
--     Insert = true,
--     Home = true,
--     Prior = true, -- page up
--     Delete = true,
--     End = true,
--     Next = true, -- page down

--     -- buttons above buttons above arrows
--     Print = true,
--     Scroll_Lock = true,
--     Pause = true,

--     Num_Lock = true,
-- }

-- NOTE: you must supply the text as a list of characters. This is for speed, as
-- lua strings are immutable, so it'd be more costly to split, change the string
-- here, and put it back together. Instead, keep the split string in memory,
-- give it to this, it will return a modified split string to you, and you can
-- then concatenate that and display it in your UI
local function act(pdata, k_id, on_exit, on_text_change)
    if k_id.event == ktypes.EVENT_RELEASE then return end


    if k_id.modifiers.Control then
        if k_id.key == "u" then
            -- create new split text because calling table.remove a bunch of
            -- times is more inefficient
            local new_split_text = {}
            for i=pdata.caret_pos + 1, #pdata.text do
                table.insert(new_split_text, pdata.text[i])
            end
            for i=1, #pdata.text do
                pdata.text[i] = new_split_text[i]
            end
            -- we removed everything before the caret, so now we're at 0
            pdata.caret_pos = 0
            on_text_change()
            return
        elseif k_id.key == "k" then
            local new_split_text = {}
            for i=1, pdata.caret_pos do
                table.insert(new_split_text, pdata.text[i])
            end
            for i=1, #pdata.text do
                pdata.text[i] = new_split_text[i]
            end
            on_text_change()
            return
        end
    end

    if #k_id.key == 1 then
        -- if we encountered no special keys, just input the key 
        table.insert(pdata.text, pdata.caret_pos + 1, k_id.key)
        pdata.caret_pos = pdata.caret_pos + 1
        on_text_change()
        return
    end

    if k_id.key == "Escape" then
        keygrabber.stop()
        on_exit()
        return
    elseif k_id.key == "Return" then
        -- keygrabber.stop()
        -- on_enter()
        return
    elseif k_id.key == "Left" then
        pdata.caret_pos = math.max(0, pdata.caret_pos - 1)
        on_text_change()
        return
    elseif k_id.key == "Right" then
        pdata.caret_pos = math.min(#pdata.text, pdata.caret_pos + 1)
        on_text_change()
        return
    elseif k_id.key == "Up" then
        return
    elseif k_id.key == "Down" then
        return
    elseif k_id.key == "BackSpace" then
        if pdata.caret_pos == 0 then return end
        table.remove(pdata.text, pdata.caret_pos)
        pdata.caret_pos = pdata.caret_pos - 1
        on_text_change()
        return
    elseif k_id.key == "Delete" then
        if pdata.caret_pos == #pdata.text then return end
        table.remove(pdata.text, pdata.caret_pos + 1)
        on_text_change()
        return
    end

    -- if all else fails, do nothing and return the same caret position
    -- return caret_pos

end



return {
    act = act
}

