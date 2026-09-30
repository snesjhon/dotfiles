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

vim.lsp.config("jsonls", {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_markers = { ".git" },
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})

vim.lsp.enable("jsonls")


local lsp_progress_ignore = {
  "^Publish Diagnostics$",
  "^Analyzing .+ and its dependencies$",
  "^Validate documents$",
}

vim.api.nvim_create_autocmd("LspProgress", {
  callback = function(ev)
    if vim.v.exiting ~= vim.NIL then return end
    local title = ev.data.params.value.title
    for _, pattern in ipairs(lsp_progress_ignore) do
      if title and title:match(pattern) then return end
    end
    local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
    local icon = ev.data.params.value.kind == "end" and " "
      or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
    vim.notify(vim.lsp.status(), "info", {
      id = "lsp_progress",
      title = "LSP Progress",
      icon = icon,
    })
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = require("mappings.lsp").on_attach,
})

local local_lsp = vim.fn.stdpath("config") .. "/lua/lsp.local.lua"
if vim.uv.fs_stat(local_lsp) then dofile(local_lsp) end
