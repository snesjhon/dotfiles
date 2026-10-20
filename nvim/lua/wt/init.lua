-- The wt command: git worktrees, each shown as its own mux session (see
-- mux/defs.lua), and the /wt skill run in them. zsh/functions/mux.zsh runs it
-- with `nvim -l`, and it writes steps for the shell the same way mux/cli.lua does.
local mux = require("mux.cli")

local usage = [[
wt new <branch> [base]       create a worktree and switch to its session
wt ticket <id or URL> [-n name | -b branch] [instructions...]
                             create a worktree and run /wt in its session
wt adopt <PR URL> [instructions...]
                             create a worktree for one of your open PRs and run /wt adopt in it
wt plan [name]               open a /wt plan in nvim
wt revise [name]             run /wt revise once the draft PR is reviewed
wt respond [name] [PR URL]   run /wt respond to triage a teammate's PR review
wt test [name]               run /wt test to build a test project and tags
wt rm [name]                 stop a worktree session and remove the worktree]]

local function fail(msg) mux.fail("wt: " .. msg) end

local function say(msg) mux.say("wt: " .. msg) end

-- Runs `cmd` and returns its trimmed stdout, or nil and its error output.
local function run(cmd)
  local r = vim.system(cmd, { text = true }):wait()
  if r.code ~= 0 then return nil, vim.trim(r.stderr ~= "" and r.stderr or r.stdout) end
  return vim.trim(r.stdout)
end

-- Like run, but stops wt with the command's error when it fails.
local function must(cmd)
  local out, err = run(cmd)
  if not out then fail(err ~= "" and err or table.concat(cmd, " ") .. " failed") end
  return out
end

-- Session names and arguments get typed into a shell, so they must be plain.
local function plain(s) return s:match("^[%w._-]+$") ~= nil end

local function plan_status(dir)
  local f = io.open(vim.fs.joinpath(dir, ".ticket", "plan.md"))
  if not f then return nil end
  local status = ("\n" .. f:read("*a")):match("\nStatus: ([^\n]*)")
  f:close()
  return status
end

-- The repo this shell is in, or the only repo with a worktree folder in
-- mux/defs.lua when the shell is in none, and that worktree folder.
local function repo()
  local dirs = {} -- repo folder -> its worktree folder
  for _, def in pairs(mux.defs()) do
    if def.worktrees then dirs[vim.fn.expand(def.path)] = vim.fn.expand(def.worktrees) end
  end
  local common = run({ "git", "rev-parse", "--path-format=absolute", "--git-common-dir" })
  local here = common and vim.fs.dirname(common)
  if here and dirs[here] then return here, dirs[here] end
  local repos = vim.tbl_keys(dirs)
  if #repos ~= 1 then
    fail("run inside a repo with worktrees set in mux/defs.lua: " .. table.concat(repos, ", "))
  end
  return repos[1], dirs[repos[1]]
end

-- Worktree session `name` (default: this window's). Returns the name, its
-- folder, and its parent session.
local function session(name)
  local current = mux.current()
  name = name or (current and (vim.fs.basename(current):gsub("%.sock$", "")))
  local def = name and mux.defs()[name]
  if not def or not def.parent then fail((name or "this window") .. " is not a worktree session") end
  return name, def.path, def.parent
end

-- Creates a worktree for `branch` in the worktree folder of the repo from
-- repo(). An existing branch (local or on origin) is checked out; a new one
-- starts from `base` on upstream (or origin when there is no upstream), by
-- default that remote's default branch. Returns the new session's name and its
-- folder.
local function worktree(branch, base)
  local root, dir = repo()
  local name = vim.fs.basename(branch)
  local path = vim.fs.joinpath(dir, name)
  if vim.uv.fs_stat(path) then fail(path .. " already exists") end
  local function has(ref) return run({ "git", "-C", root, "show-ref", "-q", "--verify", ref }) ~= nil end
  if has("refs/heads/" .. branch) or has("refs/remotes/origin/" .. branch) then
    must({ "git", "-C", root, "worktree", "add", path, branch })
  else
    -- In a fork setup origin is the fork, whose base branch can be behind.
    local remote = run({ "git", "-C", root, "remote", "get-url", "upstream" }) and "upstream" or "origin"
    if not base then
      base = must({ "git", "-C", root, "symbolic-ref", "--short", "refs/remotes/" .. remote .. "/HEAD" })
      base = base:sub(#remote + 2)
    end
    must({ "git", "-C", root, "fetch", "-q", remote, base })
    -- --no-track: the branch is pushed under its own name, not to base.
    must({ "git", "-C", root, "worktree", "add", "--no-track", "-b", branch, path, remote .. "/" .. base })
  end
  return name, path
end

-- Lowercase words joined by hyphens, at most 30 characters, for branch names.
local function slug(s)
  s = s:lower():gsub("[^%w]+", "-"):sub(1, 30)
  return (s:gsub("^%-+", ""):gsub("%-+$", ""))
end

-- Starts session `name` for worktree `dir` without switching to it, saves
-- `notes` to .ticket/notes.md, and runs /wt `args` with claude in its first tab.
local function start(name, dir, args, notes)
  if not plain(name) then fail("session name " .. name .. " has characters wt can't pass on") end
  -- info/exclude, not .gitignore: it keeps .ticket out of every worktree's
  -- commits without changing a tracked file.
  local exclude = must({ "git", "-C", dir, "rev-parse", "--path-format=absolute", "--git-common-dir" }) .. "/info/exclude"
  local f = io.open(exclude)
  local text = f and f:read("*a") or ""
  if f then f:close() end
  if not ("\n" .. text .. "\n"):find("\n/.ticket/\n", 1, true) then
    f = assert(io.open(exclude, "a"))
    f:write((text ~= "" and not text:match("\n$")) and "\n" or "", "/.ticket/\n")
    f:close()
  end
  if notes ~= "" then
    vim.fn.mkdir(vim.fs.joinpath(dir, ".ticket"), "p")
    f = assert(io.open(vim.fs.joinpath(dir, ".ticket", "notes.md"), "w"))
    f:write(notes, "\n")
    f:close()
  end
  local ok, err = mux.ensure(name)
  if not ok then fail(err) end
  local res
  res, err = mux.call(mux.sock(name), "return require('mux').send(...)",
    ("claude --permission-mode auto -n %s \"/wt %s\""):format(name, args))
  err = err or (res ~= "" and res) or nil
  if err then fail(name .. ": " .. err) end
  say("started /wt " .. args .. " in session " .. name)
end

-- Creates a worktree and switches to its session like `mux <name>`.
local function new(branch, base)
  if not branch then fail("usage: wt new <branch> [base]") end
  mux.open((worktree(branch, base)))
end

-- Creates a worktree for a ticket, starts its session without switching to it,
-- and runs /wt <id> with claude in the session's first tab. The window stays
-- put, so several tickets, or several ideas for one ticket, can start in a row.
-- The ticket is an id (IGN-123) or a URL containing one. Any words after it are
-- instructions for the agent, saved to .ticket/notes.md in the worktree, where
-- /wt reads them and writes its plan. The branch and session are <id>-<name>,
-- with the name from -n, else a short slug Haiku makes from the instructions,
-- else just <id>. -b sets the whole branch name instead.
local function ticket(args)
  local use = "usage: wt ticket <id or URL> [-n name | -b branch] [instructions...]"
  local id
  for part in (args[1] or ""):upper():gmatch("[^/]+") do
    if part:match("^[A-Z][A-Z0-9]*%-%d+$") then
      id = part
      break
    end
  end
  if not id then fail(use) end
  local i, branch, label = 2, nil, nil
  while args[i] == "-b" or args[i] == "-n" do
    if not args[i + 1] then fail(use) end
    if args[i] == "-b" then
      branch = args[i + 1]
    else
      label = slug(args[i + 1])
    end
    i = i + 2
  end
  local notes = table.concat(args, " ", i)
  if not branch and not label and notes ~= "" then
    say("naming the branch...")
    label = slug(run({ "claude", "-p", "--model", "haiku",
      "Reply with only a 1 to 3 word name for a git branch doing this work, nothing else: " .. notes }) or "")
  end
  branch = branch or (label and label ~= "" and id .. "-" .. label or id)
  local name, dir = worktree(branch)
  start(name, dir, id, notes)
end

-- Creates a worktree for the branch of one of the user's open PRs, starts its
-- session without switching to it, and runs /wt adopt <url> there, which plans
-- how to bring the PR in line with its ticket and its open review comments.
-- Words after the URL are instructions, saved like wt ticket's. The session is
-- named after the branch. The PR's branch must be on origin, since /wt pushes
-- there.
local function adopt(args)
  local url = args[1] or ""
  local pr_url = url:match("^(https://[^/]+/[^/]+/[^/]+/pull/%d+)/") or url:match("^(https://[^/]+/[^/]+/[^/]+/pull/%d+)$")
  -- The URL is typed into a shell, so it must be plain.
  if not pr_url or not url:match("^https://[%w./_-]+$") then fail("usage: wt adopt <PR URL> [instructions...]") end
  local host = pr_url:match("^https://([^/]+)/")
  local root = repo()
  local pr = vim.json.decode(must({ "gh", "pr", "view", pr_url, "--json", "headRefName,headRepositoryOwner,state,author" }))
  if pr.state ~= "OPEN" then fail(pr_url .. " is " .. pr.state:lower()) end
  local login = must({ "gh", "api", "--hostname", host, "user", "-q", ".login" })
  if pr.author.login ~= login then fail(pr_url .. " is " .. pr.author.login .. "'s PR, not yours") end
  local owner = pr.headRepositoryOwner.login
  local origin = must({ "git", "-C", root, "remote", "get-url", "origin" })
  if not origin:find("[/:]" .. vim.pesc(owner) .. "/") then
    fail(pr_url .. "'s branch is on " .. owner .. "'s repo, not origin (" .. origin .. ")")
  end
  must({ "git", "-C", root, "fetch", "-q", "origin", pr.headRefName })
  local name, dir = worktree(pr.headRefName)
  start(name, dir, "adopt " .. pr_url, table.concat(args, " ", 2))
end

-- Opens the /wt plan of session `name`'s folder in nvim, by default the plan of
-- the git worktree this shell is in.
local function plan(name)
  local dir
  if name then
    local def = mux.defs()[name]
    if not def then fail("no session named " .. name) end
    dir = vim.fn.expand(def.path)
  else
    dir = run({ "git", "rev-parse", "--show-toplevel" }) or fail("not in a git worktree")
  end
  local file = vim.fs.joinpath(dir, ".ticket", "plan.md")
  if not vim.uv.fs_stat(file) then fail("no plan in " .. dir) end
  mux.emit("edit", file)
end

-- Runs /wt <sub> in worktree session `name` (default: this window's), where sub
-- is revise (address the user's review of the draft PR), respond (triage a
-- teammate's review; takes a PR URL when the worktree has no plan yet), or test
-- (build a test project and tags in the worktree's gateway-launcher). It types
-- into the first tab, where wt ticket started claude. A claude still open there
-- is cleared first, so the run works from the plan file and the PR, not the old
-- conversation. The window stays put.
local function skill(sub, name, url)
  if name and name:match("^https://") then
    url, name = name, nil
  end
  local dir
  name, dir = session(name)
  if not plain(name) then fail("session name " .. name .. " has characters wt " .. sub .. " can't pass on") end
  if url and not url:match("^https://[%w./_-]+$") then fail(url .. " has characters wt " .. sub .. " can't pass on") end
  -- Typing into a claude that is still working would interrupt it. A worktree
  -- with no plan is idle, so respond can start there from a PR URL.
  local status = plan_status(dir)
  if not (sub == "respond" and not status and url) and status ~= "pr-open" then
    fail(name .. " has no draft PR open yet (" .. (status and "Status: " .. status or "no plan") .. ")")
  end
  local ok, err = mux.ensure(name)
  if not ok then fail(err) end
  local sock = mux.sock(name)
  local cmd = "/wt " .. sub .. (url and " " .. url or "")
  local fg = mux.call(sock, "return require('mux').first_fg()") or ""
  local texts
  if fg == "claude" then
    texts = { "/clear", cmd }
  elseif fg == "zsh" or fg == "bash" or fg == "sh" then
    texts = { ("claude --permission-mode auto -n %s \"%s\""):format(name, cmd) }
  else
    fail(name .. ": the first tab runs " .. (fg ~= "" and fg or "nothing") .. ", not claude or a shell")
  end
  for _, text in ipairs(texts) do
    -- /clear has to finish before claude takes the next prompt.
    if text == cmd then vim.wait(1000) end
    local res
    res, err = mux.call(sock, "return require('mux').send(...)", text)
    err = err or (res ~= "" and res) or nil
    if err then fail(name .. ": " .. err) end
  end
  say("started /wt " .. sub .. " in session " .. name)
end

-- Stops worktree session `name` (default: this window's) and everything running
-- in it, then removes the worktree. The branch is kept. Run inside that session,
-- the window moves to the repo's session first.
local function rm(name)
  local dir, parent
  name, dir, parent = session(name)
  -- Real paths, read while the folder still exists, since the shell's $PWD and
  -- git's worktree path can name the same folder differently.
  local cwd = vim.uv.fs_realpath(vim.env.PWD or ".") or ""
  dir = vim.uv.fs_realpath(dir) or dir
  -- git refuses to remove a worktree with changes, so check before stopping anything.
  if must({ "git", "-C", dir, "status", "--porcelain" }) ~= "" then fail(name .. " has uncommitted changes") end
  local root = vim.fs.dirname(must({ "git", "-C", dir, "rev-parse", "--path-format=absolute", "--git-common-dir" }))
  local sock = mux.sock(name)
  mux.kill_procs({ sock })
  vim.uv.chdir(root)
  must({ "git", "-C", root, "worktree", "remove", dir })
  say("removed " .. name .. "; its branch is kept")
  if mux.current() == sock then
    -- Quitting the server a window is attached to closes the window, so move it
    -- to the repo's session and wait until no window is left on this one.
    local ok, err = mux.switch(sock, parent)
    if not ok then fail(err) end
    vim.wait(10000, function() return (mux.call(sock, "return #vim.api.nvim_list_uis()") or 0) == 0 end, 50)
  end
  if cwd == dir or vim.startswith(cwd, dir .. "/") then mux.emit("cd", root) end
  -- Run inside that session, this ends the calling shell.
  mux.quit_one(sock)
end

local function main(args)
  local cmd = table.remove(args, 1)
  if cmd == "new" then return new(args[1], args[2]) end
  if cmd == "ticket" then return ticket(args) end
  if cmd == "adopt" then return adopt(args) end
  if cmd == "plan" then return plan(args[1]) end
  if cmd == "revise" or cmd == "test" then return skill(cmd, args[1]) end
  if cmd == "respond" then return skill(cmd, args[1], args[2]) end
  if cmd == "rm" then return rm(args[1]) end
  if cmd == "names" then -- worktree sessions, for tab completion
    local names = {}
    for name, def in pairs(mux.defs()) do
      if def.parent then table.insert(names, name) end
    end
    return io.stdout:write(table.concat(names, "\n"), "\n")
  end
  if cmd == "-h" or cmd == "--help" then return mux.say(usage) end
  mux.fail(cmd and "wt: unknown command " .. cmd .. "\n" .. usage or usage)
end

main(vim.list_slice(_G.arg, 1))
