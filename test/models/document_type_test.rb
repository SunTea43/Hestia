require "test_helper"

class DocumentTypeTest < ActiveSupport::TestCase
  setup do
    @document_type = DocumentType.new(
      name: "Contrato de Arrendamiento Test",
      description: "Plantilla para contratos",
      template_type: "html"
    )
  end

  test "should be valid with valid attributes" do
    assert @document_type.valid?
  end

  test "should require name" do
    @document_type.name = nil
    assert_not @document_type.valid?
    assert_includes @document_type.errors[:name], "can't be blank"
  end

  test "should require template_type" do
    @document_type.template_type = nil
    assert_not @document_type.valid?
    assert_includes @document_type.errors[:template_type], "can't be blank"
  end

  test "should validate template_type inclusion" do
    @document_type.template_type = "invalid_type"
    assert_not @document_type.valid?
    assert_includes @document_type.errors[:template_type], "is not included in the list"
  end

  test "should accept html as template_type" do
    @document_type.template_type = "html"
    assert @document_type.valid?
  end

  test "should accept attachment as template_type" do
    @document_type.template_type = "attachment"
    assert @document_type.valid?
  end

  test "should require unique name" do
    @document_type.save
    duplicate = DocumentType.new(
      name: @document_type.name,
      template_type: "html"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "should identify html templates" do
    @document_type.template_type = "html"
    assert @document_type.html_template?
    assert_not @document_type.attachment_template?
  end

  test "should identify attachment templates" do
    @document_type.template_type = "attachment"
    assert @document_type.attachment_template?
    assert_not @document_type.html_template?
  end

  test "should have many document_templates" do
    assert_respond_to @document_type, :document_templates
  end

  test "should have html_templates scope" do
    html_type = DocumentType.create!(name: "HTML Template", template_type: "html")
    attachment_type = DocumentType.create!(name: "Attachment Template", template_type: "attachment")

    html_templates = DocumentType.html_templates
    attachment_templates = DocumentType.attachment_templates

    assert_includes html_templates, html_type
    assert_not_includes html_templates, attachment_type
    assert_includes attachment_templates, attachment_type
    assert_not_includes attachment_templates, html_type
  end
end
