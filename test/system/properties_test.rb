require "application_system_test_case"

class PropertiesTest < ApplicationSystemTestCase
  setup do
    @user = users(:gestor)
    @company = companies(:hestia)
    sign_in @user
  end

  test "visiting the index" do
    visit properties_url
    assert_selector "h1", text: "Inmuebles"
  end

  test "should create property" do
    visit properties_url
    click_on "Nuevo Inmueble"

    select @company.name, from: "Empresa Gestora"
    select "Rent", from: "Tipo de Oferta"
    fill_in "Dirección Completa", with: "Carrera 7 # 100-20"
    select "Apartamento", from: "Tipo de Propiedad"
    fill_in "Área (m²)", with: 75.5
    fill_in "Valor (Arriendo o Venta)", with: 2500000
    check "elevatorSwitch"
    check "adminFeeSwitch"
    fill_in "Zonas Comunes", with: "Piscina, Gimnasio"
    fill_in "Descripción General (Larga)", with: "Un apartamento muy bonito y bien ubicado."

    click_on "Registrar Inmueble"

    assert_text "Inmueble creado exitosamente"
    assert_text "Carrera 7 # 100-20"
  end
end
