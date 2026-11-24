-- Plugins (native vim.pack, no plugin manager) ------------------------------
-- Plugins I'm developing in their own repos under ~/Developer. rig's board
-- opens plans and reviews in this nvim through rig.open.
vim.opt.rtp:prepend(vim.fs.normalize("~/Developer/trackit.nvim"))
vim.opt.rtp:prepend(vim.fs.normalize("~/Developer/rig.nvim"))
vim.opt.rtp:prepend(vim.fs.normalize("~/Developer/review.nvim"))

vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/folke/snacks.nvim",
  "https://github.com/snesjhon/gitlab-nvim-theme",
  "https://github.com/akinsho/bufferline.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/shortcuts/no-neck-pain.nvim",
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  "https://github.com/folke/flash.nvim",
  "https://github.com/snesjhon/mux.nvim", -- terminal sessions; rig builds on it
  { src = "https://github.com/Saghen/blink.cmp", version = vim.version.range("1") },
})

-- Load every *.lua file in lua/configs/ as a plugin config module, so
-- adding a new file there is enough -- no manual require to remember.
local this_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
local configs_dir = this_dir .. "/configs"
local names = {}
for name, kind in vim.fs.dir(configs_dir) do
  if kind == "file" and name ~= "init.lua" and name:match("%.lua$") then
    table.insert(names, name)
  end
end
table.sort(names)
for _, name in ipairs(names) do
  require("configs." .. name:gsub("%.lua$", ""))
end
