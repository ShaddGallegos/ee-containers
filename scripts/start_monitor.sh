#!/bin/bash
# Simple monitoring script for podman with auto-popup terminal

# Kill any existing session
tmux kill-session -t podman-monitor 2>/dev/null || true

# Create the basic session
tmux new-session -d -s podman-monitor

# Configure the session
tmux set -g status-style bg=black,fg=white

# Split into 3 panes
tmux split-window -v -p 30
tmux split-window -h

# Put commands in each pane
tmux select-pane -t 0
tmux send-keys "echo '=== BUILD OUTPUT ===' && echo 'Waiting for builds to start...'" C-m

tmux select-pane -t 1
tmux send-keys "echo '=== CONTAINERS ===' && watch -n 2 'podman ps'" C-m

tmux select-pane -t 2
tmux send-keys "echo '=== IMAGES ===' && watch -n 5 'podman image ls'" C-m

# Return to main pane
tmux select-pane -t 0

# Auto-open terminal with tmux session attached
function open_terminal_with_tmux {
  # If we're already in tmux, create a new window
  if [ -n "$TMUX" ]; then
    tmux new-window "tmux attach -t podman-monitor"
    return 0
  fi
  
  # Try different terminal emulators in order of preference
  for terminal in gnome-terminal konsole xfce4-terminal terminator mate-terminal x-terminal-emulator xterm; do
    if command -v $terminal >/dev/null 2>&1; then
      case $terminal in
        gnome-terminal)
          nohup $terminal -- tmux attach -t podman-monitor >/dev/null 2>&1 &
          ;;
        konsole|xfce4-terminal|terminator|mate-terminal|x-terminal-emulator|xterm)
          nohup $terminal -e "tmux attach -t podman-monitor" >/dev/null 2>&1 &
          ;;
      esac
      echo "Opened monitoring in $terminal"
      return 0
    fi
  done
  
  # WSL-specific handling for Windows Terminal
  if (grep -q Microsoft /proc/version 2>/dev/null); then
    nohup cmd.exe /c start wt.exe bash -c "tmux attach -t podman-monitor" >/dev/null 2>&1 &
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
