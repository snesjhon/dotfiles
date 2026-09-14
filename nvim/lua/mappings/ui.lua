vim.keymap.set("n", "<leader>uw", "<cmd>set wrap!<CR>", { desc = "Toggle wrap" })
vim.keymap.set("n", "gf", function() require("conform").format { async = true, lsp_fallback = true } end, { desc = "Format buffer" })
