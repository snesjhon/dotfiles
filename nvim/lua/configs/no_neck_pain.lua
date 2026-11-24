-- No padding in mux sessions, which are all terminals, or in rig's board,
-- which lays out its own full-width views.
local pad = not (vim.g.mux_session or vim.g.rig_dash)

require("no-neck-pain").setup({
  width = 120,
  autocmds = {
    skipEnteringNoNeckPainBuffer = true,
    enableOnVimEnter = pad,
  },
  integrations = {
    dashboard = {
      -- Enabling this makes the plugin turn itself on at startup.
      enabled = pad,
      filetypes = { "snacks_dashboard" },
    }
  },
})
