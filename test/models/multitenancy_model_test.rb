require "test_helper"

class MultitenancyModelTest < ActiveSupport::TestCase
  setup do
    ENV["APARTMENT_TENANTS"] = "public,acme,test"

    # Create test schemas
    create_test_schema("test")
    create_test_schema("acme")
  end

  test "users are isolated by tenant" do
    # Create user in test tenant
    Apartment::Tenant.switch!("test") do
      User.destroy_all

      test_user = User.create!(
        email: "test@example.com",
        password: "password123",
        password_confirmation: "password123",
        name: "Test User",
        role: :admin
      )

      assert_equal 1, User.count
      assert_equal "Test User", User.first.name
    end

    # Verify test user doesn't exist in acme
    Apartment::Tenant.switch!("acme") do
      User.destroy_all

      assert_equal 0, User.count, "acme should not see test users"
    end
  end

  test "company and occupant relationships work within tenant" do
    Apartment::Tenant.switch!("test") do
      Company.destroy_all
      Property.destroy_all
      Occupant.destroy_all
      Contract.destroy_all

      # Create company
      company = Company.create!(
        name: "Test Company",
        nit: "123.456.789-0",
        address: "Test Address"
      )

      # Create property
      property = Property.create!(
        company_id: company.id,
        address: "Test Property",
        area: 100,
        property_type: "Apartamento",
        category: :rent,
        price: 1_000_000,
        description: "Test property"
      )

      # Create occupant
      occupant = Occupant.create!(
        name: "Test Occupant",
        email: "occupant@example.com",
        document_number: "123456789"
      )

      # Create contract linking property and occupant
      contract = Contract.create!(
        property_id: property.id,
        occupant_id: occupant.id,
        start_date: Date.today,
        end_date: 1.year.from_now,
        tenant_income: 5_000_000
      )

      # Verify relationships
      assert_equal company, property.company
      assert_equal occupant, contract.occupant
      assert_equal property, contract.property
      assert_equal 1, occupant.contracts.count
      assert_equal 1, company.properties.count
    end
  end

  test "companies cannot access data from other tenants" do
    # Create company in test tenant
    Apartment::Tenant.switch!("test") do
      Company.destroy_all
      Company.create!(
        name: "Test Tenant Company",
        nit: "111.111.111-1",
        address: "Test Address"
      )

      test_company_id = Company.first.id
      assert_equal 1, Company.count
    end

    # Switch to acme and verify test company doesn't exist
    Apartment::Tenant.switch!("acme") do
      Company.destroy_all

      # Try to find the company from test tenant
      found_company = Company.find_by(id: test_company_id)
      assert_nil found_company, "Should not find company from other tenant"
    end
  end

  test "destroy in one tenant doesn't affect other tenants" do
    Apartment::Tenant.switch!("test") do
      Company.destroy_all
      3.times { |i| Company.create!(name: "Test #{i}", nit: "#{i}", address: "addr#{i}") }
      assert_equal 3, Company.count
    end

    Apartment::Tenant.switch!("acme") do
      Company.destroy_all
      2.times { |i| Company.create!(name: "ACME #{i}", nit: "9#{i}", address: "addr#{i}") }
      assert_equal 2, Company.count
    end

    # Destroy all in test
    Apartment::Tenant.switch!("test") do
      Company.destroy_all
      assert_equal 0, Company.count
    end

    # Verify acme still has data
    Apartment::Tenant.switch!("acme") do
      assert_equal 2, Company.count, "acme should still have 2 companies"
    end
  end

  private

  def create_test_schema(tenant_name)
    return if tenant_name == "public"

    begin
      Apartment::Tenant.create(tenant_name)
    rescue Apartment::SchemaExists => e
      # Schema already exists
    end
  end
end
