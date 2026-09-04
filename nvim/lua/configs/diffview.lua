local actions = require("diffview.actions")

require("diffview").setup({
  use_icons = false,
  keymaps = {
    view = {
      { "n", "<C-S-q>", actions.close, { desc = "Close Diffview" } },
    },
    file_panel = {
      { "n", "e", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
      { "n", "<C-S-q>", actions.close, { desc = "Close Diffview" } },
    }
  }
})

local resolve_base = require("configs.git_pr_base")

local function show(opts)
  opts = opts or {}
  local base = resolve_base(opts.args)
  if not base then return end
  vim.cmd.DiffviewOpen(base .. "...HEAD")
end

vim.api.nvim_create_user_command("PrDiff", show, { nargs = "?", desc = "Show diff against the PR base" })

vim.keymap.set("n", "<C-S-m>", "<cmd>PrDiff<CR>", { desc = "Diff against PR base" })
vim.keymap.set("n", "<leader>gd", show, { desc = "Diff against PR base" })

return { show = show }
