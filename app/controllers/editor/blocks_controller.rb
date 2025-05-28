class Editor::BlocksController < ApplicationController
  before_action :set_editor_block, only: %i[ show edit update destroy ]

  # GET /editor/blocks or /editor/blocks.json
  def index
    @editor_blocks = Editor::Block.all
  end

  # GET /editor/blocks/1 or /editor/blocks/1.json
  def show
  end

  # GET /editor/blocks/new
  def new
    @editor_block = Editor::Block.new
  end

  # GET /editor/blocks/1/edit
  def edit
  end

  # POST /editor/blocks or /editor/blocks.json
  def create
    @editor_block = Editor::Block.new(editor_block_params)

    respond_to do |format|
      if @editor_block.save
        format.html { redirect_to @editor_block, notice: "Block was successfully created." }
        format.json { render :show, status: :created, location: @editor_block }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @editor_block.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /editor/blocks/1 or /editor/blocks/1.json
  def update
    respond_to do |format|
      if @editor_block.update(editor_block_params)
        format.html { redirect_to @editor_block, notice: "Block was successfully updated." }
        format.json { render :show, status: :ok, location: @editor_block }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @editor_block.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /editor/blocks/1 or /editor/blocks/1.json
  def destroy
    @editor_block.destroy!

    respond_to do |format|
      format.html { redirect_to editor_blocks_path, status: :see_other, notice: "Block was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_editor_block
      @editor_block = Editor::Block.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def editor_block_params
      params.expect(editor_block: [ :document_id, :parent_id, :type, :data, :position ])
    end
end
