return {
  {
    "kawre/leetcode.nvim",
    opts = {
      lang = "typescript",
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
