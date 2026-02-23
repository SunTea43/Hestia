class Charge < ApplicationRecord
  belongs_to :contract

  enum :charge_type, { rent: 0, cleaning: 1, legal: 2, other: 3 }
  enum :status, { pending: 0, paid: 1 }

  validates :amount, :charge_type, :due_date, :status, presence: true
end
