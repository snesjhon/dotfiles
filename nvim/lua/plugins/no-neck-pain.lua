return {
  {
    "shortcuts/no-neck-pain.nvim",
    version = "*",
    lazy = false,
    opts = {
      width = 119,
      minSideBufferWidth = 10,
      autocmds = {
        skipEnteringNoNeckPainBuffer = true,
        enableOnVimEnter = true,
      },
      integrations = {
        dashboard = {
          enabled = true,
        },
      },
      buffers = {
        wo = {
          fillchars = "eob: ",
        },
      },
    },
  },
}
