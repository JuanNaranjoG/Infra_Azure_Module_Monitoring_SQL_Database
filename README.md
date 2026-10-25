# 🗄️ Azure SQL Database Monitoring Module (Azure)

This Terraform module provisions **Azure Monitor metric alerts for Azure SQL Database**.

It is designed as a reusable module that supports monitoring **multiple SQL Database instances** using a single, unified variable, following the same design standards as other monitoring modules.

The module monitors **failed connections, deadlocks, and CPU usage** from the `Microsoft.Sql/servers/databases` namespace and sends notifications through an **Azure Monitor Action Group**.

---

### 🚀 Usage

```hcl
module "sql_database_monitoring" {
  source = "git::git@github.com:bocc-principal/Infra_Azure_Module_Monitoring_SQL_Database.git//SQLDatabase?ref=1.0.0"

  sql_databases = {
    BasePrincipal = {
      id = azurerm_mssql_database.base_principal.id
    }

    # BaseSecundaria = {
    #   id = azurerm_mssql_database.base_secundaria.id
    # }

    # Ejemplo con ID hardcodeado:
    # sql-gestion-prod = {
    #   id = "/subscriptions/3eba9cfb-6349-4491-b43c-2d3a76ded2a2/resourceGroups/RG-Monitoreo/providers/Microsoft.Sql/servers/sql-server-prod/databases/sql-gestion-prod"
    # }
  }

  resource_group_name = azurerm_resource_group.rg-monitoreo.name
  action_group_id     = azurerm_monitor_action_group.monitoring_ag.id
  project             = "Gestion_TI"
  bdo_environment     = "env"
  resource_tags       = module.tags.common-tags

  thresholds = {
    connection_failed = 1   # Count   — alerta si al menos 1 conexión falla
    deadlock          = 1   # Count   — alerta si ocurre al menos 1 deadlock
    cpu_percent       = 90  # Percent — alerta si el uso de CPU supera el 90%
  }

  metric_severity = {
    connection_failed = 1  # Error
    deadlock          = 0  # Critical
    cpu_percent       = 2  # Warning
  }
}
```

> 💡 **Note:** Only define the SQL Database instances you want to monitor. The map key is used as an identifier in the name of each alert.

---

## 🔔 Action Group Configuration (Required)

```hcl
resource "azurerm_monitor_action_group" "monitoring_ag" {
  name                = "ag-monitoring-${var.project}"
  resource_group_name = var.resource_group_name
  short_name          = "mon-ag"

  email_receiver {
    name          = "correo1"
    email_address = "correo1@bancodeoccidente.com.co"
  }

  email_receiver {
    name          = "correo2"
    email_address = "correo2@bancodeoccidente.com.co"
  }
}
```

> 💡 **Note:** The Action Group must exist before applying this module. Pass its ID via the `action_group_id` variable.

---

### ✅ Requirements

| Name             | Version |
| ---------------- | ------- |
| Terraform        | >= 1.0  |
| AzureRM Provider | >= 3.0  |

---

### 📊 Monitored Metrics (Microsoft.Sql/servers/databases)

| Metric_Name       | Descripción                                                              | metric_namespace                    | Operator           | Severity | Frequency | window_size | Aggregation | Threshold  |
| ----------------- | ------------------------------------------------------------------------ | ----------------------------------- | ------------------ | -------- | --------- | ----------- | ----------- | ---------- |
| connection_failed | Conexiones a la base de datos que fallan (Count).                        | Microsoft.Sql/servers/databases     | GreaterThanOrEqual | 1        | PT5M      | PT15M       | Total       | >= 1       |
| deadlock          | Número de deadlocks ocurridos en la base de datos (Count).               | Microsoft.Sql/servers/databases     | GreaterThanOrEqual | 0        | PT5M      | PT15M       | Total       | >= 1       |
| cpu_percent       | Porcentaje de CPU utilizado por la base de datos (Percent).              | Microsoft.Sql/servers/databases     | GreaterThan        | 2        | PT5M      | PT15M       | Average     | > 90 %     |

---

### 🔔 Azure Monitor Alerts

#### ❌ Connection Failed

Fires when at least one connection to the SQL Database fails within the evaluation window. Connection failures can indicate authentication issues, network problems, firewall misconfigurations, or the database being under excessive load.

- Metric: `connection_failed`
- Unit: Count
- Aggregation: Total
- Operator: GreaterThanOrEqual
- Default threshold: **1** (`connection_failed = 1`)
- Default severity: **1 (Error)**

> ⚠️ **Important:** Las conexiones fallidas pueden ser transitorias o persistentes. Revise los registros de actividad y los errores de conexión en el portal de Azure. Causas frecuentes incluyen credenciales incorrectas, restricciones de firewall, o saturación del pool de conexiones.

#### 🔒 Deadlock

Fires when at least one deadlock is detected in the SQL Database. Deadlocks occur when two or more transactions block each other indefinitely, forcing the database engine to terminate one of them.

- Metric: `deadlock`
- Unit: Count
- Aggregation: Total
- Operator: GreaterThanOrEqual
- Default threshold: **1** (`deadlock = 1`)
- Default severity: **0 (Critical)**

> ⚠️ **Important:** Los deadlocks indican conflictos de bloqueo entre transacciones concurrentes. Analice el grafo de deadlocks en el Extended Events o en el Query Store para identificar las consultas involucradas. Soluciones comunes incluyen revisar el orden de acceso a tablas, reducir la duración de transacciones, y agregar índices adecuados.

#### 🔥 CPU Percent

Monitors the average CPU percentage consumed by the SQL Database. Sustained high CPU usage can indicate expensive queries, missing indexes, or the need to scale up the service tier.

- Metric: `cpu_percent`
- Unit: Percent (%)
- Aggregation: Average
- Operator: GreaterThan
- Default threshold: **90 %** (`cpu_percent = 90`)
- Default severity: **2 (Warning)**

> ⚠️ **Important:** Un uso de CPU sostenido por encima del 90% puede causar degradación en el rendimiento de las consultas. Utilice el Query Performance Insight en el portal de Azure para identificar las consultas más costosas. Considere optimizar índices, reescribir consultas ineficientes, o escalar el nivel de servicio (DTU/vCore).

---

### ⚙️ Input Variables

#### Required

| Name                | Type                                 | Description                                                                                                                                    |
| ------------------- | ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| sql_databases       | `map(object({ id = string }))`       | Map of SQL Database instances to monitor. The key is used as an identifier in each alert name                                                  |
| resource_group_name | `string`                             | Name of the resource group where the SQL Database instances reside                                                                             |
| action_group_id     | `string`                             | ID of the Action Group used for sending notifications                                                                                          |
| metric_severity     | `map(number)`                        | Severity per metric (0=Critical, 1=Error, 2=Warning, 3=Informational, 4=Verbose). Keys: `connection_failed`, `deadlock`, `cpu_percent`        |
| project             | `string`                             | Project or initiative name                                                                                                                     |
| bdo_environment     | `string`                             | Resource environment (Dev, QA, Prod, etc.)                                                                                                     |

#### Optional

| Name                    | Type                                                                | Default              | Description                                    |
| ----------------------- | ------------------------------------------------------------------- | -------------------- | ---------------------------------------------- |
| thresholds              | `object({ connection_failed, deadlock, cpu_percent })`              | See variables.tf     | Thresholds per metric                          |
| frequency               | `string`                                                            | `PT5M`               | Alert evaluation frequency                     |
| window_size             | `string`                                                            | `PT15M`              | Time window for evaluation                     |
| purpose                 | `string`                                                            | `monitoring`         | Purpose of the resource                        |
| name_sevice             | `string`                                                            | `Azure SQL Database` | Name of the service being monitored            |
| resource_tags           | `map(string)`                                                       | `{}`                 | Mandatory BdO / Aval tags                      |
| resource_aditional_tags | `map(string)`                                                       | `{}`                 | Optional additional tags                       |

---

### 📤 Outputs

#### sql_database_monitor_metric

Returns all alerts created by the module, grouped by SQL Database instance and metric.

```hcl
sql_database_monitor_metric = {
  BasePrincipal = {
    connection_failed = {
      id   = "/subscriptions/.../metricAlerts/Gestion_TI-BasePrincipal-connection-failed-prod"
      name = "Gestion_TI-BasePrincipal-connection-failed-prod"
    }
    deadlock = {
      id   = "/subscriptions/.../metricAlerts/Gestion_TI-BasePrincipal-deadlock-prod"
      name = "Gestion_TI-BasePrincipal-deadlock-prod"
    }
    cpu_percent = {
      id   = "/subscriptions/.../metricAlerts/Gestion_TI-BasePrincipal-cpu-percent-prod"
      name = "Gestion_TI-BasePrincipal-cpu-percent-prod"
    }
  }
}
```

---

### 🧠 Notes

- This module uses the namespace `Microsoft.Sql/servers/databases` compatible with Azure SQL Database (single databases and elastic pools).
- `connection_failed` and `deadlock` use `GreaterThanOrEqual` with threshold `1` — any occurrence triggers the alert immediately without waiting for an accumulation.
- `cpu_percent` measures the average CPU over the evaluation window. Transient spikes may not trigger the alert if the average stays below the threshold.
- Severity must be between **0 (Critical)** and **4 (Verbose)**.
- The Action Group must exist beforehand — this module does not create it.
- Alerts are created using `for_each` per database instance, allowing each alert to be managed independently in the Terraform state.

---

### 📘 References

- Azure Monitor Supported Metrics for SQL Database:
  https://learn.microsoft.com/en-us/azure/azure-monitor/reference/supported-metrics/microsoft-sql-servers-databases-metrics

- Monitoring Azure SQL Database:
  https://learn.microsoft.com/en-us/azure/azure-sql/database/monitor-tune-overview

- Azure SQL Database Metrics Reference:
  https://learn.microsoft.com/en-us/azure/azure-sql/database/monitoring-sql-database-azure-monitor

- Azure Monitor Metric Alerts:
  https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-metric-overview

- AzureRM Provider – Monitor Metric Alert:
  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert

- AzureRM Provider – MSSQL Database:
  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database
