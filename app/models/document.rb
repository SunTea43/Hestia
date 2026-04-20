class Document < ApplicationRecord
  belongs_to :property
  belongs_to :occupant
  belongs_to :document_template, optional: true

  has_many :children, class_name: "Document", foreign_key: :parent_id, dependent: :destroy
  belongs_to :parent, class_name: "Document", optional: true

  has_many :charges, dependent: :destroy
  has_one_attached :file

  # For backward compatibility with previous 'Contract' model fields
  store_accessor :metadata, :tenant_income, :co_debtor_info, :attachment_origin, :generated_pdf_at, :manual_attachment_at

  validates :start_date, presence: true

  scope :root, -> { where(parent_id: nil) }

  after_create :send_confirmation_email

  def html_template?
    document_template&.html_template?
  end

  def attachment_template?
    document_template&.attachment_template?
  end

  def rendered_body
    source_body = if html_template? && document_template&.body.present?
      document_template.body
    else
      body
    end

    return source_body unless source_body.present?

    DocumentVariableResolver.new(document_context).resolve(source_body)
  end

  def display_name
    name.presence || document_template&.name || "Documento #{id}"
  end

  def generated_pdf_attached?
    file.attached? && attachment_origin == "generated_pdf"
  end

  def manual_attachment?
    file.attached? && attachment_origin == "manual_upload"
  end

  def pdf_filename
    base_name = display_name
    "#{base_name.parameterize}.pdf"
  end

  def attach_generated_pdf!(pdf_binary)
    file.purge if file.attached?

    file.attach(
      io: StringIO.new(pdf_binary),
      filename: pdf_filename,
      content_type: "application/pdf"
    )

    update_attachment_metadata!(
      attachment_origin: "generated_pdf",
      generated_pdf_at: Time.current.iso8601,
      manual_attachment_at: nil
    )
  end

  def mark_manual_attachment!
    return unless file.attached?

    update_attachment_metadata!(
      attachment_origin: "manual_upload",
      manual_attachment_at: Time.current.iso8601,
      generated_pdf_at: nil
    )
  end

  private

  def update_attachment_metadata!(attributes)
    updated_metadata = (metadata || {}).merge(attributes.stringify_keys)

    if persisted?
      update_columns(metadata: updated_metadata, updated_at: Time.current)
      self.metadata = updated_metadata
    else
      self.metadata = updated_metadata
    end
  end

  def document_context
    DocumentContext.new(
      property: property,
      occupant: occupant,
      contract: nil,
      company: property&.company,
      document: self
    )
  end

  def send_confirmation_email
    TenantMailer.document_confirmation_email(occupant, property, self).deliver_later
  end
end
