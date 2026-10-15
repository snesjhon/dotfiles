local M = {}

M.width = 35

local ns = vim.api.nvim_create_namespace("review.tree")
local ns_current = vim.api.nvim_create_namespace("review.tree.current")
local ns_counts = vim.api.nvim_create_namespace("review.tree.counts")

local status_hl = { A = "Added", C = "Added", D = "Removed", M = "Changed", R = "Changed", T = "Changed" }

-- Puts files in the order the tree shows them, so ]f/[f walk it top to bottom.
function M.sort(files)
  for _, file in ipairs(files) do
    file.dir = vim.fs.dirname(file.path)
    file.name = vim.fs.basename(file.path)
  end
  table.sort(files, function(a, b)
    if a.dir ~= b.dir then return a.dir < b.dir end
    return a.name < b.name
  end)
end

function M.create(state)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, "review://files")
  table.insert(state.bufs, buf)
  state.tree_buf = buf

  local lines, marks = {}, {}
  state.rows, state.file_at_row = {}, {}
  local dir
  for i, file in ipairs(state.files) do
    if file.dir ~= dir then
      dir = file.dir
      if dir ~= "." then
        -- Deep paths (Java packages) would run off the panel; the pane header has the full path.
        local label = #dir + 1 < M.width and dir or vim.fn.pathshorten(dir)
        table.insert(lines, label .. "/")
        table.insert(marks, { #lines, 0, #label + 1, "Directory" })
      end
    end
    local indent = dir == "." and "" or "  "
    table.insert(lines, indent .. file.status .. " " .. file.name)
    table.insert(marks, { #lines, #indent, #indent + 1, status_hl[file.status] or "Changed" })
    state.rows[i] = #lines
    state.file_at_row[#lines] = i
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  for _, m in ipairs(marks) do
    vim.api.nvim_buf_set_extmark(buf, ns, m[1] - 1, m[2], { end_col = m[3], hl_group = m[4] })
  end
  vim.bo[buf].modifiable = false

  local win = state.tree_win
  vim.api.nvim_win_set_buf(win, buf)
  for option, value in pairs({
    number = false,
    relativenumber = false,
    signcolumn = "no",
    foldcolumn = "0",
    cursorline = true,
    wrap = false,
    winfixwidth = true,
  }) do
    vim.wo[win][option] = value
  end
  local title = state.pr and ("#" .. state.pr.number .. " " .. state.pr.title) or state.title
  vim.wo[win].winbar = " " .. title:gsub("%%", "%%%%")

  local review = require("review")
  review.map_common(buf)
  vim.keymap.set("n", "<CR>", function()
    local i = state.file_at_row[vim.api.nvim_win_get_cursor(0)[1]]
    if not i then return end
    review.select(i)
    vim.api.nvim_set_current_win(state.right)
  end, { buffer = buf, desc = "Open file" })
end

function M.update_counts(state)
  vim.api.nvim_buf_clear_namespace(state.tree_buf, ns_counts, 0, -1)
  local counts = {}
  for _, c in ipairs(state.comments) do
    counts[c.path] = (counts[c.path] or 0) + 1
  end
  for i, file in ipairs(state.files) do
    if counts[file.path] then
      vim.api.nvim_buf_set_extmark(state.tree_buf, ns_counts, state.rows[i] - 1, 0, {
        virt_text = { { " " .. counts[file.path], "DiagnosticInfo" } },
      })
    end
  end
end

function M.mark_current(state)
  local row = state.rows[state.current]
  vim.api.nvim_buf_clear_namespace(state.tree_buf, ns_current, 0, -1)
  vim.api.nvim_buf_set_extmark(state.tree_buf, ns_current, row - 1, 0, { line_hl_group = "Visual" })
  vim.api.nvim_win_set_cursor(state.tree_win, { row, 0 })
end

return M
