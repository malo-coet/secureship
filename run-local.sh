#!/usr/bin/env bash
set -euo pipefail
CLUSTER=secureship

echo "▶ 1/5  Création du cluster kind (si absent)…"
kind get clusters | grep -qx "$CLUSTER" || kind create cluster --name "$CLUSTER"

echo "▶ 2/5  Build de l'image Docker…"
docker build -t secureship:v1 .

echo "▶ 3/5  Chargement de l'image dans le cluster…"
kind load docker-image secureship:v1 --name "$CLUSTER"

echo "▶ 4/5  Déploiement sur Kubernetes…"
kubectl apply -f k8s/deployment.local.yaml
kubectl apply -f k8s/service.yaml
kubectl rollout status deploy/secureship

echo "▶ 5/5  Prêt. Ouvre l'API avec :"
echo "    kubectl port-forward svc/secureship 8080:80"
echo "    puis dans un autre terminal :  curl http://localhost:8080/health"
