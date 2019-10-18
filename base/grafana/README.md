# Grafana

[Grafana](https://https://grafana.com/) is an open-source analytics dashboard application.

A Grafana instance is part of the default Sourcegraph cluster installation.

## Namespaces

If you are deploying Sourcegraph to a non-default namespace, you'll have to change the namespace specified in
 [grafana.ClusterRoleBinding.yaml](grafana.ClusterRoleBinding.yaml) to the one that you created.

## Docker image

We are running our own image of Grafana which contains a standard Grafana installation packaged together with provisioned dashboards.
For details see [Grafana Docker Image](https://github.com/sourcegraph/sourcegraph/blob/master/docker-images/grafana/README.md)

## Exposing Grafana directly

In the frontend Grafana is accessed from behind a reverse proxy. Grafana is not fully integrated with our CSRF protection so there is a known issue: when the Grafana
web app in the browser makes POST or PUT requests Sourcegraph's CSRF protection gets triggered and responds with a "invalid CSRF token" 403 response.
We are working to solve [this issue](https://github.com/sourcegraph/sourcegraph/issues/6075). 

As a workaround you can expose Grafana directly using kubectl port-forwarding

```shell script
kubectl port-forward svc/grafana 3370:30070
``` 

and use `http://localhost:3370/-/debug/grafana` to get to the "Home Dashboard". From there you can add, modify and delete dashboards and panels.

> Note: Our Grafana instance runs in anonymous mode with all authentication turned off. Please be careful when exposing it directly.



