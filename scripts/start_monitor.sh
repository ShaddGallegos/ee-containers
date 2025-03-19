#!/bin/bash
# Simple monitoring script for podman

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

echo "Monitoring session created. Connect with: tmux attach -t podman-monitor"
