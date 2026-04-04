# Manual Multitenancy Implementation with PostgreSQL Schemas
# No external Apartment gem - using custom schema switching
#
# Each tenant gets a PostgreSQL schema:
#   - "acme" → domain acme.localhost
#   - "public" → domain localhost:3000 (PostgreSQL's default schema)
#
# Schema switching is done via ActiveRecord connection.execute("SET search_path TO ...")

# Define Apartment namespace and classes for compatibility
module Apartment
  class TenantNotFound < StandardError; end
  class SchemaExists < StandardError; end

  # List of configured tenants from environment
  TENANT_NAMES = ENV["APARTMENT_TENANTS"]&.split(",")&.map(&:strip) || [ "public" ]

  def self.tenant_names
    TENANT_NAMES
  end

  # Tenant switching module
  module Tenant
    @@current_tenant = "public"

    def self.current
      @@current_tenant
    end

    def self.switch!(tenant_name)
      unless Apartment::TENANT_NAMES.include?(tenant_name)
        raise Apartment::TenantNotFound, "Tenant '#{tenant_name}' is not configured"
      end

      # Set PostgreSQL search_path to the tenant schema
      # Use SQL formatting that PostgreSQL accepts
      ActiveRecord::Base.connection.execute("SET search_path TO \"#{tenant_name}\", public;")
      @@current_tenant = tenant_name
    end

    def self.reset
      # Reset to public schema
      # no-op since we're already using public
      @@current_tenant = "public"
    end

    def self.create(tenant_name)
      # Check if schema exists
      schema_check = ActiveRecord::Base.connection.execute(
        "SELECT 1 FROM information_schema.schemata WHERE schema_name = '#{tenant_name}'"
      ).to_a

      if schema_check.any?
        raise Apartment::SchemaExists, "Schema '#{tenant_name}' already exists"
      end

      # Create schema (skip if trying to create "public" - it already exists)
      if tenant_name != "public"
        ActiveRecord::Base.connection.execute("CREATE SCHEMA \"#{tenant_name}\";")
        puts "✅ Created schema: #{tenant_name}"
      end
    end

    def self.switch(tenant_name)
      previous_tenant = @@current_tenant
      switch!(tenant_name)
      yield if block_given?
    ensure
      switch!(previous_tenant) if block_given?
    end
  end
end

puts "🏢 Multitenancy Configured"
puts "   Tenants: #{Apartment::TENANT_NAMES.join(', ')}"
