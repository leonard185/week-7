# Your App on GKE

This repo contains Kubernetes manifests to deploy the app and a PostgreSQL database on **Google Kubernetes Engine**.

## Live URL
- **Public endpoint**: `http://<EXTERNAL-IP>/`  
  (Replace with the value from `kubectl get svc -n prod your-app`.)

## Prereqs
- Docker Hub account with these images pushed:
  - `YOUR_DOCKERHUB_USER/your-app:1.0.0-gitsha-<short>`
  - `YOUR_DOCKERHUB_USER/your-db:1.0.0` (or use `postgres:16` if you didn’t build a custom image)
- GCP project + `gcloud` + `kubectl`.

## Deploy (quickstart)
```bash
gcloud config set project <YOUR_GCP_PROJECT_ID>
gcloud container clusters create k8s-ip-cluster --num-nodes=3 --machine-type=e2-standard-2
gcloud container clusters get-credentials k8s-ip-cluster

kubectl apply -f k8s/namespace.yaml
kubectl apply -n prod -f k8s/configmap.yaml
kubectl apply -n prod -f k8s/secret.yaml
kubectl apply -n prod -f .yaml
kubectl apply -n prod -f k8s/postgres-statefulset.yaml
kubectl rollout status -n prod statefulset/postgres

kubectl apply -n prod -f k8s/app-deployment.yaml
kubectl rollout status -n prod deployment/your-app

kubectl apply -n prod -f k8s/svc-app.yaml
kubectl get svc -n prod your-app -w
