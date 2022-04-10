class Account::CheckoutsController < ApplicationController
  layout "dkk_customer_dashboard"
  before_action :guard_center!
  before_action :fetch_account

  def new
  end

  def create
    calculator = ChildEnrollment::EnrollmentPriceCalculator.new(@account)
    amount = calculator.calculate
    itemizations = calculator.itemize
    enrollments = calculator.enrollments
    recurring_enrollments = enrollments.recurring.to_a # freeze this list because the relation will change once they're paid

    if amount.to_i == 0 && calculator.requires_payment_information?
      flash[:error] = "Your children aren't enrolled in anything yet."
      redirect_to account_step_path(@account, :plan) and return
    end

    # Token is created using Stripe.js or Checkout!
    # Get the payment token ID submitted by the form:
    token = params[:stripeToken]

    customer = nil
    charge = nil

    if calculator.requires_payment_information?
      begin
        # Create a Customer:
        customer = StripeCustomerService.new(@account).find_or_create_customer(token)

        if !current_user.legacy? && !current_user.legacy_enrollment_chargeable?
          # Charge the Customer instead of the card:
          charge = Stripe::Charge.create(
            amount: amount.to_i * 100,
            currency: "usd",
            customer: customer.id,
          )
        end
      rescue Stripe::CardError => e
        puts e.message
        puts e.backtrace
        flash[:notice] = e.message
        redirect_to account_step_path(@account, :payment) and return
      rescue => e
        puts e.message
        puts e.backtrace
        flash[:error] = "There seems to be a problem with your payment information. Please try again."
        redirect_to account_step_path(@account, :payment) and return
      end
    end

    # YOUR CODE: Save the customer ID and other info in a database for later.

    # YOUR CODE (LATER): When it's time to charge the customer again, retrieve the customer ID.
    # charge = Stripe::Charge.create(
    #   :amount => 1500, # $15.00 this time
    #   :currency => "usd",
    #   :customer => customer_id, # Previously stored, then retrieved
    # )
    if charge.present?
      @account.update_attributes(
        gateway_customer_id: customer.id,
        card_brand: params[:account][:card_brand],
        card_exp_month: params[:account][:card_exp_month],
        card_exp_year: params[:account][:card_exp_year],
        card_last4: params[:account][:card_last4],
      )
    elsif calculator.requires_payment_information?
      render :new
      return
    end

    transaction = Transaction.create(
      account: @account,
      transaction_type: TransactionType[:one_time],
      month: Time.zone.now.month,
      year: Time.zone.now.year,
      gateway_id: charge.try(:id),
      amount: amount,
      paid: true,
      itemizations: itemizations
    )

    enrollments.each do |enrollment|
      enrollment.craft_enrollment_transactions(transaction)
    end

    @account.finalize_signup
    @account.record_step(:payment)

    if recurring_enrollments.any?
      next_due_enrollment = recurring_enrollments.map(&:reload).select{|e| e.next_payment_date.present?}.sort{|e| e.next_payment_date}.first

      if calculator.requires_payment_information?
        flash[:error] = "All of your enrollments have been finalized. Your card will not be charged again#{" until #{next_due_enrollment.next_payment_date.stamp("Jul. 28th, 2018")}" if next_due_enrollment.present?}. No further action is necessary on your part."
      end
    end

    TransactionalMailer.enrollment_change_report([transaction]).deliver_now

    generated_notice = nil
    if calculator.requires_payment_information?
      generated_notice = "Thank you, your payment is complete. You will receive a receipt for payment and welcome email to your registered email address. If you don't receive these, please call our office (1-530-220-4731)"
    else
      generated_notice = "Thank you, your registration is complete. You will receive a receipt and welcome email to your registered email address. If you don't receive these, please call our office (1-530-220-4731)"
    end

    redirect_to account_dashboard_path(@account), notice: generated_notice
  end

  private

  def fetch_account
    @account = Account.find(params[:account_id])
  end
end
