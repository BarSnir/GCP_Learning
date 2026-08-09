# Minimal GCE with Terraform

This example creates one Google Compute Engine VM in the simplest usable setup.

## Files

- `main.tf` - provider and VM resource
- `inputs.tf` - input definitions
- `terraform.tfvars.example` - example input values

## Prerequisites

1. Install Terraform:
   https://developer.hashicorp.com/terraform/downloads
2. Install Google Cloud SDK:
   https://cloud.google.com/sdk/docs/install
3. Authenticate to Google Cloud:

```bash
gcloud auth application-default login
```

4. Set your project in gcloud if needed:

```bash
gcloud config set project YOUR_PROJECT_ID
```

5. Make sure the Compute Engine API is enabled:

```bash
gcloud services enable compute.googleapis.com
```

## How to run

1. Copy the example inputs:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` and set at least `project_id`.

3. Initialize Terraform:

```bash
terraform init
```

4. Review the execution plan:

```bash
terraform plan
```

5. Create the VM:

```bash
terraform apply
```

6. Destroy it when finished:

```bash
terraform destroy
```

## Notes

- The VM gets a public IP because of `access_config`.
- The example uses the `default` VPC network.
- OS Login is enabled in instance metadata.