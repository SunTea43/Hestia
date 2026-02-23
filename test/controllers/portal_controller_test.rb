require "test_helper"

class PortalControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:inquilino)
    @contract = contracts(:one)
    sign_in @user
  end

  test "should get dashboard" do
    get portal_dashboard_url
    assert_response :success
  end

  test "should get documents" do
    get portal_documents_url
    assert_response :success
  end

  test "should get payments" do
    get portal_payments_url
    assert_response :success
  end

  test "should get support_requests" do
    get portal_support_requests_url
    assert_response :success
  end

  test "should get signup_contract" do
    get portal_signup_contract_url(@contract)
    assert_response :success
  end
end
