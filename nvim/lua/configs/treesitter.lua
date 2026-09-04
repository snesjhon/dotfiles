require("nvim-treesitter").install({ "javascript", "typescript", "tsx" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  callback = function() vim.treesitter.start() end,
})
