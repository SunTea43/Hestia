require "test_helper"

class ContractFormTest < ActionDispatch::IntegrationTest
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

    @tenant = User.create!(
      name: "Test Tenant",
      email: "tenant-#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: :inquilino
    )
  end

  test "link_to_vincular_inquilino should navigate to new contract form" do
    sign_in @gestor
    get property_path(@property)
    
    # Check that the link to create a contract is present
    assert_select "a[href=?]", new_contract_path(property_id: @property.id), text: "Vincular Inquilino"
  end

  test "new contract form should pre-select property when property_id is provided" do
    sign_in @gestor
    get new_contract_path(property_id: @property.id)
    
    # Check that property is pre-selected in the form
    assert_select "select[name='contract[property_id]'] option[value='#{@property.id}'][selected]"
  end

  test "tenant creation and linking flow" do
    sign_in @gestor
    
    # 1. Visit property show page
    get property_path(@property)
    assert_response :success
    assert_select "a[href=?]", new_contract_path(property_id: @property.id)
    
    # 2. Click on vincular inquilino
    get new_contract_path(property_id: @property.id)
    assert_response :success
    assert_select "select[name='contract[property_id]'] option[value='#{@property.id}'][selected]"
    
    # 3. Fill form and create contract (1 email for contract confirmation)
    assert_emails 1 do
      post contracts_path, params: {
        contract: {
          property_id: @property.id,
          tenant_id: @tenant.id,
          start_date: Date.today,
          end_date: Date.today + 1.year,
          tenant_income: 2000
        }
      }
    end
    
    # 4. Verify contract was created
    assert_response :redirect
    contract = Contract.last
    assert_equal @property.id, contract.property_id
    assert_equal @tenant.id, contract.tenant_id
  end
end
