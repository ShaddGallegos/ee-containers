#!/bin/bash

# Define the source file
source_file="ee-rhel9-vmware/ansible.cfg"

# Loop through all directories in the current directory
for dir in */; do
  # Check if the execution-environment.yml file exists in the directory
  if [[ ! -f "${dir}ansible.cfg" ]]; then
    # Copy the file from the source directory to the target directory
    cp "$source_file" "$dir"
    echo "Copied ansible.cfg to $dir" >> copied_folders.txt
  else
    echo "ansible.cfg already exists in $dir"
  fi
done

# Display the folders the file was copied into
if [[ -f "copied_folders.txt" ]]; then
  echo "ansible.cfg file was copied into the following folders:"
  cat copied_folders.txt
  rm copied_folders.txt # Clean up the temporary file
else
  echo "No folders required the ansible.cfg file to be copied."
fi

