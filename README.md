# Ansible Execution Environment Builder

A streamlined approach to building Ansible Execution Environments using Red Hat base images.

![AAP Execution Environment Builder](https://example.com/ee-containers-logo.png)

## Overview

This project automates the creation of custom Ansible Execution Environments based on Red Hat Ansible Automation Platform base images. It provides a guided, interactive process for selecting and building execution environments with detailed progress monitoring and validation.

## Features

- **Interactive Environment Selection**: Choose RHEL 8, RHEL 9, or both distributions
- **Live Build Monitoring**: Real-time progress through tmux display with status indicators
- **Registry Authentication**: Automated login to Red Hat registries  
- **Credential Management**: Securely store and reuse Red Hat credentials
- **Build Validation**: Pre-validates YAML syntax to avoid build failures
- **Detailed Summary**: Comprehensive build results with success/failure reporting

## Prerequisites

- Red Hat subscription with access to Ansible Automation Platform
- Podman installed and configured
- Python 3.6+
- Ansible Core 2.15+
- ansible-builder 3.0+
- tmux

## Required Packages

```

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/ee-containers.git
cd ee-containers
```

### 2. Run the playbook

```bash
ansible-playbook site.yml
```

### 3. View build progress

Once the playbook starts, it will create a tmux monitoring session. it should pop up "auto-magicly" or You can view it by:

```bash
tmux attach -t podman-monitor
```

## How It Works

1. **Credential Setup**: First run will prompt for Red Hat CDN username/password
2. **Environment Selection**: Choose which execution environments to build
3. **Build Process**: The playbook:
   - Pulls required base images
   - Validates environment configurations
   - Builds custom execution environments
   - Tracks build status in real-time
4. **Results Summary**: Displays successful and failed builds

## Environment Structure

Each execution environment is defined in its own directory under environments, containing:

- `execution-environment.yml`: Main configuration file
- Additional requirements files (optional):
  - `requirements.txt`: Python package requirements
  - `requirements.yml`: Collection requirements
  - `bindep.txt`: System dependencies

## Available Environments

The playbook includes configurations for:

- RHEL 8 minimal execution environments
- RHEL 8 supported execution environments
- RHEL 9 minimal execution environments
- RHEL 9 supported execution environments
- Various specialized environments (Cloud, Windows, VMware, etc.)

## Monitoring Display

The build monitoring display shows:

- ASCII art header
- Current build status with progress spinner
- List of available container images

## Troubleshooting

### Key tags to add strategically throughout the playbook

#### Core functionality tags

- setup       # Initial setup tasks
- creds       # Credential management
- images      # Image building tasks
- monitoring  # Terminal monitoring tasks
- cleanup     # Cleanup tasks
- report      # Summary reporting

#### Process stage tags

- init        # Initialization tasks
- selection   # Environment selection tasks
- build       # Build processing
- post_build  # Post-build actions

#### Specialized operation tags

- always      # Tasks that should always run
- validation  # Validation checks
- pull        # Registry authentication and image pulling
- security    # Security-related tasks

### Common Issues

- **Registry Authentication Failures**: Verify your Red Hat credentials
- **Missing Base Images**: Ensure internet connectivity to Red Hat registries
- **YAML Validation Errors**: Check syntax in your execution-environment.yml files
- **DNF/Package Manager Errors**: Some base images use microdnf instead of dnf

### Logs

- Build logs are displayed in the console output
- Monitoring logs: `/tmp/monitor.log`

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Red Hat Ansible Automation Platform team
- Ansible Builder project
