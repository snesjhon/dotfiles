require("which-key").setup({
  preset = "helix"
})

require("which-key").add({
  { "<leader>f", group = "Find" },
  { "<leader>g", group = "Git", icon = { icon = " ", color = "orange" } },
  { "<leader>gh", group = "Hunks" },
  { "<leader>gt", group = "Toggle" },
  { "<leader>l", group = "LSP", icon = { icon = " ", color = "orange" } },
  { "<leader>u", group = "UI" },
  { "<leader>s", hidden = true },
  { "<leader>z", hidden = true },
  { "<leader>/", hidden = true },
})
