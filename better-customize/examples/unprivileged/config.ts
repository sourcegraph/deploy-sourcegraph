import {
  platform,
  ingress,
  Config,
  setNamespace,
} from "../../common";
import { nonPrivileged } from "../../privilege";
import { readFileSync } from "fs";
import * as path from "path";
import * as YAML from "yaml";

export const configuration: Config = {
  filenameMapper: customFilenameMapper,
  outputDirectory: './examples/unprivileged/rendered',
  transformations: [
    platform("aws"),
    ingress({ ingressType: 'NodePort'}),
    nonPrivileged(),
    setNamespace('*', '*', 'ns-sourcegraph'),
 ],
}

function customFilenameMapper(sourceDir: string, filename: string): string {
  const rel = path.relative(sourceDir, filename);

  const yaml = YAML.parse(readFileSync(filename).toString())
  const dirParts = path.dirname(rel).split(path.sep)
  const baseParts = path.basename(filename).split('.')
  if (baseParts.length < 3) {
    console.log('ERROR: could not transform filename', filename)
    return filename
  }
  let [name, kind, ext] = baseParts
  let prefix = 'apps_v1'

  {
    // Adjustments
    if (dirParts.length > 0) {
      const dirName = dirParts[dirParts.length-1]
      if ([name, 'frontend', 'redis', 'jaeger', '.'].indexOf(dirName) === -1) {
        name = dirName + '-' + name
      }
    }
    const mappings: { [key: string]: string } = {
      'codeinsights-db': 'codeinsights-db-conf', // TODO: only apply this on the configmap change...
      'codeintel-db': 'codeintel-db-conf',
      'pgsql': 'pgsql-conf',
    }
    if (kind.toLowerCase() === 'configmap' && mappings[name]) {
      name = mappings[name]
    }
  }
  
  if (typeof yaml.apiVersion === 'string' || yaml.apiVersion instanceof String) {
    prefix = (yaml.apiVersion as string).replace('/', '_')
  }
  
  if (kind === 'IndexerService' && name === 'indexed-search') {
    return 'v1_service_indexed-search-indexer.yaml'
  }
  
  return prefix + '_' + kind.toLowerCase() + '_' + name.toLowerCase() + '.' + ext
}