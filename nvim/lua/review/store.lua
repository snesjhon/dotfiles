-- Comments and viewed marks for one review, saved under the common git dir so
-- every worktree of the repo sees the same review.
local git = require("review.git")

local M = {}

function M.path(key)
  local dir = vim.trim(git.run({ "rev-parse", "--path-format=absolute", "--git-common-dir" }) or "")
  return vim.fs.joinpath(dir, "review", key .. ".json")
end

-- The file's blob at head, or "" for a deleted file. A viewed mark only holds
-- while this stays the same, like GitHub resetting "Viewed" on new changes.
function M.blob(state, file)
  if file.status == "D" then return "" end
  return vim.trim(git.run({ "rev-parse", "--verify", "--quiet", state.head .. ":" .. file.path }) or "")
end

function M.load(state)
  state.comments, state.viewed = {}, {}
  local f = io.open(state.store)
  if not f then return end
  local ok, data = pcall(vim.json.decode, f:read("*a"))
  f:close()
  if not ok then return vim.notify("Couldn't read " .. state.store, vim.log.levels.WARN) end

  state.comments = data.comments or {}
  if data.head ~= state.head and #state.comments > 0 then
    vim.notify(
      ("%d saved comments were written against an older commit, so their lines may have moved"):format(#state.comments),
      vim.log.levels.WARN
    )
  end

  local changed = 0
  for _, file in ipairs(state.files) do
    local blob = (data.viewed or {})[file.path]
    if blob then
      if blob == M.blob(state, file) then
        state.viewed[file.path] = blob
      else
        changed = changed + 1
      end
    end
  end
  if changed > 0 then vim.notify(("%d viewed files changed since you viewed them"):format(changed)) end
end

function M.save(state)
  if #state.comments == 0 and next(state.viewed) == nil then
    os.remove(state.store)
    return
  end
  vim.fn.mkdir(vim.fs.dirname(state.store), "p")
  local data = { head = state.head, comments = state.comments, viewed = vim.empty_dict() }
  for path, blob in pairs(state.viewed) do
    data.viewed[path] = blob
  end
  vim.fn.writefile({ vim.json.encode(data) }, state.store)
end

return M
