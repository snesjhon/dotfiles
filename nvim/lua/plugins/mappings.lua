return {
  {
    "AstroNvim/astrocore",
    --- @type AstroCoreOpts
    opts = {
      mappings = {
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
          ["<Leader>w"] = { function() require("astrocore.buffer").close() end, desc = "Close buffer" },
          -- SPLITS
          ["<Leader>\\"] = {
            "<Cmd>vsplit<CR>",
          },
          ["<Leader>|"] = {
            "<Cmd>split<CR>",
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
          -- YAZI
          ["<F6>"] = { function() require("yazi").yazi() end, desc = "Open Yazi" },
          -- ["<F6>"] = { "<Cmd>Yazi toggle<CR>", desc = "Toggle Yazi" },
          -- TERMINAL
          ["<F7>"] = {
            function() require("snacks").terminal() end,
            desc = "Toggle Terminal",
          },
          -- CLAUDE CODE
          ["<F8>"] = {
            function()
              require("snacks").terminal.toggle("claude", {
                win = {
                  position = "float",
                  backdrop = 80,
                  height = 0.9,
                  width = 0.8,
                  border = "hpad",
                },
              })
            end,
            desc = "Toggle Claude Code",
          },
          -- FUN!
          ["<Leader>z"] = { "<Cmd>NoNeckPain<CR>" },
          ["<F9>"] = { function() vim.lsp.buf.format(require("astrolsp").format_opts) end, desc = "Format buffer" },
          ["<F10>"] = { "<Cmd>w<CR>" },
          ["<F12>"] = { "gcc", desc = "Toggle comment line", remap = true },
        },
        t = {
          -- Send Shift+Enter as newline to terminal apps (e.g. Claude Code)
          ["<S-CR>"] = { "\x1b[13;2u", desc = "Shift+Enter (newline)" },
          -- CLAUDE CODE - Hide when in terminal mode
          ["<F8>"] = {
            function() require("snacks").terminal.toggle "claude" end,
            desc = "Hide Claude Code",
          },
          ["<F6>"] = { function() require("yazi").toggle() end, desc = "Open Yazi" },
        },
      },
    },
  },
}
