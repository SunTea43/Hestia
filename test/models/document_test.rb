require "test_helper"

class DocumentTest < ActiveSupport::TestCase
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
      document_type: @document.document_type,
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
      document_type: @document.document_type,
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
      document_type: @document.document_type,
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
end
