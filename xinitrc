#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi


xset r rate 210 40 & # fast cursor
picom &
xrandr --dpi 82 &

# xrandr --output DP-0 --mode 2560x1440 --scale 1x1 --output HDMI-0 --same-as DP-0 --mode 1920x1080 --scale 1.333x1.333 &
# ~/dotfiles/screen_layout/detect_and_configure_screens.sh &
# exec xfce4-session
exec awesome
# exec ~/c/exp/sol/sol
exec pulseaudio
# exec xwm
