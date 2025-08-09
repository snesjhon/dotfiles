local function is_dark_mode()
  local handle = io.popen "defaults read -g AppleInterfaceStyle 2>/dev/null"
  if handle then
    local result = handle:read "*a"
    handle:close()
    return result:match "Dark" ~= nil
  end
end

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    colorscheme = is_dark_mode() and "github_dark_default" or "github_light_default",
    status = {
      winbar = {
        -- blacklist buffer patterns
        disabled = {
          buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
          filetype = { "^git.*", "fugitive", "Trouble", "dashboard" },
          -- disable winbar for empty buffer names
          bufname = { "^$" },
        },
      },
    },
  },
}
