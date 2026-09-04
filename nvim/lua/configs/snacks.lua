require("snacks").setup({
  styles = {
    float = { backdrop = false },
  },
  picker = {
    enabled = true,
    sources = {
      files = { cmd = "rg" },
    },
  },
  notifier = { enabled = true },
  dashboard = {
    enabled = true,
    preset = {
      header = [[
██╗   ██╗
██║   ██║
╚██╗ ██╔╝
 ╚████╔╝
  ╚═══╝]],
    },
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
      { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
    },
  },
})

-- Search (Snacks picker) --------------------------------------------------
vim.keymap.set("n", "<leader>f<CR>", function() require("snacks").picker.resume() end, { desc = "Resume last search" })
vim.keymap.set("n", "<leader>f'", function() require("snacks").picker.marks() end, { desc = "Find marks" })
vim.keymap.set("n", "<leader>fa", function() require("snacks").picker.files({ dirs = { vim.fn.stdpath("config") } }) end, { desc = "Find config files" })
vim.keymap.set("n", "<leader>fb", function() require("snacks").picker.buffers() end, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fc", function() require("snacks").picker.grep_word() end, { desc = "Find word under cursor" })
vim.keymap.set("n", "<leader>fC", function() require("snacks").picker.commands() end, { desc = "Find commands" })
vim.keymap.set("n", "<leader>ff", function() require("snacks").picker.files() end, { desc = "Find files" })
vim.keymap.set("n", "<leader>fF", function() require("snacks").picker.files({ hidden = true, ignored = true }) end, { desc = "Find all files" })
vim.keymap.set("n", "<leader>fg", function() require("snacks").picker.git_files() end, { desc = "Find git files" })
vim.keymap.set("n", "<leader>fh", function() require("snacks").picker.help() end, { desc = "Find help" })
vim.keymap.set("n", "<leader>fk", function() require("snacks").picker.keymaps() end, { desc = "Find keymaps" })
vim.keymap.set("n", "<leader>fl", function() require("snacks").picker.lines() end, { desc = "Find lines" })
vim.keymap.set("n", "<leader>fm", function() require("snacks").picker.man() end, { desc = "Find man pages" })
vim.keymap.set("n", "<leader>fn", function() require("snacks").picker.notifications() end, { desc = "Find notifications" })
vim.keymap.set("n", "<leader>fo", function() require("snacks").picker.recent() end, { desc = "Find old files" })
vim.keymap.set("n", "<leader>fO", function() require("snacks").picker.recent({ filter = { cwd = true } }) end, { desc = "Find old files (cwd)" })
vim.keymap.set("n", "<leader>fp", function() require("snacks").picker.projects() end, { desc = "Find projects" })
vim.keymap.set("n", "<leader>fr", function() require("snacks").picker.registers() end, { desc = "Find registers" })
vim.keymap.set("n", "<leader>fs", function() require("snacks").picker.smart() end, { desc = "Find buffers/recent/files" })
vim.keymap.set("n", "<leader>ft", function() require("snacks").picker.colorschemes() end, { desc = "Find themes" })
vim.keymap.set("n", "<leader>fu", function() require("snacks").picker.undo() end, { desc = "Find undo history" })
vim.keymap.set("n", "<leader>fw", function() require("snacks").picker.grep() end, { desc = "Find words" })
vim.keymap.set("n", "<leader>fW", function() require("snacks").picker.grep({ hidden = true, ignored = true }) end, { desc = "Find words in all files" })


-- Git (Snacks picker) -------------------------------------------------------
vim.keymap.set("n", "<leader>go", function() require("snacks").gitbrowse() end, { desc = "Git browse (open)" })
vim.keymap.set("n", "<leader>gb", function() require("snacks").picker.git_branches() end, { desc = "Git branches" })
vim.keymap.set("n", "<leader>gc", function() require("snacks").picker.git_log() end, { desc = "Git commits (repository)" })
vim.keymap.set("n", "<leader>gC", function() require("snacks").picker.git_log({ current_file = true, follow = true }) end, { desc = "Git commits (current file)" })
vim.keymap.set("n", "<leader>gs", function() require("snacks").picker.git_status() end, { desc = "Git status" })
vim.keymap.set("n", "<leader>gT", function() require("snacks").picker.git_stash() end, { desc = "Git stash" })

vim.keymap.set("n", "<leader>gg", function() require("snacks").lazygit() end, { desc = "LazyGit" })
vim.keymap.set("n", "<C-S-w>", function() require("snacks").bufdelete() end, { desc = "Close Buffer" })

-- vim.keymap.set("n", "<C-S-w>", function()
--   local buf = vim.api.nvim_get_current_buf()
--   local win = vim.api.nvim_get_current_win()
--   local was_last = #vim.tbl_filter(function(b)
--     return vim.bo[b].buflisted
--   end, vim.api.nvim_list_bufs()) == 1
--
--   require("snacks").bufdelete()
--
--   if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then return end
--
--   if was_last then
--     require("snacks").dashboard.open({ buf = vim.api.nvim_get_current_buf(), win = win })
--   end
-- end, { desc = "Close buffer" })
