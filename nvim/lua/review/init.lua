local git = require("review.git")
local tree = require("review.tree")
local diff = require("review.diff")
local comments = require("review.comments")

local M = {}

-- One review at a time: buffer names are fixed per path.
M.state = nil

local group = vim.api.nvim_create_augroup("review", { clear = true })

local function load_pr(number)
  local pr, err = require("review.gh").pr(number)
  if not pr then return nil, err end

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
    key = tostring(pr.number),
    pr = { number = pr.number, title = pr.title, host = pr.host, repo = pr.repo },
    base = base,
    head = pr.headRefOid,
  }
end

local function load_branch(override)
  local ref = require("configs.git_pr_base")(override)
  if not ref then return nil end
  local head = git.rev_parse("HEAD")
  local base, err = git.merge_base(ref, head)
  if not base then return nil, err end
  local branch = vim.trim(git.run({ "symbolic-ref", "--short", "-q", "HEAD" }) or "")
  if branch == "" then branch = head:sub(1, 12) end
  return { key = "branch-" .. branch:gsub("[^%w._-]", "_"), title = ref .. "...HEAD", base = base, head = head }
end

local function cleanup()
  if not M.state then return end
  for _, buf in ipairs(M.state.bufs) do
    if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
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

function M.map_common(buf)
  local function map(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc }) end
  map("q", M.close, "Close review")
  map("]f", function() M.select(M.state.current + 1) end, "Next file")
  map("[f", function() M.select(M.state.current - 1) end, "Previous file")
  map("L", function() comments.list(M.state) end, "List comments")
  map("S", function() require("review.submit")(M.state) end, "Submit review")
end

-- arg: a PR number, a base ref, or empty for the branch's PR base.
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
    review, err = load_pr(arg)
  else
    review, err = load_branch(arg ~= "" and arg or nil)
  end
  if not review then
    if err then vim.notify(err, vim.log.levels.ERROR) end
    return
  end

  local files, files_err = git.changed_files(review.base, review.head)
  if not files then return vim.notify(files_err, vim.log.levels.ERROR) end
  if #files == 0 then return vim.notify("No changes to review") end
  tree.sort(files)

  vim.cmd.tabnew()
  local placeholder = vim.api.nvim_get_current_buf()
  local state = vim.tbl_extend("force", review, {
    arg = arg,
    files = files,
    bufs = {},
    buf_info = {},
    store = comments.store_path(review.key),
    tab = vim.api.nvim_get_current_tabpage(),
    right = vim.api.nvim_get_current_win(),
  })
  vim.cmd("leftabove vsplit")
  state.left = vim.api.nvim_get_current_win()
  vim.cmd("topleft vsplit")
  state.tree_win = vim.api.nvim_get_current_win()
  M.state = state
  comments.load(state)

  tree.create(state)
  tree.update_counts(state)
  vim.api.nvim_win_set_width(state.tree_win, tree.width)
  M.select(1)
  vim.cmd.wincmd("=") -- tree keeps its width: winfixwidth
  vim.api.nvim_buf_delete(placeholder, { force = true })
  vim.api.nvim_set_current_win(state.right)

  -- Closing the tab any other way still wipes the buffers.
  vim.api.nvim_create_autocmd("TabClosed", {
    group = group,
    callback = function()
      if M.state and not vim.api.nvim_tabpage_is_valid(M.state.tab) then cleanup() end
    end,
  })
end

return M
