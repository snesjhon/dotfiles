local M = {}

require("gitlab-theme").setup({
  contrast = true,
  borders = true,
  italic = true,
  bold = true,
  transparent = false,
})

---Read macOS's current appearance. Returns "dark"/"light", or nil off-macOS
---(or if the read fails), so callers can fall back sensibly.
local function system_appearance()
  if vim.fn.has("mac") ~= 1 then
    return nil
  end
  local ok, result = pcall(vim.fn.system, { "defaults", "read", "-g", "AppleInterfaceStyle" })
  if not ok then
    return nil
  end
  return result:match("^Dark") and "dark" or "light"
end

---Apply whichever colorscheme macOS's appearance calls for. macOS is the only
---source of truth -- there's no manual override to preserve, so this just
---no-ops when the right scheme is already active. M.name is read by
---configs/bufferline.lua for its highlight overrides.
function M.sync()
  local name = system_appearance() == "dark" and "gitlab_dark" or "gitlab_light"
  if M.name == name then
    return
  end
  M.name = name
  vim.cmd.colorscheme(name)
end

M.sync()

-- The system can flip appearance (Dark Mode schedule, manual toggle in
-- System Settings) while the terminal isn't focused, so re-check on focus.
vim.api.nvim_create_autocmd("FocusGained", { callback = M.sync })

return M
