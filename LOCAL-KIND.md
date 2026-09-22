# SecureShip en local avec kind (plan B quota Azure)

Ton abonnement Azure a un quota vCPU nul → AKS ne peut pas démarrer. On fait
tourner le **même** projet sur un Kubernetes local (`kind`). Dockerfile et
manifestes sont identiques ; seul le provisioning du cluster change.

## Prérequis (une fois)
- Docker Desktop **lancé**
- `brew install kind kubectl`   (kubectl déjà présent chez toi)

## Lancer
```bash
./run-local.sh
```
Puis, pour accéder à l'API :
```bash
kubectl port-forward svc/secureship 8080:80
# autre terminal :
curl http://localhost:8080/health      # -> {"status":"healthy"}
```

## Comprendre les commandes (pour l'entretien)
- `kind create cluster` : crée un cluster Kubernetes **dans des conteneurs Docker**
  sur ta machine. Chaque "nœud" est un conteneur → pas besoin de VM cloud.
- `kind load docker-image` : injecte ton image dans le cluster sans passer par un
  registry (c'est pourquoi le manifeste local a `imagePullPolicy: Never`).
- `kubectl port-forward` : ouvre un tunnel de ta machine vers le Service. En cloud
  on aurait un LoadBalancer avec IP publique ; en local, le port-forward joue ce rôle.

## Arrêter / nettoyer
```bash
kind delete cluster --name secureship
```

## Ce que tu dis en entretien (l'histoire est excellente)
« Mon abonnement Azure avait un quota vCPU à zéro, impossible de provisionner AKS.
Plutôt que de rester bloqué, j'ai fait tourner le même workload sur **kind**
(Kubernetes local) — mêmes Dockerfile et manifestes — et gardé mon **Terraform AKS
prêt à appliquer** dès que le quota serait accordé. Ça montre que je maîtrise
Kubernetes indépendamment du fournisseur, et que je m'adapte aux contraintes réelles. »

## Ce qui reste "cloud"
- Le Terraform `infra/` (AKS + ACR) reste dans le repo, prêt. On pourra même
  déployer **juste l'ACR** (registry — pas de vCPU requis) pour exercer l'IaC cloud.
- Quand tu auras du quota (ou un autre cloud), on bascule sur AKS en une commande.
