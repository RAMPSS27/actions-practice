Actions Practice — CI/CD Pipeline to GKE

A practice project demonstrating a full CI/CD pipeline: build a Docker image, push it to Docker Hub, and deploy it to Google Kubernetes Engine (GKE) — all triggered automatically on every push to main.

What this pipeline does
Checkout — pulls the latest code
Build — builds a Docker image from the Dockerfile
Push — pushes the image to Docker Hub (kaivpractice/actions-practice)
Authenticate — authenticates to Google Cloud using Workload Identity Federation (no static keys or downloadable credentials)
Deploy — applies the Kubernetes Deployment manifest to a GKE cluster
Verify — waits for the rollout to become healthy, with a 90-second timeout
Rollback — if the rollout fails or times out, automatically rolls back to the previous working version
Architecture
Push to main
     ↓
GitHub Actions runner (fresh VM)
     ↓
Build Docker image → Push to Docker Hub
     ↓
Authenticate to GCP (Workload Identity Federation)
     ↓
kubectl apply → GKE cluster
     ↓
Rollout healthy? → Yes: done | No: automatic rollback
Tech stack
Docker
GitHub Actions
Google Kubernetes Engine (GKE)
Workload Identity Federation (keyless GCP authentication)
kubectl
Key design decisions
Workload Identity Federation over service account keys — Google's org policy blocks downloadable service account keys by default now; this is also the more secure, current-best-practice approach regardless.
kubectl apply with a committed YAML file, not kubectl create --dry-run — ensures Kubernetes maintains proper rollout history, which is required for kubectl rollout undo to work.
Idempotent secret/config creation — ConfigMaps and Secrets are created via --dry-run=client -o yaml | kubectl apply -f -, making the step safe to run on every pipeline execution, not just the first.
Running this locally
bash
docker build -t actions-practice .
docker run -p 5000:5000 actions-practice
Note on cost management

The GKE cluster used by this pipeline is created and destroyed manually around testing sessions, not left running continuously, to avoid unnecessary cloud costs during learning/practice.

What I learned building this
Debugging real authentication failures between CI runners and cloud providers (SSL/certificate issues, auth plugin requirements, Workload Identity Federation setup)
Why Kubernetes Deployment selectors are immutable, and how that affects redeployment strategy
The importance of writing idempotent pipeline steps, since CI/CD steps run repeatedly, not just once
How to verify a rollback safety net actually works, not just assume it does
