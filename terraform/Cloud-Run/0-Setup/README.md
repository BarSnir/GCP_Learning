## Build
gcloud builds submit \
  --project="$(terraform output -raw project_id)" \
  --tag="$(terraform output -raw image_uri)" \
  ./app


## List for built images
gcloud artifacts docker images list \
  "$(terraform output -raw artifact_registry_url)" \
  --include-tags