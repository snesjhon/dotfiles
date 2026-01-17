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
    },
  },
}
