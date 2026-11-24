-- Settings for rig (~/Developer/rig.nvim), read through ~/.config/rig.
-- Sessions are mux's (mux/config.lua). See rig's lua/rig/config.lua for the fields.
return {
  -- The board opens code reviews in review.nvim (~/Developer/review.nvim).
  review = {
    open = function(opts)
      require("review").open(opts.pr and tostring(opts.pr) or "", {
        cwd = opts.dir,
        on_submit = function(state) opts.on_submit(state.head) end,
      })
    end,
  },
}
