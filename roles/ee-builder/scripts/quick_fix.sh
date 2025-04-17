#!/bin/bash
# filepath: quick_fix.sh

echo "Finding and fixing tasks with both src and content..."

# Locate all task files with the problematic pattern
grep -l "src.*content: |" --include="*.yml" -r roles/ee-builder/tasks/ | while read -r file; do
  echo "Found problematic task in: $file"
  
  # Create a backup
  cp "$file" "$file.bak"
  
  # Replace the specific fix_ee_files task
  sed -i '/name: Copy fix_ee_files script/,/mode: "0755"/c\
- name: Copy fix_ee_files script\
  ansible.builtin.copy:\
    src: "{{ playbook_dir }}/roles/ee-builder/scripts/fix_ee_files.sh"\
    dest: "/tmp/ee-containers/fix_ee_files.sh"\
    mode: "0755"' "$file"
  
  echo "Fixed $file"
done

echo "Done!"