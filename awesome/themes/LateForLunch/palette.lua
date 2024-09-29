
---------------------------
-- Late For Lunch
---------------------------

local theme_name = "LateForLunch"
local dpi = require("beautiful.xresources").apply_dpi

local theme = {}
local home = os.getenv("HOME")
local theme_folder = home .. '/.config/awesome/themes/'..theme_name
local tcolor = require("tools.color")
theme.theme_path = theme_folder

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = "/usr/share/icons/Paper"

-------------------
-- Fonts
-------------------
theme.font_family_1 = "Roboto"
theme.font_weight_1 = "Medium"
theme.font_size_1 = 12
theme.monospace_font_family = "RobotoMono"
theme.monospace_font_size = 12

-- local color1 = "#221b18"
-- local color1 = tcolor.hsl(18, 0.17, 0.11)
-- local color2 = tcolor.rgb_from_string("#201a17")

local color1 = tcolor.hsl(0, 0, 1)
-- local color2 = tcolor.rgb_from_string("#221b18")
local color2 = tcolor.rgb_from_string("#170e0a")
-- local color3 = tcolor.hsl(15, 0.19, 0.13)

theme.bar_height = 60

-- theme.bg = color1
-- theme.bg2 = color3
theme.fg = color1
theme.bg = color2

theme.color1 = color1
theme.color2 = color2


-------------------
-- Gaps
-------------------
-- This could be used to manually determine how far away from the screen edge
-- the bars / notifications should be.
theme.screen_margin = dpi(10)
theme.useless_gap   = dpi(5)

-------------------
-- Borders
-------------------
theme.border_width  = 1
theme.border_radius = 11 -- set roundness of corners


-- theme.wallpaper = home ..'/images/elementaryos/wallpapers/Ashim_DSilva.jpg'
-- theme.wallpaper = home .. '/EHGgqUq.jpg'
-- theme.wallpaper = home .. '/images/21_9_wallpapers/Swe2Jap.png'
-- theme.wallpaper = home .. '/images/21_9_wallpapers/1y1cMG2.jpg'
-- theme.wallpaper = home .. "/images/16_9_wallpapers/4d6ed381483061.5d00e215315d2.jpg"
-- theme.wallpaper = home .. "/images/16_9_wallpapers/3e9b1878521481.5ca708b1684c4.jpg"
-- theme.wallpaper = theme_folder .. "cael_gibran_the_spirits_moon_and_sun.jpg"
-- theme.wallpaper = theme_folder .. "21_9_girl_sketch.png"
-- theme.wallpaper = "~/img/wallpapers/16_9/pexels-oleksandr-tiupa-192136.jpg"
-- theme.wallpaper = "~/img/wallpapers/16_9/pexels-rafael-cerqueira-4737484.jpg"
-- theme.wallpaper = "~/img/wallpapers/16_9/pexels-joshimer-biñas-12728339.jpg"
-- theme.wallpaper = "~/img/wallpapers/16_9/camille-sule-giant1.jpg"
-- theme.wallpaper = "~/img/wallpapers/16_9/gavryl-for-inprnt.jpg"
theme.wallpaper = "~/.config/awesome/themes/LateForLunch/gavryl-1.jpg"
-- theme.wallpaper = "~/img/wallpapers/16_9/gavryl-2.jpg"
-- theme.wallpaper = "~/img/wallpapers/16_9/gavryl-3.jpg"
-- theme.wallpaper = "~/img/wallpapers/16_9/gavryl-artwork-159.jpg"
-- theme.wallpaper = "~/img/wallpapers/16_9/sylvain-sarrailh-bridgehdartstation.jpg"
-- theme.wallpaper = home .. "/images/21_9_wallpapers/sxymz82ov2911.png"

return theme

