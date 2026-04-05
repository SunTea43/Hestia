# DEPRECATED: Company doesn't need client_id
# Companies live in tenant schemas
# The tenant identifier is managed by Apartment, not stored in Company

class AddClientIdToCompanies < ActiveRecord::Migration[8.1]
  def up
    # No-op - this migration is not executed
  end

  def down
    # No-op
  end
end
