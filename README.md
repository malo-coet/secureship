# SecureShip — Containerised API on Azure Kubernetes (AKS)

A small FastAPI service, containerised and deployed to a managed Kubernetes
cluster on Azure, provisioned entirely as code with Terraform. This is the
platform-engineering project: the app is deliberately trivial — the value is in
the **Docker → ACR → AKS** delivery chain and the security choices around it.

## Architecture

```
  Developer                Azure
  ┌────────┐   push image  ┌──────────────────────────────────────┐
  │ Docker │ ────────────▶ │  ACR (private registry)              │
  └────────┘               │        │ pull (by managed identity)  │
                           │        ▼                             │
   kubectl apply  ───────▶ │  AKS cluster                         │
                           │   ├─ Deployment (2 replicas)         │
                           │   └─ Service (LoadBalancer) ─▶ public │
                           └──────────────────────────────────────┘
```

## Stack
- **App:** FastAPI (Python 3.12), multi-stage Docker image, non-root user
- **Registry:** Azure Container Registry (ACR)
- **Orchestration:** Azure Kubernetes Service (AKS), free control plane
- **IaC:** Terraform (azurerm provider)
- **Security:** ACR pull by managed identity (no passwords), non-root container,
  resource limits, liveness/readiness probes

## Cost control
Infra is **ephemeral**: `terraform apply` in the morning, `terraform destroy`
at night. Nodes are `Standard_B2s` (small/burstable), control plane is free.

## Prerequisites
- An Azure account with credits
- Azure CLI (`az`), Terraform (`>= 1.6`), `kubectl`, Docker

See `SETUP.md` / the walkthrough for the full step-by-step.

## Roadmap
- [x] Sprint 1 — containerise + deploy to AKS  ← you are here
- [ ] CI: build + vulnerability scan (GitHub Actions + Trivy)
- [ ] CD: automated deployment
- [ ] Security: Key Vault, Workload Identity, Network Policies
- [ ] Observability: metrics, dashboards, alerts
