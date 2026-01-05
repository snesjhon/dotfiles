return {
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    config = true,
    opts = {
      preview = {
        enable = false,
        icon_provider = "mini", -- "mini" or "devicons"
      },
    },
    keys = {
      {
        "<leader>m",
        nil,
        desc = "Markview",
      },
      {
        "<leader>mt",
        "<cmd>Markview Toggle<cr>",
        desc = "Markview Toggle",
      },
    },
    dependencies = {
      "saghen/blink.cmp",
    },
  },
}
