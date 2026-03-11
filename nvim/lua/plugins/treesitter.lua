return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "ruby" },
      indent = {
        enable = true,
        disable = { "ruby" },
      },
    },
  },
}
