-- LSP-attach mappings live in lsp.lua since they're entirely buffer-local
-- on_attach logic with nothing global to split out.
local M = {}

vim.keymap.set("n", "<leader>go", function() require("snacks").gitbrowse() end, { desc = "Git browse (open)" })
vim.keymap.set("n", "<leader>gcb", function() require("snacks").picker.git_branches() end, { desc = "Git branches" })
vim.keymap.set("n", "<leader>gcc", function() require("snacks").picker.git_log() end, { desc = "Git commits (repository)" })
vim.keymap.set("n", "<leader>gcC", function() require("snacks").picker.git_log({ current_file = true, follow = true }) end, { desc = "Git commits (current file)" })
vim.keymap.set("n", "<leader>gs", function() require("snacks").picker.git_status() end, { desc = "Git status" })
vim.keymap.set("n", "<leader>gp", function() require("snacks").picker.git_diff() end, { desc = "Git diff" })

vim.api.nvim_create_user_command("LazyGit", function() require("snacks").lazygit() end, { desc = "Open yazi to pick a file" })
vim.keymap.set("n", "<leader>gg", function() require("snacks").lazygit() end, { desc = "LazyGit" })

local pr_base_active = false
vim.keymap.set("n", "<leader>gtp", function()
  local gitsigns = require("gitsigns")
  if pr_base_active then
    gitsigns.change_base(nil, true)
    pr_base_active = false
    vim.notify("Gitsigns base reset to index")
    return
  end

  local base = require("configs.git_pr_base")()
  if not base then return end
  gitsigns.change_base(base, true)
  pr_base_active = true
  vim.notify("Gitsigns base set to " .. base)
end, { desc = "Toggle inline diff against PR base" })

function M.pr_diff(opts)
  opts = opts or {}
  local base = require("configs.git_pr_base")(opts.args)
  if not base then return end
  vim.cmd.DiffviewOpen(base .. "...HEAD")
end

vim.api.nvim_create_user_command("PrDiff", M.pr_diff, { nargs = "?", desc = "Show diff against the PR base" })
vim.keymap.set("n", "<C-S-m>", "<cmd>PrDiff<CR>", { desc = "Diff against PR base" })
vim.keymap.set("n", "<leader>gd", M.pr_diff, { desc = "Diff against PR base" })

-- Passed to diffview.setup({ keymaps = ... }) by configs/diffview.lua.
M.diffview_keymaps = {
  view = {
    { "n", "<C-S-q>", function() require("diffview.actions").close() end, { desc = "Close Diffview" } },
  },
  file_panel = {
    { "n", "e", function() require("diffview.actions").goto_file_edit() end, { desc = "Open the file in the previous tabpage" } },
    { "n", "<C-S-q>", function() require("diffview.actions").close() end, { desc = "Close Diffview" } },
  },
}

-- Passed to gitsigns.setup({ on_attach = ... }) by configs/gitsigns.lua.
function M.on_attach(bufnr)
  local gitsigns = require("gitsigns")
  local function map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc }) end

  map("n", "]c", function()
    if vim.wo.diff then
      vim.cmd.normal({ "]c", bang = true })
    else
      gitsigns.nav_hunk("next")
    end
  end, "Next hunk")
  map("n", "[c", function()
    if vim.wo.diff then
      vim.cmd.normal({ "[c", bang = true })
    else
      gitsigns.nav_hunk("prev")
    end
  end, "Previous hunk")

  map("n", "<leader>ghp", gitsigns.preview_hunk, "Preview hunk")
  map("n", "<leader>ghi", gitsigns.preview_hunk_inline, "Preview hunk inline")
  map("n", "<leader>ghb", function() gitsigns.blame_line({ full = true }) end, "Blame line")
  map("n", "<leader>ghd", gitsigns.diffthis, "Diff this")
  map("n", "<leader>ghD", function() gitsigns.diffthis("~") end, "Diff this (against last commit)")
  map("n", "<leader>ghq", gitsigns.setqflist, "Hunks to quickfix")
  map("n", "<leader>ghQ", function() gitsigns.setqflist("all") end, "All hunks to quickfix")
  map("n", "<leader>gtb", gitsigns.toggle_current_line_blame, "Toggle line blame")
  map("n", "<leader>gtw", gitsigns.toggle_word_diff, "Toggle word diff")
  map({ "o", "x" }, "ih", gitsigns.select_hunk, "Select hunk")
end

return M
