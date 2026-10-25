####################################################################################################
# Alerta: Conexiones fallidas
# Dispara cuando al menos una conexión a la base de datos falla en la ventana de evaluación
####################################################################################################
resource "azurerm_monitor_metric_alert" "connection_failed" {
  for_each = var.sql_databases

  name                = "${var.project}-${each.key}-connection-failed-${var.bdo_environment}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alerta de conexiones fallidas del Azure SQL Database"
  severity            = var.metric_severity["connection_failed"]
  frequency           = var.frequency
  window_size         = var.window_size

  criteria {
    metric_namespace = local.namespace
    metric_name      = "connection_failed"
    aggregation      = "Total"
    operator         = "GreaterThanOrEqual"
    threshold        = var.thresholds.connection_failed
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = merge(
    {
      Name              = "${var.project}-${each.key}-connection-failed-${var.bdo_environment}"
      bdo-resource-type = "global"
    },
    var.resource_aditional_tags != null ? var.resource_aditional_tags : {},
    var.resource_tags
  )
}

####################################################################################################
# Alerta: Deadlocks
# Dispara cuando ocurre al menos un deadlock en la base de datos dentro de la ventana de evaluación
####################################################################################################
resource "azurerm_monitor_metric_alert" "deadlock" {
  for_each = var.sql_databases

  name                = "${var.project}-${each.key}-deadlock-${var.bdo_environment}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alerta de deadlocks del Azure SQL Database"
  severity            = var.metric_severity["deadlock"]
  frequency           = var.frequency
  window_size         = var.window_size

  criteria {
    metric_namespace = local.namespace
    metric_name      = "deadlock"
    aggregation      = "Total"
    operator         = "GreaterThanOrEqual"
    threshold        = var.thresholds.deadlock
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = merge(
    {
      Name              = "${var.project}-${each.key}-deadlock-${var.bdo_environment}"
      bdo-resource-type = "global"
    },
    var.resource_aditional_tags != null ? var.resource_aditional_tags : {},
    var.resource_tags
  )
}

####################################################################################################
# Alerta: Uso de CPU
# Monitorea el porcentaje de CPU utilizado por la base de datos. Alta utilización puede indicar
# consultas costosas, falta de índices, o necesidad de escalar el nivel de servicio.
####################################################################################################
resource "azurerm_monitor_metric_alert" "cpu_percent" {
  for_each = var.sql_databases

  name                = "${var.project}-${each.key}-cpu-percent-${var.bdo_environment}"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.id]
  description         = "Alerta de uso de CPU del Azure SQL Database"
  severity            = var.metric_severity["cpu_percent"]
  frequency           = var.frequency
  window_size         = var.window_size

  criteria {
    metric_namespace = local.namespace
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.thresholds.cpu_percent
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = merge(
    {
      Name              = "${var.project}-${each.key}-cpu-percent-${var.bdo_environment}"
      bdo-resource-type = "global"
    },
    var.resource_aditional_tags != null ? var.resource_aditional_tags : {},
    var.resource_tags
  )
}
