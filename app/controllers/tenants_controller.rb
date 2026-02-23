class TenantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tenant, only: %i[show edit update]
  # after_action :verify_authorized

  def index
    # For now, show all tenants registered in properties of companies managed by current_user
    company_ids = current_user.company_ids
    @tenants = User.inquilino.joins(contracts: :property).where(properties: { company_id: company_ids }).distinct
  end

  def show
  end

  def new
    @tenant = User.new(role: :inquilino)
  end

  def create
    @tenant = User.new(tenant_params)
    @tenant.role = :inquilino
    @tenant.password = Devise.friendly_token[0, 20] # Or a default password

    if @tenant.save
      redirect_to tenants_path, notice: "Inquilino registrado exitosamente. Se ha enviado un correo para configurar su contraseña."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @tenant.update(tenant_params)
      redirect_to @tenant, notice: "Inquilino actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_tenant
    @tenant = User.find(params[:id])
  end

  def tenant_params
    params.require(:user).permit(:name, :email, :document_number, :birth_date, :phone)
  end
end
