return {
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    specs = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          maps.n["<Leader>h"] = { '<Cmd>execute v:count . "ToggleTerm"<CR>', desc = "Toggle terminal" }
          maps.t["<Leader>h"] = { "<Cmd>ToggleTerm<CR>", desc = "Toggle terminal" }
          maps.i["<Leader>h"] = { "<Esc><Cmd>ToggleTerm<CR>", desc = "Toggle terminal" }
        end,
      },
    },
    opts = {
      direction = "float",
    },
  },
}
