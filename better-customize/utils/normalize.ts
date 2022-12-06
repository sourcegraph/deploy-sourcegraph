import * as YAML from "yaml";
import { readdirSync, readFile, writeFile } from "fs";
import * as path from "path";
import mkdirp = require("mkdirp");

export const normalizeOptions = {
    sortMapEntries: true,
    lineWidth: 0,
}

export async function normalizeYAMLRecursive(root: string, outRoot?: string) {
    const contents = readdirSync(root, { withFileTypes: true })
    contents.map(async entry => {
        if (entry.isFile()) {
            const filename = path.join(root, entry.name)
            const outFilename = path.join(outRoot || root, entry.name)
            if (entry.name.endsWith(".yaml")) {
                const contents = await new Promise<Buffer>((resolve, reject) => readFile(filename, {}, (err, data) => err ? reject(err) : resolve(data)))
                await mkdirp(path.dirname(outFilename))
                await new Promise<void>((resolve, reject) => writeFile(
                    outFilename,
                    YAML.stringify(YAML.parse(contents.toString()), { sortMapEntries: true, lineWidth: 0 }),
                    {},
                    err => err ? reject(err) : resolve()
                ))
            }
        } else {
            return normalizeYAMLRecursive(path.join(root, entry.name), outRoot && path.join(outRoot, entry.name))
        }
    })
}