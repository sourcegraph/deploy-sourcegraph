# Troubleshooting

If Sourcegraph does not start up or shows unexpected behavior, there are a variety of ways you can determine the root
cause of the failure. The most useful commands are:

*   `kubectl get pods -o=wide` — lists all pods in your cluster and the corresponding health status of each.
*   `kubectl logs -f $POD_NAME` — tails the logs for the specified pod.

If Sourcegraph is unavailable and the `sourcegraph-frontend-*` pod(s) are not in status `Running`, then view their logs with `kubectl logs -f sourcegraph-frontend-$POD_ID` (filling in `$POD_ID` from the `kubectl get pods` output). Inspect both the log messages printed at startup (at the beginning of the log output) and recent log messages.


Less frequently used commands:

*   `kubectl describe $POD_NAME` — shows detailed info about the status of a single pod.
*   `kubectl get pvc` — lists all Persistent Volume Claims (PVCs) and the status of each.
*   `kubectl get pv` — lists all Persistent Volumes (PVs) that have been provisioned. In a healthy cluster, there should
    be a one-to-one mapping between PVs and PVCs.
*   `kubectl get events` — lists all events in the cluster's history.
*   `kubectl delete pod $POD_NAME` — delete a failing pod so it gets recreated, possibly on a different node
*   `kubectl drain --force --ignore-daemonsets --delete-local-data $NODE` — remove all pods from a node and mark it as unschedulable to prevent new pods from arriving

### Common errors

*   `kubectl get pv` shows no Persistent Volumes, and/or `kubectl get events` shows a `Failed to provision volume with
    StorageClass "default"` error.

    Check that a storage class named "default" exists via `kubectl get storageclass`. If one does exist, run `kubectl get storageclass default -o=yaml` and verify that the zone indicated in the output matches the zone of your cluster.

*   `Error: release sourcegraph failed: namespaces "default" is forbidden: User "system:serviceaccount:kube-system:default" cannot get namespaces in the namespace "default": Unknown user "system:serviceaccount:kube-system:default"`. Ensure you have created the RBAC resources and helm is using them. A common reason for it to fail is you are already using Helm, so `helm init --service-account tiller` does not work correctly. To fix this for your existing Helm installation, run:

    ```bash
    kubectl apply -f https://about.sourcegraph.com/k8s/rbac-config.yml
    kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
    helm init --service-account tiller --upgrade
    ```

If you have any other issues with installation, email <mailto:support@sourcegraph.com>.
