# AWS EKS Cluster Configuration Demo

Terraform Codebase to Deploy AWS EKS Cluster and Configuration of Kubernetes Cluster resources.

## Usage
- Clone this repository
- Generate & setup IAM user Access & Secret Key
- Generate a AWS EC2 Key Pair in the region where you want to deploy stack
- Go to aws_eks directory
- Add the below variable values as Terraform Variables under workspace

### terraform.tfvars
```
keypair_name = "your-aws-keypair-name"

vpn_admin_password = "asdflkjhgqwerty1234"
```

- Add the below variable values as Environment Variables under workspace

### export
```
AWS_ACCESS_KEY_ID = "access_key"

AWS_SECRET_ACCESS_KEY = "secret_key"

AWS_DEFAULT_REGION = "eu-central-1"
```

- Modify backends.tf with your S3 Bucket & Dynamodb table for Terraform State & Lock
- Change other variables in variables.tf file if needed

```
terraform init

terraform plan

terraform apply -auto-approve -refresh=false
```

- Login to openvpn_access_server_ip with user as openvpn & vpn_admin_password
- Download the VPN connection profile
- Download & use OpenVPN client to connect to AWS VPC.
- Update your kubeconfig to connect to EKS cluster using kubectl or k9s

```
aws eks update-kubeconfig --region eu-central-1 --name aws-eks-k8s-demo-eks-cluster
```

- Add your Route53 Hosted zone & ACM certificate details under gen_variable_for_k8s.sh

```
chmod +x gen_variable_for_k8s.sh

./gen_variable_for_k8s.sh
```

- Next go to k8s directory
- Modify backends.tf with your S3 Bucket & Dynamodb table for Terraform State & Lock
- Change other variables in variables.tf file if needed

```
terraform init

terraform plan

terraform apply -auto-approve -refresh=false
```


### Login to Graffana
- Username: admin
- Password
`kubectl get secret prometheus-grafana -n prometheus -o jsonpath="{.data.admin-password}" | base64 --decode ; echo`
