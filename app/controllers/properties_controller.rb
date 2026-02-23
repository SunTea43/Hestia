class PropertiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_property, only: %i[show edit update destroy]
  after_action :verify_authorized

  def index
    @properties = policy_scope(Property)
    authorize Property
  end

  def show
    authorize @property
  end

  def new
    @property = Property.new
    authorize @property
    set_companies
  end

  def create
    @property = Property.new(property_params)
    authorize @property
    if @property.save
      redirect_to @property, notice: "Inmueble creado exitosamente."
    else
      set_companies
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @property
    set_companies
  end

  def update
    authorize @property
    if @property.update(property_params)
      redirect_to @property, notice: "Inmueble actualizado exitosamente."
    else
      set_companies
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @property
    @property.destroy
    redirect_to properties_url, notice: "Inmueble eliminado exitosamente."
  end

  private

  def set_property
    @property = Property.find(params[:id])
  end

  def set_companies
    @companies = current_user.admin? ? Company.all : current_user.companies
  end

  def property_params
    params.require(:property).permit(:company_id, :address, :area, :property_type, :category, :has_elevator, :common_areas, :price, :admin_fee_included, :description)
  end
end
