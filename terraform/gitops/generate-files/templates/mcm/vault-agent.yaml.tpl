apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: create-update-istio-crs
  namespace: ${istio_external_gateway_namespace}
rules:
  - apiGroups: ["networking.istio.io"]
    resources: ["serviceentries", "destinationrules"]
    verbs: ["*"]
  - apiGroups: ["security.istio.io"]
    resources: ["authorizationpolicies"]
    verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
# This role binding allows "jane" to read pods in the "default" namespace.
# You need to already have a Role named "pod-reader" in that namespace.
kind: RoleBinding
metadata:
  name: create-update-istio-crs-binding
  namespace: ${istio_external_gateway_namespace}
subjects:
- kind: ServiceAccount
  name: ${mcm_service_account_name}
  namespace: ${mcm_namespace}
roleRef:
  kind: Role
  name: create-update-istio-crs
  apiGroup: rbac.authorization.k8s.io
---
%{ if !istio_create_ingress_gateways ~}
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: ${nginx_external_namespace}
  name: nginx-ext-cm-all
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["configmaps"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
# This role binding allows "jane" to read pods in the "default" namespace.
# You need to already have a Role named "pod-reader" in that namespace.
kind: RoleBinding
metadata:
  name: nginx-ext-cm-all-binding
  namespace: ${nginx_external_namespace}
subjects:
- kind: ServiceAccount
  name: ${mcm_service_account_name}
  namespace: ${mcm_namespace}
roleRef:
  kind: Role
  name: nginx-ext-cm-all
  apiGroup: rbac.authorization.k8s.io
%{ endif ~}