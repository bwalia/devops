#!/bin/bash

# Install the Elastic Operator
helm upgrade --install elastic-operator elastic/eck-operator -n elastic-system --create-namespace

sleep 60

cat <<EOF | kubectl apply -f -
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: quickstart
spec:
  version: 9.1.2
  nodeSets:
  - name: default
    count: 2
    podTemplate:
      spec:
        containers:
        - name: elasticsearch
          env:
          - name: ES_JAVA_OPTS
            value: -Xms16g -Xmx16g
          resources:
            requests:
              memory: 16Gi
              cpu: 2
            limits:
              memory: 64Gi
              cpu: 4
    config:
      node.store.allow_mmap: false
    volumeClaimTemplates:
    - metadata:
        name: elasticsearch-data
      spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 100Gi
        storageClassName: longhorn
EOF


cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    nginx.ingress.kubernetes.io/proxy-ssl-verify: "false"
  name: kibana-instance-ingress 
  namespace: default
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - elastic.workstation.co.uk
    secretName: gitlab-tls
  rules:
  - host: "elastic.workstation.co.uk"
    http:
      paths:
        - pathType: Prefix
          path: "/"
          backend:
            service:
              name: quickstart-kb-http
              port:
                number: 5601
EOF

cat <<EOF | kubectl apply -f -
apiVersion: kibana.k8s.elastic.co/v1
kind: Kibana
metadata:
  name: quickstart
spec:
  config:
    server.publicBaseUrl: https://elastic.workstation.co.uk
  version: 9.1.2
  count: 1
  elasticsearchRef:
    name: quickstart
EOF

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    nginx.ingress.kubernetes.io/proxy-ssl-verify: "false"
  name: elasticsearch-instance-ingress
  namespace: default
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - elasticapi.workstation.co.uk
    secretName: gitlab-tls
  rules:
  - host: "elasticapi.workstation.co.uk"
    http:
      paths:
        - pathType: Prefix
          path: "/"
          backend:
            service:
              name: quickstart-es-http
              port:
                number: 9200
EOF

# get secret to login to your kibana ui

echo "Kibana UI login password:"
kubectl get secret quickstart-es-elastic-user -o go-template='{{.data.elastic | base64decode}}'

echo ""
echo "Visit this Github repository for more details - https://github.com/bwalia/devops.git"
