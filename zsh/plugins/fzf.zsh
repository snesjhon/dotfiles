# ctrl-t lists files with the same ignore rules as nvim's file picker.
export FZF_DEFAULT_COMMAND="rg --files"
export FZF_CTRL_R_OPTS="--height 40% --border-label ' History ' --border-label-pos 2"

# Vim-like modal navigation for fzf; NUL-delimited so callers can rebuild an exact array despite embedded spaces.
_fzf_modal_nav_binds() {
  local flag=$(mktemp -u)
  local -a binds=(
    --bind 'j:down' --bind 'k:up' --bind 'q:abort'
    --bind 'i:unbind(j,k,q,i)+change-header()'
    --bind "start:unbind(j,k,q,i)+execute-silent(rm -f $flag)"
    --bind "esc:transform:[ -f $flag ] && echo abort || echo \"execute-silent(touch $flag)+rebind(j,k,q,i)+change-header(-- NORMAL --)\""
  )
  printf '%s\0' "${binds[@]}"
}
