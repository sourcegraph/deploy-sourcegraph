This kustomization injects a fsGroup security context in each pod so that the volumes are mounted with the
specified supplemental group id and non-root pod users can write to the mounted volumes.

This is only done once at cluster creation time so this overlay is only referenced by the `create-new-cluster.sh`
script.

The reason for this approach is the behavior of fsGroup: on every mount it recursively chmod/chown the disk to add
the group specified by fsGroup and to change permissions to 775 (so group can write). This can take a long time for
large disks and sometimes times out the whole pod scheduling.

If we only do it at cluster creation time (when the disks are empty) it is fast and since the disks are persistent
volumes we know that the pod user can write to it even without the fsGroup and subsequent apply operations.

In Kubernetes 1.18 fsGroup gets an additional [feature](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#configure-volume-permission-and-ownership-change-policy-for-pods)
called `fsGroupChangePolicy` that will allow us to control the chmod/chown better. 
