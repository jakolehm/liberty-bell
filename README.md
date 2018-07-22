# Liberty Bell - Kubernetes Token Authenticator

![liberty-bell](https://bpsh2.hs.llnwd.net/e1/contenthub-cdn-origin/media/casinoeuro/casinoeuro_blog/liberty_bell_slot_600.jpg)

Liberty Bell implements a [Kubernetes Webhook Token Authenticator](https://kubernetes.io/docs/admin/authentication/#webhook-token-authentication) for authenticating users using [GitHub](https://github.com) or [Gitlab](https://gitlab.com) Personal Access Tokens. Authenticator also configures groups of authenticated user appropriately. This allows cluster administrator to setup RBAC rules based on membership in groups.

## Usage

You can deploy the `liberty-bell` using [the example DaemonSet manifest](https://github.com/jakolehm/liberty-bell/blob/master/manifests/daemonset.yaml). It is recommended to run the authenticator on your Kubernetes master using host networking so that the apiserver can access the authenticator through the loopback interface.

```
kubectl create -f https://raw.githubusercontent.com/jakolehm/liberty-bell/master/manifests/daemonset.yaml
```

Next, you need to configure Kubernetes apiserver to verify bearer token using `liberty-bell`. 

See [Kubernetes](https://kubernetes.io/docs/admin/authentication/#webhook-token-authentication) documentation how to pass configuration for apiserver.

If you are using [Kontena Pharos](https://kontena.io/pharos), configuration can be passed via [cluster.yml](https://pharos.sh/docs/usage/#webhook-token-authentication)

### Github Configuration

```yaml
---
kind: Config
apiVersion: v1
clusters:
- name: liberty-bell
  cluster:
    server: http://localhost:9393/github
users:
- name: kube-apiserver
  user: {}
contexts:
- name: webhook
  context:
    cluster: liberty-bell
    user: kube-apiserver
current-context: webhook
```

#### Group Mapping

Kubernetes groups are constructed as `<organization>/<team>`. For example if Github user belongs to `testers` team at `acme` organization then group name would be `acme/testers` in Kubernetes.


### Gitlab Configuration

```yaml
---
kind: Config
apiVersion: v1
clusters:
- name: liberty-bell
  cluster:
    server: http://localhost:9393/gitlab
users:
- name: kube-apiserver
  user: {}
contexts:
- name: webhook
  context:
    cluster: liberty-bell
    user: kube-apiserver
current-context: webhook
```

#### Group Mapping

Kubernetes groups are constructed as `<group>/<subgroup>`.

## Using with RBAC

### Grant permissions for a user

```
kubectl create namespace project1
kubectl create rolebinding johndoe-admin-binding --clusterrole=clusteradmin --user=johndoe --namespace=project1
```

### Grant permissions for a group

```
kubectl create namespace project1
kubectl create rolebinding testers-admin-binding --clusterrole=clusteradmin --group=acme/testers --namespace=project1
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jakolehm/liberty-bell
