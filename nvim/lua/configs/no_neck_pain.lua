require("no-neck-pain").setup({
  autocmds = {
    skipEnteringNoNeckPainBuffer = true,
    enableOnVimEnter = true
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
