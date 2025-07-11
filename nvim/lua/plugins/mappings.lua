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
          ["<C-S-P>"] = { "<C-\\><C-n>", desc = "Exit terminal mode" },
          ["<S-CR>"] = { "\n", desc = "Terminal New Line" },
        },
        v = {
          ["<leader>ll"] = {
            ":<C-u>let @+ = expand('%') . ':' . line(\"'<\") . '-' . line(\"'>\") <CR>",
            desc = "Copy file path with line range",
          },
        },
        n = {
          -- Removing AstroDefaults
          ["<Leader>w"] = { function() require("astrocore.buffer").close() end, desc = "Close buffer" },
          ["<Leader>uZ"] = false,
          -- WINDOWS
          ["<C-A-S-k>"] = { function() require("smart-splits").resize_up() end, desc = "Resize split up" },
          ["<C-A-S-j>"] = { function() require("smart-splits").resize_down() end, desc = "Resize split down" },
          ["<C-A-S-h>"] = { function() require("smart-splits").resize_left() end, desc = "Resize split left" },
          ["<C-A-S-l>"] = { function() require("smart-splits").resize_right() end, desc = "Resize split right" },
          -- BUFFERS
          ["<S-j>"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Next buffer" },
          ["<S-k>"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Previous buffer" },
          -- TERMINAL
          ["<Leader>tc"] = { function() vim.cmd "tabnew | terminal claude" end, desc = "Open Claude in new tab" },
          ["<Leader>tt"] = { function() vim.cmd "tabnew | terminal" end, desc = "Open Terminal in new tab" },
          ["<Leader>tl"] = {
            function()
              local Terminal = require("toggleterm.terminal").Terminal
              local term = Terminal:new {
                direction = "vertical",
                size = 40,
                on_open = function()
                  vim.cmd "wincmd H"
                  vim.cmd "vertical resize 40"
                end,
              }
              term:toggle()
            end,
            desc = "Toggle Left vertical terminal",
          },
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
