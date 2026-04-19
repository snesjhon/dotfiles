return {
  "folke/sidekick.nvim",
  opts = {
    nes = { enabled = false },
    cli = {
      win = {
        layout = "float",
        float = {
          width = 0.4,
          height = 0.99,
          row = 0,
          col = 1,
          border = "single",
        },
        wo = { wrap = true },
      },
    },
  },
}
