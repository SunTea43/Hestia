class HomeController < ApplicationController
  def index
    if user_signed_in?
      case current_user.role
      when "admin", "gestor"
        @companies = current_user.admin? ? Company.all : current_user.companies
        company_ids = @companies.pluck(:id)
        if current_user.admin? || current_user.gestor?
          @properties_count = policy_scope(Property).count
          @active_documents = Document.joins(:property).where(properties: { company_id: company_ids }).count
          @pending_charges = Charge.joins(document: :property).where(properties: { company_id: company_ids }, status: :pending).sum(:amount)
        end
      when "inquilino"
        @occupant = Occupant.find_by(email: current_user.email)
        @documents = @occupant&.documents&.includes(:property) || []
        @charges = Charge.where(document: @documents).order(due_date: :desc).limit(5)
      end
    end
  end
end
