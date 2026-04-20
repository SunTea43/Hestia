class DocumentType < ApplicationRecord
  has_many :document_templates, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :template_type, presence: true, inclusion: { in: %w[html attachment] }

  scope :html_templates, -> { where(template_type: "html") }
  scope :attachment_templates, -> { where(template_type: "attachment") }

  def html_template?
    template_type == "html"
  end

  def attachment_template?
    template_type == "attachment"
  end
end
