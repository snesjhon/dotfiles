local function setup()
  require("bufferline").setup({
    options = {
      diagnostics = "nvim_lsp", -- still colors each tab's filename by severity
      -- Default (true) registers a vim.diagnostic.handlers hook that calls
      -- vim.schedule(vim.cmd.redrawtabline) on every single diagnostic publish -- while jdtls is
      -- actively working (import, background indexing, re-validating after a request) it
      -- republishes diagnostics rapidly, and each one schedules another tabline redraw, pegging
      -- a CPU core for as long as that lasts. Off: still colored, just refreshed on normal
      -- redraw timing instead of synchronously per diagnostic event.
      diagnostics_update_on_event = false,
      show_buffer_close_icons = false,
      show_close_icon = false,
      custom_areas = {
        right = function()
          local segments = {}

          local cursor = vim.api.nvim_win_get_cursor(0)
          table.insert(segments, { text = " " .. cursor[1] .. ":" .. (cursor[2] + 1) .. " ", link = "BufferLineFill" })

          local ft = vim.bo.filetype
          if ft ~= "" then table.insert(segments, { text = ft .. " ", link = "BufferLineFill" }) end

          local count = vim.diagnostic.count(0)
          local errors = count[vim.diagnostic.severity.ERROR] or 0
          local warnings = count[vim.diagnostic.severity.WARN] or 0
          if errors > 0 then
            table.insert(segments, { text = " " .. errors .. (errors == 1 and " error " or " errors "), link = "BufferLineError" })
          elseif warnings > 0 then
            table.insert(segments, { text = " " .. warnings .. (warnings == 1 and " warning " or " warnings "), link = "BufferLineWarning" })
          end

          return segments
        end,
      },
    },
    highlights = require("gitlab-theme").bufferline({ theme = require("configs.theme").name }),
  })
end

setup()

-- No forced CursorMoved/WinEnter -> redrawtabline here (removed): redundant with the plugin's
-- own diagnostics-driven refresh (see diagnostics_update_on_event above, the actual source of
-- the redraw-storm freeze this was chasing) and with normal redraw cycles. The custom_areas
-- cursor-position segment goes stale until the next natural redraw (mode change, window/buffer
-- switch, diagnostic change, etc.) instead of updating every keystroke.
vim.api.nvim_create_autocmd("ColorScheme", { callback = setup })
