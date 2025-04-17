#!/bin/bash
set -e
for file in $(find /tmp/ee-containers -type f -name "execution-environment.yml"); do
  echo "Processing $file"
  
  # Make backup
  cp "$file" "${file}.bak"
  
  # Extract base image if possible
  BASE_IMG=$(grep -A 5 'base_image:' "$file" | grep 'name:' | head -1 | awk '{print $2}' | tr -d '"'"'" || echo "")
  
  # Use default if none found
  if [ -z "$BASE_IMG" ]; then
    BASE_IMG="registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9:latest"
  fi
  
  # Fix path issues
  BASE_IMG=$(echo "$BASE_IMG" | sed 's|//|/|g')
  BASE_IMG=$(echo "$BASE_IMG" | sed 's|ansible-automation-platform-23/|ansible-automation-platform-25/|g')
  
  # Create clean file with version 3 structure
  cat > "${file}.new" << EOT
version: 3

build_arg_defaults:
  EE_BASE_IMAGE: ${BASE_IMG}
  ANSIBLE_GALAXY_CLI_COLLECTION_OPTS: '--ignore-errors --force'
  ANSIBLE_GALAXY_CLI_ROLE_OPTS: '--ignore-errors'

ansible_config: 'ansible.cfg'

dependencies:
EOT
  
  # Preserve dependencies section if it exists
  if grep -q "python:" "${file}"; then
    echo "  python:" >> "${file}.new"
    sed -n '/python:/,/system/p' "$file" | grep -v "system:" >> "${file}.new" 
  fi
  
  if grep -q "system:" "${file}"; then
    echo "  system:" >> "${file}.new"
    sed -n '/system:/,/additional_build_steps\|galaxy\|$/{/additional_build_steps\|galaxy/!p;}' "$file" >> "${file}.new"
  fi
  
  if grep -q "galaxy:" "${file}"; then
    echo "  galaxy:" >> "${file}.new"
    sed -n '/galaxy:/,/additional_build_steps\|$/{/additional_build_steps/!p;}' "$file" >> "${file}.new"
  fi
  
  # Preserve additional_build_steps if they exist
  if grep -q "additional_build_steps:" "${file}"; then
    echo "" >> "${file}.new"
    echo "additional_build_steps:" >> "${file}.new"
    
    # Check for prepend section
    if grep -q "prepend:" "${file}"; then
      echo "  prepend:" >> "${file}.new"
      sed -n '/prepend:/,/append\|$/{/append:/!p;}' "$file" | grep -v "prepend:" >> "${file}.new"
    fi
    
    # Check for append section
    if grep -q "append:" "${file}"; then
      echo "  append:" >> "${file}.new"
      sed -n '/append:/,/$/{/^---/!p;}' "$file" | grep -v "append:" >> "${file}.new"
    fi
  fi
  
  # Replace original
  mv "${file}.new" "$file"
  echo "Fixed $file to version 3 format"
done
exit 0
