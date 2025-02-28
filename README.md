# EE-Containers

A streamlined approach to building Ansible Execution Environments (EEs) with minimal effort. This repository automates the process of building EEs for different scenarios and platforms.

## Overview

This repository includes predefined execution environment configurations for both RHEL 8 and RHEL 9. The playbook automatically detects environments using naming conventions with `-de-` (Development Environment) or `-ee-` (Execution Environment) in the `environments` folder.

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

## Required Files for Each Environment

Each environment in the `environments` directory must include:

1. `execution-environment.yml` - The main configuration file
2. Any dependency files referenced in the execution-environment.yml:
   - `requirements.txt` - Python package requirements
   - `requirements.yml` - Ansible collection requirements
   - `bindep.txt` - Binary dependencies

## Running the Playbook

Execute the playbook with:
ansible-playbook Ansible_Automation_Platform-ee_builder.yml

open a terminal and watch your build progress 
watch -n .5 podman images

You can select multiple environments, comma-separated: 
1,2,3,4,5,6,7,8

And poof, you have the latest and greatest based on the definitions provided.

After you run this once, all of the examples and base images are local in "scripts/", so you don't need a connection other than for UBI updates for your image.

## Playbook Overview

This playbook automates the process of building an Ansible execution environment (EE) container using `ansible-builder`. It prompts the user to enter their Red Hat CDN username and password, logs in to the registry, checks for the existence of `requirements.txt` and `requirements.yaml` files, installs Python requirements if they exist, selects an environment from a list, builds the image using `ansible-builder`, tags the image with a new name, and shows the build output.

### Pre-requisites

To run this playbook, you need to have `ansible-core` and `python3-pip` installed on your system. You also need to have a GitHub repository named "ee-containers" cloned to your system.

### Task Explanations

1. **Verify internet connection**: This task checks if the system has an active internet connection by pinging Google. If the ping fails, the playbook fails and displays an error message.
2. **Ensure python3-pip and ansible-core are installed via dnf**: This task installs `python3-pip` and `ansible-core` using the `dnf` package manager.
3. **Clone GitHub repository**: This task clones the "ee-containers" repository from GitHub to the `/tmp` directory.
4. **Login to registry.redhat.io**: This task logs in to the Red Hat registry using the provided username and password.
5. **Check if requirements.txt exists**: This task checks if the `requirements.txt` file exists in the cloned repository.
6. **Install Python requirements from requirements.txt if exists**: This task installs Python requirements listed in the `requirements.txt` file using `pip3`.
7. **Check if requirements.yaml exists**: This task checks if the `requirements.yaml` file exists in the cloned repository.
8. **Ensure ansible-galaxy collections in requirements.yaml are installed**: This task installs Ansible collections listed in the `requirements.yaml` file using `ansible-galaxy`.
9. **List available environments**: This task lists all available environments in the cloned repository.
10. **Select an environment**: This task prompts the user to select an environment from the list of available environments.
     - Environments pulled from:
       - [https://github.com/nickarellano/ee-containers](https://github.com/nickarellano/ee-containers)
       - [https://github.com/cloin/ee-builds](https://github.com/cloin/ee-builds)
11. **Set selected environment**: This task sets the selected environment and its base name based on the user's input.
12. **Build image using ansible-builder based on user's selection**: This task builds the Ansible execution environment image using `ansible-builder` and the selected environment's `execution-environment.yaml` file.
13. **Tag the image with the new name**: This task tags the newly built image with a new name based on the selected environment's base name.
14. **Show build output**: This task displays the build output to the user.
