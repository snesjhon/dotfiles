return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require "astroui.status"
    opts.statusline = {
      hl = { fg = "fg", bg = "bg" },
      -- Left side: colored bar only, no "NORMAL" text
      status.component.mode(),
      status.component.git_branch(),
      -- Modified indicator after branch name
      {
        provider = function() return vim.bo.modified and " ●" or "" end,
        hl = { fg = "git_changed" },
        update = { "BufModifiedSet" },
      },
      status.component.git_diff(),
      status.component.diagnostics(),
      status.component.fill(),
      status.component.cmd_info(),
      status.component.fill(),
      -- Clickable gear icon → :checkhealth
      {
        provider = function() return " " .. require("astroui").get_icon "ActiveLSP" .. "  " end,
        on_click = {
          name = "checkhealth_click",
          callback = function() vim.cmd "checkhealth" end,
        },
      },
      --
      status.component.file_info {
        filename = false,
        unique_path = false,
        filetype = false,
        file_modified = false,
        file_icon = { padding = { left = 1, right = 0 } },
      },
    }
    return opts
  end,
}
