local truncate_width = vim.api.nvim_win_get_width(0) * 0.8
---@module 'snacks'
---@type LazySpec
return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    indent = {
      enabled = false,
    },
    terminal = {
      win = {
        position = "float",
        backdrop = 80,
        height = 0.9,
        width = 0.8,
        border = "hpad",
        keys = {
          term_hide = {
            "<F7>",
            function(self) self:hide() end,
            mode = "t",
            desc = "Hide Terminal",
          },
        },
      },
    },
    dashboard = {
      preset = {
        header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
        ]],
      },
    },
    picker = {
      jump = {
        reuse_win = true,
      },
      formatters = {
        file = {
          truncate = truncate_width,
          filename_first = true,
        },
      },
    },
  },
}
