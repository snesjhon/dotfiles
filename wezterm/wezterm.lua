-- Pull in the wezterm API
local wezterm = require("wezterm")
local colors = require("colors")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

-- FORMAT
config.window_decorations = "RESIZE"
config.font = wezterm.font("FiraCode Nerd Font", { weight = "Medium" })
config.line_height = 1.2
config.font_size = 15

-- COLORS
config.color_schemes = colors

local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Github Dark Default"
	else
		return "Github Light Default"
	end
end

-- Dark Mode Toggle
wezterm.on("window-config-reloaded", function(window)
	local overrides = window:get_config_overrides() or {}
	local appearance = window:get_appearance()
	local scheme = scheme_for_appearance(appearance)
	if overrides.color_scheme ~= scheme then
		overrides.color_scheme = scheme
		window:set_config_overrides(overrides)
	end
end)

-- CURSOR
-- disable blinking cursor within terminal instances
config.default_cursor_style = "SteadyBlock"
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.cursor_blink_rate = 0

-- TAB
wezterm.on("format-tab-title", function(tab)
	local cwd = tab.active_pane.current_working_dir
	if cwd then
		local path = cwd.file_path or cwd
		local basename = path:match("([^/]+)/?$") or path
		return basename
	end
	return tab.tab_title
end)

config.window_frame = {
	font = wezterm.font("FiraCode", { weight = "Medium" }),
	font_size = 14.0,
}

-- KEYS
config.keys = {
	{
		key = "I",
		mods = "CTRL",
		action = wezterm.action.ActivateCommandPalette,
	},
	{
		-- ActiveCopyMode within wezterm unless we're in nvim mode
		key = "P",
		mods = "CTRL",
		action = wezterm.action_callback(function(window, pane)
			local process_name = string.gsub(pane:get_foreground_process_name(), "(.*/)(.*)", "%2")
			if process_name == "nvim" or process_name == "vim" then
				-- Neovim is running, pass the key through
				window:perform_action({ SendKey = { key = "P", mods = "CTRL" } }, pane)
			else
				-- Neovim is not running, activate copy mode
				window:perform_action(wezterm.action.ActivateCopyMode, pane)
			end
		end),
	},
}

return config
