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

  test "should create document with new fields" do
    assert_difference "Document.count", 1 do
      post documents_url, params: {
        document: {
          document_type_id: @document.document_type_id,
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
          document_type_id: @document.document_type_id,
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
          document_type_id: @document.document_type_id,
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
