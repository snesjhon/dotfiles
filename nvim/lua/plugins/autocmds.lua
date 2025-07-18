return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      autocmds = {
        -- first key is the augroup name
        wezterm_colorscheme = {
          -- the value is a list of autocommands to create
          {
            -- event is added here as a string or a list-like table of events
            event = "ColorScheme",
            -- the rest of the autocmd options (:h nvim_create_autocmd)
            desc = "Disable line number/fold column/sign column for terminals",
            callback = function(args)
              local colorschemes = {
                ["github_light_default"] = "Github Light Default",
                ["github_dark_default"] = "Github Dark Default",
              }
              local colorscheme = colorschemes[args.match]
              if not colorscheme then return end
              -- Write the colorscheme to a file
              local filename = vim.fn.expand "~/Developer/dotfiles/wezterm/colorscheme"
              local file = io.open(filename, "w")
              if file then
                file:write(colorscheme)
                file:close()
              else
                vim.notify("Failed to write colorscheme to " .. filename, vim.log.levels.ERROR)
              end
            end,
          },
        },
      },
    },
  },
}
