require("blink.cmp").setup({
  keymap = {
    preset = "default",
    ["<C-j>"] = { "select_next", "fallback" },
    ["<C-k>"] = { "select_prev", "fallback" },
    ["<CR>"] = { "accept", "fallback" },
  },
  completion = {
    documentation = { auto_show = true },
  },
  signature = { enabled = true },
})
