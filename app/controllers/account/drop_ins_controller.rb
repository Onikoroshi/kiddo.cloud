class Account::DropInsController < ApplicationController
  before_action :guard_center!
  before_action :fetch_account

  def step
    :plan
  end

  def new
    @account.children.each do |child|
      child.drop_ins << DropIn.where(account_id: @account.id).first_or_initialize
    end
  end

  def create
    @account.assign_attributes(new_drop_in_params)

    if @account.save
      @account.record_step(:plan)
      redirect_to account_step_path(@account, :summary), notice: "Great! You're all signed up. Let's review."
    else
      render :new
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

    def fetch_account
      @account = Account.find(params[:account_id])
    end

    #  {"id"=>nil, "account_id"=>nil, "child_id"=>nil, "date"=>nil, "notes"=>nil, "price"=>nil, "created_at"=>nil, "updated_at"=>nil}
    # Only allow a trusted parameter "white list" through.
    # Only allow a trusted parameter "white list" through.
    def new_drop_in_params
      permitted_attributes = [
        children_attributes: [
          :id,
          drop_ins_attributes: [
            :date,
            :account_id
          ],
        ]
      ]
      params.require(:account).permit(permitted_attributes)
    end

end
