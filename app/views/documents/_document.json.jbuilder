json.extract! document, :id, :property_id, :occupant_id, :name, :body, :status, :start_date, :end_date, :metadata, :created_at, :updated_at
json.url document_url(document, format: :json)
