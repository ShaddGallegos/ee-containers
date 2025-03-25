#!/bin/bash
tmux new-session -d -s podman-monitor
tmux split-window -v -p 30
tmux select-pane -t 0
tmux send-keys "watch podman ps" C-m
tmux select-pane -t 1
tmux send-keys "watch podman images" C-m
