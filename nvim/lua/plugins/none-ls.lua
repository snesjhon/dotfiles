---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    local null_ls = require("null-ls")
    opts.sources = opts.sources or {}
    table.insert(
      opts.sources,
      null_ls.builtins.formatting.prettier.with({
        filetypes = { "mdx" },
        extra_filetypes = { "mdx" },
      })
    )
  end,
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
