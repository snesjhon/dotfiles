vim.keymap.set("n", "-", "<cmd>vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", ",", "<cmd>:bprev<CR>", { desc = "prev" })
vim.keymap.set("n", ".", "<cmd>:bnext<CR>", { desc = "next" })
vim.keymap.set("n", "<C-S-q>", "<cmd>q<CR>", { desc = "Quit window" })
vim.keymap.set("n", "<leader>s", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>/", "gcc", { remap = true, silent = true, desc = "Toggle comment" })
vim.keymap.set("x", "<leader>/", "gc", { remap = true, silent = true, desc = "Toggle comment" })
vim.keymap.set("n", "vv", "V", { desc = "Select line" })
vim.keymap.set("n", "L", "$", { desc = "Go to end of line" })
vim.keymap.set("n", "H", "^", { desc = "Go to first non-blank character" })

local splits = require("splits")
for key, dir in pairs({ ["<C-h>"] = "h", ["<C-j>"] = "j", ["<C-k>"] = "k", ["<C-l>"] = "l" }) do
  vim.keymap.set({ "n", "t" }, key, function() splits.move(dir) end, { desc = "Focus split " .. dir })
end
vim.keymap.set("n", "<C-S-h>", function() splits.resize("h") end, { desc = "Resize split left" })
vim.keymap.set("n", "<C-S-l>", function() splits.resize("l") end, { desc = "Resize split right" })

vim.keymap.set("n", "<leader>z", "<cmd>NoNeckPain<CR>", { desc = "Toggle zen mode" })
vim.keymap.set("n", "+", function() require("snacks").zen.zoom() end, { desc = "Zoom window" })
