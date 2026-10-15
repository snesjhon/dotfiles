local git = require("review.git")
local store = require("review.store")
local ui = require("review.ui")

local M = {}

local ns = vim.api.nvim_create_namespace("review.comments")

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

local function mine_lines(body)
  local virt = {}
  for _, text in ipairs(vim.split(body, "\n")) do
    table.insert(virt, { { "┃ ", "DiagnosticInfo" }, { text, "DiagnosticVirtualTextInfo" } })
  end
  return virt
end

local function thread_lines(thread)
  local virt = {}
  for i, c in ipairs(thread.entries) do
    if i > 1 then table.insert(virt, { { "│", "Comment" } }) end
    table.insert(virt, { { "│ ", "Comment" }, { c.user and c.user.login or "ghost", "Title" } })
    for _, text in ipairs(vim.split((c.body:gsub("\r", "")), "\n")) do
      table.insert(virt, { { "│ ", "Comment" }, { text, "Comment" } })
    end
  end
  return virt
end

-- Draws other people's threads (dimmed) and your comments as signs on their
-- lines plus virtual lines under the last one.
M.across = across

function M.render(state, file)
  local bufs = { LEFT = file.bufs[1], RIGHT = file.bufs[2] }
  for _, buf in pairs(bufs) do
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  end

  local blocks = {}
  for _, t in ipairs(state.remote) do
    if t.path == file.path then
      table.insert(blocks, { t.side, t.start_line or t.line, t.line, thread_lines(t), "Comment" })
    end
  end
  for _, c in ipairs(state.comments) do
    if c.path == file.path then
      table.insert(blocks, { c.side, c.start_line or c.line, c.line, mine_lines(c.body), "DiagnosticInfo" })
    end
  end

  for _, block in ipairs(blocks) do
    local side, first, last, virt, sign_hl = unpack(block)
    local buf = bufs[side]
    -- Remote comments can point past the end when they're for a newer commit.
    if last <= vim.api.nvim_buf_line_count(buf) then
      for line = first, last do
        vim.api.nvim_buf_set_extmark(buf, ns, line - 1, 0, { sign_text = "▎", sign_hl_group = sign_hl })
      end
      vim.api.nvim_buf_set_extmark(buf, ns, last - 1, 0, { virt_lines = virt })

      -- Blank lines in the other pane keep the rows below lined up; diff mode
      -- doesn't count virtual lines when it aligns the panes.
      local pad = {}
      for i = 1, #virt do
        pad[i] = { { " " } }
      end
      local other = side == "LEFT" and bufs.RIGHT or bufs.LEFT
      local row = math.min(across(file, side, last), vim.api.nvim_buf_line_count(other))
      if row < 1 then
        vim.api.nvim_buf_set_extmark(other, ns, 0, 0, { virt_lines = pad, virt_lines_above = true })
      else
        vim.api.nvim_buf_set_extmark(other, ns, row - 1, 0, { virt_lines = pad })
      end
    end
  end
end

function M.clear(buf) vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1) end

local function changed(state, file)
  store.save(state)
  M.render(state, file)
  require("review.tree").refresh(state)
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

-- The commented lines with 5 lines around them, highlighted, with the comment under them.
local function preview(state, file, c)
  local sha, path = state.head, file.path
  if c.side == "LEFT" then
    sha, path = state.base, file.old_path or file.path
  end
  local lines = git.show(sha, path) or {}
  local first = c.start_line or c.line
  local from, to = math.max(1, first - 5), math.min(#lines, c.line + 5)

  local extmarks = {}
  for line = first, c.line do
    table.insert(extmarks, { row = line - from + 1, col = 0, line_hl_group = "Visual" })
  end
  table.insert(extmarks, { row = c.line - from + 1, col = 0, virt_lines = mine_lines(c.body) })

  return {
    text = table.concat(vim.list_slice(lines, from, to), "\n"),
    ft = vim.filetype.match({ filename = path }),
    extmarks = extmarks,
    loc = false,
  }
end

function M.list(state)
  if #state.comments == 0 then return vim.notify("No comments yet") end
  local index = {}
  for i, file in ipairs(state.files) do
    index[file.path] = i
  end

  local items = {}
  for _, c in ipairs(state.comments) do
    local file = state.files[index[c.path]]
    local summary = vim.split(c.body, "\n")[1]
    table.insert(items, {
      text = ("%s:%d %s"):format(c.path, c.line, summary), -- what the picker matches against
      comment = c,
      file_index = index[c.path],
      summary = summary,
      preview = preview(state, file, c),
    })
  end

  require("snacks").picker.pick({
    title = "Review comments",
    items = items,
    preview = "preview",
    format = function(item)
      local c = item.comment
      return {
        { c.path, "Directory" },
        { ":" .. c.line, "LineNr" },
        { c.side == "LEFT" and " base " or " head ", "Comment" },
        { item.summary },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      require("review").select(item.file_index)
      local win = item.comment.side == "LEFT" and state.left or state.right
      vim.api.nvim_set_current_win(win)
      vim.api.nvim_win_set_cursor(win, { item.comment.line, 0 })
    end,
  })
end

function M.map(state, buf)
  local function map(...) require("review").map(buf, ...) end
  map("n", "cc", function()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    M.add(state, line, line)
  end, "Comment on line")
  map("x", "c", function()
    local a, b = vim.fn.line("v"), vim.fn.line(".")
    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
    M.add(state, math.min(a, b), math.max(a, b))
  end, "Comment on lines")
  map("n", "ce", function() M.edit(state) end, "Edit comment")
  map("n", "cd", function() M.delete(state) end, "Delete comment")
end

return M
