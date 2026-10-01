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
-- Sent by scripts/nv-session.sh, not typed.
vim.keymap.set({ "n", "t" }, "<C-M-S-F12>", mux.switch_wanted, { desc = "Switch to the session in the want file" })

-- Smart C-\ (tmux's is_vim trick): a nested nvim gets the key; otherwise it
-- drops into normal mode over the scrollback, i.e. copy mode.
vim.keymap.set("t", "<C-\\>", function()
  if mux.fg_is_nvim() then
    vim.api.nvim_chan_send(vim.bo.channel, "\28")
  else
    vim.cmd.stopinsert()
  end
end, { desc = "Copy mode / pass to nested nvim" })

-- Tool launchers that used to be tmux-only keys.
local function launcher(lhs, nvim_keys, shell_cmd, desc)
  vim.keymap.set("t", lhs, function() mux.launch(nvim_keys, shell_cmd) end, { desc = desc })
end
launcher("<C-S-y>", "\27[17~", "y", "Yazi") -- F6
launcher("<C-S-u>", "\27:Files\r", "ff", "Find files")
launcher("<C-S-i>", "\27:RG\r", "fw", "Grep")
launcher("<C-S-n>", "\27:LazyGit\r", "gg", "LazyGit")
launcher("<C-M-S-s>", "", "nv", "Switch session")
