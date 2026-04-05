# Multitenancy en Hestia - Guía de Uso

## 🎯 Qué es y por qué lo necesitamos

**Multitenancy** permite que cada cliente de Hestia sea **dueño absoluto de sus datos** y maneje múltiples empresas inmobiliarias bajo un único usuario.

### Problema a Resolver
Actualmente, si un gestor tiene varias empresas (ej: Inmuebles Premium SA, Rental Properties Inc), necesita múltiples cuentas separadas o sus datos se mezclan. Con multitenancy:

✅ **Un usuario → Múltiples Empresas Aisladas**
- Un login único gestiona todas tus empresas
- Cada empresa tiene su propia BD (schema PostgreSQL)
- Los datos son completamente privados y no se pueden mezclar

✅ **Propiedad de Datos Garantizada**
- Cada tenant (empresa) tiene un schema aislado en PostgreSQL
- Imposible acceso cruzado entre clientes
- Datos 100% separados a nivel de base de datos

✅ **Seguridad y Privacidad**
- RBAC granular (Roles: admin, gestor, inquilino)
- Validación en cada request (middleware)
- Auditoría completa por empresa

### Caso de Uso Principal
```
Usuario: juan@inmuebles.com
Empresas:
  ├─ Inmuebles Premium SA        (acme.hestia.app)
  │   └─ 15 propiedades, $500K/mes ingresos
  ├─ Rental Properties Inc       (rental.hestia.app)
  │   └─ 8 propiedades, $250K/mes ingresos
  └─ Gestoría Inmobiliaria      (gestion.hestia.app)
      └─ 3 propiedades, $100K/mes ingresos

Juan accede a cada empresa con una URL diferente - sus datos jamás se mezclan.
```

---

## 🚀 Cómo Funciona

### Arquitectura: PostgreSQL Schemas + Subdomain Routing

Cuando accedes a Hestia a través de un subdomain específico, el sistema automáticamente aisla tus datos:

```
Accedes: acme.hestia.app
       ↓
Sistema detecta subdomain: "acme"
       ↓
Cambia PostgreSQL search_path → schema "acme"
       ↓
Todas tus queries van a schema "acme"
       ↓
Datos completamente aislados
```

**¿Por qué así es más seguro?**
- ✅ Aislamiento a nivel de **base de datos** (no de aplicación)
- ✅ Imposible leak de datos entre clientes (garantizado por PostgreSQL)
- ✅ Performance óptimo (una conexión, un schema)
- ✅ Escalable sin cambios de código

---

## 💼 Acceso por Empresa

Cada una de tus empresas tiene su propia URL:

```bash
# Empresa 1
https://acme.hestia.app          # → Schema "acme"

# Empresa 2  
https://rental.hestia.app        # → Schema "rental"

# Empresa 3
https://gestion.hestia.app       # → Schema "gestion"

# Sistema central (admin)
https://hestia.app               # → Schema "public"
```

Simplemente cambia el subdomain para acceder a cada empresa.

---

## 📊 Feature Scope

| Aspecto | Cómo Funciona |
|---------|-------------|
| **Modelo de Aislamiento** | PostgreSQL schemas (aislamiento de base de datos completo) |
| **Routing** | Subdomain-based (automático sin configuración manual) |
| **Experiencia** | Transparente - usa Hestia normalmente, datos se aíslan solos |
| **Performance** | Una conexión BD compartida, cambio de schema es instantáneo |
| **Escalabilidad** | Agregar empresa = crear schema (sin deployment) |
| **Seguridad** | Aislamiento garantizado a nivel de base de datos |

## 🔐 Seguridad Garantizada

La privacidad de tus datos está asegurada a nivel de base de datos:

✅ **Aislamiento Real**
- Cada empresa tiene su propio schema PostgreSQL
- No hay forma de acceder a datos de otra empresa incluso con acceso al código
- El aislamiento es responsabilidad de PostgreSQL, no de la aplicación

✅ **Control de Acceso**
- RBAC por rol (admin, gestor, inquilino)
- Validación en cada request
- Auditoría completa de accesos

✅ **Sin Hardcoding de Secretos**
- Credenciales cifradas
- No existen "master keys" para acceder a múltiples empresas
- Cada usuario solo ve lo que le pertenece

---

## 🧪 Usar Multitenancy Localmente

Para probar multitenancy en desarrollo:

```bash
# Setup
APARTMENT_TENANTS="public,acme" rails db:reset

# Acceder a la app
http://localhost:3000             # Schema: public (admin/system)
http://acme.localhost:3000        # Schema: acme (tenant data)

# Crear nuevo tenant
rails apartment:create:tenant[miempresa,admin@miempresa.com,password]
http://miempresa.localhost:3000   # Nuevo tenant creado
```

---

## 🚀 En Producción

### Crear una Nueva Empresa

Para agregar una nueva empresa a Hestia en producción:

```bash
# 1. Conectarse al servidor
ssh admin@hestia.app

# 2. Crear el nuevo schema/empresa
rails apartment:create:tenant[empresa001,admin@empresa.com,secure_password]

# 3. Listo - acceder con:
https://empresa001.hestia.app
```

**No requiere deployment, no requiere cambios de código - simplemente crear un nuevo schema.**

### Requisitos Mínimos
- PostgreSQL 12+
- Rails 8.1.2
- Ruby 4.0.0

---

## 📚 Más Información

- [Guía Técnica Completa](./MULTITENANCY.md) - Detalles de arquitectura e implementación
- [AGENTS.md - Arquitectura del Proyecto](../AGENTS.md) - Visión general del sistema
- [Middleware de Routing](../app/middleware/apartment_tenant_middleware.rb) - Cómo se detectan subdomains
- [Configuración de Multitenancy](../config/initializers/apartment.rb) - Código de aislamiento de esquemas

---

**Última Actualización:** 3 de Abril de 2026  
**Feature:** PostgreSQL Schema-Based Multitenancy  
**Estado:** ✅ Implementado y Funcional
