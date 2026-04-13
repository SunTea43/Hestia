class DocumentTemplate < ApplicationRecord
  has_many :children, class_name: "DocumentTemplate", foreign_key: :parent_id, dependent: :destroy
  belongs_to :parent, class_name: "DocumentTemplate", optional: true

  has_many :documents, dependent: :nullify

  validates :name, presence: true
  validates :body, presence: true

  scope :root, -> { where(parent_id: nil) }
end
