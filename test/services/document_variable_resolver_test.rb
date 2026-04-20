require "test_helper"

class DocumentVariableResolverTest < ActiveSupport::TestCase
  test "should return available variables" do
    variables = DocumentVariableResolver.available_variables

    assert_includes variables, :tenant
    assert_includes variables, :property
    assert_includes variables, :contract
    assert_includes variables, :owner
    assert_includes variables, :company
  end

  test "should return available categories" do
    categories = DocumentVariableResolver.available_categories

    assert_includes categories, :tenant
    assert_includes categories, :property
    assert_includes categories, :contract
    assert_includes categories, :owner
    assert_includes categories, :company
  end

  test "should have correct tenant variables" do
    tenant_vars = DocumentVariableResolver.available_variables[:tenant]

    assert_includes tenant_vars, :full_name
    assert_includes tenant_vars, :document_number
    assert_includes tenant_vars, :email
    assert_includes tenant_vars, :phone
  end

  test "should have correct property variables" do
    property_vars = DocumentVariableResolver.available_variables[:property]

    assert_includes property_vars, :address
    assert_includes property_vars, :area
    assert_includes property_vars, :rent_price
    assert_includes property_vars, :type
  end

  test "should leave unresolved variables when data is missing" do
    empty_context = DocumentContext.new(
      property: nil,
      occupant: nil,
      contract: nil,
      company: nil,
      document: nil
    )

    resolver = DocumentVariableResolver.new(empty_context)
    template = "Name: {{tenant.full_name}}"
    result = resolver.resolve(template)

    assert_match "{{tenant.full_name}}", result
  end

  test "should return original template when no variables present" do
    context = DocumentContext.new(
      property: nil,
      occupant: nil,
      contract: nil,
      company: nil,
      document: nil
    )

    resolver = DocumentVariableResolver.new(context)
    template = "Text without variables"
    result = resolver.resolve(template)

    assert_equal template, result
  end
end
