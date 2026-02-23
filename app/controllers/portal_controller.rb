class PortalController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_tenant

  def dashboard
    @contracts = current_user.contracts.includes(:property)
    @recent_charges = Charge.joins(:contract).where(contracts: { tenant_id: current_user.id }).order(due_date: :desc).limit(5)
  end

  def documents
    @contracts = current_user.contracts.includes(:property)
    # In a real app, we would have a Documents model linked here
  end

  def payments
    @charges = Charge.joins(:contract).where(contracts: { tenant_id: current_user.id }).order(due_date: :desc)
  end

  def support_requests
    # Placeholder for support requests logic
  end

  def signup_contract
    @contract = current_user.contracts.find(params[:id])
  end

  private

  def ensure_tenant
    unless current_user.inquilino? || current_user.admin?
      redirect_to root_path, alert: "Solo los inquilinos pueden acceder a esta sección."
    end
  end
end
