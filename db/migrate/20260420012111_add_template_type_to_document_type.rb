class AddTemplateTypeToDocumentType < ActiveRecord::Migration[8.1]
  def change
    add_column :document_types, :template_type, :string, default: 'html', null: false
    add_index :document_types, :template_type
  end
end
