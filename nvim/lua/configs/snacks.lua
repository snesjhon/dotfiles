require("snacks").setup({
  -- Backdrop dims whatever's behind a float by blending 60% of it with
  -- black. On a light theme that produces a flat neutral gray that reads
  -- like a different, colorless theme bleeding through around the modal
  -- -- drop it instead of trying to recolor it.
  styles = {
    float = { backdrop = false },
  },
  picker = {
    enabled = true,
    sources = {
      files = { cmd = "rg" },
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
      { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
    },
  },
})
-- {
--   sections = {
--     { section = "header" },
--     {
--       pane = 2,
--       section = "terminal",
--       cmd = "colorscript -e square",
--       height = 5,
--       padding = 1,
--     },
--     { section = "keys", gap = 1, padding = 1 },
--     { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
--     { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
--     {
--       pane = 2,
--       icon = " ",
--       title = "Git Status",
--       section = "terminal",
--       enabled = function()
--         return Snacks.git.get_root() ~= nil
--       end,
--       cmd = "git status --short --branch --renames",
--       height = 5,
--       padding = 1,
--       ttl = 5 * 60,
--       indent = 3,
--     },
--     { section = "startup" },
--   },
-- }
