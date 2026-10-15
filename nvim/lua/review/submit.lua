local gh = require("review.gh")
local ui = require("review.ui")

local events = {
  { label = "Comment", value = "COMMENT" },
  { label = "Approve", value = "APPROVE" },
  { label = "Request changes", value = "REQUEST_CHANGES" },
}

local function send(state, event, body)
  local review = { commit_id = state.head, event = event.value, body = body ~= "" and body or nil, comments = {} }
  for _, c in ipairs(state.comments) do
    table.insert(review.comments, {
      path = c.path,
      side = c.side,
      line = c.line,
      start_line = c.start_line,
      start_side = c.start_line and c.side or nil,
      body = c.body,
    })
  end

  vim.notify("Submitting review...")
  vim.cmd.redraw()
  local result, err = gh.submit(state.pr, review)
  if not result then return vim.notify("Review not submitted. " .. err, vim.log.levels.ERROR) end

  state.comments = {}
  require("review.comments").save(state)
  for _, file in ipairs(state.files) do
    if file.bufs then require("review.comments").render(state, file) end
  end
  require("review.tree").update_counts(state)
  vim.notify("Review submitted: " .. result.html_url)
end

return function(state)
  if not state.pr then
    return vim.notify("A branch review has no PR to submit to, so its comments stay as your own notes")
  end

  -- Comments are tied to the commit you reviewed. GitHub accepts that, and
  -- marks them outdated if a newer commit changed those lines.
  local pr = gh.pr(state.pr.number)
  if pr and pr.headRefOid ~= state.head then
    local answer = vim.fn.confirm(
      "The PR has new commits since you opened it. Submit against the commit you reviewed?",
      "&Yes\n&No",
      2
    )
    if answer ~= 1 then return end
  end

  vim.ui.select(events, {
    prompt = ("Submit review with %d comments"):format(#state.comments),
    format_item = function(event) return event.label end,
  }, function(event)
    if not event then return end
    ui.edit("Summary: " .. event.label, "", function(body)
      if body == "" and (event.value == "REQUEST_CHANGES" or (event.value == "COMMENT" and #state.comments == 0)) then
        return vim.notify(event.label .. " needs a summary", vim.log.levels.ERROR)
      end
      send(state, event, body)
    end)
  end)
end
