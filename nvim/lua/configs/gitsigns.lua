-- gitsigns -- in-buffer hunk signs, navigation, staging, and blame.
-- Keymaps only apply once gitsigns attaches to a buffer (i.e. it's tracked
-- by git), mirroring how LSP keymaps in mappings.lua only bind on LspAttach.
require("gitsigns").setup({
  on_attach = function(bufnr)
    local gitsigns = require("gitsigns")

    local function map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc }) end

    -- Navigation -- falls back to vim's native ]c/[c when in diff mode.
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

    -- Actions
    -- map("n", "<leader>hs", gitsigns.stage_hunk, "Stage hunk")
    -- map("n", "<leader>hr", gitsigns.reset_hunk, "Reset hunk")
    -- map("v", "<leader>hs", function() gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage hunk")
    -- map("v", "<leader>hr", function() gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset hunk")
    -- map("n", "<leader>hS", gitsigns.stage_buffer, "Stage buffer")
    -- map("n", "<leader>hR", gitsigns.reset_buffer, "Reset buffer")
    map("n", "<leader>hp", gitsigns.preview_hunk, "Preview hunk")
    map("n", "<leader>hi", gitsigns.preview_hunk_inline, "Preview hunk inline")
    map("n", "<leader>hb", function() gitsigns.blame_line({ full = true }) end, "Blame line")
    map("n", "<leader>hd", gitsigns.diffthis, "Diff this")
    map("n", "<leader>hD", function() gitsigns.diffthis("~") end, "Diff this (against last commit)")
    map("n", "<leader>hq", gitsigns.setqflist, "Hunks to quickfix")
    map("n", "<leader>hQ", function() gitsigns.setqflist("all") end, "All hunks to quickfix")

    -- Toggles
    map("n", "<leader>tb", gitsigns.toggle_current_line_blame, "Toggle line blame")
    map("n", "<leader>tw", gitsigns.toggle_word_diff, "Toggle word diff")

    -- Text object
    map({ "o", "x" }, "ih", gitsigns.select_hunk, "Select hunk")
  end,
})

-- PR base toggle -- points gitsigns' diff base at the same PR base diffview.lua
-- resolves (see configs/git_pr_base.lua), so the normal hunk signs/keymaps
-- above operate on the whole PR diff instead of just uncommitted changes.
-- Global, not buffer-local, since "reviewing this PR" is a whole-session mode.
local resolve_base = require("configs.git_pr_base")
local gitsigns = require("gitsigns")
local pr_base_active = false

vim.keymap.set("n", "<leader>tp", function()
  if pr_base_active then
    gitsigns.change_base(nil, true)
    pr_base_active = false
    vim.notify("Gitsigns base reset to index")
    return
  end

  local base = resolve_base()
  if not base then return end
  gitsigns.change_base(base, true)
  pr_base_active = true
  vim.notify("Gitsigns base set to " .. base)
end, { desc = "Toggle inline diff against PR base" })
