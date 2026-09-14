local M = {}

-- Passed as the LspAttach autocmd callback by lsp.lua.
function M.on_attach(ev)
  local function map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc }) end

  map("n", "gd", vim.lsp.buf.definition, "Go to definition")
  map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
  map("n", "gr", function() require("snacks").picker.lsp_references() end, "Go to references")
  map("n", "gh", vim.lsp.buf.hover, "Hover")
  map("n", "<leader>lr", vim.lsp.buf.rename, "Rename")
  map("n", "<leader>la", vim.lsp.buf.code_action, "Code action")
  map("n", "]d", function() vim.diagnostic.jump { count = 1, float = true } end, "Next diagnostic")
  map("n", "[d", function() vim.diagnostic.jump { count = -1, float = true } end, "Previous diagnostic")

  local function diagnostic_peek(forward)
    return function()
      local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
      local diag = vim.diagnostic.get(0, { lnum = lnum })[1]
        or (forward and vim.diagnostic.get_next or vim.diagnostic.get_prev)({ wrap = true })
      if diag then vim.diagnostic.open_float { pos = { diag.lnum, diag.col }, bufnr = diag.bufnr } end
    end
  end
  map("n", "]g", diagnostic_peek(true), "Peek next diagnostic")
  map("n", "[g", diagnostic_peek(false), "Peek previous diagnostic")
  map("n", "<leader>ld", function() require("snacks").picker.diagnostics_buffer() end, "Diagnostics (buffer)")
  map("n", "<leader>lD", function() require("snacks").picker.diagnostics() end, "Diagnostics (workspace)")
  map("n", "<leader>ls", function() require("snacks").picker.lsp_symbols() end, "Symbols")
  map("n", "<C-Space>", function()
    vim.cmd("startinsert!") -- append, not insert -- keeps the cursor after the current char
    require("blink.cmp").show()
  end, "Trigger completion")
end

return M
