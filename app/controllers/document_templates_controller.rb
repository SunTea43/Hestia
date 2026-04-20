class DocumentTemplatesController < ApplicationController
  before_action :set_document_template, only: %i[ show edit update destroy ]
  after_action :verify_authorized

  def index
    @document_templates = policy_scope(DocumentTemplate).includes(:children, :parent).root
    authorize DocumentTemplate
  end

  def show
    authorize @document_template
    respond_to do |format|
      format.html
      format.json { render json: @document_template }
    end
  end

  def new
    @document_template = DocumentTemplate.new(parent_id: params[:parent_id])
    authorize @document_template
  end

  def edit
    authorize @document_template
  end

  def create
    @document_template = DocumentTemplate.new(document_template_params)
    authorize @document_template

    respond_to do |format|
      if @document_template.save
        format.html { redirect_to @document_template, notice: "Plantilla de documento creada exitosamente." }
        format.json { render :show, status: :created, location: @document_template }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @document_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @document_template
    respond_to do |format|
      if @document_template.update(document_template_params)
        format.html { redirect_to @document_template, notice: "Plantilla de documento actualizada exitosamente.", status: :see_other }
        format.json { render :show, status: :ok, location: @document_template }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @document_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @document_template
    @document_template.destroy!

    respond_to do |format|
      format.html { redirect_to document_templates_path, notice: "Plantilla de documento eliminada exitosamente.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_document_template
    @document_template = DocumentTemplate.find(params.expect(:id))
  end

  def document_template_params
    params.expect(document_template: [ :name, :description, :body, :parent_id, :document_type_id ])
  end
end
