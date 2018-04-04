class Account::Manage::PaymentsController < ApplicationController
  layout :set_layout_by_role
  before_action :guard_center!
  before_action :fetch_account

  def index
    @transactions = @account.transactions.reverse_chronological
  end

  def show
    @transaction = Transaction.find(params[:id])
  end

  def new
    authorize @account, :dashboard?
    @calculator = ChildEnrollment::EnrollmentPriceCalculator.new(@account)
    @calculator.calculate
  end

  def create
    authorize @account, :dashboard?

    calculator = ChildEnrollment::EnrollmentPriceCalculator.new(@account)
    amount = calculator.calculate
    itemizations = calculator.itemize
    enrollments = calculator.enrollments

    # Token is created using Stripe.js or Checkout!
    # Get the payment token ID submitted by the form:
    token = params[:stripeToken]

    begin
      # Retrieve their Customer:
      customer = StripeCustomerService.new(@account).find_customer

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
      transaction = Transaction.create(
        account: @account,
        transaction_type: TransactionType[:one_time],
        month: Time.zone.now.month,
        year: Time.zone.now.year,
        amount: amount,
        paid: true,
        itemizations: itemizations
      )

      enrollments.each do |enrollment|
        EnrollmentTransaction.create(enrollment_id: enrollment.id, my_transaction_id: transaction.id, amount: enrollment.plan.price)
        enrollment.update_attribute(:paid, true)
      end

      redirect_to account_dashboard_payments_path(@account), notice: "Thank you, your payment is complete. You will receive a receipt for payment sent to your registered email address. If you don't receive it, please call our office (1-530-220-4731)"
    else
      render :new
    end
  end

  private

  def fetch_account
    @account = Account.find(params[:account_id])
  end
end
