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
  after_create :send_confirmation_email

  def interpolate_body
    return body unless body

    interpolated = body.dup

    # Property variables
    if property
      interpolated = interpolated.gsub(/\{\{property\.address\}\}/, property.address.to_s)
      interpolated = interpolated.gsub(/\{\{property\.area\}\}/, property.area.to_s)
      interpolated = interpolated.gsub(/\{\{property\.price\}\}/, property.price.to_s)
      interpolated = interpolated.gsub(/\{\{property\.property_type\}\}/, property.property_type.to_s)
      interpolated = interpolated.gsub(/\{\{property\.description\}\}/, property.description.to_s)
      interpolated = interpolated.gsub(/\{\{property\.common_areas\}\}/, property.common_areas.to_s)
    end

    # Occupant variables
    if occupant
      interpolated = interpolated.gsub(/\{\{occupant\.name\}\}/, occupant.name.to_s)
      interpolated = interpolated.gsub(/\{\{occupant\.email\}\}/, occupant.email.to_s)
      interpolated = interpolated.gsub(/\{\{occupant\.phone\}\}/, occupant.phone.to_s)
      interpolated = interpolated.gsub(/\{\{occupant\.document_number\}\}/, occupant.document_number.to_s)
    end

    # Document metadata variables
    if metadata
      interpolated = interpolated.gsub(/\{\{document\.tenant_income\}\}/, metadata["tenant_income"].to_s)
      interpolated = interpolated.gsub(/\{\{document\.co_debtor_info\}\}/, metadata["co_debtor_info"].to_s)
    end

    # Date variables
    if start_date
      interpolated = interpolated.gsub(/\{\{document\.start_date\}\}/, start_date.strftime("%d/%m/%Y"))
    end
    if end_date
      interpolated = interpolated.gsub(/\{\{document\.end_date\}\}/, end_date.strftime("%d/%m/%Y"))
    end

    interpolated
  end

  private

  def copy_template_content
    return unless document_template && body.blank?
    self.body = document_template.body
  end

  def send_confirmation_email
    TenantMailer.document_confirmation_email(occupant, property, self).deliver_later
  end
end
