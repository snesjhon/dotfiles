---@type LazySpec
return {
  -- Remove Astro Defaults
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
  {
    "mrjones2014/smart-splits.nvim",
    opts = {
      mappings = {},
    },
  },
  -- AI!
  -- {
  --   "greggh/claude-code.nvim",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim", -- Required for git operations
  --   },
  --   config = function()
  --     require("claude-code").setup {
  --       window = {
  --         position = "leftabove vsplit",
  --       },
  --       keymaps = {
  --         toggle = {
  --           normal = "<C-S-o>",
  --           terminal = "<C-S-o>",
  --         },
  --       },
  --     }
  --   end,
  -- },
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

--
-- -- == Examples of Adding Plugins ==
--
-- "andweeb/presence.nvim",
-- {
--   "ray-x/lsp_signature.nvim",
--   event = "BufRead",
--   config = function() require("lsp_signature").setup() end,
-- },
--
-- -- == Examples of Overriding Plugins ==
--
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
-- -- You can disable default plugins as follows:
-- { "max397574/better-escape.nvim", enabled = false },
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
--
-- {
--   "windwp/nvim-autopairs",
--   config = function(plugin, opts)
--     require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
--     -- add more custom autopairs configuration such as custom rules
--     local npairs = require "nvim-autopairs"
--     local Rule = require "nvim-autopairs.rule"
--     local cond = require "nvim-autopairs.conds"
--     npairs.add_rules(
--       {
--         Rule("$", "$", { "tex", "latex" })
--           -- don't add a pair if the next character is %
--           :with_pair(cond.not_after_regex "%%")
--           -- don't add a pair if  the previous character is xxx
--           :with_pair(
--             cond.not_before_regex("xxx", 3)
--           )
--           -- don't move right when repeat character
--           :with_move(cond.none())
--           -- don't delete if the next character is xx
--           :with_del(cond.not_after_regex "xx")
--           -- disable adding a newline when you press <cr>
--           :with_cr(cond.none()),
--       },
--       -- disable for .vim files, but it work for another filetypes
--       Rule("a", "a", "-vim")
--     )
--   end,
-- },
