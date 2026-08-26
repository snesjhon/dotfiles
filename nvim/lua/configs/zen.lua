-- Zen mode -- pads the current window with a single empty left-hand margin,
-- similar in spirit to no-neck-pain.nvim but built from core Neovim only (no
-- external dependency). Left-only and borderless to match the reference vim
-- setup: a plain margin, not a centered/boxed column.
local M = {}

local width = 100
local min_side_width = 10 -- below this a pad reads as pointless, not as margin
local state = nil -- { main = winid, left = winid }
local awaiting_reenable = false -- a real split is open; re-pad once it closes

local function side_win(cmd)
  vim.cmd(cmd)
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win, buf)
  -- Non-modifiable: nothing typed here can ever set 'modified', so closing
  -- these windows can never be blocked by (or discard) real content.
  vim.bo[buf].modifiable = false
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].cursorline = false
  vim.wo[win].winfixwidth = true
  -- vert: blank the separator between the pad and `main` -- it should read
  -- as empty margin, not a bounded panel, regardless of the active colorscheme.
  vim.wo[win].fillchars = "eob: ,vert: "
  vim.wo[win].statusline = " "
  return win
end

-- The main window's width changes as a side effect of adding/removing the
-- pads, but Neovim doesn't fire WinResized for that on its own. Width-aware
-- content (e.g. snacks' dashboard, which centers text based on window width
-- at render time) needs this nudge to re-layout for the new width.
local function notify_resize() vim.api.nvim_exec_autocmds("WinResized", {}) end

local function off()
  if not state then return end
  if vim.api.nvim_win_is_valid(state.left) then vim.api.nvim_win_close(state.left, true) end
  state = nil
  notify_resize()
end

local function on()
  local main = vim.api.nvim_get_current_win()
  local pad = math.floor((vim.o.columns - width) / 2)
  if pad < min_side_width then return end

  local left = side_win("leftabove vsplit")
  vim.api.nvim_win_set_width(left, pad)

  vim.api.nvim_set_current_win(main)
  state = { main = main, left = left }
  notify_resize()
end

function M.toggle()
  if state then
    off()
  else
    on()
  end
end

-- Run a real split command. Drops the pads first so the split gets the
-- full width; once it's the only window left again, the pads come back.
function M.split(cmd)
  local was_enabled = state ~= nil
  if was_enabled then off() end
  vim.cmd(cmd)
  if was_enabled then
    if #vim.api.nvim_list_wins() > 1 then
      awaiting_reenable = true
    else
      on()
    end
  end
end

-- On by default. Deferred to UIEnter (fires after VimEnter for the builtin
-- TUI) so it runs after snacks' dashboard has had a chance to open -- the
-- dashboard refuses to open unless there's exactly one window.
--
-- Skip padding if the dashboard is what's showing: it centers its own
-- content based on the window it's in, so padding it here would just shift
-- that centering off to the right instead of leaving it centered on screen.
-- The SnacksDashboardClosed hook below re-pads once a real buffer takes over.
vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    if vim.bo.filetype ~= "snacks_dashboard" then on() end
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "SnacksDashboardOpened",
  callback = function()
    if state then off() end
  end,
})

-- Closed fires from inside the dashboard buffer's BufWipeout autocommand,
-- where Neovim disallows splitting a window (E1159) -- defer to let that
-- close finish first.
vim.api.nvim_create_autocmd("User", {
  pattern = "SnacksDashboardClosed",
  callback = function()
    vim.schedule(function()
      if not state then on() end
    end)
  end,
})

-- Keep the side window out of the way: skip entering it, resize it on
-- terminal resize, and drop state if the user closes it manually.
vim.api.nvim_create_autocmd("WinEnter", {
  callback = function()
    if not state then return end
    if vim.api.nvim_get_current_win() == state.left then
      vim.api.nvim_set_current_win(state.main)
    end
  end,
})

vim.api.nvim_create_autocmd("WinClosed", {
  callback = function(ev)
    if not state then return end
    local win = tonumber(ev.match)
    if win == state.main then
      -- Main window closed (e.g. :q): close the pad too, on the next tick
      -- since windows can't be closed from inside a WinClosed callback.
      -- With no windows left this quits Neovim, so a single :q is enough.
      local left = state.left
      state = nil
      vim.schedule(function()
        -- 'hidden' (on by default) lets :q close main's window even with
        -- unsaved changes -- it just hides the buffer instead of erroring.
        -- Ask up front, the same way :qall would, instead of silently
        -- closing the pad first and only hitting the real check once we'd
        -- reach the truly-last window.
        if #vim.fn.getbufinfo({ bufmodified = 1 }) > 0 then
          vim.cmd("confirm qall")
          return
        end

        -- nvim_win_close() refuses to close the last window (E444); :quit
        -- on the last window just exits Neovim like a normal quit would.
        if vim.api.nvim_win_is_valid(left) then
          vim.api.nvim_set_current_win(left)
          vim.cmd("quit")
        end
      end)
    elseif win == state.left then
      state = nil
    end
  end,
})

-- A real split (opened via M.split) just closed: re-pad if it was the
-- last extra window. Deferred for the same reason as above.
vim.api.nvim_create_autocmd("WinClosed", {
  callback = function()
    if not awaiting_reenable then return end
    vim.schedule(function()
      if awaiting_reenable and not state and #vim.api.nvim_list_wins() == 1 then
        awaiting_reenable = false
        on()
      end
    end)
  end,
})

-- Covers a tmux split too: narrowing the pane shrinks this Neovim instance's
-- terminal size the same way, which fires this same event. Below the
-- minimum, drop the pad entirely rather than squeeze it thin -- matching the
-- vim setup, this doesn't auto re-pad once the split closes; `<leader>z`
-- brings it back.
vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    if not state then return end
    local pad = math.floor((vim.o.columns - width) / 2)
    if pad < min_side_width then
      off()
      return
    end
    if vim.api.nvim_win_is_valid(state.left) then vim.api.nvim_win_set_width(state.left, pad) end
  end,
})

return M
