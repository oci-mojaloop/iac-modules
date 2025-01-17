apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - vault-secret.yaml
  - keycloak-realm-cr.yaml
  - istio-gateway.yaml
  - vault-secret.yaml
  - vault-certificate.yaml
helmCharts:
- name: mojaloop-payment-manager
  releaseName: ${pm4ml_release_name}
  version: ${pm4ml_chart_version}
  repo: ${pm4ml_chart_repo}
  valuesFile: values-pm4ml.yaml
  namespace: ${pm4ml_namespace}