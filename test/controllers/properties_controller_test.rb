require "test_helper"

class PropertiesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:gestor)
    @property = properties(:one) # I'll need to define this in fixtures
    sign_in @user
  end

  test "should get index" do
    get properties_url
    assert_response :success
  end

  test "should get show" do
    get property_url(@property)
    assert_response :success
  end

  test "should get new" do
    get new_property_url
    assert_response :success
  end

  test "should get edit" do
    get edit_property_url(@property)
    assert_response :success
  end

  test "should destroy property" do
    assert_difference("Property.count", -1) do
      delete property_url(@property)
    end

    assert_redirected_to properties_url
  end
end
