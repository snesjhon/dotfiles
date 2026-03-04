---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    {
      "jay-babu/mason-null-ls.nvim",
      opts = {
        handlers = {
          rubocop = function()
            local null_ls = require("null-ls")
            null_ls.register(
              null_ls.builtins.diagnostics.rubocop.with({
                cwd = function(params)
                  local found = vim.fs.find(".rubocop.yml", {
                    upward = true,
                    path = vim.fs.dirname(params.bufname),
                  })
                  if found[1] then
                    return vim.fs.dirname(found[1])
                  end
                  return params.root
                end,
              })
            )
          end,
        },
      },
    },
  },
}
