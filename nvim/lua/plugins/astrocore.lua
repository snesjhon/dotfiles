---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    options = {
      opt = {
        relativenumber = false,
        number = false,
        digraph = false,
        foldcolumn = "0",
        showtabline = 2,
      },
    },
    autocmds = {
      terminal_mappings = {
        {
          event = "TermOpen",
          desc = "Terminal buffer-local mappings",
          callback = function()
            vim.keymap.set("n", "q", "a", { buffer = true, desc = "Return to terminal insert mode" })
          end,
        },
      },
      stay_centered_terminal = {
        {
          event = "BufEnter",
          desc = "Disable stay-centered in terminal buffers",
          callback = function()
            if vim.bo.buftype == "terminal" then
              require("stay-centered").disable()
            else
              require("stay-centered").enable()
            end
          end,
        },
      },
    },
  },
}
