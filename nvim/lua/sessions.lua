-- Mux mode: nvim as a tmux replacement ---------------------------------------
-- Only active when started by `nv` (which passes `--cmd "let g:mux = 1"`), so
-- plain nvim and the nvims nested inside mux terminals are untouched.
-- Every tab is a shell (a tmux "window"); the only UI is a bottom bar:
--   dev │ code  agent  server
local M = {}

if not vim.g.mux then return M end

local function open_shell()
  vim.cmd.terminal()
  vim.bo.buflisted = false
end

function M.statusline()
  local parts = { "%#TabLineFill# " .. (vim.g.session_name or "") .. " │" }
  local current = vim.api.nvim_get_current_tabpage()
  for i, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local ok, name = pcall(vim.api.nvim_tabpage_get_var, tab, "name")
    local hl = tab == current and "%#TabLineSel#" or "%#TabLine#"
    table.insert(parts, hl .. " " .. (ok and name or tostring(i)) .. " ")
  end
  table.insert(parts, "%#TabLineFill#")
  return table.concat(parts)
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

-- Is the terminal in the current window running nvim in the foreground? Same
-- idea as tmux's is_vim check: look at the foreground process on its pty.
function M.fg_is_nvim()
  local chan = vim.bo.channel
  if chan == 0 then return false end
  local pty = vim.api.nvim_get_chan_info(chan).pty
  if not pty then return false end
  local out = vim.system({ "ps", "-o", "stat=,comm=", "-t", vim.fs.basename(pty) }):wait().stdout or ""
  for line in out:gmatch("[^\n]+") do
    local stat, comm = line:match("^%s*(%S+)%s+(.+)$")
    if stat and stat:find("+", 1, true) and vim.fs.basename(comm):match("^n?vim$") then return true end
  end
  return false
end

vim.o.showtabline = 0
vim.o.laststatus = 3
vim.o.statusline = "%!v:lua.require'sessions'.statusline()"
vim.o.scrollback = 100000 -- max; the outer terminal's scrollback is copy mode

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
