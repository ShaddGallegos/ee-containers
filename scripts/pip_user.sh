#!/bin/bash

# Find all execution-environment.yml files
find ./environments -name "execution-environment.yml" -type f | while read -r file; do
  echo "Processing $file..."
  
  # Replace pip install commands with --user added
  # Handle different pip command patterns but avoid modifying pip check commands
  sed -i -E 's/(python3 -m pip install)([^&|;]*)/\1 --user\2/g' "$file"
  sed -i -E 's/(pip3 install)([^&|;]*)/\1 --user\2/g' "$file"
  sed -i -E 's/(pip install)([^&|;]*)/\1 --user\2/g' "$file"
  
  echo "Updated $file"
done

echo "All execution-environment.yml files updated with --user switch for pip commands"