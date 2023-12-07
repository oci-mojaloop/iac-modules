---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-ui-vs
spec:
  gateways:
%{ if pm4ml_wildcard_gateway == "external" ~} 
  - ${istio_external_gateway_namespace}/${istio_external_wildcard_gateway_name}
%{ else ~}
  - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name}
%{ endif ~}
  hosts:
  - '${portal_fqdn}'
  http:
    - name: "portal"
      match:
        - uri: 
            prefix: /
      route:
        - destination:
            host: ${pm4ml_release_name}-frontend
            port:
              number: 80
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-experience-vs
spec:
  gateways:
%{ if pm4ml_wildcard_gateway == "external" ~} 
  - ${istio_external_gateway_namespace}/${istio_external_wildcard_gateway_name}
%{ else ~}
  - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name}
%{ endif ~}
  hosts:
  - '${experience_api_fqdn}'
  http:
    - name: "experience-api"
      match:
        - uri: 
            prefix: /
      route:
        - destination:
            host: ${pm4ml_release_name}-experience-api
            port:
              number: 80
          headers:
            response:
              add:
                access-control-allow-origin: "https://${portal_fqdn}"
                access-control-allow-credentials: "true"
%{ if pm4ml_wildcard_gateway == "external" ~} 
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
%{ endif ~}
---
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: ${pm4ml_release_name}-connector-gateway
  annotations: {
    external-dns.alpha.kubernetes.io/target: ${external_load_balancer_dns}
  }
spec:
  selector:
    istio: ${istio_external_gateway_name}
  servers:
  - hosts:
    - '${mojaloop_connnector_fqdn}'
    port:
      name: https-connector
      number: 443
      protocol: HTTPS
    tls:
      credentialName: ${vault_certman_secretname}
      mode: MUTUAL
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-connector-vs
spec:
  gateways:
  - ${pm4ml_release_name}-connector-gateway
  hosts:
  - '${mojaloop_connnector_fqdn}'
  http:
    - name: "mojaloop-connector"
      match:
        - uri: 
            prefix: /
      route:
        - destination:
            host: ${pm4ml_release_name}-sdk-scheme-adapter-api-svc
            port:
              number: 4000
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-test-vs
spec:
  gateways:
    - istio-ingress-int/internal-wildcard-gateway
  hosts:
    - '${test_fqdn}'
  http:
    - name: "sim-backend"
      match:
        - uri:
            prefix: /sim-backend-test(/|$)(.*)
      route:
        - destination:
            host: sim-backend
            port:
              number: 3003
    - name: "mojaloop-core-connector"
      match:
        - uri:
            prefix: /cc-send(/|$)(.*)
      route:
        - destination:
            host: ${pm4ml_release_name}-mojaloop-core-connector
            port:
              number: 3003
    - name: "mlcon-outbound"
      match:
        - uri:
            prefix: /mlcon-outbound(/|$)(.*)
      route:
        - destination:
            host: ${pm4ml_release_name}-sdk-scheme-adapter-api-svc
            port:
              number: 4001
    - name: "mlcon-sdktest"
      match:
        - uri:
            prefix: /mlcon-sdktest(/|$)(.*)
      route:
        - destination:
            host: ${pm4ml_release_name}-sdk-scheme-adapter-api-svc
            port:
              number: 4002
    - name: "mgmt-api"
      match:
        - uri:
            prefix: /mgmt-api(/|$)(.*)
      route:
        - destination:
            host: ${pm4ml_release_name}-management-api
            port:
              number: 9050
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-ttkfront-vs
spec:
  gateways:
  - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name}
  hosts:
  - '${ttk_frontend_fqdn}'
  http:
    - match:
        - uri: 
            prefix: /
      route:
        - destination:
            host: ${pm4ml_release_name}-ttk-frontend
            port:
              number: 6060
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${pm4ml_release_name}-ttkback-vs
spec:
  gateways:
  - ${istio_internal_gateway_namespace}/${istio_internal_wildcard_gateway_name}
  hosts:
  - '${ttk_backend_fqdn}'
  http:
    - name: api
      match:
        - uri: 
            prefix: /api/
      route:
        - destination:
            host: ${pm4ml_release_name}-ttk-backend
            port:
              number: 5050
    - name: socket
      match:
        - uri: 
            prefix: /socket.io/
      route:
        - destination:
            host: ${pm4ml_release_name}-ttk-backend
            port:
              number: 5050
    - name: root
      match:
        - uri: 
            prefix: /
      route:
        - destination:
            host: ${pm4ml_release_name}-ttk-backend
            port:
              number: 4040
---