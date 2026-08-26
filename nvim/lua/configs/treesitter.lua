-- No-op if already installed.
require("nvim-treesitter").install({ "javascript", "typescript", "tsx" })

-- Highlighting isn't automatic once a parser is installed; this turns it on
-- per filetype. Core Neovim already maps javascriptreact -> javascript and
-- typescriptreact -> tsx, so no extra parsers are needed for those.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  callback = function() vim.treesitter.start() end,
})
