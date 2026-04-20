class Document < ApplicationRecord
  belongs_to :property
  belongs_to :occupant
  belongs_to :document_template, optional: true

  has_many :children, class_name: "Document", foreign_key: :parent_id, dependent: :destroy
  belongs_to :parent, class_name: "Document", optional: true

  has_many :charges, dependent: :destroy
  has_one_attached :file

  # For backward compatibility with previous 'Contract' model fields
  store_accessor :metadata, :tenant_income, :co_debtor_info

  validates :start_date, presence: true

  scope :root, -> { where(parent_id: nil) }

  before_validation :copy_template_content, if: :document_template_id_changed?
  before_validation :resolve_variables, if: :should_resolve_variables?
  after_create :send_confirmation_email

  def interpolate_body
    return body unless body

    context = DocumentContext.new(
      property: property,
      occupant: occupant,
      contract: find_contract,
      company: property&.company,
      document: self
    )

    resolver = DocumentVariableResolver.new(context)
    resolver.resolve(body)
  end

  private

  def copy_template_content
    return unless document_template && body.blank?
    self.body = document_template.body
  end

  def should_resolve_variables?
    document_template.present? && body.present? && document_template.document_type&.html_template?
  end

  def resolve_variables
    return unless should_resolve_variables?
    self.body = interpolate_body
  end

  def find_contract
    Contract.find_by(property_id: property_id, occupant_id: occupant_id)
  end

  def send_confirmation_email
    TenantMailer.document_confirmation_email(occupant, property, self).deliver_later
  end
end
