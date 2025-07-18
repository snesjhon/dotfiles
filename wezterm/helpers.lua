local wezterm = require("wezterm")
local M = {}

local function localKeybind(keys, action)
	return wezterm.action_callback(function(window, pane)
		local process_name = string.gsub(pane:get_foreground_process_name(), "(.*/)(.*)", "%2")
		if process_name == "nvim" or process_name == "vim" then
			-- Neovim is running, pass the key through
			window:perform_action({ SendKey = keys }, pane)
		else
			-- Neovim is not running, activate copy mode
			window:perform_action(action, pane)
		end
	end)
end

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

M.localKeybind = localKeybind
M.get_appearance = get_appearance
M.scheme_for_appearance = scheme_for_appearance

return M
