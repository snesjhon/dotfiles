--- super fun way of moving through code
return {
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
