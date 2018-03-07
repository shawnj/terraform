variable "vsphere_user" {
  default = ""
}

variable "vsphere_password" {}

variable "vsphere_server" {
  default = "llceozvc01.pemcoins.net"
}

variable "datacenter" {
  default = "Liberty Lake"
}

variable "vsphere_domain" {
  default = "pemcoins.net"
}

variable "vsphere_resource_pool" {
  default = "LibLake Development Cluster/Resources"
}

variable "vsphere_datastore" {
  default = "Development Datastore Cluster/VM-Dev-05"
}

variable "vsphere_template" {
  default = "Terraform2016"
}

variable "vsphere_folder" {
  default = "Development Environment/Operation Zone/Web Servers"
}

variable "vsphere_network_label" {
  default = "Dev_OZ_Vlan2171_Web"
}

variable "ip_addresses" {
  default = [
    "10.2.171.60",
  ]
}

variable "ip_gateway" {
  default = "10.2.171.1"
}

variable "chef_env" {
  default = "_default"
}

variable "vm_name" {
  default = ""
}

variable "dns_servers" {
  type    = "list"
  default = ["10.1.11.21", "10.2.11.22", "10.2.11.21"]
}

variable "count" {
  default = "1"
}

variable "private_key" {
  type        = "string"
  description = "SSH private key file in .pem format corresponding to tectonic_vmware_ssh_authorized_key. If not provided, SSH agent will be used."
  default     = "id_rsa"
}

variable "admin_pw" {
  default = "NewPass!3"
}

variable "annotation" {
  default = "Win2016S-Stage - Test Build.  Ok to delete. ver 0.1.15"
}

variable "run_list" {
  default = ["recipe[TestCB::default]"]
}

variable "chef_user" {
  default = "srv_devops_chef"
}

variable "chef_server_url" {
  default = "https://sememzap21.pemcoins.net/organizations/dev"
}

variable "az_access_key" {
  default = ""
}

variable "az_storage_account_name" {
  default = ""
}

variable "az_container_name" {
  default = ""
}

variable "az_blob_key" {
  default = ""
}

variable "build_site"{
  default = ""
}

variable "build_num" {
   default =   ""
}