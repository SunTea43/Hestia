class ContractsController < ApplicationController
  before_action :authenticate_user!

  def index
    company_ids = current_user.admin? ? Company.pluck(:id) : current_user.company_ids
    @contracts = Contract.joins(:property).where(properties: { company_id: company_ids })
  end

  def show
    @contract = Contract.find(params[:id])
  end

  def new
    @contract = Contract.new
    company_ids = current_user.admin? ? Company.pluck(:id) : current_user.company_ids
    @properties = Property.where(company_id: company_ids, category: :rent)
    @occupants = Occupant.all

    # Pre-select property if provided
    if params[:property_id].present?
      @contract.property_id = params[:property_id]
    end
  end

  def create
    @contract = Contract.new(contract_params)
    if @contract.save
      redirect_to @contract, notice: "Contrato creado exitosamente. Se ha enviado una notificación al inquilino."
    else
      company_ids = current_user.admin? ? Company.pluck(:id) : current_user.company_ids
      @properties = Property.where(company_id: company_ids, category: :rent)
      @occupants = Occupant.all
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contract_params
    params.require(:contract).permit(:property_id, :occupant_id, :start_date, :end_date, :tenant_income, :co_debtor_info)
  end
end
