# Occupant - Persona que renta una propiedad (inquilino/ocupante del inmueble)
# Lives in TENANT schema (not in public schema)
# One Occupant can have MULTIPLE Contracts (puede rentar varias propiedades)

class Occupant < ApplicationRecord
  has_many :documents, dependent: :restrict_with_error
  has_many :properties, through: :documents
  has_many :charges, through: :documents

  validates :name, :email, presence: true
  validates :email, uniqueness: { scope: :id }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, format: { with: /\A[\+\d\s\-\(\)]+\z/, message: "invalid format" }, allow_blank: true
  validates :document_number, uniqueness: { allow_blank: true }

  def full_information
    "#{name} (#{email}) - Doc: #{document_number}"
  end
end
