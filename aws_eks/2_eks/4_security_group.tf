# Name: security_group.tf
# Owner: Saurav Mitra
# Description: This terraform config will create the Security Group for EKS Cluster

resource "aws_security_group" "eks_sg" {
  name        = "${var.prefix}_eks_sg"
  description = "Security Group for Kubernetes"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.prefix}-eks-sg"
    Env   = var.env
    Owner = var.owner
    "kubernetes.io/cluster/${var.prefix}-eks-cluster" : "owned"
  }
}
