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
  - ansible-builder

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

Open a terminal and watch your build progress:
watch -n .5 podman images

You can select multiple environments, comma-separated:

And poof, you have the latest and greatest based on the definitions provided.

After you run this once, all of the examples and base images are local in "scripts/", so you don't need a connection other than for UBI updates for your image.

## Playbook Overview

This playbook automates the process of building an Ansible execution environment (EE) container using `ansible-builder`. It handles:

1. **Environment Preparation**: Sets up build directories and dependencies
2. **Configuration Validation**: Checks and fixes common issues in configuration files
3. **Build Process**: Runs ansible-builder with appropriate options
4. **Error Handling**: Provides helpful messages when builds fail

### Task Explanations

1. **Verify internet connection**: Checks if the system has an active internet connection by pinging Google.
2. **Ensure python3-pip and ansible-core are installed**: Installs required packages using dnf.
3. **Clone GitHub repository**: Clones the "ee-containers" repository to the `/tmp` directory.
4. **Login to registry.redhat.io**: Logs in to the Red Hat registry using provided credentials.
5. **Check if requirements.txt exists**: Verifies the existence of Python requirements.
6. **Install Python requirements**: Installs packages from requirements.txt using pip3.
7. **Check if requirements.yml exists**: Verifies the existence of Ansible collections.
8. **Install Ansible collections**: Installs collections from requirements.yml.
9. **List available environments**: Shows environments available for building.
10. **Environment selection**: Prompts user to select which environments to build.
     - Environments pulled from: the `environments` directory.       - [https://github.com/nickarellano/ee-containers](https://github.com/nickarellano/ee-containers)
       - [https://github.com/cloin/ee-builds](https://github.com/cloin/ee-builds)rellano/ee-containers)
11. **Set selected environment**: This task sets the selected environment and its base name based on the user's input.
12. **Build image using ansible-builder based on user's selection**: This task builds the Ansible execution environment image using `ansible-builder` and the selected environment's `execution-environment.yaml` file.
13. **Tag the image with the new name**: This task tags the newly built image with a new name based on the selected environment's base name.-builder` and the selected environment's `execution-environment.yaml` file.
14. **Show build output**: This task displays the build output to the user.ge with a new name based on the selected environment's base name.
15. **Show build output**: This task displays the build output to the user.
