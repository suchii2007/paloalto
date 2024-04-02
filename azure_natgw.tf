provider "azurerm" {
  features {}
}

# Define variables
variable "prefixlength" {
  description = "The length of Public IP prefix."
}

variable "natgwpublicIpName" {
  description = "Public IP name for Nat Gateway"
}

variable "subnetid" {
  description = "SubnetId to associate to NAT Gateway"
}

variable "natgatewayName" {
  description = "NAT Gateway Name"
}


resource "azurerm_resource_group" "example" {
  name     = "natgw-rg"
  location = "eastus"
}


# Create Public IP Prefix
resource "azurerm_public_ip_prefix" "pipprefix" {
  name                = "acceptanceTestPublicIpPrefix1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  prefix_length = var.prefixlength

  tags = {
    environment = "Production"
  }
}

# Create Public IP
resource "azurerm_public_ip" "pip" {
  name                = var.natgwpublicIpName
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create NAT Gateway
resource "azurerm_nat_gateway" "natgw" {
  name                = var.natgatewayName
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = "Standard"
  idle_timeout_in_minutes = 10
}
resource "azurerm_nat_gateway_public_ip_prefix_association" "prefixassociate" {
  nat_gateway_id      = azurerm_nat_gateway.natgw.id
  public_ip_prefix_id = azurerm_public_ip_prefix.pipprefix.id
}
resource "azurerm_nat_gateway_public_ip_association" "pipassociate" {
  nat_gateway_id       = azurerm_nat_gateway.natgw.id
  public_ip_address_id = azurerm_public_ip.pip.id
}
resource "azurerm_subnet_nat_gateway_association" "subnetassociate" {
  subnet_id      = var.subnetid
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}