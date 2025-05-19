#!/bin/bash
# filepath: /home/sgallego/Downloads/GIT/ee-containers/cleanup_role.sh
# Script to identify and remove unused files in the ee-builder role

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Define the base directory
ROLE_DIR="/home/sgallego/Downloads/GIT/ee-containers/roles/ee-builder"

# Check if the role directory exists
if [ ! -d "$ROLE_DIR" ]; then
    echo -e "${RED}Error: Role directory $ROLE_DIR not found${RESET}"
    exit 1
fi

echo -e "${GREEN}Analyzing files in $ROLE_DIR...${RESET}"

# Define required files based on meta/main.yml file structure
declare -a REQUIRED_FILES=(
    # Task files
    "tasks/main.yml"
    "tasks/initialize.yml"
    "tasks/system_setup.yml"
    "tasks/authentication.yml"
    "tasks/environment_selection.yml"
    "tasks/environment_preparation.yml"
    "tasks/fix_and_configure.yml"
    "tasks/build_monitoring.yml"
    "tasks/build_execution.yml"
    "tasks/post_build.yml"
    "tasks/final_cleanup.yml"
    # Variable files
    "vars/main.yml"
    "vars/environment-configs.yml"
    # Template files
    "templates/ansible.cfg.j2"
    "templates/tmux_header.j2"
    "templates/tmux_launcher.sh.j2"
    # Meta files
    "meta/main.yml"
    # Common Ansible role files
    "defaults/main.yml"
    "handlers/main.yml"
    "README.md"
)

# Files that should not be deleted even if not in the required list
declare -a PROTECTED_PATTERNS=(
    "*.md"
    "*.example"
    "LICENSE"
    "CHANGELOG"
    "tests/*"
    ".git*"
)

# Function to check if a file is required
is_required() {
    local file="$1"
    local required=false
    
    # Check if the file is in the required list
    for req_file in "${REQUIRED_FILES[@]}"; do
        if [ "$file" == "$req_file" ]; then
            required=true
            break
        fi
    done

    # Check if the file matches protected patterns
    if [ "$required" = false ]; then
        for pattern in "${PROTECTED_PATTERNS[@]}"; do
            if [[ "$file" = $pattern ]]; then
                required=true
                break
            fi
        done
    fi

    echo $required
}

# Function to find unused files
find_unused_files() {
    local unused_files=()
    local base_len=${#ROLE_DIR}+1

    # Find all files in the role directory
    while IFS= read -r -d '' file; do
        # Get relative path to ROLE_DIR
        rel_path=${file:$base_len}
        
        # Check if the file is required
        if [ $(is_required "$rel_path") = false ]; then
            unused_files+=("$file")
        fi
    done < <(find "$ROLE_DIR" -type f -not -path "*/\.*" -print0)

    echo "${unused_files[@]}"
}

# Find unused files
unused_files=($(find_unused_files))

# Display results
if [ ${#unused_files[@]} -eq 0 ]; then
    echo -e "${GREEN}No unused files found. Everything looks good!${RESET}"
    exit 0
fi

echo -e "${YELLOW}Found ${#unused_files[@]} potentially unused files:${RESET}"
for file in "${unused_files[@]}"; do
    echo -e "${BLUE}$file${RESET}"
done

# Ask for confirmation before deletion
read -p "Do you want to delete these files? (y/n): " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    echo -e "${YELLOW}Deleting unused files...${RESET}"
    for file in "${unused_files[@]}"; do
        echo -e "Removing: ${BLUE}$file${RESET}"
        rm "$file"
    done
    echo -e "${GREEN}Cleanup complete!${RESET}"
else
    echo -e "${GREEN}No files were deleted.${RESET}"
fi

# Clean up empty directories
echo -e "${YELLOW}Cleaning up empty directories...${RESET}"
find "$ROLE_DIR" -type d -empty -delete
echo -e "${GREEN}Directory cleanup complete!${RESET}"