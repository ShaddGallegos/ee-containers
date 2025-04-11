#!/bin/bash

# This script modifies pip commands to exclude systemd-python
# Run it before building the execution environment

# Create a wrapper script for pip in /usr/local/bin
cat > /usr/local/bin/pip-wrapper << 'EOL'
#!/bin/bash

# Store original command
ORIGINAL_COMMAND="$@"

# Check if this is an install command
if [[ "$ORIGINAL_COMMAND" == *" install "* ]]; then
  # Add --exclude systemd-python to the command
  exec /usr/bin/pip $ORIGINAL_COMMAND --exclude systemd-python
else
  # Just pass through the command
  exec /usr/bin/pip $ORIGINAL_COMMAND
fi
EOL

# Make it executable
chmod +x /usr/local/bin/pip-wrapper

# Backup original pip
mv /usr/bin/pip /usr/bin/pip.original

# Create a symbolic link to our wrapper
ln -s /usr/local/bin/pip-wrapper /usr/bin/pip

echo "Installed pip wrapper to exclude systemd-python"