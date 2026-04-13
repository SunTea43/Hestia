class AddDocumentTypeToDocumentTemplates < ActiveRecord::Migration[8.1]
  def change
    add_reference :document_templates, :document_type, null: true, foreign_key: true
  end
end
