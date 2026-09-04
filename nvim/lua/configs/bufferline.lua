require("bufferline").setup({
  options = {
    diagnostics_update_on_event = false,
    show_buffer_close_icons = false,
    show_close_icon = false,
    custom_areas = {
      right = function()
        local segments = {}
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
