variable "region" {
  default = "us-west-2"
}

variable "aws_access_key" {
  default = ""
}

variable "aws_secret_key" {
  default = ""
}

#provider "aws" {
# access_key = "${var.aws_access_key}"
#  secret_key = "${var.aws_secret_key}"
#  region     = "${var.region}"

#  skip_credentials_validation = true
#}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-2017.09.1.20180307-x86_64-ebs",
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws.secret_key}"
  region         = "us-west-2"

  #enable_nat_gateway = true
  #enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "example"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

  tags {
    Environment = "dev"
  }
}

module "ec2vm" {
  source = "github.com/shawnj/terraform//modules/awslinuxvm"

  name           = "TestVM"
  instance_count = 1

  ami                    = "${data.aws_ami.amazon_linux.id}"
  instance_type          = "t2.micro"
  monitoring             = false
  vpc_security_group_ids = ["${module.security_group.this_security_group_id}"]
  subnet_id              = "${module.vpc.private_subnets[0]}"

  tags {
    Environment = "dev"
  }
}
