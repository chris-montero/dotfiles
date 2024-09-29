
#TODO:
[x] implement a text element
[x] try & implement a very custom element that does its own drawing, and maybe also layout of its children. If unable, design a system to make it work.
[x] design some sort of reactive building framework
[x] rewrite viscanvas in elemental widget framework
[x] rewrite mathgraph in elemental widget framework
[x] rewrite mechanical in elemental widget framework
[x] add support for mouse movement in 'elemental' framework
[ ] implement setting functions for the rest of the properties of 'elemental' elements (or figure out if I even need setter functions)
[ ] implement a "continue" ween for weeny (or something similar), that smoothly animates something from where it currently is, to a given value
[ ] implement a "repeater" ween for weeny, that takes multiple weens, and creates one that repeats them (infinitely?)
[ ] test test test
[ ] add methods for removing and adding elements
[ ] write a good text element
[ ] add support for vertical text to the text element
[ ] figure out some way to write a prompt helper function
[ ] add dpi support
[ ] add rotation support for elemental
[ ] add scaling support for elemental
[ ] replace "offset_x" and "offset_y" element attributes with "translate_x" and "translate_y"
[ ] add systray support
[ ] use a profiler to take out expensive operations
[ ] add caching for results of "calculate_minimum_dimensions" methods
[ ] benchmark & optimize relayout subsystem
[ ] benchmark & optimize drawing subsystem
[ ] add clip_to_background property (or design a good api for clipping widgets to shapes)
[ ] check that mouse support works properly (especially with things like clipping to arbirary shapes, blocking mouse passthrough, etc.)
[ ] add support for radial gradients
[ ] add support for arbitrary surfaces as sources to elements
[ ] implement svg support (through an "svg" element or something like that)
[ ] implement an image element
[ ] implement MouseEntered and MouseLeft signals for all attached elements
[ ] find a good way of parameterizing values in elements. for example: using the <element>.geometry.width in esource.stop
[ ] turn the terminal colorscheme into the lvim background colorscheme
[ ] make everything have slightly higher contrast in the LateForLunch theme
[ ] make the weather widget's top-side highlight thicker, brighter, and add a glint to it so the whole widget has a 3d look to it
[ ] make the terminal color look a bit more orange (the same as the vim colorscheme color)
[ ] add a C for celsius in the UI of the weather app
[ ] write a really good billiards game
[ ] try to make it automatic that when a user presses mouse-down on a SCanvas, the mouse gets grabbed so that it will still recieve mouse events outside of the window until the user releases the mouse button

[ ] bugfix: the internal representation of the hsl and hsla colors from tools/color.lua go from 0-360 when creating it, but from 0-1 internally afterwards. fix that.
[ ] bugfix: check if the bg of a window changes in each frame. and redraw it if it does 
[ ] bugfix: Pango should normally give a user the ability to ask the text layout object: "what is the geometry (x, y, width, height) of each of the lines in this text layout?". But if you do this through lgi, then for some reason you don't get the correct information. I need to fix this bug in Pango or lgi to get this information correctly so we can correctly draw backgrounds on each of the lines of text
