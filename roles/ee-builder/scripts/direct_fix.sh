#!/bin/bash
# filepath: direct_fix.sh

echo "Directly fixing mutually exclusive src/content error..."

# Get the current directory (should be project root)
CWD=$(pwd)
echo "Current directory: $CWD"

# List the tasks directory to ensure files are where we expect
echo "Listing tasks directory:"
ls -la roles/ee-builder/tasks/

# Get all task files
TASK_FILES=$(find roles/ee-builder/tasks -name "*.yml")
echo "Found task files: $TASK_FILES"

for file in $TASK_FILES; do
  echo "Checking $file..."
  
  # Print the content that matches the problem pattern for debugging
  echo "Looking for problematic patterns in $file:"
  grep -A 10 "Copy fix_ee_files script" "$file" || echo "Pattern not found"
  
  # Create backup
  cp "$file" "${file}.bak"
  
  # First approach - sed with simple pattern
  sed -i '/name: Copy fix_ee_files script/{
    :loop
    N
    /mode: "0755"/!b loop
    s/\(src: .*\)\(\n.*content: |\).*\(mode: "0755"\)/\1\n      \3/
  }' "$file"
  
  echo "Fixed file $file - check if it worked"
  
  # Also try more aggressive fix as fallback
  sed -i 's/\(src:.*\)\(.*content: |\)/\1/' "$file"
  
  # Let's also fix any other similar patterns
  sed -i 's/\(ansible\.builtin\.copy:.*src:.*\)\(content: |\)/\1/' "$file"
  
  # One more aggressive approach for all copy tasks
  grep -A 20 "ansible.builtin.copy:" "$file" | grep -q "src:" && grep -A 20 "ansible.builtin.copy:" "$file" | grep -q "content:" && {
    echo "Found task with both src and content in $file - fixing..."
    sed -i '/ansible\.builtin\.copy:/,/mode: "0755"/ {
      /content: |/,/mode: "0755"/ {
        /content: |/d
        /^ *[^ ]/!d
      }
    }' "$file"
  }
done

echo "Done! Try running your playbook again."