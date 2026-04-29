variable "location" {
    type = string
    description = "Región de Azure en la que se despliega la infraestructura"
    default = "Asia Pacific East"
}

variable "environment" {
    type = string
    description = "Nombre del entorno de despliegue"

    validation {
        condition     = contains(["dev", "qa", "prod"], var.environment)
        error_message = "El entorno debe ser 'dev', 'qa' o 'prod'."
    }
}

variable "project_name" {
    type = string
    description = "Nombre del proyecto. Solo letras, números y guionnes"

    validation {
        condition = can(regex("^[a-zA-Z0-9-]+$", var.project_name))
        error_message = "El nombre del proyecto solo puede contener letras, números y guiones medios."
    }
}

variable "network_config" {
    type = object({
      vnet_cidr = string
      public_subnets = list(string)
      enable_nat_gateway = bool
    })

    description = "Configuración de la red virtual"

    validation {
        condition = can(cidrnetmask(var.network_config.vnet_cidr))
        error_message =  "El campo vnet_cidr en network_config debe ser un bloque CIDR válido."
    }

    validation {
        condition = length(var.network_config.public_subnets) > 0
        error_message = "El campo public_subnets en network_config debe contener al menos una subred."
    }
}

variable "vm_size" {
    type = map(string)
    description = "Mapa de tamaño de máquina virtual por nombre de entorno"
    default = {
        dev = "Standard_B1s"
        qa  = "Standard_B2s"
        prod = "Standard_D2s_v3"
    }
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

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-tfcurso-alumno17"
}