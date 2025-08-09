return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        t = {
          ["<C-\\>"] = { "<C-\\><C-n>", desc = "Exit terminal mode" },
          ["<S-CR>"] = { "\n", desc = "Terminal New Line" },
        },
        v = {
          ["<leader>gi"] = {
            function()
              require("snacks").gitbrowse {
                notify = false,
                open = function(url) vim.fn.setreg("+", url) end,
              }
            end,
            desc = "Git Browse (copy)",
          },
        },
        n = {
          -- WINDOWS
          ["<A-S-k>"] = { function() require("smart-splits").resize_up() end, desc = "Resize split up" },
          ["<A-S-j>"] = { function() require("smart-splits").resize_down() end, desc = "Resize split down" },
          ["<A-S-h>"] = { function() require("smart-splits").resize_left() end, desc = "Resize split left" },
          ["<A-S-l>"] = { function() require("smart-splits").resize_right() end, desc = "Resize split right" },
          -- BUFFERS
          ["<S-j>"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Next buffer" },
          ["<S-k>"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Previous buffer" },
          ["<Leader>w"] = { function() require("astrocore.buffer").close() end, desc = "Close buffer" },
          -- VIM
          ["vv"] = { "<S-v>", desc = "Visual Select" },
          -- GIT
          ["gf"] = { function() vim.lsp.buf.format(require("astrolsp").format_opts) end, desc = "Format buffer" },
          ["gh"] = { function() vim.lsp.buf.hover() end, desc = "Hover Info" },
          ["<Leader>gj"] = { "<Cmd>DiffviewOpen origin/main...HEAD<CR>", desc = "DiffviewOpen" },
          ["<Leader>gq"] = { "<Cmd>DiffviewClose<CR>", desc = "DiffviewClose" },
          ["<Leader>gh"] = { "<Cmd>DiffviewFileHistory<CR>", desc = "DiffviewHistory" },
          -- LINE
          ["<leader>gi"] = {
            ":<C-u>let @+ = expand('%') <CR>",
            desc = "Copy file path",
          },
          -- EXPLORER
          ["<Leader>j"] = {
            function()
              require("snacks").explorer {
                layout = {
                  preset = "vertical",
                },
                auto_close = true,
              }
            end,
            desc = "Toggle Explorer",
          },
          -- FUN!
          ["<Leader>k"] = { "<Cmd>NoNeckPain<CR>" },
          ["<Leader>s"] = { "<Cmd>w<CR>" },
        },
      },
    },
  },
}
