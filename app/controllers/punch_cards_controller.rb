class PunchCardsController < MortimerController
  # before_action :set_punch_card, only: %i[ show edit update destroy ]

  # # GET /punch_cards or /punch_cards.json
  # def index
  #   @punch_cards = PunchCard.all
  # end

  # # GET /punch_cards/1 or /punch_cards/1.json
  # def show
  # end

  # # GET /punch_cards/new
  # def new
  #   @punch_card = PunchCard.new
  # end

  # # GET /punch_cards/1/edit
  # def edit
  # end

  # # POST /punch_cards or /punch_cards.json
  # def create
  #   @punch_card = PunchCard.new(punch_card_params)

  #   respond_to do |format|
  #     if @punch_card.save
  #       format.html { redirect_to punch_card_url(@punch_card), notice: "Punch card was successfully created." }
  #       format.json { render :show, status: :created, location: @punch_card }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @punch_card.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PATCH/PUT /punch_cards/1 or /punch_cards/1.json
  # def update
  #   respond_to do |format|
  #     if @punch_card.update(punch_card_params)
  #       format.html { redirect_to punch_card_url(@punch_card), notice: "Punch card was successfully updated." }
  #       format.json { render :show, status: :ok, location: @punch_card }
  #     else
  #       format.html { render :edit, status: :unprocessable_entity }
  #       format.json { render json: @punch_card.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /punch_cards/1 or /punch_cards/1.json
  # def destroy
  #   @punch_card.destroy!

  #   respond_to do |format|
  #     format.html { redirect_to punch_cards_url, notice: "Punch card was successfully destroyed." }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Only allow a list of trusted parameters through.
    def resource_params
      params.require(:punch_card).permit(:account_id, :employee_id, :work_date, :work_minutes, :ot1_minutes, :ot2_minutes, :break_minutes, :punches_settled_at)
    end
end
