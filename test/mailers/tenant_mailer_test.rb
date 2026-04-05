require "test_helper"

class TenantMailerTest < ActionMailer::TestCase
  test "invitation_email sends to correct address" do
    occupant = Occupant.create!(
      name: "Juan Pérez",
      email: "juan@example.com",
      document_number: "11111111"
    )

    email = TenantMailer.invitation_email(occupant)

    assert_equal [ "juan@example.com" ], email.to
    assert_equal "Bienvenida a Hestia - Configurar tu cuenta", email.subject

    # Check HTML part
    assert_includes email.html_part.body.to_s, "Bienvenido a Hestia"
    assert_includes email.html_part.body.to_s, "Juan Pérez"

    # Check text part
    assert_includes email.text_part.body.to_s, "Bienvenido a Hestia"
  end

  test "document_confirmation_email sends to tenant with property details" do
    company = Company.create!(name: "Test Company")
    property = Property.create!(
      company: company,
      address: "Calle Principal 123",
      area: 100,
      property_type: "apartment",
      category: :rent,
      price: 1500
    )
    occupant = Occupant.create!(
      name: "María García",
      email: "maria@example.com",
      document_number: "22222222"
    )
    doc_type = DocumentType.create!(name: "Contrato", icon: "file-text", color: "#000000")
    document = Document.create!(
      document_type: doc_type,
      property: property,
      occupant: occupant,
      start_date: Date.today,
      end_date: Date.today + 2.years,
      tenant_income: 2000
    )

    email = TenantMailer.document_confirmation_email(occupant, property, document)

    assert_equal [ "maria@example.com" ], email.to
    assert_includes email.subject, "documento"

    # Check HTML part
    assert_includes email.html_part.body.to_s, "Calle Principal 123"
    assert_includes email.html_part.body.to_s, "María García"

    # Check text part
    assert_includes email.text_part.body.to_s, "Calle Principal 123"
  end

  test "document confirmation email is sent when creating document" do
    company = Company.create!(name: "Test Company")
    property = Property.create!(
      company: company,
      address: "Avenida Reforma 456",
      area: 80,
      property_type: "house",
      category: :rent,
      price: 2500
    )
    occupant = Occupant.create!(
      name: "Ana Martínez",
      email: "ana@example.com",
      document_number: "33333333"
    )
    doc_type = DocumentType.create!(name: "Contrato", icon: "file-text", color: "#000000")

    assert_emails 1 do
      Document.create!(
        document_type: doc_type,
        property: property,
        occupant: occupant,
        start_date: Date.today,
        end_date: Date.today + 1.year,
        tenant_income: 3000
      )
    end
  end
end
