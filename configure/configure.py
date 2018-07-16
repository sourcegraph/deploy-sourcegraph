#!/usr/bin/env python

import hashlib
import os
from ruamel.yaml import YAML


def main():
    yaml = YAML()

    with open("../base/config-file.ConfigMap.yaml", "r+") as baseconfig:

        configmap = yaml.load(baseconfig.read())
        config = configmap["data"]["config.json"]
        hasher = hashlib.md5(config.encode("utf-8"))
        hashedname = "config-file-" + hasher.hexdigest()[:10]

        configmap["metadata"]["name"] = hashedname

        baseconfig.seek(0)
        yaml.dump(configmap, baseconfig)
        baseconfig.truncate()

        # for root, _, files in os.walk("../base"):
        #     # print((root, dirs, files))
        #     for file in files:
        #         with open(os.path.join(root, file), "w") as f:
        #             y = yaml.load(f.read())
        #             modified = False
        #             for cm in find("configMap", y):
        #                 name = cm["name"]
        #                 if name.startswith("config-file"):
        #                     modified = True
        #                     cm["name"] = hashedname
        #             if modified:
        #                 yaml.dump(y, f)

    # document = """
    # a: 1
    # b:
    #     c: 3
    #     d: 4
    # """
    # print(yaml.dump(yaml.load(document)))
    # asdfadsf


def find(target, thing):
    if isinstance(thing, dict):
        for key in thing:
            if key == target:
                yield thing
            yield from find(target, thing[key])


if __name__ == "__main__":
    main()
