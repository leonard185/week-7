# Explanation: Design & Deployment Choices

## 1) Kubernetes Objects
- **Database via StatefulSet**: I used a `StatefulSet` for PostgreSQL to get stable Pod identities and persistent volume claims per replica. This makes storage management simpler and reliable during reschedules or restarts. A **headless Service** (`clusterIP: None`) provides stable DNS (`postgres-0.postgres.prod.svc.cluster.local`).
- **App via Deployment**: The application is stateless and horizontally scalable, so a `Deployment` with RollingUpdate strategy and probes (readiness/liveness) suits it best.

## 2) Exposure Method
- **Service type `LoadBalancer`** on GKE. This provisions a Google Cloud external load balancer and gives me a public `EXTERNAL-IP`, meeting the requirement for a live `IP:port` endpoint without needing DNS or Ingress. Port 80 maps to container 8080.

## 3) Persistent Storage
- **PVC via `volumeClaimTemplates`** on the `StatefulSet` for PostgreSQL. I requested `10Gi` with `ReadWriteOnce` and `storageClassName: premium-rwo` (GKE’s SSD-backed class). If the cluster’s default differs, omitting `storageClassName` lets the default StorageClass handle provisioning.

## 4) Git Workflow
- **Branching**: `main` is protected; feature branches (`feat/k8s-manifests`, `chore/ci`) via PRs.
- **Tags**: Docker images use **SemVer + git SHA** (e.g., `1.0.0-gitsha-a1b2c3d`) for immutability and easy rollback.
- **CI (optional)**: On merge to `main`, build & push images to Docker Hub with the tag `1.0.0-gitsha-<short>` and update manifests in `k8s/` via a PR or manual apply.

## 5) Running Application / Debugging
- Public link is documented in `README.md` as `http://<EXTERNAL-IP>/` (or `<EXTERNAL-IP>:80`).
- **Debugging measures** if not live:
  - `kubectl get pods -n prod` and `kubectl describe pod/...` for scheduling/probe issues.
  - `kubectl logs -n prod deploy/your-app -f` and `kubectl logs -n prod statefulset/postgres -f`.
  - Verify secrets/config: `kubectl get cm,secret -n prod -o yaml` (do not commit secrets).
  - Check Service/LoadBalancer: `kubectl get svc -n prod your-app -w` until `EXTERNAL-IP` appears.
  - Network policy: none applied here; default allow within namespace.

## 6) Docker Image Naming Good Practices
- Repo: `leonard254/kubernets`
- Tags: `1.0.0-gitsha-<short>` (immutable), `stable` (movable).
- Avoid `latest` in manifests to ensure deterministic rollouts.

