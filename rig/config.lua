-- Sessions and settings for rig (~/Developer/rig.nvim), read through
-- ~/.config/rig. See rig's lua/rig/config.lua for the fields.
return {
  sessions = {
    dev = {
      path = "~/Developer",
      default = true,
      tabs = {
        { "dots", path = "~/Developer/dotfiles" },
        { "me", path = "~/Developer/me" },
      },
    },
  },
  -- The board opens code reviews in review.nvim (~/Developer/review.nvim).
  review = {
    open = function(opts)
      local review = require("review")
      -- An open review only reads saved comments when it opens.
      if opts.reload and review.state then review.close() end
      review.open(opts.pr and tostring(opts.pr) or "", {
        cwd = opts.dir,
        on_submit = function(state) opts.on_submit(state.head) end,
      })
    end,
    add_comments = function(opts) require("review.store").add(opts.dir, opts.pr, opts.head, opts.comments) end,
  },
}
