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
          ["<Leader>b\\"] = {
            function()
              require("astroui.status.heirline").buffer_picker(function(bufnr)
                vim.cmd.vsplit()
                vim.api.nvim_win_set_buf(0, bufnr)
              end)
            end,
            desc = "Switch",
          },
          ["<Leader>b|"] = {
            function()
              require("astroui.status.heirline").buffer_picker(function(bufnr)
                vim.cmd.split()
                vim.api.nvim_win_set_buf(0, bufnr)
              end)
            end,
            desc = "Switch2",
          },
          -- VIM
          ["vv"] = { "<S-v>", desc = "Visual Select" },
          -- PICKERS
          ["<Leader>fe"] = {
            function() require("snacks").picker.highlights() end,
            desc = "highlight",
          },
          ["grs"] = {
            function() require("snacks").picker.lsp_references() end,
            desc = "Search references",
          },
          ["g\\"] = {
            -- Open LSP definition as a split pane or show picker
            function()
              local params = vim.lsp.util.make_position_params(0, "utf-8")
              local clients = vim.lsp.get_clients { bufnr = 0 }
              if #clients == 0 then
                vim.notify("No LSP clients attached", vim.log.levels.WARN)
                return
              end

              -- Request definitions from LSP
              vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
                if err or not result or vim.tbl_isempty(result) then
                  vim.notify("No definition found", vim.log.levels.WARN)
                  return
                end

                -- Handle single vs multiple definitions
                if type(result) == "table" and #result == 1 then
                  -- Single definition: open in horizontal split
                  -- vim.cmd "split"
                  vim.cmd.vsplit()
                  vim.lsp.util.show_document(result[1], "utf-8", {
                    focus = true,
                  })
                  -- vim.lsp.util.jump_to_location(result[1], "utf-8")
                else
                  -- Multiple definitions or fallback: use picker
                  require("snacks").picker.lsp_definitions()
                end
              end)
            end,
            desc = "LSP definitions in horizontal split",
          },
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
