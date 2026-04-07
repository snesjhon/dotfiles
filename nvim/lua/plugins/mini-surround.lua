return {
  {
    "nvim-mini/mini.surround",
    version = "*",
    opts = {
      mappings = {
        add = "<LocalLeader>a", -- Add surrounding in Normal and Visual modes
        delete = "<LocalLeader>d", -- Delete surrounding
        find = "<LocalLeader>f", -- Find surrounding (to the right)
        find_left = "<LocalLeader>F", -- Find surrounding (to the left)
        highlight = "<LocalLeader>h", -- Highlight surrounding
        replace = "<LocalLeader>r", -- Replace surrounding

        -- suffix_last = "l", -- Suffix to search with "prev" method
        -- suffix_next = "n", -- Suffix to search with "next" method
      },
    },
  },
}
