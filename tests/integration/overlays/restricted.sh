#!/usr/bin/env bash

OUTPUT_FOLDER=generated-cluster-restricted
NAMESPACE=ns-sourcegraph

setup_restricted() {
  kubectl apply -f sourcegraph.StorageClass.yaml

  kubectl apply -f nonroot-policy.yaml

  kubectl create namespace ${NAMESPACE}

  kubectl create serviceaccount -n ${NAMESPACE} fake-user

  kubectl create rolebinding -n ${NAMESPACE} fake-admin --clusterrole=admin --serviceaccount=${NAMESPACE}:fake-user

  # Kubernetes < 1.16 change to '--resource=podsecuritypolicies.extensions'
  kubectl create role -n ${NAMESPACE} nonroot:unprivileged --verb=use --resource=podsecuritypolicies.extensions --resource-name=nonroot-policy

  kubectl create rolebinding -n ${NAMESPACE} fake-user:nonroot:unprivileged --role=nonroot:unprivileged --serviceaccount=${NAMESPACE}:fake-user

  /bin/cat <<EOM >deploy_sourcegraph_git_ssh_config
Host *
  StrictHostKeyChecking no
EOM

  kubectl create secret -n ${NAMESPACE} generic gitserver-ssh --from-literal=rsa=supersecret --from-literal=config=topsecret
}

deploy_restricted() {
  mkdir $OUTPUT_FOLDER
  CLEANUP="rm -rf ${OUTPUT_FOLDER}; $CLEANUP"
  "${DEPLOY_SOURCEGRAPH_ROOT}"/overlay-generate-cluster.sh non-privileged-create-cluster ${CURRENT_DIR}/${OUTPUT_FOLDER}

  GS=${CURRENT_DIR}/${OUTPUT_FOLDER}/apps_v1_statefulset_gitserver.yaml
  cat $GS | yj | jq '.spec.template.spec.containers[].volumeMounts += [{mountPath: "/home/sourcegraph/.ssh", name: "ssh"}]' | jy -o $GS
  cat $GS | yj | jq '.spec.template.spec.volumes += [{name: "ssh", secret: {defaultMode: 384, secretName:"gitserver-ssh"}}]' | jy -o $GS

  kubectl --as=system:serviceaccount:${NAMESPACE}:fake-user -n ${NAMESPACE} apply -f ${CURRENT_DIR}/${OUTPUT_FOLDER} --recursive

  # kubectl -n ${NAMESPACE} expose deployment sourcegraph-frontend --type=NodePort --name sourcegraph --type=LoadBalancer --port=3080 --target-port=3080

  # wait for it all to finish (we list out the ones with persistent volume claim because they take longer)

  timeout 10m kubectl -n ${NAMESPACE} rollout status -w statefulset/indexed-search
  timeout 10m kubectl -n ${NAMESPACE} rollout status -w deployment/prometheus
  timeout 10m kubectl -n ${NAMESPACE} rollout status -w deployment/redis-cache
  timeout 10m kubectl -n ${NAMESPACE} rollout status -w deployment/redis-store
  timeout 10m kubectl -n ${NAMESPACE} rollout status -w statefulset/gitserver
  timeout 10m kubectl -n ${NAMESPACE} rollout status -w deployment/sourcegraph-frontend
}

cleanup_restricted() {
  kubectl delete -f sourcegraph.StorageClass.yaml

  kubectl delete -f nonroot-policy.yaml

  kubectl delete namespace ${NAMESPACE}
}
