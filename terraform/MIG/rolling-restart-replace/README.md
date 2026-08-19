## Acutal restart
```
gcloud compute instance-groups managed rolling-action restart web-mig-regional \
--region=europe-west1 \
--max-unavailable=1
```