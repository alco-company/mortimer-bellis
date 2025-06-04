class Editor::BlocksController < ApplicationController
  def create
    @document = Editor::Document.find(params[:document_id])
    @block = @document.blocks.create!(
      type: params[:type],
      text: params[:text] || "#{params[:type]} #{@document.blocks.count + 1}",
      parent_id: params[:parent_id] || nil,
      position: next_position(params[:parent_id])
    )

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to editor_document_path(@document) }
    end
  end

  def reorder
    blocks = params[:ids].each_with_index.map do |id, index|
      block = Editor::Block.find(id)
      block.update!(position: index + 1)
      block
    end

    @document = blocks.first.document if blocks.any?

    respond_to do |format|
      format.turbo_stream
      format.json { head :ok }
    end
  end

  private
    def next_position(parent_id)
      scope = parent_id.present? ? Editor::Block.where(parent_id:) : @document.blocks.where(parent_id: nil)
      scope.maximum(:position).to_i + 1
    end
  # before_action :set_editor_block, only: %i[ show edit update destroy ]

  # # GET /editor/blocks or /editor/blocks.json
  # def index
  #   @editor_blocks = Editor::Block.all
  # end

  # # GET /editor/blocks/1 or /editor/blocks/1.json
  # def show
  # end

  # # GET /editor/blocks/new
  # def new
  #   @editor_block = Editor::Block.new
  # end

  # # GET /editor/blocks/1/edit
  # def edit
  # end

  # # POST /editor/blocks or /editor/blocks.json
  # def create
  #   @editor_block = Editor::Block.new(editor_block_params)

  #   respond_to do |format|
  #     if @editor_block.save
  #       format.html { redirect_to @editor_block, notice: "Block was successfully created." }
  #       format.json { render :show, status: :created, location: @editor_block }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @editor_block.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PATCH/PUT /editor/blocks/1 or /editor/blocks/1.json
  # def update
  #   respond_to do |format|
  #     if @editor_block.update(editor_block_params)
  #       format.html { redirect_to @editor_block, notice: "Block was successfully updated." }
  #       format.json { render :show, status: :ok, location: @editor_block }
  #     else
  #       format.html { render :edit, status: :unprocessable_entity }
  #       format.json { render json: @editor_block.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /editor/blocks/1 or /editor/blocks/1.json
  # def destroy
  #   @editor_block.destroy!

  #   respond_to do |format|
  #     format.html { redirect_to editor_blocks_path, status: :see_other, notice: "Block was successfully destroyed." }
  #     format.json { head :no_content }
  #   end
  # end

  # private
  #   # Use callbacks to share common setup or constraints between actions.
  #   def set_editor_block
  #     @editor_block = Editor::Block.find(params.expect(:id))
  #   end

  #   # Only allow a list of trusted parameters through.
  #   def editor_block_params
  #     params.expect(editor_block: [ :document_id, :parent_id, :type, :data, :position ])
  #   end
end
