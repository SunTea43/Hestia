Rails.application.routes.draw do
  resources :documents
  resources :document_types
  root "home#index"

  resources :properties
  resources :tenants
  resources :contracts

  scope "/portal" do
    get "dashboard", to: "portal#dashboard", as: :portal_dashboard
    get "documents", to: "portal#documents", as: :portal_documents
    get "payments", to: "portal#payments", as: :portal_payments
    get "support_requests", to: "portal#support_requests", as: :portal_support_requests
    get "sign_document/:id", to: "portal#sign_document", as: :portal_sign_document
  end

  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check
end
