class HomeController < ApplicationController
  def index
    if user_signed_in?
      case current_user.role
      when "admin", "gestor"
        @companies = current_user.admin? ? Company.all : current_user.companies
        company_ids = @companies.pluck(:id)
        @properties_count = Property.where(company_id: company_ids).count
        @active_contracts = Contract.joins(:property).where(properties: { company_id: company_ids }).count
        @pending_charges = Charge.joins(contract: :property).where(properties: { company_id: company_ids }, status: :pending).sum(:amount)
      when "inquilino"
        @contracts = current_user.contracts.includes(:property)
        @charges = Charge.where(contract: @contracts).order(due_date: :desc).limit(5)
      end
    end
  end
end
