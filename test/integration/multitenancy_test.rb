require "test_helper"

class MultitenancyTest < ActionDispatch::IntegrationTest
  setup do
    # Configure test tenants
    ENV["APARTMENT_TENANTS"] = "public,acme,test"

    # Create test tenant schema if it doesn't exist
    create_test_schema("test")
    create_test_schema("acme")
    create_test_schema("public")
  end

  test "switching between tenants isolates data correctly" do
    # Create data in "test" tenant
    Apartment::Tenant.switch!("test") do
      Company.destroy_all

      test_company = Company.create!(
        name: "Test Company",
        nit: "999.999.999-9",
        address: "Test Address"
      )

      assert_equal 1, Company.count, "Should have 1 company in test tenant"
      assert_equal "Test Company", Company.first.name
    end

    # Verify data doesn't exist in "acme" tenant
    Apartment::Tenant.switch!("acme") do
      Company.destroy_all  # Clear any existing data

      assert_equal 0, Company.count, "acme tenant should have no companies initially"

      acme_company = Company.create!(
        name: "ACME Company",
        nit: "900.000.000-0",
        address: "ACME Address"
      )

      assert_equal 1, Company.count
      assert_equal "ACME Company", Company.first.name
    end

    # Verify test tenant still has original data
    Apartment::Tenant.switch!("test") do
      assert_equal 1, Company.count
      assert_equal "Test Company", Company.first.name
      assert_not_equal "ACME Company", Company.first.name
    end

    # Verify acme tenant still has its data
    Apartment::Tenant.switch!("acme") do
      assert_equal 1, Company.count
      assert_equal "ACME Company", Company.first.name
    end
  end

  test "occupant data is isolated by tenant" do
    Apartment::Tenant.switch!("test") do
      Occupant.destroy_all

      test_occupant = Occupant.create!(
        name: "Test Occupant",
        email: "test@example.com",
        document_number: "123456789"
      )

      assert_equal 1, Occupant.count
      assert_equal "Test Occupant", Occupant.first.name
    end

    Apartment::Tenant.switch!("acme") do
      # acme should not see test occupant
      assert_equal 0, Occupant.count

      acme_occupant = Occupant.create!(
        name: "ACME Occupant",
        email: "acme@example.com",
        document_number: "987654321"
      )

      assert_equal 1, Occupant.count
    end

    # Verify test tenant's occupant still exists
    Apartment::Tenant.switch!("test") do
      assert_equal 1, Occupant.count
      assert_equal "Test Occupant", Occupant.first.name
    end
  end

  test "schemas are correctly configured" do
    configured_tenants = Apartment::TENANT_NAMES

    # Base tenants are always configured at startup
    assert configured_tenants.include?("test"), "test tenant should be configured"
    assert configured_tenants.include?("public"), "public tenant should be configured"

    # Verify we can switch to dynamically created tenants
    # even if not in the initial TENANT_NAMES constant
    Apartment::Tenant.switch!("acme") do
      assert_equal "acme", Apartment::Tenant.current
    end
  end

  test "tenant switching with block syntax" do
    Apartment::Tenant.switch("test") do
      Company.destroy_all
      Company.create!(
        name: "Block Test Company",
        nit: "111.111.111-1",
        address: "Block Address"
      )

      assert_equal 1, Company.count
    end

    # After block, should be back to public
    Apartment::Tenant.switch("acme") do
      Company.destroy_all

      assert_equal 0, Company.count, "acme should not have block test company"
    end
  end

  private

  def create_test_schema(tenant_name)
    return if tenant_name == "public"  # public schema already exists

    begin
      Apartment::Tenant.create(tenant_name)
    rescue Apartment::SchemaExists => e
      # Schema already exists, that's fine
    end
  end
end
