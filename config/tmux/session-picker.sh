#!/bin/zsh

# This script provides an interactive way to switch between tmux sessions using fzf.

# 1. List all running tmux sessions. If none exist, print a message and exit.
# The `tmux ls` command will have a non-zero exit code if the server isn't running,
# which is perfect for this check.
if ! tmux ls >/dev/null 2>&1; then
  echo "No tmux sessions found."
  return 1
fi

# 2. Get the list of sessions and pipe it to fzf for interactive selection.
# - `fzf --height 40% --reverse`: launches fzf in a compact, bottom-up layout.
# - `awk -F':' '{print $1}'`: processes the selected line from fzf. It splits the
#   string by the colon ':' and prints the first part (the session name).
selected_session=$(tmux ls | fzf --height 40% --reverse | awk -F':' '{print $1}')

# 3. If the user cancelled fzf (e.g., by pressing Esc), the variable will be empty.
# In that case, we should just exit gracefully.
if [[ -z $selected_session ]]; then
  return 0
fi

# 4. Check if the script is being run from *inside* an existing tmux session.
# The `$TMUX` environment variable is only set when inside tmux.
if [[ -n "$TMUX" ]]; then
  # If inside tmux, we use `switch-client` to smoothly switch to the target session.
  tmux switch-client -t "$selected_session"
else
  # If not in tmux, we use `attach-session` to connect to the selected session.
  tmux attach-session -t "$selected_session"
fi
