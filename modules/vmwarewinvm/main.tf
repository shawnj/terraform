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

resource "vsphere_virtual_machine" "Win2016TestVM" {
  name             = "${var.vm_name}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "${var.vsphere_folder}"
  #count            = "${var.count}"
  num_cpus         = 2
  memory           = 4096
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

  connection {
    type     = "winrm"
    user     = "Administrator"
    password = "${var.admin_pw}"
    insecure = true
    https    = false
    host     = "${var.ip_addresses[0]}"
    port     = "5985"
    timeout  = "10m"
  }

  provisioner "chef" {
    environment             = "${var.chef_env}"
    node_name               = "${var.vm_name}"
    server_url              = "${var.chef_server_url}"
    recreate_client         = true
    user_name               = "${var.chef_user}"
    user_key                = "${file("${var.chef_user}.pem")}"
    secret_key              = "${file("data_sk.pem")}"
    run_list                = ["${var.run_list}"]
    fetch_chef_certificates = true
    ssl_verify_mode         = "verify_none"
    version                 = "13.6.4"
    attributes_json = <<-EOF
      {
        "TestCB": {
          "build_site":"${var.build_site}",
          "build_num": "${var.build_num}"
        }
      }
    EOF
  }
}
