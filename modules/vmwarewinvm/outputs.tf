output "ip" {
  value = "${vsphere_virtual_machine.Win2016TestVM.clone.0.customize.0.network_interface.0.ipv4_address}"
}
output "vmName" {
  value = "${vsphere_virtual_machine.Win2016TestVM.name}"
}
output "notes" {
  value = "${vsphere_virtual_machine.Win2016TestVM.annotation}"
}

