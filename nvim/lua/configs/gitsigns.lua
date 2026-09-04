require("gitsigns").setup({
  on_attach = function(bufnr)
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

    map("n", "<leader>hp", gitsigns.preview_hunk, "Preview hunk")
    map("n", "<leader>hi", gitsigns.preview_hunk_inline, "Preview hunk inline")
    map("n", "<leader>hb", function() gitsigns.blame_line({ full = true }) end, "Blame line")
    map("n", "<leader>hd", gitsigns.diffthis, "Diff this")
    map("n", "<leader>hD", function() gitsigns.diffthis("~") end, "Diff this (against last commit)")
    map("n", "<leader>hq", gitsigns.setqflist, "Hunks to quickfix")
    map("n", "<leader>hQ", function() gitsigns.setqflist("all") end, "All hunks to quickfix")
    map("n", "<leader>tb", gitsigns.toggle_current_line_blame, "Toggle line blame")
    map("n", "<leader>tw", gitsigns.toggle_word_diff, "Toggle word diff")
    map({ "o", "x" }, "ih", gitsigns.select_hunk, "Select hunk")
  end,
})

local pr_base_active = false
vim.keymap.set("n", "<leader>tp", function()
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
