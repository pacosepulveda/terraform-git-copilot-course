variable "location" {
    type = string
    description = "Región de Azure en la que se despliega la infraestructura"
    default = "Japan West"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-tfcurso-alumno17"
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

variable "vnet_cidr" {
    type = string
    description = "CIDR de la red virtual"
    default = "10.20.0.0/16"

    validation {
        condition     = can(cidrnetmask(var.vnet_cidr))
        error_message = "El CIDR de la red virtual no es válido."
    }
}

variable "subnets" {
    type = map(object({
        cidr   = string
        allow_http = bool
        allow_private_app = bool
    }))

    description = "Mapa de subredes con su CIDR y permisos"

    default = {
        "web" = {
            cidr   = "10.20.1.0/24"
            allow_http = true
            allow_private_app = false
        }

        "app" = {
            cidr   = "10.20.2.0/24"
            allow_http = false
            allow_private_app = true
        }

        "db" = {
            cidr   = "10.20.3.0/24"
            allow_http = false
            allow_private_app = false
        }
    }

    validation {
        condition = alltrue([for subnet in var.subnets : can(cidrnetmask(subnet.cidr))])
        error_message = "Todas las subredes deben tener un CIDR válido"
    }
}

variable "create_diagnostics_storage" {
    type = bool
    description = "Indica si se debe crear una cuenta de almacenamiento para diagnósticos"
    default = false
}

variable "allowed_admin_cidr" {
    type = string
    description = "CIDR permitido para acceso administrativo"
    default = "0.0.0.0/0"

    validation {
        condition     = can(cidrnetmask(var.allowed_admin_cidr))
        error_message = "El CIDR permitido para acceso administrativo no es válido."
    }
}