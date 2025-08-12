#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract current working directory from JSON input
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

# Get git branch (fallback to current directory if cwd is not available)
if [ -n "$cwd" ] && [ -d "$cwd" ]; then
    cd "$cwd" 2>/dev/null
fi

# Get current git branch
git_branch=$(git branch --show-current 2>/dev/null)
if [ -z "$git_branch" ]; then
    git_branch="no git"
fi

# Get weather information using wttr.in (free weather API)
# Using a timeout to avoid hanging if the service is slow
weather=$(timeout 3s curl -s "wttr.in/?format=%t+%C" 2>/dev/null | head -1)

# If weather fetch fails or times out, use a fallback
if [ -z "$weather" ] || [ "$weather" = "Unknown location" ]; then
    weather="Weather unavailable"
fi

# Format and output the status line
printf "%s | git: %s" "$weather" "$git_branch"