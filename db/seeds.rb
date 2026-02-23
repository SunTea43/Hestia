# db/seeds.rb

puts "Cleaning database..."
Charge.destroy_all
Contract.destroy_all
Property.destroy_all
CompanyManager.destroy_all
Company.destroy_all
User.destroy_all

puts "Creating users..."
admin = User.create!(
  email: 'admin@hestia.com',
  password: 'password',
  name: 'Admin Hestia',
  role: :admin
)

gestor = User.create!(
  email: 'gestor@hestia.com',
  password: 'password',
  name: 'Juan Gestor',
  role: :gestor
)

inquilino = User.create!(
  email: 'inquilino@hestia.com',
  password: 'password',
  name: 'Maria Inquilino',
  role: :inquilino,
  document_number: '12345678',
  birth_date: '1990-01-01'
)

puts "Creating company..."
company = Company.create!(
  name: 'Inmobiliaria Hestia',
  nit: '900.123.456-1',
  address: 'Calle 123 # 45-67'
)

CompanyManager.create!(company: company, user: gestor)

puts "Creating properties..."
prop1 = Property.create!(
  company: company,
  address: 'Calle Falsa 123',
  area: 85.5,
  property_type: 'Apartamento',
  category: :rent,
  has_elevator: true,
  common_areas: 'Piscina, Gimnasio',
  price: 1500000,
  admin_fee_included: true,
  description: 'Hermoso apartamento con vista a la ciudad'
)

prop2 = Property.create!(
  company: company,
  address: 'Carrera 10 # 20-30',
  area: 120.0,
  property_type: 'Casa',
  category: :sale,
  has_elevator: false,
  common_areas: 'Patio, Garaje',
  price: 450000000,
  admin_fee_included: false,
  description: 'Casa amplia en sector residencial'
)

puts "Creating contract..."
contract = Contract.create!(
  property: prop1,
  tenant: inquilino,
  start_date: Date.today,
  end_date: 1.year.from_now,
  tenant_income: 5000000,
  co_debtor_info: 'Codeudor: Pedro Perez, Ingresos: 4000000'
)

puts "Creating charges..."
Charge.create!(
  contract: contract,
  amount: 1500000,
  charge_type: :rent,
  due_date: Date.today,
  status: :pending
)

Charge.create!(
  contract: contract,
  amount: 50000,
  charge_type: :cleaning,
  due_date: Date.today,
  status: :paid
)

puts "Seeds finished!
Admin: admin@hestia.com / password
Gestor: gestor@hestia.com / password
Inquilino: inquilino@hestia.com / password"
