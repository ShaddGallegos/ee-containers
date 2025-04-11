#!/bin/bash

# Save selected environments
if [ "$1" != "" ]; then
  echo "$1" > /tmp/selected_envs
fi

# Kill any existing session to ensure clean slate
tmux kill-session -t podman-monitor 2>/dev/null || true

# Create initial status file with default message
echo "NOTHING BUILDING YET" > /tmp/current_env

# Create new session with dynamic dimensions
tmux new-session -d -s podman-monitor

# Split window into three panes with optimized sizes:
tmux split-window -v -t podman-monitor:0.0 -p 85
tmux split-window -v -t podman-monitor:0.1 -p 40

# Top pane: ASCII art header and registry status
tmux select-pane -t podman-monitor:0.0
tmux send-keys -t podman-monitor:0.0 "clear; cat << 'EOF'
┌──────────────────────────────────────────────────────────────────────────┐
│              ●●●●●●●                                                     │
│             ●●●●●●●●●                                                    │
│            ●●●●●●●●●●●                                                   │
│    ╔══════●●●●●●═●●●●●●══════╗                                           │
│    ║     ●●●●●●    ●●●●●● NSIBLE & PODMAN                                │
│    ║    ●●●●●●      ●●●●●●    ║ EXECUTION ENVIRONMENT BUILD MONITOR      │
│    ╚═══●●●●●●════════●●●●●●═══╝                                          │
└──────────────────────────────────────────────────────────────────────────┘
EOF
" C-m

tmux send-keys -t podman-monitor:0.0 "echo 'Selected environments:'" C-m
tmux send-keys -t podman-monitor:0.0 "if [ -f /tmp/selected_envs ]; then cat /tmp/selected_envs; else echo 'None selected yet'; fi" C-m
tmux send-keys -t podman-monitor:0.0 "echo ''" C-m
tmux send-keys -t podman-monitor:0.0 "echo 'Registry status:'" C-m
tmux send-keys -t podman-monitor:0.0 "podman login --get-login registry.redhat.io 2>/dev/null && echo 'Registry authentication: ✓' || echo 'Registry authentication: ✗'" C-m

# Middle pane: Build status with file watch
tmux select-pane -t podman-monitor:0.1
tmux send-keys -t podman-monitor:0.1 'while true; do clear; echo "Current build:"; cat /tmp/current_env 2>/dev/null || echo "No build running"; sleep 1; done' C-m

# Bottom pane: Fast refresh podman images
tmux select-pane -t podman-monitor:0.2
tmux send-keys -t podman-monitor:0.2 'watch -n .05 podman images' C-m

echo "Monitor session started. Use 'tmux attach -t podman-monitor' to view."
