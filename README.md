# EE-Containers

                                                                                     ..:-=*##*=-:..              
                                                                                   .*%@@@@@@@@@@@@%*.            
                                                                                .:#@@@@@@@@@@@@@@@@@@#:.         
                                                                               .*@@@@@@@@@@*-@@@@@@@@@@*.        
                                                                              .#@@@@@@@@@@*. =@@@@@@@@@@#.       
                                                                             .%@@@@@@@@@@@ .# +@@@@@@@@@@%.      
                                                                             -%@@@@@@@@@@..#%-.*@@@@@@@@@%-      
    "A Streamlined Approach to Building Ansible Execution Environments"     .+@@@@@@@@@@= =@@@.:#@@@@@@@@@+.     
                                                                            .+@@@@@@@@@# ..:+@%.-@@@@@@@@@+.     
                                                                            .=@@@@@@@@@ .@@+. *+.-@@@@@@@%=      
                                                                             .%@@@@@@@:.*@@@@%.  .+@@@@@@%.      
                                                                              .@@@@@@= =@@@@@@@%=.:%@@@@@.       
                                                                               :%@@@@@@@@@@@@@@@@@@@@@@%:        
                                                                                .*@@@@@@@@@@@@@@@@@@@@*.         
                                                                                  .+@@@@@@@@@@@@@@@@+..          
                                                                                    ..+*%@@@@@@%*+..              

A streamlined approach to building Ansible Execution Environments (EEs) with minimal effort. This repository automates the process of building EEs for different scenarios and platforms.

## Current Direct/Active Contributors

- Shadd Gallegos (<Shadd@redhat.com>)
- Alexon Oliveira
- Brady Thompson
- Christopher Norville
- Faith Chua
- Juan Madina
- Mark Lowcher

## Overview

This repository includes predefined execution environment configurations for both RHEL 8 and RHEL 9. The playbook automatically detects environments using naming conventions with `-de-` (Development Environment) or `-ee-` (Execution Environment) in the `environments` folder.
It is a wrapper for Ansible-Builder that automates the manual parts and makes life a little easier.

## Prerequisites

### Required Accounts and Tokens

- Red Hat Subscription
- Red Hat CDN username and password
- Authentication tokens from:
  - [Automation Hub](https://console.redhat.com/ansible/automation-hub/token)
  - [Ansible Galaxy](https://galaxy.ansible.com/ui/token) (optional)
- Note: reccomend adding your CDN username password and tokens to your ansible.cfg and templates/ansible.cfg.j2 and using ansible vault to encrypt so you dont have to add the info each time.

### Required Packages on your Development Node/Machine/Workstation/Dev-Container

#### Needs to be pre installed

- ansible-core

#### Installed by the Ansible_Automation_Platform-ee_builder.yml

- python3-pip
- ansible-builder
- git
- podman
- podman-docker
- tmux
- xdg-utils
- yum-utils

## Required Files for Each Environment

Each environment in the `environments` directory must include:

1. `execution-environment.yml` - The main configuration file
2. Any dependency files referenced in the execution-environment.yml:
   - `requirements.txt` - Python package requirements
   - `requirements.yml` - Ansible collection requirements
   - `bindep.txt` - Binary dependencies

## Current Working EE/DE Definitions

### Environment Selection

## RHEL 8 Environments

 rhel8-de-minimal-general
 rhel8-de-supported
 rhel8-ee-minimal
 rhel8-ee-minimal-terraform

## RHEL 9 Environments

 rhel9-de-minimal-cloudstrike
 rhel9-de-supported
 rhel9-ee-minimal
 rhel9-ee-minimal-vmware
 rhel9-ee-minimal-windows

## Running the Playbook

### Basic Execution

Run the playbook with:

```
sudo ansible-playbook Ansible_Automation_Platform-ee_builder.yml -K
```

### Build Monitoring

The playbook automatically creates a tmux session to monitor build progress. You can:

1. View the monitoring session with:

   ```

   tmux attach -t podman-monitor

   ```

    tmux attach -t podman-monitor  /tmp/podman-monitor.sh

   ```

2. Alternative monitoring method:

   ```

    /tmp/podman-monitor.sh

   ```
### Registry Authentication Issues

If experiencing registry connection issues, ensure:

- Your Red Hat credentials are correct
- Your system can resolve and connect to registry.redhat.io
 
This playbook automates the process of building Ansible execution environment (EE) containers using `ansible-builder`. It handles:

1. **Environment Preparation**: Sets up build directories and dependencies
2. **Configuration Validation**: Checks and fixes common issues in configuration files
3. **Build Process**: Runs ansible-builder with appropriate options
4. **Error Handling**: Provides helpful messages when builds fail

After first run, all examples of definitions are cloned and stored at "examples/",
the base images are stored localy

- "registry.redhat.io/ansible-automation-platform-25/de-minimal-rhel8"
- "registry.redhat.io/ansible-automation-platform-25/de-minimal-rhel9"
- "registry.redhat.io/ansible-automation-platform-25/de-supported-rhel8"
- "registry.redhat.io/ansible-automation-platform-25/de-supported-rhel9"
- "registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel8"
- "registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel9"
- "registry.redhat.io/ansible-automation-platform-25/ee-supported-rhel8"
- "registry.redhat.io/ansible-automation-platform-25/ee-supported-rhel9"

so you don't need a connection other than for UBI updates for your image builds.
