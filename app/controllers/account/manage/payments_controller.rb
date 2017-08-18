class Account::Manage::PaymentsController < ApplicationController
  layout "dkk_customer_dashboard"
  before_action :guard_center!
  before_action :fetch_account

  def new
  end

  def create

    amount = ChildEnrollment::DropInPriceCalculator.new(@account.children, @account.center.current_program).calculate

    # Token is created using Stripe.js or Checkout!
    # Get the payment token ID submitted by the form:
    token = params[:stripeToken]

    begin
      # Create a Customer:
      customer = StripeCustomerService.new(@account).find_or_create_customer(token)

      # Charge the Customer instead of the card:
      charge = Stripe::Charge.create(
        :amount => amount.to_i * 100,
        :currency => "usd",
        :customer => customer.id,
      )

    rescue Stripe::CardError => e
      puts e.message
      puts e.backtrace
      flash[:notice] = e.message
      redirect_to new_account_dashboard_payment_path(@account) and return
    rescue => e
      puts e.message
      puts e.backtrace
      flash[:error] = 'There seems to be a problem with your payment information. Please try again.'
      redirect_to new_account_dashboard_payment_path(@account) and return
    end

    if charge.present?
      @account.drop_ins.where(paid: false).map { |d| d.update_attributes(paid: true) }
      @account.transactions << Transaction.create(
        account: @account,
        program: @account.center.current_program,
        transaction_type: "dropin payment",
        month: Time.zone.now.month,
        year: Time.zone.now.year,
        amount: amount,
        paid: true
      )
      redirect_to my_dropins_account_dashboard_path(@account), notice: 'Your drop-in days have been added'
    else
      render :new
    end
  end

  private

    def fetch_account
      @account = Account.find(params[:account_id])
    end

end
