#!/bin/bash

IS_WSL="${1:-False}"

if [ "$IS_WSL" = "True" ]; then
  echo "Trying to open Windows Terminal with tmux monitor session..."
  
  # Method 1: Direct wt.exe approach
  if command -v wt.exe >/dev/null 2>&1; then
    wt.exe bash -c "tmux attach -t podman-monitor || echo No tmux session found" &
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
      echo "Launched with direct wt.exe method"
      exit 0
    fi
  fi
  
  # Method 2: PowerShell approach
  if command -v powershell.exe >/dev/null 2>&1; then
    echo "Trying PowerShell approach..."
    powershell.exe -Command "Start-Process wt.exe -ArgumentList 'bash', '-c', 'tmux attach -t podman-monitor || echo No tmux session found'" &
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
      echo "Launched with PowerShell method"
      exit 0
    fi
  fi
  
  # Method 3: CMD approach
  if command -v cmd.exe >/dev/null 2>&1; then
    echo "Trying CMD approach..."
    cmd.exe /c "start wt.exe bash -c \"tmux attach -t podman-monitor\"" &
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
      echo "Launched with CMD method"
      exit 0
    fi
  fi
  
  echo "All Windows Terminal launch methods failed"
  echo "Please run manually: tmux attach -t podman-monitor"
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
