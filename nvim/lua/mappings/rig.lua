-- Keys for rig sessions (~/Developer/rig.nvim). They only apply inside a
-- session, and the move keys in an nvim opened from one. Loaded last, so these
-- win over the same keys set elsewhere in the config.
require("rig").keys({
  ["<C-S-,>"] = "prev_tab",
  ["<C-S-.>"] = "next_tab",
  ["<C-M-S-n>"] = "new_tab",
  ["<C-M-S-q>"] = "close_tab",
  ["<C-M-S-v>"] = "split",
  ["<C-h>"] = "left",
  ["<C-j>"] = "down",
  ["<C-k>"] = "up",
  ["<C-l>"] = "right",
  ["<C-S-h>"] = "resize_left",
  ["<C-S-l>"] = "resize_right",
  ["<C-\\>"] = "copy_mode",
  ["<C-S-o>"] = "sidebar",
  ["<C-S-d>"] = "dash",
}, {
  launch = {
    ["<C-S-y>"] = { nvim = "\27[121;6u", shell = "y" }, -- <C-S-y> as CSI-u, for the nvim's own Yazi key
    ["<C-S-u>"] = { nvim = ":Files", shell = "nvim +Files" },
    ["<C-S-i>"] = { nvim = ":RG", shell = "nvim +RG" },
    ["<C-S-n>"] = { nvim = ":LazyGit", shell = "gg" },
  },
})
