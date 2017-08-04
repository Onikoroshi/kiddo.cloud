class Account::DropInsController < ApplicationController
  before_action :guard_center!
  before_action :fetch_account

  def step
    :plan
  end

  def new
    redirect_to edit_account_drop_ins_path(@account) and return if children_have_dropins?
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
    pre_load_drop_ins
  end

  def update
    @account.update_attributes(edit_drop_in_params)

    if @account.save
      @account.record_step(:plan)
      redirect_to account_step_path(@account, :summary), notice: "Great! You're all signed up. Let's review."
    else
      render :new
    end
  end

  def destroy
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
            :program_id
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
            :_destroy
          ],
        ]
      ]
      params.require(:account).permit(permitted_attributes)
    end

end
