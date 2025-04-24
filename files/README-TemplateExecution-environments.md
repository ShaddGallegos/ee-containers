---

# Version declaration - Required

# Specifies the format version of this config file (required field)

# Version 3 is the current standard for ansible-builder 3.x

version: 3

# Build Arguments - Optional

# Define default values for build arguments that can be used in the build process

# These can be overridden at build time with --build-arg

build_arg_defaults:

# Arguments passed to ansible-galaxy when installing collections

  ANSIBLE_GALAXY_CLI_COLLECTION_OPTS: '--ignore-errors'

# Arguments passed to ansible-galaxy when installing roles

  ANSIBLE_GALAXY_CLI_ROLE_OPTS: '--ignore-errors'

# Python command to use (default is python3)

  PYCMD: 'python3'

# Package manager to use (microdnf is recommended for RHEL-based images)

  PKGMGR: 'microdnf'

# Images Configuration - Required

# Defines the base container image to use for building the execution environment

images:

# Base image configuration

  base_image:
    # Image name in the format repository/image:tag
    # For AAP 2.5, use one of these official images:
    # - registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9:latest
    # - registry.redhat.io/ansible-automation-platform-25/ee-supported-rhel9:latest
    # - registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel8:latest
    # - registry.redhat.io/ansible-automation-platform-25/ee-supported-rhel8:latest
    name: 'registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9:latest'

# Options - Optional

# Various build options to customize the execution environment

options:

# Path to the package manager executable

  package_manager_path: /usr/bin/microdnf

# Set build context defaults

  container_init: false

# Control resource limits for the build

  build_arg_defaults:
    EE_BASE_IMAGE: 'registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9:latest'

# Dependencies - Optional

# Specifies the dependency files for the execution environment

dependencies:

# Path to Python requirements file (relative to EE directory)

# Contains Python packages to install with pip

  python: requirements.txt
  
# Path to system requirements file (relative to EE directory)

# Contains system packages to install with the package manager

# Uses bindep format

  system: bindep.txt
  
# Path to Galaxy requirements file (relative to EE directory)

# Contains Ansible collections and roles to install

  galaxy: requirements.yml

# Additional Build Steps - Optional

# Define custom commands to run at various stages of the build process

additional_build_steps:

# Commands to run before base image preparation

# This runs in the initial stage before any dependencies are installed

  prepend_base: |
    RUN microdnf install -y python3-pip python3-devel

# Commands to run after base image preparation

# Use this for additional system setup

  append_base: |
    RUN microdnf upgrade -y && \
        python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Commands to run before Galaxy collection installation

# Use for custom repository setup or pre-Galaxy tasks

  prepend_galaxy: |
    # Set up custom Galaxy server if needed
    RUN mkdir -p ~/.ansible && \
        echo "[galaxy]" > ~/.ansible/galaxy.yml && \
        echo "server_list = automation_hub, galaxy" >> ~/.ansible/galaxy.yml

# Commands to run after Galaxy collection installation

# Use for post-Galaxy cleanup or verification

  append_galaxy: |
    # Verify collections were installed correctly
    RUN ansible-galaxy collection list

# Commands to run before final image preparation

# Use for final dependency installations

  prepend_final: |
    # Install additional runtime dependencies
    RUN pip install --no-cache-dir pytest coverage

# Commands to run after final image preparation

# Use for cleanup operations and final preparations

  append_final: |
    # Clean up package caches to reduce image size
    USER root
    RUN microdnf clean all && \
        rm -rf /var/cache/{dnf,yum} && \
        rm -rf /etc/ansible/ansible.cfg
    # Verify installations
    RUN pip check || echo "Some packages have issues, but continuing anyway"
    # Set final runtime user (good practice for security)
    USER 1001
