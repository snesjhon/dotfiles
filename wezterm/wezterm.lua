-- Pull in the wezterm API
local wezterm = require("wezterm")
local colors = require("colors")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

config.font_size = 15

config.color_schemes = colors

local function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Github Dark Default"
	else
		return "Github Light Default"
	end
end

config.color_scheme = scheme_for_appearance(get_appearance())

config.window_decorations = "RESIZE"
config.font = wezterm.font("Hack Nerd Font")

config.keys = {
	{
		key = "P",
		mods = "CTRL",
		action = wezterm.action.DisableDefaultAssignment,
	},
}

return config
