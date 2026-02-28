return {
  "mikavilpas/yazi.nvim",
  version = "*", -- use the latest stable version
  event = "VeryLazy",
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  keys = {
    {
      "<F6>",
      function()
        -- If a floating terminal (yazi) is open, close it; otherwise open yazi
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local cfg = vim.api.nvim_win_get_config(win)
          local buf = vim.api.nvim_win_get_buf(win)
          if cfg.relative ~= "" and vim.bo[buf].buftype == "terminal" then
            vim.api.nvim_win_close(win, true)
            return
          end
        end
        vim.cmd "Yazi"
      end,
      desc = "Toggle yazi",
      mode = { "n", "t" },
    },
  },

  opts = {
    open_for_directories = false,
    highlight_hovered_buffers_in_same_directory = false,
    open_file_function = function(chosen_file, config, state)
      -- resolve to absolute path so search results (shift-s) open correctly
      local abs = vim.fn.fnamemodify(chosen_file, ":p")
      vim.cmd.edit(abs)
    end,
  },
}
