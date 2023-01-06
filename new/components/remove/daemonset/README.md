# delete daemonset

A component to delete all daemonsets and its related resources:

- cadvisor
- node-exporter
- otel-agent

# WARNING

Cannot be used with the [delete-cadvisor component](./delete-cadvisor/README.md), or you will see an error about not being able to find the cadvisor to delete. This is because the daemonset has already been deleted by the delete-cadvisor component.
