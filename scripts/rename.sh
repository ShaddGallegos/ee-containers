#!/bin/bash

# Loop through all directories in the current directory
for dir in */; do
  # Check if the directory name ends with "-ee"
  if [[ "$dir" == *-de/ ]]; then
    # Remove the trailing slash
    dir="${dir%/}"
    # Extract the base name without "-ee"
    base="${dir%-de}"
    # Rename the directory
    mv "$dir" "de-$base"
  fi
done

