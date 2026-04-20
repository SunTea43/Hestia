require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  fixtures :documents, :document_templates, :properties, :occupants, :companies

  def setup
    @document = documents(:one)
  end

  test "should belong to document_template" do
    assert_respond_to @document, :document_template
  end

  test "should have many children" do
    assert_respond_to @document, :children
  end

  test "should belong to parent" do
    assert_respond_to @document, :parent
  end

  test "should have one attached file" do
    assert_respond_to @document, :file
  end

  test "should be valid without document_template" do
    @document.document_template = nil
    assert @document.valid?
  end

  test "should be valid without parent" do
    @document.parent = nil
    assert @document.valid?
  end

  test "should have hierarchical structure" do
    parent = documents(:one)
    child = Document.create!(
      property: @document.property,
      occupant: @document.occupant,
      start_date: Date.today,
      parent: parent
    )

    assert_equal parent, child.parent
    assert_includes parent.children, child
  end

  test "should destroy children when destroyed" do
    parent = documents(:one)
    Document.create!(
      property: @document.property,
      occupant: @document.occupant,
      start_date: Date.today,
      parent: parent
    )

    assert_difference "Document.count", -2 do
      parent.destroy
    end
  end

  test "scope root should return documents without parent" do
    parent = documents(:one)
    child = Document.create!(
      property: @document.property,
      occupant: @document.occupant,
      start_date: Date.today,
      parent: parent
    )

    root_documents = Document.root
    assert_includes root_documents, parent
    assert_not_includes root_documents, child
  end

  test "should attach file" do
    @document.file.attach(
      io: StringIO.new("test content"),
      filename: "test.txt",
      content_type: "text/plain"
    )

    assert @document.file.attached?
    assert_equal "test.txt", @document.file.filename.to_s
  end

  test "rendered_body resolves template variables from template source" do
    template = DocumentTemplate.create!(
      name: "Contrato base",
      body: "Contrato de {{propietario.nombre_completo}} y {{inquilino.nombre_completo}}",
      document_type: DocumentType.create!(name: "Contrato HTML", template_type: "html")
    )

    @document.update!(document_template: template, body: nil)

    assert_equal "Contrato de Inmobiliaria Hestia y Maria Inquilino", @document.rendered_body
    assert_nil @document.body
  end

  test "rendered_body falls back to document body when there is no html template" do
    @document.body = "Texto libre para {{inquilino.nombre_completo}}"

    assert_equal "Texto libre para Maria Inquilino", @document.rendered_body
  end

  test "attach_generated_pdf stores a pdf attachment with the document filename" do
    @document.name = "Contrato Final"

    @document.attach_generated_pdf!("%PDF-1.4")

    assert @document.file.attached?
    assert_equal "application/pdf", @document.file.content_type
    assert_equal "contrato-final.pdf", @document.file.filename.to_s
    assert_equal "generated_pdf", @document.attachment_origin
    assert @document.generated_pdf_at.present?
  end

  test "mark_manual_attachment marks uploaded files as manual" do
    @document.file.attach(
      io: StringIO.new("manual"),
      filename: "manual.pdf",
      content_type: "application/pdf"
    )

    @document.mark_manual_attachment!

    assert_equal "manual_upload", @document.attachment_origin
    assert @document.manual_attachment_at.present?
    assert @document.manual_attachment?
  end
end
