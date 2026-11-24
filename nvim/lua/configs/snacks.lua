local opts = {
  styles = {
    float = { backdrop = false },
  },
  picker = {
    enabled = true,
    sources = {
      files = { cmd = "rg" },
    },
  },
  notifier = { enabled = true },
  zen = {
    zoom = {
      center = true, -- scroll so the cursor line is mid-screen
      win = {
        width = 100, -- narrower than the screen, so snacks centers it horizontally
        -- Solid fill that is 99% the Normal background, so the sides look empty. 100 turns the backdrop off.
        backdrop = { transparent = false, blend = 99 },
      },
    },
  },
  lazygit = {
    -- FloatBorder is too faint for the unfocused panels and tab names; matches lazygit/gitlab-*.yml.
    theme = { inactiveBorderColor = { fg = "Comment" } },
  },
  terminal = {
      win = {
        wo = {
          winbar = "",
        },
        -- Same key as mux's copy mode, which hands it to the nvim in front.
        keys = { copy_mode = { "<C-\\>", function() vim.cmd.stopinsert() end, mode = "t" } },
      },
    },
  dashboard = {
    enabled = not vim.g.mux_session, -- no dashboard in mux sessions
    preset = {
      header = [[
██╗   ██╗
██║   ██║
╚██╗ ██╔╝
 ╚████╔╝
  ╚═══╝]],
    },
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
      { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
    },
  },
}

require("snacks").setup(opts)
