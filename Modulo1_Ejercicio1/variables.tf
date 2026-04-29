variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-tfcurso-alumno17"
}

variable "admin_username" {
    description = "Admin username for the virtual machine"
    type        = string
    default     = "adminuser"
}

variable "admin_password" {
    description = "Admin password for the virtual machine"
    type        = string
}

variable "location" {
  description = "Azure region for the resources"
  type        = string
}