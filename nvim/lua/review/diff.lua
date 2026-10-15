local git = require("review.git")
local comments = require("review.comments")

local M = {}

local function side(state, file, label, sha, path, exists)
  local lines, ft = {}, nil
  if exists then
    local content, err = git.show(sha, path)
    if content then
      lines, ft = content, vim.filetype.match({ filename = path, contents = content })
    else
      lines = { err }
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  -- Named by the file's current path on both sides: it's unique across the
  -- PR, while an old path can repeat (a copy and its source both start there).
  vim.api.nvim_buf_set_name(buf, "review://" .. label .. "/" .. file.path)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  if ft then vim.bo[buf].filetype = ft end
  table.insert(state.bufs, buf)
  state.buf_info[buf] = { file = file, side = label == "base" and "LEFT" or "RIGHT" }
  require("review").map_common(buf)
  comments.map(state, buf)
  return buf, lines
end

local function winbar(label, path) return (" %s  %s"):format(label, path:gsub("%%", "%%%%")) end

function M.show(state)
  local file = state.files[state.current]
  local first_visit = not file.bufs
  if first_visit then
    local old_path = file.old_path or file.path
    local a, a_lines = side(state, file, "base", state.base, old_path, file.status ~= "A")
    local b, b_lines = side(state, file, "head", state.head, file.path, file.status ~= "D")
    file.bufs, file.lines = { a, b }, { a_lines, b_lines }
    comments.render(state, file)
  end

  -- diffoff before swapping buffers: the diff options belong to the window,
  -- and the new buffers would otherwise start with stale diff state.
  local wins = { state.left, state.right }
  for i, win in ipairs(wins) do
    vim.api.nvim_win_call(win, function() vim.cmd.diffoff() end)
    vim.api.nvim_win_set_buf(win, file.bufs[i])
  end
  for _, win in ipairs(wins) do
    vim.api.nvim_win_call(win, function() vim.cmd.diffthis() end)
    vim.wo[win].foldlevel = 0 -- fold unchanged regions; the global foldlevel keeps everything open
  end
  vim.wo[state.left].winbar = winbar("base", file.old_path or file.path)
  vim.wo[state.right].winbar = winbar("head", file.path)

  if first_visit then
    vim.api.nvim_win_call(state.right, function()
      vim.cmd("normal! gg")
      if vim.fn.diff_hlID(1, 1) == 0 and vim.fn.diff_filler(1) == 0 then vim.cmd("normal! ]c") end
    end)
  end
end

return M
