return {
  "mikavilpas/yazi.nvim",
  opts = {
    open_file_function = function(chosen_file, config, state)
      -- resolve to absolute path so search results (shift-s) open correctly
      local abs = vim.fn.fnamemodify(chosen_file, ":p")
      vim.cmd.edit(abs)
    end,
  },
}
