provider "azurerm" {
  features {}
}

locals {
  front_door_profile_name         = "MyFrontDoor"
  front_door_sku_name             = "Standard_AzureFrontDoor" // Must be premium for Private Link support.
  front_door_endpoint_name        = "myfd"
  front_door_origin_group_name    = "MyOriginGroup"
  front_door_origin_name          = "myOriginName"
  front_door_route_name           = "MyRoute"
  front_door_firewall_policy_name = "MyWAFPolicy"
  resource_group_name		  = "vmss-rg"
}

resource "azurerm_cdn_frontdoor_profile" "my_front_door" {
  name                = local.front_door_profile_name
  resource_group_name = local.resource_group_name
  sku_name            = local.front_door_sku_name
}

resource "azurerm_cdn_frontdoor_endpoint" "my_endpoint" {
  name                     = local.front_door_endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.my_front_door.id
}

resource "azurerm_cdn_frontdoor_origin_group" "my_origin_group" {
  name                     = local.front_door_origin_group_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.my_front_door.id
  session_affinity_enabled = true

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    path                = "/"
    request_type        = "HEAD"
    protocol            = "Https"
    interval_in_seconds = 100
  }
}

resource "azurerm_cdn_frontdoor_origin" "my_public_ip_origin" {
  name                          = local.front_door_origin_name
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.my_origin_group.id

  enabled                        = true
  host_name                      = "4.156.30.6"
  http_port                      = 80
  https_port                     = 443
  priority                       = 1
  weight                         = 1000
  certificate_name_check_enabled = true

}

resource "azurerm_cdn_frontdoor_route" "my_route" {
  name                          = local.front_door_route_name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.my_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.my_origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.my_public_ip_origin.id]

  supported_protocols       = ["Http", "Https"]
  patterns_to_match         = ["/*"]
  forwarding_protocol       = "HttpsOnly"
  link_to_default_domain    = true
  https_redirect_enabled    = true
}

resource "azurerm_cdn_frontdoor_firewall_policy" "my_waf_policy" {
  name                = local.front_door_firewall_policy_name
  resource_group_name = local.resource_group_name
  sku_name            = local.front_door_sku_name
  enabled             = true
  mode                = "Prevention"
}
