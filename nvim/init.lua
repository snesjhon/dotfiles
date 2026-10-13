vim.loader.enable() -- cache compiled Lua modules; must run before any require
vim.g.mapleader = " "

require("options")
require("plugins")
require("mux")
require("mappings")
require("lsp")

