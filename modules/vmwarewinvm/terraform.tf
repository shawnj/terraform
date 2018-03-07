terraform {
  backend "azurerm" {}
}

data "terraform_remote_state" "state" {
  backend = "azurerm"

  config {
    storage_account_name = "${var.az_storage_account_name}"
    container_name       = "${var.az_container_name}"
    key                  = "${var.az_blob_key}"
    access_key           = "${var.az_access_key}"
  }
}
