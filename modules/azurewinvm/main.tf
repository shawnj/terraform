#resource "azurerm_resource_group" "rg" {
#  name     = "${var.resource_group}"
#  location = "${var.location}"
#}

#resource "azurerm_virtual_network" "vnet" {
#  name                = "${var.virtual_network_name}"
#  location            = "${var.location}"
#  address_space       = ["${var.address_space}"]
#  resource_group_name = "${azurerm_resource_group.rg.name}"
#}

#resource "azurerm_subnet" "subnet" {
#  name                 = "${var.rg_prefix}subnet"
#  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
#  resource_group_name  = "${azurerm_resource_group.rg.name}"
#  address_prefix       = "${var.subnet_prefix}"
#}

resource "azurerm_network_interface" "nic" {
  name                = "${var.hostname}nic"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  ip_configuration {
    name                          = "${var.hostname}ipconfig"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.pip.id}"
    #load_balancer_backend_address_pools_ids = ["${var.backend_pool_ids}"]  
  }
}

resource "azurerm_public_ip" "pip" {
  name                         = "${var.rg_prefix}-ip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group}"
  public_ip_address_allocation = "Dynamic"
  domain_name_label            = "${var.dns_name}"
}


resource "azurerm_storage_account" "stor" {
  name                     = "${var.dns_name}stor"
  location                 = "${var.location}"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  account_tier             = "${var.storage_account_tier}"
  account_replication_type = "${var.storage_replication_type}"
}

resource "azurerm_managed_disk" "datadisk" {
  name                 = "${var.hostname}-datadisk"
  location             = "${var.location}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "40"
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.rg_prefix}vm"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]

  delete_data_disks_on_termination = true
  delete_os_disks_on_termination = true

  #availability_set_id = "${var.availability_set}"
  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  storage_os_disk {
    name              = "${var.hostname}-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  storage_data_disk {
    name              = "${var.hostname}-datadisk"
    managed_disk_id   = "${azurerm_managed_disk.datadisk.id}"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "100"
    create_option     = "Attach"
    lun               = 0
  }

  os_profile {
    computer_name  = "${var.hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }
  
  os_profile_windows_config {
    #winrm = ""
  }

  tags{
    environment = "staging"
  }
}
