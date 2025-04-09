#!/bin/bash

# Kill any existing session to ensure clean slate
tmux kill-session -t podman-monitor 2>/dev/null || true

# Create initial status file with default message
echo "NOTHING BUILDING YET" > /tmp/current_env

# Create new session with proper dimensions
tmux new-session -d -s podman-monitor -x 100 -y 40

# Split window into three panes
# Main layout: top (ASCII art), middle (status), bottom (images)
tmux split-window -v -t podman-monitor:0.0 -p 70
tmux split-window -v -t podman-monitor:0.1 -p 30

# Top pane: Keep the existing ASCII art header
tmux select-pane -t podman-monitor:0.0
tmux send-keys -t podman-monitor:0.0 "clear; cat << 'EOF'
                ●●●●●●●
               ●●●●●●●●●
              ●●●●●●●●●●●
    ╔════════●●●●●●═●●●●●●══════════════════════════════════════════════╗
    ║       ●●●●●●    ●●●●●●                                            ║
    ║      ●●●●●●      ●●●●●●                                           ║
    ║     ●●●●●●        ●●●●●●                                          ║
    ║    ●●●●●●           ●●●●●●                                        ║
    ║   ●●●●●●●●●          ●●●●●●                                       ║
    ║  ●●●●●● ●●●●●●●       ●●●●●●                                      ║
    ║ ●●●●●●      ●●●●●●●    ●●●●●● ANSIBLE & PODMAN                    ║
    ╠●●●●●●══════════●●●●●●══●●●●●●●════════════════════════════════════╣
   ●●●●●●              ●●●●●●●●●●●● EXECUTION BUILD MONITOR             ║
  ●●●●●●══════════════════●●●●●●●●●═════════════════════════════════════╝
  ●●●●●
EOF
" C-m

# Middle pane: Current build status
tmux select-pane -t podman-monitor:0.1
tmux send-keys -t podman-monitor:0.1 '
while true; do
  clear
  BUILDING_FILE=/tmp/current_env
  if [ -f "$BUILDING_FILE" ]; then
    BUILDING_ENV=$(cat "$BUILDING_FILE")
    
    # Default output with no spinner
    OUTPUT="$BUILDING_ENV"
    
    # Check for active build and add spinner
    if [[ "$BUILDING_ENV" != "SKIPPED"* && 
          "$BUILDING_ENV" != "COMPLETED"* && 
          "$BUILDING_ENV" != "NOTHING BUILDING YET" && 
          "$BUILDING_ENV" != "FAILED"* ]]; then
      SPINNER_CHARS=("|" "/" "-" "\\")
      SPINNER_INDEX=$(( (SECONDS / 1) % 4 ))
      SPINNER=${SPINNER_CHARS[$SPINNER_INDEX]}
      OUTPUT="Building: $BUILDING_ENV ${SPINNER}"
    elif [[ "$BUILDING_ENV" == "FAILED"* ]]; then
      OUTPUT="\033[1;31m$BUILDING_ENV\033[0m"
    elif [[ "$BUILDING_ENV" == "COMPLETED"* ]]; then
      OUTPUT="\033[1;32m$BUILDING_ENV\033[0m"
    fi
    
    # Print centered output
    printf "\n %b\n" "$OUTPUT"
  else
    printf "\n NOTHING BUILDING YET\n"
  fi
  sleep 0.5
done
' C-m

# Bottom pane: Podman images list (full screen width)
tmux select-pane -t podman-monitor:0.2
tmux send-keys -t podman-monitor:0.2 '
watch -n 1 "podman images | (echo \"REPOSITORY                  TAG           IMAGE ID       CREATED       SIZE\" && echo \"------------------------------------------------------------------------------\" && grep -v \"REPOSITORY\")"
' C-m

echo "Monitor session started. Use 'tmux attach -t podman-monitor' to view."
