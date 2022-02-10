-- NOTE: color file must exist at path galaxyline/themes/colors.lua
-- can't currently change it from that

-- Check if the end user is using this fork with themes support
-- before trying to add the theme
--
-- NOTE: not working
-- local present, galaxyline_colors = pcall(require, 'galaxyline.themes.colors')
-- if not present then
--   return
-- end

-- NOTE: colors from onedark
-- {
--     black,
--     bg0,
--     bg1,
--     bg2,
--     bg3,
--     bg_d,
--     bg_blue,
--     bg_yellow,
--     fg,
--     purple,
--     green,
--     orange,
--     blue,
--     yellow,
--     cyan,
--     red,
--     grey,
--     light_grey,
--     dark_cyan,
--     dark_red,
--     dark_yellow,
--     dark_purple,
--     diff_add,
--     diff_delete,
--     diff_change,
--     diff_text
-- }

local c = require 'onedark.colors'

-- NOTE: https://github.com/NTBBloodbath/galaxyline.nvim/blob/main/lua/galaxyline/themes/eviline.lua
-- is currently hard-coded to use colors from 'doom-one' theme :-(

local colors = {}

-- NOTE: these are actually onedark colors
colors['doom-one'] = {
  bg = c.bg,
  fg = c.fg,
  fg_alt = c.fg,
  yellow = c.yellow,
  cyan = c.cyan,
  green = c.green,
  orange = c.orange,
  magenta = c.purple,
  blue = c.blue,
  red = c.red,
}

return colors
