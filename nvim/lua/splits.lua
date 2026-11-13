local M = {}

local opposite = { h = "l", j = "k", k = "j", l = "h" }

local function wrap(dir) vim.cmd("999wincmd " .. opposite[dir]) end

-- Moves to the next split in direction dir (h/j/k/l). Past the last split,
-- calls at_edge(dir), which by default wraps to the far split.
function M.move(dir, at_edge)
  local win = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(dir)
  if vim.api.nvim_get_current_win() == win then (at_edge or wrap)(dir) end
end

-- Moves the divider toward dir (h/l). Plain :vertical resize grows or shrinks
-- the current window, which would push the divider the wrong way in the
-- rightmost split.
function M.resize(dir)
  local has_right = vim.fn.winnr("l") ~= vim.fn.winnr()
  local grow = (dir == "l") == has_right
  vim.cmd("vertical resize " .. (grow and "+3" or "-3"))
end

return M
