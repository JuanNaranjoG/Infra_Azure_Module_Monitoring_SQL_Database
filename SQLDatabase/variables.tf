variable "sql_databases" {
  description = "Mapa de instancias de Azure SQL Database a monitorear. La key es el nombre identificador y se usa en el nombre de la alerta."
  type = map(object({
    id = string
  }))
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos donde residen las instancias de Azure SQL Database"
  type        = string
}

variable "action_group_id" {
  description = "ID del Action Group para el envío de notificaciones"
  type        = string
}

####################
# Parámetros de alerta
####################
variable "metric_severity" {
  description = "Severidad de las alertas por métrica (0 = Critical, 1 = Error, 2 = Warning, 3 = Informational, 4 = Verbose)"
  type        = map(number)

  validation {
    condition     = alltrue([for k, v in var.metric_severity : v >= 0 && v <= 4])
    error_message = "La severidad debe estar entre 0 y 4."
  }
}

variable "frequency" {
  description = "Frecuencia de evaluación de la alerta. Ejemplos: PT1M, PT5M, PT15M, PT30M, PT1H"
  type        = string
  default     = "PT5M"
}

variable "window_size" {
  description = "Ventana de tiempo para la evaluación. Ejemplos: PT5M, PT10M, PT15M, PT30M, PT1H, PT6H, PT12H, P1D"
  type        = string
  default     = "PT15M"
}

####################
# Umbrales por métrica
####################
variable "thresholds" {
  description = <<-EOT
    Umbrales para cada métrica de Azure SQL Database. Valores por defecto:
      - connection_failed : 1  (Count)   — alerta si al menos 1 conexión falla
      - deadlock          : 1  (Count)   — alerta si ocurre al menos 1 deadlock
      - cpu_percent       : 90 (Percent) — alerta si el uso de CPU supera el 90%
  EOT
  type = object({
    connection_failed = number
    deadlock          = number
    cpu_percent       = number
  })
  default = {
    connection_failed = 1
    deadlock          = 1
    cpu_percent       = 90
  }
}

#####################
# Variables generales
#####################
variable "project" {
  description = "Nombre del proyecto o iniciativa"
  type        = string
}

variable "purpose" {
  description = "Propósito del recurso"
  type        = string
  default     = "monitoring"
}

variable "bdo_environment" {
  description = "Ambiente del recurso (Dev, QA, Prod, etc.)"
  type        = string
}

variable "resource_aditional_tags" {
  description = "Tags adicionales opcionales"
  type        = map(string)
  default     = {}
}

variable "resource_tags" {
  description = "Tags obligatorios BdO / Aval"
  type        = map(string)
  default     = {}
}

variable "name_sevice" {
  description = "Nombre del servicio a monitorear"
  type        = string
  default     = "Azure SQL Database"
}
