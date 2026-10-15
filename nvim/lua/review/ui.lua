local M = {}

local count = 0

-- Opens a markdown float under the cursor. `:w` saves (calls on_save with the
-- trimmed text) and closes it, `q` closes it without saving.
function M.edit(title, body, on_save)
  count = count + 1
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, "review://comment/" .. count)
  vim.bo[buf].buftype = "acwrite" -- so :w runs BufWriteCmd below
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "markdown"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(body, "\n"))
  vim.bo[buf].modified = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = math.min(80, vim.api.nvim_win_get_width(0) - 4),
    height = 8,
    style = "minimal",
    title = " " .. title .. " ",
    footer = " :w save  q cancel ",
    footer_pos = "right",
  })
  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = function()
      local text = vim.trim(table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n"))
      vim.bo[buf].modified = false
      -- Scheduled so :wq can still quit the float itself; closing it here
      -- would leave :q to close the window underneath.
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
        on_save(text)
      end)
    end,
  })
  vim.keymap.set("n", "q", function() vim.api.nvim_win_close(win, true) end, { buffer = buf, desc = "Cancel" })

  if body == "" then vim.cmd.startinsert() end
end

return M
