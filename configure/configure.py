#!/usr/bin/env python

import hashlib
import os
from ruamel.yaml import YAML
import glob


def configureSSD():
    ssdpath = input("Path to local ssd?")
    if not ssdpath:
        print("Not using SSDs")
        return

    # 1. Copy pod-tmp-gc template files to output
    # 2. Attach volume to necessary deployments


def configureDefaultStorageClass():
    storageclass = input("Name of default storage class?")
    if not storageclass:
        print("Using default storage class")
        return

    yaml = YAML()
    yaml.preserve_quotes = True

    for pvc in glob.glob("../base/**/*.PersistentVolumeClaim.yaml"):
        with open(pvc, "r+") as f:
            data = yaml.load(f.read())
            data["spec"]["storageClassName"] = storageclass

            f.seek(0)
            yaml.dump(data, f)
            f.truncate()


def configureGitserver():
    gitserver = input("How many gitserver replicas? [1] ")
    if not gitserver:
        gitserver = 1

    bases = [
        "../base/gitserver/gitserver-1.Deployment.yaml",
        "../base/gitserver/gitserver-1.PersistentVolumeClaim.yaml",
        "../base/gitserver/gitserver-1.Service.yaml",
    ]

    original = {}
    for base in bases:
        with open(base, "r") as b:
            original[base] = b.read()

    # gitservers = ["gitserver-" + str(i + 1) for i]
    for i in range(1, int(gitserver)):
        newgitserver = "gitserver-" + str(i + 1)
        # gitservers.append(newgitserver)
        print("configuring " + newgitserver)
        for path, contents in original.items():
            newpath = path.replace("gitserver-1", newgitserver)
            newcontents = contents.replace("gitserver-1", newgitserver)
            with open(newpath, "w") as newfile:
                newfile.write(newcontents)

    yaml = YAML()
    yaml.preserve_quotes = True

    # Update SRC_GIT_SERVERS, use value from config map?
    for root, _, files in os.walk("../base"):
        for file in files:
            if not file.endswith(".yaml"):
                continue
            with open(os.path.join(root, file), "r+") as f:
                y = yaml.load(f.read())
                modified = False
                for cm in find("name", y):
                    name = cm["name"]
                    if name == "SRC_GIT_SERVERS":
                        template = cm["value"]
                        gitservers = [
                            template.replace("gitserver-1", "gitserver-" + str(i + 1))
                            for i in range(0, int(gitserver))
                        ]
                        newvalue = " ".join(gitservers)
                        if not newvalue == cm["value"]:
                            cm["value"] = newvalue
                            modified = True
                if modified:
                    print("updated SRC_GIT_SERVERS in " + file)
                    f.seek(0)
                    yaml.dump(y, f)
                    f.truncate()


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
                        name = cm["configMap"]["name"]
                        if name.startswith("config-file"):
                            modified = True
                            cm["configMap"]["name"] = hashedname
                    if modified:
                        print("updated config-file in " + file)
                        f.seek(0)
                        yaml.dump(y, f)
                        f.truncate()


def find(target, thing):
    if isinstance(thing, dict):
        for key in thing:
            if key == target:
                yield thing
            yield from find(target, thing[key])
    elif isinstance(thing, list):
        for entry in thing:
            yield from find(target, entry)


if __name__ == "__main__":
    # configureDefaultStorageClass()
    configureGitserver()
    # configureConfigMap()
