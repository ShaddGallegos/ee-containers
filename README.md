# EE-Containers

A streamlined approach to building Ansible Execution Environments (EEs) with minimal effort. This repository automates the process of building EEs for different scenarios and platforms.

## Overview

This repository includes predefined execution environment configurations for both RHEL 8 and RHEL 9. The playbook automatically detects environments using naming conventions with `-de-` (Development Environment) or `-ee-` (Execution Environment) in the environments folder.

## Prerequisites

- Red Hat subscription
- Red Hat CDN username and password
- Tokens from:
  - [Automation Hub](https://console.redhat.com/ansible/automation-hub/token)
  - [Ansible Galaxy](https://galaxy.ansible.com/ui/token) (optional)
- Installed packages:
  - ansible-core
  - python3-pip
  - podman
  - git
  - ansible-builder

## Required Files for Each Environment

Each environment in the environments directory must include:

1. `execution-environment.yml` - The main configuration file
2. Any dependency files referenced in the execution-environment.yml:
   - requirements.txt - Python package requirements
   - requirements.yml - Ansible collection requirements
   - `bindep.txt` - Binary dependencies

## Running the Playbook

Execute the playbook with:

```bash
ansible-playbook Ansible_Automation_Platform-ee_builder.yml
```

Open a terminal and watch your build progress:

```bash
watch -n .5 podman images
```

You can select multiple environments, comma-separated from the menu that appears during execution.

After you run this once, all of the examples and base images are local in the work directory, so you don't need a connection other than for UBI updates for your image.

## Playbook Overview

This playbook automates the process of building Ansible execution environment (EE) containers using `ansible-builder`. It handles:

1. **Environment Preparation**: Sets up build directories and dependencies
2. **Configuration Validation**: Checks and fixes common issues in configuration files
3. **Build Process**: Runs ansible-builder with appropriate options
4. **Error Handling**: Provides helpful messages when builds fail

### Task Explanations

1. **Environment Validation**: Verifies execution environment files exist and are properly formatted
2. **Registry Authentication**: Logs in to Red Hat and other container registries using provided credentials
3. **Dependency Management**: Installs Python packages and Ansible collections required for building
4. **Container Image Management**: Pulls required base images from registries and manages local images
5. **Environment Selection**: Presents a menu of available environments and processes user selections
6. **Configuration Cleanup**: Automatically fixes common issues in configuration files:
   - Corrects deprecated property names (prepend → prepend_builder, append → append_builder)
   - Updates package references for RHEL 9 compatibility (python39- → python3-)
   - Removes problematic collection references (ansible.builtin)
   - Replaces deprecated collections (infra.ansible → infra.ee_utilities + infra.aap_utilities)
7. **Resource Cleanup**: Removes existing containers and images related to the current build
8. **Container Building**: Runs ansible-builder with appropriate options to build the container image
9. **Build Verification**: Confirms successful image creation and provides detailed build output
10. **Error Handling**: Provides clear error messages and continues processing multiple environments

## Environment Examples

This repository includes examples from:
- [https://github.com/nickarellano/ee-containers](https://github.com/nickarellano/ee-containers)
- [https://github.com/cloin/ee-builds](https://github.com/cloin/ee-builds)

## Troubleshooting

If builds fail, check:
1. Registry authentication - ensure your Red Hat credentials are correct
2. Internet connectivity - verify you can reach required registries
3. Base image availability - confirm you have access to the required base images
4. Build logs - review the detailed output for specific errors

To clean up failed builds:
```bash
podman image prune -f
```

## Contributing

To add new execution environments:
1. Create a new directory under environments with a descriptive name
2. Add the required files (execution-environment.yml, requirements.txt, requirements.yml, and bindep.txt.)
3. Test your environment with the playbook Ansible_Automation_Platform-ee_builder.yml
