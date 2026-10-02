local M = {}

require("gitlab-theme").setup({
  contrast = true,
  borders = true,
  italic = true,
  bold = true,
  transparent = false,
})

-- Last appearance seen, so startup can pick the scheme without waiting on
-- `defaults` (30-40ms).
local cache = vim.fn.stdpath("state") .. "/appearance"

local function apply(appearance)
  local name = appearance == "dark" and "gitlab_dark" or "gitlab_light"
  if M.name == name then
    return
  end
  M.name = name
  vim.cmd.colorscheme(name)
end

local function read_cache()
  local f = io.open(cache)
  if not f then
    return nil
  end
  local appearance = f:read("*l")
  f:close()
  return appearance
end

---Apply whichever colorscheme macOS's appearance calls for. macOS is the only
---source of truth, so this no-ops when the right scheme is already active.
---The check runs in the background so startup and focus changes don't wait on
---it. M.name is read by configs/bufferline.lua for its highlight overrides.
function M.sync()
  if vim.fn.has("mac") ~= 1 then
    apply(nil)
    return
  end
  vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }, { text = true }, vim.schedule_wrap(function(out)
    local appearance = (out.stdout or ""):match("^Dark") and "dark" or "light"
    if appearance ~= read_cache() then
      local f = io.open(cache, "w")
      if f then
        f:write(appearance, "\n")
        f:close()
      end
    end
    apply(appearance)
  end))
end

apply(read_cache())
M.sync()

-- The system can flip appearance (Dark Mode schedule, manual toggle in
-- System Settings) while the terminal isn't focused, so re-check on focus.
vim.api.nvim_create_autocmd("FocusGained", { callback = M.sync })

return M
