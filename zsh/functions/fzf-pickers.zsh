# fzf-driven pickers for find-files/grep-words/open-in-vim; kept in their own file so ctrl-g can re-source just this via `become()`.
export FZF_PICKERS_FILE="$ZSH_CONFIG_DIR/functions/fzf-pickers.zsh"

# Bounded-preview script shared with vim/plugins/fzf.vim's :Rg and :Files.
export FZF_PREVIEW_SCRIPT="${ZSH_CONFIG_DIR:h}/scripts/fzf-preview.sh"

# Base-branch resolution shared with vim's :PrDiff, hunk.zsh, and lazygit/config.yml, so they all treat "the PR" identically.
export GIT_PR_BASE_SCRIPT="${ZSH_CONFIG_DIR:h}/scripts/git-pr-base.sh"

# ctrl-g's become() sources only this file in a fresh non-interactive zsh, so pull in plugins/theme.zsh ourselves (a no-op if zshrc already sourced it).
if ! typeset -f _fzf_theme_opts >/dev/null; then
  source "$ZSH_CONFIG_DIR/plugins/theme.zsh"
fi

# Reuses an existing vim pane in the tmux window instead of nesting vim in :terminal; multi-file selections open a fresh vim instead.
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

# Vim-like modal navigation (mirrors vim/plugins/fzf.vim's FzfModalNavBinds); NUL-delimited so callers can rebuild an exact array despite embedded spaces.
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

# Fuzzy filename picker -- terminal counterpart to vim's <leader>ff (:Files); ctrl-g swaps to fw (content grep) via `become`.
ff() {
  local files
  local -a nav_binds
  nav_binds=("${(0)$(_fzf_modal_nav_binds)}")
  nav_binds=("${nav_binds[@]:#}")
  files=(${(f)"$(FZF_DEFAULT_OPTS="$(_fzf_theme_opts)" fzf --tmux 90%,70% -m \
    --prompt '> ' \
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

# Ctrl+F in any non-vim pane (tmux/mappings.conf's is_vim + fzf-insert-picker.sh): runs in a
# tmux popup since the pane's foreground process (shell, claude, whatever) isn't one we can run
# fzf in directly, then types the pick back into that pane as a relative path -- no Enter, so
# it doesn't auto-submit whatever input the pane's app is showing.
_fzf_insert_picker() {
  local pane="$1"
  local file
  local -a nav_binds
  nav_binds=("${(0)$(_fzf_modal_nav_binds)}")
  nav_binds=("${nav_binds[@]:#}")
  file=$(FZF_DEFAULT_OPTS="$(_fzf_theme_opts)" fzf \
    --prompt '> ' \
    --border-label ' Insert File ' --border-label-pos 2 \
    --preview "$FZF_PREVIEW_SCRIPT {}" \
    --preview-window 'right,50%' \
    --preview-label ' Preview ' \
    --bind 'focus:transform-preview-label:echo [ {} ]' \
    --bind "alt-.:transform:[[ \$FZF_PROMPT != *hidden* ]] && echo \"reload(rg --files --hidden --no-ignore)+change-prompt(hidden> )\" || echo \"reload(\$FZF_DEFAULT_COMMAND)+change-prompt(Insert> )\"" \
    "${nav_binds[@]}")
  [[ -n "$file" && -n "$pane" ]] || return
  tmux send-keys -t "$pane" -l -- "${file} "
}

# Live content grep -- terminal counterpart to vim's <leader>fw (:Rg); ctrl-f toggles between rg-reload mode and a local fuzzy filter, stashing each mode's query so switching back restores it.
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
  local rg_query_file=$(mktemp -u)
  local filter_query_file=$(mktemp -u)
  local selection
  local -a nav_binds
  nav_binds=("${(0)$(_fzf_modal_nav_binds)}")
  nav_binds=("${nav_binds[@]:#}")
  selection=$(FZF_DEFAULT_COMMAND="$initial" FZF_DEFAULT_OPTS="$(_fzf_theme_opts)" fzf --ansi --disabled --prompt 'Rg> ' \
    --query "$query" \
    --delimiter : \
    --tmux 90%,70% \
    --border-label ' Rg ' --border-label-pos 2 \
    --bind "change:reload:$(printf "$cmd" '{q}')" \
    --bind "alt-.:transform:[[ \$FZF_PROMPT != *hidden* ]] && echo \"change-prompt(Rg [hidden]> )+reload($(printf "$hidden_cmd" '{q}'))\" || echo \"change-prompt(Rg> )+reload($(printf "$cmd" '{q}'))\"" \
    --bind "ctrl-g:become(zsh -c 'source \"\$FZF_PICKERS_FILE\"; ff')" \
    --bind "ctrl-f:transform:if [[ \$FZF_PROMPT == *filter* ]]; then echo \"execute-silent(echo -n \\{q} > $filter_query_file)+change-prompt(Rg> )+disable-search+rebind(change)+transform-query(cat $rg_query_file 2>/dev/null)\"; else echo \"execute-silent(echo -n \\{q} > $rg_query_file)+change-prompt(Rg [filter]> )+enable-search+unbind(change)+transform-query(cat $filter_query_file 2>/dev/null)\"; fi" \
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
