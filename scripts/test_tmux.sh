#!/bin/bash
# filepath: c:\Users\sgallego\Downloads\GIT\ee-containers\scripts\test_tmux.sh

# Make this script executable
chmod +x "$0"

echo "=== TMUX SESSION TEST SCRIPT ==="
echo "Running diagnostic checks..."

# Check if tmux is installed
if ! command -v tmux &>/dev/null; then
    echo "ERROR: tmux is not installed. Please install it with:"
    echo "sudo apt-get update && sudo apt-get install -y tmux"
    exit 1
fi

echo "✓ tmux is installed"

# First, kill any existing sessions to start fresh
echo "Removing any existing podman-monitor sessions..."
tmux kill-session -t podman-monitor 2>/dev/null || true
sleep 1

# Create a new session
echo "Creating new basic session..."
tmux new-session -d -s podman-monitor
sleep 1

# Verify session exists
if ! tmux has-session -t podman-monitor 2>/dev/null; then
    echo "ERROR: Failed to create tmux session!"
    exit 1
fi

echo "✓ Created tmux session successfully"

# Add some content to it
echo "Adding content to session..."
tmux send-keys -t podman-monitor "clear" C-m
tmux send-keys -t podman-monitor "echo '=== PODMAN MONITOR SESSION ==='" C-m
tmux send-keys -t podman-monitor "echo 'Run \"podman images\" to see your images:'" C-m
tmux send-keys -t podman-monitor "podman images" C-m

echo "✓ Added content to session"

# Test Windows Terminal launching methods
echo "=== LAUNCHING TERMINAL ==="
echo "1. Attempting direct wt.exe launch..."
wt.exe -d . wsl.exe -d rhel9 bash -c "tmux attach -t podman-monitor" &
sleep 3

echo "2. Attempting PowerShell launch..."
powershell.exe -Command "Start-Process wt.exe -ArgumentList '-d', '.', 'wsl.exe', '-d', 'rhel9', 'bash', '-c', 'tmux attach -t podman-monitor'" &
sleep 3

echo "=== MANUAL CONNECTION INSTRUCTIONS ==="
echo "If no terminal opened automatically, please:"
echo "1. Open Windows Terminal"
echo "2. Run: tmux attach -t podman-monitor"

# Verify if session still exists
if tmux has-session -t podman-monitor 2>/dev/null; then
    echo "✓ Session is still active and waiting for connection"
else
    echo "ERROR: Session was lost!"
    exit 1
fi

exit 0