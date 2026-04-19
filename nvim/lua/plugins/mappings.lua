return {
  {
    "AstroNvim/astrocore",
    --- @type AstroCoreOpts
    opts = {
      mappings = {
        v = {
          ["<leader>ac"] = {
            function() require("sidekick.cli").send { name = "claude", msg = "File: {file}\n\n{selection}" } end,
            desc = "Send selection to Claude",
          },
          ["<leader>gi"] = {
            function()
              require("snacks").gitbrowse {
                notify = false,
                open = function(url) vim.fn.setreg("+", url) end,
              }
            end,
            desc = "Git Browse (copy)",
          },
          ["<S-h>"] = { "^", desc = "Beginning of line" },
          ["<S-l>"] = { "$", desc = "End of line" },
          ["<F12>"] = { "gc", desc = "Toggle comment", remap = true },
        },
        n = {
          -- WINDOWS
          ["<C-h>"] = { function() require("smart-splits").move_cursor_left() end, desc = "Move to left window/pane" },
          ["<C-l>"] = { function() require("smart-splits").move_cursor_right() end, desc = "Move to right window/pane" },
          ["<LocalLeader>l"] = { function() require("smart-splits").resize_left(30) end, desc = "Resize split left" },
          ["<LocalLeader>;"] = { function() require("smart-splits").resize_right(30) end, desc = "Resize split right" },
          -- BUFFERS
          ["<S-j>"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Next buffer" },
          ["<S-k>"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Previous buffer" },
          ["<C-M-w>"] = { function() require("astrocore.buffer").close() end, desc = "Close buffer" },
          -- SPLITS
          ["<Leader>\\"] = {
            function() vim.cmd "vsplit" end,
          },
          ["<Leader>|"] = {
            function() vim.cmd "split" end,
          },
          -- VIM
          ["vv"] = { "<S-v>", desc = "Visual Select" },
          ["<S-h>"] = { "^", desc = "Beginning of line" },
          ["<S-l>"] = { "$", desc = "End of line" },
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
                  vim.cmd.vsplit()
                  vim.lsp.util.show_document(result[1], "utf-8", {
                    focus = true,
                  })
                else
                  -- Multiple definitions or fallback: use picker
                  require("snacks").picker.lsp_definitions()
                end
              end)
            end,
            desc = "LSP definitions in horizontal split",
          },
          -- GIT
          ["gf"] = {
            function() vim.lsp.buf.format(require("astrolsp").format_opts) end,
            desc = "Format buffer",
          },
          ["gh"] = { function() vim.lsp.buf.hover() end, desc = "Hover Info" },
          ["<Leader>gj"] = { "<Cmd>DiffviewOpen origin/main...HEAD<CR>", desc = "DiffviewOpen" },
          ["<Leader>gq"] = { "<Cmd>DiffviewClose<CR>", desc = "DiffviewClose" },
          ["<Leader>gh"] = { "<Cmd>DiffviewFileHistory<CR>", desc = "DiffviewHistory" },
          -- LINE
          ["<leader>gi"] = {
            ":<C-u>let @+ = expand('%') <CR>",
            desc = "Copy file path",
          },
          -- TERMINAL
          ["<F4>"] = {
            function()
              local opts = {
                win = {
                  position = "float",
                  border = "single",
                  backdrop = false,
                  height = 0.99,
                  width = 0.5,
                  row = 2,
                  col = 0.6,
                  zindex = 9,
                },
              }
              local term
              for _, t in pairs(require("snacks").terminal.list()) do
                if t.cmd == nil then
                  term = t
                  break
                end
              end
              if term and term:win_valid() then
                if vim.api.nvim_get_current_win() == term.win then
                  term:hide()
                else
                  term:focus()
                end
              else
                require("snacks").terminal.toggle(nil, opts)
              end
            end,
            desc = "Toggle Terminal",
          },
          -- CLAUDE CODE
          ["<F8>"] = {
            function() require("sidekick.cli").toggle { name = "claude", focus = true } end,
            desc = "Toggle Claude Code",
          },
          ["<F9>"] = { function() vim.lsp.buf.format(require("astrolsp").format_opts) end, desc = "Format buffer" },
          ["<F10>"] = { "<Cmd>w<CR>" },
          ["<F12>"] = { "gcc", desc = "Toggle comment line", remap = true },
          -- FUN!
          ["<Leader>z"] = { "<Cmd>NoNeckPain<CR>" },
        },
        t = {
          -- Send Shift+Enter as newline to terminal apps (e.g. Claude Code)
          ["<S-CR>"] = { "\x1b[13;2u", desc = "Shift+Enter (newline)" },
          -- CLAUDE CODE - Hide when in terminal mode
          ["<F4>"] = {
            function()
              require("snacks").terminal.toggle(nil, {
                win = {
                  position = "float",
                  border = "single",
                  backdrop = false,
                  height = 0.99,
                  width = 0.5,
                  row = 2,
                  col = 0.6,
                  zindex = 9,
                },
              })
            end,
            desc = "Toggle Terminal",
          },
          ["<F8>"] = {
            function() require("sidekick.cli").toggle { name = "claude" } end,
            desc = "Hide Claude Code",
          },
        },
      },
    },
  },
}
