#!/usr/bin/env bash

OUTPUT_FOLDER=generated-cluster-base
NAMESPACE=default

setup_base() {
  kubectl apply -f sourcegraph.StorageClass.yaml

  /bin/cat <<EOM >deploy_sourcegraph_git_ssh_config
Host *
  StrictHostKeyChecking no
EOM

  kubectl create secret -n ${NAMESPACE} generic gitserver-ssh --from-literal=rsa=supersecret --from-literal=config=topsecret
}

deploy_base() {
  mkdir $OUTPUT_FOLDER
  CLEANUP="rm -rf ${OUTPUT_FOLDER}; $CLEANUP"
  cp -r ${DEPLOY_SOURCEGRAPH_ROOT}/base ${CURRENT_DIR}/${OUTPUT_FOLDER}

  GS=${CURRENT_DIR}/${OUTPUT_FOLDER}/base/gitserver/gitserver.StatefulSet.yaml
  cat $GS | yj | jq '.spec.template.spec.containers[].volumeMounts += [{mountPath: "/home/sourcegraph/.ssh", name: "ssh"}]' | jy -o $GS
  cat $GS | yj | jq '.spec.template.spec.volumes += [{name: "ssh", secret: {defaultMode: 384, secretName:"gitserver-ssh"}}]' | jy -o $GS

  kubectl -n ${NAMESPACE} apply -f ${CURRENT_DIR}/${OUTPUT_FOLDER} --recursive

  # wait for it all to finish (we list out the ones with persistent volume claim because they take longer)

  timeout 10m kubectl -n ${NAMESPACE} rollout status -w statefulset/indexed-search
  timeout 10m kubectl -n ${NAMESPACE} rollout status -w deployment/prometheus
  timeout 10m kubectl -n ${NAMESPACE} rollout status -w deployment/redis-cache
  timeout 10m kubectl -n ${NAMESPACE} rollout status -w deployment/redis-store
  timeout 10m kubectl -n ${NAMESPACE} rollout status -w statefulset/gitserver
  timeout 10m kubectl -n ${NAMESPACE} rollout status -w deployment/sourcegraph-frontend
}

cleanup_base() {
  kubectl delete -n ${NAMESPACE} -f ${CURRENT_DIR}/${OUTPUT_FOLDER} --recursive

  kubectl delete -f sourcegraph.StorageClass.yaml

  kubectl delete secret -n ${NAMESPACE} gitserver-ssh
}
