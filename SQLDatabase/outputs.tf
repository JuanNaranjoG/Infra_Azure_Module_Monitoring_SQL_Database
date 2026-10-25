output "sql_database_monitor_metric" {
  description = "Salidas para todas las alertas de monitoreo, agrupadas por instancia de SQL Database y métrica"
  value = {
    for key in keys(var.sql_databases) : key => {
      connection_failed = {
        id   = azurerm_monitor_metric_alert.connection_failed[key].id
        name = azurerm_monitor_metric_alert.connection_failed[key].name
      }

      deadlock = {
        id   = azurerm_monitor_metric_alert.deadlock[key].id
        name = azurerm_monitor_metric_alert.deadlock[key].name
      }

      cpu_percent = {
        id   = azurerm_monitor_metric_alert.cpu_percent[key].id
        name = azurerm_monitor_metric_alert.cpu_percent[key].name
      }
    }
  }
}
