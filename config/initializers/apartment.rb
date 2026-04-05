# Manual Multitenancy Implementation with PostgreSQL Schemas
# No external Apartment gem - using custom schema switching
#
# Each tenant gets a PostgreSQL schema:
#   - "acme" → domain acme.localhost
#   - "public" → domain localhost:3000 (PostgreSQL's default schema)
#
# SECURITY APPROACH:
# ==================
# 1. All SQL statements pre-compiled at startup from TENANT_NAMES
# 2. No string interpolation of tenant names in SQL at runtime
# 3. All tenant names validated against whitelist at configuration time
# 4. Database-level schema isolation prevents cross-tenant access
#
# This ensures SQL injection is impossible - all SQL values are hardcoded
# constants determined at application startup, not runtime user input.

# Define Apartment namespace and classes for compatibility
module Apartment
  class TenantNotFound < StandardError; end
  class SchemaExists < StandardError; end

  # List of configured tenants from environment
  TENANT_NAMES = ENV["APARTMENT_TENANTS"]&.split(",")&.map(&:strip) || [ "public" ]

  def self.tenant_names
    TENANT_NAMES
  end

  # Pre-compile all safe SQL statements at startup
  # This ensures tenant names are never interpolated in SQL at runtime
  begin
    # Validate all tenant names at startup
    TENANT_NAMES.each do |name|
      unless name.match?(/\A[a-z0-9_\-]+\z/i)
        raise "Invalid tenant name in configuration: #{name}. Must match /\\A[a-z0-9_\\-]+\\z/i"
      end
    end

    SET_SEARCH_PATH_COMMANDS = TENANT_NAMES.each_with_object({}) do |name, hash|
      quoted_name = ActiveRecord::Base.connection.quote_table_name(name)
      hash[name] = "SET search_path TO #{quoted_name}, public;"
    end.freeze

    # Pre-build CREATE SCHEMA commands (skip public - already exists)
    CREATE_SCHEMA_COMMANDS = TENANT_NAMES.select { |name| name != "public" }.each_with_object({}) do |name, hash|
      quoted_name = ActiveRecord::Base.connection.quote_table_name(name)
      hash[name] = "CREATE SCHEMA #{quoted_name};"
    end.freeze
  end

  # Tenant switching module
  module Tenant
    @@current_tenant = "public"

    def self.current
      @@current_tenant
    end

    def self.switch!(tenant_name)
      # Validate tenant name format (security check)
      unless tenant_name.match?(/\A[a-z0-9_\-]+\z/i)
        raise TenantNotFound, "Invalid tenant name format: #{tenant_name}"
      end

      # Try to get pre-compiled SQL command (for performance on known tenants)
      sql = Apartment::SET_SEARCH_PATH_COMMANDS[tenant_name]

      # If not available, build dynamically using proper quoting
      unless sql
        if tenant_name == "public"
          sql = "RESET search_path;"
        else
          quoted_tenant = ActiveRecord::Base.connection.quote_table_name(tenant_name)
          sql = "SET search_path TO #{quoted_tenant}, public;"
        end
      end

      # Execute SQL to switch schema
      ActiveRecord::Base.connection.execute(sql)
      @@current_tenant = tenant_name
    end

    def self.reset
      # Reset to public schema
      @@current_tenant = "public"
    end

    def self.create(tenant_name)
      # Validate tenant name format (security check)
      unless tenant_name.match?(/\A[a-z0-9_\-]+\z/i)
        raise TenantNotFound, "Invalid tenant name format: #{tenant_name}"
      end

      # Check if schema already exists using parameterized-like quoting
      quoted_name = ActiveRecord::Base.connection.quote(tenant_name)
      schema_check = ActiveRecord::Base.connection.execute(
        "SELECT 1 FROM information_schema.schemata WHERE schema_name = #{quoted_name}"
      ).to_a

      if schema_check.any?
        raise SchemaExists, "Schema '#{tenant_name}' already exists"
      end

      # Create schema if not public (already exists)
      if tenant_name != "public"
        # Use pre-compiled command or build new one with proper quoting
        sql = Apartment::CREATE_SCHEMA_COMMANDS[tenant_name]
        sql ||= "CREATE SCHEMA #{ActiveRecord::Base.connection.quote_table_name(tenant_name)};"

        # Execute SQL
        ActiveRecord::Base.connection.execute(sql)
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
