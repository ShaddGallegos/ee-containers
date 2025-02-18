#!/bin/bash

# Variables
WSL_IP=$(hostname -I | awk '{print $1}') # Get the WSL IP address
VM_IP="172.23.240.149" # Replace with your VM's IP address
VM_USER="root" # Replace with your VM's username
LAPTOP_IP="172.21.80.1" # Replace with your Laptop's IP address

# Connect WSL to VM
echo "Connecting WSL to VM at $VM_IP..."
ssh $VM_USER@$VM_IP << EOF
echo "Connected to VM."
# Additional setup commands for your VM can go here
EOF

# Connect VM to Laptop
echo "Connecting VM to Laptop at $LAPTOP_IP..."
ssh $VM_USER@$VM_IP << EOF
ssh-copy-id $USER@$LAPTOP_IP
ssh $USER@$LAPTOP_IP
EOF

echo "Connection setup complete."