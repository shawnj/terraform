resource "azurerm_network_interface" "nic" {
  name                = "${var.hostname}nic"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"

  ip_configuration {
    name                          = "${var.hostname}ipconfig"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.pip.id}"
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
  name                     = "${var.rg_prefix}stor"
  location                 = "${var.location}"
  resource_group_name      = "${var.resource_group}"
  account_tier             = "${var.storage_account_tier}"
  account_replication_type = "${var.storage_replication_type}"
}

resource "azurerm_managed_disk" "datadisk" {
  name                 = "${var.hostname}-datadisk"
  location             = "${var.location}"
  resource_group_name  = "${var.resource_group}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "40"
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.hostname}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]

  delete_data_disks_on_termination = true
  delete_os_disk_on_termination = true

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
    custom_data    = "${var.custom_data}"
  }
  
  os_profile_linux_config {
    disable_password_authentication = "${var.disable_password}"
    ssh_keys = {
      key_data = "${file("${var.ssh_key}")}"
      path = "/home/${var.admin_username}/.ssh/authorized_keys"
    }
  }

  tags{
    environment = "staging"
  }
}
