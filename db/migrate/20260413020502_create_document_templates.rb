class CreateDocumentTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :document_templates do |t|
      t.string :name
      t.text :description
      t.text :body
      t.integer :parent_id

      t.timestamps
    end

    add_index :document_templates, :parent_id
    add_foreign_key :document_templates, :document_templates, column: :parent_id
  end
end
