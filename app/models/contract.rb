class Contract < ApplicationRecord
  belongs_to :property
  belongs_to :tenant, class_name: "User"
  has_many :charges, dependent: :destroy

  validates :start_date, :tenant_income, presence: true

  after_create :send_confirmation_email

  private

  def send_confirmation_email
    TenantMailer.contract_confirmation_email(tenant, property, self).deliver_later
  end
end
