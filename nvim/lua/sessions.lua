local M = {}

if not vim.g.mux then return M end

local function open_shell()
  vim.cmd.terminal()
  vim.bo.buflisted = false
end

local function set_highlights()
  local fill = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false })
  local dim = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
  vim.api.nvim_set_hl(0, "MuxFill", { fg = fill.fg, bg = fill.bg })
  vim.api.nvim_set_hl(0, "MuxTab", { fg = dim.fg, bg = fill.bg })
  vim.api.nvim_set_hl(0, "MuxTabSel", { fg = fill.fg, bg = fill.bg, bold = true })
end

-- Like the tmux bar: session on the left, tabs centered, clock on the right.
-- The tabs are padded by hand so they stay centered in the window even though
-- the left and right text differ in width; %= then pushes the clock to the edge.
function M.statusline()
  local left = " \u{e795} " .. (vim.g.session_name or "") -- terminal icon
  local right = os.date("%I:%M %p") .. " 󰥔 "
  local sep = " • "

  local names = {}
  local current = vim.api.nvim_get_current_tabpage()
  local tabs, tabs_width = {}, 0
  for i, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local ok, name = pcall(vim.api.nvim_tabpage_get_var, tab, "name")
    name = ok and name or tostring(i)
    table.insert(names, name)
    tabs_width = tabs_width + vim.fn.strdisplaywidth(name)
    local hl = tab == current and "%#MuxTabSel#" or "%#MuxTab#"
    table.insert(tabs, hl .. name:gsub("%%", "%%%%"))
  end
  tabs_width = tabs_width + vim.fn.strdisplaywidth(sep) * (#names - 1)

  local pad_left = math.floor((vim.o.columns - tabs_width) / 2) - vim.fn.strdisplaywidth(left)
  return table.concat({
    "%#MuxFill#" .. left:gsub("%%", "%%%%"),
    string.rep(" ", math.max(pad_left, 1)),
    table.concat(tabs, "%#MuxTab#" .. sep),
    "%#MuxFill#%=" .. right,
  })
end

function M.start(name)
  local session = require("session_defs")[name]
  if not session then
    vim.notify("No session named " .. name, vim.log.levels.ERROR)
    return
  end
  vim.g.session_name = name
  vim.cmd.cd(vim.fn.expand(session.path))

  for i, tab in ipairs(session.tabs) do
    -- The first tab reuses the tabpage nvim started with.
    if i > 1 then vim.cmd.tabnew() end
    vim.t.name = tab
    open_shell()
  end
  vim.cmd.tabfirst()
end

-- New tabs are unnamed; the bar shows their number until :TabRename.
function M.new_tab()
  vim.cmd.tabnew()
  open_shell()
end

-- Close the tab and kill its shells, like tmux kill-window. The last tab takes
-- the whole session with it.
function M.close_tab()
  if #vim.api.nvim_list_tabpages() == 1 then
    vim.cmd("qa!")
    return
  end
  local terms = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == "terminal" then table.insert(terms, buf) end
  end
  vim.cmd.tabclose()
  for _, buf in ipairs(terms) do
    if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
  end
end

-- Foreground process name of the terminal in the current window, read from its
-- pty (same idea as tmux's is_vim check).
function M.fg_comm()
  local chan = vim.bo.channel
  if chan == 0 then return nil end
  local pty = vim.api.nvim_get_chan_info(chan).pty
  if not pty then return nil end
  local out = vim.system({ "ps", "-o", "stat=,comm=", "-t", vim.fs.basename(pty) }):wait().stdout or ""
  for line in out:gmatch("[^\n]+") do
    local stat, comm = line:match("^%s*(%S+)%s+(.+)$")
    if stat and stat:find("+", 1, true) then return (vim.fs.basename(comm):gsub("^%-", "")) end
  end
  return nil
end

function M.fg_is_nvim()
  local comm = M.fg_comm()
  return comm ~= nil and comm:match("^n?vim$") ~= nil
end

-- Tool launchers (yazi, lazygit, file/grep pickers). A nested nvim gets its own
-- command as keys; an idle shell gets the shell command typed in; anything else
-- (claude, a server) is left alone, so the tool opens in a new tab.
function M.launch(nvim_keys, shell_cmd)
  if M.fg_is_nvim() then
    vim.api.nvim_chan_send(vim.bo.channel, nvim_keys)
    return
  end
  local comm = M.fg_comm()
  if not (comm and comm:match("^[zb]?a?sh$")) then M.new_tab() end
  -- Wait for a new tab's shell to start before typing into it.
  vim.defer_fn(function()
    if vim.bo.buftype == "terminal" then vim.api.nvim_chan_send(vim.bo.channel, shell_cmd .. "\r") end
  end, comm and 0 or 300)
end

-- Every session is a headless nvim server listening on <sock_dir>/<name>.sock
-- (same layout as zsh/functions/nv.zsh). A window is just a UI attached to one
-- of them, so `:connect` moves the window to another session and closing the
-- window leaves the session running.
local function sock_dir()
  return vim.fs.joinpath(vim.fs.normalize(vim.env.TMPDIR or "/tmp"), "nv-sessions")
end

local function sock_path(name) return vim.fs.joinpath(sock_dir(), name .. ".sock") end

local function alive(sock)
  local ok, chan = pcall(vim.fn.sockconnect, "pipe", sock, { rpc = true })
  if not ok or chan == 0 then return false end
  vim.fn.chanclose(chan)
  return true
end

-- Moves this window to session `name`, starting it first if needed. Must run
-- from the UI's own input (a keymap); :connect from an RPC call or autocmd has
-- no UI to move.
function M.switch(name)
  local sock = sock_path(name)
  if vim.fs.normalize(vim.v.servername) == sock then return end
  if not alive(sock) then
    if not require("session_defs")[name] then
      vim.notify("No session named " .. name, vim.log.levels.ERROR)
      return
    end
    vim.fn.mkdir(sock_dir(), "p")
    vim.fn.jobstart(
      { vim.v.progpath, "--headless", "--listen", sock, "--cmd", "let g:mux = 1", "+Session " .. name },
      { detach = true }
    )
    if not vim.wait(5000, function() return alive(sock) end, 50) then
      vim.notify("Session " .. name .. " did not start", vim.log.levels.ERROR)
      return
    end
  end
  vim.cmd({ cmd = "connect", args = { sock } })
end

-- nv-session.sh (window-manager hotkeys, and `nv <name>` inside a session)
-- leaves the wanted session name in a file and sends a key to the focused
-- window, so the switch runs from the UI's own input.
function M.switch_wanted()
  local file = vim.fs.joinpath(sock_dir(), "want")
  local f = io.open(file)
  if not f then return end
  local name = vim.trim(f:read("*a"))
  f:close()
  os.remove(file)
  if name ~= "" then M.switch(name) end
end

vim.o.showtabline = 0
vim.o.laststatus = 3
vim.o.statusline = "%!v:lua.require'sessions'.statusline()"
-- The outer terminal's scrollback is copy mode, but each kept line slows output:
-- at 100000, printing 300k lines takes about 4x as long as at 10000.
vim.o.scrollback = 10000

set_highlights()
vim.api.nvim_create_autocmd({ "ColorScheme", "VimResized" }, {
  group = vim.api.nvim_create_augroup("mux_bar", { clear = true }),
  callback = function(ev)
    if ev.event == "ColorScheme" then set_highlights() end
    vim.cmd.redrawstatus()
  end,
})
-- Keep the clock current.
vim.uv.new_timer():start(30000, 30000, vim.schedule_wrap(function() vim.cmd.redrawstatus() end))

vim.api.nvim_create_user_command("Session", function(opts) M.start(opts.args) end, {
  nargs = 1,
  complete = function() return vim.tbl_keys(require("session_defs")) end,
  desc = "Start a named session",
})

vim.api.nvim_create_user_command("TabRename", function(opts)
  vim.t.name = opts.args
  vim.cmd.redrawstatus()
end, { nargs = 1, desc = "Rename the current tab" })

local group = vim.api.nvim_create_augroup("mux", { clear = true })

-- Terminals behave like tmux panes: typing goes straight to the shell.
vim.api.nvim_create_autocmd("TermOpen", {
  group = group,
  callback = function()
    vim.wo.number = false
    vim.wo.signcolumn = "no"
    vim.wo.cursorline = false
    vim.cmd.startinsert()
  end,
})
vim.api.nvim_create_autocmd({ "TabEnter", "VimEnter" }, {
  group = group,
  callback = function()
    if vim.bo.buftype == "terminal" then vim.cmd.startinsert() end
  end,
})

-- `exit` in a shell closes its tab, like tmux. nvim's own TermClose default
-- deletes the buffer first (leaving an empty window in the tab), so drop it
-- and handle every exit here.
for _, au in ipairs(vim.api.nvim_get_autocmds({ group = "nvim.terminal", event = "TermClose" })) do
  if au.desc and au.desc:match("^Automatically close terminal buffers") then vim.api.nvim_del_autocmd(au.id) end
end
vim.api.nvim_create_autocmd("TermClose", {
  group = group,
  callback = function(ev)
    local wins = vim.fn.win_findbuf(ev.buf)
    local tab = wins[1] and vim.api.nvim_win_get_tabpage(wins[1])
    vim.schedule(function()
      if tab and vim.api.nvim_tabpage_is_valid(tab) and #vim.api.nvim_tabpage_list_wins(tab) == 1 then
        if #vim.api.nvim_list_tabpages() == 1 then
          vim.cmd("qa!")
          return
        end
        vim.cmd.tabclose(vim.api.nvim_tabpage_get_number(tab))
      end
      if vim.api.nvim_buf_is_valid(ev.buf) then vim.api.nvim_buf_delete(ev.buf, { force = true }) end
    end)
  end,
})

return M
