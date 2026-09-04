vim.keymap.set("n", "-", "<cmd>vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", ",", "<cmd>:bprev<CR>", { desc = "prev" })
vim.keymap.set("n", ".", "<cmd>:bnext<CR>", { desc = "next" })
vim.keymap.set("n", "<C-S-q>", "<cmd>q<CR>", { desc = "Quit window" })
vim.keymap.set("n", "<leader>s", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>/", "gcc", { remap = true, silent = true })
vim.keymap.set("x", "<leader>/", "gc", { remap = true, silent = true })
vim.keymap.set("n", "vv", "V")
vim.keymap.set("n", "L", "$")
vim.keymap.set("n", "H", "^")

-- UI --------------------------------------------------
vim.keymap.set("n", "<leader>uw", "<cmd>set wrap!<CR>", { desc = "Toggle wrap" })
vim.keymap.set("n", "gf", function() require("conform").format { async = true, lsp_fallback = true } end, { desc = "Format buffer" })

-- Smart-Splits
local function nav(wincmd, tmux_dir)
  return function()
    local win = vim.api.nvim_get_current_win()
    vim.cmd("wincmd " .. wincmd)
    if vim.env.TMUX and vim.api.nvim_get_current_win() == win then
      vim.system({ "tmux", "select-pane", tmux_dir })
    end
  end
end
vim.keymap.set("n", "<C-h>", nav("h", "-L"), { desc = "Window/pane left" })
vim.keymap.set("n", "<C-j>", nav("j", "-D"), { desc = "Window/pane down" })
vim.keymap.set("n", "<C-k>", nav("k", "-U"), { desc = "Window/pane up" })
vim.keymap.set("n", "<C-l>", nav("l", "-R"), { desc = "Window/pane right" })
