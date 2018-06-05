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

variable "resource_group" {
  default = "TestCore"
}

variable "location" {
  default = "westus"
}

variable "virtual_network_name" {
  default = "vnet"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.2.0/24"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.virtual_network_name}"
  location            = "${var.location}"
  address_space       = ["${var.address_space}"]
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.rg_prefix}subnet"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.subnet_prefix}"
}

module "azure_coreos1" {
  source = "github.com/shawnj/terraform//modules/azurelinuxvm"

  image_offer     = "CoreOS"
  image_sku       = "Stable"
  image_publisher = "CoreOS"
  image_version   = "latest"

  admin_username   = "${var.admin_username}"
  admin_password   = "${var.admin_password}"
  disable_password = true
  ssh_key          = "keydata.key"

  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  subscription_id = "${var.subscription_id}"
  tenant_id       = "${var.tenant_id}"

  hostname       = "TestCoreOSVM1"
  resource_group = "TestCore"
  location       = "westus"
  rg_prefix      = "tc"

  subnet_id = "${azurerm_subnet.subnet.id}"
}

