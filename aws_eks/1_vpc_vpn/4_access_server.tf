# Name: access_server.tf
# Owner: Saurav Mitra
# Description: This terraform config will create 1 EC2 intance as OpenVPN Access Server
# https://openvpn.net/vpn-server-resources/amazon-web-services-ec2-byol-appliance-quick-start-guide/

# Security Group
resource "aws_security_group" "openvpn_server_sg" {
  name        = "${var.prefix}_openvpn_server_sg"
  description = "Security Group for OpenVPN Access Server"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 945
    to_port     = 945
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.prefix}-openvpn-server-sg"
    Env   = var.env
    Owner = var.owner
  }
}


# OpenVPN AMI Filter
data "aws_ami" "openvpn" {
  owners      = var.openvpn_server_owners
  most_recent = true

  filter {
    name   = "name"
    values = [var.openvpn_server_ami_name]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# User Data Init
data "template_file" "init" {
  template = file("${path.module}/3_config_server.sh")

  vars = {
    VPN_ADMIN_USER     = var.vpn_admin_user
    VPN_ADMIN_PASSWORD = var.vpn_admin_password
    VPC_NAME_SERVER    = cidrhost(var.vpc_cidr_block, 2)
    VPC_CIDR_BLOCK     = var.vpc_cidr_block
  }
}


# EC2 Instance
resource "aws_instance" "openvpn_server" {
  ami                         = data.aws_ami.openvpn.id
  instance_type               = var.openvpn_server_instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet[0].id
  vpc_security_group_ids      = [aws_security_group.openvpn_server_sg.id]
  key_name                    = var.keypair_name
  source_dest_check           = false

  user_data = data.template_file.init.rendered

  root_block_device {
    volume_size           = 30
    delete_on_termination = true
  }

  tags = {
    Name  = "${var.prefix}-openvpn-server"
    Env   = var.env
    Owner = var.owner
  }
}