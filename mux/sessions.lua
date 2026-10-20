-- Sessions for mux (plugins/mux), read from ~/.config/mux: name -> { path, tabs }. A session with
-- `worktrees` also gets one session per git worktree of its repo, which is
-- where wt (plugins/wt) creates them.
local sessions = {
  dev = {
    path = "~/Developer",
    default = true, -- what plain `mux` attaches to before any other session
    tabs = {
      { "dots", path = "~/Developer/dotfiles" },
      { "me", path = "~/Developer/me" },
    },
  },
}

-- Machine-specific sessions, from the gitignored sessions.local.lua next to this file.
local dir = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$")
local ok, extra = pcall(dofile, dir .. "/sessions.local.lua")
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
