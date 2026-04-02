# AGENTS.md - Hestia Real Estate Management System

## 📋 Resumen Ejecutivo

**Hestia** es un sistema integral de gestión inmobiliaria construido con **Ruby on Rails 8.1.2** que permite digitalizar todo el ciclo de negocio de bienes raíces: desde la lista de propiedades hasta la gestión de contratos, tenants y seguimiento de pagos.

**Propósito**: Proporcionar una plataforma moderna para gestores inmobiliarios (agentes), propietarios y inquilinos con control de acceso basado en roles y una interfaz premium.

---

## 🏗️ Arquitectura del Proyecto

### Stack Tecnológico Principal

| Componente | Tecnología | Versión |
|-----------|-----------|---------|
| **Framework Backend** | Ruby on Rails | 8.1.2 |
| **Base de Datos** | PostgreSQL | - |
| **Runtime Ruby** | Ruby | 4.0.0 |
| **Frontend Framework** | Hotwire (Turbo + Stimulus) | Latest |
| **Autenticación** | Devise | - |
| **Autorización** | Pundit (RBAC) | - |
| **Styling** | Bootstrap 5 + Dart Sass | 5.3.3 |
| **Assets Pipeline** | Propshaft | - |
| **Persistent Storage** | Solid Cache, Solid Queue, Solid Cable | - |
| **Web Server** | Puma | - |
| **Deployment** | Kamal (Docker) | - |

---

## 📁 Estructura del Proyecto

```
hestia/
├── app/                           # Código de aplicación
│   ├── models/                    # Modelos Active Record
│   │   ├── user.rb               # Autenticación con Devise
│   │   ├── company.rb            # Empresa gestora
│   │   ├── company_manager.rb    # Relación usuario-empresa
│   │   ├── property.rb           # Inmuebles
│   │   ├── tenant.rb             # Inquilinos
│   │   ├── contract.rb           # Contratos de alquiler
│   │   └── charge.rb             # Cargos y pagos
│   ├── controllers/               # Controllers MVC
│   │   ├── application_controller.rb
│   │   ├── properties_controller.rb
│   │   ├── tenants_controller.rb
│   │   ├── contracts_controller.rb
│   │   ├── portal_controller.rb   # Portal inquilino
│   │   └── home_controller.rb
│   ├── views/                     # HTML/ERB templates
│   │   ├── layouts/              # Layouts principales
│   │   ├── properties/           # Vistas de propiedades
│   │   ├── tenants/              # Vistas de inquilinos
│   │   ├── contracts/            # Vistas de contratos
│   │   ├── portal/               # Portal tenant
│   │   └── devise/               # Auth views (Devise)
│   ├── helpers/                   # View helpers
│   ├── policies/                  # Pundit policies (RBAC)
│   ├── javascript/                # Stimulus controllers
│   ├── jobs/                      # Background jobs (Solid Queue)
│   ├── mailers/                   # Mailers (correos)
│   └── assets/                    # CSS, images
├── config/                        # Configuración Rails
│   ├── routes.rb                 # Routing principal
│   ├── application.rb            # Configuración app
│   ├── environments/             # Configs por ambiente
│   ├── initializers/             # Inicializadores
│   └── database.yml              # Conexión BD
├── db/                           # Base de datos
│   ├── migrate/                  # Migraciones
│   ├── schema.rb                 # Schema actual
│   └── seeds.rb                  # Datos iniciales
├── test/                         # Tests (TDD)
│   ├── models/
│   ├── controllers/
│   ├── integration/
│   ├── system/                   # Tests de sistema
│   └── fixtures/
├── lib/                          # Librerías custom
├── package.json                  # Node dependencies (CSS)
├── Gemfile                       # Ruby dependencies
├── Dockerfile                    # Containerización
├── Procfile.dev                  # Development processes
└── bin/                          # Executables
```

---

## 🗄️ Modelo de Datos

### Entidades Principales

```
users (Devise)
├── has_many :company_managers
├── has_many :companies, through: :company_managers
└── role: [admin, gestor, inquilino]

companies
├── has_many :company_managers
├── has_many :users, through: :company_managers
├── has_many :properties
└── manage Real Estate agencies

properties
├── belongs_to :company
├── has_many :contracts
├── has_many :tenants, through: :contracts
├── has_many :charges
└── attributes: address, price, area, amenities, description

contracts
├── belongs_to :property
├── belongs_to :tenant
├── has_many :charges
└── attributes: start_date, end_date, rent_amount, deposit

tenants
├── has_many :contracts
├── has_many :properties, through: :contracts
├── has_many :charges, through: :contracts
└── attributes: name, email, phone, income_verification

charges
├── belongs_to :contract
├── attributes: amount, type[:rent, :extraordinary, :cleaning, :legal], status[:pending, :paid]
└── track payments and fees
```

---

## 🔐 Sistema de Roles y Permisos

### Roles Implementados (Devise + Pundit)

| Rol | Permisos | Vista Principal |
|-----|----------|-----------------|
| **admin** | Acceso total a todas las empresas, propiedades, usuarios | Dashboard admin completo |
| **gestor** | Gestionar solo propiedades/inquilinos asignados a su empresa | Panel gestor + Portal |
| **inquilino** | Ver solo su contrato, documentos y pagos | Portal tenant (read-only) |

### Policies (Pundit)

- `app/policies/application_policy.rb` - Base policy
- `app/policies/property_policy.rb` - Lógica de autorización por propiedad
- Extensible para otros recursos

---

## 🚦 Flujos Principales

### 1. **Ciclo de Contrato** (Rental Management)
```
1. Gestor crea Property
   ↓
2. Gestor vincula Tenant a Property
   ↓
3. Sistema genera Contract (start/end date, amountrent)
   ↓
4. Sistema genera Charges periódicas (Solid Queue)
   ↓
5. Tenant accede a Portal para ver documentos/pagos
   ↓
6. Gestor/Admin rastrea estado de pagos
```

### 2. **Autenticación**
```
Usuario → Devise Auth → Login
                    ↓
              Email + Password
                    ↓
          Sistema asigna rol
                    ↓
        Redirect según rol
   (Admin/Gestor/Inquilino)
```

### 3. **Autorización**
```
Acción en Recurso (ej: editar Property)
        ↓
  Pundit Policy
        ↓
  user.admin? ✓ o user.manages?(company)?
        ↓
  Policy.authorize! → ✓ o ✗ PolicyError
```

---

## 📡 Endpoints Principales

### API Routes (RESTful)

```ruby
resources :properties  # GET /properties, POST, PATCH, DELETE
resources :tenants     # GET /tenants, POST, PATCH, DELETE
resources :contracts   # GET /contracts, POST, PATCH, DELETE

# Portal Inquilino
scope "/portal" do
  GET  /portal/dashboard          → ver resumen
  GET  /portal/documents          → descargar docs
  GET  /portal/payments           → ver estado pagos
  GET  /portal/support_requests   → soporte
  GET  /portal/signup_contract/:id → firmar contrato
end

# Auth (Devise)
devise_for :users
GET  /users/sign_in
POST /users/sign_in
POST /users/sign_out
```

---

## 🎨 Frontend Architecture

### Styling
- **Bootstrap 5** para componentes
- **Dart Sass** para CSS personalizado
- **Lucide Rail Icons** para iconografía
- **Tema Custom "Hestia Gold"** en `app/assets/stylesheets/`

### Interactividad
- **Stimulus.js** para JavaScript sin framework
  - Controllers en `app/javascript/controllers/`
  - Binding a elementos HTML con `data-controller`, `data-action`
- **Turbo** para navegación SPA-like
  - `turbo_frame_tag` para actualizaciones parciales
  - `turbo_stream` para cambios en tiempo real

### Estructura de Vistas (ERB)
```
layouts/
├── _head.html.erb
├── _navbar.html.erb
└── application.html.erb (layout principal)

properties/
├── index.html.erb     (lista de propiedades)
├── show.html.erb      (detalle)
├── edit.html.erb      (formulario)
└── _form.html.erb     (partial compartido)

portal/
├── dashboard.html.erb (vista inquilino)
├── documents.html.erb
└── payments.html.erb
```

---

## 🔄 Background Jobs & Caching

### Solid Queue (Background Jobs)
- Location: `app/jobs/`
- Generación automática de `Charges` cuando vence un período de renta
- Envío de recordatorios por email
- Procesos batch para reportes

### Solid Cache
- Cache de datos frecuentes (propiedades, usuarios)
- Expedite queries de usuario habituales

### Solid Cable
- WebSocket support para notificaciones en tiempo real
- Notificaciones de pagos recibidos

---

## 🔍 Development Workflow

### Locales (Development)

```bash
# Setup inicial
bin/setup
bin/dev          # Inicia Procfile.dev: Rails + JS builder + CSS watcher

# Migraciones
rails db:create
rails db:migrate
rails db:seed    # Datos iniciales

# Tests
rails test
rails test:system  # Capybara system tests

# Auditoría de código
bin/rubocop      # Linting
bin/brakeman     # Security
bin/bundler-audit # Gem vulnerabilities
```

### Procfile.dev
```
web: bin/rails server -p 3000
js: npm run build:css -- --watch
tailwind: ...
```

---

## 📦 Deployment

### Docker + Kamal
```dockerfile
# Dockerfile MultiStage
# Stage 1: Build (gems, assets)
# Stage 2: Runtime (solo lo necesario)

# Deployment
kamal setup      # Deploy inicial
kamal deploy     # Redeploy
kamal logs       # Ver logs
```

### Environments
- **development**: db local, debug enabled
- **production**: credentials encriptadas, logging, error tracking
- **test**: bd en memoria, fixtures

---

## 🧪 Testing Strategy

### Test Directory Structure
```
test/
├── models/
│   ├── user_test.rb
│   ├── property_test.rb
│   ├── contract_test.rb
│   └── charge_test.rb
├── controllers/
│   ├── properties_controller_test.rb
│   └── portal_controller_test.rb
├── integration/        # Multi-step flows
├── system/            # Capybara - full browser
└── policies/          # Pundit authorizations
```

### Tipos de Tests
- **Unit**: `models/` - Validaciones, callbacks, asociaciones
- **Controller**: Requests HTTP, autenticación
- **Integration**: Workflows multi-step
- **System**: Full app flow (Capybara)
- **Policy**: Pundit authorization rules

---

## 🛡️ Seguridad

### Implementaciones
- **Devise**: Autenticación segura (bcrypt)
- **Pundit**: RBAC en nivel de recurso
- **CSRF Protection**: Built-in Rails
- **Parameter Filtering**: `config/initializers/filter_parameter_logging.rb`
- **Content Security Policy**: `config/initializers/content_security_policy.rb`
- **Credentials**: Encriptadas en `config/credentials.yml.enc`
- **Auditoría**: brakeman, bundler-audit en CI
- **No hardcodear secrets**: Usar `rails credentials:edit` siempre
- **Principio de menor privilegio**: Usuarios/roles solo acceso necesario
- **Validación de input**: Todas las entradas validadas

### Data Classification
- PII (Personal ID): Nombres, teléfonos de tenants
- Financial: Montos de renta, pagos, depósitos
- Contracts: Documentos sensibles firmados

---

## 🔐 Protecciones de Rama (GitHub)

### Branch Protection Rules (main)

✅ **Configuración Requerida**:
- [ ] Require pull request reviews before merging (mínimo 1)
- [ ] Dismiss stale pull request approvals when new commits are pushed
- [ ] Require status checks to pass before merging (CI/CD)
- [ ] Require branches to be up to date before merging
- [ ] Restrict who can push to matching branches (solo admins)
- [ ] **CODEOWNERS file**: `CODEOWNERS` en raíz del repo
- [ ] Secret scanning: Habilitado en Settings > Security
- [ ] **No self-edit rule**: Crear rama, PR review obligatorio

### CODEOWNERS Template
```
# CODEOWNERS - Aprobación requerida antes de merge

# Código crítico
app/models/user.rb @admin-team
app/models/company.rb @admin-team
app/models/contract.rb @admin-team
app/policies/ @admin-team
config/routes.rb @admin-team
db/migrate/ @admin-team

# Autenticación
app/controllers/application_controller.rb @admin-team
config/initializers/devise.rb @admin-team

# Secretos e infra
config/credentials.yml.enc @admin-team
Docker* @admin-team
config/deploy.yml @admin-team

# Automatización
app/jobs/ @admin-team
app/mailers/ @admin-team

# Testing
test/ @admin-team
```

---

## 🎯 Puntos de Extensión para Agentes

### Módulos que Pueden Expandir Agentes

#### 1. **Nuevas Funcionalidades**
- `app/models/` - Nuevas entidades (ej: inspecciones, mantenimiento)
- `app/controllers/` - Nuevos endpoints
- `app/views/` - Nuevas interfaces

#### 2. **Automatización**
- `app/jobs/` - Nuevos jobs (ej: reporte mensual automático)
- `app/mailers/` - Nuevos email templates

#### 3. **Integraciones Externas**
- APIs de pagos (Stripe, PayPal)
- Servicios de firma electrónica
- CRM externo

#### 4. **Reportes & Analytics**
- `lib/reports/` - Generadores de reportes
- Dashboard analytics mejorado

#### 5. **Performance**
- Optimización de queries (N+1 problems)
- Caché estratégico
- Índices de BD

---

## 📍 Restricciones y Boundaries

### ✅ LO QUE PUEDEN HACER LOS AGENTES
- Crear/editar modelos en `app/models/` con aprobación
- Agregar tests a `test/`
- Actualizar vistas en `app/views/`
- Crear jobs en `app/jobs/` para automatización
- Optimizar queries existentes
- Agregar documentación en `README.md`
- Crear branches y hacer PR con enfoque específico
- Modificar `Gemfile` solo si necesario + PR review

### 🚫 PROHIBIDO para Agentes

**Secretos e Infraestructura**:
- ❌ NUNCA hardcodear credentials, API keys, tokens
- ❌ NUNCA modificar `config/credentials.yml.enc` sin proceso de auditoría
- ❌ NUNCA exponer variables de ambiente en código
- ❌ NUNCA hacer commit de `.env`, `.pem`, `.key` files
- ❌ NUNCA mergear directamente a `main` (siempre PR)

**Permisos Amplios**:
- ❌ NUNCA crear usuarios con rol `admin` sin autorización
- ❌ NUNCA modificar políticas Pundit sin review exhaustivo
- ❌ NUNCA cambiar rutas críticas en `config/routes.rb` sin justificación
- ❌ NUNCA alterar autenticación en `app/models/user.rb` sin co-review
- ❌ NUNCA permitir permisos escalables sin validación de principio de menor privilegio

**Infraestructura Sensible**:
- ❌ NUNCA modificar `Dockerfile` sin testing exhaustivo
- ❌ NUNCA cambiar configuración `production.rb` sin proceso definido
- ❌ NUNCA ejecutar migraciones destructivas sin backup
- ❌ NUNCA exponer puertos internos o servicios en producción
- ❌ NUNCA deshabilitar CSP, CORS o protecciones de seguridad

**Datos Sensibles**:
- ❌ NUNCA loguear PII (nombres, teléfonos, emails sin anonimizar)
- ❌ NUNCA copiar datos de producción a desarrollo sin cifrar
- ❌ NUNCA guardar datos financieros en logs
- ❌ NUNCA cambiar recolección de datos sin notificación

**Self-Edit**:
- ❌ NUNCA hacer self-merge: crear PR → debe reviewar otro → merge
- ❌ NUNCA saltarse CI/CD checks
- ❌ NUNCA forzar push a ramas compartidas
- ❌ NUNCA revertir cambios críticos sin justificación documentada

### AppSec Checklist Obligatorio

Antes de cada PR/merge, validar:

```
[ ] ¿Hay secretos hardcodeados? (buscar: password, key, token, secret)
[ ] ¿Se validan todas las entradas de usuario?
[ ] ¿Hay autorización con Pundit para nuevos endpoints?
[ ] ¿Se usan parametrizadas queries (evitar SQL injection)?
[ ] ¿Hay logs de PII? (auditar con brakeman)
[ ] ¿Funciona CSRF protection?
[ ] ¿Se escapa HTML en vistas ERB?
[ ] ¿Brakeman sin warnings críticos?
[ ] ¿Bundler-audit OK?
[ ] ¿PR revisado por CODEOWNERS?
[ ] ¿Tests pasan?  
[ ] ¿Código pasa rubocop?
```

---

## 📚 Archivos Clave para Entender el Proyecto

| Archivo | Propósito | Criticidad |
|---------|-----------|-----------|
| `config/routes.rb` | Rutas principales | 🔴 Crítico |
| `app/models/user.rb` | Modelo auth + roles | 🔴 Crítico |
| `app/policies/` | Autorización RBAC | 🔴 Crítico |
| `db/schema.rb` | Estructura DB | 🔴 Crítico |
| `app/controllers/portal_controller.rb` | Logic tenant | 🟠 Importante |
| `config/environments/production.rb` | Config prod | 🟠 Importante |
| `package.json` | CSS build pipeline | 🟡 Referencia |

---

## 🚀 Comandos Útiles para Agentes

```bash
# Info del proyecto
rails db:schema:dump    # Ver schema actual
rails routes            # Listar todas las rutas

# Debugging
rails console           # IRB con app loaded
rails c -s             # Console + sandbox (rollback)

# Generación de código
rails generate model PropertyReview
rails generate controller Reports
rails generate migration AddIndexToProperties

# Security & Quality
bin/rubocop -a          # Autofix linting issues
bin/brakeman            # Detectar vulnerabilidades
bin/bundler-audit       # Auditar gemas

# Testing
rails test:models       # Solo tests de modelos
rails test:controllers
rails test:system

# Assets
rails assets:precompile # Build assets prod
```

---

## 🔗 Referencias Internas

### Configuraciones Importantes
- **Devise Config**: `config/initializers/devise.rb`
- **CORS/CSP**: `config/initializers/content_security_policy.rb`
- **Email**: `config/environments/production.rb` (ActionMailer)
- **Storage**: `config/storage.yml` (Active Storage config)

### Documentación Externa
- [Rails 8.1 Guide](https://guides.rubyonrails.org)
- [Devise Wiki](https://github.com/heartcombo/devise)
- [Pundit Authorization](https://github.com/varvet/pundit)
- [Bootstrap Docs](https://getbootstrap.com)
- [Stimulus.js Manual](https://stimulus.hotwired.dev)

---

## 📝 Notas para Agentes

1. **Antes de cambios grandes**: Revisa `config/routes.rb` y modelos relacionados
2. **Tests**: Siempre incluir tests para nuevas features
3. **Migraciones**: Usar `rails generate migration` para DB changes
4. **Views**: Usa partials (`_variable.html.erb`) para DRY
5. **Performance**: Eager load con `.includes()`, `.preload()` para evitar N+1
6. **Security**: Nunca saltarse Pundit policies para autorización
7. **Styling**: Importar nuevos estilos en `app/assets/stylesheets/application.bootstrap.scss`
8. **Credentials**: Usar `rails credentials:edit` para secrets, NO hardcodear

---

## ✅ Checklist de Calidad para PRs

- [ ] Tests agregados/actualizados
- [ ] No hay N+1 queries
- [ ] Autorización con Pundit validada
- [ ] Código pasa `rubocop -a`
- [ ] Brakeman sin warnings críticos
- [ ] Migraciones reversibles
- [ ] Documentado en código/comits
- [ ] Assets compilados

---

**Last Updated**: 2 de abril de 2026  
**Framework Version**: Rails 8.1.2  
**Ruby Version**: 4.0.0
