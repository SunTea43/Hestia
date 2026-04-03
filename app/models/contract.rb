# Contrato de alquiler vinculando Property + Occupant
# - occupant_id: Inquilino que renta (modelo Occupant)
# - property_id: Inmueble siendo alquilado

class Contract < ApplicationRecord
  belongs_to :property
  belongs_to :occupant, class_name: "Occupant", foreign_key: :occupant_id
  has_many :charges, dependent: :destroy

  validates :start_date, :tenant_income, presence: true

  after_create :send_confirmation_email

  private

  def send_confirmation_email
    TenantMailer.contract_confirmation_email(occupant, property, self).deliver_later
  end
end
