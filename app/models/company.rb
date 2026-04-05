# Empresa gestora inmobiliaria
# Vive en TENANT SCHEMA (aislada por Apartment)
# - Un tenant puede tener múltiples Companies
#
# Ejemplo: Tenant "acme" (schema tenant_acme) tiene:
#   - Company "ACME Residencial"
#   - Company "ACME Comercial"
#   Todas comparten el mismo schema tenant_acme

class Company < ApplicationRecord
  has_many :properties, dependent: :destroy
  has_many :company_managers, dependent: :destroy
  has_many :contracts, through: :properties
  has_many :charges, through: :contracts

  validates :name, presence: true
end
