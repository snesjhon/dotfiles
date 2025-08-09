return {
  "projekt0n/github-nvim-theme",
  name = "github-nvim-theme",
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require("github-theme").setup {
      groups = {
        all = {
          StatusLine = { bg = "bg2", fg = "gray" }, -- Make status line background transparent
          StatusLineNC = { bg = "bg2", fg = "gray" }, -- Make inactive status line transparent too
          WinSeparator = { fg = "bg2" },
          DiffAdd = { fg = "NONE", bg = "#DAFBE1" },
          DiffChange = { fg = "NONE", bg = "#FFEBE9" },
          DiffText = { fg = "NONE", bg = "#FFCECB" },
        },
      },
    }
  end,
}
