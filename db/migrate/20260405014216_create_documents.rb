class CreateDocuments < ActiveRecord::Migration[8.1]
  def change
    # Rename the table
    rename_table :contracts, :documents

    # Add new abstract fields
    add_reference :documents, :document_type, foreign_key: true
    add_column :documents, :name, :string
    add_column :documents, :body, :text
    add_column :documents, :status, :string
    add_column :documents, :metadata, :jsonb

    # Update the charges table reference
    rename_column :charges, :contract_id, :document_id
  end
end
