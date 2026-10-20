-- The mux command (bin/mux): attach a terminal to a session, pick or switch
-- sessions, open one from a hotkey, restart, and kill. init.lua and wt use its
-- session helpers.
--
-- Every session is a headless nvim server listening on <dir>/<name>.sock. A
-- window is just a UI attached to one of them, so `:connect` moves the window to
-- another session and closing the window leaves the session running.
--
-- Sessions come from a `sessions` Lua module on the runtimepath (for example
-- ~/.config/nvim/lua/sessions.lua), returning name -> { path, tabs, ... }.
-- Messages go to stderr.
local M = {}

function M.dir() return vim.fs.joinpath(vim.fs.normalize(vim.env.TMPDIR or "/tmp"), "mux-sessions") end

function M.sock(name) return vim.fs.joinpath(M.dir(), name .. ".sock") end

-- Loaded fresh each time: sessions can come and go while a server runs.
function M.sessions()
  package.loaded["sessions"] = nil
  return require("sessions")
end

-- Socket files of every session started so far, running or not.
function M.socks()
  local socks = {}
  if not vim.uv.fs_stat(M.dir()) then return socks end
  for file in vim.fs.dir(M.dir()) do
    if file:match("%.sock$") then table.insert(socks, vim.fs.joinpath(M.dir(), file)) end
  end
  table.sort(socks)
  return socks
end

-- The session of the shell this runs in, when it runs inside one.
function M.current()
  local nvim = vim.env.NVIM and vim.fs.normalize(vim.env.NVIM)
  if nvim and vim.fs.dirname(nvim) == M.dir() then return nvim end
end

function M.alive(sock)
  local ok, chan = pcall(vim.fn.sockconnect, "pipe", sock, { rpc = true })
  if not ok or chan == 0 then return false end
  vim.fn.chanclose(chan)
  return true
end

-- Runs Lua `code` in the session on `sock` with `...` as its arguments. Returns
-- the result, or nil and the error.
function M.call(sock, code, ...)
  local ok, chan = pcall(vim.fn.sockconnect, "pipe", sock, { rpc = true })
  if not ok or chan == 0 then return nil, vim.fs.basename(sock) .. " is not running" end
  local done, res = pcall(vim.rpcrequest, chan, "nvim_exec_lua", code, { ... })
  pcall(vim.fn.chanclose, chan)
  if not done then return nil, res end
  return res
end

-- Starts session `name`'s server if it isn't running, and waits until it
-- answers. Returns true, or false and the error.
function M.ensure(name)
  local sock = M.sock(name)
  if M.alive(sock) then return true end
  if not M.sessions()[name] then return false, "no session named " .. name end
  os.remove(sock)
  vim.fn.mkdir(M.dir(), "p")
  -- detach: the server keeps running after whatever started it exits.
  vim.system(
    { vim.v.progpath, "--headless", "--listen", sock, "--cmd", "let g:mux = 1", "+Session " .. name },
    { detach = true, stdin = false, stdout = false, stderr = false }
  )
  if vim.wait(5000, function() return M.alive(sock) end, 50) then return true end
  return false, "session " .. name .. " did not start"
end

-- Plain `mux` outside a session attaches to the session saved here.
function M.remember(name)
  local f = io.open(vim.fs.joinpath(M.dir(), "last"), "w")
  if f then
    f:write(name, "\n")
    f:close()
  end
end

-- Moves the window showing the session on `sock` to session `name` (see switch
-- in init.lua). Returns true, or false and the error.
function M.switch(sock, name)
  local res, err = M.call(sock, "return require('mux').switch(...)", name)
  err = err or (res ~= "" and res) or nil
  return not err, err
end

-- Quits the session on `sock`. Each shell gets a hangup, but anything that
-- outlives it (background jobs, tools that ignore the hangup) keeps running.
function M.quit_one(sock)
  -- A separate client with a timeout: a server already shutting down (its last
  -- shell exited) may never answer.
  vim.system(
    { vim.v.progpath, "--clean", "--headless", "--server", sock, "--remote-send", "<Cmd>qa!<CR>" },
    { stdin = false, timeout = 2000 }
  ):wait()
end

-- Quits the sessions on `socks` (default: all) and returns how many were
-- running. Run inside one of them, quitting its own server ends the calling
-- shell, so that one is left for the caller to quit last; it is returned too.
function M.quit(socks)
  local n, own = 0, nil
  for _, sock in ipairs(socks or M.socks()) do
    if M.alive(sock) then
      n = n + 1
      if sock == M.current() then
        own = sock
      else
        M.quit_one(sock)
      end
    else
      os.remove(sock) -- nothing is listening, so this is a leftover file
    end
  end
  return n, own
end

local function output(cmd)
  local r = vim.system(cmd, { text = true }):wait()
  return r.code == 0 and r.stdout or ""
end

-- Stops every process on the ptys of the sessions on `socks` (default: all)
-- and their children, which catches ones that moved off the pty. Returns the
-- number of running sessions and of processes stopped.
function M.kill_procs(socks)
  local kids, parent = {}, {}
  for pid, ppid in output({ "ps", "-A", "-o", "pid=,ppid=" }):gmatch("(%d+)%s+(%d+)") do
    pid, ppid = tonumber(pid), tonumber(ppid)
    parent[pid] = ppid
    kids[ppid] = kids[ppid] or {}
    table.insert(kids[ppid], pid)
  end
  local queue, n = {}, 0
  for _, sock in ipairs(socks or M.socks()) do
    local ptys = M.alive(sock) and M.call(sock, "return require('mux').ptys()")
    if ptys then
      n = n + 1
      for pty in ptys:gmatch("[^\n]+") do
        for pid in output({ "ps", "-o", "pid=", "-t", vim.fs.basename(pty) }):gmatch("%d+") do
          table.insert(queue, tonumber(pid))
        end
      end
    end
  end
  if n == 0 then return 0, 0 end

  -- This process and the shells that ran it, when run inside a session.
  local skip, p = {}, vim.uv.os_getpid()
  while p and p > 1 do
    skip[p] = true
    p = parent[p]
  end
  local pids, seen = {}, {}
  while #queue > 0 do
    p = table.remove(queue, 1)
    if not seen[p] then
      seen[p] = true
      if not skip[p] then table.insert(pids, p) end
      vim.list_extend(queue, kids[p] or {})
    end
  end

  for _, pid in ipairs(pids) do
    vim.uv.kill(pid, "sigterm")
  end
  local function left()
    return vim.tbl_filter(function(pid) return vim.uv.kill(pid, 0) == 0 end, pids)
  end
  -- Give them a second to exit cleanly before forcing it.
  vim.wait(1000, function() return #left() == 0 end, 50)
  for _, pid in ipairs(left()) do
    vim.uv.kill(pid, "sigkill")
  end
  return n, #pids
end

function M.say(msg) io.stderr:write(msg, "\n") end

function M.fail(msg)
  io.stderr:write(msg, "\n")
  os.exit(1)
end

-- Hands this terminal to `cmd` until it exits, then exits with its code.
function M.exec(cmd)
  local code
  local handle = vim.uv.spawn(cmd[1], { args = vim.list_slice(cmd, 2), stdio = { 0, 1, 2 } }, function(c) code = c end)
  if not handle then M.fail("could not start " .. cmd[1]) end
  vim.wait(math.huge, function() return code ~= nil end, 50)
  os.exit(code)
end

-- A cold-started Ghostty opens its own blank window. It is closed once the
-- session window exists, so only one is left.
local new_window = [[
on run argv
  set wasRunning to application "Ghostty" is running
  tell application "Ghostty"
    activate
    set blank to missing value
    if not wasRunning then
      repeat 50 times
        if (count of windows) > 0 then exit repeat
        delay 0.1
      end repeat
      if (count of windows) > 0 then set blank to window 1
    end if
    set cfg to new surface configuration
    set command of cfg to "/bin/zsh -lic 'mux " & item 1 of argv & "'"
    new window with configuration cfg
    if blank is not missing value then close window blank
  end tell
end run
]]

-- For hotkeys, which run mux with no terminal: moves the window showing a
-- session to `name`, or opens a new Ghostty window on it when none is open.
local function show(name)
  for _, sock in ipairs(M.socks()) do
    if (M.call(sock, "return #vim.api.nvim_list_uis()") or 0) > 0 then
      local ok, err = M.switch(sock, name)
      if not ok then M.fail("mux: " .. err) end
      vim.system({ "open", "-a", "Ghostty" }):wait()
      return
    end
  end
  vim.system({ "osascript", "-", name }, { stdin = new_window }):wait()
end

-- Shows session `name`: inside a session, switches this window; from a
-- hotkey, the open window; otherwise attaches this terminal.
function M.open(name)
  local current = M.current()
  if current then
    local ok, err = M.switch(current, name)
    if not ok then M.fail("mux: " .. err) end
    return
  end
  if vim.uv.guess_handle(0) ~= "tty" then return show(name) end
  local ok, err = M.ensure(name)
  if not ok then M.fail("mux: " .. err) end
  M.remember(name)
  M.exec({ vim.v.progpath, "--remote-ui", "--server", M.sock(name) })
end

-- Re-runs the nvim config in every running session (see reload in init.lua).
local function restart()
  local n = 0
  for _, sock in ipairs(M.socks()) do
    if M.alive(sock) then
      local res, err = M.call(sock, "return require('mux').reload()")
      err = err or (res ~= "" and res) or nil
      if err then
        M.say("mux: " .. vim.fs.basename(sock):gsub("%.sock$", "") .. ": " .. err)
      else
        n = n + 1
      end
    end
  end
  if n == 0 then M.fail("mux: no sessions reloaded") end
  M.say(("mux: reloaded config in %d session(s)"):format(n))
end

-- Stops every process in the sessions, then quits the servers.
local function kill()
  local n, procs = M.kill_procs()
  if n == 0 then M.fail("mux: no running sessions") end
  M.say(("mux: killed %d session(s) and %d process(es)"):format(n, procs))
  -- A session quits by itself once its last shell exits, so this only catches the rest.
  local _, own = M.quit()
  if own then M.quit_one(own) end
end

local usage = [[
mux [session]  attach this terminal to a session, or switch this window to one
               (inside a session, no name opens a picker; outside, the last session)
mux restart    reload the nvim config in every running session
mux kill       stop every process in the sessions' shells, then quit them]]

function M.main(args)
  local cmd = args[1]
  if cmd == "restart" then return restart() end
  if cmd == "kill" then return kill() end
  if cmd == "-h" or cmd == "--help" then return M.say(usage) end
  if cmd == "names" then -- for tab completion
    return io.stdout:write(table.concat(vim.tbl_keys(M.sessions()), "\n"), "\n")
  end

  local current = M.current()
  if not cmd and current then
    local _, err = M.call(current, "return require('mux').pick()")
    if err then M.fail("mux: " .. err) end
    return
  end
  local name = cmd
  -- Like tmux attach: with no name, go back to the last session a window showed,
  -- or the session marked default = true the first time.
  local sessions = M.sessions()
  if not name then
    local f = io.open(vim.fs.joinpath(M.dir(), "last"))
    name = f and vim.trim(f:read("*a")) or ""
    if f then f:close() end
    if not sessions[name] then
      for n, s in pairs(sessions) do
        if s.default then name = n end
      end
    end
  end
  if not sessions[name] then M.fail("mux: no session named " .. name) end
  M.open(name)
end

return M
