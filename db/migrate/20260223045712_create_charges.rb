class CreateCharges < ActiveRecord::Migration[8.1]
  def change
    create_table :charges do |t|
      t.references :contract, null: false, foreign_key: true
      t.decimal :amount
      t.integer :charge_type
      t.date :due_date
      t.integer :status

      t.timestamps
    end
  end
end
