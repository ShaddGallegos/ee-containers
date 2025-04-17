#!/bin/bash
echo "Running pre-build hook"

# Create symlink for package managers if needed
if [ ! -f /usr/bin/dnf ] && [ -f /usr/bin/microdnf ]; then
  ln -s /usr/bin/microdnf /usr/bin/dnf || true
  echo "Created symlink from microdnf to dnf"
fi

exit 0