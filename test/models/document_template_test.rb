require "test_helper"

class DocumentTemplateTest < ActiveSupport::TestCase
  fixtures :companies

  def setup
    @html_type = DocumentType.create!(name: "HTML Type", template_type: "html")
    @attachment_type = DocumentType.create!(name: "Attachment Type", template_type: "attachment")

    @template = DocumentTemplate.new(
      name: "Contrato de Arrendamiento",
      description: "Plantilla para contratos de arrendamiento",
      body: "<h1>Contrato de Arrendamiento</h1><p>Contenido del contrato...</p>",
      document_type: @html_type
    )
  end

  test "should be valid with valid attributes" do
    assert @template.valid?
  end

  test "should not be valid without name" do
    @template.name = nil
    assert_not @template.valid?
    assert_includes @template.errors[:name], "can't be blank"
  end

  test "should not be valid without body for html template" do
    @template.body = nil
    assert_not @template.valid?
    assert_includes @template.errors[:body], "can't be blank"
  end

  test "should be valid without body for attachment template" do
    @template.document_type = @attachment_type
    @template.body = nil
    assert @template.valid?
  end

  test "should be valid without description" do
    @template.description = nil
    assert @template.valid?
  end

  test "should be valid without parent" do
    assert @template.valid?
    assert_nil @template.parent
  end

  test "should be valid without document_type" do
    @template.document_type = nil
    assert @template.valid?
  end

  test "should identify html templates" do
    @template.document_type = @html_type
    assert @template.html_template?
    assert_not @template.attachment_template?
  end

  test "should identify attachment templates" do
    @template.document_type = @attachment_type
    assert @template.attachment_template?
    assert_not @template.html_template?
  end

  test "should return false for html_template? when no document_type" do
    @template.document_type = nil
    assert_not @template.html_template?
  end

  test "should return false for attachment_template? when no document_type" do
    @template.document_type = nil
    assert_not @template.attachment_template?
  end

  test "should have many children" do
    @template.save!
    child = DocumentTemplate.create!(
      name: "Sub-plantilla",
      description: "Plantilla hija",
      body: "<p>Contenido</p>",
      parent: @template
    )

    assert_includes @template.children, child
    assert_equal @template, child.parent
  end

  test "should have many documents" do
    @template.save!
    property = Property.create!(
      company: companies(:acme_residential),
      address: "Calle Test 123",
      area: 100.0,
      property_type: "Apartamento",
      category: :rent,
      price: 1_500_000
    )
    occupant = Occupant.create!(
      name: "Test Occupant",
      email: "test@example.com",
      phone: "+57 300 123 4567",
      document_number: "1234567890"
    )

    document = Document.create!(
      property: property,
      occupant: occupant,
      start_date: Date.today,
      document_template: @template
    )

    assert_includes @template.documents, document
  end

  test "should destroy children when destroyed" do
    @template.save!
    DocumentTemplate.create!(
      name: "Sub-plantilla",
      description: "Plantilla hija",
      body: "<p>Contenido</p>",
      parent: @template
    )

    assert_difference "DocumentTemplate.count", -2 do
      @template.destroy
    end
  end

  test "should nullify documents when destroyed" do
    @template.save!
    property = Property.create!(
      company: companies(:acme_residential),
      address: "Calle Test 123",
      area: 100.0,
      property_type: "Apartamento",
      category: :rent,
      price: 1_500_000
    )
    occupant = Occupant.create!(
      name: "Test Occupant",
      email: "test@example.com",
      phone: "+57 300 123 4567",
      document_number: "1234567890"
    )

    document = Document.create!(
      property: property,
      occupant: occupant,
      start_date: Date.today,
      document_template: @template
    )

    assert_difference "@template.documents.count", -1 do
      @template.destroy
    end

    document.reload
    assert_nil document.document_template
  end

  test "scope root should return templates without parent" do
    @template.save!
    child = DocumentTemplate.create!(
      name: "Sub-plantilla",
      description: "Plantilla hija",
      body: "<p>Contenido</p>",
      parent: @template
    )

    root_templates = DocumentTemplate.root
    assert_includes root_templates, @template
    assert_not_includes root_templates, child
  end

  test "should include document_type in json serialization" do
    @template.save!
    json = @template.as_json

    assert json["document_type"]
    assert_equal @html_type.id, json["document_type"]["id"]
  end

  test "should render body for document using its context" do
    @template.body = "Contrato de {{propietario.nombre_completo}} con {{inquilino.nombre_completo}}"
    @template.save!

    property = Property.create!(
      company: companies(:acme_residential),
      address: "Calle Test 123",
      area: 100.0,
      property_type: "Apartamento",
      category: :rent,
      price: 1_500_000
    )
    occupant = Occupant.create!(
      name: "Pepito Perez",
      email: "test@example.com",
      phone: "+57 300 123 4567",
      document_number: "1234567890"
    )
    document = Document.create!(
      property: property,
      occupant: occupant,
      start_date: Date.today,
      document_template: @template
    )

    assert_equal "Contrato de ACME Residencial con Pepito Perez", @template.rendered_body_for(document)
  end
end
