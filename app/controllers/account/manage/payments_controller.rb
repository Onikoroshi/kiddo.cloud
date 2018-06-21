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

    calculator = ChildEnrollment::EnrollmentPriceCalculator.new(@account, params.permit!.to_h)
    calculator.calculate
    recurring_enrollments = calculator.enrollments.recurring.to_a # freeze this list because the relation will change once they're paid

    # Token is created using Stripe.js or Checkout!
    # Get the payment token ID submitted by the form:
    token = params[:stripeToken]
    customer = StripeCustomerService.new(@account).find_or_create_customer(token)

    begin
      charge_transaction = handle_charges(calculator, customer)
      handle_refunds(calculator, customer, charge_transaction)
      send_emails(charge_transaction)
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

    if recurring_enrollments.any?
      flash[:error] = "All of your enrollments have been finalized. Your card will not be charged again until #{recurring_enrollments.map(&:reload).sort{|e| e.next_payment_date}.last.next_payment_date.stamp("Jul. 28th, 2018")}. No further action is necessary on your part."
    end

    unless @account.signup_complete?
      @account.finalize_signup
      @account.record_step(:payment)
    end

    TransactionalMailer.enrollment_change_report(charge_transaction).deliver_now

    redirect_to account_dashboard_payments_path(@account), notice: "Thank you, your payment is complete. You will receive a receipt for payment sent to your registered email address. If you don't receive it, please call our office (1-530-220-4731)"
  end

  private

  def fetch_account
    @account = Account.find(params[:account_id])
  end

  def send_emails(transaction)
    program_ids = transaction.itemizations.keys.select{|key| key.to_s.include?("signup_fee_")}.map{|key| key.to_s.gsub("signup_fee_", "")}

    signed_up_programs = Program.where(id: program_ids).distinct
    TransactionalMailer.welcome_summer_customer(@account).deliver_now if signed_up_programs.for_summer.any?
    TransactionalMailer.welcome_fall_customer(@account).deliver_now if signed_up_programs.for_fall.any?
  end

  def handle_charges(calculator, customer)
    amount = calculator.total

    charge = nil
    if amount > 0
      charge = Stripe::Charge.create(
        :amount => (amount * 100).to_i,
        :currency => "usd",
        :customer => customer.id,
      )
    end

    transaction = Transaction.create!(
      account: @account,
      transaction_type: TransactionType[:one_time],
      gateway_id: charge.present? ? charge.id : "",
      amount: amount,
      paid: true,
      itemizations: calculator.itemizations
    )

    calculator.enrollments.each do |enrollment|
      enrollment.craft_enrollment_transactions(transaction, calculator.find_altered_enrollment_cost(enrollment))
    end

    calculator.enrollment_changes.generating_charge.each do |enrollment_change|
      EnrollmentChangeTransaction.create!(enrollment_change_id: enrollment_change.id, my_transaction_id: transaction.id, amount: enrollment_change.charge_amount)
    end

    transaction
  end

  def handle_refunds(calculator, customer, charge_transaction)
    target_transactions = calculator.enrollment_changes.transactions
    target_transactions.each do |original_transaction|
      trans_changes = original_transaction.pending_enrollment_changes

      refund_amount = trans_changes.refund_total
      refund_transaction = nil

      if refund_amount > 0
        refund = Stripe::Refund.create(
          :charge => original_transaction.gateway_id,
          :amount => (refund_amount * 100).to_i,
        )

        refund_transaction = Transaction.create!(
          account: @account,
          transaction_type: TransactionType[:refund],
          parent: original_transaction,
          gateway_id: refund.id,
          amount: refund_amount,
          paid: true,
          itemizations: {}
        )
      end

      trans_changes.each do |enrollment_change|
        target_transaction = refund_transaction.present? ? refund_transaction : charge_transaction
        if target_transaction.present?
          EnrollmentChangeTransaction.create!(enrollment_change_id: enrollment_change.id, my_transaction_id: target_transaction.id, amount: enrollment_change.refund_amount)
        end

        enrollment_change.apply_to_enrollment!
      end
    end
  end
end
