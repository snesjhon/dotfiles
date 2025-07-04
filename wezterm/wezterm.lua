-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

-- or, changing the font size and color scheme.
config.font_size = 15
-- config.color_scheme = "Github Dark"

local function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return "Dark"
end

local function scheme_for_appearance(appearance)
  if appearance:find("Dark") then
    return "GitHub Dark"
  else
    return "Github (base16)"
  end
end

config.color_scheme = scheme_for_appearance(get_appearance())
config.window_decorations = "RESIZE"

-- Finally, return the configuration to wezterm:
return config
