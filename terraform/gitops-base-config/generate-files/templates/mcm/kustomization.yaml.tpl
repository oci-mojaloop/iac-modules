apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - vault-rbac.yaml
  - vault-agent.yaml
configMapGenerator:
  - name: vault-agent
    files:
      - config.hcl=configmaps/vault-config-configmap.hcl
      - config-init.hcl=configmaps/vault-config-init-configmap.hcl
generatorOptions:
  disableNameSuffixHash: true
helmCharts:
- name: connection-manager
  releaseName: mcm
  version: ${mcm_chart_version}
  repo: ${mcm_chart_repo}
  valuesFile: values-mcm.yaml
  namespace: ${mcm_namespace}