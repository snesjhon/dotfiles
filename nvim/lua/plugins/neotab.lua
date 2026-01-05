return {
  {
    "kawre/neotab.nvim",
    event = "InsertEnter",
    opts = {
      tabkey = "<Tab>",
      reverse_key = "<S-Tab>",
      act_as_tab = true,
      behavior = "nested",
      pairs = {
        { open = "(", close = ")" },
        { open = "[", close = "]" },
        { open = "{", close = "}" },
        { open = "'", close = "'" },
        { open = '"', close = '"' },
        { open = "`", close = "`" },
        { open = "<", close = ">" },
      },
    },
  },
}
