import * as k8s from "@kubernetes/client-node";
import { readFileSync } from "fs";
import * as _ from 'lodash';
import * as path from "path";
import * as YAML from "yaml";
import {
  platform,
  ingress,
  setNamespace,
  normalize,
  overlay,
  Config,
  removeComponent,
} from "../../common";


export const configuration = async (): Promise<Config> => ({
  sourceDirectory: '../base',
  outputDirectory: './examples/complex/rendered' ,
  additionalManifestDirectories: ['./examples/complex/include'],
  filenameMapper: customFilenameMapper,
  transformations: [
    platform("gcp", (storageClass: k8s.V1StorageClass) => {
      // Make optional customizations to the storage class here
    }),
    ingress({ ingressType: 'NodePort'}),
    
    removeComponent('sourcegraph', 'StorageClass'),

    setNamespace('*', '*', 'sourcegraph', {
      omit: [
        ['cadvisor', 'PodSecurityPolicy'],
        ['cadvisor', 'ClusterRoleBinding'],
        ['cadvisor', 'ClusterRole'],
        ['prometheus', 'ClusterRoleBinding'],
        ['prometheus', 'ClusterRole'],
      ]
    }),
    
    overlay('codeintel-db', {
      service: {
        metadata: { labels: { deploy: 'sourcegraph-db'}},
      },
      deployment: {
        metadata: { labels: { deploy: 'sourcegraph-db' } },
        spec: { 
          template: {
            spec: {
              volumes: [
                {
                  name: 'pgsql-conf',
                  configMap: {
                    defaultMode: 511,
                  }
                }
              ]
            },
            metadata: {
              labels: {
                deploy: 'sourcegraph-db'
              }
            }
          }
        },
      },
      persistentVolumeClaim: {
        metadata: { labels: { deploy: 'sourcegraph-db' } },
        spec: {
          storageClassName: 'sourcegraph-storage-class',
        }
      },
    }),
    overlay('codeintel-db-conf', {
      configMap: {
        metadata: {
          labels: {
            deploy: 'sourcegraph-db'
          }
        }
      },
    }),
    
    overlay('codeinsights-db', {
      service: {
        metadata: { labels: { deploy: 'sourcegraph-db'}},
      },
      deployment: {
        metadata: { labels: { deploy: 'sourcegraph-db' } },
        spec: {
          template: {
            metadata: { labels: { deploy: 'sourcegraph-db'} },
            spec: {
              containers: [
                {
                  name: 'timescaledb',
                  resources: {
                    requests: {
                      cpu: '1'
                    }
                  }
                }
              ],
              volumes: [
                {
                  name: 'timescaledb-conf',
                  configMap: { defaultMode: 0o777 },
                }
              ],
            }
          },
        },
      },
      persistentVolumeClaim: {
        metadata: { labels: { deploy: 'sourcegraph-db' } },
        spec: {
          storageClassName: 'sourcegraph-storage-class',
        }
      },
    }),
    overlay('codeinsights-db-conf', {
      configMap: { 
        metadata: { labels: { deploy: 'sourcegraph-db' } },
      },
    }),
    
    
    overlay('minio', {
      persistentVolumeClaim: { spec: { storageClassName: 'sourcegraph-storage-class' } },
    }),
    
    overlay('pgsql', {
      service: {
        metadata: { labels: { deploy: 'sourcegraph-db'}},
      },
      deployment: {
        metadata: { labels: { deploy: 'sourcegraph-db' } },
        spec: { 
          template: {
            metadata: {
              labels: {
                deploy: 'sourcegraph-db'
              }
            },
            spec: {
              volumes: [
                {
                  name: 'pgsql-conf',
                  configMap: {
                    defaultMode: 511,
                  }
                }
              ]
            }
          }
        },  
      },
      persistentVolumeClaim: {
        metadata: { labels: { deploy: 'sourcegraph-db' } },
        spec: {
          storageClassName: 'sourcegraph-storage-class',
          resources: {
            requests: {
              storage: '250Gi',
            }
          }
        }
      }
    }),
    
    overlay('pgsql-conf', {
      configMap: {
        metadata: { labels: { deploy: 'sourcegraph-db' }},
        data: {
          'postgresql.conf': readFileSync('./examples/complex/data/postgresql.conf').toString(),
        }
      }
    }),
    
    overlay('prometheus', {
      deployment: {
        spec: {
          template: {
            spec: {
              volumes: [
                {
                  name: 'config',
                  configMap: {
                    defaultMode: 511,
                  }
                }
              ]
            }
          }
        }
      },
      persistentVolumeClaim: {
        spec: {
          storageClassName: 'sourcegraph-storage-class',
          resources: {requests: {storage: '50Gi'} },
        }
      },
    }),
    
    overlay('redis-cache', { persistentVolumeClaim: { spec: {storageClassName: 'sourcegraph-storage-class'}}}),
    overlay('redis-store', { persistentVolumeClaim: { spec: {storageClassName: 'sourcegraph-storage-class'}}}),
    overlay('sourcegraph-frontend', {
      ingress: {
        metadata: {
          annotations: {
            'nginx.ingress.kubernetes.io/affinity': 'cookie',
            'nginx.ingress.kubernetes.io/affinity-mode': 'persistent',
          }
        },
        spec: {
          rules: [
            {
              host: 'sourcegraph.canaveral-beta.us-west-2.aws',
              http: {
                paths: [
                  {
                    pathType: 'ImplementationSpecific'
                  }
                ]
              }
            }
          ],
          tls: [
            {
              hosts: ['sourcegraph.canaveral-beta.us-west-2.aws'],
              secretName: 'sourcegraph-tls',
            }
          ]
        }
      },
      deployment: {
        spec: {
          template: {
            spec: {
              containers: [
                {
                  name: 'frontend',
                  env: [
                    {
                      name: 'SRC_GIT_SERVERS',
                      value: 'gitserver-0.gitserver:3178 gitserver-1.gitserver:3178',
                    },
                  ]
                }
              ]
            }
          }
        }
      }
    }),
    overlay('gitserver', {
      statefulSet: {
        spec: {
          replicas: 2,
          template: {
            spec: {
              containers: [
                {
                  name: 'gitserver',
                  env: [{ name: 'SRC_ENABLE_GC_AUTO', value: 'false' }],
                  resources: {
                    requests: { memory: '4G' },
                    limits: { cpu: '8', memory: '8G' },
                  }                  
                }
              ],
            },
          },
          volumeClaimTemplates: [
            {
              metadata: {
                name: 'repos',
              },
              spec: {
                resources: {
                  requests: {
                    storage: '1Ti',
                  }
                },
                storageClassName: 'sourcegraph-storage-class'
              }
            }
          ],
        },
      }
    }, { service: ['spec.clusterIP'] }),
    overlay('searcher', {
      deployment: {
        spec: {
          replicas: 1,
          template: {
            spec: {
              containers: [
                {
                  name: 'searcher',
                  resources: {
                    limits: { memory: '4G' },
                    requests: { memory: '1G' },
                  }
                }
              ]
            }
          }
        },
      },
    }),
    overlay('symbols', {
      deployment: {
        spec: {
          template: {
            spec: {
              containers: [
                {
                  name: 'symbols',
                  resources: {
                    limits: {
                      cpu: '4',
                      'ephemeral-storage': '10G',
                      memory: '4G',
                    },
                    requests: {
                      cpu: '1',
                      memory: '1G',
                    }
                  }
                }
              ]
            }
          }
        }
      }
    }),

    overlay('indexed-search-indexer', {}, { service: ['spec.clusterIP'] }),
    overlay('indexed-search', {
      statefulSet: {
        spec: {
          replicas: 2,
          template: {
            spec: {
              containers: [
                {
                  name: 'zoekt-webserver',
                  resources: {
                    limits: {
                      memory: '16G'
                    },
                    requests: {
                      cpu: '1',
                      memory: '16G'
                    }
                  }
                },
                {
                  name: 'zoekt-indexserver',
                  resources: {
                    limits: {
                      cpu: '4',
                      memory: '16G',
                    },
                    requests: {
                      memory: '8G'
                    }
                  }
                }
              ],
            },
          },
          volumeClaimTemplates: [
            {
              metadata: {name: 'data'},
              spec: {storageClassName: 'sourcegraph-storage-class', resources: {requests: {storage: '100Gi'}}},
            }
          ]
        }
      }
    }, { service: ['spec.clusterIP'], statefulSet: ['spec.volumeClaimTemplates[0].metadata.labels'] }),

    overlay('grafana', {
      statefulSet: {
        spec: {
          template: {
            spec: {
              volumes: [
                {
                  name: 'config',
                  configMap: {
                    defaultMode: 511,
                  }
                }
              ]
            }
          },
          volumeClaimTemplates: [
            {
              metadata: { name: 'grafana-data' },
              spec: {
                resources: {
                  requests: {storage: '10Gi' },
                },
                storageClassName: 'sourcegraph-storage-class'
              }
            }
          ]
        }
      }
    }),
    
    normalize(),
  ]
})



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