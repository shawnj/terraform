data "vsphere_datacenter" "dc" {
  name = "${var.datacenter}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.vsphere_datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.vsphere_resource_pool}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "${var.vsphere_network_label}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.vsphere_template}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "null_resource" "disk_prefix" {
  triggers = {
    prefix = "${var.vm_name}"
  }

  lifecycle {
    ignore_changes = [
      "triggers",
    ]
  }
}

resource "vsphere_virtual_machine" "vSphereVM" {
  name             = "${var.vm_name}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "${var.vsphere_folder}"
  #count            = "${var.count}"
  num_cpus         = "${var.cpu_count}"
  memory           = "${var.memory}"
  annotation       = "${var.annotation}"
  guest_id         = "windows9Server64Guest"

  network_interface {
    network_id = "${data.vsphere_network.network.id}"
  }

  disk {
    name             = "${null_resource.disk_prefix.triggers.prefix}.vmdk"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  disk {
    name        = "${null_resource.disk_prefix.triggers.prefix}_1.vmdk"
    size        = 40
    unit_number = 1
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      network_interface {
        ipv4_address = "${var.ip_addresses[0]}"
        ipv4_netmask = 24
      }

      ipv4_gateway    = "${var.ip_gateway}"
      dns_server_list = "${var.dns_servers}"
      
      windows_options {
        computer_name  = "${var.vm_name}"
        admin_password = "${var.admin_pw}"
      }

      #windows_sysprep_text = "${file("${path.module}/sysprep.xml")}"
    }
  }
}
