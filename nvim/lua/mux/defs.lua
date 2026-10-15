local sessions = {
  dev = {
    path = "~/Developer",
    tabs = {
      { "dots", path = "~/Developer/dotfiles" },
      { "me", path = "~/Developer/me" },
    },
  },
}

-- dofile, not require: `mux` loads this file under `nvim --clean`, where this
-- directory isn't on package.path.
local dir = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$")
local ok, extra = pcall(dofile, dir .. "/defs.local.lua")
if ok then sessions = vim.tbl_extend("force", sessions, extra) end

local trees = {}
for parent, def in pairs(sessions) do
  if def.worktrees then
    local out = vim.system({ "git", "-C", vim.fn.expand(def.path), "worktree", "list", "--porcelain" }):wait().stdout
    local first = true
    for path in (out or ""):gmatch("worktree ([^\n]+)") do
      -- The first entry is the repo itself, which is already this session.
      -- A worktree whose folder was deleted by hand stays listed until pruned.
      if not first and vim.uv.fs_stat(path) then
        trees[vim.fs.basename(path)] = { path = path, tabs = def.tabs, parent = parent }
      end
      first = false
    end
  end
end
sessions = vim.tbl_extend("keep", sessions, trees)

return sessions
