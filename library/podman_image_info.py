#!/usr/bin/python

# Copyright: (c) 2023, Your Name <your.email@example.com>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: podman_image_info
short_description: Gather information about Podman images
description:
    - Gather information about Podman images.
    - Lists images and their attributes.
options:
    name:
        description:
            - Filter by image name.
        type: str
        required: false
    tag:
        description:
            - Filter by image tag.
        type: str
        required: false
author:
    - "Your Name (@yourGitHubHandle)"
'''

EXAMPLES = r'''
- name: Get info about all images
  podman_image_info:
  register: image_info

- name: Get info about a specific image
  podman_image_info:
    name: registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel8
  register: specific_image_info
'''

RETURN = r'''
images:
    description: List of image dictionaries
    returned: always
    type: list
    elements: dict
    contains:
        id:
            description: Image ID
            type: str
            sample: "sha256:f9a9f253f6798722d9e692c2b1429aa1"
        names:
            description: Image names and tags
            type: list
            sample: ["registry.redhat.io/ansible-automation-platform-25/ee-minimal-rhel8:latest"]
        created:
            description: When the image was created
            type: str
            sample: "2023-04-20T10:15:30Z"
        size:
            description: Image size in bytes
            type: int
            sample: 358974135
'''

import json
import re
import subprocess

from ansible.module_utils.basic import AnsibleModule


def run_command(module, command):
    """Run a Podman command and return the output."""
    try:
        result = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
            universal_newlines=True
        )
        if result.returncode != 0:
            module.fail_json(
                msg="Failed to execute command",
                command=command,
                stdout=result.stdout,
                stderr=result.stderr,
                rc=result.returncode
            )
        return result.stdout
    except Exception as e:
        module.fail_json(msg=f"Command execution error: {e}", command=command)


def get_image_info(module, name=None, tag=None):
    """Get image information using podman images."""
    command = ["podman", "images", "--format", "json"]
    
    if name:
        command.append(name)
        if tag:
            command[-1] = f"{name}:{tag}"
    
    output = run_command(module, command)
    
    try:
        return json.loads(output)
    except json.JSONDecodeError:
        module.fail_json(msg="Failed to parse podman images output", output=output)


def main():
    """Main module function."""
    module_args = {
        'name': {'type': 'str', 'required': False},
        'tag': {'type': 'str', 'required': False}
    }
    
    result = {'changed': False}
    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)
    
    # In check mode, return empty list
    if module.check_mode:
        result['images'] = []
        module.exit_json(**result)
    
    name = module.params['name']
    tag = module.params['tag']
    
    result['images'] = get_image_info(module, name, tag)
    module.exit_json(**result)


if __name__ == '__main__':
    main()
