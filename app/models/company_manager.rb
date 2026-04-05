# CompanyManager - Relación vinculando User con Companies dentro del tenant
# Permite que un User (admin/gestor) gestione múltiples Companies

class CompanyManager < ApplicationRecord
  belongs_to :company
  belongs_to :user
end
