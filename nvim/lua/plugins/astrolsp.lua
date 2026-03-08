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
