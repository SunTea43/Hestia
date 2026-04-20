require "test_helper"

class DocumentVariableResolverTest < ActiveSupport::TestCase
  test "should return available variables" do
    variables = DocumentVariableResolver.available_variables

    assert_includes variables, :inquilino
    assert_includes variables, :propiedad
    assert_includes variables, :contrato
    assert_includes variables, :propietario
    assert_includes variables, :empresa
  end

  test "should return available categories" do
    categories = DocumentVariableResolver.available_categories

    assert_includes categories, :inquilino
    assert_includes categories, :propiedad
    assert_includes categories, :contrato
    assert_includes categories, :propietario
    assert_includes categories, :empresa
  end

  test "should have correct inquilino variables" do
    inquilino_vars = DocumentVariableResolver.available_variables[:inquilino]

    assert_includes inquilino_vars, :nombre_completo
    assert_includes inquilino_vars, :cedula
    assert_includes inquilino_vars, :email
    assert_includes inquilino_vars, :telefono
  end

  test "should have correct propiedad variables" do
    propiedad_vars = DocumentVariableResolver.available_variables[:propiedad]

    assert_includes propiedad_vars, :direccion
    assert_includes propiedad_vars, :area
    assert_includes propiedad_vars, :precio_renta
    assert_includes propiedad_vars, :tipo
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
    template = "Nombre: {{inquilino.nombre_completo}}"
    result = resolver.resolve(template)

    assert_match "{{inquilino.nombre_completo}}", result
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
    template = "Texto sin variables"
    result = resolver.resolve(template)

    assert_equal template, result
  end
end
