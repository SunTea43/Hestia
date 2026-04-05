class DocumentsController < ApplicationController
  before_action :set_document, only: %i[ show edit update destroy ]
  after_action :verify_authorized

  # GET /documents or /documents.json
  def index
    @documents = policy_scope(Document).includes(:document_type, :property, :occupant)
    authorize Document
  end

  # GET /documents/1 or /documents/1.json
  def show
    authorize @document
  end

  # GET /documents/new
  def new
    @document = Document.new
    authorize @document
    @document.property_id = params[:property_id]
  end

  # GET /documents/1/edit
  def edit
    authorize @document
  end

  # POST /documents or /documents.json
  def create
    @document = Document.new(document_params)
    authorize @document

    respond_to do |format|
      if @document.save
        format.html { redirect_to @document, notice: "Documento creado exitosamente." }
        format.json { render :show, status: :created, location: @document }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documents/1 or /documents/1.json
  def update
    authorize @document
    respond_to do |format|
      if @document.update(document_params)
        format.html { redirect_to @document, notice: "Documento actualizado exitosamente.", status: :see_other }
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1 or /documents/1.json
  def destroy
    authorize @document
    @document.destroy!

    respond_to do |format|
      format.html { redirect_to documents_path, notice: "Documento eliminado exitosamente.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def document_params
      params.expect(document: [ :document_type_id, :property_id, :occupant_id, :name, :body, :status, :start_date, :end_date, :metadata ])
    end
end
