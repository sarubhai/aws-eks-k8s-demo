# Name: aws_node_termination_handler.tf
# Owner: Saurav Mitra
# Description: This terraform config will install AWS Node Termination Handler in EKS Cluster
# https://github.com/aws/aws-node-termination-handler/blob/main/config/helm/aws-node-termination-handler/README.md
# https://artifacthub.io/packages/helm/aws/aws-node-termination-handler

# THIS IS NOT REQUIRED, AS WE ARE USING EKS MANAGED NODE GROUPS
/*
resource "helm_release" "termination_handler" {
  name       = "termination-handler"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-node-termination-handler"
  namespace  = "kube-system"
  version    = "0.21.0"
}
*/
