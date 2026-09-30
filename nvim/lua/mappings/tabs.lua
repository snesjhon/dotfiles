if not vim.g.mux then return end
local mux = require("sessions")

-- The outer nvim owns only these keys; everything else in a terminal must reach
-- the shell or the nvim nested in it. So drop every global terminal-mode map
-- the rest of the config set (smart-splits C-hjkl, <C-S-o>, <F6>, ...).
for _, map in ipairs(vim.api.nvim_get_keymap("t")) do
  vim.keymap.del("t", map.lhs)
end

vim.keymap.set({ "n", "t" }, "<C-S-,>", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
vim.keymap.set({ "n", "t" }, "<C-S-.>", "<cmd>tabnext<CR>", { desc = "Next tab" })
vim.keymap.set({ "n", "t" }, "<C-M-S-n>", mux.new_tab, { desc = "New tab" })
vim.keymap.set({ "n", "t" }, "<C-M-S-q>", mux.close_tab, { desc = "Close tab" })

-- Smart C-\ (tmux's is_vim trick): a nested nvim gets the key; otherwise it
-- drops into normal mode over the scrollback, i.e. copy mode.
vim.keymap.set("t", "<C-\\>", function()
  if mux.fg_is_nvim() then
    vim.api.nvim_chan_send(vim.bo.channel, "\28")
  else
    vim.cmd.stopinsert()
  end
end, { desc = "Copy mode / pass to nested nvim" })
