-- Sessions for mux (installed by vim.pack), read through ~/.config/mux. See
-- mux's lua/mux/config.lua for the fields.
return {
  sessions = {
    dev = {
      path = "~/Developer",
      default = true,
      tabs = {
        { "dots", path = "~/Developer/dotfiles" },
        { "me", path = "~/Developer/me" },
      },
    },
  },
  -- One session per git worktree of the repos in the rig config.
  sources = { ["rig.source"] = "~/Developer/rig.nvim" },
  -- The float key shows rig's board over the tab.
  float = { "rig", "dash", "--float" },
}
