-- Completion menu -- replaces native vim.lsp.completion. Debounced and
-- fuzzy-matched client-side, so it's safe to trigger on every keystroke
-- (unlike re-requesting the LSP server on each letter typed).
require("blink.cmp").setup({
  keymap = {
    preset = "default",
    -- Move through the menu with C-j/C-k; C-k also drives signature help in
    -- the "default" preset, but arrow navigation is more useful here.
    ["<C-j>"] = { "select_next", "fallback" },
    ["<C-k>"] = { "select_prev", "fallback" },
    -- Accept the selected item on Enter; falls through to a normal newline
    -- when the menu isn't open.
    ["<CR>"] = { "accept", "fallback" },
  },
  completion = {
    documentation = { auto_show = true },
  },
  signature = { enabled = true },
})
