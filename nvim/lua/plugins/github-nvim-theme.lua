return {
  "projekt0n/github-nvim-theme",
  name = "github-nvim-theme",
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require("github-theme").setup {
      groups = {
        all = {
          StatusLine = { bg = "bg2", fg = "black" }, -- Make status line background transparent
          StatusLineNC = { bg = "bg2", fg = "black" }, -- Make inactive status line transparent too
        },
        github_light_default = {
          -- Fix low contrast for git changes in snacks explorer (light mode only)
          -- GitSignsChange = { fg = "#fb8500" },
          -- GitSignsChangeNr = { fg = "#fb8500" },
          -- GitSignsChangeLn = { fg = "#fb8500" },
          -- DiffChange = { fg = "#fb8500" },
          -- DiffText = { fg = "#fb8500", bg = "#fff5b4" },
        },
      },
    }
  end,
}
