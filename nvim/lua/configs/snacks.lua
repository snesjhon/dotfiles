require("snacks").setup({
  styles = {
    float = { backdrop = false },
  },
  picker = {
    enabled = true,
    sources = {
      files = { cmd = "rg" },
    },
  },
  notifier = { enabled = true },
  lazygit = {
    -- FloatBorder is too faint for the unfocused panels and tab names; matches lazygit/gitlab-*.yml.
    theme = { inactiveBorderColor = { fg = "Comment" } },
  },
  terminal = {
      win = {
        wo = {
          winbar = "",
        },
      },
    },
  dashboard = {
    enabled = not vim.g.mux, -- no dashboard in the mux (sessions.lua)
    preset = {
      header = [[
██╗   ██╗
██║   ██║
╚██╗ ██╔╝
 ╚████╔╝
  ╚═══╝]],
    },
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
      { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
    },
  },
})
