require "test_helper"

class DocumentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  fixtures :all

  setup do
    @user = users(:gestor)
    @document = documents(:one)
    sign_in @user
  end

  test "should get index" do
    get documents_url
    assert_response :success
  end

  test "should get new" do
    get new_document_url
    assert_response :success
  end

  test "should get show" do
    get document_url(@document)
    assert_response :success
  end
end
