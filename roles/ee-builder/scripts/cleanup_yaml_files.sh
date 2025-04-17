#!/bin/bash
# filepath: c:\Users\sgallego\Desktop\ee-containers\cleanup_yaml_files.sh
# Description: Removes embedded scripts from Ansible YAML files and replaces with external file references

set -e

# Define color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      CLEANING UP EMBEDDED SCRIPTS IN YAML FILES       ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════╝${NC}"

# Find all relevant YAML files
YAML_FILES=$(find roles/ee-builder/tasks -name "*.yml")
COUNT=0

for file in $YAML_FILES; do
  echo -e "\n${YELLOW}Scanning ${file}...${NC}"
  
  # Create a backup of the file
  cp "$file" "${file}.bak"
  
  # Replace embedded assemble script task
  if grep -q "Create modified assemble script" "$file"; then
    echo -e "${GREEN}Replacing embedded assemble script...${NC}"
    sed -i -E '/name: Create modified assemble script/,/mode: "0755"/c\
# Copy pre-built assemble script from scripts directory\
- name: Copy modified assemble script\
  ansible.builtin.copy:\
    src: "{{ role_path }}/scripts/build/assemble"\
    dest: "{{ paths.build }}"\
    mode: "0755"' "$file"
    COUNT=$((COUNT+1))
  fi

  # Replace embedded pre-build hook task
  if grep -q "Create pre-build hook" "$file"; then
    echo -e "${GREEN}Replacing embedded pre-build hook...${NC}"
    sed -i -E '/name: Create pre-build hook/,/mode: "0755"/c\
# Copy pre-built hook script from scripts directory\
- name: Copy pre-build hook\
  ansible.builtin.copy:\
    src: "{{ role_path }}/scripts/hooks/pre-build"\
    dest: "{{ paths.hooks }}/pre-build"\
    mode: "0755"' "$file"
    COUNT=$((COUNT+1))
  fi

  # Replace embedded fix_ee_files script
  if grep -q "Create Python fix script" "$file" || grep -q "fix_ee_files" "$file"; then
    echo -e "${GREEN}Replacing embedded fix_ee_files script...${NC}"
    sed -i -E '/name: Create.*fix.*script/,/mode: "0755"/c\
# Copy pre-built fix script from scripts directory\
- name: Copy fix_ee_files script\
  ansible.builtin.copy:\
    src: "{{ role_path }}/scripts/fix_ee_files.sh"\
    dest: "/tmp/ee-containers/fix_ee_files.sh"\
    mode: "0755"' "$file"
    COUNT=$((COUNT+1))
  fi

  # Replace embedded custom assemble script
  if grep -q "universal package manager" "$file"; then
    echo -e "${GREEN}Replacing embedded custom-assemble.sh script...${NC}"
    sed -i -E '/name: Create.*universal package manager/,/mode: "0755"/c\
# Copy pre-built custom assemble script\
- name: Copy custom assemble script\
  ansible.builtin.copy:\
    src: "{{ role_path }}/scripts/custom-assemble.sh"\
    dest: "/tmp/ee-containers/custom-assemble.sh"\
    mode: "0755"' "$file"
    COUNT=$((COUNT+1))
  fi

  # Replace embedded build monitor script
  if grep -q "Copy tmux monitor script" "$file"; then
    echo -e "${GREEN}Replacing embedded tmux monitor script...${NC}"
    sed -i -E '/name: Copy tmux monitor script/,/changed_when: false/c\
# Copy pre-built monitor script\
- name: Copy tmux monitor script\
  ansible.builtin.copy:\
    src: "{{ role_path }}/scripts/build_monitor.sh"\
    dest: "{{ paths.scripts }}/{{ tmux.monitor_script }}"\
    mode: "0755"\
  when: var_check is succeeded' "$file"
    COUNT=$((COUNT+1))
  fi

  # Check if the file changed
  if cmp -s "$file" "${file}.bak"; then
    echo -e "${YELLOW}No changes required in ${file}${NC}"
    rm "${file}.bak"
  else
    echo -e "${GREEN}Updated ${file} - replaced embedded scripts with external references${NC}"
  fi
done

echo -e "\n${BLUE}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                   CLEANUP COMPLETE                     ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════╝${NC}"

echo -e "\n${GREEN}Replaced $COUNT embedded scripts with external references.${NC}"
echo -e "The following scripts are now referenced from external files:"
echo -e "  • ${YELLOW}assemble${NC} - roles/ee-builder/scripts/build/assemble"
echo -e "  • ${YELLOW}pre-build${NC} - roles/ee-builder/scripts/hooks/pre-build"
echo -e "  • ${YELLOW}fix_ee_files.sh${NC} - roles/ee-builder/scripts/fix_ee_files.sh"
echo -e "  • ${YELLOW}custom-assemble.sh${NC} - roles/ee-builder/scripts/custom-assemble.sh"
echo -e "  • ${YELLOW}build_monitor.sh${NC} - roles/ee-builder/scripts/build_monitor.sh"

# Remove backup files
find roles/ee-builder/tasks -name "*.yml.bak" -exec rm {} \;