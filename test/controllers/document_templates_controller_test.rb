require "test_helper"

class DocumentTemplatesControllerTest < ActionDispatch::IntegrationTest
  fixtures :document_templates, :users

  def setup
    @template = document_templates(:one)
    sign_in users(:admin)
  end

  test "should get index" do
    get document_templates_url
    assert_response :success
  end

  test "should get new" do
    get new_document_template_url
    assert_response :success
  end

  test "should create document_template" do
    assert_difference "DocumentTemplate.count", 1 do
      post document_templates_url, params: {
        document_template: {
          name: "New Template",
          description: "Test description",
          body: "<p>Test body</p>"
        }
      }
    end

    assert_redirected_to document_template_path(DocumentTemplate.last)
  end

  test "should show document_template" do
    get document_template_url(@template)
    assert_response :success
  end

  test "should get edit" do
    get edit_document_template_url(@template)
    assert_response :success
  end

  test "should update document_template" do
    patch document_template_url(@template), params: {
      document_template: {
        name: "Updated Name"
      }
    }

    assert_redirected_to document_template_path(@template)
    @template.reload
    assert_equal "Updated Name", @template.name
  end

  test "should destroy document_template" do
    assert_difference "DocumentTemplate.count", -1 do
      delete document_template_url(@template)
    end

    assert_redirected_to document_templates_url
  end
end
