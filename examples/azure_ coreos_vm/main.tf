variable "admin_username" {
  description = "administrator user name"
  default     = ""
}

variable "admin_password" {
  description = "administrator password (recommended to disable password auth)"
}

variable "client_id" {
  description = ""
}

variable "client_secret" {
  description = ""
}

variable "subscription_id" {
  description = ""
}

variable "tenant_id" {
  description = ""
}

module "azure_coreos" {
  source = "github.com/shawnj/terraform//modules/azurelinuxvm"

  image_offer     = "CoreOS"
  image_sku       = "Stable"
  image_publisher = "CoreOS"
  image_version   = "latest"

  admin_username = "${var.admin_username}"
  #admin_password = "${var.admin_password}"
  disable_password = true
  ssh_key = "keydata.key"

  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  subscription_id = "${var.subscription_id}"
  tenant_id       = "${var.tenant_id}"

  hostname       = "TestCoreOSVM"
  resource_group = "TestCore"
  location       = "westus"
  rg_prefix      = "tc"
}
