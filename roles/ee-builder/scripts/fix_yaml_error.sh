#!/bin/bash
# filepath: fix_yaml_error.sh

echo "Fixing YAML syntax error in setup.yml..."

# Backup the file
cp roles/ee-builder/tasks/setup.yml roles/ee-builder/tasks/setup.yml.bak

# Fix the specific issue - indentation around line 93
sed -i '93s/^  ---/    ---/' roles/ee-builder/tasks/setup.yml

# Also check for and fix other instances of both src and content
sed -i '/ansible\.builtin\.copy:/ {
  :start
  n
  /src:/ {
    h
    :loop
    n
    /content:/ {
      s/content: |/# content removed to fix error/
      x
      p
      d
    }
    /mode:/ b end
    b loop
  }
  /mode:/ b end
  b start
  :end
}' roles/ee-builder/tasks/setup.yml

echo "Fixed setup.yml - check syntax with:"
echo "ansible-playbook --syntax-check -i localhost, your_playbook.yml"