# Inmueble para alquiler
# Vive en TENANT SCHEMA (aislado por Company via Apartment)

class Property < ApplicationRecord
  belongs_to :company
  has_many :documents, dependent: :destroy
  has_many :charges, through: :documents

  enum :category, { rent: 0, sale: 1 }

  validates :address, :area, :property_type, :category, :price, presence: true
end
