-- local Terminal = require("toggleterm.terminal").Terminal
-- local lazygit = Terminal:new {
--   -- cmd = "Claude",
--   -- dir = "gi",
--   direction = "tab",
--   hidden = true,
--   count = 5,
--   -- float_opts = {
--   --   border = "double",
--   -- },
--   -- function to run on opening the terminal
--   on_open = function(term)
--     vim.cmd "startinsert!"
--     -- vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
--   end,
--   -- function to run on closing the terminal
--   on_close = function(term) vim.cmd "startinsert!" end,
-- }
--
-- function Lazygit_toggle() lazygit:toggle() end

return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        g = {
          -- Disable global keymaps that clash with normal mode maps
          ["<C-j>"] = false,
        },
        t = {
          ["<esc><esc>"] = { "<C-\\><C-n>", desc = "Exit terminal mode" },
        },
        n = {
          -- Removing AstroDefaults
          ["<Leader>w"] = { function() require("astrocore.buffer").close() end, desc = "Close buffer" },
          ["<Leader>uZ"] = false,
          -- WINDOWS
          ["<C-A-S-h>"] = { "<C-w>h", desc = "Move to left split" },
          ["<C-A-S-l>"] = { "<C-w>l", desc = "Move to right split" },
          ["<C-A-S-j>"] = { "<C-w>j", desc = "Move to below split" },
          ["<C-A-S-k>"] = { "<C-w>k", desc = "Move to above split" },
          ["<C-A-S-m>"] = { function() require("smart-splits").resize_up() end, desc = "Resize split up" },
          ["<C-A-S-,>"] = { function() require("smart-splits").resize_down() end, desc = "Resize split down" },
          ["<C-A-S-n>"] = { function() require("smart-splits").resize_left() end, desc = "Resize split left" },
          ["<C-A-S-.>"] = { function() require("smart-splits").resize_right() end, desc = "Resize split right" },
          -- BUFFERS
          ["<S-j>"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Next buffer" },
          ["<S-k>"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Previous buffer" },
          -- TERMINAL
          -- ["<Leader>tv"] = { "<Cmd>ToggleTerm size=100 direction=vertical<CR>", desc = "ToggleTerm vertical split" },
          -- ["<Leader>tc"] = { "<Cmd>TermExec cmd='Claude' direction=tab<CR>" },
          -- ["<Leader>tc"] = { "<Cmd>lua Lazygit_toggle()<CR>" },
          --   function()
          --     require("toggleterm.terminal").Terminal
          --       :new({
          --         cmd = "Claude",
          --         direction = "tab",
          --         hidden = true,
          --       })
          --       :toggle()
          --   end,
          --   desc = "ClaudeCode",
          -- },
          ["<Leader>tc"] = { function() vim.cmd "tabnew | terminal claude" end, desc = "Open Claude in new tab" },
          -- VIM
          ["vv"] = { "<S-v>", desc = "Visual Select" },
          -- GIT
          ["gf"] = { function() vim.lsp.buf.format(require("astrolsp").format_opts) end, desc = "Format buffer" },
          ["gh"] = { function() vim.lsp.buf.hover() end, desc = "Hover Info" },
          ["<Leader>gx"] = { "<Cmd>DiffviewOpen origin/main...HEAD<CR>", desc = "Diffview Open Files" },
          -- FUN!
          ["<Leader>s"] = { "<Cmd>w<CR>" },
          ["<Leader>zz"] = { function() require("snacks").toggle.zen():toggle() end, desc = "Toggle zen mode" },
          ["<Leader>e"] = { function() require("snacks").explorer() end, desc = "Toggle Explorer" },
        },
      },
    },
  },
}
