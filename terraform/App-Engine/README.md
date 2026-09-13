# Setup
## Eanble service:
"""
  gcloud services enable \
  appengine.googleapis.com \
  cloudbuild.googleapis.com
"""

## Verify:
gcloud services list --enabled \
  --filter="NAME:(appengine.googleapis.com cloudbuild.googleapis.com)"


## Lesson:
1. gcloud auth login authenticates the gcloud CLI, while gcloud auth application-default login creates ADC, which tools such as Terraform and Google client libraries can use. Therefore, gcloud can work while Terraform fails if the ADC credentials are missing, expired, or belong to a different account.

terraform import google_app_engine_application.app pca-certification


## Go Standard - Key Lessons

1. **Deploy source code**
   - Upload `main.go` + `go.mod`.
   - App Engine Standard uses Cloud Build / Buildpacks to compile the app.

2. **Use the correct entrypoint**
   - Wrong: `go run main.go`
   - Correct: `main`
   - The runtime does not include the Go compiler.

3. **Terraform does not read `app.yaml`**
   - `gcloud app deploy` uses `app.yaml`.
   - `google_app_engine_standard_app_version` requires runtime, scaling, service, and entrypoint in Terraform.

4. **Troubleshooting flow**
   - `503` → check App Engine logs.
   - Build failure → check Cloud Build logs.
   - Do not change configuration before checking the logs.

5. **Use versions**
   - Example: broken `v1` → fixed `v2`.
   - Versions are later used for rollback, traffic migration, and A/B testing.

6. **Use disposable services**
   ```hcl
   service                   = "go-standard"
   delete_service_on_destroy = true


## Spliting - 4-Java API
gcloud app services set-traffic java-api \
  --splits=v1=0.9,v2=0.1 \
  --split-by=random

## Migrating 4-Java API
gcloud app services set-traffic java-api \
  --splits=v2=1 \
  --migrate