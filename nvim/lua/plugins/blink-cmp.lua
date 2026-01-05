--- I wanted to disable blink tabs because I want to enable neotab
return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",
        ["<Tab>"] = {},
        ["<S-Tab>"] = {},
      },
    },
  },
}
