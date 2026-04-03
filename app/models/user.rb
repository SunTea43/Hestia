# Usuario que accede a la aplicación (autenticación)
# Roles: admin (acceso total), gestor (gestiona companies/properties)
#
# IMPORTANTE: Los inquilinos/ocupantes del inmueble son modelo separado: Occupant
# Un User pertenece a un tenant schema (vía Apartment)

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { admin: 0, gestor: 1 }

  # Apartment: User vive en su respectivo TENANT schema
  # Todos los users de ACME en schema tenant_acme, etc
  # No excluded_from_tenants - quiere decir que CADA tenant tiene sus users

  validates :name, :role, presence: true
end
