## Complete Lecture Notes
- 00-lecture-notes-gc.md
- This file is a subset (duplicate) for learners to make it easy to follow!

## Compute Engine Hands on - Setting up a HTTP server [DEMO] 2000201011
```bash
# Print Working Directory - display the current directory
pwd

# Switch to the root user to run administrative commands
sudo su

# Apt - Advanced Package Tool (a software management system in Linux)
# Refresh package index
apt update 

# Install the Apache HTTP Server 
# Automatically answer "yes" to all prompts
apt -y install apache2

# Start the Apache2 web server
sudo service apache2 start

# Access using External IP
# Make sure you are using HTTP and make sure HTTP Traffic is enabled

# Change Directory to Apache Web Server Root Folder
ls /var/www/html

# Print the text
echo "Hello World!"

# Print the text to a text file
echo "Hello World!" > /var/www/html/index.html

# Show the content for the file
cat /var/www/html/index.html

# Print the host name of vm
echo $(hostname)

# Print the IP address of vm
echo $(hostname -i)

# Print the text containing host name of vm
echo "Hello World from $(hostname)"

# Print the text containing ip and host name of vm
echo "Hello World from $(hostname) $(hostname -i)"

# Write a test message with hostname and internal IP to the web page
echo "Hello world from $(hostname) $(hostname -i)" > /var/www/html/index.html

```

## Compute Engine Troubleshooting - Setting up a HTTP server [DEMO] 2000201021
```bash
# Change Directory to Apache Web Server Root Folder
ls /var/www/html

# Show the content for the file
cat /var/www/html/index.html

# Switch to the root user to run administrative commands
sudo su

# Start the Apache2 web server
sudo service apache2 start
```

## Bootstrapping with VM Startup Script [DEMO] 2000201041
```bash
#!/bin/bash
apt update 
apt -y install apache2
echo "Hello world from $(hostname) $(hostname -I)" > /var/www/html/index.html
```

## Reducing Launch Time with VM Custom Image [DEMO] 2000201051
```
#!/bin/bash
echo "Hello world from $(hostname) $(hostname -I)" > /var/www/html/index.html
service apache2 start
```

## Gcloud - Getting Started [CMDLINE] 2000399901

```bash

# Lot of other tools including kubectl, bq and cbt
gcloud --version 

# initialize
gcloud init

# Set default configuration - shows current configuration
#choose 2 - create new configuration, existing account and id of `my-command-line-project`


# see existing configuration
gcloud config list

```

## Playing with gcloud config set [CMDLINE] 2000399911
```bash
# show active configuration
gcloud config list

# show active account (core/account)
gcloud config list account

# Error!
gcloud config list environment #ERROR

#metrics is section name
gcloud config list metrics/environment

#core is default
gcloud config list project 
gcloud config list core/project

#set default compute region and zone
gcloud config set compute/region us-central1 #enable api

# show active configuration
gcloud config list

gcloud config set compute/zone us-central1-a

# show active configuration
gcloud config list

# review slides

#get help
gcloud config --help # q quit

#get specific help
gcloud config list --help

# review slides
```

## Gcloud - Managing Multiple Configurations [CMDLINE] 2000399921
```bash

# list all configurations
gcloud config configurations list

# only active configuration (along with defaults)
gcloud config list

# switch active configuration
gcloud config configurations activate cloudshell-11869

# shows values from new configuration that is active now
gcloud config list

# switch back
gcloud config configurations activate my-first-gcloud-configuration

# take time and play with commands to remember these commands

# create another configuration
gcloud config configurations create my-second-gcloud-configuration

gcloud config set project my-command-line-project-496308

gcloud config list
gcloud config configurations list

# Show details for specific inactive configuration
gcloud config configurations describe my-first-gcloud-configuration
```

## Understanding gcloud command structure [CMDLINE] 2000399931
```bash
# check configuration
gcloud config list

# set default project, zone and region
#set default compute region and zone
gcloud config set project my-command-line-project-496308
gcloud config set compute/region us-central1 #enable api
gcloud config set compute/zone us-central1-a
gcloud config list

#play with instances
gcloud compute instances list

gcloud compute instances create my-first-vm-from-gcloud 
#ERROR because default machine type not available

gcloud compute instances create my-first-vm-from-gcloud --machine-type=n2-standard-2

gcloud compute instances list
gcloud compute instances describe my-first-vm-from-gcloud
gcloud compute instances delete my-first-vm-from-
# review slides

gcloud compute regions list
gcloud compute zones list
gcloud compute zones list --filter="region:us-central1"
gcloud compute zones list --filter="region:(us-central1 us-east1)"

```

## List and Describe commands [CMDLINE] 2000399981
```bash
gcloud compute regions list
gcloud compute zones list

gcloud compute zones list --filter="region:us-central1"
gcloud compute zones list --filter="region:us-central1" --sort=name
#change sort order with ~
gcloud compute zones list --filter="region:us-central1" --sort=~name
gcloud compute zones list --uri

# go back to slide
gcloud compute regions describe us-central1
gcloud compute zones describe us-central1-a

```

## Playing with Instance Templates [CMDLINE] 2000399996

```bash

gcloud config set project my-command-line-project-496308

gcloud compute instance-templates list #empty

gcloud compute instance-templates create my-instance-template-from-gcloud

gcloud compute instance-templates describe my-instance-template-from-gcloud

#explore slide

gcloud compute instance-templates delete my-instance-template-from-gcloud

gcloud compute instance-templates list

# explore slide
```


## Playing with Google App Engine [DEMO] 2002099901

```bash
# my-app-engine-project
gcloud config set project jovial-sound-497406-n6
cd default-service/
gcloud app deploy

```

## Exploring Google App Engine [DEMO] 2002099911

```bash
gcloud app deploy --version=v2
```

## Releasing New Versions of Google App Engine Services [DEMO] 2002099921
```bash
# Deploy v3 without making it live
gcloud app deploy --version=v3 --no-promote

# Go to cloud console - Access v3 url from versions
# Test V3 and make sure it is working

# Send some traffic to V3
gcloud app services set-traffic --splits=v2=0.5,v3=0.5 
gcloud app services set-traffic --splits=v2=0.5,v3=0.5 --split-by=random

# switch to v3 completely
gcloud app services set-traffic --splits=v3=1 --split-by=random

```


## Managing Multiple Services with Google App Engine [DEMO] 2002099931

```bash
# Creating multiple services
# Copy my-default-service and call it my-first-service
# main.py - Change to My First Service - V1
# app.yaml - add service: my-first-service

cd ..
cd my-first-service/
gcloud app deploy --version=v1

# explore services in cloud console

# back to command line
gcloud app services list
gcloud app versions list

gcloud app browse
gcloud app browse --service=default
gcloud app browse --service=my-first-service --version=v1
```

## Playing with App Engine - Command Line [CMDLINE] 2002099941
```bash
gcloud app open-console --service="my-first-service" --version="v1"
gcloud app open-console --service="my-first-service" --version="v1" --logs
gcloud app regions list
```

## Playing with App Engine Services, Versions and Instances [CMDLINE] 2002099951
```bash
gcloud app services list
gcloud app services browse my-first-service --version="v1"
gcloud app services describe my-first-service
gcloud app services describe default
gcloud app versions list
gcloud app versions list --hide-no-traffic
gcloud app services describe default
```
## Cloud Run - From the Command Line - 1[CMDLINE] 2003199921
```bash
gcloud config set project my-cloud-run-project-id
gcloud config set run/region us-central1

# custom image from docker hub
# /hello-world
gcloud run deploy hello-world --image=in28min/hello-world-rest-api:0.0.1.RELEASE --region=us-central1 --revision-suffix=v1

# second version with different image
gcloud run deploy hello-world --image=in28min/hello-world-rest-api:0.0.2.RELEASE --region=us-central1 --revision-suffix=v2

# back to slide
```

## Cloud Run - From the Command Line - 2[CMDLINE] 2003199931
```bash
gcloud run deploy hello-world --image=in28min/hello-world-rest-api:0.0.3.RELEASE --region=us-central1 --revision-suffix=v3 --no-traffic
gcloud run services update-traffic hello-world --to-revisions=hello-world-v2=50,hello-world-v3=50 --region=us-central1
gcloud run services update-traffic hello-world --to-revisions=hello-world-v3=100 --region=us-central1

# back to slides
gcloud run services list
gcloud run services describe hello-world --region=us-central1
gcloud run revisions list
gcloud run revisions describe hello-world-v1 --region=us-central1

```

## Kubernetes - A Journey - Deploy Your Microservice [DEMO]

```bash
gcloud container clusters get-credentials my-cluster --region us-central1 --project my-kubernetes-project-489210

# kubectl: execute kubernetes commands against cluster
kubectl create deployment hello-world-rest-api --image=in28min/hello-world-rest-api:0.0.1.RELEASE
kubectl expose deployment hello-world-rest-api --type=LoadBalancer --port=8080

# get external ip
kubectl get services
kubectl get services --watch
# http://EXTERNAL_IP:8080
# http://EXTERNAL_IP:8080/hello-world

```


## Key Kubernetes Logical Concepts [DEMO]
```bash
# Scale Deployment
kubectl scale deployment hello-world-rest-api --replicas=2

# 2nd instance my take time
kubectl get deployments

kubectl get pods

# get service ip
kubectl get svc

# last few characters indicate pod name
# Automatic load balancing is provided by service
curl 34.67.155.207:8080/hello-world

# delete a pod
kubectl delete pod/hello-world-rest-api-6db748795f-pcxl6
# kubernetes starts self healing 
# creates a new pod
# you will see two pods again
kubectl get pods

```

## Kubernetes - A Journey - Scaling [DEMO]
```bash
kubectl autoscale deployment hello-world-rest-api --max=4 --cpu=70%
kubectl get hpa

# Go back to slides
# If you are using Standard cluster, you need scale nodes as well
# Commands in slide
```

## Kubernetes - A Journey - The End [DEMO]
```bash
kubectl delete service hello-world-rest-api
kubectl delete deployment hello-world-rest-api
# Delete cluster if you want to keep costs low

```

# Digging Deeper Into Kubernetes

## Deployment vs ReplicaSet [DEMO]
```bash
# Demo for Deployment vs ReplicaSet
kubectl create deployment hello-world-rest-api --image=in28min/hello-world-rest-api:0.0.1.RELEASE --replicas=2
kubectl expose deployment hello-world-rest-api --type=LoadBalancer --port=8080

# scales to 2 and immediately goes to 1 because of hpa
kubectl get deployment
kubectl get rs
kubectl get hpa

# delete hpa
kubectl delete hpa hello-world-rest-api

# scale to 2 instances
kubect scale deployment hello-world-rest-api --replicas=2

# wait till 2 pods ready
# can take time - 15 minutes
kubectl get rs
kubectl get pods

# get ip and hit url
kubectl get svc

# see which pod responds
# load balancing in action
curl 34.67.155.207:8080/hello-world

# Use V2 Version
kubectl set image deployment hello-world-rest-api hello-world-rest-api=in28min/hello-world-rest-api:0.0.2.RELEASE

# Watch whats happening
# Deployment created a RS
# There will be 2 replicasets
kubectl get rs --watch

# see which pod responds
curl 34.67.155.207:8080/hello-world

kubectl delete pod ID

# pods will be back
kubectl get pods

# see details about rs and 
kubectl get rs -o wide


# go back to slides
```

## Exploring Kubernetes Pod [DEMO]
```bash

# get details about pods
kubectl get pods -o wide

# delete pod
# new pod will have different ip address
kubectl delete pod ID

```

## Troubleshooting Kubernetes Deployment Errors [DEMO]

```bash
kubectl create deployment hello-world-rest-api --image=in28min/hello-world-rest-api:0.0.10.RELEASE #ERROR IMAGE
kubectl get events
kubectl get pods -o wide
kubectl describe pod hello-world-rest-api-54487b7447-xh5zt
kubectl delete deployment hello-world-rest-api
```


## Exploring Declarative Kubernetes Fundamental [DEMO]

```bash

# delete earlier deployments
kubectl delete deployment hello-world-rest-api
kubectl delete service hello-world-rest-api

kubectl create namespace hello-world-rest-api-ns

kubectl apply -f deployment-v1.yaml 

# EMPTY
kubectl get pods

# Explore YAML file

kubectl get pods --namespace=hello-world-rest-api-ns
kubectl get svc --namespace=hello-world-rest-api-ns

# Creation of lb can take 10-15 minutes
curl 35.202.83.101:8080
curl 35.202.83.101:8080/hello-world

```

## Exploring Power of Kubernetes Labels [DEMO]

```bash

# delete earlier stuff
kubectl delete -f deployment-v1.yaml 

# create two deployments and one service using deployment-v2.yaml
kubectl apply -f deployment-v2.yaml

kubectl get pods --namespace=hello-world-rest-api-ns

kubectl get svc --namespace=hello-world-rest-api-ns

# Load balancing between v1 and v2
curl 35.202.83.101:8080/hello-world

# Goto v2 yaml add selector version:v1 to service
# Only changed objects will be updated
kubectl apply -f deployment-v2.yaml

# Response from v1 only
curl 35.202.83.101:8080/hello-world


# Goto v2 yaml change selector version:v2 to service
# Only changed objects will be updated
kubectl apply -f deployment-v2.yaml

# Response from v2 only
curl 35.202.83.101:8080/hello-world

# labels are powerful
# play around and then delete!

kubectl delete -f deployment-v2.yaml

```

## Managing Disks and Snapshots with Gcloud [CMDLINE] 2011199941
```bash
gcloud config set project project-45a38234-36e5-4203-bb2 # My First Project
gcloud compute disks list
gcloud compute disk-types list
gcloud compute disk-types list --filter zone=us-central1-a
gcloud compute disk-types list --filter zone=us-central1-a --format "value(NAME)"

# slide

gcloud compute snapshots list
gcloud compute snapshots describe disk-20260511-09071-us-central1-a-20260525232855-9bqnbcbl

```

## Managing Images with Gcloud [CMDLINE] 2011199951
```bash
gcloud compute images list # DONT EXECUTE - BRINGS A LOT OF IMAGES
gcloud compute images list --no-standard-images

gcloud compute images deprecate in28minutes-custom-image --state=DEPRECATED

# our custom image is not listed
gcloud compute images list --no-standard-images

# our custom image is listed
gcloud compute images list --no-standard-images --show-deprecated

gcloud compute images delete in28minutes-custom-image

# slide

```

## Cloud Storage From Command Line – gcloud storage [CMDLINE] 2011199971
```bash
## slide - introduce gcloud storage command

gcloud storage buckets list
gcloud storage buckets list --format "value(NAME)"
gcloud storage buckets describe my-first-bucket-in28minutes-2050 #ERROR
gcloud storage buckets describe gs://my-first-bucket-in28minutes-2050
#slide

# lists objects at root of buckets
gcloud storage objects list gs://my-first-bucket-in28minutes-2050

# recursively list all objects in bucket
gcloud storage objects list gs://my-first-bucket-in28minutes-2050/**
gcloud storage objects list gs://my-first-bucket-in28minutes-2050/** --format "value(storage_url)"

#slide
gcloud storage objects describe gs://my-first-bucket-in28minutes-2050/index.html

#slide

```

## Cloud Storage From Command Line – Miscellaneous [CMDLINE] 2011199981
```bash
#slide
# lists all bucket urls in project
gcloud storage ls

# lists all files and folders at root of bucket
gcloud storage ls gs://my-first-bucket-in28minutes-2050/

# lists all files in the bucket
gcloud storage ls gs://my-first-bucket-in28minutes-2050/**
gcloud storage ls gs://my-first-bucket-in28minutes-2050/**/*.png
#slide
```

## Managing Databases using Gcloud [CMDLINE] 2012199941

```yaml

## see bq and cbt
gcloud --version
## you dont need to remember lal commands
## slides

# table details including schema
# samples is a public dataset
bq show bigquery-public-data:samples.shakespeare


echo project=project-45a38234-36e5-4203-bb2 > ~/.cbtrc
cat ~/.cbtrc
cbt listinstances

```

## Exploring IAM using Gcloud [CMDLINE] 2030199941
```bash
gcloud config set project project-45a38234-36e5-4203-bb2 #My First Project

# get info about project
gcloud compute project-info describe

#slide

# list active accounts
gcloud auth list

# slide

gcloud projects get-iam-policy #ERROR

# IAM Policy contains bindings from member(s) to a role

gcloud projects get-iam-policy project-45a38234-36e5-4203-bb2 #My First Project

gcloud projects add-iam-policy-binding project-45a38234-36e5-4203-bb2 #ERROR
gcloud projects add-iam-policy-binding project-45a38234-36e5-4203-bb2 --member=user:id@gmail.com --role=roles/storage.objectAdmin

gcloud projects remove-iam-policy-binding project-45a38234-36e5-4203-bb2 --member=user:id@gmail.com --role=roles/storage.objectAdmin

# slide
gcloud iam roles describe roles/storage.objectAdmin

# slide
gcloud iam roles copy --source=roles/storage.objectAdmin --destination=my.custom.role --dest-project=project-45a38234-36e5-4203-bb2
```

## Managing Projects using Gcloud - gcloud projects [CMDLINE] 2030199951

```bash
gcloud projects list
gcloud projects describe project-45a38234-36e5-4203-bb2
gcloud projects get-iam-policy project-45a38234-36e5-4203-bb2

```

## Managing Active Services using Gcloud - gcloud services [CMDLINE] 2030199971
```bash
gcloud services list --enabled --project=project-45a38234-36e5-4203-bb2 #My First Project
gcloud services list --available --project=project-45a38234-36e5-4203-bb2

```



## Managing PubSub From Command Line [CMDLINE] 2060199911
```bash
gcloud config set project project-45a38234-36e5-4203-bb2 # MY FIRST PROJECT

gcloud pubsub topics create my-topic-from-gcloud

gcloud pubsub subscriptions create subscription-gcloud-1 --topic=my-topic-from-gcloud
gcloud pubsub subscriptions create subscription-gcloud-2 --topic=my-topic-from-gcloud

# pull a subscription
gcloud pubsub subscriptions pull subscription-gcloud-1

# publish messages
gcloud pubsub topics publish my-topic-from-gcloud --message="My First Message From Gcloud"
gcloud pubsub topics publish my-topic-from-gcloud --message="My Second Message From Gcloud"
gcloud pubsub topics publish my-topic-from-gcloud --message="My Third Message From Gcloud"

# pull subscriptions
gcloud pubsub subscriptions pull subscription-gcloud-1
gcloud pubsub subscriptions pull subscription-gcloud-1 --auto-ack
gcloud pubsub subscriptions pull subscription-gcloud-2
gcloud pubsub subscriptions pull subscription-gcloud-2 --auto-ack

#slides
gcloud pubsub topics list-subscriptions my-topic-from-gcloud
```