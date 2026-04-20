require "test_helper"

class DocumentFormTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @company = Company.create!(name: "Test Company")
    @gestor = User.create!(
      name: "Test Gestor",
      email: "gestor-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: :gestor
    )
    CompanyManager.create!(user: @gestor, company: @company)

    @property = Property.create!(
      company: @company,
      address: "Calle Test 123",
      area: 100,
      property_type: "apartment",
      category: :rent,
      price: 1500
    )

    @occupant = Occupant.create!(
      name: "Test Occupant",
      email: "occupant-#{SecureRandom.hex(4)}@example.com",
      document_number: "#{SecureRandom.hex(4)}"
    )

    @doc_type = DocumentType.create!(name: "Contrato #{SecureRandom.hex(4)}", icon: "file-text", color: "#000000", template_type: "attachment")
  end

  test "link_to_vincular_inquilino should navigate to new document form" do
    sign_in @gestor
    get property_path(@property)

    # Check that the link to create a document is present
    assert_select "a[href=?]", new_document_path(property_id: @property.id), text: "Vincular Inquilino"
  end

  test "new document form should pre-select property when property_id is provided" do
    sign_in @gestor
    get new_document_path(property_id: @property.id)

    # Check that property is pre-selected in the form
    assert_select "select[name='document[property_id]'] option[value='#{@property.id}'][selected]"
  end

  test "tenant creation and linking flow" do
    sign_in @gestor

    # 1. Visit property show page
    get property_path(@property)
    assert_response :success
    assert_select "a[href=?]", new_document_path(property_id: @property.id)

    # 2. Click on vincular inquilino
    get new_document_path(property_id: @property.id)
    assert_response :success
    assert_select "select[name='document[property_id]'] option[value='#{@property.id}'][selected]"

    # 3. Fill form and create document (1 email for document confirmation)
    assert_emails 1 do
      post documents_path, params: {
        document: {
          document_type_id: @doc_type.id,
          property_id: @property.id,
          occupant_id: @occupant.id,
          start_date: Date.today,
          end_date: Date.today + 1.year,
          status: "published",
          name: "Test Document"
        }
      }
    end

    # 4. Verify document was created
    assert_response :redirect
    document = Document.last
    assert_equal @property.id, document.property_id
    assert_equal @occupant.id, document.occupant_id
  end
end
