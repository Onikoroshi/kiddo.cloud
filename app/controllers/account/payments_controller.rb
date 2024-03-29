class Account::PaymentsController < ApplicationController
  layout "dkk_customer_dashboard"
  before_action :guard_center!
  before_action :fetch_account

  def new
  end

  def create
    amount = ChildEnrollment::DropInPriceCalculator.new(@account).calculate

    # Token is created using Stripe.js or Checkout!
    # Get the payment token ID submitted by the form:
    token = params[:stripeToken]

    begin
      # Create a Customer:
      customer = StripeCustomerService.new(@account)
        .find_or_create_customer(token)

      if !current_user.legacy? && !current_user.legacy_dropin_chargeable?
        # Charge the Customer instead of the card:
        charge = Stripe::Charge.create(
          amount: amount.to_i * 100,
          currency: "usd",
          customer: customer.id,
        )
        flash[:notice] = "Card charged successfully."
      else
        flash[:notice] = "Payment method successfully stored."
      end
    rescue Exceptions::PaymentVerificationError, Stripe::CardError => e
      puts e.message
      puts e.backtrace
      flash[:notice] = "There seems to be a problem with your payment details. Please check and try again."
      return
    rescue => e
      puts e.message
      puts e.backtrace
      flash[:notice] = "An unspecified error occured."
      return
    end

    # YOUR CODE: Save the customer ID and other info in a database for later.

    # YOUR CODE (LATER): When it's time to charge the customer again, retrieve the customer ID.
    # charge = Stripe::Charge.create(
    #   :amount => 1500, # $15.00 this time
    #   :currency => "usd",
    #   :customer => customer_id, # Previously stored, then retrieved
    # )

    if !current_user.legacy? && !current_user.legacy_enrollment_chargeable?
      if charge.present?
        @account.record_step(:payment)
        @account.finalize_signup
        @account.drop_ins.each do |d|
          d.update_attributes(paid: true)
        end

        @account.transactions << Transaction.create(
          account: @account,
          program: @account.center.current_program,
          transaction_type: "drop in payment",
          month: Time.zone.now.month,
          year: Time.zone.now.year,
          amount: amount,
          paid: true,
        )

        redirect_to account_dashboard_path(@account), notice: "Thank you, your payment is complete. You will receive an email shortly with a payment receipt."
      else
        render :new
      end
    else
      @account.record_step(:payment)
      @account.finalize_signup
      redirect_to account_dashboard_path(@account), notice: "Thank you, your payment is complete. You will receive an email shortly with a payment receipt."
    end
  end

  private

  def fetch_account
    @account = Account.find(params[:account_id])
  end
end
