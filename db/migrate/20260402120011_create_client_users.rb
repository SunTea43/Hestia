# DEPRECATED: ClientUser model is not needed
# Users belong to a tenant schema, not to a Client entity
# Access control is handled via Company and role-based permissions

class CreateClientUsers < ActiveRecord::Migration[8.1]
  def up
    # No-op - this migration is not executed
  end

  def down
    # No-op
  end
end
