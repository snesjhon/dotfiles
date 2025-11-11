---@type LazySpec
return {
  -- Remove Astro Defaults
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
  { "rafamadriz/friendly-snippets", enabled = false },
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    config = true,
    opts = {
      preview = {
        enable = false,
        icon_provider = "mini", -- "mini" or "devicons"
      },
    },
    keys = {
      {
        "<leader>m",
        nil,
        desc = "Markview",
      },
      {
        "<leader>mt",
        "<cmd>Markview Toggle<cr>",
        desc = "Markview Toggle",
      },
    },
    dependencies = {
      "saghen/blink.cmp",
    },
  },
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      terminal_cmd = "/Users/jhonatansalazar/.nvm/versions/node/v22.18.0/bin/claude", -- Point to local installation
    },
    config = true,
    keys = {
      { "<leader>a", nil, desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "snacks_picker_list" },
      },
      -- Diff management
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    opts = {
      direction = "float",
    },
  },
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      set_dark_mode = function()
        vim.api.nvim_set_option_value("background", "dark", {})
        vim.cmd "colorscheme github_dark_default"
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value("background", "light", {})
        vim.cmd "colorscheme github_light_default"
      end,
      update_interval = 3000,
      fallback = "dark",
    },
  },
  {
    "shortcuts/no-neck-pain.nvim",
    version = "*",
    lazy = false,
    opts = {
      width = 119,
      autocmds = {
        skipEnteringNoNeckPainBuffer = true,
        enableOnVimEnter = true,
      },
      integrations = {
        dashboard = {
          enabled = true,
        },
      },
      buffers = {
        wo = {
          fillchars = "eob: ",
        },
      },
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
      -- { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
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
