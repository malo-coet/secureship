# ---- Stage 1: builder ----------------------------------------------------
# On construit les dépendances Python en "wheels" dans un étage jetable.
# Rien de cet étage ne part dans l'image finale, sauf les wheels compilés
# -> image finale légère, sans outils de build.
FROM python:3.12-slim AS builder
WORKDIR /app
COPY app/requirements.txt .
RUN pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt

# ---- Stage 2: runtime ----------------------------------------------------
# L'image qu'on livre vraiment : Python + nos deps + notre code. Rien de plus.
FROM python:3.12-slim
WORKDIR /app

# Installe les deps depuis les wheels pré-construits (rapide, hors-ligne).
COPY app/requirements.txt .
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir --no-index --find-links=/wheels -r requirements.txt \
    && rm -rf /wheels

# Copie le code de l'application.
COPY app/ ./app/

# Sécurité : on ne tourne JAMAIS en root dans le conteneur.
# On crée un utilisateur avec un UID NUMÉRIQUE fixe (1000) et on l'active par
# son numéro. Kubernetes ne résout pas les noms d'utilisateur : pour vérifier
# que le conteneur n'est pas root, il lui faut un UID numérique. D'où USER 1000.
RUN adduser --disabled-password --gecos "" --uid 1000 appuser \
    && chown -R 1000:1000 /app
USER 1000

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
