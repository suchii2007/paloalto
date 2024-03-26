provider "azurerm" {
  features {}
}

# Define variables
variable "resource_group_name" {
  description = "The name of the existing resource group where resources will be created."
}

variable "location" {
  description = "The Azure region where resources will be deployed."
}

variable "vmss_name" {
  description = "The name of the Virtual Machine Scale Set."
}

variable "admin_username" {
  description = "The admin username for the virtual machines."
}

variable "admin_password" {
  description = "The admin password for the virtual machines."
}

variable "subnet_ids" {
  description = "List of subnet IDs to attach to the VMSS NICs. The first subnet is for the public LB and the second for the private LB."
  type = list(string)
}

variable "paloalto_image_publisher" {
  description = "The publisher of the Palo Alto Networks image."
}

variable "paloalto_image_offer" {
  description = "The offer of the Palo Alto Networks image."
}

variable "paloalto_image_sku" {
  description = "The SKU of the Palo Alto Networks image."
}

variable "paloalto_image_version" {
  description = "The version of the Palo Alto Networks image."
}

variable "data_port" {
  description = "The Health Probe port."
}

variable "mgmt_port" {
  description = "The Health Probe port."
}

variable "public_lb_name" {
  description = "The Public Load Balancer Name."
}

data "azurerm_lb" "public" {
  name                = var.public_lb_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_lb_backend_address_pool" "databpepool" {
  loadbalancer_id = data.azurerm_lb.public.id
  name            = "fw-data-backend-pool"
}


resource "azurerm_lb_backend_address_pool" "mgmtbpepool" {
  loadbalancer_id = data.azurerm_lb.public.id
  name            = "fw-mgmt-backend-pool"
}

resource "azurerm_lb_probe" "data" {
  loadbalancer_id     = data.azurerm_lb.public.id
  name                = "fw-data-health-probe"
  port                = var.data_port
}

resource "azurerm_lb_probe" "mgmt" {
  loadbalancer_id     = data.azurerm_lb.public.id
  name                = "fw-mgmt-health-probe"
  port                = var.mgmt_port
}

resource "azurerm_lb_rule" "lbdatarule" {
  loadbalancer_id                = data.azurerm_lb.public.id
  name                           = "fw-data-lb-rule"
  protocol                       = "Tcp"
  frontend_port                  = var.data_port
  backend_port                   = var.data_port
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.databpepool.id]
  frontend_ip_configuration_name = data.azurerm_lb.public.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.data.id
}

resource "azurerm_lb_rule" "lbmgmtrule" {
  loadbalancer_id                = data.azurerm_lb.public.id
  name                           = "fw-mgmt-lb-rule"
  protocol                       = "Tcp"
  frontend_port                  = var.mgmt_port
  backend_port                   = var.mgmt_port
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.mgmtbpepool.id]
  frontend_ip_configuration_name = data.azurerm_lb.public.frontend_ip_configuration[1].name
  probe_id                       = azurerm_lb_probe.mgmt.id
}

resource "azurerm_virtual_machine_scale_set" "vmss" {
  name                = var.vmss_name
  location            = var.location
  resource_group_name = var.resource_group_name
  upgrade_policy_mode = "Manual"

  sku {
    name     = "Standard_DS3_v2"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    publisher = var.paloalto_image_publisher
    offer     = var.paloalto_image_offer
    sku       = var.paloalto_image_sku
    version   = var.paloalto_image_version
  }
  plan {
    publisher = var.paloalto_image_publisher
    product   = var.paloalto_image_offer
    name      = var.paloalto_image_sku
  }
  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "vmlab"
    admin_username       = var.admin_username
    admin_password       = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  network_profile {
    name    = "nic-data"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = var.subnet_ids[1]
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.databpepool.id]
      primary                                = true
    }
  }
  network_profile {
    name    = "nic-mgmt"
    primary = false

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = var.subnet_ids[0]
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.mgmtbpepool.id]
      primary                                = true
    }
  }
}
