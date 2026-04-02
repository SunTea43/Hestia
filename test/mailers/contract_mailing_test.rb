require "test_helper"

class ContractMailingTest < ActionMailer::TestCase
  setup do
    @company = Company.create!(name: "Test Company")
  end

  test "contract creation sends confirmation email to tenant" do
    property = Property.create!(
      company: @company,
      address: "Avenida Principal 456",
      area: 75,
      property_type: "apartment",
      category: :rent,
      price: 1200
    )

    # Create tenant without triggering invitation email in this test block
    tenant = User.create!(
      name: "Carlos López",
      email: "carlos@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: :inquilino
    )

    # Clear the previous email from tenant creation
    ActionMailer::Base.deliveries.clear

    assert_emails 1 do
      contract = Contract.create!(
        property: property,
        tenant: tenant,
        start_date: Date.today,
        end_date: Date.today + 2.years,
        tenant_income: 1800
      )

      # Verify the contract confirmation email
      email = ActionMailer::Base.deliveries.last
      assert_equal [ "carlos@example.com" ], email.to
      assert_includes email.subject, "Nuevo contrato de arrendamiento"
      assert_includes email.html_part.body.to_s, "Avenida Principal 456"
    end
  end

  test "tenant invitation is sent when creating new inquilino user" do
    assert_emails 1 do
      User.create!(
        name: "Ana Martínez",
        email: "ana@example.com",
        password: "password123",
        password_confirmation: "password123",
        role: :inquilino
      )
    end

    email = ActionMailer::Base.deliveries.last
    assert_equal [ "ana@example.com" ], email.to
    assert_includes email.subject, "Bienvenida a Hestia"
  end

  test "no email is sent when creating non-inquilino user" do
    assert_emails 0 do
      User.create!(
        name: "Manager User",
        email: "manager@example.com",
        password: "password123",
        password_confirmation: "password123",
        role: :gestor
      )
    end
  end

  test "email contains correct property information" do
    property = Property.create!(
      company: @company,
      address: "Calle Reforma 789",
      area: 120,
      property_type: "house",
      category: :rent,
      price: 3000
    )

    tenant = User.create!(
      name: "Roberto Díaz",
      email: "roberto@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: :inquilino
    )

    # Clear the previous email from tenant creation
    ActionMailer::Base.deliveries.clear

    assert_emails 1 do
      contract = Contract.create!(
        property: property,
        tenant: tenant,
        start_date: "2026-04-15",
        end_date: "2028-04-15",
        tenant_income: 2500
      )
    end

    # Get the contract confirmation email
    email = ActionMailer::Base.deliveries.last
    body = email.html_part.body.to_s

    assert_includes body, "Calle Reforma 789"
    assert_includes body, "house"
    assert_includes body, "120"  # area in m²
    assert_not_empty email.text_part.body.to_s
  end

  test "full workflow: create tenant and contract sends both emails" do
    property = Property.create!(
      company: @company,
      address: "Plaza Mayor 100",
      area: 95,
      property_type: "apartment",
      category: :rent,
      price: 2000
    )

    assert_emails 2 do
      # Create tenant (sends invitation email)
      tenant = User.create!(
        name: "Diego Sánchez",
        email: "diego@example.com",
        password: "password123",
        password_confirmation: "password123",
        role: :inquilino
      )

      # Create contract (sends contract confirmation email)
      Contract.create!(
        property: property,
        tenant: tenant,
        start_date: Date.today,
        end_date: Date.today + 1.year,
        tenant_income: 1500
      )
    end

    # Verify both emails
    emails = ActionMailer::Base.deliveries.last(2)

    # First email: invitation
    invitation_email = emails[0]
    assert_equal [ "diego@example.com" ], invitation_email.to
    assert_includes invitation_email.subject, "Bienvenida a Hestia"

    # Second email: contract confirmation
    contract_email = emails[1]
    assert_equal [ "diego@example.com" ], contract_email.to
    assert_includes contract_email.subject, "Nuevo contrato de arrendamiento"
    assert_includes contract_email.html_part.body.to_s, "Plaza Mayor 100"
  end
end
