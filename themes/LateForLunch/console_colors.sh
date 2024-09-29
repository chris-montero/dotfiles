

if [ "$TERM" = "linux" ]; then
        # background 
        # printf "\033]P01e1613" # GOOD (dark brown)
        # printf "\033]P01d1512" # GOOD (dark brown)
        printf "\033]P0170f0d" # GOOD (dark brown)
        # color normally used for string names
        printf "\033]P1e8b270" # GOOD (sand yellow)
        # color of valid command, color of tmux bottom bar
        # printf "\033]P2684830" # (medium faded brown 2)
        printf "\033]P2c25028" # GOOD (darker halloween orange)
        # line number color in nvim:
        printf "\033]P340251e" # GOOD (medium dark brown)
        # comments color, "last modified date" in `ls`:
        printf "\033]P4665048" # GOOD (medium faded brown)
        # color of macros, #include symbol in C
        printf "\033]P5ae303a" # GOOD (autumn red)
        # symlinks path color, color of core/common lua functions (require, _G, etc):
        # printf "\033]P6544e70" # (gray blue)
        printf "\033]P6a878fd" # GOOD (halloween medium purple)
        # normally "white" color. also color for most "normal" things like function calls, variable names, text file names, etc.:
        printf "\033]P7ffeed4" # GOOD (very light yellow)

        # color of '->' arrows and hyphens in output of `ls -alhg`
        printf "\033]P8303030" # dark gray
        # color of "incorrect command" in prompt:
        printf "\033]P9a62e38" # GOOD (light orange)
        # color of file size in ls, color of executables, color of C keywords (static, void, int, struct)
        printf "\033]Pa3ea0e8" # (medium blue)
        # file owner name, lua "local" keyword, c "if, while, else, for, return" keywords:
        printf "\033]Pbd85830" # GOOD (halloween orange)
        # printf "\033]Pc40aff0" # (clear sky blue)
        # color of directories
        printf "\033]Pc6b3827" # GOOD (dark brick red)
        # color for machine name in prompt
        # printf "\033]Pdf0c038" # (intense yellow)
        printf "\033]Pd584bbb" # (halloween blue)
        # file that is symlink, color of user name in prompt:
        printf "\033]Pe9890a8" # (very light blue)
        # @ symbol in prompt
        printf "\033]Pfd85830" # (halloween orange)
fi

# printf "\033]P44858d8" # NOTE: decent blue color
# printf "\033]P42878fd" # NOTE: decent blue color
# printf "\033]P4f65048" # NOTE: decent faded orange color
# printf "\033]P6a878fd" # GOOD (halloween medium purple) 
# printf "\033]P63a4860" # GOOD (metal grey)
# printf "\033]P2085830" # GOOD (dark green)
# printf "\033]P3e92f52" # (bright neon pink)
# printf "\033]P1e8b270" # GOOD (sand yellow)
# printf "\033]P640aff0" # (neon bright blue)

