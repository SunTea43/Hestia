class DocumentTemplate < ApplicationRecord
  belongs_to :document_type, optional: true

  has_many :children, class_name: "DocumentTemplate", foreign_key: :parent_id, dependent: :destroy
  belongs_to :parent, class_name: "DocumentTemplate", optional: true

  has_many :documents, dependent: :nullify

  validates :name, presence: true
  validates :body, presence: true, if: :requires_body?

  scope :root, -> { where(parent_id: nil) }

  def html_template?
    document_type&.html_template?
  end

  def attachment_template?
    document_type&.attachment_template?
  end

  def as_json(options = {})
    super(options.merge(include: :document_type))
  end

  private

  def requires_body?
    document_type.present? && document_type.html_template?
  end
end
