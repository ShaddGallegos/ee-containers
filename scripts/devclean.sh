#!/bin/bash
# filepath: /mnt/c/Users/sgallego/Downloads/GIT/ee-containers/scripts/devclean.sh
# Script to identify and move unused files in ee-containers directory to backup

# Change to repository root directory (one level up from scripts)
cd "$(dirname "$0")/.." || { echo "Could not change to repository root"; exit 1; }
REPO_ROOT=$(pwd)

# Define backup directory
BACKUP_DIR="${REPO_ROOT}/../backup/ee-containers-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="${BACKUP_DIR}/backup_log.txt"

echo "Repository root: ${REPO_ROOT}"
echo "Backup directory: ${BACKUP_DIR}"

# Create backup directory
mkdir -p "${BACKUP_DIR}"
echo "Backup started at $(date)" > "${LOG_FILE}"
echo "Source directory: ${REPO_ROOT}" >> "${LOG_FILE}"
echo "-------------------------------------------" >> "${LOG_FILE}"

# Function to move a file or directory to backup
backup_item() {
    local item=$1
    local reason=$2
    
    # Skip if in .git or .vscode
    if [[ "$item" == *".git"* ]] || [[ "$item" == *".vscode"* ]]; then
        return
    fi
    
    # Create directory structure in backup
    mkdir -p "$(dirname "${BACKUP_DIR}/${item}")"
    
    # Move the file/directory to backup
    if [ -e "$item" ]; then
        mv "$item" "${BACKUP_DIR}/${item}" 2>/dev/null
        echo "Moved: ${item} - Reason: ${reason}" >> "${LOG_FILE}"
    fi
}

# Function to find and back up files by pattern
find_and_backup() {
    local pattern=$1
    local type=$2
    local reason=$3
    local directory=${4:-.}  # Default to current directory if not specified
    
    echo "Moving ${reason}s from ${directory}..."
    find "${directory}" -name "${pattern}" -type "${type}" -not -path "*.git*" -not -path "*.vscode*" 2>/dev/null | while read -r item; do
        backup_item "$item" "$reason"
    done
}

# Clean up various file types
find_and_backup "*.bak" "f" "Backup file"
find_and_backup "*.retry" "f" "Retry file"
find_and_backup "*.tmp" "f" "Temporary file"
find_and_backup ".ansible-lint" "f" "Lint file"
find_and_backup "*.orig" "f" "Orig file"
find_and_backup "__pycache__" "d" "Cache directory"
find_and_backup "*.pyc" "f" "Python compiled file"
find_and_backup ".pytest_cache" "d" "Pytest cache"
find_and_backup "*.log" "f" "Log file"

# Handle empty directories
echo "Moving empty directories..."
find . -type d -empty -not -path "*.git*" -not -path "*.vscode*" 2>/dev/null | while read -r item; do
    if [[ "$item" != "." ]]; then
        backup_item "$item" "Empty directory"
    fi
done

# Check for specific files
if [ -f "templates/ansible.cfg.old.j2" ]; then
    backup_item "templates/ansible.cfg.old.j2" "Old template"
fi

if [ -f "templates/ansible.cfg.bak.j2" ]; then
    backup_item "templates/ansible.cfg.bak.j2" "Backup template"
fi

if [ -f "templates/protected_images.old.j2" ]; then
    backup_item "templates/protected_images.old.j2" "Old template"
fi

# Special cleanup for environments directory
echo "Cleaning environments directory..."
if [ -d "environments" ]; then
    echo "Performing deep clean of environments directory..."
    find_and_backup "*.bak" "f" "Environment backup file" "environments"
    find_and_backup "*.yml.old" "f" "Old YAML file" "environments"
    find_and_backup "*.bak.yml" "f" "Backup YAML file" "environments"
    find_and_backup "*.retry" "f" "Environment retry file" "environments"
    find_and_backup "*.tmp" "f" "Environment temporary file" "environments"
    find_and_backup "*.swp" "f" "Vim swap file" "environments"
    find_and_backup "*~" "f" "Backup file" "environments"
fi

echo "-------------------------------------------" >> "${LOG_FILE}"
echo "Backup completed at $(date)" >> "${LOG_FILE}"
echo "Total files/directories moved: $(find "${BACKUP_DIR}" -path "${BACKUP_DIR}/*" | wc -l)" >> "${LOG_FILE}"

echo "Backup completed. See ${LOG_FILE} for details."