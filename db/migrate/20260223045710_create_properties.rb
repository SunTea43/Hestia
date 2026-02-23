class CreateProperties < ActiveRecord::Migration[8.1]
  def change
    create_table :properties do |t|
      t.references :company, null: false, foreign_key: true
      t.string :address
      t.decimal :area
      t.string :property_type
      t.integer :category
      t.boolean :has_elevator
      t.text :common_areas
      t.decimal :price
      t.boolean :admin_fee_included
      t.text :description

      t.timestamps
    end
  end
end
