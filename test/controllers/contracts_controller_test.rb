require "test_helper"

class ContractsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:gestor)
    @contract = contracts(:one)
    sign_in @user
  end

  test "should get index" do
    get contracts_url
    assert_response :success
  end

  test "should get new" do
    get new_contract_url
    assert_response :success
  end

  test "should get show" do
    get contract_url(@contract)
    assert_response :success
  end
end
