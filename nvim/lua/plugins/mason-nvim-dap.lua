---@type LazySpec
return {
  -- Ensure debuggers are installed
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "js-debug-adapter" })
    end,
  },
  -- Configure DAP for TypeScript/JavaScript
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "jay-babu/mason-nvim-dap.nvim",
        optional = true,
      },
    },
    opts = function()
      local dap = require "dap"

      -- Use Mason's standard install path for js-debug-adapter
      local mason_path = vim.fn.stdpath "data" .. "/mason/packages/js-debug-adapter"
      local adapter_path = mason_path .. "/js-debug/src/dapDebugServer.js"

      -- Check if the adapter file actually exists
      if vim.fn.filereadable(adapter_path) == 0 then
        vim.notify("js-debug-adapter not found at " .. adapter_path, vim.log.levels.WARN)
        vim.notify("Install it with :Mason or wait for mason-tool-installer to install it", vim.log.levels.INFO)
        -- Still set up configs even if adapter isn't ready yet
      else
        -- Set up the adapter only if it exists
        dap.adapters["pwa-node"] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "node",
            args = { adapter_path, "${port}" },
          },
        }
      end

      -- Configure for all JS/TS file types
      for _, language in ipairs { "typescript", "javascript", "typescriptreact", "javascriptreact" } do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "launch",
            name = "Debug Jest Tests",
            runtimeExecutable = "node",
            runtimeArgs = {
              "./node_modules/jest/bin/jest.js",
              "--runInBand",
            },
            rootPath = "${workspaceFolder}",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
          },
        }
      end
    end,
  },
}
