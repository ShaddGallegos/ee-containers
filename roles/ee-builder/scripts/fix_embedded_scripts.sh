#!/bin/bash
# filepath: fix_embedded_scripts.sh

echo "Fixing Ansible task files with embedded scripts..."

# Find and process all yml files in the tasks directory
find roles/ee-builder/tasks -name "*.yml" -type f | while read -r file; do
  echo "Processing $file..."
  
  # Create backup
  cp "$file" "$file.bak"
  
  # Replace patterns where src and content are both specified
  sed -i -E '
    # Pattern for build/assemble script
    /ansible\.builtin\.copy:[[:space:]]*$/{
      :loop
      /src: ".*\/scripts\/build\/assemble"/!b next_block
      N
      /content: \|/!b loop
      :content_loop
      N
      /mode: "0755"/!b content_loop
      s/(src: ".*\/scripts\/build\/assemble"[^|]*).+?(mode: "0755")/\1\n      \2/
      b done_replace
      :next_block
    }
    
    # Pattern for pre-build hook
    /ansible\.builtin\.copy:[[:space:]]*$/{
      :loop2
      /src: ".*\/scripts\/hooks\/pre-build"/!b next_block2
      N
      /content: \|/!b loop2
      :content_loop2
      N
      /mode: "0755"/!b content_loop2
      s/(src: ".*\/scripts\/hooks\/pre-build"[^|]*).+?(mode: "0755")/\1\n      \2/
      b done_replace
      :next_block2
    }
    
    # Pattern for fix_ee_files script
    /ansible\.builtin\.copy:[[:space:]]*$/{
      :loop3
      /src: ".*\/scripts\/fix_ee_files\.sh"/!b next_block3
      N
      /content: \|/!b loop3
      :content_loop3
      N
      /mode: "0755"/!b content_loop3
      s/(src: ".*\/scripts\/fix_ee_files\.sh"[^|]*).+?(mode: "0755")/\1\n      \2/
      b done_replace
      :next_block3
    }
    
    # Pattern for custom-assemble script
    /ansible\.builtin\.copy:[[:space:]]*$/{
      :loop4
      /src: ".*\/scripts\/custom-assemble\.sh"/!b next_block4
      N
      /content: \|/!b loop4
      :content_loop4
      N
      /mode: "0755"/!b content_loop4
      s/(src: ".*\/scripts\/custom-assemble\.sh"[^|]*).+?(mode: "0755")/\1\n      \2/
      b done_replace
      :next_block4
    }
    
    :done_replace
  ' "$file"

  # Simple check if file was modified
  if cmp -s "$file" "$file.bak"; then
    echo "  No changes needed for $file"
    rm "$file.bak"
  else
    echo "  Fixed embedded script tasks in $file"
  fi
done

echo "Fixing the paths to match correct structure..."
find roles/ee-builder/tasks -name "*.yml" -type f | xargs sed -i 's|{{ role_path }}/scripts|{{ playbook_dir }}/roles/ee-builder/scripts|g'

echo "Done!"