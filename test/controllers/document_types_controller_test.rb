require "test_helper"

class DocumentTypesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  fixtures :all

  setup do
    @gestor = users(:gestor)
    @document_type = document_types(:one)
    sign_in @gestor
  end

  test "should get index" do
    get document_types_url
    assert_response :success
  end

  test "should get new" do
    get new_document_type_url
    assert_response :success
  end

  test "should create document_type" do
    assert_difference("DocumentType.count") do
      post document_types_url, params: { document_type: { color: @document_type.color, description: @document_type.description, icon: @document_type.icon, name: @document_type.name } }
    end

    assert_redirected_to document_type_url(DocumentType.last)
  end

  test "should show document_type" do
    get document_type_url(@document_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_document_type_url(@document_type)
    assert_response :success
  end

  test "should update document_type" do
    patch document_type_url(@document_type), params: { document_type: { color: @document_type.color, description: @document_type.description, icon: @document_type.icon, name: @document_type.name } }
    assert_redirected_to document_type_url(@document_type)
  end

  test "should destroy document_type" do
    new_type = DocumentType.create!(name: "ToDelete", icon: "trash", color: "#000000")
    assert_difference("DocumentType.count", -1) do
      delete document_type_url(new_type)
    end

    assert_redirected_to document_types_url
  end
end
