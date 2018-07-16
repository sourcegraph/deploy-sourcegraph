#!/usr/bin/env python

import hashlib
import os
from ruamel.yaml import YAML


def configureGitserver():
    gitserver = input("How many gitserver replicas? [1]")
    if not gitserver:
        gitserver = 1

    for i in range(1, gitserver):
        print(i)
    return


def configureConfigMap():
    yaml = YAML()
    yaml.preserve_quotes = True

    with open("../base/config-file.ConfigMap.yaml", "r+") as baseconfig:

        configmap = yaml.load(baseconfig.read())
        config = configmap["data"]["config.json"]
        hasher = hashlib.md5(config.encode("utf-8"))
        hashedname = "config-file-" + hasher.hexdigest()[:10]

        configmap["metadata"]["name"] = hashedname

        baseconfig.seek(0)
        yaml.dump(configmap, baseconfig)
        baseconfig.truncate()

        for root, _, files in os.walk("../base"):
            for file in files:
                if not file.endswith(".yaml"):
                    continue
                with open(os.path.join(root, file), "r+") as f:
                    y = yaml.load(f.read())
                    modified = False
                    for cm in find("configMap", y):
                        name = cm["name"]
                        if name.startswith("config-file"):
                            modified = True
                            cm["name"] = hashedname
                    if modified:
                        print("updated config-file in " + file)
                        f.seek(0)
                        yaml.dump(y, f)
                        f.truncate()


def find(target, thing):
    if isinstance(thing, dict):
        for key in thing:
            if key == target:
                yield thing[target]
            yield from find(target, thing[key])
    elif isinstance(thing, list):
        for entry in thing:
            yield from find(target, entry)


if __name__ == "__main__":
    configureGitserver()
    # configureConfigMap()
