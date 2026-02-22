return {
  {
    "kawre/leetcode.nvim",
    ---@type lc.UserConfig
    opts = {
      lang = "typescript",
      storage = {
        home = vim.fn.expand("$HOME") .. "/Developer/snesjhon/ysk/leetcode",
      },
    },
  },
  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["<Leader>mc"] = { "<Cmd>Leet console<CR>" },
          ["<Leader>md"] = { "<Cmd>Leet desc<CR>" },
          ["<Leader>mr"] = { "<Cmd>Leet run<CR>" },
          ["<Leader>ms"] = { "<Cmd>Leet submit<CR>" },
        },
      },
    },
  },
}
