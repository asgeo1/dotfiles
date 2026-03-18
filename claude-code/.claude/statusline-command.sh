#!/bin/bash
# Claude Code status line - inspired by metro fish theme
# Shows: dir | git branch (with dirty/staged indicators) | model | context %

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd')
model=$(echo "$input" | jq -r '.model.display_name')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Directory: show basename only (metro style)
dir=$(basename "$cwd")
if [ "$cwd" = "$HOME" ]; then
  dir="~"
fi

# Git info (use -C to avoid cd; skip optional locks)
git_info=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" describe --tags --exact-match HEAD 2>/dev/null \
    || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

  git_status=$(git -C "$cwd" status --porcelain 2>/dev/null)
  indicator=""
  if echo "$git_status" | grep -q "^[MADRC]"; then
    # staged changes
    if echo "$git_status" | grep -q "^.[MD]"; then
      indicator=" ±"  # staged + dirty
    else
      indicator=" +"  # staged only
    fi
  elif [ -n "$git_status" ]; then
    indicator=" ✗"  # dirty/untracked only
  fi

  if [ -n "$branch" ]; then
    git_info=" \033[1;34mgit:(\033[0;31m${branch}\033[1;34m)\033[0;33m${indicator}\033[0m"
  fi
fi

# Context usage
ctx_info=""
if [ -n "$used_pct" ]; then
  ctx_int=${used_pct%.*}
  ctx_info=" \033[0;35mctx:${ctx_int}%\033[0m"
fi

# Model (short display)
model_info=" \033[0;36m${model}\033[0m"

printf "\033[0;37m${dir}\033[0m${git_info}${model_info}${ctx_info}"
