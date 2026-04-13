class OccupantsController < ApplicationController
  before_action :set_occupant, only: %i[show edit update destroy]
  after_action :verify_authorized

  def index
    @occupants = policy_scope(Occupant)
    authorize Occupant
  end

  def show
    authorize @occupant
    respond_to do |format|
      format.html
      format.json { render json: @occupant }
    end
  end

  def new
    @occupant = Occupant.new
    authorize @occupant
  end

  def create
    @occupant = Occupant.new(occupant_params)
    authorize @occupant

    respond_to do |format|
      if @occupant.save
        format.html { redirect_to @occupant, notice: "Ocupante creado exitosamente." }
        format.json { render :show, status: :created, location: @occupant }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @occupant.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    authorize @occupant
  end

  def update
    authorize @occupant
    respond_to do |format|
      if @occupant.update(occupant_params)
        format.html { redirect_to @occupant, notice: "Ocupante actualizado exitosamente." }
        format.json { render :show, status: :ok, location: @occupant }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @occupant.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @occupant
    @occupant.destroy!
    respond_to do |format|
      format.html { redirect_to occupants_url, notice: "Ocupante eliminado exitosamente." }
      format.json { head :no_content }
    end
  end

  private

  def set_occupant
    @occupant = Occupant.find(params[:id])
  end

  def occupant_params
    params.expect(occupant: [ :name, :email, :phone, :document_number ])
  end
end
