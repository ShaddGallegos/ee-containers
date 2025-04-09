# README.md - Ansible Execution Environment Builder

This README provides an overview of the Ansible Execution Environment Builder toolset contained in this repository. This automation enables the creation and management of custom execution environments for use with Ansible Automation Platform.

## Overview

The site.yml playbook provides an interactive framework for building, managing, and monitoring custom Ansible execution environments based on Red Hat AAP base images. It simplifies the process of creating and managing execution environments for various use cases.

## Features

- **Interactive Selection**: Choose RHEL 8, RHEL 9, or both distributions for your execution environments
- **Multi-Environment Building**: Select and build multiple environments in a single run
- **Real-time Monitoring**: Visualize build progress through an interactive tmux-based dashboard
- **Custom Environments**: Support for specialized environments including:
  - Terraform integration
  - ServiceNow integration
  - Cloud platform integrations
- **Credential Management**: Secure handling of registry credentials for Red Hat repositories
- **Error Recovery**: Automatic fixes for common build issues
- **Dynamic Display**: Responsive monitoring interface that scales to terminal dimensions

## Requirements

- Red Hat Enterprise Linux 8 or 9
- Podman container runtime
- Ansible 2.15+
- ansible-builder 3.0+
- tmux (for monitoring interface)
- Red Hat subscription for accessing base images

## Usage

### Basic Build Process

```bash
ansible-playbook site.yml
```

This will:

1. Prompt for Red Hat credentials if needed
2. Ask you to select RHEL 8, RHEL 9, or both distributions
3. Display available environments you can build
4. Launch a monitoring dashboard
5. Build selected environments
6. Display build results

### Monitoring Dashboard

The monitoring dashboard has three sections:

- **Top Pane**: ASCII art header with logo and title
- **Middle Pane**: Single-line status indicator showing current build progress
- **Bottom Pane**: Live updating container image list

### Command-line Options

```bash
# Build specific environments
ansible-playbook site.yml -e "selected_environments=['rhel8-ee-minimal-terraform']"

# Force rebuild of environments that already exist
ansible-playbook site.yml -e "force_rebuild=true"

# Run specific playbook sections using tags
ansible-playbook site.yml --tags init       # Initial setup
ansible-playbook site.yml --tags creds      # Update credentials
ansible-playbook site.yml --tags monitoring # Launch monitoring only
ansible-playbook site.yml --tags cleanup    # Clean up containers and images
```

## Environment Types

### Standard Environments

- `rhel8-ee-minimal`: Basic EE with minimal packages
- `rhel8-ee-supported`: Full-featured EE with additional dependencies
- `rhel9-ee-minimal`: RHEL 9 version of the minimal EE
- `rhel9-ee-supported`: RHEL 9 version of the supported EE

### Specialized Environments

- **Terraform**: `rhel8-ee-minimal-terraform` - Includes Terraform binary, terraform-inventory, and Python terraform libraries
- **ServiceNow**: `rhel8-ee-supported-servicenow` - Includes ServiceNow API client libraries
- **Cloud Platforms**: Specialized environments for AWS, Azure, and GCP integrations

## Troubleshooting

### Common Issues

1. **Build failures related to package managers**:
   - The tool automatically detects and adapts to available package managers (dnf, microdnf, yum)
   - Custom assemble scripts handle package installation issues

2. **Container storage issues**:
   - Run `podman system reset` to clear storage problems
   - Check available disk space with `df -h /var`

3. **Python dependency conflicts**:
   - The tool removes problematic dependencies like `--exclude systemd-python`
   - Installs critical packages directly in assemble scripts

### Logs

- Build logs are displayed in the monitoring interface
- Full logs are stored in current_env during the build process

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
