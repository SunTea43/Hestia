#!/bin/bash
# Script para crear un nuevo tenant en Hestia multitenancy
# Uso: bin/create-tenant.sh <tenant_name> [admin_email] [admin_password]

set -e

TENANT_NAME="${1:?Error: Por favor proporciona el nombre del tenant. Uso: bin/create-tenant.sh <tenant_name> [admin_email] [admin_password]}"
ADMIN_EMAIL="${2:-admin@${TENANT_NAME}.local}"
ADMIN_PASSWORD="${3:-password123}"

echo "Creando nuevo tenant: $TENANT_NAME"
echo "   Email admin: $ADMIN_EMAIL"
echo ""

# Validate tenant name (alphanumeric and underscore only)
if ! [[ "$TENANT_NAME" =~ ^[a-z0-9_]+$ ]]; then
  echo "El nombre del tenant debe contener solo letras minúsculas, números y guiones bajos"
  exit 1
fi

# Check if tenant already exists
TENANT_EXISTS=$(APARTMENT_TENANTS="" rails runner "
  schema_check = ActiveRecord::Base.connection.execute(
    \"SELECT 1 FROM information_schema.schemata WHERE schema_name = '#{\"$TENANT_NAME\"}'\"
  ).to_a.any?
  puts schema_check
" 2>&1 | grep -i "true" || echo "false")

if [ "$TENANT_EXISTS" = "true" ]; then
  echo "El tenant '$TENANT_NAME' ya existe"
  exit 1
fi

# Create tenant schema
echo "Creando schema en PostgreSQL..."
APARTMENT_TENANTS="public,$TENANT_NAME" rails runner "
  begin
    Apartment::Tenant.create('$TENANT_NAME')
  rescue Apartment::SchemaExists => e
    puts 'Schema ya existe'
  end
" || true

# Run migrations on the new schema
echo "Ejecutando migraciones..."
APARTMENT_TENANTS="public,$TENANT_NAME" rails runner "
  Apartment::Tenant.switch!('$TENANT_NAME') do
    if defined?(ActiveRecord::MigrationContext)
      migration_context = ActiveRecord::MigrationContext.new(
        Rails.root.join('db/migrate')
      )
      migration_context.up
    end
  end
" 2>&1 | grep -E "(Migrating|migrated|completed)" || true

# Create admin user
echo "Creando usuario administrador..."
APARTMENT_TENANTS="public,$TENANT_NAME" rails runner "
  Apartment::Tenant.switch!('$TENANT_NAME') do
    admin = User.find_or_create_by!(email: '$ADMIN_EMAIL') do |user|
      user.password = '$ADMIN_PASSWORD'
      user.password_confirmation = '$ADMIN_PASSWORD'
      user.name = 'Admin ' + '$TENANT_NAME'.capitalize
      user.role = :admin
    end
    puts \"Usuario creado: \#{admin.email}\"
  end
"

# Create default company
echo "Creando empresa por defecto..."
APARTMENT_TENANTS="public,$TENANT_NAME" rails runner "
  Apartment::Tenant.switch!('$TENANT_NAME') do
    company = Company.find_or_create_by!(nit: '000.000.000-0') do |c|
      c.name = \"#{TENANT_NAME.capitalize} Corporation\"
      c.address = \"Tenant: $TENANT_NAME\"
    end
    puts \"Empresa creada: \#{company.name}\"
    
    # Link admin to company
    admin = User.find_by(email: '$ADMIN_EMAIL')
    CompanyManager.find_or_create_by(user: admin, company: company)
    puts \"Admin vinculado a empresa\"
  end
"

echo ""
echo "="*70
echo "Tenant '$TENANT_NAME' creado exitosamente!"
echo "="*70
echo ""
echo "Información del Tenant:"
echo "   Nombre: $TENANT_NAME"
echo "   Schema: $TENANT_NAME"
echo "   Admin Email: $ADMIN_EMAIL"
echo "   Admin Password: $ADMIN_PASSWORD"
echo ""
echo "Acceso local:"
echo "   http://$TENANT_NAME.localhost:3000"
echo ""
echo "IMPORTANTE: Cambia la contraseña del admin en producción"
echo "="*70
