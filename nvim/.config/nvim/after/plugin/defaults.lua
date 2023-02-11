-- Tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.keymap.set('n', '<leader>ef', require("nvim-tree").focus, { desc = "[E]xplorer [F]ocus" })
vim.keymap.set('n', '<leader>ee', require("nvim-tree").toggle, { desc = "[E]xplorer Toggle" })

-- Terminal Colors
vim.opt.termguicolors = true
vim.cmd [[colorscheme github_light]]

-- keymaps
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
