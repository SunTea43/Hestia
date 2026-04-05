class PortalController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_tenant
  before_action :set_current_occupant

  def dashboard
    @documents = @current_occupant&.documents&.includes(:property, :document_type) || []
    @recent_charges = Charge.joins(:document)
                            .where(documents: { occupant_id: @current_occupant&.id })
                            .order(due_date: :desc).limit(5)
  end

  def documents
    @documents = @current_occupant&.documents&.includes(:property, :document_type) || []
  end

  def payments
    @charges = Charge.joins(:document)
                     .where(documents: { occupant_id: @current_occupant&.id })
                     .order(due_date: :desc)
  end

  def support_requests
    # Placeholder for support requests logic
  end

  def sign_document
    @document = @current_occupant&.documents&.find(params[:id])
  end

  private

  def set_current_occupant
    @current_occupant = Occupant.find_by(email: current_user.email)
  end

  def ensure_tenant
    unless current_user.inquilino? || current_user.admin?
      redirect_to root_path, alert: "Solo los inquilinos pueden acceder a esta sección."
    end
  end
end
