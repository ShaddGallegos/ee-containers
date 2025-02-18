#!/bin/bash
source_file="ansible.cfg"
target_directory="environments/"

# Loop over each subdirectory in the target directory
for dir in "$target_directory"/*; do
  if [ -d "$dir" ]; then
    cp "$source_file" "$dir"
  fi
done

echo "File copied to all subdirectories of $target_directory"

