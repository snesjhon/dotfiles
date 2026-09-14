vim.keymap.set("n", "<C-S-w>", function()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local was_last = #vim.tbl_filter(function(b)
    return vim.bo[b].buflisted
  end, vim.api.nvim_list_bufs()) == 1

  require("snacks").bufdelete()

  if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then return end

  if was_last then
    require("snacks").dashboard.open({ buf = vim.api.nvim_get_current_buf(), win = win })
  end
end, { desc = "Close buffer" })
