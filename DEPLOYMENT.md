# Deployment

## Stack
- Backend: Node.js/Express → port 4000
- Frontend: Next.js → port 3002
- Database: MongoDB

## Local dev

```bash
cp .env.example .env
docker-compose up -d
```

Frontend → http://localhost:3002  
Backend → http://localhost:4000  
MongoDB → localhost:27017

## Kubernetes

```bash
kubectl apply -f k8s/
```

## Helm

```bash
helm dependency update helm/

helm upgrade --install backend  helm/ -n assessment \
  -f helm/values/backend/values.yaml \
  -f helm/values/backend/values-prod.yaml \
  --set image.tag=$(git rev-parse --short HEAD) --wait

helm upgrade --install frontend helm/ -n assessment \
  -f helm/values/frontend/values.yaml \
  -f helm/values/frontend/values-prod.yaml \
  --set image.tag=$(git rev-parse --short HEAD) --wait

helm upgrade --install database helm/ -n assessment \
  -f helm/values/database/values.yaml --wait
```

## CI/CD

`pull_request` → lint → test → build (no push)  
`push main` → + trivy scan → push to GHCR → kubectl deploy

## Debug

```bash
kubectl logs -n assessment <pod> --previous
kubectl describe pod -n assessment <pod>
kubectl exec -n assessment -it <pod> -- mongosh
```
