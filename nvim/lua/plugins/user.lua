---@type LazySpec
return {
  -- Remove Astro Defaults
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
  {
    "shortcuts/no-neck-pain.nvim",
    version = "*",
    lazy = false,
    opts = {
      width = 119,
      autocmds = {
        skipEnteringNoNeckPainBuffer = true,
      },
      integrations = {
        dashboard = {
          enabled = true,
        },
      },
    },
  },
  {
    "mrjones2014/smart-splits.nvim",
    opts = {
      mappings = {},
    },
  },
  -- super fun way of moving through code
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      label = {
        uppercase = false,
      },
      modes = {
        search = {
          enabled = true,
        },
        char = {
          jump_labels = true,
        },
      },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = { "o" }, function() require("flash").remote() end, desc = "Remote Flash" },
      {
        "R",
        mode = { "o", "x" },
        function() require("flash").treesitter_search() end,
        desc = "Treesitter Search",
      },
    },
  },
}

-- -- customize dashboard options
-- {
--   "folke/snacks.nvim",
--   opts = {
--     dashboard = {
--       preset = {
--         header = table.concat({
--           " █████  ███████ ████████ ██████   ██████ ",
--           "██   ██ ██         ██    ██   ██ ██    ██",
--           "███████ ███████    ██    ██████  ██    ██",
--           "██   ██      ██    ██    ██   ██ ██    ██",
--           "██   ██ ███████    ██    ██   ██  ██████ ",
--           "",
--           "███    ██ ██    ██ ██ ███    ███",
--           "████   ██ ██    ██ ██ ████  ████",
--           "██ ██  ██ ██    ██ ██ ██ ████ ██",
--           "██  ██ ██  ██  ██  ██ ██  ██  ██",
--           "██   ████   ████   ██ ██      ██",
--         }, "\n"),
--       },
--     },
--   },
-- },
--
-- -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
-- {
--   "L3MON4D3/LuaSnip",
--   config = function(plugin, opts)
--     require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
--     -- add more custom luasnip configuration such as filetype extend or custom snippets
--     local luasnip = require "luasnip"
--     luasnip.filetype_extend("javascript", { "javascriptreact" })
--   end,
-- },
