# fzf picker for YouTrack issues -- terminal counterpart to `gh issue list`. Requires YOUTRACK_URL/YOUTRACK_TOKEN; optional YOUTRACK_GH_HOST/REPO enable ctrl-o (open PR) and ctrl-p (checkout PR), both looked up on demand so the list never waits on GitHub.
export YOUTRACK_PREVIEW_SCRIPT="${ZSH_CONFIG_DIR:h}/scripts/youtrack-preview.sh"
export YOUTRACK_OPEN_PR_SCRIPT="${ZSH_CONFIG_DIR:h}/scripts/youtrack-open-pr.sh"
export YOUTRACK_CHECKOUT_PR_SCRIPT="${ZSH_CONFIG_DIR:h}/scripts/youtrack-checkout-pr.sh"

# Trial: standalone variant of _fzf_modal_nav_binds that adds lazygit-style pane focus (l/h move focus, j/k then scroll the preview); promote to the shared helper if it sticks.
_yt_nav_binds() {
  local flag=$(mktemp -u)
  local pflag=$(mktemp -u)
  local -a binds=(
    --bind "j:transform:[ -f $pflag ] && echo preview-down || echo down"
    --bind "k:transform:[ -f $pflag ] && echo preview-up || echo up"
    --bind 'q:abort'
    --bind "l:execute-silent(touch $pflag)+change-header(-- PREVIEW --)"
    --bind "h:execute-silent(rm -f $pflag)+change-header(-- NORMAL --)"
    --bind "i:unbind(j,k,q,i,h,l)+execute-silent(rm -f $pflag)+change-header()"
    --bind "start:unbind(j,k,q,i,h,l)+execute-silent(rm -f $flag $pflag)"
    --bind "esc:transform:[ -f $flag ] && echo abort || echo \"execute-silent(touch $flag)+rebind(j,k,q,i,h,l)+change-header(-- NORMAL --)\""
  )
  printf '%s\0' "${binds[@]}"
}

yt() {
  if [[ -z "$YOUTRACK_URL" || -z "$YOUTRACK_TOKEN" ]]; then
    print -u2 "yt: set YOUTRACK_URL and YOUTRACK_TOKEN (see zshrc.local)"
    return 1
  fi

  # Default query covers issues assigned to me or where I'm primary dev; built via plain assignment since zsh's brace-matching mishandles the literal {Primary Dev} default.
  local query="$*"
  [[ -z "$query" ]] && query="Assignee: me or {Primary Dev}: me #Unresolved sort by: updated desc"
  # Fetches everything the preview could need up front so the preview is a local decode, not a per-focus-change API call.
  local issues_json
  issues_json=$(curl -sG "$YOUTRACK_URL/api/issues" \
    -H "Authorization: Bearer $YOUTRACK_TOKEN" \
    -H 'Accept: application/json' \
    --data-urlencode "query=$query" \
    --data-urlencode 'fields=idReadable,summary,description,reporter(fullName),customFields(name,value(name))' \
    --data-urlencode '$top=100')

  # No gh call here -- PRs are looked up lazily on ctrl-o. Column 6 is a base64'd JSON blob (built from data already in hand) carrying everything the preview renders, so it never re-hits the API.
  local tsv
  tsv=$(jq -n -r --arg base "$YOUTRACK_URL" --argjson issues "$issues_json" '
    def field(n): (.customFields[]? | select(.name == n) | .value.name // "-");
    $issues[] | . as $issue |
    {
      id: $issue.idReadable, summary: $issue.summary,
      state: field("State"), priority: field("Priority"), type: field("Type"),
      assignee: field("Assignee"), primaryDev: field("Primary Dev"),
      reporter: ($issue.reporter.fullName // "-"),
      description: ($issue.description // "_No description_")
    } as $detail |
    [
      $issue.idReadable,
      $detail.state,
      $detail.assignee,
      $issue.summary,
      ($base + "/issue/" + $issue.idReadable),
      ($detail | tojson | @base64)
    ] | @tsv
  ')
  [[ -n "$tsv" ]] || { print "No issues found"; return 0 }

  # Columns 1-4 get column -t alignment as one fzf field; columns 5-6 (issue url, detail blob) ride along hidden, same trick as gd()'s hidden path field.
  local display hidden rows
  display=$(print -r -- "$tsv" | cut -f1-4 | column -t -s $'\t')
  hidden=$(print -r -- "$tsv" | cut -f5-6)
  rows=$(paste -d $'\t' <(print -r -- "$display") <(print -r -- "$hidden"))

  local -a nav_binds
  nav_binds=("${(0)$(_yt_nav_binds)}")
  nav_binds=("${nav_binds[@]:#}")

  # ctrl-p's checkout writes its outcome to a temp file (read after fzf exits) rather than a change-header, since it always ends in `abort` and a closed picker can't display a header.
  local checkout_status
  checkout_status=$(mktemp)

  # ctrl-o/ctrl-p run as fzf transforms so they stay inside the picker: ctrl-o reports via change-header, ctrl-p resolves to `abort` once the checkout finishes.
  local sel
  sel=$(print -r -- "$rows" | fzf --tmux 90%,70% \
    --prompt 'Issues> ' \
    --border-label ' YouTrack ' --border-label-pos 2 \
    --delimiter $'\t' --with-nth 1 \
    --preview "$YOUTRACK_PREVIEW_SCRIPT {3}" \
    --preview-window 'right,50%' \
    --preview-label ' Details (ctrl-o: open PR, ctrl-p: checkout PR) ' \
    --bind "ctrl-o:transform:$YOUTRACK_OPEN_PR_SCRIPT {1}" \
    --bind "ctrl-p:change-header(-- checking out PR... --)+transform:$YOUTRACK_CHECKOUT_PR_SCRIPT {1} $checkout_status" \
    "${nav_binds[@]}")

  if [[ -s "$checkout_status" ]]; then
    print -r -- "$(<$checkout_status)"
  fi
  rm -f "$checkout_status"

  [[ -n "$sel" ]] || return

  open "$(cut -f2 <<< "$sel")"
}
