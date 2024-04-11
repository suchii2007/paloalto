provider "azurerm" {
  features {}
}

# Define your existing resources
resource "azurerm_resource_group" "example" {
  name     = "mydemo-appgw-rg"
  location = "eastus"
}

resource "azurerm_virtual_network" "example" {
  name                = "mydemo-vnet"
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
  location 	          = azurerm_resource_group.example.location
}

resource "azurerm_subnet" "example" {
  name                 = "appgw-snet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_web_application_firewall_policy" "example" {
  name                = "example-wafpolicy"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
  }
}
}

# Create an Azure Application Gateway with WAF_v2 SKU and private IP
resource "azurerm_application_gateway" "example" {
  name                 = "appgw-demo"
  resource_group_name  = azurerm_resource_group.example.name
  location             = azurerm_resource_group.example.location

   sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.example.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                          = "webfrontend"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.10"  
  }

  backend_address_pool {
    name = "webpool"
  }

  backend_http_settings {
    name                  = "httpsetting"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "httplistener"
    frontend_ip_configuration_name = "webfrontend"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "httprule"
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = "httplistener"
    backend_address_pool_name  = "webpool"
    backend_http_settings_name = "httpsetting"
  }

  firewall_policy_id = azurerm_web_application_firewall_policy.example.id

}
# Reference the existing Virtual Machine Scale Set (VMSS)
data "azurerm_virtual_machine_scale_set" "example" {
  name                = "vmss-demo"
  resource_group_name = "vmss-rg"
}

# Add the VMSS to the backend pool of the Application Gateway
resource "azurerm_application_gateway_backend_address_pool_vmss_association" "example" {
  application_gateway_name        = azurerm_application_gateway.example.name
  resource_group_name             = azurerm_resource_group.example.name
  backend_address_pool_name       = azurerm_application_gateway.example.backend_address_pool[0].name
  virtual_machine_scale_set_id    = data.azurerm_virtual_machine_scale_set.example.id
}





