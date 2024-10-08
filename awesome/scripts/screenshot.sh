#!/bin/bash
# Screenshot wrapper
# Uses maim (which uses slop)
# Adapted from Elena's script

SCREENSHOTS_DIR=~/img/screenshots
TIMESTAMP="$(date +%Y.%m.%d-%H.%M.%S)"
FILENAME=$SCREENSHOTS_DIR/$TIMESTAMP.screenshot.png
PHOTO_ICON_PATH=~/.icons/oomox-only_icons/categories/scalable/applications-photography.svg

# -u option hides cursor
# -m option changes the compression level
#   -m 3 takes the shot faster but the file size is slightly bigger

if [[ "$1" = "-s" ]]; then
    # Area/window selection.
    notify-send "Select area to capture." --urgency low -i $PHOTO_ICON_PATH
    # make it screenshot a window and have it automatically add a fancy shadow
    # maim -u -m 3 -s $FILENAME
    maim -u -m 3 -s | convert - \( +clone -background black -shadow 80x3+5+5 \) +swap -background none -layers merge +repage $FILENAME
    if [[ "$?" = "0" ]]; then
        notify-send "Screenshot taken." --urgency low -i $PHOTO_ICON_PATH
    fi
elif [[ "$1" = "-c" ]]; then
    notify-send 'Select area to copy to clipboard.' --urgency low -i $PHOTO_ICON_PATH
    # Copy selection to clipboard
    #maim -u -m 3 -s | xclip -selection clipboard -t image/png
    maim -u -m 3 -s /tmp/maim_clipboard
    if [[ "$?" = "0" ]]; then
        xclip -selection clipboard -t image/png /tmp/maim_clipboard
        notify-send "Copied selection to clipboard." --urgency low -i $PHOTO_ICON_PATH
        rm /tmp/maim_clipboard
    fi
elif [[ "$1" = "-b" ]]; then
    # Browse with feh
    feh -g 1080x608 --scale-down "$(echo "$SCREENSHOTS_DIR"/*) | sort"
else
    # Full screenshot
    maim -u -m 3 $FILENAME
    notify-send "Screenshot taken." --urgency low -i $PHOTO_ICON_PATH
fi
