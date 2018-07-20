#!/usr/bin/env python3

"""This program updates params.go to reflect the running versions on dogfood"""

import os
import re
import subprocess

def main():
    images = get_image_tags()
    if 'docker.sourcegraph.com/bitbucket-server' not in images:
        print('WARNING: bitbucket-server image is not present. Please ensure your kctx is pointing to dogfood')

    for dirpath, _, filenames in os.walk('base'):
        replace_image_tags(dirpath, filenames, images)

    for dirpath, _, filenames in os.walk('configure'):
        replace_image_tags(dirpath, filenames, images)

def get_image_tags():
    out = subprocess.check_output(['kubectl', 'get', 'deploy', '--no-headers', '-o=custom-columns=image:.spec.template.spec.containers[].image'])
    d = {}
    for line in out.decode('utf-8').splitlines():
        image = line.strip()
        if ':' not in image:
            continue
        name, tag = image.split(':', 1)
        if name in d and d[name] != tag:
            print('WARNING: {} is deployed with tag {} and {}'.format(name, tag, d[name]))
            if tag < d[name]:  # Prefer "newer" tag to be deterministic
                continue
        d[name] = tag
    return d

def replace_image_tags(dirpath, filenames, images):
    for filename in filenames:
        if not filename.endswith('.Deployment.yaml'):
            continue
            
        file = os.path.join(dirpath, filename)
        with open(file, 'r') as f:
            contents = f.read()
        
        for image, tag in images.items():
            contents = re.sub(image+':.*', image+':'+tag, contents)
            
        with open(file, 'w') as f:
            f.write(contents)

if __name__ == '__main__':
    main()
