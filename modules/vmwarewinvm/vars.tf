variable "vsphere_user" {
  default = ""
}

variable "vsphere_password" {}

variable "vsphere_server" {
  default = ""
}

variable "datacenter" {
  default = ""
}

variable "vsphere_domain" {
  default = ""
}

variable "vsphere_resource_pool" {
  default = ""
}

variable "vsphere_datastore" {
  default = ""
}

variable "vsphere_template" {
  default = ""
}

variable "vsphere_folder" {
  default = ""
}

variable "vsphere_network_label" {
  default = ""
}

variable "ip_addresses" {

}

variable "ip_gateway" {

}

variable "chef_env" {
  default = "_default"
}

variable "vm_name" {
  default = ""
}

variable "dns_servers" {

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
  default = ""
}

variable "annotation" {
  default = "Win2016S-Stage - Test Build.  Ok to delete. ver 0.1.15"
}

variable "run_list" {
  default = [""]
}

variable "chef_user" {
  default = ""
}

variable "chef_server_url" {
  default = ""
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

variable "cpu_count" {
   default =   "2"
}

variable "memory" {
   default =   "4096"
}