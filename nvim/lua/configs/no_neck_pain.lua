require("no-neck-pain").setup({
  autocmds = {
    skipEnteringNoNeckPainBuffer = true,
    enableOnVimEnter = not vim.g.mux, -- the mux (sessions.lua) is all terminals; no padding
  },
  integrations = {
    dashboard = {
      enabled = true,
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
