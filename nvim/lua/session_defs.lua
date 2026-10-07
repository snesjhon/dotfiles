-- Session definitions for `mux` (zsh/functions/mux.zsh). Kept free of side
-- effects so `mux` can list the names without loading the whole config.
-- Every tab is a shell started in `path`. Machine-specific sessions go in
-- session_defs.local.lua next to this file (gitignored).
local sessions = {
  dev = {
    path = "~/Developer",
    tabs = { "code", "agent", "server" },
  },
}

-- dofile, not require: `mux` loads this file under `nvim --clean`, where this
-- directory isn't on package.path.
local dir = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$")
local ok, extra = pcall(dofile, dir .. "/session_defs.local.lua")
if ok then sessions = vim.tbl_extend("force", sessions, extra) end

return sessions
