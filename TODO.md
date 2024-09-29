
## TODO:
[ ] clean up my .conifg/alacritty/alacritty.yml
[ ] write a a better tmux config
[ ] write a custom htop config
[ ] add multi-monitor support in sol and get rid of the "screen_config" directory

## To link
[ ] awesomewm config
[ ] alacritty config
[ ] ".zshrc" to "~/.config/zshrc/.zshrc" and export $ZDOTDIR="$HOME/.config/zshrc/"
[ ] fontconfig
[ ] picom config
[ ] starship config
[ ] fonts from ~/graphics/fonts
[ ] the /etc/X11/xorg.conf.d/50-mouse-acceleration.conf file
[ ] xinitrc to ~/.xinitrc

## DON'T FORGET WHEN WRITING AN INSTALL SCRIPT
[ ] install lua5.1
[ ] install luajit
[ ] install luarocks
[ ] install mpd (dont forget to `ln -s /etc/sv/mpd /var/service`)
[ ] install mpc
[ ] install vimpc
[ ] install picom
[ ] install zsh
[ ] install pulseaudio <!-- TODO: get exactly the packages I need to make audio work-->
[ ] install alsa <!-- TODO: get exactly the packages I need to make audio work-->
[ ] install font-config
[ ] install ImageMagick (for my screenshot-taking script)
[ ] install yt-dlp
[ ] luarocks install busted
[ ] luarocks install lfs
[ ] export $ZDOTDIR = "$HOME/config/zshrc/"
[ ] check what the colors set in .Xresources do
[ ] link all fonts from ~/graphics/fonts
[ ] install neovim v >= 0.8
[ ] install `xorg-xset` and `xorg-xinput`
[ ] make sure to get all plugins for nvim properly
[ ] install `dbus`
[ ] do `ln -s /etc/sv/dbus /var/service`
[ ] do `ln -s /etc/sv/elogind /var/service`
[ ] install `nvidia`, `nvidia-dkms`, `linux-firmware-nvidia`, `nvidia-firmware`, `nvidia-gtklibs`, `nvidia-libs`

## When writing an install script for void linux
* packages:
    * luarocks-lua51
    * neovim
    * xorg-minimal
    * sol <!-- TODO: write a package for void -->
    * sane <!-- TODO: write a package for void -->
    * mpd
    * curl
    * gcc
    * exa (to replace ls)
    * nvidia <!-- unfortunately not opensource, but works much better than nouveau. TODO: get an AMD card -->
    * xset
    * xrandr <!-- This will probably be needed for sol in the future -->
    <!-- NEEDED FOR SOL: -->
    * libxdg-basedir
    * xcb-util-keysyms
    * xcb-util-wm
    * xcb-util-cursor
    * xcb-util-errors <!-- TODO: maybe I can add this as an optional dependency because this depends on python 3 which we'd like to avoid -->
    * libxkbcommon
    * cairo
    * make
    * libev
    * Luajit
    * pkg-config

* luarocks:
    luafilesystem
    lgi

* packages for devel:
    <!-- NEEDED FOR SOL: -->
    * lua51-devel
    * libxcb-devel
    * libxdg-basedir-devel
    * xcb-util-keysyms-devel
    * xcb-util-wm
    * xcb-util-cursor-devel
    * xcb-util-errors <!-- TODO: maybe I can add this as an optional dependency because this depends on python 3 which we'd like to avoid -->
    * libxkbcommon-devel
    * cairo-devel
    * libev-devel
    * Luajit-devel
    * gobject-introspection <!-- for lgi; TODO: write my own alternative to this, because this too uses python, which I would like to avoid depending upon -->

* for microcode:
    * install package `void-repo-nonfree`
    * run `sudo xbps-install -S intel-ucode`
    * install package `iucode-tool`
    * run `sudo iucode_tool -Ll -S --write-earlyfw=/boot/intel-ucode.img.new -tb /lib/firmware/intel-ucode`
    * run `mv /boot/intel-ucode.img.new /boot/intel-ucode.img` as `su`
    * then, make sure to add the `initrd=\boot\intel-ucode.img initrd=\boot\initramfs-<kernel_version>.img` boot parameters to "/boot/refind_linux.conf"

* To download when writing an install script
    * my own private "fonts" repo
    * my sol wm config repo
    * my other dotfiles repo

## before starting to make vids
[ ] clear ".zsh_history"


## Write command line utilities which would be helpful
[ ] `flatten`: takes a directory, and recursively returns a space-separated list 
    containing absolute paths to all the files inside
[x] `blink`: command line utility which scans a config file, and links all files
    listed in the config to the specified path. (useful for easier deployment
    of config files and keeping all config files in one place)
