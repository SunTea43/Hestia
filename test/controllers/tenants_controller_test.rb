require "test_helper"

class TenantsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:gestor)
    @tenant = users(:inquilino)
    sign_in @user
  end

  test "should get index" do
    get tenants_url
    assert_response :success
  end

  test "should get new" do
    get new_tenant_url
    assert_response :success
  end

  test "should create tenant" do
    assert_difference("User.count") do
      post tenants_url, params: { user: { name: "Nuevo Inquilino", email: "nuevo@example.com", phone: "123456", document_number: "99999" } }
    end

    assert_redirected_to tenants_path
  end
end
