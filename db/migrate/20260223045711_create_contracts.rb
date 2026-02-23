class CreateContracts < ActiveRecord::Migration[8.1]
  def change
    create_table :contracts do |t|
      t.references :property, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: { to_table: :users }
      t.date :start_date
      t.date :end_date
      t.decimal :tenant_income
      t.text :co_debtor_info

      t.timestamps
    end
  end
end
