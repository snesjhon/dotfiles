local set_keymap = vim.api.nvim_set_keymap
local opts = { noremap=true, silent=true}

set_keymap('n', '<leader>h', '0', opts)
set_keymap('n', '<leader>l', '$', opts)
set_keymap('n', '<leader>wl', '<C-w>l', opts)
set_keymap('n', '<leader>wh', '<C-w>h', opts)
set_keymap('n', '<D-Shift>e', ':NvimTreeFocus<cr>', opts)
