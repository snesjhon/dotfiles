-- Hammerspoon Config
-- Meh key (Shift+Ctrl+Alt) used as modifier for all bindings

local meh = { "shift", "ctrl", "alt" }

-- App launcher hotkeys
local appBindings = {
  { key = "f", app = "Ghostty" },
  { key = "d", app = "Google Chrome" },
  { key = "s", app = "Obsidian" },
  { key = "a", app = "Music" },
}

for _, binding in ipairs(appBindings) do
  hs.hotkey.bind(meh, binding.key, function()
    hs.application.launchOrFocus(binding.app)
  end)
end

-- Window management
local windowBindings = {
  { key = "n", unit = { x = 0, y = 0, w = 0.5, h = 1 } },  -- left half
  { key = ".", unit = { x = 0.5, y = 0, w = 0.5, h = 1 } }, -- right half
  { key = "m", unit = { x = 0, y = 0, w = 1, h = 1 } },    -- maximize
}

for _, binding in ipairs(windowBindings) do
  hs.hotkey.bind(meh, binding.key, function()
    local win = hs.window.focusedWindow()
    if win then
      win:moveToUnit(binding.unit)
    end
  end)
end

hs.hotkey.bind(meh, ",", function()
  local win = hs.window.focusedWindow()
  if win then
    win:toggleFullScreen()
  end
end)
