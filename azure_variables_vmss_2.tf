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

