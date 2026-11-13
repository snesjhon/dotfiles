-- No padding in rig sessions, which are all terminals, or in rig's board,
-- which lays out its own full-width views.
local pad = not (vim.g.rig_session or vim.g.rig_dash)

require("no-neck-pain").setup({
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
  buffers = {
    right = {
      enabled = false
    },
    wo = { fillchars = "eob: ,vert: " }
  }
})
