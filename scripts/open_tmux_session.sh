#!/bin/bash
# open_tmux_session.sh - Opens a terminal window with tmux session attached

# Function to try opening a terminal with tmux
open_terminal_with_tmux() {
  # If we're already in tmux, create a new window
  if [ -n "$TMUX" ]; then
    tmux new-window "tmux attach -t podman-monitor"
    return 0
  fi

  # Try different terminal emulators in order of preference
  for terminal in gnome-terminal konsole xfce4-terminal terminator mate-terminal xterm; do
    if command -v $terminal >/dev/null 2>&1; then
      case $terminal in
        gnome-terminal)
          nohup $terminal -- tmux attach -t podman-monitor >/dev/null 2>&1 &
          ;;
        *)
          nohup $terminal -e "tmux attach -t podman-monitor" >/dev/null 2>&1 &
          ;;
      esac
      echo "Opened tmux session in $terminal"
      return 0
    fi
  done
  
  # If none of the above worked, try X-terminal-emulator alternative
  if command -v x-terminal-emulator >/dev/null 2>&1; then
    nohup x-terminal-emulator -e "tmux attach -t podman-monitor" >/dev/null 2>&1 &
    echo "Opened tmux session in x-terminal-emulator"
    return 0
  fi
  
  return 1
}

# Main script execution
main() {
  # Verify tmux session exists
  if ! tmux has-session -t podman-monitor 2>/dev/null; then
    echo "Error: podman-monitor tmux session doesn't exist."
    exit 1
  fi

  # Try to open terminal with tmux
  if ! open_terminal_with_tmux; then
    echo "Could not open a terminal window automatically."
    echo "To view podman monitor, run: tmux attach -t podman-monitor"
    exit 1
  fi
  
  exit 0
}

# Run main function
main
