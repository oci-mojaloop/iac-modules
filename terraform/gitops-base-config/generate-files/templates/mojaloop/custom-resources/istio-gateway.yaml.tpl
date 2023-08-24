%{ if istio_create_ingress_gateways ~}
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: interop-gateway
spec:
  selector:
    istio: ${istio_external_gateway_name}
  servers:
  - hosts:
    - '${interop_switch_fqdn}'
    port:
      name: https-interop
      number: 443
      protocol: HTTPS
    tls:
      credentialName: ${vault_certman_secretname}
      mode: MUTUAL
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: interop-vs
spec:
  gateways:
  - interop-gateway
  hosts:
  - '${interop_switch_fqdn}'
  http:
    - name: participants
      match:
        - uri: 
            prefix: /participants
      route:
        - destination:
            host: ${mojaloop_release_name}-account-lookup-service
            port:
              number: 80
    - name: parties
      match:
        - uri: 
            prefix: /parties
      route:
        - destination:
            host: ${mojaloop_release_name}-account-lookup-service
            port:
              number: 80
    - name: quotes
      match:
        - uri: 
            prefix: /quotes
      route:
        - destination:
            host: ${mojaloop_release_name}-quoting-service
            port:
              number: 80
    - name: transfers
      match:
        - uri: 
            prefix: /transfers
      route:
        - destination:
            host: ${mojaloop_release_name}-ml-api-adapter-service      
            port:
              number: 80
    - name: bulkQuotes
      match:
        - uri: 
            prefix: /bulkQuotes
      route:
        - destination:
            host: ${mojaloop_release_name}-quoting-service      
            port:
              number: 80
    - name: bulkTransfers
      match:
        - uri: 
            prefix: /bulkTransfers
      route:
        - destination:
            host: ${mojaloop_release_name}-bulk-api-adapter-service      
            port:
              number: 80
    - name: transactionRequests
      match:
        - uri: 
            prefix: /transactionRequests
      route:
        - destination:
            host: ${mojaloop_release_name}-transaction-requests-service      
            port:
              number: 80
    - name: authorizations
      match:
        - uri: 
            prefix: /authorizations
      route:
        - destination:
            host: ${mojaloop_release_name}-transaction-requests-service      
            port:
              number: 80
---
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: mojaloop-ttk-gateway
spec:
  selector:
    istio: ${istio_external_gateway_name}
  servers:
  - hosts:
    - 'ttkfrontend.${ingress_subdomain}'
    - 'ttkbackend.${ingress_subdomain}'
    port:
      name: https-mojaloop-ttk
      number: 443
      protocol: HTTPS
    tls:
      credentialName: ${default_ssl_certificate}
      mode: SIMPLE
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: mojaloop-ttkfront-vs
spec:
  gateways:
  - mojaloop-ttk-gateway
  hosts:
  - 'ttkfrontend.${ingress_subdomain}'
  http:
    - match:
        - uri: 
            prefix: /
      route:
        - destination:
            host: ${mojaloop_release_name}-ml-testing-toolkit-frontend
              port: 6060
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: mojaloop-ttkback-vs
spec:
  gateways:
  - mojaloop-ttk-gateway
  hosts:
  - 'ttkbackend.${ingress_subdomain}'
  http:
    - name: api
      match:
        - uri: 
            prefix: /api/
      route:
        - destination:
            host: ${mojaloop_release_name}-ml-testing-toolkit-backend
              port: 5050
    - name: socket
      match:
        - uri: 
            prefix: /socket.io/
      route:
        - destination:
            host: ${mojaloop_release_name}-ml-testing-toolkit-backend
              port: 5050
    - name: root
      match:
        - uri: 
            prefix: /
      route:
        - destination:
            host: ${mojaloop_release_name}-ml-testing-toolkit-backend
              port: 4040
---
%{ endif ~}