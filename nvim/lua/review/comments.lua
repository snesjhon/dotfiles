local git = require("review.git")
local ui = require("review.ui")

local M = {}

local ns = vim.api.nvim_create_namespace("review.comments")

-- Saved under the common git dir so every worktree of the repo sees the same review.
function M.store_path(key)
  local dir = vim.trim(git.run({ "rev-parse", "--path-format=absolute", "--git-common-dir" }) or "")
  return vim.fs.joinpath(dir, "review", key .. ".json")
end

function M.load(state)
  state.comments = {}
  local f = io.open(state.store)
  if not f then return end
  local ok, data = pcall(vim.json.decode, f:read("*a"))
  f:close()
  if not ok then return vim.notify("Couldn't read " .. state.store, vim.log.levels.WARN) end
  state.comments = data.comments or {}
  if data.head ~= state.head then
    vim.notify(
      ("%d saved comments were written against an older commit, so their lines may have moved"):format(#data.comments),
      vim.log.levels.WARN
    )
  end
end

local function save(state)
  if #state.comments == 0 then
    os.remove(state.store)
    return
  end
  vim.fn.mkdir(vim.fs.dirname(state.store), "p")
  vim.fn.writefile({ vim.json.encode({ head = state.head, comments = state.comments }) }, state.store)
end

-- GitHub rejects the whole review if any comment sits outside a hunk, so this
-- is checked when the comment is written instead of at submit.
local function in_hunk(state, file, side, first, last)
  file.hunks = file.hunks or git.hunks(state.base, state.head, file)
  for _, hunk in ipairs(file.hunks[side]) do
    if first >= hunk[1] and last <= hunk[2] then return true end
  end
  return false
end

-- Hunks between the two panes as { start_a, count_a, start_b, count_b }, from
-- the same diff engine :diffthis uses.
local function alignment(file)
  if not file.alignment then
    local function text(lines) return #lines == 0 and "" or table.concat(lines, "\n") .. "\n" end
    file.alignment = vim.text.diff(text(file.lines[1]), text(file.lines[2]), {
      result_type = "indices",
      indent_heuristic = vim.o.diffopt:find("indent-heuristic") ~= nil,
      algorithm = vim.o.diffopt:match("algorithm:(%w+)"),
    })
  end
  return file.alignment
end

-- The line in the other pane drawn on the same row as `line`. Inside a hunk
-- where the other pane only has filler, it's that hunk's last line (0 when the
-- other side of the hunk is empty and it starts the file).
local function across(file, side, line)
  -- A hunk with count 0 starts after `start`, so the next shared line is start + 1.
  local function after(start, count) return count == 0 and start + 1 or start + count end
  local offset = 0
  for _, h in ipairs(alignment(file)) do
    local start, count, other_start, other_count = h[3], h[4], h[1], h[2]
    if side == "LEFT" then
      start, count, other_start, other_count = h[1], h[2], h[3], h[4]
    end
    if line < (count == 0 and start + 1 or start) then break end
    if line < start + count then
      local k = line - start
      if k < other_count then return other_start + k end
      return other_count == 0 and other_start or other_start + other_count - 1
    end
    offset = after(other_start, other_count) - after(start, count)
  end
  return line + offset
end

function M.render(state, file)
  local bufs = { LEFT = file.bufs[1], RIGHT = file.bufs[2] }
  for _, buf in pairs(bufs) do
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  end

  for _, c in ipairs(state.comments) do
    if c.path == file.path then
      local buf = bufs[c.side]
      for line = c.start_line or c.line, c.line do
        vim.api.nvim_buf_set_extmark(buf, ns, line - 1, 0, { sign_text = "▎", sign_hl_group = "DiagnosticInfo" })
      end
      local virt, pad = {}, {}
      for _, text in ipairs(vim.split(c.body, "\n")) do
        table.insert(virt, { { "┃ ", "DiagnosticInfo" }, { text, "DiagnosticVirtualTextInfo" } })
        table.insert(pad, { { " " } })
      end
      vim.api.nvim_buf_set_extmark(buf, ns, c.line - 1, 0, { virt_lines = virt })

      -- Blank lines in the other pane keep the rows below lined up; diff mode
      -- doesn't count virtual lines when it aligns the panes.
      local other = c.side == "LEFT" and bufs.RIGHT or bufs.LEFT
      local row = math.min(across(file, c.side, c.line), vim.api.nvim_buf_line_count(other))
      if row < 1 then
        vim.api.nvim_buf_set_extmark(other, ns, 0, 0, { virt_lines = pad, virt_lines_above = true })
      else
        vim.api.nvim_buf_set_extmark(other, ns, row - 1, 0, { virt_lines = pad })
      end
    end
  end
end

local function changed(state, file)
  save(state)
  M.render(state, file)
  require("review.tree").update_counts(state)
end

function M.add(state, first, last)
  local info = state.buf_info[vim.api.nvim_get_current_buf()]
  if not in_hunk(state, info.file, info.side, first, last) then
    local where = first == last and ("Line %d is"):format(last) or ("Lines %d-%d aren't all"):format(first, last)
    return vim.notify(
      where .. " outside the diff. GitHub only takes comments on changed lines and the 3 lines around them.",
      vim.log.levels.ERROR
    )
  end

  local title = first == last and ("Line %d"):format(last) or ("Lines %d-%d"):format(first, last)
  ui.edit(title, "", function(body)
    if body == "" then return end
    table.insert(state.comments, {
      path = info.file.path,
      side = info.side,
      line = last,
      start_line = first ~= last and first or nil,
      body = body,
    })
    changed(state, info.file)
  end)
end

-- The newest comment covering the cursor line, and its index in state.comments.
local function under_cursor(state)
  local info = state.buf_info[vim.api.nvim_get_current_buf()]
  local line = vim.api.nvim_win_get_cursor(0)[1]
  for i = #state.comments, 1, -1 do
    local c = state.comments[i]
    if c.path == info.file.path and c.side == info.side and line >= (c.start_line or c.line) and line <= c.line then
      return c, i, info.file
    end
  end
  vim.notify("No comment on this line")
end

function M.edit(state)
  local c, i, file = under_cursor(state)
  if not c then return end
  ui.edit("Edit comment", c.body, function(body)
    if body == "" then
      table.remove(state.comments, i)
    else
      c.body = body
    end
    changed(state, file)
  end)
end

function M.delete(state)
  local c, i, file = under_cursor(state)
  if not c then return end
  if vim.fn.confirm("Delete this comment?", "&Yes\n&No", 2) ~= 1 then return end
  table.remove(state.comments, i)
  changed(state, file)
end

function M.map(state, buf)
  local function map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc }) end
  map("n", "c", function()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    M.add(state, line, line)
  end, "Comment on line")
  map("x", "c", function()
    local a, b = vim.fn.line("v"), vim.fn.line(".")
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
    M.add(state, math.min(a, b), math.max(a, b))
  end, "Comment on lines")
  map("n", "e", function() M.edit(state) end, "Edit comment")
  map("n", "dc", function() M.delete(state) end, "Delete comment")
end

return M
