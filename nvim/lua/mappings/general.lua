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

-- In nvim nested in a mux shell, moving past the last split moves to the mux's
-- next pane (mux move), the way smart-splits hands off to tmux.
require("smart-splits").setup({
  at_edge = function(ctx)
    if vim.g.mux or not vim.env.NVIM then return ctx.wrap() end
    local ok, chan = pcall(vim.fn.sockconnect, "pipe", vim.env.NVIM, { rpc = true })
    if not ok or chan == 0 then return ctx.wrap() end
    local dir = ({ left = "h", down = "j", up = "k", right = "l" })[ctx.direction]
    pcall(vim.rpcrequest, chan, "nvim_exec_lua", "local mux = require('mux'); if mux.move then mux.move(...) end", { dir })
    vim.fn.chanclose(chan)
  end,
})

vim.keymap.set({ "n", "t" }, "<C-h>", require("smart-splits").move_cursor_left, { desc = "Focus split left" })
vim.keymap.set({ "n", "t" }, "<C-j>", require("smart-splits").move_cursor_down, { desc = "Focus split below" })
vim.keymap.set({ "n", "t" }, "<C-k>", require("smart-splits").move_cursor_up, { desc = "Focus split above" })
vim.keymap.set({ "n", "t" }, "<C-l>", require("smart-splits").move_cursor_right, { desc = "Focus split right" })

vim.keymap.set("n", "<leader>z", "<cmd>NoNeckPain<CR>", { desc = "Toggle zen mode" })
