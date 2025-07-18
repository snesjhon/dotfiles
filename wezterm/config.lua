local wezterm = require("wezterm")
local colors = require("colors")
local helpers = require("helpers")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Find color scheme
local file = io.open(wezterm.config_dir .. "/colorscheme", "r")
local color_scheme_sync = "Github Dark Default"
if file then
	color_scheme_sync = file:read("*a")
	file:close()
end
-- else
-- 	config.color_scheme = "Tokyo Night Day"
-- end

config = {
	-- FORMAT
	window_decorations = "RESIZE",
	font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = "Medium" }),
	line_height = 1.2,
	font_size = 15,

	-- COLORS
	color_schemes = colors,
	color_scheme = color_scheme_sync,
	-- color_scheme = helpers.scheme_for_appearance(helpers.get_appearance()),

	-- Additional settings to remove borders
	enable_scroll_bar = false,
	window_background_opacity = 1.0,

	-- CURSOR
	cursor_blink_rate = 0,

	-- config.window_frame = {
	-- 	font = wezterm.font("FiraCode", { weight = "Medium" }),
	-- 	font_size = 14.0,
	-- }

	window_padding = {
		top = 5,
		bottom = 0,
	},

	-- KEYS
	keys = {
		{
			key = "I",
			mods = "CTRL",
			action = wezterm.action.ActivateCommandPalette,
		},
		{ key = "r", mods = "CTRL|SHIFT", action = wezterm.action.ResetTerminal },
		{
			-- ActiveCopyMode within wezterm unless we're in nvim mode
			key = "P",
			mods = "CTRL",
			action = helpers.localKeybind({ key = "P", mods = "CTRL" }, wezterm.action.ActivateCopyMode),
		},

		-- Workspace navigation
		{ key = "w", mods = "CTRL|SHIFT", action = wezterm.action.ShowLauncher },

		-- Quick workspace switching
		{ key = "l", mods = "CTRL|SHIFT", action = wezterm.action.SwitchToWorkspace({ name = "logs" }) },
		{ key = "1", mods = "CTRL|SHIFT", action = wezterm.action.SwitchToWorkspace({ name = "backend" }) },
		{ key = "2", mods = "CTRL|SHIFT", action = wezterm.action.SwitchToWorkspace({ name = "frontend" }) },

		-- Pause/Resume functionality for logs workspace
		-- { key = "space", mods = "CTRL|SHIFT", action = helpers.toggleLogsPause },
	},
}

return config
