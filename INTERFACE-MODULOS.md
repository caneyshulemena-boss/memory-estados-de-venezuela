# INTERFAZ DE MÓDULOS - ODOO PLATFORM v2.2.2
**Fecha:** 2026-02-12  
**Versión:** 2.2.2  
**Estado:** ESTABLE
---
## 1. ARQUITECTURA GENERAL
```
                    ┌─────────────────┐
                    │   config.sh     │
                    │  (solo vars)    │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ 00-bootstrap    │ (opcional)
                    │   (loader)      │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         ▼                   ▼                   ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ odoo_platform_  │  │ odoo_optimizer_ │  │  docker_setup   │
│   core.sh       │  │    lib.sh       │  │      .sh        │
│   (BASE)        │  │   (pura)        │  │   (Docker)      │
└────────┬────────┘  └────────┬────────┘  └────────┬────────┘
         │                    │                    │
         └───────────┬────────┴───────────┬────────┘
                     ▼                    ▼
           ┌─────────────────┐  ┌─────────────────┐
           │odoo_optimizer   │  │odoo_platform_   │
           │     .sh         │  │  deploy.sh      │
           └─────────────────┘  └────────┬────────┘
                                         ▼
                               ┌─────────────────┐
                               │odoo_platform_   │
                               │  clients.sh     │
                               └─────────────────┘
                                         ▼
                               ┌─────────────────┐
                               │odoo_platform_   │
                               │     ui.sh       │
                               └─────────────────┘
```
---
## 2. DEPENDENCIAS OBLIGATORIAS
| Módulo | Depende de | Tipo | Versión mínima |
|--------|-----------|------|----------------|
| `odoo_platform_core.sh` | Ninguno | Base | 2.2.2 |
| `odoo_optimizer_lib.sh` | Ninguno | Pura | 2.1.0+ |
| `docker_setup.sh` | `odoo_platform_core.sh` | Requerido | 2.2.2 |
| `odoo_platform_deploy.sh` | `odoo_platform_core.sh` | Requerido | 2.2.2 |
| `odoo_platform_clients.sh` | `odoo_platform_core.sh` | Requerido | 2.2.2 |
| `odoo_platform_ui.sh` | `odoo_platform_core.sh` | Requerido | 2.2.2 |
| `odoo_optimizer.sh` | `odoo_optimizer_lib.sh` | Requerido | 2.2.0 |
**REGLAS:**
1. Ningún módulo debe cargar otro módulo más de una vez
2. El core DEBE cargarse primero y UNA SOLA VEZ
3. Las funciones de logging y confirmación DEBEN venir ÚNICAMENTE del core
---
## 3. API DE MÓDULOS
### 3.1 `odoo_platform_core.sh` - BASE DEL SISTEMA
**Inicialización:**
```bash
source /ruta/odoo_platform_core.sh
init_odoo_platform          # Inicializa rutas, carga config, valida
```
**Funciones EXPORTADAS:**
| Función | Descripción | Parámetros |
|---------|-------------|------------|
| `log_info` | Log informativo | `mensaje` |
| `log_success` | Log éxito | `mensaje` |
| `log_warning` | Log advertencia | `mensaje` |
| `log_error` | Log error | `mensaje` |
| `log_debug` | Log debug (condicional) | `mensaje` |
| `show_progress` | Progreso con ícono | `mensaje` |
| `confirm_action` | Confirmación interactiva | `mensaje` |
| `press_enter_to_continue` | Pausa | - |
| `show_banner` | Banner UI | `título`, `subtítulo` |
| `validate_odoo_configuration` | Valida toda la config | - |
| `validate_ports` | Valida solo puertos | - |
| `get_server_ip` | IP del servidor | - |
| `get_total_memory_bytes` | RAM total en bytes | - |
| `get_available_memory_bytes` | RAM disponible | - |
| `get_system_cores` | Núcleos CPU | - |
| `get_free_disk_bytes` | Disco libre | `[ruta]` |
| `bytes_to_human` | Bytes a formato legible | `bytes`, `[precisión]` |
| `install_packages` | Instala paquetes según distro | `lista_paquetes` |
**Variables EXPORTADAS:**
- `SCRIPT_DIR`, `MODULES_DIR`, `BASE_DIR`
- `CONFIG_DIR`, `LOGS_DIR`, `BACKUP_DIR`
- `ODOO_PLATFORM_DIR`, `ODOO_DATA_DIR`, `ODOO_CLIENTS_DIR`
- `ODOO_DEFAULT_VERSION` (19.0)
- `NPM_PORT` (81)
- `DISTRO`
- `ODOO_LOG_FILE`
---
### 3.2 `docker_setup.sh` - DOCKER
**Dependencia:** Requiere `odoo_platform_core.sh` precargado.
**Inicialización:**
```bash
source /ruta/odoo_platform_core.sh && init_odoo_platform
source /ruta/docker_setup.sh
```
**Funciones EXPORTADAS:**
| Función | Descripción |
|---------|-------------|
| `run_docker_setup` | Instalación completa |
| `install_docker` | Solo instalar Docker Engine |
| `configure_docker` | Solo configurar Docker |
| `install_docker_compose` | Instalar Docker Compose |
| `install_nginx_proxy_manager` | Instalar NPM (usa NPM_PORT) |
| `install_docker_tools` | Herramientas adicionales |
| `show_docker_status` | Estado detallado |
| `test_docker_installation` | Prueba hello-world |
| `check_docker_resources` | Verifica recursos mínimos |
| `check_docker_dependencies` | Verifica dependencias |
**Variables UTILIZADAS (de core/config):**
- `INSTALL_DOCKER`
- `INSTALL_NPM`
- `NPM_PORT`, `NPM_WEB_PORT`, `NPM_SSL_PORT`
- `NEW_USER`
- `INTERACTIVE_MODE`
- `FORCE_RECONFIGURE`
---
### 3.3 `odoo_optimizer_lib.sh` - LIBRERÍA PURA
**Inicialización:**
```bash
source /ruta/odoo_optimizer_lib.sh
```
**NO DEPENDE DE NINGÚN OTRO MÓDULO.**  
Funciones matemáticas puras, sin efectos secundarios.
**Funciones EXPORTADAS:**
- `arithmetic` - Cálculos con bc
- `bytes_to_human` - Conversión bytes
- `human_to_bytes` - Conversión inversa
- `get_system_cores` - Detección CPU
- `get_total_memory_bytes` - RAM total
- `get_available_memory_bytes` - RAM disponible
- `get_swap_total_bytes` - Swap total
- `calculate_max_allowed_memory` - Memoria máxima permitida
- `calculate_optimal_workers` - Workers óptimos
- `calculate_memory_limits` - Límites por worker
- `calculate_db_connections` - Conexiones PostgreSQL
- `calculate_odoo_parameters` - TODO en JSON
- `generate_odoo_config` - Config .conf
- `generate_docker_compose_config` - Config Docker
- `generate_resource_report` - Reporte
- `validate_odoo_config` - Validación
- `validate_system_for_odoo` - Validación sistema
- `compatible_worker_analysis` - Modo legacy
---
## 4. CONFIGURACIÓN CENTRALIZADA
**ÚNICA FUENTE DE VERDAD:** `config/config.sh`
**REGLAS:**
1. `config.sh` SOLO declara variables con `${VAR:-default}`
2. NUNCA contiene lógica de validación
3. Las validaciones se realizan EXCLUSIVAMENTE en `odoo_platform_core.sh:validate_odoo_configuration()`
4. Todos los módulos DEBEN usar las variables del core, no leer config.sh directamente
**VARIABLES CRÍTICAS UNIFICADAS:**
| Variable | Valor actual | Notas |
|----------|--------------|-------|
| `ODOO_DEFAULT_VERSION` | `19.0` | **UNIFICADO** |
| `NPM_PORT` | `81` | **UNIFICADO** (admin) |
| `ODOO_BASE_PORT` | `8069` | Base para clientes |
| `DB_BASE_PORT` | `5432` | Base para PostgreSQL |
| `NEW_USER` | `vpsadmin` | Usuario del sistema |
| `SSH_PORT` | `15951` | Puerto SSH personalizado |
---
## 5. COMPATIBILIDAD HACIA ATRÁS
### 5.1 Scripts legacy que esperan `NPM_PORT=8081`
- `odoo_platform_deploy.sh` fue modificado para usar `NPM_PORT` de config
- Para mantener compatibilidad con instalaciones existentes:
  ```bash
  export NPM_PORT=8081  # Forzar puerto legacy
  ```
### 5.2 Scripts legacy que esperan `ODOO_DEFAULT_VERSION=17.0`
- **DECISIÓN ARQUITECTÓNICA**: Se unifica a 19.0
- Compatibilidad con cálculos de workers: `odoo_optimizer_lib.sh` acepta versión como parámetro
- Si un cliente específico requiere 17.0, se puede especificar en su creación:
  ```bash
  create_optimized_odoo_client cliente "Empresa" "dominio" --version 17.0
  ```
### 5.3 Módulos que no han sido refactorizados
Los siguientes módulos MANTIENEN SU COMPORTAMIENTO ORIGINAL:
- `odoo_optimizer.sh` - Cliente de optimización
- `odoo_platform_clients.sh` - Gestión de clientes (>1000 líneas, pendiente división)
- `odoo_platform_deploy.sh` - Despliegue de infraestructura
- `odoo_platform_ui.sh` - Interfaz de usuario
**ESTRATEGIA:**
1. NO modificar estos archivos en esta fase
2. Asegurar que funcionan con las nuevas variables unificadas
3. Refactorización completa en FASE 2
---
## 6. GUÍA DE CARGA PARA DESARROLLADORES
### MODO RECOMENDADO (BOOTSTRAP)
```bash
#!/bin/bash
# 00-bootstrap.sh - Punto de entrada único
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 1. Cargar CORE (siempre primero)
source "$SCRIPT_DIR/odoo_platform_core.sh"
init_odoo_platform
# 2. Cargar módulos necesarios según función
source "$SCRIPT_DIR/odoo_optimizer_lib.sh"
source "$SCRIPT_DIR/docker_setup.sh"
source "$SCRIPT_DIR/odoo_platform_deploy.sh"
# 3. Ejecutar función deseada
run_docker_setup
```
### MODO COMPATIBLE (CARGA BAJO DEMANDA)
```bash
#!/bin/bash
# Script existente que ya funciona
set -euo pipefail
# Cargar config directamente (válido para scripts legacy)
CONFIG_DIR="$(dirname "$0")/../config"
[ -f "$CONFIG_DIR/config.sh" ] && source "$CONFIG_DIR/config.sh"
# Cargar core si no está cargado
if ! type init_odoo_platform &>/dev/null; then
    source "$(dirname "$0")/odoo_platform_core.sh"
    init_odoo_platform
fi
# Resto del script...
```
---
## 7. VERSIONADO
**TODOS los módulos DEBEN tener versión consistente:**
| Módulo | Versión actual | Estado |
|--------|----------------|--------|
| `config.sh` | 2.2.2 | ✅ UNIFICADO |
| `odoo_platform_core.sh` | 2.2.2 | ✅ UNIFICADO |
| `docker_setup.sh` | 2.2.2 | ✅ UNIFICADO |
| `odoo_optimizer_lib.sh` | 2.1.0+ | ⚠️ Mantiene su versión |
| `odoo_optimizer.sh` | 2.2.0 | ⚠️ Pendiente |
| `odoo_platform_clients.sh` | 2.2.1 | ⚠️ Pendiente |
| `odoo_platform_deploy.sh` | 2.2.0 | ⚠️ Pendiente |
| `odoo_platform_ui.sh` | 2.2.0 | ⚠️ Pendiente |
**Objetivo FASE 2:** Unificar TODOS a 2.2.2
---
## 8. VALIDACIÓN DE CONSISTENCIA
### Script de verificación rápida:
```bash
#!/bin/bash
# check-consistency.sh
echo "=== VERIFICANDO CONSISTENCIA DE MÓDULOS ==="
# Verificar versión Odoo en todos los archivos
echo "1. Versión Odoo:"
grep -r "ODOO_DEFAULT_VERSION" --include="*.sh" . | \
    grep -v "19.0" && echo "⚠️  Inconsistencia detectada"
# Verificar puerto NPM
echo "2. Puerto NPM:"
grep -r "NPM_PORT" --include="*.sh" . | \
    grep -E "(81|8081)" | grep -v "81" && echo "⚠️  Inconsistencia detectada"
# Verificar funciones duplicadas de logging
echo "3. Funciones duplicadas:"
grep -r "log_info()" --include="*.sh" . | grep -v "core.sh" && \
    echo "⚠️  Función log_info duplicada fuera de core"
```
---
## 9. HISTORIAL DE CAMBIOS
| Fecha | Versión | Cambios |
|-------|---------|---------|
| 2026-02-12 | 2.2.2 | **REFACTORIZACIÓN FASE 1**<br>- Unificación `ODOO_DEFAULT_VERSION=19.0`<br>- Unificación `NPM_PORT=81`<br>- Core como única fuente de logging/validación<br>- Docker_setup limpio de duplicaciones<br>- Documentación de interfaces |
---
*Este documento es parte de Odoo Platform y debe mantenerse actualizado con cada cambio en la arquitectura de módulos.*
