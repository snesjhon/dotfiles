-- Review comments already on the PR (from anyone), shown read-only.
local M = {}

-- Groups comments into threads. GitHub points every reply at the thread's
-- first comment, and gives outdated comments no current line, so those
-- threads (and their replies) are left out.
local function threads(comments)
  local list, by_id = {}, {}
  for _, c in ipairs(comments) do
    local thread = c.in_reply_to_id and by_id[c.in_reply_to_id]
    if thread then
      table.insert(thread.entries, c)
    elseif not c.in_reply_to_id and c.line then
      thread = { path = c.path, side = c.side, line = c.line, start_line = c.start_line, entries = { c } }
      by_id[c.id] = thread
      table.insert(list, thread)
    end
  end
  return list
end

-- Calls on_done with the PR's comment threads once they arrive, without blocking.
function M.fetch(pr, on_done)
  local path = ("repos/%s/pulls/%d/comments"):format(pr.repo, pr.number)
  local args = { "gh", "api", "--hostname", pr.host, "--paginate", "--slurp", path }
  vim.system(args, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        return vim.notify("Couldn't load PR comments: " .. vim.trim(result.stderr), vim.log.levels.WARN)
      end
      local comments = {}
      for _, page in ipairs(vim.json.decode(result.stdout, { luanil = { object = true } })) do
        vim.list_extend(comments, page)
      end
      on_done(threads(comments))
    end)
  end)
end

return M
