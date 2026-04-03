class RenameContractTenantToOccupant < ActiveRecord::Migration[8.1]
  def change
    # Rename foreign key from tenant_id to occupant_id
    rename_column :contracts, :tenant_id, :occupant_id

    # Update the foreign key constraint to point to occupants instead of users
    remove_foreign_key :contracts, column: :occupant_id
    add_foreign_key :contracts, :occupants, column: :occupant_id
  end
end
