-- Without the script, review.nvim uses its own default PR base.
if vim.env.GIT_PR_BASE_SCRIPT then require("review").setup({ pr_base = require("configs.git_pr_base") }) end
