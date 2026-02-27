return {
  "mikavilpas/yazi.nvim",
  version = "*", -- use the latest stable version
  event = "VeryLazy",
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  keys = {
    -- 👇 in this section, choose your own keymappings!
    {
      "<leader>-",
      mode = { "n", "v" },
      "<cmd>Yazi<cr>",
      desc = "Open yazi at the current file",
    },
  },

  opts = {
    open_for_directories = false,
    open_file_function = function(chosen_file, config, state)
      -- resolve to absolute path so search results (shift-s) open correctly
      local abs = vim.fn.fnamemodify(chosen_file, ":p")
      vim.cmd.edit(abs)
    end,
  },
}
