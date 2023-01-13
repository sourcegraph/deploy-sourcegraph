#!/bin/bash
resourceList=$(cat) # read the `kind: ResourceList` from stdin
gitserver=$(echo "$resourceList" | sed -n 's/.*gitserver: \([0-9]*\).*/\1/p' | head -n 1)
indexer=$(echo "$resourceList" | sed -n 's/.*indexer: \([0-9]*\).*/\1/p' | head -n 1)
searcher=$(echo "$resourceList" | sed -n 's/.*searcher: \([0-9]*\).*/\1/p' | head -n 1)
symbols=$(echo "$resourceList" | sed -n 's/.*symbols: \([0-9]*\).*/\1/p' | head -n 1)
SRC_GIT_SERVERS=$(for i in $(seq 0 $(expr $gitserver - 1)); do echo -n "gitserver-$i.gitserver:3178 "; done)
INDEXED_SEARCH_SERVERS=$(for i in $(seq 0 $(expr $indexer - 1)); do echo -n "indexed-search-$i.indexed-search:6070 "; done)
SEARCHER_URL=$(for i in $(seq 0 $(expr $searcher - 1)); do echo -n "searcher-$i.searcher:3180 "; done)
SYMBOLS_URL=$(for i in $(seq 0 $(expr $symbols - 1)); do echo -n "symbols-$i.symbols:3184 "; done)

echo "
kind: ResourceList
items:
- kind: ConfigMap
  apiVersion: v1
  metadata:
    name: sourcegraph-endpoints-map
  labels:
    deploy: sourcegraph
    app.kubernetes.io/component: sourcegraph-frontend
  data:
    SRC_GIT_SERVERS: $SRC_GIT_SERVERS
    SEARCHER_URL: $SEARCHER_URL
    SYMBOLS_URL: $SYMBOLS_URL
    INDEXED_SEARCH_SERVERS: $INDEXED_SEARCH_SERVERS
"
