class TimeDisputesController < ApplicationController
  before_action :set_time_dispute, only: [:show, :edit, :update, :destroy]

  # GET /time_disputes
  # GET /time_disputes.json
  def index
    @time_disputes = TimeDispute.all
  end

  # GET /time_disputes/1
  # GET /time_disputes/1.json
  def show
  end

  # GET /time_disputes/new
  def new
    @time_dispute = TimeDispute.new
  end

  # GET /time_disputes/1/edit
  def edit
  end

  # POST /time_disputes
  # POST /time_disputes.json
  def create
    @time_dispute = TimeDispute.new(time_dispute_params)

    respond_to do |format|
      if @time_dispute.save
        format.html { redirect_to @time_dispute, notice: 'Time dispute was successfully created.' }
        format.json { render :show, status: :created, location: @time_dispute }
      else
        format.html { render :new }
        format.json { render json: @time_dispute.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /time_disputes/1
  # PATCH/PUT /time_disputes/1.json
  def update
    respond_to do |format|
      if @time_dispute.update(time_dispute_params)
        format.html { redirect_to @time_dispute, notice: 'Time dispute was successfully updated.' }
        format.json { render :show, status: :ok, location: @time_dispute }
      else
        format.html { render :edit }
        format.json { render json: @time_dispute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /time_disputes/1
  # DELETE /time_disputes/1.json
  def destroy
    @time_dispute.destroy
    respond_to do |format|
      format.html { redirect_to time_disputes_url, notice: 'Time dispute was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_time_dispute
      @time_dispute = TimeDispute.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def time_dispute_params
      params.require(:time_dispute).permit(:first_name, :last_name, :email, :phone, :date, :location_id, :message)
    end
end
