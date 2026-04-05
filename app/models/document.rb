class Document < ApplicationRecord
  belongs_to :document_type
  belongs_to :property
  belongs_to :occupant
  has_many :charges, dependent: :destroy

  # For backward compatibility with previous 'Contract' model fields
  store_accessor :metadata, :tenant_income, :co_debtor_info

  validates :start_date, presence: true

  after_create :send_confirmation_email

  private

  def send_confirmation_email
    TenantMailer.document_confirmation_email(occupant, property, self).deliver_later
  end
end
