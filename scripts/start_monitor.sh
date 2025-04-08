#!/bin/bash

# Kill existing session if it exists
if tmux has-session -t podman-monitor 2>/dev/null; then
  tmux kill-session -t podman-monitor
  pkill -f "tmux" || true
  sleep 1
fi

# Create basic session with forced dimensions
tmux new-session -d -s podman-monitor

# IMPORTANT: First split into top and bottom
# Then split the top portion to create the middle line
# This approach gives better control over the middle pane height
tmux split-window -t podman-monitor:0.0 -v -p 60  # Bottom pane is 60% of the screen
tmux split-window -t podman-monitor:0.0 -v -l 1   # Middle pane is exactly 1 line tall

# Create initial status file with default message
echo "NOTHING BUILDING YET" > /tmp/current_env

# Now we have:
# podman-monitor:0.0 - Top pane (header)
# podman-monitor:0.1 - Middle pane (build info - exactly one line)
# podman-monitor:0.2 - Bottom pane (podman images)

# Configure the top pane with ASCII art header (pane 0)
tmux select-pane -t podman-monitor:0.0
tmux send-keys -t podman-monitor:0.0 "clear; cat << 'EOF'

Starting Podman monitoring...


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

# Configure middle pane for Build info with progress spinner (pane 1) - exactly one line
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
          \"\$BUILDING_ENV\" != \"NOTHING BUILDING YET\" ]]; then
      # Add spinner only for active builds
      SPINNER_CHARS=(\"|\" \"/\" \"-\" \"\\\\\")
      SPINNER_INDEX=\$(( (SECONDS / 1) % 4 ))
      SPINNER=\${SPINNER_CHARS[\$SPINNER_INDEX]}
      
      # Format with 'Building:' prefix and spinner suffix
      OUTPUT=\"Building: \$BUILDING_ENV \${SPINNER}\"
    fi
    
    # Clear line and print output
    clear
    printf \" %s\" \"\$OUTPUT\"
  else
    # Fallback if file doesn't exist
    clear
    printf \" NOTHING BUILDING YET\"
  fi
  sleep 0.5
done
" C-m

# Configure bottom pane for podman images with continuous update
tmux select-pane -t podman-monitor:0.2
tmux send-keys -t podman-monitor:0.2 "watch -n 0.5 'podman images | (echo \"REPOSITORY                                                            TAG            IMAGE ID      CREATED       SIZE\" && echo \"----------------------------------------------------------------------------------------------------------------\" && grep -v \"REPOSITORY\")'" C-m

# Now, let's attach to the session rather than detaching from it
tmux attach -t podman-monitor
