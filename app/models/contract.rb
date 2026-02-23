class Contract < ApplicationRecord
  belongs_to :property
  belongs_to :tenant, class_name: "User"
  has_many :charges, dependent: :destroy

  validates :start_date, :tenant_income, presence: true
end
