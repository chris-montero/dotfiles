#!/usr/bin/env zsh
Xephyr -screen 1600x900 :5 & sleep 1; env DISPLAY=:5 awesome
# Xephyr -screen 2560x1440 :5 & sleep 1; env DISPLAY=:5 awesome
# Xephyr -screen 1920x1080 :5 & sleep 1; env DISPLAY=:5 awesome

