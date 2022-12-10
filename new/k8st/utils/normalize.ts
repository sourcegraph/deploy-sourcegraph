import * as YAML from "yaml";
import { readdirSync, readFile, writeFile } from "fs";
import * as path from "path";
import mkdirp = require("mkdirp");

export const normalizeOptions: YAML.DocumentOptions & YAML.SchemaOptions & YAML.ParseOptions & YAML.CreateNodeOptions & YAML.ToStringOptions = {
    sortMapEntries: true,
    lineWidth: 100,
    indent: 2,
    indentSeq: false,
    minContentWidth: 0,
    blockQuote: 'literal',
    // defaultKeyType: 'PLAIN',
    // defaultStringType: 'BLOCK_LITERAL',
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
                    YAML.stringify(YAML.parse(contents.toString()), normalizeOptions),
                    {},
                    err => err ? reject(err) : resolve()
                ))
            }
        } else {
            return normalizeYAMLRecursive(path.join(root, entry.name), outRoot && path.join(outRoot, entry.name))
        }
    })
}
