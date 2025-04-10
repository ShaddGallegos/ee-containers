#!/bin/bash

# Kill any existing session to ensure clean slate
tmux kill-session -t podman-monitor 2>/dev/null || true

# Create initial status file with default message
echo "NOTHING BUILDING YET" > /tmp/current_env

# Create new session with dynamic dimensions
tmux new-session -d -s podman-monitor

# Split window into three panes with optimized sizes:
tmux split-window -v -t podman-monitor:0.0 -p 85
tmux split-window -v -t podman-monitor:0.1 -p 5

# Top pane: ASCII art header
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

# Middle pane: Single-line status display
tmux select-pane -t podman-monitor:0.1
tmux send-keys -t podman-monitor:0.1 'while true; do
  clear
  BUILDING_FILE=/tmp/current_env
  if [ -f "$BUILDING_FILE" ]; then
    BUILDING_ENV=$(cat "$BUILDING_FILE")
    
    OUTPUT="$BUILDING_ENV"
    
    if [[ "$BUILDING_ENV" != "SKIPPED"* && 
          "$BUILDING_ENV" != "COMPLETED"* && 
          "$BUILDING_ENV" != "NOTHING BUILDING YET" && 
          "$BUILDING_ENV" != "FAILED"* ]]; then
      SPINNER_CHARS=("|" "/" "-" "\\")
      SPINNER_INDEX=$(( (SECONDS / 1) % 4 ))
      SPINNER=${SPINNER_CHARS[$SPINNER_INDEX]}
      OUTPUT="⏳ Building: $BUILDING_ENV ${SPINNER}"
    elif [[ "$BUILDING_ENV" == "FAILED"* ]]; then
      OUTPUT="❌ $BUILDING_ENV"
    elif [[ "$BUILDING_ENV" == "COMPLETED"* ]]; then
      OUTPUT="✅ $BUILDING_ENV"
    elif [[ "$BUILDING_ENV" == "NOTHING BUILDING YET" ]]; then
      OUTPUT="💤 $BUILDING_ENV"
    fi
    
    COLS=$(tput cols)
    printf "%*s\n" $(( (${#OUTPUT} + COLS) / 2 )) "$OUTPUT"
  else
    COLS=$(tput cols)
    MSG="NOTHING BUILDING YET"
    printf "%*s\n" $(( (${#MSG} + COLS) / 2 )) "💤 $MSG"
  fi
  sleep 0.5
done' C-m

# Bottom pane: Use faster refresh for podman images
tmux select-pane -t podman-monitor:0.2
tmux send-keys -t podman-monitor:0.2 'watch -n .05 podman images' C-m

echo "Monitor session started. Use 'tmux attach -t podman-monitor' to view."
