class Editor::DocumentsController < ApplicationController
  before_action :set_editor_document, only: %i[ show edit update destroy ]

  # GET /editor/documents or /editor/documents.json
  def index
    @editor_documents = Editor::Document.all
  end

  # GET /editor/documents/1 or /editor/documents/1.json
  def show
  end

  # GET /editor/documents/new
  def new
    @editor_document = Editor::Document.new
  end

  # GET /editor/documents/1/edit
  def edit
  end

  # POST /editor/documents or /editor/documents.json
  def create
    @editor_document = Editor::Document.new(editor_document_params)

    respond_to do |format|
      if @editor_document.save
        format.html { redirect_to @editor_document, notice: "Document was successfully created." }
        format.json { render :show, status: :created, location: @editor_document }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @editor_document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /editor/documents/1 or /editor/documents/1.json
  def update
    respond_to do |format|
      if @editor_document.update(editor_document_params)
        format.html { redirect_to @editor_document, notice: "Document was successfully updated." }
        format.json { render :show, status: :ok, location: @editor_document }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @editor_document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /editor/documents/1 or /editor/documents/1.json
  def destroy
    @editor_document.destroy!

    respond_to do |format|
      format.html { redirect_to editor_documents_path, status: :see_other, notice: "Document was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_editor_document
      @editor_document = Editor::Document.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def editor_document_params
      params.expect(editor_document: [ :title ])
    end
end
