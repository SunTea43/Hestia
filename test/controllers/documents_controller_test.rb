require "test_helper"

class DocumentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  fixtures :all

  setup do
    @user = users(:gestor)
    @document = documents(:one)
    @template = document_templates(:one)
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

  test "should show rendered template content" do
    template = DocumentTemplate.create!(
      name: "Contrato visible",
      body: "Contrato de {{propietario.nombre_completo}} con {{inquilino.nombre_completo}}",
      document_type: DocumentType.create!(name: "HTML visible", template_type: "html")
    )
    @document.update!(document_template: template, body: nil)

    get document_url(@document)

    assert_response :success
    assert_match "Contrato de Inmobiliaria Hestia con Maria Inquilino", response.body
  end

  test "should regenerate pdf for html template documents" do
    template = DocumentTemplate.create!(
      name: "Contrato PDF",
      body: "Contrato de {{propietario.nombre_completo}} con {{inquilino.nombre_completo}}",
      document_type: DocumentType.create!(name: "HTML PDF", template_type: "html")
    )
    @document.update!(document_template: template, body: nil)

    pdf_binary = "%PDF-1.4 test"
    call_arguments = nil
    pdf_stub = Object.new
    pdf_stub.define_singleton_method(:pdf_from_string) do |html, options|
      call_arguments = [ html, options ]
      pdf_binary
    end

    WickedPdf.singleton_class.alias_method :__original_new_for_test__, :new
    WickedPdf.define_singleton_method(:new) { |*_args| pdf_stub }

    begin
      post regenerate_pdf_document_url(@document)
    ensure
      WickedPdf.singleton_class.alias_method :new, :__original_new_for_test__
      WickedPdf.singleton_class.remove_method :__original_new_for_test__
    end

    assert_redirected_to document_url(@document)
    assert_includes call_arguments.first, "Contrato de Inmobiliaria Hestia con Maria Inquilino"
    assert_equal "Pagina [page] de [topage]", call_arguments.last.dig(:footer, :right)
    assert_equal "Contrato PDF", call_arguments.last.dig(:header, :center)

    @document.reload
    assert @document.file.attached?
    assert_equal "contrato-pdf.pdf", @document.file.filename.to_s
    assert_equal "generated_pdf", @document.attachment_origin
  end

  test "should download existing generated pdf" do
    @document.file.attach(
      io: StringIO.new("%PDF-1.4 stored"),
      filename: "documento.pdf",
      content_type: "application/pdf"
    )
    @document.update!(metadata: (@document.metadata || {}).merge("attachment_origin" => "generated_pdf"))

    get download_pdf_document_url(@document)

    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert_match "%PDF-1.4 stored", response.body
  end

  test "should redirect pdf download when document has no generated pdf" do
    get download_pdf_document_url(@document)

    assert_redirected_to document_url(@document)
  end

  test "should mark uploaded file as manual attachment" do
    patch document_url(@document), params: {
      document: {
        file: fixture_file_upload("test.txt", "text/plain")
      }
    }

    assert_redirected_to document_path(@document)
    @document.reload
    assert_equal "manual_upload", @document.attachment_origin
    assert @document.manual_attachment_at.present?
  end

  test "should create document with new fields" do
    assert_difference "Document.count", 1 do
      post documents_url, params: {
        document: {
          property_id: @document.property_id,
          occupant_id: @document.occupant_id,
          name: "New Document",
          start_date: Date.today,
          document_template_id: @template.id,
          parent_id: nil
        }
      }
    end

    assert_redirected_to document_path(Document.last)
  end

  test "should create document with file" do
    assert_difference "Document.count", 1 do
      post documents_url, params: {
        document: {
          property_id: @document.property_id,
          occupant_id: @document.occupant_id,
          name: "Document with file",
          start_date: Date.today,
          file: fixture_file_upload("test.txt", "text/plain")
        }
      }
    end

    assert_redirected_to document_path(Document.last)
    assert Document.last.file.attached?
  end

  test "should create document with parent" do
    assert_difference "Document.count", 1 do
      post documents_url, params: {
        document: {
          property_id: @document.property_id,
          occupant_id: @document.occupant_id,
          name: "Child Document",
          start_date: Date.today,
          parent_id: @document.id
        }
      }
    end

    assert_redirected_to document_path(Document.last)
    assert_equal @document, Document.last.parent
  end

  test "should update document with new fields" do
    patch document_url(@document), params: {
      document: {
        name: "Updated Name",
        document_template_id: @template.id
      }
    }

    assert_redirected_to document_path(@document)
    @document.reload
    assert_equal "Updated Name", @document.name
    assert_equal @template.id, @document.document_template_id
  end

  test "should update document with file" do
    patch document_url(@document), params: {
      document: {
        file: fixture_file_upload("test.txt", "text/plain")
      }
    }

    assert_redirected_to document_path(@document)
    @document.reload
    assert @document.file.attached?
  end
end
