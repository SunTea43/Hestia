# Load Apartment Tenant Middleware
require Rails.root.join("app/middleware/apartment_tenant_middleware")

# Register middleware in Rails stack
Rails.application.config.middleware.use ApartmentTenantMiddleware
