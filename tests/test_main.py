"""Tests d'API exécutés automatiquement dans la CI.
On vérifie que les endpoints répondent correctement — un filet de sécurité :
si un futur changement casse /health, la CI le bloque avant tout déploiement."""
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json() == {"status": "healthy"}


def test_root():
    r = client.get("/")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"
