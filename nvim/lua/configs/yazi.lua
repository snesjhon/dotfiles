local Snacks = require("snacks")

local active

local function chooser()
  if active and active:buf_valid() then
    active:focus()
    return
  end

  local origin_win = vim.api.nvim_get_current_win()
  local tmpfile = vim.fn.tempname()
  local cmd = { "yazi", "--chooser-file=" .. tmpfile }
  local current_file = vim.fn.expand("%:p")
  if current_file ~= "" then table.insert(cmd, current_file) end

  local terminal = Snacks.terminal.open(cmd, {
    auto_close = false,
    win = {
      position = "float",
      width = 0.9,
      height = 0.9,
      border = "rounded",
      title = " Yazi ",
      title_pos = "center",
    },
  })
  active = terminal

  terminal:on("TermClose", function()
    vim.schedule(function()
      local picked = vim.fn.filereadable(tmpfile) == 1 and vim.fn.readfile(tmpfile) or {}
      vim.fn.delete(tmpfile)
      terminal:close()
      if vim.api.nvim_win_is_valid(origin_win) then
        vim.api.nvim_set_current_win(origin_win)
        for _, path in ipairs(picked) do
          if path ~= "" then vim.cmd("edit " .. vim.fn.fnameescape(path)) end
        end
      end
    end)
  end, { buf = true })
end

vim.api.nvim_create_user_command("YaziChooser", chooser, { desc = "Open yazi to pick a file" })

vim.keymap.set({ "n", "t" }, "<F6>", chooser, { desc = "Open yazi" })
