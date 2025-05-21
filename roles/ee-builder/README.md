# EE-Containers

## "A Streamlined Approach to Building Ansible Execution Environments"

## Disclaimer

This Role was written and tested by me and is meant to show some of the cool things Ansible can do. It is not a product of Ansible, Red Hat, or IBM and is not supported and has no warranty implied or other. The software is opensource and you can download, review, test, and use at your own discretion. Treat this "AS IS" found on the internet. If you have questions please feel free to ping me at <shadd@redhat.com> and I will see if I can assist you.

## Synopsis

EE-Containers is an Ansible role designed to simplify and streamline the creation of Ansible Execution Environments. This script is a helper script for Ansible Builder that provides a robust framework for building, validating, and managing container images that can be used with Ansible Automation Platform. The role handles common pain points like registry authentication, schema validation, and dependency management, allowing users to focus on defining their automation requirements rather than container complexities.

## Requirements

* ansible-core 2.12 or higher
* podman 3.0 or higher
* podman-docker
* ansible-builder 3.0 or higher
* Red Hat registry credentials (for accessing base images)
* Internet connectivity for downloading dependencies
* At least 2GB of free disk space
* Sudo/root privileges for container operations
* tmux (for build monitoring)

## Initial Setup

Before running the playbook, you'll need to set up the project structure:

1. Clone the repository:

   ```bash
   git clone https://github.com/your-org/ee-containers.git
   cd ee-containers
   ```

2. Configure your Red Hat registry credentials:

   ```yaml
   cp templates/config.j2 ~/.ansible/vars/config
      ---
      rh_username: "Red Hat CDN username"
      rh_password: "Red Hat CDN password"
      automation_hub_token: ""
      galaxy_token: ""

   # Edit ~/.ansible/vars/config with your credentials
   ```

3. Run the playbook:

   ```bash
   sudo ansible-playbook ee_builder.yml -K
   ```

4. Select environments to build from the interactive menu.

5. Access the built containers:

   ```bash
   podman images
   ```

## What It Does

The EE-Containers role:

1. Sets up the necessary infrastructure for building Execution Environments
2. Authenticates with container registries
3. Validates and fixes execution-environment.yml schema issues
4. Pulls required base images
5. Builds customized Execution Environments
6. Installs necessary dependencies
7. Creates built container images ready for use with Ansible Automation Platform
8. Provides a flexible, interactive menu for environment selection
9. Cleans up dangling images after building

## Features

* Interactive menu system for environment selection
* Automatic schema validation and fixing
* Registry authentication handling
* Custom assemble script for reliable dependency installation
* Support for both RHEL8 and RHEL9 environments
* Progress reporting and build status
* Error handling and recovery
* Cleanup of dangling images
* Parallel build capabilities

## Creating Custom Definitions

If you want to make your own definitions, create a project folder using this naming convention:
`<OS major version>-<ee or de>-<base image type minimal or supported>-<Vendor or Product>`

For example:

* `rhel9-ee-minimal-aws` for an AWS-focused execution environment
* `rhel8-de-supported-azure` for an Azure decision environment

Definitions Consist oF:

* Project folder structure:

  ```text
  project folder
  ├── bindep.txt
  ├── execution-environment.yml
  ├── requirements.txt
  └── requirements.yml
  ```

## Working Environment Definitions

As of April 14, 2025, the following environment definitions have been tested and confirmed working:

### RHEL8 Environments

* rhel8-de-minimal
* rhel8-de-supported
* rhel8-ee-controller_101
* rhel8-ee-first_playbook
* rhel8-ee-minimal
* rhel8-ee-netbox
* rhel8-ee-network
* rhel8-ee-servicenow

### RHEL9 Environments

* rhel9-de-supported
* rhel9-ee-minimal
* rhel9-ee-minimal-general
* rhel9-ee-minimal-vmware

## Troubleshooting

### Common Issues

1. **Build failures related to package managers**:
   * The tool automatically detects and adapts to available package managers (dnf, microdnf, yum)
   * Custom assemble scripts handle package installation issues

2. **Container storage issues**:
   * Run `podman system reset` to clear storage problems
   * Check available disk space with `df -h /var`

3. **Python dependency conflicts**:
   * The tool removes problematic dependencies like `--exclude systemd-python`
   * Installs critical packages directly in assemble scripts

### Logs

* Build logs are displayed in the monitoring interface
* Full logs are stored in current_env during the build process

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.


# EE Containers - Ansible Execution Environments Builder

## Task Order Reference
- Initialization:
  - Initialize critical variables
- System Setup:
  - Ensure required system packages are installed
  - Ensure required directories exist
- Authentication:
  - Check if credentials file exists
  - Load credentials from file if it exists
  - Prompt for Red Hat CDN username
  - Prompt for Red Hat CDN password
  - Save credentials to file
  - Generate token for Automation Hub
  - Ensure container registry authentication is configured
- Network Validation
- Environment Selection
- Environment Preparation
- Fix and Configure Environments:
  - Create repair script for execution-environment.yml files
  - Run fix script
- Build Monitoring:
  - Launch tmux session for build monitoring
- Build Execution:
  - Check for existing images
  - Run ansible-builder for each environment
- Post-Build Tasks
- Final Cleanup

## Variables Reference

### Initialization
- `playbook_dir`: Current playbook directory path
- `timestamp`: Dynamically generated timestamp
- `user_home`: User's home directory
- `container_registries`: Container registries to authenticate with
- `authfile`: Container registry authentication file
- `working_dir`: Base working directory
- `problematic_collections`: List of problematic collections to exclude
- `rh_username`: Red Hat username from environment variable
- `rh_password`: Red Hat password from environment variable

### System Setup
- Registry configurations
- Base images for EE/DE environments
  - Note: There are typos in image names: "ee-supprted-rhel9" and "de-supprted-rhel9" should be "ee-supported-rhel9" and "de-supported-rhel9"
- Various path configurations

### Authentication
- Red Hat credentials management

### Environment Preparation
- Environment-specific configurations
- Build configurations

### Build Monitoring
- tmux session configurations

### Build Execution
- Template configurations
- Requirements management

## Role Tags
- `setup`: Initial setup tasks
- `dependencies`: Installing required dependencies
- `environment`: Environment configuration tasks
- `authentication`: Registry authentication tasks
- `build`: Core build tasks
- `monitoring`: Build monitoring tasks
- `cleanup`: Cleanup tasks
- `always`: Tasks that always run

## Usage Examples

### Basic Usage
```yaml
- hosts: localhost
  roles:
    - role: ee-builder
```

### Usage with Selected Environment
```yaml
- hosts: localhost
  vars:
    selected_env:
      - rhel9-ee-minimal-general
  roles:
    - role: ee-builder
```

- "ee-supprted-rhel9" should be "ee-supported-rhel9" 
- "de-supprted-rhel9" should be "de-supported-rhel9"

- "ee-supprted-rhel9" should be "ee-supported-rhel9" 
- "de-supprted-rhel9" should be "de-supported-rhel9"

These should also be corrected in your `defaults/main.yml` file.

# Ordered Task List for Reference
task_order:
  - Initialization:
      - Initialize critical variables
  - System Setup:
      - Ensure required system packages are installed
      - Ensure required directories exist
  - Authentication:
      - Check if credentials file exists
      - Load credentials from file if it exists
      - Prompt for Red Hat CDN username
      - Prompt for Red Hat CDN password
      - Save credentials to file
      - Generate token for Automation Hub
      - Ensure container registry authentication is configured
  - Network Validation:
      - (Add tasks here if applicable)
  - Environment Selection:
      - (Add tasks here if applicable)
  - Environment Preparation:
      - (Add tasks here if applicable)
  - Fix and Configure Environments:
      - Create repair script for execution-environment.yml files
      - Run fix script
  - Build Monitoring:
      - Launch tmux session for build monitoring
  - Build Execution:
      - Check for existing images
      - Run ansible-builder for each environment
  - Post-Build Tasks:
      - (Add tasks here if applicable)
  - Final Cleanup:
      - (Add tasks here if applicable)

# Variables Reference
vars_reference:
  Initialization:
    - playbook_dir: "{{ playbook_dir }}" # Current playbook directory path
    - timestamp: "{{ lookup('pipe', 'date +%Y%m%d%H%M%S') }}" # Dynamically generated timestamp
    - user_home: "{{ lookup('env', 'HOME') }}" # User's home directory
    - container_registries: ["registry.redhat.io", "registry.access.redhat.com"] # Container registries to authenticate with
    - authfile: "/etc/containers/auth.json" # Container registry authentication file
    - working_dir: "/tmp/ee-containers" # Base working directory
    - problematic_collections: [] # List of problematic collections to exclude
    - rh_username: "{{ lookup('env', 'RH_USERNAME') }}" # Red Hat username from environment variable
    - rh_password: "{{ lookup('env', 'RH_PASSWORD') }}" # Red Hat password from environment variable
    - paths:
        config: ["~/.ansible/vars", "~/.config/containers", "~/.docker", "/etc/containers"] # Configuration directories
        build: [
          "/tmp/ee-containers", 
          "/tmp/ee-containers/_build", 
          "/tmp/ee-containers/context", 
          "/tmp/ee-containers/environments", 
          "/tmp/ee-containers/collections/ansible_collections", 
          "/tmp/ee-containers/hooks", 
          "/tmp/ee-containers/containerfiles",
          "/tmp/ee-containers/_build/configs", 
          "/tmp/ansible_safe", 
          "/tmp/ee-containers/_build/rpms"
        ] # Build directories

  System Setup:
    - registry:
        redhat:
          url: "registry.redhat.io" # Red Hat registry URL
          auth_file: "/etc/containers/auth.json" # Authentication file for Red Hat registry
        search_paths: ["registry.access.redhat.com", "registry.redhat.io"] # Registry search paths
    - images:
        base:
          # Execution Environments (EE)
          # RHEL 8
          ee-minimal-rhel8: "registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel8:latest" # RHEL 8 minimal EE
          ee-supported-rhel8: "registry.redhat.io/ansible-automation-platform-25/ee-supported-rhel8:latest" # RHEL 8 supported EE
          # RHEL 9
          ee-minimal-rhel9: "registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9:latest" # RHEL 9 minimal EE
          ee-supprted-rhel9: "registry.redhat.io/ansible-automation-platform-25/ee-supported-rhel9:latest" # RHEL 9 supported EE

          # Decision Environments (DE)
          # RHEL 8
          de-minimal-rhel8: "registry.redhat.io/ansible-automation-platform-25/de-minimal-rhel8:latest" # RHEL 8 minimal DE
          de-supported-rhel8: "registry.redhat.io/ansible-automation-platform-25/de-supported-rhel8:latest" # RHEL 8 supported DE
          # RHEL 9
          de-minimal-rhel9: "registry.redhat.io/ansible-automation-platform-25/de-minimal-rhel9:latest" # RHEL 9 minimal DE
          de-supprted-rhel9: "registry.redhat.io/ansible-automation-platform-25/de-supported-rhel9:latest" # RHEL 9 supported DE
        platform_version: "25" # Platform version for compatibility
    - paths:
        base: "/tmp/ee-containers" # Base directory for the role
        scripts: "{{ playbook_dir }}/scripts" # Scripts directory
        tmux:
          header: "/tmp/ee-containers/tmux_header.txt" # Tmux header file
          launcher: "/tmp/ee-containers/tmux_launcher.sh" # Tmux launcher script
          monitor: "/tmp/podman-monitor.sh" # Podman monitor script
        status_file: "/tmp/ee-containers/build_status.txt" # Build status file
        fix_script: "/tmp/ee-containers/fix_ee_files.py" # Fix script for execution environments
        environments: "/tmp/ee-containers/environments" # Environments directory
        containerfiles: "/tmp/ee-containers/containerfiles" # Containerfiles directory
        hooks: "/tmp/ee-containers/hooks" # Hooks directory
        context: "/tmp/ee-containers/context" # Build context directory
        build: "/tmp/ee-containers/context/_build/scripts" # Build scripts directory
        ansible_config: "/tmp/ansible_safe" # Ansible configuration directory
    - dir_paths: # For backwards compatibility
        base: "/tmp/ee-containers" # Base directory
        ansible_config: "/tmp/ansible_safe" # Ansible configuration directory
        hooks: "/tmp/ee-containers/hooks" # Hooks directory
        context: "/tmp/ee-containers/context" # Context directory
        build: "/tmp/ee-containers/context/_build/scripts" # Build scripts directory
        containerfiles: "/tmp/ee-containers/containerfiles" # Containerfiles directory
        environments: "/tmp/ee-containers/environments" # Environments directory

  Authentication:
    - rh_username: "{{ lookup('env', 'RH_USERNAME') }}" # Red Hat username for authentication
    - rh_password: "{{ lookup('env', 'RH_PASSWORD') }}" # Red Hat password for authentication

  Environment Preparation:
    - environment_configs:
        rhel9-ee-minimal-general:
          base_image: "registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9:latest" # RHEL 9 minimal general environment base image
          python_dependencies: "{{ common_python_deps }}" # Common Python dependencies
          system_dependencies: "{{ common_system_deps }}" # Common system dependencies
          galaxy_dependencies: "requirements.yml" # Galaxy dependencies file
          build_steps: "{{ common_build_steps }}" # Common build steps
        rhel8-ee-minimal-network:
          base_image: "registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel8:latest" # RHEL 8 minimal network environment base image
          python_dependencies: "{{ common_python_deps + ['netaddr>=0.8.0', 'jmespath>=1.0.0'] }}" # Python dependencies with network add-ons
          system_dependencies: "{{ common_system_deps }}" # Common system dependencies
          galaxy_dependencies: 
            - "name: ansible.netcommon" # Ansible NetCommon collection
            - "name: cisco.ios" # Cisco IOS collection
          build_steps: "{{ common_build_steps }}" # Common build steps

  Build Monitoring:
    - tmux:
        session_name: "podman_monitor" # Name of the tmux session for monitoring
        header_template: "tmux_header.j2" # Template file for the tmux header
        launcher_template: "tmux_launcher.sh.j2" # Template file for the tmux launcher script
        monitor_script: "build_monitor.sh" # Build monitor script

  Build Execution:
    - templates:
        requirements:
          collections:
            - name: "ansible.utils"
              version: ">=2.0.0" # Ansible Utils collection
            - name: "ansible.posix"
              version: ">=1.5.0" # Ansible Posix collection
            - name: "community.general"
              version: ">=7.0.0" # Community General collection
          python:
            - "pytz" # Python timezone library
            - "ansible-core" # Core Ansible library
            - "ansible-runner"            
            - "setuptools" # Python package management library
            - "wheel" # Python package building library
            - "pip" # Python package installer
        ansible_config:
        execution_environment:
          version: 3 # Execution environment version
          build_args:
            ANSIBLE_GALAXY_CLI_COLLECTION_OPTS: "--ignore-errors --force" # Options for Ansible Galaxy CLI for collections
            ANSIBLE_GALAXY_CLI_ROLE_OPTS: "--ignore-errors" # Options for Ansible Galaxy CLI for roles
        status_header: |
          ╔═══════════════════════════════════════════════════════╗
          ║           ANSIBLE EXECUTION ENVIRONMENT               ║
          ║                    BUILD STATUS                       ║
          ╚═══════════════════════════════════════════════════════╝
          # (ASCII header for build status display)

# Role Tags Reference
tags_reference:
  - setup: Initial setup tasks
  - dependencies: Installing required dependencies
  - environment: Environment configuration tasks
  - authentication: Registry authentication tasks
  - build: Core build tasks
  - monitoring: Build monitoring tasks
  - cleanup: Cleanup tasks
  - always: Tasks that always run

# Usage Examples
usage_examples:
  - name: "Basic Usage"
    example: |
      - hosts: localhost
        roles:
          - role: ee-builder
  
  - name: "With Specific Environment"
    example: |
      - hosts: localhost
        vars:
          selected_env:
            - rhel9-ee-minimal-general
        roles:
          - role: ee-builder

# File Structure
file_structure:
  tasks:
    - "main.yml: Main task file that imports other tasks"
    - "initialize.yml: Variable initialization tasks"
    - "system_setup.yml: System setup and dependency installation"
    - "authentication.yml: Authentication with container registries"
    - "environment_selection.yml: Environment selection tasks"
    - "environment_preparation.yml: Prepare selected environments"
    - "fix_and_configure.yml: Fix and configure environment files"
    - "build_monitoring.yml: Setup build monitoring"
    - "build_execution.yml: Execute the builds"
    - "post_build.yml: Post-build verification and cleanup"
    - "final_cleanup.yml: Final cleanup tasks"
  
  vars:
    - "main.yml: Main variables"
    - "environment-configs.yml: Environment-specific configurations"
  
  templates:
    - "ansible.cfg.j2: Template for ansible.cfg"
    - "tmux_header.j2: Template for tmux header"
    - "tmux_launcher.sh.j2: Template for tmux launcher script"

# Troubleshooting
troubleshooting:
  - issue: "Authentication fails with Red Hat registry"
    solution: |
      1. Verify your credentials are correct
      2. Check if your subscription is active
      3. Make sure /etc/containers/auth.json has correct permissions
  
  - issue: "Build process fails"
    solution: |
      1. Check build logs in the tmux session
      2. Verify all dependencies are installed
      3. Ensure network connectivity to container registries

# Contributors
contributors:
  - Your Name <your.email@example.com>

# Testing Information
testing:
  methods:
    - Tested on RHEL 8 and RHEL 9
    - Tested with both minimal and full environments
  run_tests: |
    To test the role:
    ansible-playbook tests/test.yml -K

# Changelog
changelog:
  - version: "1.0.0"
    date: "2025-05-19"
    changes:
      - Initial release
      - Support for RHEL 8 and 9 environments
      - Integrated tmux monitoring
