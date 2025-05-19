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