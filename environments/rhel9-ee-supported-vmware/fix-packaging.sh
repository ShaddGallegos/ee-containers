#!/bin/bash

# Create a wrapper around pip to always use --ignore-installed flag
cat > /usr/local/bin/pip-safe << 'EOF'
#!/bin/bash
/usr/bin/python3 -m pip "$@" --ignore-installed
EOF

chmod +x /usr/local/bin/pip-safe

# Create symlinks for common pip commands
ln -sf /usr/local/bin/pip-safe /usr/local/bin/pip
ln -sf /usr/local/bin/pip-safe /usr/local/bin/pip3

# Pin problematic system packages to prevent upgrades
echo "packaging==20.9" > /tmp/pinned.txt

# Use our new wrapper to install bindep safely
pip-safe install --no-cache-dir pyyaml requirements-parser
pip-safe install --no-deps --no-cache-dir bindep

echo "Pip installation patched successfully"