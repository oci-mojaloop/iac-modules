---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: pm4ml-vs
spec:
  gateways:
%{ if pm4ml_wildcard_gateway == "external" ~} 
  - ${istio_external_gateway_namespace}/${istio_external_wildcard_gateway_name}
%{ else ~}
  - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name}
%{ endif ~}
  hosts:
  - '${pm4ml_public_fqdn}'
  http:
    - name: "api"
      match:
        - uri: 
            prefix: /api
      route:
        - destination:
            host: mcm-connection-manager-api
            port:
              number: 3001
    - name: "ui"
      match:
        - uri: 
            prefix: /
      route:
        - destination:
            host: mcm-connection-manager-ui
            port:
              number: 8080
%{ if pm4ml_wildcard_gateway == "external" ~} 
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: pm4ml-jwt
  namespace: ${istio_external_gateway_namespace}
spec:
  selector:
    matchLabels:
      app: ${istio_external_gateway_name}
  action: DENY
  rules:
    - to:
        - operation:
            paths: ["/api/*"]
      from:
        - source:
            notRequestPrincipals: ["https://${keycloak_fqdn}/realms/${keycloak_pm4ml_realm_name}/*"]
      when:
        - key: connection.sni
          values: ["${pm4ml_public_fqdn}", "${pm4ml_public_fqdn}:*"]
---
apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
  name: keycloak-${keycloak_pm4ml_realm_name}-jwt
  namespace: ${istio_external_gateway_namespace}
spec:
  selector:
    matchLabels:
      istio: ${istio_external_gateway_name}
  jwtRules:
  - issuer: "https://${keycloak_fqdn}/realms/${keycloak_pm4ml_realm_name}"
    jwksUri: "https://${keycloak_fqdn}/realms/${keycloak_pm4ml_realm_name}/protocol/openid-connect/certs"
    fromHeaders:
      - name: Authorization
        prefix: "Bearer "
      - name: Cookie
        prefix: "MCM_SESSION"
%{ endif ~}