#!/usr/bin/env python3

"""This program updates params.go to reflect the running versions on dogfood"""

__author__ = "Keegan Carruthers-Smith <keegan@sourcegraph.com"
__credits__ = ["Beyang Liu <beyang@sourcegraph.com>"]

import os
import re
import subprocess

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

def main(params_path):
    with open(params_path) as fd:
        content = fd.read()
    images = get_image_tags()

    if 'docker.sourcegraph.com/dogfood-bot' not in images:
        print('WARNING: dogfood-bot image is not present. Please ensure your kctx is pointing to dogfood')
    for name, tag in images.items():
        content = re.sub(r'image\: ({})\:([A-Za-z0-9\-\._]+)'.format(name), r'image: \1:{}'.format(tag), content)
    with open(params_path, 'w') as fd:
        fd.write(content)

if __name__ == '__main__':
    dir_path = os.path.dirname(os.path.realpath(__file__))
    main(os.path.join(dir_path, 'values.yaml'))
