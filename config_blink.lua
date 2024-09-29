
table.unpack = table.unpack or unpack

-- TODO: Move tests elsewhere and do them properly
-- local test_config_inexistent_sources = {
--     {"./zshrc", "~/.zshrc"},
--     {"./non-existent_file.txt", "~/non-existent_file.txt"},
--     {"./xinitrc", "~/.xinitrc"},
-- }
--
-- local test_config_multiple_times_target = {
--     {"./zshrc", "~/.zshrc" },
--     {"~/HUGESPACE/../dotfiles/zshrc", "~/.zshrc" },
--     {"./xinitrc", "~/.xinitrc" },
-- }
--
-- local test_config_source_and_target_point_to_the_same_place = {
--     {"./zshrc", "~/dotfiles/zshrc"},
-- }
--
-- local test_config_intermediary_target_directories_dont_exist = {
--     {"./zshrc", "~/inexistent_directory1/inexistent_directory2/zshrc"},
-- }
--
-- local test_config_targets_exist = {
--     {"./xinitrc", "~/.xinitrc"},
--     {"./zshrc", "~/mnt"}, -- already exists
--     {"./zshrc", "/root"}, -- already exists
--     {"./zshrc", "/etc/rc.shutdown"}, -- already exists on void
-- }

local _common_config = {
    {"./zshrc", "~/.zshrc"},
    {"./xinitrc", "~/.xinitrc"},
    {"./gdbinit", "~/.gdbinit"}, -- TODO: can't I have this exist at "~/.config/gdb/gdbinit" or something like that?
    {"./gitconfig", "~/.gitconfig"}, -- TODO: can't I have this exist at "~/.config/git/gitconfig" or something like that?
    -- TODO: maybe have a global .gitignore too
    {"./fontconfig", "~/.config/fontconfig"},
    {"./tmux", "~/.config/tmux"},
    {"./awesome", "~/.config/awesome"},
    {"./nvim", "~/.config/nvim"},
    {"./mpd", "~/.config/mpd"},
}

local function make_themed_config(theme_name)

    local theme_path = "./themes/" .. theme_name

    return {
        { theme_path .. "/console_colors.sh", "~/.config/console_colors.sh" },
        { theme_path .. "/alacritty/", "~/.config/alacritty" },
        { theme_path .. "/picom/", "~/.config/picom" },
        { theme_path .. "/starship/", "~/.config/starship" },
        table.unpack(_common_config)
    }

end


-- return config_substitute_home(home, test_config_inexistent_sources)
-- return config_substitute_home(home, test_config_multiple_times_target)
-- return config_substitute_home(home, test_config_source_and_target_point_to_the_same_place)
-- return config_substitute_home(home, test_config_intermediary_target_directories_dont_exist)
-- return config_substitute_home(home, test_config_targets_exist)
return make_themed_config("LateForLunch")

