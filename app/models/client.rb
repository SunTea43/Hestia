# Cliente SaaS
# Punto de entrada de multitenancy (cada Client = 1 tenant/schema)
#
# Multitenancy via Apartment:
#   Client "ACME" (subdomain: "acme") → schema "tenant_acme"
#
# Un Client puede tener:
#   - Múltiples Companies (todas en mismo tenant schema)
#   - Múltiples Users via ClientUsers
#   - Estar distribuido en múltiples monolitos (si lo decide)

class Client < ApplicationRecord
  has_many :client_users, dependent: :destroy
  has_many :users, through: :client_users
  has_many :companies, dependent: :destroy

  # Apartment: vive en PUBLIC schema
  self.excluded_from_tenants = true

  validates :name, :subdomain, presence: true
  validates :subdomain, uniqueness: true,
            format: { with: /\A[a-z0-9_]+\z/, message: "must be lowercase alphanumeric with underscores" }
  validates :plan, inclusion: { in: %w(free pro enterprise) }, allow_blank: true

  # Tenant schema name for Apartment
  def tenant_name
    "tenant_#{subdomain}"
  end
end
