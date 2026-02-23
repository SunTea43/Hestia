class Company < ApplicationRecord
  has_many :company_managers, dependent: :destroy
  has_many :users, through: :company_managers
  has_many :properties, dependent: :destroy

  validates :name, presence: true
end
