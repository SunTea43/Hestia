class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Compatibilidad con la implementación personalizada de multitenancy
  class_attribute :excluded_from_tenants, default: false
end
