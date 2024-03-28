provider "azurerm" {
  features {}
}

# Define the variables
variable "resource_group_name" {
  description = "The name of the existing resource group where the private load balancer will be created."
}

variable "location" {
  description = "The Azure region where the resources will be deployed."
}

variable "lb_name" {
  description = "The name of the private load balancer."
}

variable "subnet_id" {
  description = "The ID of the subnet to associate with the private load balancer."
}

# Create the load balancer
resource "azurerm_lb" "pvtlb" {
  name                = var.lb_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku		      = "Standard"

  frontend_ip_configuration {
    name                          = "PrivateFrontend"
    subnet_id                     = var.subnet_id
  }
}

# Output the private IP address of the load balancer
output "private_ip_address" {
  value = azurerm_lb.pvtlb.private_ip_address
}
