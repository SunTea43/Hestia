# Relación: User tiene acceso a múltiples Clients
# Vive en PUBLIC schema
#
# Reemplaza la anterior CompanyManager (que era Company-específica)
# Ahora es Client-específica (nivel superior)

class ClientUser < ApplicationRecord
  belongs_to :user
  belongs_to :client

  # Apartment: vive en PUBLIC schema
  self.excluded_from_tenants = true

  validates :user_id, uniqueness: { scope: :client_id }
end
