#!/usr/bin/env bash
# Bounded preview (byte-size + line-depth) for the content-grep pickers, since bat's highlight cost scales with matched line number, not file size.
set -u

FILE=${1:-}
CENTER=${2:-}
[[ "$CENTER" =~ ^[0-9]+$ ]] || CENTER=

if [[ -z "$FILE" || ! -r "$FILE" ]]; then
  echo "File not found: $FILE"
  exit 1
fi

# Callers scroll to min(matched line, pad+1) per item -- keep their 151 in sync with this pad value.
pad=150
if [[ -n "$CENTER" ]]; then
  start=$(( CENTER > pad ? CENTER - pad : 1 ))
  end=$(( CENTER + pad ))
else
  start=1
  end=$(( pad * 2 ))
fi

bat_opts=(--color=always --style=numbers --pager=never --line-range "${start}:${end}")
[[ -n "$CENTER" ]] && bat_opts+=(--highlight-line "$CENTER")

if (( $(wc -c < "$FILE") > 307200 )) || (( ${CENTER:-0} > 2000 )); then
  bat_opts+=(--language=txt)
fi

exec bat "${bat_opts[@]}" -- "$FILE"
