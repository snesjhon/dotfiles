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

local function name_for(appearance)
  return appearance == "dark" and "gitlab_dark" or "gitlab_light"
end

local function apply(name)
  M.name = name
  vim.cmd.colorscheme(name)
end

-- Track the system appearance we last synced to, separate from M.name, so a
-- manual M.toggle() below isn't immediately clobbered by FocusGained syncing
-- -- only an actual OS-level appearance change should override a manual pick.
M.last_system = system_appearance()
apply(name_for(M.last_system))

---Flip light/dark by hand. Sticks until the system's own appearance changes.
function M.toggle()
  apply(M.name == "gitlab_dark" and "gitlab_light" or "gitlab_dark")
end

---Re-check the system appearance and follow it if it changed.
function M.sync()
  local appearance = system_appearance()
  if appearance and appearance ~= M.last_system then
    M.last_system = appearance
    apply(name_for(appearance))
  end
end

-- The system can flip appearance (Dark Mode schedule, manual toggle in
-- System Settings) while the terminal isn't focused, so re-check on focus.
vim.api.nvim_create_autocmd("FocusGained", { callback = M.sync })

return M
