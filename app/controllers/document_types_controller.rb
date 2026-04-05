class DocumentTypesController < ApplicationController
  before_action :set_document_type, only: %i[ show edit update destroy ]
  after_action :verify_authorized

  # GET /document_types or /document_types.json
  def index
    @document_types = policy_scope(DocumentType)
    authorize DocumentType
  end

  # GET /document_types/1 or /document_types/1.json
  def show
    authorize @document_type
  end

  # GET /document_types/new
  def new
    @document_type = DocumentType.new
    authorize @document_type
  end

  # GET /document_types/1/edit
  def edit
    authorize @document_type
  end

  # POST /document_types or /document_types.json
  def create
    @document_type = DocumentType.new(document_type_params)
    authorize @document_type

    respond_to do |format|
      if @document_type.save
        format.html { redirect_to @document_type, notice: "Tipo de documento creado exitosamente." }
        format.json { render :show, status: :created, location: @document_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @document_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /document_types/1 or /document_types/1.json
  def update
    authorize @document_type
    respond_to do |format|
      if @document_type.update(document_type_params)
        format.html { redirect_to @document_type, notice: "Tipo de documento actualizado exitosamente.", status: :see_other }
        format.json { render :show, status: :ok, location: @document_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @document_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /document_types/1 or /document_types/1.json
  def destroy
    authorize @document_type
    @document_type.destroy!

    respond_to do |format|
      format.html { redirect_to document_types_path, notice: "Tipo de documento eliminado exitosamente.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document_type
      @document_type = DocumentType.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def document_type_params
      params.expect(document_type: [ :name, :description, :icon, :color ])
    end
end
