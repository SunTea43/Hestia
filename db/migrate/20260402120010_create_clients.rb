# DEPRECATED: Clients model is not needed
# Subdomain is managed by Apartment gem, not stored in a model
# Each tenant schema (e.g., tenant_acme) is created/managed by Apartment

class CreateClients < ActiveRecord::Migration[8.1]
  def up
    # No-op - this migration is not executed
  end

  def down
    # No-op
  end
end
