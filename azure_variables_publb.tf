# Define the variables
variable "resource_group_name" {
  description = "The name of the existing resource group where the public load balancer will be created."
}

variable "location" {
  description = "The Azure region where the resources will be deployed."
}

variable "lb_name" {
  description = "The name of the public load balancer."
}

variable "public_ip_address_name_data" {
  description = "The name of the public IP address."
}

variable "public_ip_address_name_mgmt" {
  description = "The name of the public IP address."
}

variable "frontend_ip_configuration_name_data" {
  description = "The name of the frontend IP configuration."
}

variable "frontend_ip_configuration_name_mgmt" {
  description = "The name of the frontend IP configuration."
}