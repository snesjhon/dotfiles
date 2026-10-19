local M = {}

local opposite = { h = "l", j = "k", k = "j", l = "h" }

-- In nvim nested in a mux shell, moving past the last split moves to the mux's
-- next pane (mux move). Anywhere else it wraps to the far split.
local function at_edge(dir)
  if vim.g.mux or not vim.env.NVIM then
    vim.cmd("999wincmd " .. opposite[dir])
    return
  end
  local ok, chan = pcall(vim.fn.sockconnect, "pipe", vim.env.NVIM, { rpc = true })
  if not ok or chan == 0 then return end
  pcall(vim.rpcrequest, chan, "nvim_exec_lua", "local mux = require('mux'); if mux.move then mux.move(...) end", { dir })
  vim.fn.chanclose(chan)
end

function M.move(dir)
  local win = vim.api.nvim_get_current_win()
  vim.cmd.wincmd(dir)
  if vim.api.nvim_get_current_win() == win then at_edge(dir) end
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
