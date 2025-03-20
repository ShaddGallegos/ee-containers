#!/bin/bash
# Enhanced monitoring script for podman with auto-popup terminal and title screen

# Kill any existing session
tmux kill-session -t podman-monitor 2>/dev/null || true

# Create the basic session
tmux new-session -d -s podman-monitor

# Configure the session with proper formatting
tmux set -g status-style bg=black,fg=white
tmux set -g default-terminal "screen-256color"
tmux set -g terminal-overrides ",xterm-256color:Tc"

# Set larger history limit for better scrollback
tmux set -g history-limit 10000

# Split into 2 panes
tmux split-window -v -p 30

# Put commands in each pane
tmux select-pane -t 0

# Clear screen and display tmux_header.txt as main title
tmux send-keys "clear" C-m

# Display the header file directly in the main pane
if [ -f "tmux_header.txt" ]; then
  # Display the header with proper coloring
  tmux send-keys "cat tmux_header.txt" C-m
else
  # Fallback if header file isn't found
  tmux send-keys "printf '\e[1;36m%s\e[0m\n' '=== BUILD OUTPUT ==='" C-m
  tmux send-keys "echo 'Waiting for builds to start...'" C-m
fi

# Configure second pane
tmux select-pane -t 1
tmux send-keys "printf '\e[1;32m%s\e[0m\n' '=== IMAGES ==='" C-m
tmux send-keys "watch -n .5 'podman images'" C-m

# Return to main pane
tmux select-pane -t 0

# Auto-open terminal with tmux session attached
function open_terminal_with_tmux {
  # If we're already in tmux, create a new window
  if [ -n "$TMUX" ]; then
    tmux new-window "tmux attach -t podman-monitor"
    return 0
  fi
  
  # Try different terminal emulators
  for terminal in gnome-terminal konsole xfce4-terminal terminator mate-terminal x-terminal-emulator xterm; do
    if command -v $terminal >/dev/null 2>&1; then
      case $terminal in
        gnome-terminal)
          nohup $terminal --geometry=120x40 -- tmux attach -t podman-monitor >/dev/null 2>&1 &
          ;;
        konsole|xfce4-terminal|terminator|mate-terminal|x-terminal-emulator)
          nohup $terminal --geometry=120x40 -e "tmux attach -t podman-monitor" >/dev/null 2>&1 &
          ;;
        xterm)
          nohup $terminal -geometry 120x40 -e "tmux attach -t podman-monitor" >/dev/null 2>&1 &
          ;;
      esac
      echo "Opened monitoring in $terminal"
      return 0
    fi
  done
  
  # WSL-specific handling
  if (grep -q Microsoft /proc/version 2>/dev/null); then
    nohup cmd.exe /c start wt.exe -w 0 new-tab --title "Podman Monitor" bash -c "tmux attach -t podman-monitor" >/dev/null 2>&1 &
    if [ $? -eq 0 ]; then
      echo "Opened monitoring in Windows Terminal"
      return 0
    fi
  fi
  
  return 1
}

# Try to open terminal with tmux
if ! open_terminal_with_tmux; then
  echo "Could not automatically open a terminal. Connect with: tmux attach -t podman-monitor"
fi
