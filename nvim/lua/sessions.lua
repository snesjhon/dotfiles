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
