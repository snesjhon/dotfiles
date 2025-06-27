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
