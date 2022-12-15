# delete daemonset

A component to delete all daemonset.

# WARNING

Please leave the `- patches/cadvisor.yaml` **commented** if you are also using the [delete-cadvisor component](./delete-cadvisor/README.md), or you will see an error about not being able to find the cadvisor to delete. This is because the daemonset has already been deleted by the delete-cadvisor component.

Uncomment the line about `"- patches/cadvisor.yaml"` to remove cadvisor daemonset only if you are **not** using the [delete-cadvisor component](./delete-cadvisor/README.md).