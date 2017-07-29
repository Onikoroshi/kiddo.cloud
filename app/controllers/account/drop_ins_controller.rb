class Account::DropInsController < ApplicationController
  before_action :guard_center!
  before_action :fetch_account
  before_action :fetch_drop_in, only: [:create, :edit, :update, :destroy]

  def step
    :plan
  end

  def new
    @account.children.each do |child|
      child.drop_ins << DropIn.where(account_id: @account.id).first_or_initialize
    end
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def fetch_drop_in
      @drop_in = DropIn.find(params[:id])
    end

    def fetch_account
      @account = Account.find(params[:account_id])
    end

    #  {"id"=>nil, "account_id"=>nil, "child_id"=>nil, "date"=>nil, "notes"=>nil, "price"=>nil, "created_at"=>nil, "updated_at"=>nil}
    # Only allow a trusted parameter "white list" through.
    # Only allow a trusted parameter "white list" through.
    def account_selection_params
      permitted_attributes = [
        children_attributes: [
          :id,
          drop_ins_attributes: [
            :id,
            :monday,
            :tuesday,
            :wednesday,
            :thursday,
            :friday,
            :saturday,
            :sunday,
          ],
        ]
      ]
      params.require(:account).permit(permitted_attributes)
    end

end
