#!/usr/bin/env bash
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // empty')
display_model=$(echo "$input" | jq -r '.model.display_name? // .model.id? // (.model | strings) // empty')

parts=()

if [ -n "$display_model" ]; then
  parts+=("$(printf '\033[01;35m%s\033[00m' "$display_model")")
fi

if [ -n "$CLD_HOST_DIR" ]; then
  parts+=("$(printf '\033[01;32m(cld) %s\033[00m' "$CLD_HOST_DIR")")
elif [ -n "$cwd" ]; then
  parts+=("$(printf '\033[01;32m%s\033[00m' "$cwd")")
fi

if [ -n "$used" ]; then
  parts+=("$(printf '\033[01;34mContext: %.0f%% used\033[00m' "$used")")
fi

printf '%s' "$(IFS=' | '; echo "${parts[*]}")"
