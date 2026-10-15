-- Calls block: outputs here are small, and file contents are cached by sha so
-- revisiting a file never runs git again.
local M = {}

local contents = {}

function M.run(args)
  local result = vim.system(vim.list_extend({ "git" }, args), { text = true }):wait()
  if result.code ~= 0 then return nil, vim.trim(result.stderr) end
  return result.stdout
end

function M.rev_parse(ref)
  local out = M.run({ "rev-parse", "--verify", "--quiet", ref .. "^{commit}" })
  return out and vim.trim(out)
end

function M.merge_base(a, b)
  local out, err = M.run({ "merge-base", a, b })
  return out and vim.trim(out), err
end

-- The remote whose URL points at "owner/repo", so PR refs are fetched from the
-- repo the PR lives in even when origin is a fork.
function M.remote_for(repo)
  repo = repo:lower()
  for _, name in ipairs(vim.split(vim.trim(M.run({ "remote" }) or ""), "\n")) do
    local url = vim.trim(M.run({ "remote", "get-url", name }) or ""):lower():gsub("%.git$", "")
    local tail = url:sub(-(#repo + 1))
    if tail:sub(2) == repo and tail:sub(1, 1):match("[/:]") then return name end
  end
  return "origin"
end

function M.changed_files(base, head)
  local out, err = M.run({ "diff", "--name-status", "-z", "-M", base, head })
  if not out then return nil, err end
  local parts = vim.split(out, "\0", { plain = true })
  local files, i = {}, 1
  while parts[i] and parts[i] ~= "" do
    local status = parts[i]:sub(1, 1)
    if status == "R" or status == "C" then
      table.insert(files, { status = status, old_path = parts[i + 1], path = parts[i + 2] })
      i = i + 3
    else
      table.insert(files, { status = status, path = parts[i + 1] })
      i = i + 2
    end
  end
  return files
end

-- Returns the file's lines at a commit, or nil and the reason it can't be shown.
function M.show(sha, path)
  local key = sha .. ":" .. path
  if not contents[key] then
    local out, err = M.run({ "show", key })
    if not out then return nil, err end
    if out:find("\0", 1, true) then return nil, "Binary file" end
    contents[key] = vim.split((out:gsub("\n$", "")), "\n", { plain = true })
  end
  return contents[key]
end

return M
