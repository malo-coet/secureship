"""SecureShip API — minimal FastAPI service used as the workload we containerise
and ship to Kubernetes. Kept intentionally small: the point of the project is the
*platform* around it (Docker, AKS, CI/CD, security), not the app itself."""
from fastapi import FastAPI

app = FastAPI(title="SecureShip API", version="1.0.0")


@app.get("/")
def root():
    return {"service": "secureship", "message": "API is running", "status": "ok"}


@app.get("/health")
def health():
    """Liveness/readiness endpoint. Kubernetes calls this to know if the pod is
    healthy and ready to receive traffic."""
    return {"status": "healthy"}
