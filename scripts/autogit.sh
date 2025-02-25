#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

# Function to print errors
print_error() {
    echo -e "${RED}[!]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please run this script as a regular user, not as root"
    exit 1
fi

# Prompt for GitHub credentials
read -p "Enter your GitHub username: " github_username
read -sp "Enter your GitHub Personal Access Token: " github_token
echo

# Configure Git globally
print_status "Configuring Git globally..."
git config --global user.name "$github_username"
read -p "Enter your email address: " github_email
git config --global user.email "$github_email"

# Store credentials
print_status "Setting up credential storage..."
git config --global credential.helper store

# Update remote URL with credentials
print_status "Updating remote URL..."
git remote set-url origin "https://${github_username}:${github_token}@github.com/ShaddGallegos/ee-containers.git"

# Test authentication
print_status "Testing authentication..."
if git ls-remote &>/dev/null; then
    print_status "Authentication successful!"
    
    # Fix VSCode Git socket issue
    if [ ! -d "/run/user/$UID" ]; then
        sudo mkdir -p "/run/user/$UID"
        sudo chown $USER:$USER "/run/user/$UID"
    fi
    
    # Try to push
    print_status "Attempting to push..."
    git push
else
    print_error "Authentication failed. Please check your credentials."
fi
