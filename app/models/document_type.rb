class DocumentType < ApplicationRecord
  has_many :documents, dependent: :restrict_with_error
end
