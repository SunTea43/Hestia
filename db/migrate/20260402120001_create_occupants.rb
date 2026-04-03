class CreateOccupants < ActiveRecord::Migration[8.1]
  def change
    create_table :occupants do |t|
      t.string :name, null: false
      t.string :email
      t.string :phone
      t.string :document_number

      t.timestamps
    end
    
    add_index :occupants, :email
    add_index :occupants, :document_number
  end
end
