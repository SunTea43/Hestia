class Property < ApplicationRecord
  belongs_to :company
  has_many :contracts, dependent: :destroy

  enum :category, { rent: 0, sale: 1 }

  validates :address, :area, :property_type, :category, :price, presence: true
end
