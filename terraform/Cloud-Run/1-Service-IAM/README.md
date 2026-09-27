## Order of provision:
Artifact Registry
      ↓
Build + Push Image
      ↓
Cloud Run Service


## Lessons Learned

- Cloud Run **Ingress** controls where traffic can come from; **IAM** controls who is allowed to invoke the service.
- `INGRESS_TRAFFIC_ALL` does **not** automatically make a service public.
- Public access can be granted with `roles/run.invoker` to `allUsers`.
- Private services require a valid Google-signed **ID token**.
- `roles/run.invoker` must be granted to the identity calling the service.
- For Service Account impersonation, the user needs `roles/iam.serviceAccountTokenCreator`.
- The ID token `aud` should match the Cloud Run service URL.
- Runtime Service Accounts and Caller Service Accounts serve different purposes:
  - Runtime SA = identity used **by the Cloud Run application**.
  - Caller SA = identity used **to invoke the Cloud Run service**.
- IAM changes may take a short time to propagate.
- A successful authenticated request returned `HTTP 200`, while anonymous access to the private service returned `403`.