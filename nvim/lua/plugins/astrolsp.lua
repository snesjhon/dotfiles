---@type LazySpec
return {
  "AstroNvim/astrolsp",
  opts = {
    config = {
      sorbet = {
        cmd = { "rbenv", "exec", "bundle", "exec", "srb", "tc", "--lsp" },
        root_dir = require("lspconfig.util").root_pattern("sorbet/config"),
        filetypes = { "ruby" },
      },
      ruby_lsp = {
        cmd = { "rbenv", "exec", "bundle", "exec", "ruby-lsp" },
        root_dir = require("lspconfig.util").root_pattern("Gemfile", ".git"),
        filetypes = { "ruby" },
        init_options = {
          formatter = "auto",
        },
      },
      vtsls = {
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
          "mdx",
        },
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
      },
      basedpyright = {
        settings = {
          basedpyright = {
            analysis = {
              diagnosticSeverityOverrides = {
                reportUnusedImport = "none",
                reportWildcardImportFromLibrary = "none",
              },
            },
          },
        },
      },
    },
  },
}
