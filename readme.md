# yandex cloud instance group autscalng demo
# based on https://yandex.cloud/en-ru/docs/tutorials/infrastructure-management/autoscale-monitoring

## prereqs
### terraform (v1.7.5) <https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli>
### yc cli (v0.120.0) <https://cloud.yandex.com/en-ru/docs/cli/quickstart>
### packer (v1.8.7) <https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli>
### aws cli (2.15.38) <https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html>

```console
alias tf=terraform
alias p=packer
```

## create env vars
```console
export _YANDEX_FOLDER_NAME=dev
export _YANDEX_CLOUD_NAME=tests
export _TERRAFORM_SERVICE_ACC_NAME=temporary-acc-for-terraform
```
## add _YANDEX_FOLDER_NAME and _YANDEX_CLOUD_NAME values to terraform.tfvars file
```console
sed -E \
  -e 's/(cloud_name\s*=\s*")[^"]*(")/\1'"${_YANDEX_CLOUD_NAME}"'\2/g' \
  -e 's/(folder_name\s*=\s*")[^"]*(")/\1'"${_YANDEX_FOLDER_NAME}"'\2/g' \
  "$(git rev-parse --show-toplevel)/terraform.tfvars" > "$(git rev-parse --show-toplevel)/override.auto.tfvars"
```
## create service ac for terraform
```console
yc iam service-account create --name "${_TERRAFORM_SERVICE_ACC_NAME}" --description "terraform acc for autoscaling instance group demo" --folder-name "${_YANDEX_FOLDER_NAME}"
```
## grant roles to created terraform service acc
```console
yc resource-manager folder add-access-binding --role admin --service-account-name "${_TERRAFORM_SERVICE_ACC_NAME}" "${_YANDEX_FOLDER_NAME}" --folder-name "${_YANDEX_FOLDER_NAME}"
yc resource-manager cloud add-access-binding --role viewer --service-account-name "${_TERRAFORM_SERVICE_ACC_NAME}" "${_YANDEX_CLOUD_NAME}" --folder-name "${_YANDEX_FOLDER_NAME}"
```
## create and save authorization key for terraform service acc
```console
yc iam key create --service-account-name "${_TERRAFORM_SERVICE_ACC_NAME}" --folder-name "${_YANDEX_FOLDER_NAME}" --description 'for terraform cli' --output "$(git rev-parse --show-toplevel)/credentials.json"
```
## install terraform and packer dependencies
```console
tf init && p init config.pkr.hcl
```
## create cloud resource
```console
tf apply
```
## send messages to queue
```console
$(git rev-parse --show-toplevel)/generated_files/messages.sh
```
## monitor instance group VMs
```console
watch -n15 yc compute instance-group list-instances --folder-name "${_YANDEX_FOLDER_NAME}" --name queue-autoscale-ig-demo
```
## delete instance_group
```console
yc compute instance-group delete --name $(tf output -raw instance_group_name)
```
## delete packer image
```console
yc compute image delete --name $(tf output -raw packer_image_name)
```
## destroy created resources
```console
tf destroy
```
## delete service acc for instance_group
```console
yc iam service-account delete --name queue-autoscale-sa
```
## delete terraform service acc
```console
yc iam service-account delete "${_TERRAFORM_SERVICE_ACC_NAME}"
```
