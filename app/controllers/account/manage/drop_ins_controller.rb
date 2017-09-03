class Account::Manage::DropInsController < ApplicationController
  layout "dkk_customer_dashboard"
  before_action :guard_center!
  before_action :fetch_account

  def index
    authorize @account, :dashboard?
  end

  def new
    authorize @account, :dashboard?
    @account.drop_ins.where(paid: false).destroy_all # clear out any drop ins that have been created but not paid for
  end

  def create
    authorize @account, :dashboard?
    @account.validate_location = true
    @account.assign_attributes(new_drop_in_params)

    if @account.save
      redirect_to new_account_dashboard_payment_path(@account),  notice: "Great! Now let's pay."
    else
      render :new
    end
  end

  def edit
    authorize @account, :dashboard?
    pre_load_drop_ins
  end

  def update
    authorize @account, :dashboard?
    @account.validate_location = true
    @account.update_attributes(edit_drop_in_params)

    if @account.save
      @account.record_step(:plan)
      redirect_to account_step_path(@account, :summary), notice: "Great! You're all signed up. Let's review."
    else
      render :new
    end
  end

  def destroy
    authorize @account, :dashboard?
    @drop_in = DropIn.find_by(id: params[:drop_in_id])
    @drop_in.destroy
    redirect_to my_dropins_account_dashboard_path, notice: 'This drop-in date has been removed'
  end

  private

    def fetch_account
      @account = Account.find(params[:account_id])
    end

    def children_have_dropins?
      exist = false
      @account.children.each do |c|
        exist = true if c.drop_ins.any?
      end
      exist
    end

    def pre_load_drop_ins
      @account.children.each do |child|
        child.drop_ins.build unless child.drop_ins.any?
      end
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
            :account_id,
            :program_id,
            :time_slot
          ],
        ]
      ]
      params.require(:account).permit(permitted_attributes)
    end

    def edit_drop_in_params
      permitted_attributes = [
        children_attributes: [
          :id,
          drop_ins_attributes: [
            :id,
            :date,
            :account_id,
            :program_id,
            :time_slot,
            :_destroy
          ],
        ]
      ]
      params.require(:account).permit(permitted_attributes)
    end

end
