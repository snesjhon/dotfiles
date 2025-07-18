local wezterm = require("wezterm")

wezterm.on("window-config-reloaded", function(window)
	local file = io.open(wezterm.config_dir .. "/colorscheme", "r")
	local color_scheme_sync = "Github Dark Default"
	if file then
		color_scheme_sync = file:read("*a")
		file:close()
	end
	local overrides = window:get_config_overrides() or {}
	if overrides.color_scheme ~= color_scheme_sync then
		overrides.color_scheme = color_scheme_sync
		window:set_config_overrides(overrides)
	end
end)

-- Workspace startup configuration
wezterm.on("gui-startup", function(cmd)
	-- Create logs workspace with 3 windows
	local logs_tab, logs_pane, logs_window = wezterm.mux.spawn_window({
		workspace = "logs",
		cwd = wezterm.home_dir,
	})
	logs_tab:set_title("App Logs")

	-- Second log window
	local logs_tab2, logs_pane2 = logs_window:spawn_tab({
		cwd = wezterm.home_dir,
	})
	logs_tab2:set_title("DB Logs")

	-- Third log window
	local logs_tab3, logs_pane3 = logs_window:spawn_tab({
		cwd = wezterm.home_dir,
	})
	logs_tab3:set_title("System Logs")

	-- Create backend workspace
	local backend_tab, backend_pane, backend_window = wezterm.mux.spawn_window({
		workspace = "backend",
		cwd = wezterm.home_dir .. "/Developer", -- adjust path as needed
	})
	backend_tab:set_title("admin-web")

	-- Add shopify tab
	local shopify_tab, shopify_pane = backend_window:spawn_tab({
		cwd = wezterm.home_dir .. "/Developer", -- adjust path as needed
	})
	shopify_tab:set_title("shopify")

	-- Add merchant-analytics-api tab
	local analytics_tab, analytics_pane = backend_window:spawn_tab({
		cwd = wezterm.home_dir .. "/Developer", -- adjust path as needed
	})
	analytics_tab:set_title("merchant-analytics-api")

	-- Create frontend workspace
	local frontend_tab, frontend_pane, frontend_window = wezterm.mux.spawn_window({
		workspace = "frontend",
		cwd = wezterm.home_dir .. "/Developer", -- adjust path as needed
	})
	frontend_tab:set_title("admin-web")

	-- Add analytics-ui-components tab
	local ui_tab, ui_pane = frontend_window:spawn_tab({
		cwd = wezterm.home_dir .. "/Developer", -- adjust path as needed
	})
	ui_tab:set_title("analytics-ui-components")

	-- Start in logs workspace
	logs_window:gui_window():focus()
end)
