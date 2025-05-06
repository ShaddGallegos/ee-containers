#!/bin/bash

echo "Testing registry authentication..."

# Try pulling an image
podman pull registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9:latest || {
  echo "Authentication failed. Check your credentials or network connection."
  exit 1
}

echo "Authentication successful!"
exit 0