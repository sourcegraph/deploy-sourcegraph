def rbacAPI:
    .apiVersion and 
    (.apiVersion | contains("rbac.authorization.k8s.io"));

def rbacKind:
    .kind as $k 
    | ["Role", "RoleBinding", "ClusterRole", "ClusterRoleBinding", "ServiceAccount"]
    | index($k);

def isRBAC: 
    rbacAPI or rbacKind;

def hasLabel: 
    if . | isRBAC then
        .metadata.labels.category == "rbac" 
    else
        true
    end;

. | all(hasLabel)
