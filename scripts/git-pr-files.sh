#!/usr/bin/env bash
# Lists files changed vs the resolved PR base as fzf source lines for gp()/:PrFiles -- colored status + display path, with the real (post-rename) path hidden in field 2.
set -u

DIFF_BASE=${1:?}
ROOT=${2:-.}

cd "$ROOT" || exit 1

git diff --name-status "${DIFF_BASE}...HEAD" | while IFS=$'\t' read -r status_code path1 path2; do
  if [[ "$status_code" == R* || "$status_code" == C* ]]; then
    rel_path="$path2"
    name1=$(basename -- "$path1") name2=$(basename -- "$path2")
    dir1=$(dirname -- "$path1") dir2=$(dirname -- "$path2")
    [[ "$name1" == "$name2" ]] && name_part="$name2" || name_part="${name1} -> ${name2}"
    [[ "$dir1" == "$dir2" ]] && dir_part="$dir2" || dir_part="${dir1} -> ${dir2}"
  else
    rel_path="$path1"
    name_part=$(basename -- "$path1")
    dir_part=$(dirname -- "$path1")
  fi
  if [[ "$dir_part" == '.' ]]; then
    display_path="$name_part"
  else
    display_path="${name_part}  "$'\e[2m'"${dir_part}/"$'\e[0m'
  fi
  case "${status_code:0:1}" in
    A) colored_code=$'\e[32mA\e[0m' ;;
    D) colored_code=$'\e[31mD\e[0m' ;;
    M) colored_code=$'\e[33mM\e[0m' ;;
    R|C) colored_code=$'\e[36m'"${status_code:0:1}"$'\e[0m' ;;
    *) colored_code="${status_code:0:1}" ;;
  esac
  printf '%s %s\t%s\n' "$colored_code" "$display_path" "$rel_path"
done
