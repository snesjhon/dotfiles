# lazygit with the GitLab theme matching macOS's light/dark appearance, checked
# on every run so an open shell follows an appearance change.
gg() {
  local dir=${ZSH_CONFIG_DIR:h}/lazygit
  LG_CONFIG_FILE="$dir/gitlab-$(_resolve_theme).yml" command lazygit "$@"
}
