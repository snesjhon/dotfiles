# fzf-driven pickers for find-files / grep-words / open-in-vim; kept in their
# own file so ctrl-g can re-source just this via `become()`.
export FZF_PICKERS_FILE="$ZSH_CONFIG_DIR/functions/fzf-pickers.zsh"

# Bounded-preview script shared with vim/plugins/fzf.vim's :Rg and :Files.
export FZF_PREVIEW_SCRIPT="${ZSH_CONFIG_DIR:h}/scripts/fzf-preview.sh"

# Diff-preview script for gd()'s changed-files list.
export GIT_STATUS_PREVIEW_SCRIPT="${ZSH_CONFIG_DIR:h}/scripts/git-status-preview.sh"

# Reuses an existing vim pane in the tmux window instead of nesting vim in
# :terminal; multi-file selections open a fresh vim instead.
_open_in_vim() {
  local file="$1" line="$2"
  if [[ -n "$TMUX" ]]; then
    local pane id tty
    while IFS=' ' read -r id tty; do
      if ps -o state= -o comm= -t "$tty" 2>/dev/null | grep -qiE '^[^TXZ ]+ +(\S+/)?g?(view|n?vim?x?)(diff)?$'; then
        pane="$id"
        break
      fi
    done < <(tmux list-panes -F '#{pane_id} #{pane_tty}' 2>/dev/null)
    if [[ -n "$pane" ]]; then
      local escaped="${file//\\/\\\\}"
      escaped="${escaped// /\\ }"
      escaped="${escaped//\%/\\%}"
      escaped="${escaped//\#/\\#}"
      local keys=":e ${escaped}"
      [[ -n "$line" ]] && keys="${keys} | ${line}"
      tmux send-keys -t "$pane" Escape
      tmux send-keys -t "$pane" "$keys" Enter
      tmux select-pane -t "$pane"
      return
    fi
  fi
  if [[ -n "$line" ]]; then
    vim "+${line}" -- "$file"
  else
    vim -- "$file"
  fi
}

# Vim-like modal navigation, mirrors vim/plugins/fzf.vim's FzfModalNavBinds exactly.
# NUL-delimited output so callers can rebuild an exact array via ${(0)$(...)} despite embedded spaces.
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

# Fuzzy filename picker -- terminal counterpart to vim's <leader>ff (:Files).
# ctrl-g swaps to fw (content grep) inside the same session via `become`.
ff() {
  local files
  local -a nav_binds
  nav_binds=("${(0)$(_fzf_modal_nav_binds)}")
  nav_binds=("${nav_binds[@]:#}")
  files=(${(f)"$(fzf --tmux 90%,70% -m \
    --prompt 'Files> ' \
    --border-label ' Files ' --border-label-pos 2 \
    --preview "$FZF_PREVIEW_SCRIPT {}" \
    --preview-window 'right,50%' \
    --preview-label ' Preview ' \
    --bind 'focus:transform-preview-label:echo [ {} ]' \
    --bind "alt-.:transform:[[ \$FZF_PROMPT != *hidden* ]] && echo \"reload(rg --files --hidden --no-ignore)+change-prompt(hidden> )\" || echo \"reload(\$FZF_DEFAULT_COMMAND)+change-prompt(Files> )\"" \
    --bind "ctrl-g:become(zsh -c 'source \"\$FZF_PICKERS_FILE\"; fw')" \
    "${nav_binds[@]}" \
  )"})
  (( $#files )) || return
  if (( $#files == 1 )); then
    _open_in_vim "$files[1]"
  else
    vim -- "${files[@]}"
  fi
}

# Live content grep -- terminal counterpart to vim's <leader>fw (:Rg); mirrors
# vim/plugins/fzf.vim's s:LiveGrep exactly.
fw() {
  local cmd='rg --column --line-number --no-heading --color=always -- %s || true'
  local hidden_cmd='rg --column --line-number --no-heading --color=always --hidden --no-ignore -- %s || true'
  local query="$*"
  local initial
  if [[ -z "$query" ]]; then
    initial='true'
  else
    initial=$(printf "$cmd" "$(printf '%q' "$query")")
  fi
  local selection
  local -a nav_binds
  nav_binds=("${(0)$(_fzf_modal_nav_binds)}")
  nav_binds=("${nav_binds[@]:#}")
  selection=$(FZF_DEFAULT_COMMAND="$initial" fzf --ansi --disabled --prompt 'Rg> ' \
    --query "$query" \
    --delimiter : \
    --tmux 90%,70% \
    --border-label ' Rg ' --border-label-pos 2 \
    --bind "change:reload:$(printf "$cmd" '{q}')" \
    --bind "alt-.:transform:[[ \$FZF_PROMPT != *hidden* ]] && echo \"change-prompt(Rg [hidden]> )+reload($(printf "$hidden_cmd" '{q}'))\" || echo \"change-prompt(Rg> )+reload($(printf "$cmd" '{q}'))\"" \
    --bind "ctrl-g:become(zsh -c 'source \"\$FZF_PICKERS_FILE\"; ff')" \
    --bind 'focus:transform-preview-label(echo [ {1} ])+transform(LINE={2}; ROW=$(( LINE < 151 ? LINE : 151 )); echo "change-preview-window(+$ROW-/2,right,50%)")' \
    --preview "$FZF_PREVIEW_SCRIPT {1} {2}" \
    --preview-window 'right,50%' \
    --preview-label ' Preview ' \
    "${nav_binds[@]}")
  [[ -n "$selection" ]] || return
  local file="${selection%%:*}"
  local rest="${selection#*:}"
  local line="${rest%%:*}"
  _open_in_vim "$file" "$line"
}

# Fuzzy directory jump -- named picker for what fzf's native Alt-C used to do,
# kept as a typed command instead of a raw keystroke to match ff/fw/fr.
fcd() {
  local dir
  local base_cmd='fd --type d --strip-cwd-prefix --exclude .git --exclude node_modules --exclude build'
  local -a nav_binds
  nav_binds=("${(0)$(_fzf_modal_nav_binds)}")
  nav_binds=("${nav_binds[@]:#}")
  dir=$(FZF_DEFAULT_COMMAND="$base_cmd" fzf --tmux 90%,70% \
    --prompt 'Dirs> ' \
    --border-label ' Dirs ' --border-label-pos 2 \
    --preview 'ls -la --color=always {} 2>/dev/null || ls -la {}' \
    --preview-window 'right,50%' \
    --preview-label ' Preview ' \
    --bind 'focus:transform-preview-label:echo [ {} ]' \
    --bind "alt-.:transform:[[ \$FZF_PROMPT != *hidden* ]] && echo \"reload(fd --type d --hidden --no-ignore --strip-cwd-prefix)+change-prompt(hidden> )\" || echo \"reload($base_cmd)+change-prompt(Dirs> )\"" \
    "${nav_binds[@]}")
  [[ -n "$dir" ]] || return
  cd -- "$dir"
}

# Recently opened files (written by vim/plugins/mru.vim) -- terminal
# counterpart to startify's "Recently Used".
fr() {
  local mru="$HOME/.cache/vim/mru"
  if [[ ! -s "$mru" ]]; then
    print -u2 "No recent files yet"
    return 1
  fi
  local files
  local -a nav_binds
  nav_binds=("${(0)$(_fzf_modal_nav_binds)}")
  nav_binds=("${nav_binds[@]:#}")
  files=(${(f)"$(fzf --tmux 90%,70% -m --prompt 'Recent> ' \
    --border-label ' Recent ' --border-label-pos 2 \
    --preview "$FZF_PREVIEW_SCRIPT {}" \
    --preview-window 'right,50%' \
    --preview-label ' Preview ' \
    --bind 'focus:transform-preview-label:echo [ {} ]' \
    "${nav_binds[@]}" \
    < "$mru")"})
  (( $#files )) || return
  if (( $#files == 1 )); then
    _open_in_vim "$files[1]"
  else
    vim -- "${files[@]}"
  fi
}

# Flat list of working-tree changes (staged/unstaged/untracked) -- terminal
# counterpart to vim-fugitive's :G status and lazygit's Files panel. Status
# codes are colored by hand (rather than `git status`'s own --color) so the
# real path can ride along as a hidden tab-delimited field (hidden via
# --with-nth) instead of being re-derived from the colored text fzf hands
# back -- a stray lookup miss there previously fed vim a bare directory,
# which is what dropped it into netrw instead of opening the file.
gd() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -z "$root" ]]; then
    print -u2 "Not a git repository"
    return 1
  fi

  # NB: don't name any of these `path`/`fpath`/etc. -- those are zsh's special
  # tied-to-$PATH parameters and shadowing them locally breaks command lookup
  # (fzf, git, vim) for the rest of this function.
  local raw code rel_path new_path idx_ch wt_ch idx_disp wt_disp colored_code display
  local -a fzf_lines
  while IFS= read -r raw; do
    code="${raw[1,2]}"
    rel_path="${raw[4,-1]}"
    if [[ "$rel_path" == *' -> '* ]]; then
      new_path="${rel_path#* -> }"
    else
      new_path="$rel_path"
    fi
    if [[ "$code" == '??' ]]; then
      colored_code=$'\e[33m??\e[0m'
    else
      idx_ch="${code[1]}"
      wt_ch="${code[2]}"
      [[ "$idx_ch" == ' ' ]] && idx_disp=' ' || idx_disp=$'\e[32m'"$idx_ch"$'\e[0m'
      [[ "$wt_ch" == ' ' ]] && wt_disp=' ' || wt_disp=$'\e[31m'"$wt_ch"$'\e[0m'
      colored_code="${idx_disp}${wt_disp}"
    fi
    display="${colored_code} ${rel_path}"
    fzf_lines+=("${display}"$'\t'"${new_path}")
  done < <(git -C "$root" status --porcelain=v1 --untracked-files=all)

  if (( $#fzf_lines == 0 )); then
    print "Clean working tree"
    return 0
  fi

  local -a nav_binds
  nav_binds=("${(0)$(_fzf_modal_nav_binds)}")
  nav_binds=("${nav_binds[@]:#}")
  local -a sels
  sels=(${(f)"$(printf '%s\n' "${fzf_lines[@]}" | fzf --ansi -m --tmux 90%,70% \
    --prompt 'Changes> ' \
    --border-label ' Changes ' --border-label-pos 2 \
    --delimiter $'\t' --with-nth 1 \
    --preview "$GIT_STATUS_PREVIEW_SCRIPT {2} '$root'" \
    --preview-window 'right,50%' \
    --preview-label ' Diff ' \
    "${nav_binds[@]}")"})
  (( $#sels )) || return

  local -a files
  local s
  for s in "${sels[@]}"; do
    files+=("${root}/${s##*$'\t'}")
  done
  if (( $#files == 1 )); then
    _open_in_vim "$files[1]"
  else
    vim -- "${files[@]}"
  fi
}
