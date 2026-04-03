# Multitenancy en Hestia

## Descripción General

Hestia implementa multitenancy basada en **PostgreSQL schemas** y **subdomains**. Cada cliente (tenant) obtiene:

- Un **schema separado** en PostgreSQL (ej: `acme`, `empresa_xyz`)
- Un **subdominio único** para acceso (ej: `acme.localhost:3000`, `empresa_xyz.example.com`)
- **Aislamiento completo** de datos entre tenants

### Ventajas

✅ Seguridad: Datos completamente aislados a nivel de base de datos
✅ Escalabilidad: Un schema por tenant sin crear nuevas BD
✅ Simpleza: Middleware automático maneja el switching de schemas
✅ Flexibilidad: Fácil agregar nuevos tenants sin redeploar

---

## Arquitectura Técnica

### Componentes Clave

| Componente | Ubicación | Propósito |
|-----------|-----------|----------|
| **Middleware** | `app/middleware/apartment_tenant_middleware.rb` | Detecta subdomain y cambia schema |
| **Inicializador** | `config/initializers/apartment.rb` | Implementación manual de multitenancy |
| **Rake Tasks** | `lib/tasks/apartment.rake` | Crear schemas, migrar, seedear |
| **Script Bash** | `bin/create-tenant.sh` | Crear tenant interactivamente |

### Flujo de Request

```
1. Request arrives → acme.localhost:3000
              ↓
2. ApartmentTenantMiddleware intercepts
              ↓
3. Extracts subdomain → "acme"
              ↓
4. Llamada: Apartment::Tenant.switch!("acme")
              ↓
5. PostgreSQL: SET search_path TO "acme"
              ↓
6. Rails controllers see only "acme" schema data
              ↓
7. Response sent
              ↓
8. Middleware resets: Apartment::Tenant.reset
              ↓
9. PostgreSQL: SET search_path TO "public"
```

### Base de Datos

```
PostgreSQL: hestia_development
├── public schema (default tenant + system data)
│   ├── users
│   ├── companies
│   ├── properties
│   ├── occupants
│   ├── contracts
│   └── charges
├── acme schema (ACME Corporation tenant)
│   ├── users (isolated from public)
│   ├── companies
│   ├── properties
│   └── ... (same tables, different data)
└── empresa_xyz schema (example tenant)
    └── ... (same structure)
```

### Esquema "public"

El schema `public` tiene dual purpose:
- **Sistema**: Tablas de infraestructura (`schema_migrations`, etc)
- **Tenant Default**: Datos del tenant "public" (localhost sin subdomain)

---

## Crear un Nuevo Tenant

### Opción 1: Bash Script (Recomendado)

```bash
bin/create-tenant.sh acme admin@acme.com password123
```

**Parámetros:**
- `acme` - Nombre del tenant (alphanumeric + underscore)
- `admin@acme.com` - Email del admin (opcional, por defecto `admin@tenant.local`)
- `password123` - Contraseña (opcional, por defecto `password123`)

**Qué hace:**
1. Valida el nombre del tenant
2. Crea schema en PostgreSQL
3. Ejecuta migraciones en el nuevo schema
4. Crea usuario admin
5. Crea empresa por defecto
6. Vincula admin a empresa

**Output:**
```
🏢 Creando nuevo tenant: acme
   Email admin: admin@acme.com

1️⃣ Creando schema en PostgreSQL...
✅ Schema creado

2️⃣ Ejecutando migraciones...
✅ Migraciones completadas

3️⃣ Creando usuario administrador...
✅ Usuario creado: admin@acme.com

4️⃣ Creando empresa por defecto...
✅ Empresa creada: Acme Corporation
✅ Admin vinculado a empresa

======================================================================
✅ Tenant 'acme' creado exitosamente!
======================================================================

📝 Información del Tenant:
   Nombre: acme
   Schema: acme
   Admin Email: admin@acme.com
   Admin Password: password123

🌐 Acceso local:
   http://acme.localhost:3000

⚠️  IMPORTANTE: Cambia la contraseña del admin en producción
======================================================================
```

### Opción 2: Rake Task

```bash
# Con parámetros posicionales
rails apartment:create:tenant[my_tenant,admin@my_tenant.com,secure_pass]

# Con variables de ambiente
TENANT_NAME=my_tenant ADMIN_EMAIL=admin@my_tenant.com rails apartment:create:tenant

# Valores por defecto
rails apartment:create:tenant[my_tenant]
# → admin@my_tenant.local / password123
```

---

## Acceder a un Tenant

### Desarrollo Local

```
http://acme.localhost:3000     → Schema "acme"
http://localhost:3000           → Schema "public"
http://www.localhost:3000       → Schema "public" (www ignored)
http://empresaxyz.localhost:3000 → Schema "empresaxyz"
```

### Producción

```
https://acme.example.com        → Schema "acme"
https://www.example.com         → Schema "public"
https://empresaxyz.example.com  → Schema "empresaxyz"
```

**Nota:** El subdominio se extrae automáticamente via `ActionDispatch::Request#subdomain`

---

## Gestionar Tenants

### Ver todos los schemas

```bash
psql -d hestia_development -c "
  SELECT schema_name 
  FROM information_schema.schemata 
  ORDER BY schema_name
"
```

### Ver datos de un schema específico

```bash
psql -d hestia_development << 'EOF'
SET search_path TO "acme";
SELECT COUNT(*) as user_count FROM users;
SELECT * FROM users;
EOF
```

### Seedear un tenant específico

```bash
# Seedear solo "acme" (sin "public")
APARTMENT_TENANTS="acme" rails db:seed

# Seedear multiples tenants
APARTMENT_TENANTS="public,acme,enterprise" rails db:seed
```

### Migrar un tenant específico

```bash
# Migrar solo "acme"
APARTMENT_TENANTS="acme" rails apartment:migrate

# Migrar multiples
APARTMENT_TENANTS="public,acme,enterprise" rails apartment:migrate
```

### Eliminar un tenant (⚠️ DESTRUCTIVO)

```bash
psql -d hestia_development -c "DROP SCHEMA acme CASCADE"
```

---

## Testing en Multitenancy

### Tests Predefinidos

```bash
# Test multitenancy
APARTMENT_TENANTS="public,acme" rails test test/integration/multitenancy_test.rb

# Test middleware
APARTMENT_TENANTS="public,acme" rails test test/integration/middleware_subdomain_test.rb

# Test modelos
APARTMENT_TENANTS="public,acme" rails test test/models/multitenancy_model_test.rb
```

### Escribir Tests

Configure `test_helper.rb` y use en tests:

```ruby
def test_users_isolated_between_tenants
  Apartment::Tenant.switch!("acme") do
    acme_user = User.create!(email: "user@acme.com", ...)
    assert_equal 1, User.count
  end

  Apartment::Tenant.switch!("public") do
    public_user = User.create!(email: "user@public.com", ...)
    assert_equal 1, User.count  # isolated!
  end
end
```

---

## Solución de Problemas

### "TenantNotFound" error

```
Apartment::TenantNotFound: Could not find tenant 'unknown_schema'
```

**Causa:** Subdomain no existe como schema
**Solución:** 
- Verificar nombre del schema: `APARTMENT_TENANTS="public,schema_correcto" rails apartment:migrate`
- Usar `bin/create-tenant.sh` para crear correctamente

### Datos no aislados

**Síntoma:** Un tenant ve datos de otro
**Causa:** Middleware no está activo o schema switching falló

**Debugging:**
```ruby
# En console
rails c
Apartment::Tenant.current  # debe mostrar el schema actual
Apartment::Tenant.switch!('acme') do
  User.count  # usuarios de "acme"
end
```

### "Schema does not exist" en migraciones

**Causa:** Tenant schema no fue creado
**Solución:**
```bash
APARTMENT_TENANTS="public,acme" rails apartment:create_schemas
APARTMENT_TENANTS="public,acme" rails apartment:migrate
```

---

## Seguridad

### ✅ Best Practices

- [ ] Todos los tenants usan HTTPS en producción
- [ ] Subdomain validation: solo alphanumeric + hyphen
- [ ] Admin passwords cambiadas después de créación
- [ ] Backups por tenant/schema separados
- [ ] Audit log: quién creó/modificó cada tenant

### 🚫 Anti-patrones

- ❌ Hardcodear tenant names en código
- ❌ Crear usuarios manualmente sin validar aislamiento
- ❌ Compartir cache entre tenants
- ❌ No validar subdomains (SQL injection risk)

---

## Troubleshooting avanzado

### Listar todas las operaciones Apartment

```ruby
# En rails console
Apartment::Tenant.all_tenants     # todos los schemas
Apartment::Tenant.current         # schema actual
Apartment::Tenant.switch!('acme') # cambiar
Apartment::Tenant.reset          # resetear a public
```

### Verificar integridad de schemas

```bash
APARTMENT_TENANTS="" rails runner "
  schemas = ActiveRecord::Base.connection.execute(
    \"SELECT schema_name FROM information_schema.schemata 
     WHERE schema_name NOT IN ('information_schema', 'pg_catalog')\"
  ).map { |row| row['schema_name'] }
  
  puts \"Schemas encontrados: #{schemas.join(', ')}\"
  
  schemas.each do |schema|
    Apartment::Tenant.switch!(schema)
    table_count = ActiveRecord::Base.connection.tables.size
    puts \"  - #{schema}: #{table_count} tablas\"
    Apartment::Tenant.reset
  end
"
```

---

## Referencias

- [Documentación Oficial: Apartment Gem (deprecated para Rails 8)](https://github.com/influitive/apartment)
- [PostgreSQL Schemas](https://www.postgresql.org/docs/current/sql-createschema.html)
- [Rails 8 Multitenancy Best Practices](https://guides.rubyonrails.org)

---

**Última actualización:** 3 de Abril de 2026
**Rails Version:** 8.1.2
**Database:** PostgreSQL
