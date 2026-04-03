# Apartment Tenant Middleware
# Extracts subdomain from request host and switches to appropriate tenant schema
#
# Schema naming convention: subdomain → "subdomain" (stored in APARTMENT_TENANTS env or dynamically)
# Examples:
#   - acme.myapp.local → "acme"
#   - localhost:3000 → "default"
#   - www.myapp.local → "default"

class ApartmentTenantMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    # Use ActionDispatch::Request instead of Rack::Request to access subdomain method
    request = ActionDispatch::Request.new(env)

    # Extract subdomain from host
    # "acme.myapp.local" → "acme"
    # "localhost:3000" → nil (local development)
    subdomain = request.subdomain

    # Determine tenant name
    tenant_name = if subdomain.present? && subdomain != "www"
                    subdomain  # Use subdomain as tenant identifier
                  else
                    "public"  # Use PostgreSQL's default schema
                  end

    begin
      # Switch to tenant schema
      Apartment::Tenant.switch!(tenant_name)

      # Process request
      status, headers, body = @app.call(env)

      [status, headers, body]
    rescue Apartment::TenantNotFound => e
      # Tenant schema doesn't exist
      [404, { "Content-Type" => "text/plain" }, ["Tenant not found: #{tenant_name}"]]
    ensure
      # Always reset to public schema after request
      Apartment::Tenant.reset
    end
  end
end
