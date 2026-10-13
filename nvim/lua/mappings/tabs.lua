if not vim.g.mux then return end
local mux = require("mux")

-- The outer nvim owns only these keys; everything else in a terminal must reach
-- the shell or the nvim nested in it. So drop every global terminal-mode map
-- the rest of the config set (smart-splits C-hjkl, <C-S-o>, <C-S-y>, ...).
for _, map in ipairs(vim.api.nvim_get_keymap("t")) do
  vim.keymap.del("t", map.lhs)
end

vim.keymap.set({ "n", "t" }, "<C-S-,>", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
vim.keymap.set({ "n", "t" }, "<C-S-.>", "<cmd>tabnext<CR>", { desc = "Next tab" })
vim.keymap.set({ "n", "t" }, "<C-M-S-n>", mux.new_tab, { desc = "New tab" })
vim.keymap.set({ "n", "t" }, "<C-M-S-q>", mux.close_tab, { desc = "Close tab" })
vim.keymap.set({ "n", "t" }, "<C-M-S-v>", mux.vsplit, { desc = "Split with a new shell" })
-- Sent by scripts/mux.sh, not typed.
vim.keymap.set({ "n", "t" }, "<C-M-S-F12>", mux.switch_wanted, { desc = "Switch to the session in the want file" })

-- Smart C-\: a nested nvim gets the key; otherwise it
-- drops into normal mode over the scrollback, i.e. copy mode.
vim.keymap.set("t", "<C-\\>", function()
  if mux.fg_is_nvim() then
    vim.api.nvim_chan_send(vim.bo.channel, "\28")
  else
    vim.cmd.stopinsert()
  end
end, { desc = "Copy mode / pass to nested nvim" })

-- A nested nvim toggles its own terminal; otherwise the tab's sidebar shell.
-- The key is resent as CSI-u because the plain Ctrl encoding drops Shift
-- (<C-S-o> would arrive as <C-o>).
vim.keymap.set({ "n", "t" }, "<C-S-o>", function()
  if mux.fg_is_nvim() then
    vim.api.nvim_chan_send(vim.bo.channel, "\27[111;6u")
  else
    mux.toggle_sidebar()
  end
end, { desc = "Toggle terminal" })

-- C-hjkl move between panes. A nested nvim gets the key to move between its
-- own splits; a shell gets it only when there's no pane that way, so C-l still
-- clears a lone shell.
for key, dir in pairs({ ["<C-h>"] = "h", ["<C-j>"] = "j", ["<C-k>"] = "k", ["<C-l>"] = "l" }) do
  vim.keymap.set({ "n", "t" }, key, function()
    if vim.fn.mode() == "n" then
      mux.move(dir)
    elseif mux.fg_is_nvim() or not mux.move(dir) then
      vim.api.nvim_chan_send(vim.bo.channel, vim.keycode(key))
    end
  end, { desc = "Move to pane " .. dir })
end

-- Tool launchers: nvim's own picker when nvim is in front, else the shell tool.
local function launcher(lhs, nvim_keys, shell_cmd, desc)
  vim.keymap.set("t", lhs, function() mux.launch(nvim_keys, shell_cmd) end, { desc = desc })
end
launcher("<C-S-y>", "\27[121;6u", "y", "Yazi") -- <C-S-y> as CSI-u
launcher("<C-S-u>", "\27:Files\r", "ff", "Find files")
launcher("<C-S-i>", "\27:RG\r", "fw", "Grep")
launcher("<C-S-n>", "\27:LazyGit\r", "gg", "LazyGit")
launcher("<C-M-S-s>", "", "mux", "Switch session")
