#!/bin/bash

for file in $(find {{ environments_dir }} -name "execution-environment.yml"); do
  echo "Checking and fixing YAML structure in $file"

  {% if backup_enabled %}
  # Make a backup
  cp "$file" "${file}.bak"
  {% endif %}

  # 1. Remove disallowed properties from build_arg_defaults
  if grep -q "AH_TOKEN" "$file"; then
    echo "Removing disallowed AH_TOKEN from $file"
    sed -i '/AH_TOKEN:/d' "$file"
  fi

  # 2. Try to fix YAML structure by properly indenting blocks
  # Extract key sections
  version=$(grep "^version:" "$file" | head -1 | awk '{print $2}')

  # Create new file with clean structure
  cat > "${file}.new" << EOF
version: ${version}

build_arg_defaults:
  ANSIBLE_GALAXY_CLI_COLLECTION_OPTS: '--ignore-errors --force'
  ANSIBLE_GALAXY_CLI_ROLE_OPTS: '--ignore-errors'
  PKGMGR_PRESERVE_CACHE: 'false'

dependencies:
EOF

  # Extract dependencies section if it exists
  if grep -q "^dependencies:" "$file"; then
    # Get all dependencies content, preserving python and system sections
    if grep -q "  python:" "$file"; then
      echo "  python:" >> "${file}.new"
      sed -n '/  python:/,/  system/p' "$file" | grep -v "^  system" >> "${file}.new"
    fi

    if grep -q "  system:" "$file"; then
      echo "  system:" >> "${file}.new"
      sed -n '/  system:/,/^[a-z]/p' "$file" | grep -v "^[a-z]" >> "${file}.new"
    fi
  fi

  # Extract additional_build_steps if present
  if grep -q "^additional_build_steps:" "$file"; then
    echo "" >> "${file}.new"
    echo "additional_build_steps:" >> "${file}.new"

    if grep -q "  prepend:" "$file"; then
      echo "  prepend_base: |" >> "${file}.new"
      sed -n '/  prepend:/,/  append:/p' "$file" | grep -v "  prepend:" | grep -v "  append:" | sed 's/^  /    /' >> "${file}.new"
    fi

    if grep -q "  append:" "$file"; then
      echo "  append_base: |" >> "${file}.new"
      sed -n '/  append:/,/^[a-z]/p' "$file" | grep -v "  append:" | grep -v "^[a-z]" | sed 's/^  /    /' >> "${file}.new"
    fi
  fi

  # Add images section
  echo "" >> "${file}.new"
  echo "images:" >> "${file}.new"
  echo "  base_image:" >> "${file}.new"
  echo "    name: registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9:latest" >> "${file}.new"

  # Check validity with python yaml parser
  if python3 -c "import yaml; yaml.safe_load(open('${file}.new')); print('Valid YAML')"; then
    mv "${file}.new" "$file"
    echo "Successfully fixed $file"
  else
    echo "Failed to validate fixed YAML, keeping original file"
    rm -f "${file}.new"
  fi
done