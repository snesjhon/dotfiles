require("diffview").setup()

local resolve_base = require("configs.git_pr_base")

local function show(opts)
  opts = opts or {}
  local base = resolve_base(opts.args)
  if not base then return end
  vim.cmd.DiffviewOpen(base .. "...HEAD")
end

vim.api.nvim_create_user_command("PrDiff", show, { nargs = "?", desc = "Show diff against the PR base" })

return { show = show }
