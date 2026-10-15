local M = {}

local function run(args)
  local result = vim.system(vim.list_extend({ "gh" }, args), { text = true }):wait()
  if result.code ~= 0 then return nil, vim.trim(result.stderr) end
  return vim.json.decode(result.stdout)
end

-- Adds `host` and `repo` ("owner/repo"), taken from the PR URL, so callers
-- know which remote to fetch from and where to submit.
function M.pr(number)
  local pr, err = run({ "pr", "view", number, "--json", "number,title,url,headRefOid,baseRefOid,baseRefName" })
  if not pr then return nil, err end
  pr.host, pr.repo = pr.url:match("^https?://([^/]+)/([^/]+/[^/]+)/pull/")
  return pr
end

-- Returns the created review, or nil and GitHub's error.
function M.submit(pr, review)
  local path = ("repos/%s/pulls/%d/reviews"):format(pr.repo, pr.number)
  -- --hostname: gh api otherwise talks to github.com, even inside an enterprise repo.
  local args = { "gh", "api", "--hostname", pr.host, "--method", "POST", path, "--input", "-" }
  local result = vim.system(args, { text = true, stdin = vim.json.encode(review) }):wait()
  if result.code == 0 then return vim.json.decode(result.stdout) end

  -- gh prints the API's JSON error on stdout; its `errors` say which comment failed.
  local err = vim.trim(result.stderr)
  local ok, data = pcall(vim.json.decode, result.stdout)
  if ok and type(data) == "table" and data.errors then
    local details = vim.tbl_map(function(e) return type(e) == "table" and (e.message or vim.inspect(e)) or tostring(e) end, data.errors)
    err = err .. ": " .. table.concat(details, "; ")
  end
  return nil, err
end

return M
