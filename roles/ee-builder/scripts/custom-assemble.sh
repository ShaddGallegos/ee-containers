#!/bin/bash

# Custom assemble script for Ansible EE
echo "Running custom assemble script..."

# Create the output directory structure
mkdir -p /output/scripts/

# Copy the assemble script from bind-mount to output
if [ -f /build/scripts/assemble ]; then
  cp /build/scripts/assemble /output/scripts/
  chmod +x /output/scripts/assemble
fi

# Create helper scripts
cat > /output/scripts/pip_install << 'EOF'
#!/bin/bash
pip3 install --no-cache-dir "$@"
EOF
chmod +x /output/scripts/pip_install

# Copy entrypoint if it exists
if [ -f /build/scripts/entrypoint ]; then
  cp /build/scripts/entrypoint /output/scripts/
  chmod +x /output/scripts/entrypoint
fi

echo "Custom assemble script completed successfully"
exit 0
