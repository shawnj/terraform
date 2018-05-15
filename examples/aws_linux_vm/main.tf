variable "region" {
  default = "us-west-2"
}

variable "aws_access_key" {
  default = ""
}

variable "aws_secret_key" {
  default = ""
}

variable "public_key" {
  default = ""
}

variable "vm_name" {
  default = "TestVM"
}

variable "keypair_name" {
  default = "none"
}

provider "aws" {
 access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"

  skip_credentials_validation = true
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-2018.03.0.20180412-x86_64-ebs",
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

  azs             = ["us-west-2a"]
  private_subnets = ["10.0.1.0/24"]

  #enable_nat_gateway = true
  #enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

#variable "vpc_ready" {
#  description = "Use this variable to ensure the Network ACL does not get created until the VPC is ready. This can help to work around a Terraform or AWS issue where trying to create certain resources, such as Network ACLs, before the VPC's Gateway and NATs are ready, leads to a huge variety of eventual consistency bugs. You should typically point this variable at the vpc_ready output from the Gruntwork VPCs."
#}

resource "null_resource" "vpc_ready" {
  triggers {
    # Explicitly wait on the passed in vpc_ready variable
    vpc_ready = "${module.vpc.vpc_id}"
  }
}

resource "null_resource" "instance_ready" {
  triggers {
    # Explicitly wait on the passed in vpc_ready variable
    instance_ready = "${module.ec2vm.id[0]}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${module.vpc.vpc_id}"
  depends_on = ["null_resource.vpc_ready"]
}

resource "aws_eip" "default" {
  instance = "${module.ec2vm.id[0]}"
  vpc      = true
  depends_on = ["aws_internet_gateway.gw","null_resource.instance_ready"]
}

resource "aws_route" "ssh_access" {
  route_table_id         = "${module.vpc.private_route_table_ids[0]}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

module "security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "example"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp", "ssh-tcp"]
  egress_rules        = ["all-all"]

  tags {
    Environment = "dev"
  }
}

module "ec2vm" {
  source = "github.com/shawnj/terraform//modules/awslinuxvm"

  name           = "${var.vm_name}"
  instance_count = 1

  ami                    = "${data.aws_ami.amazon_linux.id}"
  instance_type          = "t2.micro"
  monitoring             = false
  vpc_security_group_ids = ["${module.security_group.this_security_group_id}"]
  subnet_id              = "${module.vpc.private_subnets[0]}"

  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  region         = "us-west-2"

  key_name = "${var.keypair_name}"

  tags {
    Environment = "dev"
  }
}
