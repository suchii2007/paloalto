provider "azurerm" {
  features {}
}

# Create the public IP address
resource "azurerm_public_ip" "datapip" {
  name                = var.public_ip_address_name_data
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku		      = "Standard"
}

resource "azurerm_public_ip" "mgmtpip" {
  name                = var.public_ip_address_name_mgmt
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku		      = "Standard"
}
# Create the load balancer
resource "azurerm_lb" "publb" {
  name                = var.lb_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku		      = "Standard"

  frontend_ip_configuration {
    name                          = var.frontend_ip_configuration_name_data
    public_ip_address_id          = azurerm_public_ip.datapip.id
  }
  frontend_ip_configuration {
    name                          = var.frontend_ip_configuration_name_mgmt
    public_ip_address_id          = azurerm_public_ip.mgmtpip.id
  }
}

# Output the public IP address of the load balancer
output "public_ip_address_data" {
  value = azurerm_public_ip.datapip.ip_address
}
output "public_ip_address_mgmt" {
  value = azurerm_public_ip.mgmtpip.ip_address
}
