class RemoveDocumentTypeFromDocuments < ActiveRecord::Migration[8.1]
  def change
    remove_reference :documents, :document_type, foreign_key: true
  end
end
