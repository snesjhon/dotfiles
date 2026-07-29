# fzf-driven pickers for find-files/grep-words/open-in-vim; kept in their own file so ctrl-g can re-source just this via `become()`.
export FZF_PICKERS_FILE="$ZSH_CONFIG_DIR/functions/fzf-pickers.zsh"

# Bounded-preview script shared with vim/plugins/fzf.vim's :Rg and :Files.
export FZF_PREVIEW_SCRIPT="${ZSH_CONFIG_DIR:h}/scripts/fzf-preview.sh"

# Diff-preview script for gd()'s changed-files list.
export GIT_STATUS_PREVIEW_SCRIPT="${ZSH_CONFIG_DIR:h}/scripts/git-status-preview.sh"

# Diff-preview script for gp()'s PR-files list.
export GIT_PR_PREVIEW_SCRIPT="${ZSH_CONFIG_DIR:h}/scripts/git-pr-preview.sh"

# Base-branch resolution + changed-files listing for gp(), shared with vim's :PrFiles so both pickers treat "the PR" identically.
export GIT_PR_BASE_SCRIPT="${ZSH_CONFIG_DIR:h}/scripts/git-pr-base.sh"
export GIT_PR_FILES_SCRIPT="${ZSH_CONFIG_DIR:h}/scripts/git-pr-files.sh"

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

# Fuzzy directory jump -- named picker for what fzf's native Alt-C used to do, kept as a typed command to match ff/fw/fr.
fcd() {
  local dir
  local base_cmd='fd --type d --strip-cwd-prefix --exclude .git --exclude node_modules --exclude build'
  local -a nav_binds
  nav_binds=("${(0)$(_fzf_modal_nav_binds)}")
  nav_binds=("${nav_binds[@]:#}")
  dir=$(FZF_DEFAULT_COMMAND="$base_cmd" FZF_DEFAULT_OPTS="$(_fzf_theme_opts)" fzf --tmux 90%,70% \
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

# Recently opened files (written by vim/plugins/mru.vim) -- terminal counterpart to startify's "Recently Used".
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
  files=(${(f)"$(FZF_DEFAULT_OPTS="$(_fzf_theme_opts)" fzf --tmux 90%,70% -m --prompt 'Recent> ' \
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

# Flat list of working-tree changes -- terminal counterpart to vim-fugitive's :G status/lazygit's Files panel; status codes are hand-colored so the real path can ride hidden in a tab-delimited field instead of being re-derived from colored text.
gd() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -z "$root" ]]; then
    print -u2 "Not a git repository"
    return 1
  fi

  # NB: don't name any of these `path`/`fpath`/etc. -- shadowing zsh's special $PATH-tied parameters breaks command lookup for the rest of this function.
  local raw code rel_path new_path old_path name_part dir_part disp_path
  local idx_ch wt_ch idx_disp wt_disp colored_code display
  local -a fzf_lines
  while IFS= read -r raw; do
    code="${raw[1,2]}"
    rel_path="${raw[4,-1]}"
    # Filename leads and the directory trails dimmed, since fzf's ellipsis truncates off the end of the line and the directory matters least.
    if [[ "$rel_path" == *' -> '* ]]; then
      old_path="${rel_path% -> *}"
      new_path="${rel_path#* -> }"
      if [[ "${old_path:t}" == "${new_path:t}" ]]; then
        name_part="${new_path:t}"
      else
        name_part="${old_path:t} -> ${new_path:t}"
      fi
      if [[ "${old_path:h}" == "${new_path:h}" ]]; then
        dir_part="${new_path:h}"
      else
        dir_part="${old_path:h} -> ${new_path:h}"
      fi
    else
      new_path="$rel_path"
      name_part="${rel_path:t}"
      dir_part="${rel_path:h}"
    fi
    if [[ "$dir_part" == '.' ]]; then
      disp_path="$name_part"
    else
      disp_path="${name_part}  "$'\e[2m'"${dir_part}/"$'\e[0m'
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
    display="${colored_code} ${disp_path}"
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
  sels=(${(f)"$(printf '%s\n' "${fzf_lines[@]}" | FZF_DEFAULT_OPTS="$(_fzf_theme_opts)" fzf --ansi -m --tmux 90%,70% \
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

# Flat list of files changed by the current branch's PR -- unlike gd() (working-tree changes), mirrors a PR's own Files-changed tab; base resolution is shared with vim's :PrFiles.
gp() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -z "$root" ]]; then
    print -u2 "Not a git repository"
    return 1
  fi

  local diff_base
  diff_base=$("$GIT_PR_BASE_SCRIPT" "${1:-}" "$root" 2>&1) || { print -u2 "gp: $diff_base"; return 1 }

  local -a fzf_lines
  fzf_lines=(${(f)"$("$GIT_PR_FILES_SCRIPT" "$diff_base" "$root")"})

  if (( $#fzf_lines == 0 )); then
    print "No changes vs ${diff_base}"
    return 0
  fi

  local -a nav_binds
  nav_binds=("${(0)$(_fzf_modal_nav_binds)}")
  nav_binds=("${nav_binds[@]:#}")
  local -a sels
  sels=(${(f)"$(printf '%s\n' "${fzf_lines[@]}" | FZF_DEFAULT_OPTS="$(_fzf_theme_opts)" fzf --ansi -m --tmux 90%,70% \
    --prompt "PR (${diff_base})> " \
    --border-label ' PR Changes ' --border-label-pos 2 \
    --delimiter $'\t' --with-nth 1 \
    --preview "$GIT_PR_PREVIEW_SCRIPT {2} '$diff_base' '$root'" \
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
