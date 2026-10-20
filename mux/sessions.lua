-- Sessions for mux (plugins/mux), read through ~/.config/mux. See
-- plugins/mux/lua/mux/cli.lua for the fields.
local sessions = {
  dev = {
    path = "~/Developer",
    default = true,
    tabs = {
      { "dots", path = "~/Developer/dotfiles" },
      { "me", path = "~/Developer/me" },
    },
  },
}

-- Machine-specific sessions, from the gitignored sessions.local.lua next to this file.
local dir = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))
local ok, extra = pcall(dofile, dir .. "/sessions.local.lua")
if ok then sessions = vim.tbl_extend("force", sessions, extra) end

return sessions
