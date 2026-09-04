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
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99 -- start with everything unfolded
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

-- Quickfix ------------------------------------------------------------------
-- Neovim sets 'buflisted' on the quickfix buffer by default (e.g. after `grr`
-- populates and opens it), which makes bufferline treat it as a real buffer
-- and give it its own tab. It's not a file to keep open -- unlist it.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function() vim.bo.buflisted = false end,
})
