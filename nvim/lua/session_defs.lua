-- Session definitions for `nv` (zsh/functions/nv.zsh). Kept free of side
-- effects so `nv` can list the names without loading the whole config.
-- Every tab is a shell started in `path`.
return {
  dev = {
    path = "~/Developer",
    tabs = { "code", "agent", "server" },
  },
}
