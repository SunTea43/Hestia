class CreateDocumentTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :document_types do |t|
      t.string :name
      t.text :description
      t.string :icon
      t.string :color

      t.timestamps
    end
  end
end
