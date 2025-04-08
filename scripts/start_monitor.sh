#!/bin/bash

# Create basic session with forced dimensions
tmux new-session -d -s podman-monitor

# Create initial status file with default message
echo "NOTHING BUILDING YET" > /tmp/current_env

# Configure the top pane with ASCII art header
tmux select-pane -t podman-monitor:0.0
tmux send-keys -t podman-monitor:0.0 "clear; cat << 'EOF'

                  ●●●●●●●
                 ●●●●●●●●●
                ●●●●●●●●●●●
               ●●●●●  ●●●●●●
    ╔═════════●●●●●════●●●●●●════════════════════════════════════════════════════╗
    ║        ●●●●●      ●●●●●●                                                   ║
    ║       ●●●●●        ●●●●●●                                                  ║
    ║      ●●●●●          ●●●●●●                                                 ║
    ║     ●●●●●●           ●●●●●●●                                               ║
    ║    ●●●●●●              ●●●●●●                                              ║
    ║   ●●●●●●●●●             ●●●●●●                                             ║
    ║  ●●●●●● ●●●●●●●●         ●●●●●●                                            ║
    ║ ●●●●●●      ●●●●●●●       ●●●●●● ANSIBLE & PODMAN                          ║
    ╠●●●●●●══════════●●●●●●●════●●●●●●●══════════════════════════════════════════╣
    ●●●●●●              ●●●●●●●●●●●●●●● EXECUTION BUILD MONITOR                  ║
  ●●●●●●══════════════════●●●●●●●●●●●●═══════════════════════════════════════════╝
●●●●●●●
EOF
" C-m
# Split into bottom panes
tmux split-window -v -t podman-monitor
tmux split-window -v -t podman-monitor:0.1

# Set pane sizes
tmux resize-pane -t podman-monitor:0.0 -y 15
tmux resize-pane -t podman-monitor:0.1 -y 2
tmux resize-pane -t podman-monitor:0.2 -y 20

# Configure middle pane for current build status with spinner
tmux select-pane -t podman-monitor:0.1
tmux send-keys -t podman-monitor:0.1 "
while true; do
  BUILDING_FILE=/tmp/current_env
  if [ -f \"\$BUILDING_FILE\" ]; then
    BUILDING_ENV=\$(cat \"\$BUILDING_FILE\")
    
    # Default output with no spinner
    OUTPUT=\"\$BUILDING_ENV\"
    
    # Check if this is an active build (not SKIPPED, COMPLETED, or default message)
    if [[ \"\$BUILDING_ENV\" != \"SKIPPED\"* && 
          \"\$BUILDING_ENV\" != \"COMPLETED\"* && 
          \"\$BUILDING_ENV\" != \"NOTHING BUILDING YET\" && 
          \"\$BUILDING_ENV\" != \"FAILED\"* ]]; then
      # Add spinner only for active builds
      SPINNER_CHARS=(\"|\" \"/\" \"-\" \"\\\\\")
      SPINNER_INDEX=\$(( (SECONDS / 1) % 4 ))
      SPINNER=\${SPINNER_CHARS[\$SPINNER_INDEX]}
      
      # Format with 'Building:' prefix and spinner suffix
      OUTPUT=\"Building: \$BUILDING_ENV \${SPINNER}\"
    elif [[ \"\$BUILDING_ENV\" == \"FAILED\"* ]]; then
      # Red for failed builds
      OUTPUT=\"\033[1;31m\$BUILDING_ENV\033[0m\"
    elif [[ \"\$BUILDING_ENV\" == \"COMPLETED\"* ]]; then
      # Green for completed builds
      OUTPUT=\"\033[1;32m\$BUILDING_ENV\033[0m\"
    fi
    
    # Clear line and print output
    clear
    printf \" %b\" \"\$OUTPUT\"
  else
    # Fallback if file doesn't exist
    clear
    printf \" NOTHING BUILDING YET\"
  fi
  sleep 0.5
done
" C-m

# Configure bottom pane for podman images
tmux select-pane -t podman-monitor:0.2
tmux send-keys -t podman-monitor:0.2 "watch -n 0.5 'podman images | (echo \"REPOSITORY                                                            TAG            IMAGE ID      CREATED       SIZE\" && echo \"----------------------------------------------------------------------------------------------------------------\" && grep -v \"REPOSITORY\")'" C-m

# Do NOT attach - let the session run detached
# This way Ansible can continue and the monitor stays running
echo "Monitor session started. Use 'tmux attach -t podman-monitor' to view."
