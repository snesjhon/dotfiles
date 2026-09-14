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
  terminal = {
      win = {
        wo = {
          winbar = "",
        },
      },
    },
  dashboard = {
    enabled = true,
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
