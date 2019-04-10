class Account::Manage::CreditCardsController < ApplicationController
  layout :set_layout_by_role
  before_action :guard_center!
  before_action :set_account

  def new
    authorize @account, :dashboard?
  end

  def create
    authorize @account, :dashboard?

    begin
      customer = StripeCustomerService.new(@account).find_customer
      old_card = customer.sources.first

      new_card = customer.sources.create(source: params[:stripeToken])
      @account.update_attributes(
        card_brand: new_card.brand,
        card_last4: new_card.last4
      )

      old_card.delete

      redirect_to account_dashboard_credit_card_path(@account), notice: 'Card successfully changed.'
    rescue Stripe::CardError => e
      puts e.message
      puts e.backtrace
      flash[:notice] = e.message
      render :new
    rescue => e
      puts e.message
      puts e.backtrace
      flash[:error] = 'There seems to be a problem with your payment information. Please try again.'
      render :new
    end
  end

  def show
    customer = StripeCustomerService.new(@account).find_customer

    redirect_to new_account_dashboard_credit_card_path(@account) and return unless customer.present?

    card = customer.sources.first
    @card_info = {
      brand: card.brand,
      numbers: card.last4,
      expiration: "#{card.exp_month}/#{card.exp_year}"
    }
  end

  def destroy
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  # Only allow a trusted parameter "white list" through.
  def account_medical_form_params
    permitted_attributes = [
      :family_physician,
      :physician_phone,
      :family_dentist,
      :dentist_phone,
      :insurance_company,
      :insurance_policy_number,
      :medical_waiver_agreement
    ]
    params.require(:account_medical_form).permit(permitted_attributes)
  end
end
