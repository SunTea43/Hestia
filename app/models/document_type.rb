class DocumentType < ApplicationRecord
  has_many :document_templates, dependent: :restrict_with_error
end
