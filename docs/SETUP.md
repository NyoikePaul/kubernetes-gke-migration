# Setup Guide
## Prerequisites
| Tool | Version |
|---|---|
| gcloud | latest |
| terraform | >= 1.6 |
| kubectl | >= 1.28 |
| helm | >= 3.12 |

## Deploy
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init && terraform apply -var-file=terraform.tfvars
```
