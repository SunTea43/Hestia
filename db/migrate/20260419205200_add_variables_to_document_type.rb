class AddVariablesToDocumentType < ActiveRecord::Migration[8.1]
  def change
    add_column :document_types, :variables, :jsonb
  end
end
