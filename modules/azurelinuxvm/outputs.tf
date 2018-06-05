#output "ip" {
#  value = "${azurerm_virtual_machine.vm.network_interface.0.ipv4_address}"
#}

output "vmName" {
  value = "${azurerm_virtual_machine.vm.name}"
}


