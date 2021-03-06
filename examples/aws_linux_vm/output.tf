# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.vpc.vpc_id}"
}

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = ["${module.vpc.private_subnets}"]
}

#output "public_subnets" {
#  description = "List of IDs of public subnets"
#  value       = ["${module.vpc.public_subnets}"]
#}

# NAT gateways
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = ["${module.vpc.nat_public_ips}"]
}

output "lb_dns_name" {
  value = "${module.elb.this_elb_dns_name}"
}

output "igw" {
  value = "${aws_internet_gateway.gw.id}"
}

output "route_table" {
  value = "${module.vpc.private_route_table_ids[0]}"
}

#output "public_ip" {
#  value = "${aws_eip.default.public_ip}"
#}

