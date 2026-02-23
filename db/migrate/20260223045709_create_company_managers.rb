class CreateCompanyManagers < ActiveRecord::Migration[8.1]
  def change
    create_table :company_managers do |t|
      t.references :company, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
