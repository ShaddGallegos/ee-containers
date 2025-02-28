# EE-Containers

Building EEs the easy way. If you clone this repo, by default, the definitions to update base EEs for RHEL 8 and RHEL 9 are included. If you add EE or DE definitions using the naming convention with a `-de-` or `-ee-` in it, in the environments folder, it will appear in the dynamic build menu.

## Task: Prompt User for Environment Selection

```plaintext
TASK [Prompt user for environment selection] *********************************************************************************************************************
task path: /home/sgallego/ee-containers/Ansible_Automation_Platform-ee_builder.yml:427
[Prompt user for environment selection]
Enter numbers for environments to build (comma-separated, max 8):
1. rhel8-de-minimal
2. rhel8-de-supported
3. rhel8-ee-minimal
4. rhel9-de-minimal
5. rhel9-de-minimal-cloudstrike
6. rhel9-de-supported
7. rhel9-ee-minimal
8. rhel9-ee-supported
```

You can copy the environment and create a definition for your vendor (EXAMPLE: Cloudstrike).

## Running the Playbook

Run the playbook with the following command:
```bash
ansible-playbook Ansible_Automation_Platform-ee_builder.yml
```

You can select multiple environments, comma-separated:
```plaintext
1,2,3,4,5,6,7,8
```

And poof, you have the latest and greatest based on the definitions provided.

After you run this once, all of the examples and base images are local, so you don't need a connection other than for UBI updates to your image.

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
