---@module 'snacks'
---@type LazySpec
return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    indent = {
      enabled = false,
    },
    -- zen = {
    -- toggles = { dim = false, diagnostics = true, inlay_hints = false },
    -- show = {
    --   tabline = true,
    -- },
    -- win = {
    --   width = function() return math.min(120, math.floor(vim.o.columns * 0.75)) end,
    --   height = 0,
    --   -- backdrop = {
    --   --   transparent = false,
    --   --   win = { wo = { winhighlight = "Normal:Normal" } },
    --   -- },
    --   wo = {
    --     number = false,
    --     relativenumber = false,
    --     signcolumn = "no",
    --     foldcolumn = "0",
    --     winbar = "",
    --     list = false,
    --     showbreak = "NONE",
    --   },
    -- },
    -- opts.zen = {
    --       toggles = { dim = false, diagnostics = false, inlay_hints = false },
    --       on_open = function(win)
    --         -- disable snacks indent
    --         vim.b[win.buf].snacks_indent_old = vim.b[win.buf].snacks_indent
    --         vim.b[win.buf].snacks_indent = false
    --       end,
    --       on_close = function(win)
    --         -- restore snacks indent setting
    --         vim.b[win.buf].snacks_indent = vim.b[win.buf].snacks_indent_old
    --       end,
    --       win = {
    --         width = function() return math.min(120, math.floor(vim.o.columns * 0.75)) end,
    --         height = 0.9,
    --         backdrop = {
    --           transparent = false,
    --           win = { wo = { winhighlight = "Normal:Normal" } },
    --         },
    --         wo = {
    --           number = false,
    --           relativenumber = false,
    --           signcolumn = "no",
    --           foldcolumn = "0",
    --           winbar = "",
    --           list = false,
    --           showbreak = "NONE",
    --         },
    --       },
    --     }
    -- },
    picker = {
      sources = {
        explorer = {
          layout = {
            layout = {
              position = "right",
            },
          },
        },
      },
    },
  },
}
