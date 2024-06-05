#!/bin/bash
# Name: gen_variable_for_k8s.sh
# Owner: Saurav Mitra
# Description: Generate variable values as terraform.tfvars file in the k8s folder

# User Input
# Replace Below Accordingly
route53_zone_id="YourRoute53HostedZoneId"
route53_domain="YourDomainName"
acm_certificate_arn="YourAcmCertificateARN"


terraform output > ../k8s/terraform.tfvars

echo route53_zone_id=\"$route53_zone_id\"           >> ../k8s/terraform.tfvars
echo route53_domain=\"$route53_domain\"             >> ../k8s/terraform.tfvars
echo acm_certificate_arn=\"$acm_certificate_arn\"   >> ../k8s/terraform.tfvars

cd ../k8s
terraform fmt
