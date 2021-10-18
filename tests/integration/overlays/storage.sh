#!/usr/bin/env bash

OUTPUT_FOLDER=generated-cluster-storage
NAMESPACE=default

setup_storage () {
  cat sourcegraph.StorageClass.yaml | yj | jq '.metadata.name = "new-storageclass"' | jy -o new-storageclass.StorageClass.yaml
  kubectl apply -f new-storageclass.StorageClass.yaml

  PVC=${DEPLOY_SOURCEGRAPH_ROOT}/overlays/storageclass/replace-storageclass-name-pvc.yaml
  cat $PVC| yj | jq '.[].value = "new-storageclass"' | jy -o $PVC
  PVC=${DEPLOY_SOURCEGRAPH_ROOT}/overlays/storageclass/replace-storageclass-name-sts.yaml
  cat $PVC| yj | jq '.[].value = "new-storageclass"' | jy -o $PVC

  /bin/cat <<EOM >deploy_sourcegraph_git_ssh_config
Host *
  StrictHostKeyChecking no
EOM

  kubectl create secret -n ${NAMESPACE} generic gitserver-ssh --from-literal=rsa=supersecret --from-literal=config=topsecret
}

deploy_storage () {
  mkdir $OUTPUT_FOLDER
  CLEANUP="rm -rf ${OUTPUT_FOLDER}; $CLEANUP"
  "${DEPLOY_SOURCEGRAPH_ROOT}"/overlay-generate-cluster.sh storageclass ${CURRENT_DIR}/${OUTPUT_FOLDER}

  GS=${CURRENT_DIR}/${OUTPUT_FOLDER}/apps_v1_statefulset_gitserver.yaml
  cat $GS | yj | jq '.spec.template.spec.containers[].volumeMounts += [{mountPath: "/home/sourcegraph/.ssh", name: "ssh"}]' | jy -o $GS
  cat $GS | yj | jq '.spec.template.spec.volumes += [{name: "ssh", secret: {defaultMode: 384, secretName:"gitserver-ssh"}}]' | jy -o $GS

  kubectl -n ${NAMESPACE} apply -f ${CURRENT_DIR}/${OUTPUT_FOLDER} --recursive

  # kubectl -n ${NAMESPACE} expose deployment sourcegraph-frontend --type=NodePort --name sourcegraph --type=LoadBalancer --port=3080 --target-port=3080

  # wait for it all to finish (we list out the ones with persistent volume claim because they take longer)

  timeout 10m kubectl -n ${NAMESPACE} rollout status -w statefulset/indexed-search
  timeout 10m kubectl -n ${NAMESPACE} rollout status -w deployment/prometheus
  timeout 10m kubectl -n ${NAMESPACE} rollout status -w deployment/redis-cache
  timeout 10m kubectl -n ${NAMESPACE} rollout status -w deployment/redis-store
  timeout 10m kubectl -n ${NAMESPACE} rollout status -w statefulset/gitserver
  timeout 10m kubectl -n ${NAMESPACE} rollout status -w deployment/sourcegraph-frontend

  # TODO: Verify that the correct storageclass is being used
}

cleanup_storage() {
  kubectl delete -n ${NAMESPACE} -f ${CURRENT_DIR}/${OUTPUT_FOLDER} --recursive

  kubectl delete -f new-storageclass.StorageClass.yaml

  kubectl delete secret -n ${NAMESPACE} gitserver-ssh
}
