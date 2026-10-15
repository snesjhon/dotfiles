local git = require("review.git")
local tree = require("review.tree")
local diff = require("review.diff")
local comments = require("review.comments")
local gh = require("review.gh")
local store = require("review.store")

local M = {}

-- One review at a time: buffer names are fixed per path.
M.state = nil

local group = vim.api.nvim_create_augroup("review", { clear = true })

local function load_pr(pr)
  local number = tostring(pr.number)
  local remote = git.remote_for(pr.repo)
  if not git.rev_parse(pr.headRefOid) then
    vim.notify("Fetching PR #" .. number .. "...")
    vim.cmd.redraw()
    local out, fetch_err = git.run({ "fetch", "--quiet", remote, "refs/pull/" .. number .. "/head" })
    if not out then return nil, fetch_err end
  end
  if not git.rev_parse(pr.baseRefOid) then git.run({ "fetch", "--quiet", remote, pr.baseRefName }) end

  local base, base_err = git.merge_base(pr.baseRefOid, pr.headRefOid)
  if not base then return nil, base_err end
  return {
    key = number,
    pr = { number = pr.number, title = pr.title, host = pr.host, repo = pr.repo },
    base = base,
    head = pr.headRefOid,
  }
end

local function branch_key()
  local branch = vim.trim(git.run({ "symbolic-ref", "--short", "-q", "HEAD" }) or "")
  if branch == "" then branch = git.rev_parse("HEAD"):sub(1, 12) end
  return "branch-" .. branch:gsub("[^%w._-]", "_")
end

-- The current branch's PR. Comments written in a branch review move over the
-- first time it's opened, so notes taken before the PR existed can be submitted.
local function load_branch_pr(pr)
  local review, err = load_pr(pr)
  if not review then return nil, err end
  local from, to = store.path(branch_key()), store.path(review.key)
  if vim.uv.fs_stat(from) and not vim.uv.fs_stat(to) then os.rename(from, to) end
  if git.rev_parse("HEAD") ~= review.head then
    vim.notify("Reviewing PR #" .. review.key .. " as pushed. Local commits that aren't pushed are left out.")
  end
  return review
end

local function load_branch(override)
  local ref = require("configs.git_pr_base")(override)
  if not ref then return nil end
  local head = git.rev_parse("HEAD")
  local base, err = git.merge_base(ref, head)
  if not base then return nil, err end
  return { key = branch_key(), title = ref .. "...HEAD", base = base, head = head }
end

local function cleanup()
  local state = M.state
  if not state then return end
  for _, buf in ipairs(state.bufs) do
    if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
  end
  -- Real file buffers stay (unless the review loaded them), minus the review's keymaps and marks.
  for _, m in ipairs(state.real_maps) do
    pcall(vim.keymap.del, m[2], m[3], { buffer = m[1] })
  end
  for buf, loaded_by_review in pairs(state.real_bufs) do
    if vim.api.nvim_buf_is_valid(buf) then
      comments.clear(buf)
      if loaded_by_review and not vim.bo[buf].modified and #vim.fn.win_findbuf(buf) == 0 then
        vim.api.nvim_buf_delete(buf, {})
      end
    end
  end
  vim.api.nvim_clear_autocmds({ group = group })
  M.state = nil
end

function M.close()
  local state = M.state
  if not state then return end
  if vim.api.nvim_tabpage_is_valid(state.tab) then
    -- nvim refuses to close the last tab, so give it somewhere to land.
    if #vim.api.nvim_list_tabpages() == 1 then vim.cmd.tabnew() end
    vim.cmd.tabclose(vim.api.nvim_tabpage_get_number(state.tab))
  end
  cleanup()
end

function M.select(i)
  local state = M.state
  if not state or not state.files[i] then return end
  state.current = i
  diff.show(state)
  tree.mark_current(state)
end

function M.map(buf, mode, lhs, rhs, desc)
  local state = M.state
  local action = rhs
  -- A real file buffer can also be open in another tab (e.g. after `e`), where
  -- it's just the file and its normal keys apply. It also outlives the review,
  -- so its keymaps are recorded for cleanup.
  if state.real_bufs[buf] ~= nil then
    action = function()
      if vim.api.nvim_get_current_tabpage() == state.tab then return rhs() end
      local count = vim.v.count > 0 and tostring(vim.v.count) or ""
      vim.api.nvim_feedkeys(count .. vim.keycode(lhs), "n", false)
    end
    table.insert(state.real_maps, { buf, mode, lhs })
  end
  vim.keymap.set(mode, lhs, action, { buffer = buf, desc = desc })
end

-- Opens the file in the tab the review started from, at the matching line
-- when called from a diff pane. The review stays open in its own tab.
function M.edit_file()
  local state = M.state
  local buf = vim.api.nvim_get_current_buf()
  local i, line = state.current, 1
  if buf == state.tree_buf then
    i = state.file_at_row[vim.api.nvim_win_get_cursor(0)[1]]
    if not i then return end
  else
    local info = state.buf_info[buf]
    line = vim.api.nvim_win_get_cursor(0)[1]
    if info.side == "LEFT" then line = math.max(comments.across(info.file, "LEFT", line), 1) end
  end

  local file = state.files[i]
  if file.status == "D" then return vim.notify(file.path .. " is deleted in this review, so there's no file to open") end
  if vim.api.nvim_tabpage_is_valid(state.origin_tab) then
    vim.api.nvim_set_current_tabpage(state.origin_tab)
  else
    vim.cmd.tabnew()
  end
  vim.cmd.edit(vim.fn.fnameescape(vim.fs.joinpath(state.worktree, file.path)))
  pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 })
end

function M.map_common(buf)
  local function map(lhs, rhs, desc) M.map(buf, "n", lhs, rhs, desc) end
  map("q", M.close, "Close review")
  map("x", function()
    local state = M.state
    local i = state.current
    if vim.api.nvim_get_current_buf() == state.tree_buf then
      i = state.file_at_row[vim.api.nvim_win_get_cursor(0)[1]]
    end
    if i then tree.toggle_viewed(state, i) end
  end, "Toggle viewed")
  map(".", function() M.select(M.state.current + 1) end, "Next file")
  map(",", function() M.select(M.state.current - 1) end, "Previous file")
  map("e", M.edit_file, "Open file in the editor")
  map("L", function() comments.list(M.state) end, "List comments")
  map("S", function() require("review.submit")(M.state) end, "Submit review")
end

-- arg: a PR number, a base ref, or empty for the branch's PR (or its PR base when it has none).
function M.open(arg)
  arg = vim.trim(arg or "")
  if M.state then
    if M.state.arg == arg and vim.api.nvim_tabpage_is_valid(M.state.tab) then
      vim.api.nvim_set_current_tabpage(M.state.tab)
      return
    end
    M.close()
  end

  local review, err
  if arg:match("^%d+$") then
    local pr
    pr, err = gh.pr(arg)
    if pr then review, err = load_pr(pr) end
  else
    -- With no ref given, the branch's own PR comes first so the review can be submitted.
    local pr = arg == "" and gh.pr() or nil
    if pr then
      review, err = load_branch_pr(pr)
    else
      review, err = load_branch(arg ~= "" and arg or nil)
    end
  end
  if not review then
    if err then vim.notify(err, vim.log.levels.ERROR) end
    return
  end

  local files, files_err = git.changed_files(review.base, review.head)
  if not files then return vim.notify(files_err, vim.log.levels.ERROR) end
  if #files == 0 then return vim.notify("No changes to review") end
  tree.sort(files)

  -- The right pane can show real files only when the worktree is at head.
  local at_head = git.rev_parse("HEAD") == review.head
  local worktree = git.root()
  local origin_tab = vim.api.nvim_get_current_tabpage()

  vim.cmd.tabnew()
  local placeholder = vim.api.nvim_get_current_buf()
  local state = vim.tbl_extend("force", review, {
    arg = arg,
    files = files,
    bufs = {},
    buf_info = {},
    real_bufs = {},
    real_maps = {},
    remote = {},
    origin_tab = origin_tab,
    worktree = worktree,
    root = at_head and worktree or nil,
    dirty = at_head and git.dirty() or {},
    store = store.path(review.key),
    tab = vim.api.nvim_get_current_tabpage(),
    right = vim.api.nvim_get_current_win(),
  })
  vim.cmd("leftabove vsplit")
  state.left = vim.api.nvim_get_current_win()
  vim.cmd("topleft vsplit")
  state.tree_win = vim.api.nvim_get_current_win()
  M.state = state
  store.load(state)

  tree.create(state)
  tree.refresh(state)
  vim.api.nvim_win_set_width(state.tree_win, tree.width)
  M.select(1)
  vim.cmd.wincmd("=") -- tree keeps its width: winfixwidth
  vim.api.nvim_buf_delete(placeholder, { force = true })
  vim.api.nvim_set_current_win(state.right)

  if state.pr then
    require("review.remote").fetch(state.pr, function(threads)
      if M.state ~= state then return end
      state.remote = threads
      for _, file in ipairs(state.files) do
        if file.bufs then comments.render(state, file) end
      end
    end)
  end

  -- Closing the tab any other way still wipes the buffers.
  vim.api.nvim_create_autocmd("TabClosed", {
    group = group,
    callback = function()
      if M.state and not vim.api.nvim_tabpage_is_valid(M.state.tab) then cleanup() end
    end,
  })
end

return M
