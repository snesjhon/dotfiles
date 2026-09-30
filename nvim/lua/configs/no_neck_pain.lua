require("no-neck-pain").setup({
  autocmds = {
    skipEnteringNoNeckPainBuffer = true,
    enableOnVimEnter = not vim.g.mux, -- the mux (sessions.lua) is all terminals; no padding
  },
  integrations = {
    dashboard = {
      -- Enabling this makes the plugin turn itself on at startup, so skip it in the mux.
      enabled = not vim.g.mux,
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
