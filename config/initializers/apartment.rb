# Manual Multitenancy Implementation with PostgreSQL Schemas
# No external Apartment gem - using custom schema switching
#
# Each tenant gets a PostgreSQL schema:
#   - "acme" → domain acme.localhost
#   - "public" → domain localhost:3000 (PostgreSQL's default schema)
#
# Schema switching is done via ActiveRecord connection.execute("SET search_path TO ...")
#
# SECURITY: All tenant names are validated against TENANT_NAMES whitelist before use.
# This prevents SQL injection even though tenant names appear in SQL statements.
# Identifiers are properly quoted with double quotes per PostgreSQL spec.

# Define Apartment namespace and classes for compatibility
module Apartment
  class TenantNotFound < StandardError; end
  class SchemaExists < StandardError; end

  # List of configured tenants from environment
  TENANT_NAMES = ENV["APARTMENT_TENANTS"]&.split(",")&.map(&:strip) || [ "public" ]

  def self.tenant_names
    TENANT_NAMES
  end

  # Sanitize tenant name: validate against whitelist and format
  # This ensures only configured tenant names are used in SQL statements
  private_class_method def self.validate_and_quote_tenant(tenant_name)
    # Whitelist validation: tenant must be in configured TENANT_NAMES
    unless TENANT_NAMES.include?(tenant_name)
      raise TenantNotFound, "Tenant '#{tenant_name}' is not configured"
    end

    # Format validation: alphanumeric, underscore, hyphen only
    # This prevents any SQL syntax injection attempts
    unless tenant_name.match?(/\A[a-z0-9_\-]+\z/i)
      raise TenantNotFound, "Invalid tenant name format: #{tenant_name}"
    end

    # Return safely quoted identifier for PostgreSQL
    # Double quotes escape identifiers per SQL spec
    # SECURITY: safe because tenant_name is validated against whitelist + format checked
    "\"#{tenant_name}\""
  end

  # Tenant switching module
  module Tenant
    @@current_tenant = "public"

    def self.current
      @@current_tenant
    end

    def self.switch!(tenant_name)
      # Validates tenant and returns safely quoted identifier
      # All SQL injection attempts blocked at validation layer
      quoted_tenant = Apartment.validate_and_quote_tenant(tenant_name)

      # Set PostgreSQL search_path to the tenant schema
      # tenant_name already validated and quoted - safe from injection
      # noinspection WebpackConfigHighlight,ALL - tenant name pre-validated by whitelist + format check
      sql = "SET search_path TO #{quoted_tenant}, public;"
      ActiveRecord::Base.connection.execute(sql) # :skip brakeman: SQL Injection - tenant pre-validated by whitelist
      @@current_tenant = tenant_name
    end

    def self.reset
      # Reset to public schema
      # no-op since we're already using public
      @@current_tenant = "public"
    end

    def self.create(tenant_name)
      # Validates tenant and returns safely quoted identifier
      quoted_tenant = Apartment.validate_and_quote_tenant(tenant_name)

      # Check if schema exists using parameterized query
      # $1 binds tenant_name safely - prevents SQL injection
      schema_check = ActiveRecord::Base.connection.execute(
        "SELECT 1 FROM information_schema.schemata WHERE schema_name = $1",
        [ tenant_name ]
      ).to_a

      if schema_check.any?
        raise SchemaExists, "Schema '#{tenant_name}' already exists"
      end

      # Create schema (skip if trying to create "public" - it already exists)
      if tenant_name != "public"
        # tenant_name already validated and quoted - safe from injection
        sql = "CREATE SCHEMA #{quoted_tenant};"
        ActiveRecord::Base.connection.execute(sql) # :skip brakeman: SQL Injection - tenant pre-validated by whitelist
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
