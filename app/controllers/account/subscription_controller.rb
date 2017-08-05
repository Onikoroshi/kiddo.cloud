class Account::SubscriptionController < ApplicationController
  before_action :guard_center!
  before_action :set_account

  # GET /account/children/1
  def show
  end

  # GET /account/children/new
  def new
    @subscription = Subscription.new
  end

  # GET /account/children/1/edit
  def edit
  end

  # POST /account/children
  def create
    subscription = StripeSubscriptionService.new(@account, params[:stripeToken]).subscribe

    if subscription.present?
      @account.record_step(:payment)
      @account.finalize_signup
      @account.mark_paid!
      redirect_to account_dashboard_path(@account), notice: 'Congratuations!'
    else
      render :new
    end
  end

  # PATCH/PUT /account/children/1
  def update
    if @account_child.update(account_child_params)
      redirect_to account_dashboard_path(@account), notice: 'Congratuations!'
    else

      render :edit
    end
  end

  # DELETE /account/children/1
  def destroy
    @subscription.destroy
    redirect_to account_children_path(@account), notice: 'Child was successfully removed.'
  end

  private

    def set_account
      @account = Account.find(params[:account_id])
    end

    # Only allow a trusted parameter "white list" through.
    def account_child_params
      permitted_attributes = [
       :first_name,
       :last_name,
       :gender,
       :grade_entering,
       :birthdate,
       :additional_info,
       care_items_attributes: [:id, :name, :active, :explanation]
      ]
      params.require(:child).permit(permitted_attributes)
    end
end
