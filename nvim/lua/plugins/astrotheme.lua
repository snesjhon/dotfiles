---@type LazySpec
return {
  "AstroNvim/astrotheme",
  opts = {
    style = {
      transparent = true,
    },
    highlights = {
      global = {
        -- Don't dim windows when they're not in focused
        NormalNC = { link = "Normal" },

        -- Visual mode selection
        Visual = { bg = "#D6EAFF", fg = "NONE" },
        -- Yank highlight
        IncSearch = { bg = "NONE", fg = "NONE" },
        CurSearch = {
          bg = "#F0EDD6", -- Red background
          fg = "NONE", -- White text
        },

        -- Alternative yank highlight (some configs use this)
        Search = { bg = "#FCF0BE", fg = "#000000" },

        DiffAdd = { bg = "#e6ffed", fg = "#ffffff" }, -- Light green
        DiffDelete = { bg = "#ffeef0", fg = "#cb2431" }, -- Light red
        DiffChange = { bg = "#f1f8ff", fg = "#005cc5" }, -- Light blue
        DiffText = { bg = "#c8e1ff", fg = "#005cc5", bold = true },
      },
    },
  },
}
