# db/seeds.rb
# Development seeds with Multitenancy (Apartment)
#
# Architecture (NEW - No Client model):
# - Tenant Schemas: "acme", "public" (each is a PostgreSQL schema)
# - Each tenant schema contains: Users, Companies, Properties, Contracts, Charges, Occupants
# - Subdomain routing (acme.localhost) → switches to "acme" schema
# - User authentication happens within the tenant schema

puts "=" * 70
puts "Seeding Hestia Multitenancy Database"
puts "=" * 70

# ========== DEFINE TENANTS ==========
# These are tenant identifiers - should match subdomains in production
# Use "default_tenant" instead of "public" to avoid SQL keyword conflicts
tenants_to_seed = [ "acme", "public" ]  # "public" is the default schema in PostgreSQL

# ========== CREATE TENANT SCHEMAS ==========

puts "\nCreating tenant schemas..."
tenants_to_seed.each do |tenant_name|
  begin
    Apartment::Tenant.create(tenant_name)
    puts "Schema '#{tenant_name}' created"
  rescue Apartment::SchemaExists => e
    puts "Schema already exists: #{tenant_name}"
  rescue => e
    puts "Error creating schema: #{e.message}"
  end
end

# ========== SEED ACME TENANT ==========

puts "\nSwitching to ACME tenant schema..."
Apartment::Tenant.switch!("acme")

# Clean ACME tenant
[ Charge, Contract, Occupant, Property, Company, CompanyManager, User ].each do |model|
  begin
    model.destroy_all
  rescue => e
    puts "  Could not clean #{model.table_name}"
  end
end

puts "\nCreating Users in ACME tenant..."
acme_admin = User.create!(
  email: 'admin@acme.local',
  password: 'password123',
  password_confirmation: 'password123',
  name: 'Admin ACME',
  role: :admin
)
puts "ACME Admin: #{acme_admin.email}"

acme_gestor = User.create!(
  email: 'gestor@acme.local',
  password: 'password123',
  password_confirmation: 'password123',
  name: 'Juan Gestor ACME',
  role: :gestor
)
puts "ACME Gestor: #{acme_gestor.email}"

puts "\nCreating Companies in ACME tenant..."
acme_residential = Company.create!(
  name: 'ACME Residencial',
  nit: '900.123.456-1',
  address: 'Calle 123 # 45-67'
)
puts "Company: #{acme_residential.name}"

acme_commercial = Company.create!(
  name: 'ACME Comercial',
  nit: '900.123.456-2',
  address: 'Calle 456 # 78-90'
)
puts "Company: #{acme_commercial.name}"

# Link users to companies (CompanyManager association)
CompanyManager.create!(user: acme_admin, company: acme_residential)
CompanyManager.create!(user: acme_admin, company: acme_commercial)
CompanyManager.create!(user: acme_gestor, company: acme_residential)
puts "Users linked to companies"

puts "\nCreating Properties in ACME tenant..."
property1 = Property.create!(
  company_id: acme_residential.id,
  address: 'Calle Falsa 123, Apartamento 501',
  area: 85.5,
  property_type: 'Apartamento',
  category: :rent,
  has_elevator: true,
  common_areas: 'Piscina, Gimnasio',
  price: 1_500_000,
  admin_fee_included: true,
  description: 'Hermoso apartamento con vista'
)
puts "Property: #{property1.address}"

property2 = Property.create!(
  company_id: acme_commercial.id,
  address: 'Avenida Empresarial 100, Oficina 2000',
  area: 150.0,
  property_type: 'Oficina',
  category: :rent,
  has_elevator: true,
  common_areas: 'Estacionamiento, Cafetería',
  price: 3_500_000,
  admin_fee_included: false,
  description: 'Oficina premium en centro de negocios'
)
puts "Property: #{property2.address}"

puts "\nCreating Occupants in ACME tenant..."
occupant1 = Occupant.create!(
  name: 'María García López',
  email: 'maria.garcia@email.com',
  phone: '+57 301 234 5678',
  document_number: '1023456789'
)
puts "Occupant: #{occupant1.name}"

occupant2 = Occupant.create!(
  name: 'Javier López (multi-property renter)',
  email: 'javier.lopez@email.com',
  phone: '+57 303 456 7890',
  document_number: '1111111111'
)
puts "Occupant: #{occupant2.name}"

puts "\nCreating Contracts in ACME tenant..."
contract1 = Contract.create!(
  property_id: property1.id,
  occupant_id: occupant1.id,
  start_date: Date.today,
  end_date: 1.year.from_now,
  tenant_income: 5_000_000,
  co_debtor_info: 'Pedro García (padre), Ingresos: 4M'
)
puts "Contract: #{occupant1.name} → #{property1.address}"

contract2 = Contract.create!(
  property_id: property2.id,
  occupant_id: occupant2.id,
  start_date: Date.today,
  end_date: 2.years.from_now,
  tenant_income: 8_000_000,
  co_debtor_info: 'Sin codeudor'
)
puts "Contract: #{occupant2.name} → #{property2.address}"

contract3 = Contract.create!(
  property_id: property1.id,
  occupant_id: occupant2.id,
  start_date: (Date.today + 2.months),
  end_date: (Date.today + 2.months + 18.months),
  tenant_income: 8_000_000,
  co_debtor_info: 'Sin codeudor'
)
puts "Contract: #{occupant2.name} → Multiple contracts"

puts "\nCreating Charges in ACME tenant..."
Charge.create!(
  contract_id: contract1.id,
  amount: 1_500_000,
  charge_type: :rent,
  due_date: (Date.today + 1.month),
  status: :pending
)
Charge.create!(
  contract_id: contract2.id,
  amount: 3_500_000,
  charge_type: :rent,
  due_date: (Date.today + 5.days),
  status: :paid
)
Charge.create!(
  contract_id: contract3.id,
  amount: 1_500_000,
  charge_type: :rent,
  due_date: (Date.today + 3.months),
  status: :pending
)
puts "Charges created"

# ========== SEED DEFAULT TENANT ==========

puts "\nSwitching to DEFAULT tenant schema..."
Apartment::Tenant.reset
Apartment::Tenant.switch!("public")

# Clean default tenant
[ Charge, Contract, Occupant, Property, Company, CompanyManager, User ].each do |model|
  begin
    model.destroy_all
  rescue => e
    puts "  Could not clean #{model.table_name}"
  end
end

puts "\nCreating data for DEFAULT tenant..."
default_admin = User.create!(
  email: 'admin@default.local',
  password: 'password123',
  password_confirmation: 'password123',
  name: 'Admin Default',
  role: :admin
)
puts "Default Admin: #{default_admin.email}"

default_company = Company.create!(
  name: 'Default Properties',
  nit: '800.999.888-7',
  address: 'Calle Default 999'
)
puts "Company: #{default_company.name}"

CompanyManager.create!(user: default_admin, company: default_company)

default_property = Property.create!(
  company_id: default_company.id,
  address: 'Calle del Río 500, Casa 1',
  area: 200.0,
  property_type: 'Casa',
  category: :rent,
  has_elevator: false,
  common_areas: 'Patio, Jardín',
  price: 4_000_000,
  admin_fee_included: true,
  description: 'Casa moderna con terraza'
)
puts "Property: #{default_property.address}"

default_occupant = Occupant.create!(
  name: 'Carlos Mendoza',
  email: 'carlos@email.com',
  phone: '+57 312 345 6789',
  document_number: '1234567890'
)
puts "Occupant: #{default_occupant.name}"

default_contract = Contract.create!(
  property_id: default_property.id,
  occupant_id: default_occupant.id,
  start_date: Date.today,
  end_date: 1.year.from_now,
  tenant_income: 6_000_000,
  co_debtor_info: 'Sin codeudor'
)
puts "Contract created"

# ========== RESET TO PUBLIC SCHEMA ==========

puts "\nResetting to public schema..."
Apartment::Tenant.reset
puts "Back to public schema"

# ========== SEED DOCUMENT TYPES (Shared across all tenants) ==========

puts "\nCreating default document types..."
document_types = [
  {
    name: 'Certificado de Tradición y Libertad',
    description: 'Documento que certifica la historia jurídica del inmueble',
    icon: 'scroll',
    color: '#D4AF37'
  },
  {
    name: 'Documento de Identidad - Propietario',
    description: 'Copia de cédula del propietario del inmueble',
    icon: 'user',
    color: '#3498DB'
  },
  {
    name: 'Documento de Identidad - Inquilino',
    description: 'Copia de cédula del inquilino del arrendamiento',
    icon: 'users',
    color: '#2ECC71'
  },
  {
    name: 'Contrato de Cesión de Administración',
    description: 'Contrato entre propietario e inmobiliaria para administración del inmueble',
    icon: 'file-check',
    color: '#E74C3C'
  },
  {
    name: 'Contrato de Arrendamiento',
    description: 'Contrato de arrendamiento entre inquilino e inmobiliaria/administrador',
    icon: 'file-text',
    color: '#9B59B6'
  }
]

document_types.each do |dt|
  DocumentType.find_or_create_by!(name: dt[:name]) do |type|
    type.description = dt[:description]
    type.icon = dt[:icon]
    type.color = dt[:color]
  end
  puts "Document Type: #{dt[:name]}"
end

# ========== SUMMARY ==========

puts "\n" + "=" * 70
puts "Seeds completed successfully!"
puts "=" * 70

puts "\nTenant: acme"
Apartment::Tenant.switch!("acme") do
  puts "  Users: #{User.count}"
  puts "  Companies: #{Company.count}"
  puts "  Properties: #{Property.count}"
  puts "  Occupants: #{Occupant.count}"
  puts "  Contracts: #{Contract.count}"
  puts "  Charges: #{Charge.count}"
end

puts "\nTenant: default"
Apartment::Tenant.switch!("public") do
  puts "  Users: #{User.count}"
  puts "  Companies: #{Company.count}"
  puts "  Properties: #{Property.count}"
  puts "  Occupants: #{Occupant.count}"
  puts "  Contracts: #{Contract.count}"
  puts "  Charges: #{Charge.count}"
end

puts "\n" + "=" * 70
puts "🎯 Account Credentials:"
puts "=" * 70
puts "\nTenant: ACME (acme.localhost:3000)"
puts "  Admin: admin@acme.local / password123"
puts "  Gestor: gestor@acme.local / password123"
puts "\nTenant: DEFAULT (localhost:3000)"
puts "  Admin: admin@default.local / password123"
puts "\n" + "=" * 70
