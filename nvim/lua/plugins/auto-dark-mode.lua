return {
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      set_dark_mode = function()
        vim.api.nvim_set_option_value("background", "dark", {})
        vim.cmd "colorscheme gitlab_dark"
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value("background", "light", {})
        vim.cmd "colorscheme gitlab_light"
        -- vim.cmd "colorscheme github_light_default"
      end,
      update_interval = 3000,
      fallback = "dark",
    },
  },
}
