return {
  "projekt0n/github-nvim-theme",
  name = "github-nvim-theme",
  config = function()
    require("github-theme").setup {
      groups = {
        all = {
          StatusLine = { bg = "bg0" }, -- Make status line background transparent
          StatusLineNC = { bg = "bg0" }, -- Make inactive status line transparent too
        },
      },
    }
  end,
}
