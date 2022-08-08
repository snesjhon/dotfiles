require("github-theme").setup({
    theme_style = "light"
})
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    adaptive_size = true,
    mappings = {
      list = {
        { key = "u", action = "dir_up" },
      },
    },
    side = 'right',
preserve_window_proportions = true
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})
print('plugins installed')
