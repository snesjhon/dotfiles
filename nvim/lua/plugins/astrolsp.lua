---@type LazySpec
return {
  "AstroNvim/astrolsp",
  opts = {
    config = {
      vtsls = {
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
      },
    },
  },
}
