# SecureShip — commandes du quotidien (kind + kubectl)

Il y a 3 niveaux distincts. Ne les confonds pas :
  • le **port-forward** = un tunnel (processus au premier plan dans un terminal)
  • l'**app** (Deployment + Service) = ce qui tourne DANS le cluster
  • le **cluster** kind lui-même = l'environnement Kubernetes

## Accéder à l'app
    kubectl port-forward svc/secureship 8080:80      # ouvre le tunnel (bloque le terminal)
    # -> Ctrl+C pour fermer le tunnel (l'app continue de tourner dans le cluster)

## Voir l'état
    kubectl get pods                 # les pods et leur statut
    kubectl get all                  # tout : pods, deployment, service
    kubectl logs deploy/secureship   # les logs de l'app
    kubectl logs -f deploy/secureship  # logs en direct (Ctrl+C pour sortir)

## Arrêter / redémarrer l'APP (le cluster reste debout)
    kubectl delete -f k8s/deployment.local.yaml -f k8s/service.yaml   # arrête l'app
    kubectl apply  -f k8s/deployment.local.yaml -f k8s/service.yaml   # la relance
    kubectl rollout restart deploy/secureship                         # redémarre les pods (rolling)
    kubectl scale deploy/secureship --replicas=3                      # change le nb d'exemplaires

## Après avoir MODIFIÉ le code (Dockerfile / app)
    docker build -t secureship:v1 .
    kind load docker-image secureship:v1 --name secureship
    kubectl rollout restart deploy/secureship        # recharge la nouvelle image

## Éteindre / rallumer (fin de journée, reboot du Mac)
  - Le cluster kind est fait de conteneurs Docker : il se remet en route tout seul
    quand Docker Desktop redémarre. Le tunnel port-forward, lui, doit être relancé.
  - Au retour :  lance Docker Desktop -> `docker ps` -> re-fais le `port-forward`.
  - Si le cluster a disparu :  `./run-local.sh` reconstruit tout en ~1 min.

## Tout supprimer (cluster compris)
    kind delete cluster --name secureship            # efface l'environnement complet
    kind get clusters                                # vérifie ce qui reste

## Repartir de zéro
    ./run-local.sh                                   # cluster + build + load + déploie
