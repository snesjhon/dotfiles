-- General -----------------------------------------------------------------
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.swapfile = false

vim.opt.title = true
vim.opt.titlestring = "v"

-- UI ------------------------------------------------------------------------
vim.opt.termguicolors = true
vim.opt.number = false
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.scrolloff = 999
vim.opt.wrap = false
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.fillchars = { eob = " " }
vim.opt.winborder = "rounded" -- border on all floats: hover, diagnostics, signature help, etc.
vim.opt.cmdheight = 0 -- no reserved command-line row; messages show as an overlay
vim.opt.laststatus = 0 -- no statusline; bufferline already covers filename/diagnostics

-- Completion ------------------------------------------------------------
vim.opt.completeopt = { "menu", "menuone", "noselect", "popup" }

-- Indentation -----------------------------------------------------------
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true

-- Search --------------------------------------------------------------------
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
