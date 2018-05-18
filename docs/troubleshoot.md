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

If you have any other issues with installation, email <mailto:support@sourcegraph.com>.
