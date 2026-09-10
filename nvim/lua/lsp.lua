Snacks.util.lsp.on({ method = "textDocument/inlayHint" }, function(buf) vim.lsp.inlay_hint.enable(true, { bufnr = buf }) end)

vim.diagnostic.config({ virtual_text = { spacing = 2, prefix = "●" } })

vim.lsp.config("*", {
  capabilities = {
    workspace = { didChangeWatchedFiles = { dynamicRegistration = false } },
  },
})

vim.lsp.config("vtsls", {
  cmd = { "vtsls", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
  capabilities = require("blink.cmp").get_lsp_capabilities(),
  settings = {
    typescript = {
      inlayHints = {
        parameterNames = { enabled = "all" },
        variableTypes = { enabled = true },
      },
    },
    javascript = {
      inlayHints = { parameterNames = { enabled = "all" } },
    },
  },
})

vim.lsp.enable("vtsls")



-- Per-file busywork (e.g. vtsls re-analyzing a file and its deps on every
-- edit/save) is noise -- only startup progress is worth a popup.
local lsp_progress_ignore = {
  "^Publish Diagnostics$",
  "^Analyzing .+ and its dependencies$",
}

vim.api.nvim_create_autocmd("LspProgress", {
  callback = function(ev)
    -- jdtls emits progress notifications as part of its own graceful
    -- shutdown, which exit_timeout (see lsp.local.lua) blocks quitting on.
    -- v:exiting is set before any VimLeavePre autocmd runs (including
    -- vim.lsp's own client:stop() handler), so this reliably skips
    -- popping the notifier -- and its spinner-driven redraw loop -- while
    -- nvim is already on its way out.
    if vim.v.exiting ~= vim.NIL then return end
    local title = ev.data.params.value.title
    for _, pattern in ipairs(lsp_progress_ignore) do
      if title and title:match(pattern) then return end
    end
    local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
    -- `icon` must be a plain value, not a function: snacks' notifier treats a
    -- function-valued `opts`/dynamic field as perpetually dirty and re-renders
    -- (force-flushing the whole screen) on every tick of its ~50ms refresh
    -- timer for as long as the notification stays queued -- not just when we
    -- actually call vim.notify. jdtls keeps this notification alive
    -- continuously for tens of seconds during import/indexing, which turned
    -- into a sustained 20Hz full-screen redraw fighting everything else
    -- (e.g. scrolling a references picker) for CPU the whole time.
    local icon = ev.data.params.value.kind == "end" and " "
      or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
    vim.notify(vim.lsp.status(), "info", {
      id = "lsp_progress",
      title = "LSP Progress",
      icon = icon,
    })
  end,
})

-- LSP keymaps -----------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gr", function() require("snacks").picker.lsp_references() end, opts)
    vim.keymap.set("n", "gh", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.jump { count = 1, float = true } end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.jump { count = -1, float = true } end, opts)

    local function diagnostic_peek(forward)
      return function()
        local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
        local diag = vim.diagnostic.get(0, { lnum = lnum })[1]
          or (forward and vim.diagnostic.get_next or vim.diagnostic.get_prev)({ wrap = true })
        if diag then vim.diagnostic.open_float { pos = { diag.lnum, diag.col }, bufnr = diag.bufnr } end
      end
    end
    vim.keymap.set("n", "]g", diagnostic_peek(true), opts)
    vim.keymap.set("n", "[g", diagnostic_peek(false), opts)
    vim.keymap.set("n", "<leader>d", function() require("snacks").picker.diagnostics_buffer() end, opts)
    vim.keymap.set("n", "<leader>lD", function() require("snacks").picker.diagnostics() end, opts)
    vim.keymap.set("n", "<leader>ls", function() require("snacks").picker.lsp_symbols() end, opts)
    vim.keymap.set("n", "<C-Space>", function()
      vim.cmd("startinsert!") -- append, not insert -- keeps the cursor after the current char
      require("blink.cmp").show()
    end, opts)
  end,
})

local local_lsp = vim.fn.stdpath("config") .. "/lua/lsp.local.lua"
if vim.uv.fs_stat(local_lsp) then dofile(local_lsp) end
