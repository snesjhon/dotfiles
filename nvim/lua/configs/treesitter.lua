require("nvim-treesitter").install({ "javascript", "typescript", "tsx", "json", "java" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "java" },
  callback = function() vim.treesitter.start() end,
})
