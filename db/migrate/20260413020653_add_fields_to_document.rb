class AddFieldsToDocument < ActiveRecord::Migration[8.1]
  def change
    add_column :documents, :parent_id, :integer
    add_column :documents, :document_template_id, :integer

    add_index :documents, :parent_id
    add_index :documents, :document_template_id
    add_foreign_key :documents, :documents, column: :parent_id
    add_foreign_key :documents, :document_templates
  end
end
