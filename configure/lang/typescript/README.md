# lang-typescript

This folder contains the deployment manifests for the [Javascript/Typescript language extension](https://sourcegraph.com/extensions/sourcegraph/typescript). 

## Installation instructions

### Setup TLS/SSL (Highly recommended, optional)

TLS/SSL is required for secure communication with the language server. Once you have completed ["Configure TLS/SSL"](../../../docs/configure.md#configure-tlsssl) in [docs/configure.md](../../../docs/configure.md#configure-tlsssl), for your overall Sourcegraph instance, you'll need to configure TLS/SSL for the Javascript/Typescript language server as well. 

The Javascript/Typescript language server needs it's own domain (e.g. `typescript.sourcegraph.example.com`), and an SSL certificate/key for that domain.

1. Create a [TLS secret](https://kubernetes.io/docs/concepts/configuration/secret/) that contains your TLS certificate and private key for the Javascript/Typescript language server.

   ```bash
   kubectl create secret tls typescript-tls --key $PATH_TO_KEY --cert $PATH_TO_CERT
   ```

   Update [create-new-cluster.sh](../../../create-new-cluster.sh) with the previous command.

   ```bash
   echo kubectl create secret tls typescript-tls --key $PATH_TO_KEY --cert $PATH_TO_CERT >> create-new-cluster.sh
   ```

1. Add the above TLS configuration to [configure/lang/typescript/lang-typescript.Ingress.yaml](lang-typescript.Ingress.yaml), making sure to use the real domain name that you are using for the Javascript/Typescript language server.

    ```yaml
    spec:
        tls:
        - hosts:
        # 🚨 TLS is required for secure communication with the language server. 
        # See the customization guide (../../../docs/configure.md) for information
        # about configuring TLS
        #
        # Make sure to replace 'typescript.sourcegraph.example.com' with the real domain that you are
        # using for the Javascript/Typescript language server.
        - typescript.sourcegraph.example.com
        secretName: typescript-tls
        rules:
        - host: typescript.sourcegraph.example.com
    ```

**WARNING:** Do NOT commit the actual TLS cert and key files to your fork (unless your fork is
private **and** you are okay with storing secrets in it).

### HTTP basic authentication (Highly recommended, optional)

HTTP basic authentication is used to prevent unauthorized access to the language server. At a high level, you'll create a secret then put it in both [configure/lang/typescript/lang-typescript.Ingress.yaml](lang-typescript.Ingress.yaml) and in your Sourcegraph global settings so that logged-in users are authenticated when their browser makes requests to the Javascript/Typescript language server.

**WARNING:** 🚨 If your basic auth credentials are exposed, anyone with that credential now has unauthorized access to the language server and the code it operates on. Using an auth proxy, VPN, or firewall would provide more security. More information about these alternative methods will come at a later date. 🚨

_These instructions are derived from https://kubernetes.github.io/ingress-nginx/examples/auth/basic/_

1. Create an `.htpasswd` file in the current directory with one entry:

    ```console
    > htpasswd -c auth langserveruser 
    New password:
    Re-type new password:
    Adding password for user langserveruser
    ```

    **WARNING:** Do NOT commit the actual `auth` password file to your fork (unless your fork is
    private **and** you are okay with storing secrets in it).

1. Create a secret named `langserver-auth` from the `auth` file that you just created

    ```console
    > kubectl create secret generic langserver-auth --from-file=auth
    secret "basic-auth" created
    ```

   Update [create-new-cluster.sh](../../../create-new-cluster.sh) with the previous command.

   ```console
   echo kubectl create secret generic langserver-auth --from-file=auth >> create-new-cluster.sh
   ```

### Apply the Javascript/Typescript language server configuration to the cluster

1. Add the `kubectl` command that applies the Javascript/Typescript language server configuration to [kubectl-apply-all.sh](../../../kubectl-apply-all.sh)

    ```console
    echo kubectl apply --prune -l deploy=lang-typescript -f configure/lang/typescript --recursive >> kubectl-apply-all.sh
    ```

1. Apply your changes to the cluster

    ```console
    ./kubectl-apply-all.sh
    ```

### Configure Sourcegraph to use the Typescript language server

Add the following fields to your Sourcegraph global settings (`$PASSWORD` is the HTTP basic auth password that you created above, and `$TYPESCRIPT_DOMAIN_NAME` is the domain name that you are using for your Typescript language server instance):

```js
"typescript.serverUrl": "wss://langserveruser:$PASSWORD@$TYPESCRIPT_DOMAIN_NAME/",
"typescript.sourcegraphUrl": "http://sourcegraph-frontend:30080",
```

If you haven't setup SSL/TLS and HTTP basic authentication yet `typescript.serverUrl` should look like this:

```js
"typescript.serverUrl": "ws://$TYPESCRIPT_DOMAIN_NAME"
```

Note that `wss` has been changed to `ws`.

If you choose not to expose the language server to the internet yet, you need to forward a local port to the language server so that your browser can connect to it:

```console
kubectl port-forward svc/lang-typescript 9876:8080
```

Then your `typescript.serverUrl` would look like this:

```js
"typescript.serverUrl": "ws://localhost:9876"
```
