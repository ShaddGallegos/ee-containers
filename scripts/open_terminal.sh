#!/bin/bash

IS_WSL="${1:-False}"

if [ "$IS_WSL" = "True" ]; then
  # Simply launch Windows Terminal without specifying a distribution
  # This will use the default WSL distribution automatically
  
  echo "Trying to open Windows Terminal with tmux monitor session..."
  
  # Method 1: Direct wt.exe approach (simplest)
  wt.exe bash -c "tmux attach -t podman-monitor || echo No tmux session found" &
  
  # If that didn't work, try PowerShell approach as fallback
  if [ $? -ne 0 ]; then
    echo "Trying PowerShell approach..."
    powershell.exe -Command "Start-Process wt.exe -ArgumentList 'bash', '-c', 'tmux attach -t podman-monitor || echo No tmux session found'" &
  fi
else
  # Standard Linux approaches
  if command -v x-terminal-emulator >/dev/null 2>&1; then
    x-terminal-emulator -e "tmux attach -t podman-monitor" &
  elif command -v gnome-terminal >/dev/null 2>&1; then
    gnome-terminal -- bash -c "tmux attach -t podman-monitor" &
  elif command -v xterm >/dev/null 2>&1; then
    xterm -e "tmux attach -t podman-monitor" &
  elif command -v konsole >/dev/null 2>&1; then
    konsole -e "tmux attach -t podman-monitor" &
  fi
fi

exit 0
