output "public_ip" {
  value = "${azurerm_public_ip.pip.ip_address}"
}

output "vmName" {
  value = "${azurerm_virtual_machine.vm.name}"
}


