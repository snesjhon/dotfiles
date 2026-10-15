local M = {}

local function run(args)
  local result = vim.system(vim.list_extend({ "gh" }, args), { text = true }):wait()
  if result.code ~= 0 then return nil, vim.trim(result.stderr) end
  return vim.json.decode(result.stdout)
end

-- Adds `repo` ("owner/repo", taken from the PR URL) so callers know which
-- remote to fetch from and where to submit.
function M.pr(number)
  local pr, err = run({ "pr", "view", number, "--json", "number,title,url,headRefOid,baseRefOid,baseRefName" })
  if not pr then return nil, err end
  pr.repo = pr.url:match("^https?://[^/]+/([^/]+/[^/]+)/pull/")
  return pr
end

return M
