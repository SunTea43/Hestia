require "test_helper"

class PortalControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  fixtures :all

  setup do
    @user = users(:inquilino)
    @document = documents(:one)
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

  test "should get sign_document" do
    get portal_sign_document_url(@document)
    assert_response :success
  end
end
