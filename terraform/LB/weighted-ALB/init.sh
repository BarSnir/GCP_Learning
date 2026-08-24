#!/bin/bash

apt-get update
apt-get install -y nginx

ROLE=$(curl -s \
  -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/attributes/app_role)

echo "$ROLE - $(hostname)" > /var/www/html/index.html

systemctl restart nginx